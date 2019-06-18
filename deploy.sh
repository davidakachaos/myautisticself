#!/usr/bin/env bash
# Deploy script
echo 'Generating tags...'
./tag-generator.py
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
    echo 'No new tags generated or old removed.'
else
    echo 'New tags generated or old removed, adding changes to git'
    git add tag/*
    git commit -m 'Added new tags'
fi
echo 'Deploying to GitHub'
git push