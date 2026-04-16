#!/usr/bin/env bash
# =============================================================================
# sf agent preview — Interactive Chat Demo
#
# Usage:  ./scripts/demo-preview.sh [org-alias] [bundle-name]
#         Defaults: org=agentdev  bundle=OrderManagement
#
# Type messages, see agent responses. Type "quit" or "exit" to end.
# =============================================================================

set -euo pipefail

ORG="${1:-agentdev}"
BUNDLE="${2:-OrderManagement}"

BOLD=$(tput bold)
DIM=$(tput dim)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
MAGENTA=$(tput setaf 5)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

clear

printf "\n"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s  sf agent preview — Interactive Chat%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s  Agent: %s  |  Org: %s%s\n" "${CYAN}" "${BUNDLE}" "${ORG}" "${RESET}"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "\n"

# ---- start session ----
printf "  %sStarting preview session...%s\n" "${DIM}" "${RESET}"
printf "  %s\$ sf agent preview start --json --authoring-bundle %s -o %s%s\n" "${YELLOW}" "${BUNDLE}" "${ORG}" "${RESET}"
printf "\n"

START_OUTPUT=$(sf agent preview start --json --authoring-bundle "$BUNDLE" -o "$ORG" 2>/dev/null)
SESSION_ID=$(printf '%s' "$START_OUTPUT" | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['sessionId'])")

if [ -z "$SESSION_ID" ]; then
  printf "  %sFailed to start session.%s\n" "${RED}" "${RESET}"
  printf '%s\n' "$START_OUTPUT"
  exit 1
fi

printf "  %sSession: %s%s\n" "${GREEN}" "${SESSION_ID}" "${RESET}"
printf "\n"
printf "%s──────────────────────────────────────────────────────────────────────%s\n" "${DIM}" "${RESET}"
printf "  %sType a message and press Enter. Type %squit%s%s to end the session.%s\n" "${DIM}" "${BOLD}" "${RESET}" "${DIM}" "${RESET}"
printf "%s──────────────────────────────────────────────────────────────────────%s\n" "${DIM}" "${RESET}"
printf "\n"

# ---- chat loop ----
while true; do
  printf "  %sYou > %s" "${BOLD}${GREEN}" "${RESET}"
  read -r UTTERANCE

  if [ -z "$UTTERANCE" ]; then
    continue
  fi

  if [ "$UTTERANCE" = "quit" ] || [ "$UTTERANCE" = "exit" ]; then
    break
  fi

  # send utterance
  RESPONSE=$(sf agent preview send --json \
    --authoring-bundle "$BUNDLE" \
    --session-id "$SESSION_ID" \
    --utterance "$UTTERANCE" \
    -o "$ORG" 2>/dev/null)

  # parse and display agent response
  printf "\n"
  printf '%s' "$RESPONSE" | python3 -c "
import json, sys, re
raw = sys.stdin.read()
clean = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f]', '', raw)
try:
    d = json.loads(clean)
    msgs = d.get('result', {}).get('messages', [])
    if msgs:
        for m in msgs:
            print(f'  Agent > {m.get(\"message\", \"(no message)\")}')
    else:
        print('  Agent > (no response)')
except Exception as e:
    print(f'  Agent > (error parsing response: {e})')
"
  printf "\n"
done

# ---- end session ----
printf "\n"
printf "%s──────────────────────────────────────────────────────────────────────%s\n" "${DIM}" "${RESET}"
printf "  %sEnding session and collecting traces...%s\n" "${DIM}" "${RESET}"
printf "  %s\$ sf agent preview end --json --authoring-bundle %s --session-id %s -o %s%s\n" "${YELLOW}" "${BUNDLE}" "${SESSION_ID}" "${ORG}" "${RESET}"
printf "\n"

END_OUTPUT=$(sf agent preview end --json \
  --authoring-bundle "$BUNDLE" \
  --session-id "$SESSION_ID" \
  -o "$ORG" 2>/dev/null)

TRACES_PATH=$(printf '%s' "$END_OUTPUT" | python3 -c "import json,sys; print(json.load(sys.stdin)['result']['tracesPath'])" 2>/dev/null || printf "")

