if [ -z "$GITLAB_TOKEN" ]; 
then
  echo "No GITLAB_TOKEN provided"
  exit 1;
fi;
read -p "Enter date difference to today: " DAYS
AFTER_DATE=$(date -v-"$(($DAYS+1))"d +%Y-%m-%d)
if [ $DAYS == 1 ]
then
  BEFORE_DATE=$(date +%Y-%m-%d);
elif [ $DAYS == 0 ]
then
  BEFORE_DATE=$(date -v+1d +%Y-%m-%d);
else
  BEFORE_DATE=$(date -v-"$(($DAYS-1))"d +%Y-%m-%d);
fi;
echo "Querying activity after $AFTER_DATE and before $BEFORE_DATE"
GITLAB_USER="manuelpland"
COMMIT_LOG=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/users/$GITLAB_USER/events?after=$AFTER_DATE&before=$BEFORE_DATE&per_page=100" \
  | jq '.[] | { action: .action_name, description: (if .target_title != null then .target_title elif .push_data != null then .push_data.commit_title elif .note != null then .note.body else "No title" end), branch: (if .action_name == "pushed to" then .push_data.ref else "no code change" end)}')

echo "Your commit log"
echo $COMMIT_LOG | jq

PROMPT="Describe the programmers work based on the commit log in a concise manner. Only do the task without any introductions and write from the programmers perspective. Dont do any formatting. $COMMIT_LOG"

PAYLOAD=$(jq -n \
  --arg model "llama3-8b-8192" \
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

echo "Your summary"
curl https://api.groq.com/openai/v1/chat/completions -s \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -d "$PAYLOAD" | jq .choices[0].message.content
