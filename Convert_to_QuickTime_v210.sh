#!/bin/sh



# Change values set for temp and audio variables to $1 (1st argument)
movMovieFilepath="$1"
sourceFileBaseName="${movMovieFilepath##*/}"
sourceFileNoExt="${sourceFileBaseName%.ts}"
BASEDIR=$(dirname "$1")


/usr/local/bin/ffmpeg -i "$movMovieFilepath" -color_primaries bt2020 -colorspace bt2020_ncl -color_trc smpte2084 -vcodec v210 -pix_fmt yuv422p10le -an "$BASEDIR"/"$sourceFileNoExt".mov
