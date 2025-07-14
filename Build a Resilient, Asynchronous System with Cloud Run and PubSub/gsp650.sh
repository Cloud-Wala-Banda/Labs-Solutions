clear

#!/bin/bash
# Define color variables

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

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Step 1: Set Compute Zone & Region
echo "${BOLD}${BLUE}Setting Compute Zone & Region${RESET}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud config set compute/zone $ZONE

gcloud config set compute/region $REGION

# Step 2: Create Pub/Sub Topic
echo "${BOLD}${GREEN}Creating Pub/Sub topic 'new-lab-report'${RESET}"
gcloud pubsub topics create new-lab-report

# Step 3: Enable Cloud Run API
echo "${BOLD}${YELLOW}Enabling Cloud Run API${RESET}"
gcloud services enable run.googleapis.com

# Step 4: Clone Pet Theory Repository
echo "${BOLD}${MAGENTA}Cloning the pet-theory repository${RESET}"
git clone https://github.com/rosera/pet-theory.git

# Step 5: Navigate to lab-service Directory
echo "${BOLD}${CYAN}Navigating to lab-service directory${RESET}"
cd pet-theory/lab05/lab-service

# Step 6: Install Node Dependencies
echo "${BOLD}${RED}Installing npm dependencies${RESET}"
npm install express
npm install body-parser
npm install @google-cloud/pubsub

# Step 7: Replace Files with Lab Versions
echo "${BOLD}${GREEN}Replacing default files with lab-specific files${RESET}"
rm package.json

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/lab-service/package.json

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/lab-service/index.js

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/lab-service/Dockerfile

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/lab-service/deploy.sh

curl -LO https://raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/lab-service/post-reports.sh

# Step 8: Deploy Lab Service
echo "${BOLD}${BLUE}Deploying lab-service${RESET}"
chmod u+x deploy.sh

./deploy.sh

# Step 9: Post Reports
echo "${BOLD}${YELLOW}Running post-reports.sh${RESET}"
export LAB_REPORT_SERVICE_URL=$(gcloud run services describe lab-report-service --platform managed --region "$REGION" --format="value(status.address.url)")
chmod u+x post-reports.sh

./post-reports.sh

# Step 10: Navigate to email-service Directory
echo "${BOLD}${MAGENTA}Navigating to email-service directory${RESET}"
cd ~/pet-theory/lab05/email-service

# Step 11: Install Email Service Dependencies
echo "${BOLD}${CYAN}Installing npm dependencies for email-service${RESET}"
npm install express
npm install body-parser

# Step 12: Replace Email Service Files
echo "${BOLD}${RED}Replacing email-service files with lab versions${RESET}"
rm package.json

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/email-service/package.json

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/email-service/index.js

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/email-service/Dockerfile

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/email-service/deploy.sh

# Step 13: Deploy Email Service
echo "${BOLD}${GREEN}Deploying email-service${RESET}"
chmod u+x deploy.sh

./deploy.sh

# Step 14: Create Service Account for Invoker
echo "${BOLD}${BLUE}Creating service account for Pub/Sub Cloud Run invoker${RESET}"
gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker"

# Step 15: Add IAM Policy Binding to Email Service
echo "${BOLD}${YELLOW}Adding IAM policy binding for email-service${RESET}"
gcloud run services add-iam-policy-binding email-service --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com --role=roles/run.invoker --region $REGION --project=$DEVSHELL_PROJECT_ID --platform managed

# Step 16: Grant Token Creator Role to Pub/Sub SA
echo "${BOLD}${MAGENTA}Granting IAM role to Pub/Sub SA${RESET}"
PROJECT_NUMBER=$(gcloud projects list --filter="qwiklabs-gcp" --format='value(PROJECT_NUMBER)')

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com --role=roles/iam.serviceAccountTokenCreator

# Step 17: Create Push Subscription
echo "${BOLD}${CYAN}Creating push subscription to email-service${RESET}"
EMAIL_SERVICE_URL=$(gcloud run services describe email-service --platform managed --region=$REGION --format="value(status.address.url)")

gcloud pubsub subscriptions create email-service-sub --topic new-lab-report --push-endpoint=$EMAIL_SERVICE_URL --push-auth-service-account=pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com

# Step 18: Post Reports Again
echo "${BOLD}${RED}Re-running post-reports.sh for verification${RESET}"
~/pet-theory/lab05/lab-service/post-reports.sh

# Step 19: Navigate to SMS Service
echo "${BOLD}${GREEN}Navigating to sms-service directory${RESET}"
cd ~/pet-theory/lab05/sms-service

# Step 20: Install SMS Service Dependencies
echo "${BOLD}${BLUE}Installing npm dependencies for sms-service${RESET}"
npm install express
npm install body-parser

# Step 21: Replace SMS Service Files
echo "${BOLD}${YELLOW}Replacing sms-service files with lab versions${RESET}"
rm package.json

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/sms-service/package.json

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/sms-service/index.js

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/sms-service/Dockerfile

curl -LO raw.githubusercontent.com/Cloud-Wala-Banda/Labs-Solutions/refs/heads/main/Build%20a%20Resilient%2C%20Asynchronous%20System%20with%20Cloud%20Run%20and%20PubSub/sms-service/deploy.sh

