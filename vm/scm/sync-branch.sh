#!/bin/bash

parentBranch='main'
echo "executing command: git fetch origin"
git fetch origin
echo "executing command: git merge origin/$parentBranch"
git merge origin/$parentBranch
