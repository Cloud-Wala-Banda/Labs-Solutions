BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution${RESET}"

# 1. Create English Request JSON
cat << 'EOF' > "$REQUEST1"
{
  "config": {
    "encoding": "LINEAR16",
    "languageCode": "en-US",
    "audioChannelCount": 2
  },
  "audio": {
    "uri": "gs://spls/arc131/question_en.wav"
  }
}
EOF

echo "Calling Speech-to-Text API for English..."
curl -s -X POST -H "Content-Type: application/json" --data-binary @"$REQUEST1" \
"https://speech.googleapis.com/v1/speech:recognize?key=$API_KEY" > "$RESPONSE1"

# 2. Create Spanish Request JSON
cat << 'EOF' > "$REQUEST2"
{
  "config": {
    "encoding": "FLAC",
    "languageCode": "es-ES"
  },
  "audio": {
    "uri": "gs://spls/arc131/multi_es.flac"
  }
}
EOF

echo "Calling Speech-to-Text API for Spanish..."
curl -s -X POST -H "Content-Type: application/json" --data-binary @"$REQUEST2" \
"https://speech.googleapis.com/v1/speech:recognize?key=$API_KEY" > "$RESPONSE2"

# 3. Upload files to Cloud Storage to pass the lab checks
echo "Uploading files to Google Cloud Storage bucket: gs://$BUCKET_NAME"
gcloud storage cp "$REQUEST1" "gs://${BUCKET_NAME}/speech_request.json"
gcloud storage cp "$RESPONSE1" "gs://${BUCKET_NAME}/response.json"
gcloud storage cp "$REQUEST2" "gs://${BUCKET_NAME}/speech_request_sp.json"
gcloud storage cp "$RESPONSE2" "gs://${BUCKET_NAME}/response_sp.json"

echo "${RED}${BOLD}Congratulations${RESET} ${WHITE}${BOLD}for${RESET} ${GREEN}${BOLD}Completing the Lab !!!${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
