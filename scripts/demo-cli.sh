#!/usr/bin/env bash
# =============================================================================
# sf agent CLI Commands — Interactive Demo
#
# Usage:  ./scripts/demo-cli.sh
#
# Press Enter to reveal each command. Talk through it, then press Enter again.
# =============================================================================

set -euo pipefail

BOLD=$(tput bold)
DIM=$(tput dim)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

clear

printf "\n"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s  sf agent — CLI Commands%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "\n"

read -r -s -p "$(printf '%s  ▶ Press Enter to start...%s' "${GREEN}" "${RESET}")"
printf "\n"

# ---- 1 ----
printf "\n"
printf "  %s1. Generate%s\n" "${BOLD}" "${RESET}"
printf "  %sScaffold a new .agent + bundle-meta.xml%s\n" "${DIM}" "${RESET}"
printf "\n"
printf "  %s\$ sf agent generate authoring-bundle \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --no-spec \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --name \"Order Management\" \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --api-name OrderManagement%s\n" "${YELLOW}" "${RESET}"
printf "\n"

read -r -s -p "$(printf '%s  ▶ Press Enter to continue...%s' "${GREEN}" "${RESET}")"
printf "\n"

# ---- 2 ----
printf "\n"
printf "  %s2. Validate%s\n" "${BOLD}" "${RESET}"
printf "  %sLocal syntax and structure validation%s\n" "${DIM}" "${RESET}"
printf "\n"
printf "  %s\$ sf agent validate authoring-bundle \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --json \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --api-name OrderManagement%s\n" "${YELLOW}" "${RESET}"
printf "\n"

read -r -s -p "$(printf '%s  ▶ Press Enter to continue...%s' "${GREEN}" "${RESET}")"
printf "\n"

# ---- 3 ----
printf "\n"
printf "  %s3. Publish%s\n" "${BOLD}" "${RESET}"
printf "  %sCreate runtime entities from the bundle (Bot, BotVersion, GenAiPlannerBundle)%s\n" "${DIM}" "${RESET}"
printf "\n"
printf "  %s\$ sf agent publish authoring-bundle \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --json \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --api-name OrderManagement%s\n" "${YELLOW}" "${RESET}"
printf "\n"

read -r -s -p "$(printf '%s  ▶ Press Enter to continue...%s' "${GREEN}" "${RESET}")"
printf "\n"

# ---- 4 ----
printf "\n"
printf "  %s4. Activate%s\n" "${BOLD}" "${RESET}"
printf "  %sMake the published agent live for conversations and tests%s\n" "${DIM}" "${RESET}"
printf "\n"
printf "  %s\$ sf agent activate \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --json \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --api-name OrderManagement%s\n" "${YELLOW}" "${RESET}"
printf "\n"

read -r -s -p "$(printf '%s  ▶ Press Enter to continue...%s' "${GREEN}" "${RESET}")"
printf "\n"

# ---- 5 ----
printf "\n"
printf "  %s5. Deactivate%s\n" "${BOLD}" "${RESET}"
printf "  %sTake an active agent offline%s\n" "${DIM}" "${RESET}"
printf "\n"
printf "  %s\$ sf agent deactivate \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --json \\%s\n" "${YELLOW}" "${RESET}"
printf "  %s    --api-name OrderManagement%s\n" "${YELLOW}" "${RESET}"
printf "\n"

read -r -s -p "$(printf '%s  ▶ Press Enter to continue...%s' "${GREEN}" "${RESET}")"
printf "\n"

# ---- summary ----
printf "\n"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "\n"
printf "  %sgenerate%s   →  %svalidate%s   →  %spublish%s   →  %sactivate%s  /  %sdeactivate%s\n" \
  "${BOLD}" "${RESET}" "${BOLD}" "${RESET}" "${BOLD}" "${RESET}" "${BOLD}" "${RESET}" "${BOLD}" "${RESET}"
printf "\n"
printf "  %sscaffold      check       create        go live      take offline%s\n" "${DIM}" "${RESET}"
printf "  %s.agent file   locally     runtime       for users    for changes%s\n" "${DIM}" "${RESET}"
printf "\n"
printf "%s━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n" "${BOLD}${CYAN}" "${RESET}"
printf "\n"
