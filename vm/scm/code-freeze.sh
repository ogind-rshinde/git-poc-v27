#!/bin/bash

read -r -p "$(tput setaf 3) Enter code freeze branch name : " freezeBranch
tput setaf 7
git checkout main
echo "$(tput setaf 3)update the main branch $(tput setaf 7)"
git pull origin main
echo "$(tput setaf 3)creating a new code freeze branch $(tput setaf 7)"
git checkout -b "$freezeBranch"
git push origin "$freezeBranch"
echo "$(tput setaf 3)creating a PR from code freeze branch$(tput setaf 7) to release/next"
releaseBranch='release/next'
gh pr create -t "Merge code freeze branch $freezeBranch to release/next branch" -b "PR to merge code freeze branch $freezeBranch merge to release/next branch" -B "$releaseBranch"
