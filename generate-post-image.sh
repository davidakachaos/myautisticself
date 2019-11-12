#!/usr/bin/env bash
if [[ -z $1 ]]; then
  echo "Please give the post title as a parameter!"
  exit 1
fi
title=$1
slug=$(slugify "$1")
# Check if assets/img/$slug.png is present...
if [[ -f "assets/img/posts/$slug.png" ]]; then
    echo "assets/img/posts/$slug.png exist!"
    exit 2
fi

randomcolors=(DarkSlateGray SlateBlue RosyBrown SaddleBrown PaleTurquoise olive MistyRose)
# Seed random generator
RANDOM=$$$(date +%s)
selectedcolor=${randomcolors[$RANDOM % ${#randomcolors[@]} ]}

mkdir .tmp
# Generate random background
convert -size 300x200 xc: +noise Random -write mpr:rand \
           -extent 300x200   -page +50-40 mpr:rand \
           -page +50+40 mpr:rand -flatten -virtual-pixel tile \
           -blur 0x12 -fx intensity -normalize \
     -size 1x9 gradient:$selectedcolor-white \
     -interpolate integer -fx 'v.p{0,G*(v.h-1)}' \
     .tmp/bg.png
# Create text image
convert -background transparent -size 300x200 \
-gravity Center \
-weight 700 -pointsize 25 \
caption:"$title" \
.tmp/text.png
# Combine them
mogrify -alpha Set -draw 'image Dst_Over 0,0 0,0 ".tmp/bg.png"' .tmp/text.png
# Move to the right place and cleanup
mkdir -p assets/img/posts
cp .tmp/text.png assets/img/posts/$slug.png
rm -Rf .tmp
