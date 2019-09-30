#!/usr/bin/env bash
# Deploy script

if branch=$(git symbolic-ref --short -q HEAD);then
  if [ "$branch" == "source" ]; then
    echo 'Getting latest changes...'
    git pull --rebase origin source
  else
  	echo Not on the source branch. We are on $branch so aborting!
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

echo 'Building Jekyll...'
JEKYLL_ENV=production jekyll build
echo 'Switching to master branch...'
git checkout master
echo 'Copying build site to master branch'
cp -r _site/* .
echo 'Remove build site...'
rm -r _site
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add .
  git commit -m 'Latest version of My Autistic Self'
  echo 'Pushing latest to GitHub!'
  git push
  git checkout source
  echo 'https://myautisticself.nl has been deployed.'
  echo 'Sending webmentions...'
  jekyll webmention
else
  echo 'Nothing was changed! Aborting deployment.'
  git checkout source
fi

# echo 'Deploying to GitHub'
# git push