#!/bin/bash

USERNAME=$(git config user.userid)

if [[ "$USERNAME" == "" ]]; then
  echo "$(tput setaf 1) Your GitHub User Account is not setup."
  read -r -p "$(tput setaf 2) Please provide your GitHub username which will be used for creating the branches: " userid
  echo "executing command: git config user.userid $userid"
  git config user.userid "$userid"
  echo "Your GitHub Account has been setup successfully. Kindly run the branch-create.sh command once again."
  exit
fi

#branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

echo "$(tput setaf 2) Which type of branch do you want to create?
1 - Feature Branch
2 - Dev Bug Branch
3 - QA Bug Branch
4 - Hotfixes Bug Branch
5 - ESN Bug Branch"

while :; do
  read -r -p "Select the type of branch you want to create: " branchOption
  [[ $branchOption =~ ^[0-9]+$ ]] || {
    echo "Enter a valid number"
    continue
  }
  if ((branchOption >= 1 && branchOption <= 5)); then
    break
  else
    echo "$(tput setaf 1) ******* Selected number is out of range. Try again!"
  fi
done

read -r -p "Enter JIRA Ticket Number: " ticket

while :; do
  read -r -p "$(tput setaf 2)Enter the branch description ( maximum 30 characters): " description
  if (("${#description}" >= 1 && "${#description}" < 31)); then
    break
  else
    echo "$(tput setaf 1) ********* Branch description should be less than 30 characters!"
  fi
done

description=$(echo "$description" | tr -d '%#@$^*!~')
description=$(echo "$description" | xargs)
description=${description// /-}
ticket=${ticket// /-}
echo "$(tput setaf 3) "

echo "executing command: git fetch origin"
git fetch origin
isBranchCreated=0

if test "$branchOption" = 1; then
  git checkout --no-track -b "feat-${ticket,,}/$USERNAME/${description,,}" origin/main
  isBranchCreated=1
elif test "$branchOption" = 2; then
  git checkout --no-track -b "dvbg-${ticket,,}/$USERNAME/${description,,}" origin/main
  isBranchCreated=1
elif test "$branchOption" = 3; then
  git checkout --no-track -b "qabg-${ticket,,}/$USERNAME/${description,,}" origin/main
  isBranchCreated=1
elif test "$branchOption" = 4; then
  git checkout --no-track -b "hfbg-${ticket,,}/$USERNAME/${description,,}" origin/main
  isBranchCreated=1
elif test "$branchOption" = 5; then
  git checkout --no-track -b "esbg-${ticket,,}/$USERNAME/${description,,}" origin/main
  isBranchCreated=1
fi

if [[ "$isBranchCreated" -eq "1" ]]; then
  echo "$(tput setaf 2) ********************** Your Branch is created successfully ****************************"
fi
