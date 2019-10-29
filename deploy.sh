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
    git push
else
    echo 'No new tags generated or old removed.'
fi

echo 'Building Jekyll...'
JEKYLL_ENV=production jekyll build
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  echo 'Git status not clean after build, aborting deploy!'
  exit 3
fi
echo 'Optimizing site....'
JEKYLL_ENV=production grunt optimize
rm -Rf .tmp
echo 'Removing optimized files from deploy'
rm -Rf _site/assets/js/vendor
rm -f _site/assets/js/main.js
rm -f _site/assets/css/main.css
rm -f _site/assets/css/mobile.css
rm -f _site/assets/css/vendor/syntax.css
rm -f _site/assets/css/vendor/semantic.min.css
exit 2
echo 'Switching to master branch...'
git checkout master
echo 'Copying build site to master branch'
cp -r _site/* .
echo 'Remove build site...'
rm -r _site
if [[ $(git status --porcelain | wc -l) -gt 0 ]]; then
  git add -A .
  git commit -m "Latest version of My Autistic Self - `date +'%Y-%m-%d %H:%M:%S'`"
  echo 'Pushing latest to GitHub!'
  git push
  echo 'Restoring build site...'
  mkdir _site
  cp -r * ./_site/ 2>/dev/null
  git checkout source
  rm -r ./_site/_site
  echo 'https://myautisticself.nl has been deployed.'
  echo 'Sending webmentions...'
  jekyll webmention
  echo 'Sending pingbacks...'
  jekyll pingback
else
  echo 'Nothing was changed! Aborting deployment.'
  cp -r * ./_site/ 2>/dev/null
  git checkout source
  rm -r ./_site/_site
fi
