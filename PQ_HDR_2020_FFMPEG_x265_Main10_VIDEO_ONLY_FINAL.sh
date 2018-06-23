#!/bin/sh

#***************************************************************************
# Chris Seeger - NBCUniversal, LLC      April 13, 2017
#***************************************************************************

#***************************************************************************
#   SET USER VARIABLES BELOW                                           *
#***************************************************************************


#***************************************************************************
# PLEASE SET ALL OF THESE VARIABLES (Frame Rate not required)
#***************************************************************************
outputScalingResolution="3840x2160"
# FFMPEG Input Color Tags - Primaries (bt709, bt2020)
ffmpeg_In_ColorPrimaries="bt2020"
# FFMPEG Color Space = Color Matrix (bt709,bt2020_ncl)
ffmpeg_In_ColorSpace="bt2020_ncl"
# Transfer Function (bt709, smpte2084)
ffmpeg_In_TransferFunction="smpte2084"

# x265 output bitrate
HEVCBitrateDefault=32000
# x265 Color Primaries (bt709, bt2020)
x265_Out_Color_Primaries="bt2020"
# x265 Transfer Function (1 = 709, 16 = PQ/ST2084)
x265_Out_TransferFunction="16"
# Color Matrix Conversion Equation (bt709, bt2020nc)
x265_Out_ColorMatrixEquation="bt2020nc"
# Use one of these x265 presets (the slower the encode, the more encoder options are checked)
# ultrafast, superfast, veryfast, faster, fast, medium (default), slow, slower, veryslow
x265EncoderPresets="slow"

#***************************************************************************
#***************************************************************************

# Set $1 argument to source path for mov movie conversions
movMovieFilepath="$1"

# TEMP path
#Laptop CS15
converttemp="/Users/Shared/___HDR_HEVC_Testing/___TEMP"
#outdir="/Users/Shared/___HDR_HEVC_Testing/OUTPUT"

#NBC
#outdir="/Volumes/Promise_x10_RAID60-C/_____HEVC_CONV_TEMP"


#***************************************************************************
#***************************************************************************
#********DON'T CHANGE BELOW THIS LINE***************************************
#********DON'T CHANGE BELOW THIS LINE***************************************
#********DON'T CHANGE BELOW THIS LINE***************************************
#********DON'T CHANGE BELOW THIS LINE***************************************
#********DON'T CHANGE BELOW THIS LINE***************************************
#********DON'T CHANGE BELOW THIS LINE***************************************
#********DON'T CHANGE BELOW THIS LINE***************************************
#***************************************************************************
#***************************************************************************
# BEGIN SCRIPT FUNCTIONS (BELOW)  ***DON'T CHANGE BELOW THIS LINE
#***************************************************************************

# Set Terminal Text Formatting Variables
BLACK_F="\033[30m"; BLACK_B="\033[40m"
RED_F="\033[31m"; RED_B="\033[41m"
GREEN_F="\033[32m"; GREEN_B="\033[42m"
YELLOW_F="\033[33m"; YELLOW_B="\033[43m"
BLUE_F="\033[34m"; BLUE_B="\033[44m"
MAGENTA_F="\033[35m"; MAGENTA_B="\033[45m"
CYAN_F="\033[36m"; CYAN_B="\033[46m"
WHITE_F="\033[37m"; WHITE_B="\033[47m"
NORM="\033[0m"
BLINK="\e[5m"
UNDERLINE="\033[4m"


printf "\n\n"
printf ""
printf ""
printf "${RED_B}${BLINK}PLEASE VERIFY SOURCE vs OUTPUT RESOLUTION ${NORM}\n\n"
printf ""
sleep 2


