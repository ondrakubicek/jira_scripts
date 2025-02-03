#!/bin/bash

# 🛠 Loading variables from .env
export $(grep -v '^#' .env | xargs)

# 🔍 Check if all required variables are loaded
if [[ -z "$JIRA_EMAIL" || -z "$JIRA_TOKEN" || -z "$JIRA_DOMAIN" ]]; then
  echo "❌ Missing JIRA_EMAIL, JIRA_TOKEN, or JIRA_DOMAIN in .env file"
  exit 1
fi


# Default values  (if day is not specified, use today's date)
DAY_FROM=$(date "+%Y-%m-%d")
DAY_TO=$DAY_FROM
TIME_SPENT="0.25h"              # Defaultně 15 minut (0.25h)
LOG_TIME="09:45"                # Defaultně v 9:45 ráno
TICKET=$TICKET_DEFAULT

# Processing arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --ticket=*) TICKET="${1#*=}" ;;
    --ticket) shift; TICKET="$1" ;;

    --day-from=*) DAY_FROM="${1#*=}" ;;
    --day-from) shift; DAY_FROM="$1" ;;

    --day-to=*) DAY_TO="${1#*=}" ;;
    --day-to) shift; DAY_TO="$1" ;;

    --time-spent=*) TIME_SPENT="${1#*=}" ;;
    --time-spent) shift; TIME_SPENT="$1" ;;

    --log-time=*) LOG_TIME="${1#*=}" ;;
    --log-time) shift; LOG_TIME="$1" ;;

    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

# check mandatory arguments
if [[ -z "$TICKET" || -z "$TIME_SPENT" || -z "$LOG_TIME" ]]; then
  echo "❌ Missing mandatory arguments argument! Usage:"
  echo "  $0 --ticket=TICKET --day-from=YYYY-MM-DD --day-to=YYYY-MM-DD --time-spent=H:M --log-time=H:M"
  exit 1
fi


# 📅 convert time to Jira format
LOG_TIME_ISO="${LOG_TIME}:00.000+0100"

# 🔄 Generating date range (if DAY_TO is specified)
DATES=()
if [[ -z "$DAY_TO" ]]; then
  DATES=("$DAY_FROM")
else
  CURRENT_DATE="$DAY_FROM"
  while [[ "$CURRENT_DATE" != "$(date -j -v+1d -f "%Y-%m-%d" "$DAY_TO" "+%Y-%m-%d")" ]]; do
    # ❌ Skip weekends (sat: 6, sun: 7)
    WEEKDAY=$(date -j -f "%Y-%m-%d" "$CURRENT_DATE" "+%u")
    if [[ "$WEEKDAY" -lt 6 ]]; then
      DATES+=("$CURRENT_DATE")
    fi
    # 📅 next day
    CURRENT_DATE=$(date -j -v+1d -f "%Y-%m-%d" "$CURRENT_DATE" "+%Y-%m-%d")
  done
fi

# 📌 Počet úspěšně zalogovaných dní
LOGGED_COUNT=0

# 🔄 Send logu for each day DATES
for DAY in "${DATES[@]}"; do
  # 📅 Convert to ISO
  LOG_DATE_ISO="${DAY}T${LOG_TIME_ISO}"

  # 📡 Send to Jira api
   RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
      -u "$JIRA_EMAIL:$JIRA_TOKEN" \
      -H "Content-Type: application/json" \
      --data '{
        "timeSpent": "'"$TIME_SPENT"'",
        "started": "'"$LOG_DATE_ISO"'"
      }' \
      "https://$JIRA_DOMAIN/rest/api/3/issue/$TICKET/worklog")


  # ✅ Response control
  if [[ "$RESPONSE" == "201" ]]; then
    LOGGED_COUNT=$((LOGGED_COUNT + 1))
    echo "✅ Logged: $DAY to ticket $TICKET ($TIME_SPENT)"
  else
    echo "❌ Error logging $DAY (HTTP $RESPONSE)"
  fi
done

# 🖥  MacOS notification
if [[ "$LOGGED_COUNT" -gt 0 ]]; then
  if [[ "${#DATES[@]}" -eq 1 ]]; then
    osascript -e "display notification \"✅ Logged $TIME_SPENT on $TICKET\" sound name \"Submarine\""
  else
    osascript -e "display notification \"Logged a total of $LOGGED_COUNT days on $TICKET\" with title \"JIRA Log\""
  fi
fi
