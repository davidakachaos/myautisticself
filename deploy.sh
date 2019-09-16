#!/usr/bin/env bash
# Deploy script
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
	echo 'Git status not clean, aborting deploy!'
	exit 1
fi
exit 0
echo 'Generating tags...'
./tag-generator.py
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
    echo 'No new tags generated or old removed.'
else
    echo 'New tags generated or old removed, adding changes to git'
    git add tag/*
    git add category/*
    git commit -m 'Added new tags / category'
fi
echo 'Deploying to GitHub'
git push