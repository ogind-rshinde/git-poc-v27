#!/bin/bash

echo "Executing command: git rev-parse --abbrev-ref HEAD"
BRANCH=$(git rev-parse --abbrev-ref HEAD)

previousDate=$(date --date="120 days ago" +"%Y-%m-%d")

echo "$(tput setaf 7)Executing command: git fetch origin"
git fetch origin

jiraTicket=$(echo "$BRANCH" |cut -d/ -f 1)
jiraTicket=${jiraTicket:5}

branchType=${BRANCH:0:4}
if [[ "$branchType" == "hfbg" ]]; then
  echo "Identifying PR number for the current branch"
  #getting the pull request number created for the current branch to merge into main branch.
  echo "$(tput setaf 7)Executing command: gh pr list --base main -s all --search 'created:>$previousDate' | grep $BRANCH"
  prNumber=$(gh pr list --base main -s all --search "created:>$previousDate" | grep "$BRANCH" | cut -d $'\t' -f1)
  echo "$(tput setaf 2)PR Number is:  $prNumber"

  while true; do
    read -r -p "$(tput setaf 3)Is $prNumber PR number is correct? yes/no: " prValid
    case $prValid in
    [Yy]*) break ;;
    [Nn]*) read -r -p "Please enter correct PR number: " prNumber ;;
    *) echo "Please answer yes or no." ;;
    esac
  done

  searchString="(#$prNumber)"
  echo "$searchString"
  #Getting the commitID for the PR from the main branch created by the PR. Assumption the search string will never be provided manually.
  echo "$(tput setaf 7)Executing command: git log --oneline origin/main | grep $searchString | cut -d $' ' -f1"
  commitID=$(git log --oneline origin/main | grep "$searchString" | cut -d $' ' -f1)
  echo "$(tput setaf 2)commitID is: $commitID"

  if [[ "$commitID" == "" ]]; then
    echo "$(tput setaf 1)ERROR: Your PR is not merged correct way, it should be squash and merge!"
    exit
  fi

  while true; do
    read -r -p "$(tput setaf 6)Is ($prNumber) PR number commit ($commitID) ID is correct? yes/no: " prValid
    case $prValid in
    [Yy]*) break ;;
    [Nn]*) read -r -p "Please enter correct commid ID of PR number: " commitID ;;
    *) echo "Please answer yes or no." ;;
    esac
  done

  #Create a hfrn branch from origin/release/next
  hfrnBranchName="${BRANCH/hfbg/hfrn}"
  echo "$(tput setaf 7)Executing command: git checkout -b $hfrnBranchName origin/release/next"
  if ! git checkout --no-track -b "$hfrnBranchName" origin/release/next; then
    echo "$(tput setaf 1)ERROR: Failed to create hfrn branch!"
    exit
  fi

  echo "$(tput setaf 7)Executing command: git cherry-pick $commitID"
  if ! git cherry-pick "$commitID"; then
    echo "$(tput setaf 1)ERROR: Failed to cherry-pick!"
    exit
  fi

  git push origin "$hfrnBranchName" -f
  releaseBranch='release/next'
  echo "$(tput setaf 3)PR will be created in edit mode, please update the description and create pull request."
  read -r -p "Please press Enter key to continue..."
  gh pr create -t "$jiraTicket Merge hfrn branch $BRANCH to release/next branch" -B "$releaseBranch" -w
  git checkout "$BRANCH"

elif [[ "$branchType" == "hfrn" ]]; then
  # TODO: generate the PR if not already generated for QARN branch
  prNumber=$(gh pr list --base release/next -s all --search "created:>$previousDate" | grep "$BRANCH" | cut -d $'\t' -f1)
  if [[ "$prNumber" != "" ]]; then
    echo "$(tput setaf 1)ERROR: PR($prNumber) is already exist for this branch!"
    exit
  fi

  echo "$(tput setaf 6) Pushing the changes to branch..."
  git push origin "$BRANCH"

  while true; do
    read -r -p "$(tput setaf 6)Do you want generate PR for release/next branch of $BRANCH? yes/no: " prValid
    case $prValid in
    [Yy]*) break ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
  done
  releaseBranch='release/next'
  echo "$(tput setaf 3)PR will be created in edit mode, please update the description and create pull request."
  read -r -p "Please press Enter key to continue..."
  gh pr create -t "$jiraTicket Merge hfrn branch $BRANCH to release/next branch" -B "$releaseBranch" -w
  hfbgBranchName="${BRANCH/hfrn/hfbg}"
  git checkout "$hfbgBranchName"
else
  echo "$(tput setaf 1) ***** This script is applicable only for hfbg and hfrn prefix branches! **** "
  exit
fi
