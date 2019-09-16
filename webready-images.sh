cd assets/img/
mkdir -p webready/

echo 'Converting jpg/jpeg'
for PHOTO in *.jpg
do
  BASE=`basename $PHOTO .jpg`
  convert "$PHOTO" -sampling-factor '4:2:0' -strip -quality 85 -interlace JPEG -colorspace sRGB "webready/$BASE.jpg"
  mv webready/$BASE.jpg .
done

for PHOTO in *.jpeg
do
  BASE=`basename $PHOTO .jpeg`
  convert "$PHOTO" -sampling-factor '4:2:0' -strip -quality 85 -interlace JPEG -colorspace sRGB "webready/$BASE.jpeg"
  mv webready/$BASE.jpeg .
done

echo 'Converting png'
for PHOTO in *.png
do
  BASE=`basename $PHOTO .png`
  convert "$PHOTO" -strip "webready/$BASE.png"
  mv webready/$BASE.png .
done
rm -Rf ./webready/
echo 'Done.'
git status .
cd ../..