#!/bin/bash
#-----------------------------------#
# Secure Public GCS Bucket Script   #
#-----------------------------------#

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

# Color pools
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#
echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Bucket Security Script...${RESET}"

# Step 1: Fetch project ID
echo "${BOLD}${CYAN}Fetching the active project ID...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
echo "${GREEN}Current Project:${RESET} ${YELLOW}$PROJECT_ID${RESET}"

# Step 2: Define bucket name based on project ID
export BUCKET_NAME="${PROJECT_ID}-urgent"
echo "${BOLD}${CYAN}Target Bucket:${RESET} ${YELLOW}$BUCKET_NAME${RESET}"

# Step 3: Secure the bucket
echo "${BOLD}${BLUE}Removing public access (allUsers, allAuthenticatedUsers)...${RESET}"

gsutil iam ch -d allUsers:objectViewer gs://$BUCKET_NAME
gsutil iam ch -d allAuthenticatedUsers:objectViewer gs://$BUCKET_NAME

echo "${BOLD}${CYAN}Verifying uniform bucket-level access settings...${RESET}"
gsutil uniformbucketlevelaccess get gs://$BUCKET_NAME

# Step 4: Success message
function random_congrats() {
    MESSAGES=(
        "${GREEN}✅ Bucket secured successfully! Excellent job!${RESET}"
        "${CYAN}🎉 Great work! The bucket is no longer public!${RESET}"
        "${YELLOW}💪 Mission accomplished! You’ve locked down your bucket!${RESET}"
        "${BLUE}🔒 Fantastic! The bucket is now fully secure!${RESET}"
        "${MAGENTA}👏 Outstanding! Public access removed successfully!${RESET}"
        "${RED}🚀 Done! Your bucket is safe and sound!${RESET}"
    )
    RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo -e "${BOLD}${MESSAGES[$RANDOM_INDEX]}"
}

random_congrats

# Optional cleanup (used in Qwiklabs environments)
cd
remove_files() {
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            if [[ -f "$file" ]]; then
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}
remove_files

echo "${BOLD}${GREEN}All tasks completed successfully.${RESET}"
echo
#----------------------------------------------------end----------------------------------------------------#