# Step 22: Deploy SMS Service
echo "${BOLD}${MAGENTA}Deploying sms-service${RESET}"
chmod u+x deploy.sh

./deploy.sh

echo

# Function to display a random congratulatory message
function random_congrats() {
    MESSAGES=(
        "${GREEN}Congratulations For Completing The Lab! Keep up the great work!${RESET}"
        "${CYAN}Well done! Your hard work and effort have paid off!${RESET}"
        "${YELLOW}Amazing job! You’ve successfully completed the lab!${RESET}"
        "${BLUE}Outstanding! Your dedication has brought you success!${RESET}"
        "${MAGENTA}Great work! You’re one step closer to mastering this!${RESET}"
        "${RED}Fantastic effort! You’ve earned this achievement!${RESET}"
        "${CYAN}Congratulations! Your persistence has paid off brilliantly!${RESET}"
        "${GREEN}Bravo! You’ve completed the lab with flying colors!${RESET}"
        "${YELLOW}Excellent job! Your commitment is inspiring!${RESET}"
        "${BLUE}You did it! Keep striving for more successes like this!${RESET}"
        "${MAGENTA}Kudos! Your hard work has turned into a great accomplishment!${RESET}"
        "${RED}You’ve smashed it! Completing this lab shows your dedication!${RESET}"
        "${CYAN}Impressive work! You’re making great strides!${RESET}"
        "${GREEN}Well done! This is a big step towards mastering the topic!${RESET}"
        "${YELLOW}You nailed it! Every step you took led you to success!${RESET}"
        "${BLUE}Exceptional work! Keep this momentum going!${RESET}"
        "${MAGENTA}Fantastic! You’ve achieved something great today!${RESET}"
        "${RED}Incredible job! Your determination is truly inspiring!${RESET}"
        "${CYAN}Well deserved! Your effort has truly paid off!${RESET}"
        "${GREEN}You’ve got this! Every step was a success!${RESET}"
        "${YELLOW}Nice work! Your focus and effort are shining through!${RESET}"
        "${BLUE}Superb performance! You’re truly making progress!${RESET}"
        "${MAGENTA}Top-notch! Your skill and dedication are paying off!${RESET}"
        "${RED}Mission accomplished! This success is a reflection of your hard work!${RESET}"
        "${CYAN}You crushed it! Keep pushing towards your goals!${RESET}"
        "${GREEN}You did a great job! Stay motivated and keep learning!${RESET}"
        "${YELLOW}Well executed! You’ve made excellent progress today!${RESET}"
        "${BLUE}Remarkable! You’re on your way to becoming an expert!${RESET}"
        "${MAGENTA}Keep it up! Your persistence is showing impressive results!${RESET}"
        "${RED}This is just the beginning! Your hard work will take you far!${RESET}"
        "${CYAN}Terrific work! Your efforts are paying off in a big way!${RESET}"
        "${GREEN}You’ve made it! This achievement is a testament to your effort!${RESET}"
        "${YELLOW}Excellent execution! You’re well on your way to mastering the subject!${RESET}"
        "${BLUE}Wonderful job! Your hard work has definitely paid off!${RESET}"
        "${MAGENTA}You’re amazing! Keep up the awesome work!${RESET}"
        "${RED}What an achievement! Your perseverance is truly admirable!${RESET}"
        "${CYAN}Incredible effort! This is a huge milestone for you!${RESET}"
        "${GREEN}Awesome! You’ve done something incredible today!${RESET}"
        "${YELLOW}Great job! Keep up the excellent work and aim higher!${RESET}"
        "${BLUE}You’ve succeeded! Your dedication is your superpower!${RESET}"
        "${MAGENTA}Congratulations! Your hard work has brought great results!${RESET}"
        "${RED}Fantastic work! You’ve taken a huge leap forward today!${RESET}"
        "${CYAN}You’re on fire! Keep up the great work!${RESET}"
        "${GREEN}Well deserved! Your efforts have led to success!${RESET}"
        "${YELLOW}Incredible! You’ve achieved something special!${RESET}"
        "${BLUE}Outstanding performance! You’re truly excelling!${RESET}"
        "${MAGENTA}Terrific achievement! Keep building on this success!${RESET}"
        "${RED}Bravo! You’ve completed the lab with excellence!${RESET}"
        "${CYAN}Superb job! You’ve shown remarkable focus and effort!${RESET}"
        "${GREEN}Amazing work! You’re making impressive progress!${RESET}"
        "${YELLOW}You nailed it again! Your consistency is paying off!${RESET}"
        "${BLUE}Incredible dedication! Keep pushing forward!${RESET}"
        "${MAGENTA}Excellent work! Your success today is well earned!${RESET}"
        "${RED}You’ve made it! This is a well-deserved victory!${RESET}"
        "${CYAN}Wonderful job! Your passion and hard work are shining through!${RESET}"
        "${GREEN}You’ve done it! Keep up the hard work and success will follow!${RESET}"
        "${YELLOW}Great execution! You’re truly mastering this!${RESET}"
        "${BLUE}Impressive! This is just the beginning of your journey!${RESET}"
        "${MAGENTA}You’ve achieved something great today! Keep it up!${RESET}"
        "${RED}You’ve made remarkable progress! This is just the start!${RESET}"
    )

    RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo -e "${BOLD}${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files