if [ -z "$TRACES_PATH" ] || [ ! -d "$TRACES_PATH/traces" ]; then
  printf "  %sSession ended. No trace files found.%s\n" "${DIM}" "${RESET}"
  printf "\n"
  exit 0
fi

printf "  %sTraces: %s%s\n" "${GREEN}" "${TRACES_PATH}" "${RESET}"
printf "\n"

# ---- trace analysis ----
read -r -s -p "$(printf '%s  ▶ Press Enter to see trace analysis...%s' "${GREEN}" "${RESET}")"
printf "\n\n"

printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s  Trace Analysis%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "\n"

# topic routing
printf "  %sTopic Routing%s\n" "${BOLD}${MAGENTA}" "${RESET}"
printf "\n"
for f in "$TRACES_PATH"/traces/*.json; do
  python3 -c "
import json
d=json.load(open('$f'))
topic=d.get('topic','?')
for s in d.get('plan',[]):
    if s.get('type')=='UserInputStep':
        utt=s.get('message','')[:55]
        print(f'  {utt:<55}  ->  {topic}')
        break
"
done
printf "\n"

read -r -s -p "$(printf '%s  ▶ Press Enter to see safety scores...%s' "${GREEN}" "${RESET}")"
printf "\n\n"

# safety scores
printf "  %sSafety Scores%s\n" "${BOLD}${MAGENTA}" "${RESET}"
printf "\n"
for f in "$TRACES_PATH"/traces/*.json; do
  python3 -c "
import json
d=json.load(open('$f'))
utt=''
for s in d.get('plan',[]):
    if s.get('type')=='UserInputStep':
        utt=s.get('message','')[:45]
        break
for s in d.get('plan',[]):
    if s.get('type')=='PlannerResponseStep':
        score=s.get('safetyScore',{}).get('safetyScore',{}).get('safety_score','N/A')
        safe='yes' if s.get('isContentSafe') else 'no'
        print(f'  {utt:<45}  safety={score}  safe={safe}')
        break
"
done
printf "\n"

read -r -s -p "$(printf '%s  ▶ Press Enter to see variable changes...%s' "${GREEN}" "${RESET}")"
printf "\n\n"

# variable changes
printf "  %sVariable Changes%s\n" "${BOLD}${MAGENTA}" "${RESET}"
printf "\n"
for f in "$TRACES_PATH"/traces/*.json; do
  python3 -c "
import json
d=json.load(open('$f'))
changes=[]
for s in d.get('plan',[]):
    if s.get('type')=='VariableUpdateStep':
        for u in s.get('data',{}).get('variable_updates',[]):
            n=u.get('variable_name','')
            if not n.startswith('AgentScript') and not n.startswith('__'):
                o=u.get('variable_past_value','')
                v=u.get('variable_new_value','')
                if str(o)!=str(v):
                    changes.append(f'    {n}: {o} -> {v}')
if changes:
    for s in d.get('plan',[]):
        if s.get('type')=='UserInputStep':
            print(f'  [{s.get(\"message\",\"\")[:50]}]')
            break
    for c in changes:
        print(c)
    print()
"
done

read -r -s -p "$(printf '%s  ▶ Press Enter to see action invocations...%s' "${GREEN}" "${RESET}")"
printf "\n\n"

# action invocations
printf "  %sAction Invocations%s\n" "${BOLD}${MAGENTA}" "${RESET}"
printf "\n"
for f in "$TRACES_PATH"/traces/*.json; do
  python3 -c "
import json
d=json.load(open('$f'))
utt=''
for s in d.get('plan',[]):
    if s.get('type')=='UserInputStep':
        utt=s.get('message','')[:45]
        break
actions=[]
for s in d.get('plan',[]):
    if s.get('type')=='LLMStep':
        for rm in s.get('response_messages',[]):
            ti=rm.get('tool_invocation',{})
            if ti.get('name'):
                actions.append(ti['name'])
if actions:
    print(f'  {utt:<45}  actions: {\", \".join(actions)}')
else:
    print(f'  {utt:<45}  actions: (text response only)')
"
done
printf "\n"

# done
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s  Session complete. Traces saved to:%s\n" "${BOLD}" "${RESET}"
printf "  %s%s%s\n" "${DIM}" "${TRACES_PATH}" "${RESET}"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "\n"
