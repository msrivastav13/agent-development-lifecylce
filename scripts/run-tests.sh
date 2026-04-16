#!/usr/bin/env bash
# =============================================================================
# Run OrderManagement Smoke Tests — Deploy, Execute, Display Results
#
# Usage:  ./scripts/run-tests.sh [org-alias]
#         Default org alias: agentdev
#
# Known issue: sf CLI plugin-agent v1.32.x can crash with a RETRY enum error
# when polling results. This script works around it by calling the REST API
# directly when the CLI fails.
# =============================================================================

set -euo pipefail

ORG="${1:-agentdev}"
SPEC="tests/OrderManagement-smoke.yaml"
API_NAME="OrderManagement_Smoke"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPEC_PATH="$PROJECT_ROOT/$SPEC"

BOLD=$(tput bold)
DIM=$(tput dim)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

SPINNER_CHARS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

# ---- grab org credentials once ----
ORG_JSON=$(sf org display -o "$ORG" --json 2>/dev/null)
ACCESS_TOKEN=$(printf '%s' "$ORG_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['accessToken'])")
INSTANCE_URL=$(printf '%s' "$ORG_JSON" | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['instanceUrl'])")
API_VERSION="v63.0"

printf "\n"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s  OrderManagement Smoke Tests%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s  Org: %s  |  Spec: %s%s\n" "${CYAN}" "${ORG}" "${SPEC}" "${RESET}"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "\n"

# ---- step 1: deploy ----
printf "  %s[1/3] Deploying test suite%s\n" "${BOLD}" "${RESET}"
printf "  %s\$ sf agent test create --spec %s --api-name %s --force-overwrite -o %s%s\n" "${YELLOW}" "${SPEC}" "${API_NAME}" "${ORG}" "${RESET}"

CREATE_OUT=$(sf agent test create --json \
  --spec "$SPEC_PATH" \
  --api-name "$API_NAME" \
  --force-overwrite \
  -o "$ORG" 2>/dev/null)

CREATE_STATUS=$(printf '%s' "$CREATE_OUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',1))")
if [ "$CREATE_STATUS" = "0" ]; then
  printf "  %s✓ Test suite created%s\n" "${GREEN}" "${RESET}"
else
  printf "  %s✗ Create failed%s\n" "${RED}" "${RESET}"
  printf '%s\n' "$CREATE_OUT" | python3 -m json.tool 2>/dev/null || printf '%s\n' "$CREATE_OUT"
  exit 1
fi

# also push the metadata so the org has the latest utterances
printf "  %s\$ sf project deploy start --metadata AiEvaluationDefinition:%s -o %s%s\n" "${YELLOW}" "${API_NAME}" "${ORG}" "${RESET}"
DEPLOY_OUT=$(sf project deploy start --json --metadata "AiEvaluationDefinition:$API_NAME" -o "$ORG" 2>/dev/null)
DEPLOY_STATUS=$(printf '%s' "$DEPLOY_OUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('result',{}).get('status','?'))")
printf "  %s✓ Metadata deployed (%s)%s\n\n" "${GREEN}" "${DEPLOY_STATUS}" "${RESET}"

# ---- step 2: start the run ----
printf "  %s[2/3] Starting test run%s\n" "${BOLD}" "${RESET}"
printf "  %s\$ sf agent test run --api-name %s --result-format json -o %s%s\n" "${YELLOW}" "${API_NAME}" "${ORG}" "${RESET}"

RUN_OUT=$(sf agent test run --json \
  --api-name "$API_NAME" \
  --result-format json \
  -o "$ORG" 2>/dev/null)

