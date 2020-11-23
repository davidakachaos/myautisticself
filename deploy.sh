#!/usr/bin/env bash
# Deploy script
notify-send 'Deploying My Autistic Self to the world!'
cd /home/david/Broncode/myautisticself || exit 1
if branch=$(git symbolic-ref --short -q HEAD);then
  if [ "$branch" == "source" ]; then
    echo 'Getting latest changes...'
    git pull --rebase origin source
  else
    echo "Not on the source branch. We are on $branch so aborting!"
    exit 1
  fi
fi

if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
	echo 'Git status not clean, aborting deploy!'
	notify-send 'Git status not clean, aborting deploy!'
	exit 2
fi
echo 'Pushing changes to the source branch'
git push
datetime=$(date +'%Y-%m-%d %H:%M')
echo 'Generating tags...'
./tag-generator.py
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
    echo 'New tags generated or old removed, adding changes to git'
    git add tag/*
    git add category/*
    git add en/tag/*
    git add en/category/*
    git commit -m "Added new tags / category - $($datetime)"
else
    echo 'No new tags generated or old removed.'
fi
git gc --auto --prune
echo 'Building Jekyll...'
export JEKYLL_ENV=production
bundle exec jekyll build || exit 1
export JEKYLL_ENV=development
# Force some renames for fixing JS templating
./sed_posts.sh || exit 1
# Optimize AMP generated pages
./optimize_amp_pages.sh || exit 1
# Add cache file for bitlys to git
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add .bitly_cache
  git commit -m "Added URLs to Bitly cache -  $($datetime)"
fi
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add -A assets/resized/
  git commit -m "Added resized assets -  $($datetime)"
fi
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  echo 'Git status not clean after build, aborting deploy!'
  notify-send 'Git status not clean after build, aborting deploy!'
  exit 3
fi
echo 'Optimizing site....'
grunt optimize --force || exit 1
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  echo 'Adding optimized images to source...'
  git add assets
  git commit -m "Optimized assets - $($datetime)"
fi
# LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "@{u}")
BASE=$(git merge-base @ "@{u}")
if [ "$REMOTE" = "$BASE" ]; then
    echo "Need to push changes to source!"
    git push
fi
echo 'Switching to master branch...'
git checkout master || exit 1
echo 'Copying build site to master branch'
# cp -r _site/* . || exit 1
# Also delete files no longer needed
rsync --delete --progress --checksum -z --archive _site/* . || exit 1
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add -A .
  git commit -m "Latest version of My Autistic Self - $($datetime)"
  echo 'Pushing latest to GitHub!'
  git gc --prune
  git push || exit 1
  git checkout source
  echo 'https://myautisticself.nl has been deployed.'
  echo 'Clearing cache...'
  ./clear_cache.sh
  notify-send 'https://myautisticself.nl has been deployed.'
  echo 'Sending webmentions...'
  bundle exec jekyll webmention
  echo 'Sending pingbacks...'
  bundle exec jekyll pingback
  echo 'Generate bitly links...'
  generate-bitlys.rb
  git add db.json .bitly_cache
  git commit -m "Created new Bitly Links after deploy - $($datetime)"
else
  notify-send 'Nothing was changed! Aborting deployment.'
  git checkout source
fi
