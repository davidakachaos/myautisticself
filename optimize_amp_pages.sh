#!/usr/bin/env bash
shopt -s globstar
for f in _site/amp/**/index.html
do
  # echo "Processing $f file..."
  # take action on each file. $f store current file name
  amp optimize "$f" > tmp_amp
  # echo "Done, replacing file..."
  mv tmp_amp "$f"
  # cat $f
done
rm tmp_amp