#***************************************************************************
# Parse Input File for source media metadata
#***************************************************************************
echo "${MAGENTA_F}${UNDERLINE}Source File Metadata${NORM}"
printf "Movie Duration:"
ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "$movMovieFilepath"
printf "Movie Frame Rate:"
ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=noprint_wrappers=1:nokey=1 "$movMovieFilepath"
printf ""
printf "Color Primaries: "`ffprobe -v error -select_streams v:0 -show_entries stream=color_primaries -of default=noprint_wrappers=1:nokey=1 "$movMovieFilepath"`
echo ""
printf "Transfer Function: "`ffprobe -v error -select_streams v:0 -show_entries stream=color_transfer -of default=noprint_wrappers=1:nokey=1 "$movMovieFilepath"`
echo ""
printf "Color Space: "`ffprobe -v error -select_streams v:0 -show_entries stream=color_space -of default=noprint_wrappers=1:nokey=1 "$movMovieFilepath"`
echo ""
printf "Input File Resolution: "
eval $(ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=height,width "$movMovieFilepath")
outputScalingResolution=${streams_stream_0_width}x${streams_stream_0_height}
echo $outputScalingResolution
echo ""
echo ""
sleep 2
#***************************************************************************



#***************************************************************************
# Ask for input to resolution and output file name suffix variables on this job
#***************************************************************************

echo ""
echo ""
echo "Resolution choices are 3840x2160 or 1920x1080"
read -p "Please enter the default or scaled resolution for your encode. Source File is: [$outputScalingResolution] : " outputScalingResolutionInput
outputScalingResolutionInput="${outputScalingResolutionInput:-$outputScalingResolution}"

echo ""
outputFileNameSuffixDefault="out"
read -p "Please select an output file name suffix: Default is [$outputFileNameSuffixDefault] : " outputFileNameSuffixInput
outputFileNameSuffixInput="${outputFileNameSuffixInput:-$outputFileNameSuffixDefault}"

echo ""
read -p "Please select an HEVC bitrate for output file: Default is [$HEVCBitrateDefault] : " HEVCBitrateDefaultInput
HEVCBitrateDefaultInput="${HEVCBitrateDefaultInput:-$HEVCBitrateDefault}"


#***************************************************************************
#***************************************************************************


# Change values set for temp and audio variables to $1 (1st argument)
sourceFileBaseName="${movMovieFilepath##*/}"
sourceFileNoExt="${sourceFileBaseName%.mov}"
echo "Input File Base Name $sourceFileBaseName"
echo "Input File Base Name without extension $sourceFileNoExt"


#***************************************************************************
# HEVC VIDEO COMPRESSION VIA FFMPEG & libx265 with 10bit option
# MAKE SURE x265 is preinstalled with 16-bit option (so 10bit is available)
#***************************************************************************

function ffmpegx265encode2020 {

ffmpeg -i "$movMovieFilepath" \
-s $outputScalingResolution \
-color_primaries $ffmpeg_In_ColorPrimaries \
-color_trc $ffmpeg_In_TransferFunction \
-colorspace $ffmpeg_In_ColorSpace \
-c:v libx265 \
-crf 18 \
-preset $x265EncoderPresets \
-tune grain \
-x265-params \
"level-idc=51\
:high-tier=no\
:bframes=12\
:keyint=72\
:sar=1\
:range=limited\
:aq-mode=3\
:aq-strength=2.0\
:colorprim=$x265_Out_Color_Primaries\
:transfer=$x265_Out_TransferFunction\
:colormatrix=$x265_Out_ColorMatrixEquation\
:master-display='G(13250,34500)B(7500,3000)R(34000,16000)WP(15635,16450)L(10000000,50)'\
:max-cll='1000,400'\
:chromaloc=2\
:bitrate=$HEVCBitrateDefaultInput\
:repeat-headers=yes" \
-tag:v hvc1 \
-pix_fmt yuv420p10le \
-c:a ac3 \
-ac 6 \
-ar 48000 \
-ab 448k \
-dialnorm -27 \
-dsur_mode 0 \
-original 1 \
-dmix_mode 2 \
-channel_layout 63 \
-out_channel_layout FL+FR+FC+LFE+BL+BR \
""$converttemp/$sourceFileNoExt"_"$outputFileNameSuffixInput.mp4""

}
#***************************************************************************


ffmpegx265encode2020
#CleanYUVtemp
#CleanHEVCtemp


#***************************************************************************




exit
