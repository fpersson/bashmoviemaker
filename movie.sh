#!/bin/bash
#Desc: Ett mindre fint bashscript för att skapa en mpeg-film av ett gäng bilder
# med morphad övergång mellan bilderna. Scriptet kräver ffmpeg och ImageMagick.
#Version: 1.1
#Coder: Fredrik Persson
#E-mail: fpersson.se@gmail.com
#Download/webpage:
#Licens: BSD
#TODO: Exif-rotation?

declare -i I
declare -i J
declare -i K
declare -i L
declare -i STILLS

SIZE=640x480
I=0
J=0
M=0

mkdir ./tmp

#skala om den svarta bakgrunden.
convert -resize $SIZE ./back.png ./tmp/back.png

for files in *.jpg; do
  I=$I+1
  convert -resize $SIZE $files ./tmp/n$I.jpg;
  composite -gravity center ./tmp/n$I.jpg ./tmp/back.png ./tmp/n$I.jpg;
done

echo $I

L=$I+1

while [ $J -lt $I ]
do
  J=$J+1
  K=$J+1
  if [ $K -lt $L ]
  then
    mkdir ./M$K
    echo "Doing morph " $J " of " $I " ... Please wait...."
    convert -morph 100 ./tmp/n$J.jpg ./tmp/n$K.jpg ./M$K/morph.jpg
    STILLS=102
    while [ $STILLS -lt 151 ]
    do
      cp ./tmp/n$K.jpg ./M$K/morph-$STILLS.jpg
      STILLS=$STILLS+1
    done
    echo "Encode morph " $J " of " $I " ... Please wait...."
    ffmpeg -s $SIZE -i ./M$K/morph-%d.jpg part$J.mpg
    src=$src" "part$J.mpg
    echo "Done..."
    rm ./M$K/*.*
    rmdir ./M$K
  fi
done

cat $src > final.mpg
ffmpeg -i final.mpg -sameq output.mpg

rm part*.mpg
rm final.mpg
rm ./tmp/*.*
rmdir ./tmp
