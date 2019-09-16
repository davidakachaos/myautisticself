#!/usr/bin/env bash
# Deploy script

if branch=$(git symbolic-ref --short -q HEAD);then
  if [ "$branch" == "master" ]; then
    echo 'Getting latest changes...'
    git pull --rebase origin master
  else
  	echo Not on the master branch. We are on $branch so aborting!
  	exit 1
  fi
fi

if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
	echo 'Git status not clean, aborting deploy!'
	exit 2
fi
echo 'Generating tags...'
./tag-generator.py
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
    echo 'New tags generated or old removed, adding changes to git'
    git add tag/*
    git add category/*
    git add en/tag/*
    git add en/category/*
    git commit -m 'Added new tags / category'
else
    echo 'No new tags generated or old removed.'
fi
echo 'Deploying to GitHub'
git push