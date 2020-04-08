cd assets/resized/
echo 'Converting jpg/jpeg'
for PHOTO in **/*.jpg
do
  BASE=`basename $PHOTO .jpg`
  TOO_BIG=`identify -format "%[fx:w>900&&h>900]" $PHOTO`
  if [ "$TOO_BIG" -eq "1" ]; then
    echo "$PHOTO needs a resize..."
    convert "$PHOTO" -resize 900x900\> -sampling-factor '4:2:0' -strip -quality 85 -interlace JPEG -colorspace sRGB "$PHOTO"
  else
    convert "$PHOTO" -sampling-factor '4:2:0' -strip -quality 85 -interlace JPEG -colorspace sRGB "$PHOTO"
  fi
done

for PHOTO in **/*.jpeg
do
  BASE=`basename $PHOTO .jpeg`
  TOO_BIG=`identify -format "%[fx:w>900&&h>900]" $PHOTO`
  if [ "$TOO_BIG" -eq "1" ]; then
    echo "$PHOTO needs a resize..."
    convert "$PHOTO" -resize 900x900\> -sampling-factor '4:2:0' -strip -quality 85 -interlace JPEG -colorspace sRGB "$PHOTO"
  else
    convert "$PHOTO" -sampling-factor '4:2:0' -strip -quality 85 -interlace JPEG -colorspace sRGB "$PHOTO"
  fi
done

echo 'Converting png'
for PHOTO in **/*.png
do
  BASE=`basename $PHOTO .png`
  TOO_BIG=`identify -format "%[fx:w>900&&h>900]" $PHOTO`
  if [ "$TOO_BIG" -eq "1" ]; then
    echo "$PHOTO needs a resize..."
    convert "$PHOTO" -resize 900x900\>  -strip "$PHOTO"
  else
    convert "$PHOTO" -strip "$PHOTO"
  fi
  pngquant -f --ext .png --quality 75-80 $PHOTO
done
rm -Rf ./webready/
echo 'Done converting, optimizing...'
jpegoptim -q -s --all-progressive **/*.jpg
jpegoptim -q -s --all-progressive **/*.jpeg
optipng -strip "all" -clobber -silent **/*.png
git status .
cd ../..
