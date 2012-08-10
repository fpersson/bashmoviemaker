#!/bin/bash
#Desc: Ett mindre fint bashscript för att skapa en mpeg-film av ett gäng bilder
# med morphad övergång mellan bilderna. Scriptet kräver ffmpeg och ImageMagick.
#Version: 1.1
#Coder: Fredrik Persson
#E-mail: fpersson.se@gmail.com
#Download/webpage:
#Licens: BSD
#TODO: Exif-rotation?

declare -i I=0
declare -i J=0
declare -i K=0
declare -i L=0
declare -i STILLS

SIZE=640x480
TMP_DIR=$HOME/.movietmp/

if [ $1 == '--help' ]; then
  echo "Usage: movie.sh path/to/image/dir/ dest/filename.mpg"
  exit
fi

SRC_DIR=$1
DEST_FILE=$2

mkdir $TMP_DIR

#create a black background image
convert -size $SIZE xc:black $TMP_DIR/back.png


for files in $SRC_DIR/*.jpg; do
  I=$I+1
  convert -resize $SIZE $files $TMP_DIR/n$I.jpg;
  composite -gravity center $TMP_DIR/n$I.jpg $TMP_DIR/back.png $TMP_DIR/n$I.jpg;
done

echo $I

L=$I+1

while [ $J -lt $I ]; do
  J=$J+1
  K=$J+1
  if [ $K -lt $L ]
  then
    mkdir $TMP_DIR/M$K
    echo "Doing morph " $J " of " $I " ... Please wait...."
    convert -morph 100 $TMP_DIR/n$J.jpg $TMP_DIR/n$K.jpg $TMP_DIR/M$K/morph.jpg
    STILLS=102
    #151 gives ~ 50 frames without any morphing....
    while [ $STILLS -lt 151 ]; do
      cp $TMP_DIR/n$K.jpg $TMP_DIR/M$K/morph-$STILLS.jpg
      STILLS=$STILLS+1
    done
    echo "Encode morph " $J " of " $I " ... Please wait...."
    ffmpeg -s $SIZE -i $TMP_DIR/M$K/morph-%d.jpg $TMP_DIR/part$J.mpg
    src=$src" "$TMP_DIR/part$J.mpg
    echo "Done..."
    rm $TMP_DIR/M$K/*.*
    rmdir $TMP_DIR/M$K
  fi
done

cat $src > $TMP_DIR/final.mpg
ffmpeg -i $TMP_DIR/final.mpg -sameq $DEST_FILE

rm $TMP_DIR/part*.mpg
rm $TMP_DIR/final.mpg
rm $TMP_DIR/*.*
rmdir $TMP_DIR
