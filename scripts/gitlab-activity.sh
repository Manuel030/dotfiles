if [ -z "$GITLAB_TOKEN" ]; 
then
  echo "No GITLAB_TOKEN provided"
  exit 1;
fi;

if [ $# -eq 0 ]; then
  echo "Usage: $0 <date>"
  echo "Date must be in ISO 8601 format (YYYY-MM-DD)"
  exit 1
fi

ISO_DATE=$1

# Validate the date format
if [[ ! $ISO_DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Invalid date format. Please use YYYY-MM-DD format."
  exit 1
fi

# Set the date range to one day
AFTER_DATE=$(date -v-1d -j -f "%Y-%m-%d" "$ISO_DATE" +%Y-%m-%d)
BEFORE_DATE=$(date -v+1d -j -f "%Y-%m-%d" "$ISO_DATE" +%Y-%m-%d)

#echo "Querying activity on $ISO_DATE (from $AFTER_DATE to $BEFORE_DATE)"
GITLAB_USER="manuelpland"
COMMIT_LOG=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/users/$GITLAB_USER/events?after=$AFTER_DATE&before=$BEFORE_DATE&per_page=100")

#echo $COMMIT_LOG

if [[ "$COMMIT_LOG" == "[]" ]]; then
  exit 0
fi

PROMPT="Describe the programmers work based on the commit log in a concise manner. Only do the task without any introductions and write from the programmers perspective. Dont do any formatting. $COMMIT_LOG"

PAYLOAD=$(jq -n \
  --arg model "openai/gpt-4o" \
  --arg content "$PROMPT" \
  '{
    model: $model,
    messages: [
      {
        role: "user",
        content: $content
      }
    ]
  }'
)

curl -s https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d "$PAYLOAD" | jq .choices[0].message.content
