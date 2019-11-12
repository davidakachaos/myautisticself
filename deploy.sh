#!/usr/bin/env bash
# Deploy script
notify-send 'Deploying My Autistic Self to the world!'
cd /home/david/Broncode/myautisticself
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
	notify-send 'Git status not clean, aborting deploy!'
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
    git commit -m "Added new tags / category - `date +'%Y-%m-%d %H:%M:%S'`"
else
    echo 'No new tags generated or old removed.'
fi

echo 'Building Jekyll...'
JEKYLL_ENV=production jekyll build
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  echo 'Git status not clean after build, aborting deploy!'
  notify-send 'Git status not clean after build, aborting deploy!'
  exit 3
fi
echo 'Optimizing site....'
grunt optimize
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  echo 'Adding optimized images to source...'
  git add assets
  git commit -m "Optimized assets - `date +'%Y-%m-%d %H:%M:%S'`"
fi
# LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "@{u}")
BASE=$(git merge-base @ "@{u}")
if [ $REMOTE = $BASE ]; then
    echo "Need to push changes to source!"
    git push
fi
echo 'Switching to master branch...'
git checkout master || exit 1
echo 'Copying build site to master branch'
cp -r _site/* . || exit 1
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add -A .
  git commit -m "Latest version of My Autistic Self - `date +'%Y-%m-%d %H:%M:%S'`"
  echo 'Pushing latest to GitHub!'
  git push || exit 1
  git checkout source
  echo 'https://myautisticself.nl has been deployed.'
  notify-send 'https://myautisticself.nl has been deployed.'
  echo 'Sending webmentions...'
  jekyll webmention
  echo 'Sending pingbacks...'
  jekyll pingback
else
  notify-send 'Nothing was changed! Aborting deployment.'
  git checkout source
fi