JOB_ID=$(printf '%s' "$RUN_OUT" | python3 -c "
import json, sys
d = json.load(sys.stdin)
r = d.get('result', {})
print(r.get('runId', r.get('jobId', '')))
" 2>/dev/null || printf "")

if [ -z "$JOB_ID" ]; then
  printf "  %s✗ Failed to start test run%s\n" "${RED}" "${RESET}"
  printf '%s\n' "$RUN_OUT" | python3 -m json.tool 2>/dev/null || printf '%s\n' "$RUN_OUT"
  exit 1
fi

printf "  %s✓ Job ID: %s%s\n\n" "${GREEN}" "${JOB_ID}" "${RESET}"

# ---- step 3: poll for results ----
printf "  %s[3/3] Waiting for results%s\n\n" "${BOLD}" "${RESET}"

MAX_POLLS=60        # 60 x 10s = 10 minutes max
POLL_INTERVAL=10
POLL_COUNT=0
SPIN_IDX=0
START_TIME=$(date +%s)
FINAL_JSON=""

# poll_results: try CLI first, fall back to REST API on error
poll_results() {
  local RAW
  # try the CLI
  RAW=$(sf agent test results --json \
    --job-id "$JOB_ID" \
    --result-format json \
    -o "$ORG" 2>&1 || true)

  # check if the CLI returned valid JSON with results
  local IS_VALID
  IS_VALID=$(printf '%s' "$RAW" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    if d.get('result', {}).get('testCases') is not None:
        print('OK')
    elif d.get('exitCode') or d.get('name'):
        print('CLI_ERROR')
    else:
        print('OK')
except:
    print('PARSE_ERROR')
" 2>/dev/null)

  if [ "$IS_VALID" = "OK" ]; then
    printf '%s' "$RAW"
    return
  fi

  # fallback: call the REST API directly
  RAW=$(curl -sf "${INSTANCE_URL}/services/data/${API_VERSION}/einstein/ai-evaluations/runs/${JOB_ID}" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" 2>/dev/null || printf '{}')

  # wrap it in the same shape the CLI would return
  printf '%s' "$RAW" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print(json.dumps({'status': 0, 'result': d}))
except:
    print(json.dumps({'status': 1, 'result': {}}))
"
}

while [ "$POLL_COUNT" -lt "$MAX_POLLS" ]; do
  NOW=$(date +%s)
  ELAPSED=$(( NOW - START_TIME ))
  MINS=$(( ELAPSED / 60 ))
  SECS=$(( ELAPSED % 60 ))

  SPIN_CHAR="${SPINNER_CHARS:SPIN_IDX:1}"
  SPIN_IDX=$(( (SPIN_IDX + 1) % ${#SPINNER_CHARS} ))

  printf "\r  %s %sRunning tests... %dm %02ds elapsed  (poll %d)%s    " \
    "${SPIN_CHAR}" "${DIM}" "${MINS}" "${SECS}" "$((POLL_COUNT + 1))" "${RESET}"

  RESULTS_OUT=$(poll_results)

  STATUS=$(printf '%s' "$RESULTS_OUT" | python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    r = d.get('result', {})
    cases = r.get('testCases', [])
    status = r.get('status', r.get('runStatus', ''))
    # check if any test case has actual results
    has_results = any(tc.get('testResults') for tc in cases)
    if has_results:
        print('DONE')
    elif status in ('COMPLETED', 'Completed', 'FAILED', 'Failed', 'ERROR', 'Error'):
        print('DONE')
    else:
        print('RUNNING')
except:
    print('RUNNING')
" 2>/dev/null || printf "RUNNING")

  if [ "$STATUS" = "DONE" ]; then
    FINAL_JSON="$RESULTS_OUT"
    break
  fi

  sleep "$POLL_INTERVAL"
  POLL_COUNT=$(( POLL_COUNT + 1 ))
done

# clear spinner
NOW=$(date +%s)
ELAPSED=$(( NOW - START_TIME ))
MINS=$(( ELAPSED / 60 ))
SECS=$(( ELAPSED % 60 ))

if [ -z "$FINAL_JSON" ]; then
  printf "\r  %s⏱ Timed out after %dm %02ds%s                              \n" "${YELLOW}" "${MINS}" "${SECS}" "${RESET}"
  printf "  %sThe test run is still going. Check manually:%s\n" "${DIM}" "${RESET}"
  printf "  %s\$ sf agent test results --json --job-id %s --result-format json -o %s%s\n\n" "${YELLOW}" "${JOB_ID}" "${ORG}" "${RESET}"
  exit 1
fi

printf "\r  %s✓ Completed in %dm %02ds%s                                    \n\n" "${GREEN}" "${MINS}" "${SECS}" "${RESET}"

# ---- display results ----
printf '%s' "$FINAL_JSON" | python3 -c "
import json, sys

d = json.load(sys.stdin)
r = d.get('result', {})
cases = r.get('testCases', [])
status = r.get('status', r.get('runStatus', '?'))

if not cases:
    print(f'  Status: {status}')
    print(f'  No test case results found.')
    sys.exit(0)

passed = 0
failed = 0
total = len(cases)

print(f'  {total} test cases  (status: {status})')
print()

hdr_utt = 'Utterance'
hdr_top = 'Topic'
hdr_act = 'Action'
hdr_out = 'Outcome'
print(f'  {hdr_utt:<52} {hdr_top:>8} {hdr_act:>8} {hdr_out:>8}')
print(f'  {chr(9472) * 52} {chr(9472) * 8} {chr(9472) * 8} {chr(9472) * 8}')

for tc in cases:
    utt = tc.get('inputs', {}).get('utterance', '(no utterance)')
    if not utt:
        utt = '(no utterance)'
    utt = utt[:50]

    test_results = tc.get('testResults', [])
    results = {}
    for tr in test_results:
        name = tr.get('name', '')
        result = tr.get('result', '?')
        # normalize assertion names (server may return different names)
        if 'topic' in name:
            results['topic'] = result
        elif 'action' in name:
            results['action'] = result
        elif 'output' in name or 'response' in name or 'bot_response' in name:
            results['outcome'] = result

    topic  = results.get('topic', '-')
    action = results.get('action', '-')
    outcome = results.get('outcome', '-')

    all_pass = all(v == 'PASS' for v in results.values() if v != '-')
    if all_pass and results:
        passed += 1
    elif not test_results:
        # no results yet — don't count as failed
        pass
    else:
        failed += 1

    print(f'  {utt:<52} {topic:>8} {action:>8} {outcome:>8}')

print()
print(f'  {chr(9472) * 80}')
print(f'  Passed: {passed}  |  Failed: {failed}  |  Total: {total}')
print()

if failed == 0 and passed > 0:
    print(f'  ✓ ALL TESTS PASSED')
elif failed == 0 and passed == 0:
    print(f'  ⚠ No assertion results returned — tests may need more time')
else:
    print(f'  ✗ {failed} TEST(S) FAILED')
"

printf "\n"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "\n"
