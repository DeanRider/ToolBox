#!/bin/bash
#######################################################################
# 
# This script will scan a folder to create a list of input paf files 
# It will then use each file in the list it created
# for use with Alvis
# The user must decide which flavor of modified Alvis to use and
# remove the # from the line corresponding to the desired command
# 
# Requirements:
# ALVIS, java, .paf files
#
# Use: bash MegaAlvis2.sh
#
# Written December 5, 2022 by S. Dean Rider Jr.
# 
#######################################################################

# set path for running sam2paf
export PATH="$PATH:$(pwd):$(pwd)/misc"
# scan directory structure for sam results and store as a list
find . -name "*.paf" -type file -exec echo '{}' >> alvislist.txt \;
COUNTER=0
while read reffile; do

echo $reffile

# get the filename without the file path and call it $base
base=$(basename "$reffile")

# USER: remove the hash tag from the beginning of the next line if you want to run regular colors in ALVIS
# Java -jar Alvis.jar -type contigAlignment -inputfmt paf -outputfmt svg \
-in $reffile -out Alvis.$base

# USER: remove the hash tag from the beginning of the next line if you want to run Blue-Red colors in ALVIS
Java -jar AlvisBR.jar -type contigAlignment -inputfmt paf -outputfmt svg \
-in $reffile -out Alvis.BR.$base

# USER: remove the hash tag from the beginning of the next line if you want to run Yellow-Blue colors in ALVIS
# Java -jar AlvisYB.jar -type contigAlignment -inputfmt paf -outputfmt svg \
-in $reffile -out Alvis.YB.$base

done < "alvislist.txt"


echo
echo
echo
echo -e "\033[1;31m ▄▄▄▄▄▄▄▄     ▄▄▄▄▄▄▄▄▄▄▄  ▄▄        ▄  ▄▄▄▄▄▄▄▄▄▄▄ \033[0m";
echo -e "\033[1;31m▐░░░░░░░░▌   ▐░░░░░░░░░░░▌▐░░▌      ▐░▌▐░░░░░░░░░░░▌\033[0m";
echo -e "\033[1;31m▐░█▀▀▀▀▀█░▌  ▐░█▀▀▀▀▀▀▀█░▌▐░▌░▌     ▐░▌▐░█▀▀▀▀▀▀▀▀▀ \033[0m";
echo -e "\033[1;31m▐░▌      ▐░▌ ▐░▌       ▐░▌▐░▌▐░▌    ▐░▌▐░▌          \033[0m";
echo -e "\033[1;31m▐░▌       ▐░▌▐░▌       ▐░▌▐░▌ ▐░▌   ▐░▌▐░█▄▄▄▄▄▄▄▄▄ \033[0m";
echo -e "\033[1;31m▐░▌       ▐░▌▐░▌       ▐░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌\033[0m";
echo -e "\033[1;31m▐░▌       ▐░▌▐░▌       ▐░▌▐░▌   ▐░▌ ▐░▌▐░█▀▀▀▀▀▀▀▀▀ \033[0m";
echo -e "\033[1;31m▐░▌      ▐░▌ ▐░▌       ▐░▌▐░▌    ▐░▌▐░▌▐░▌          \033[0m";
echo -e "\033[1;31m▐░█▄▄▄▄▄█░▌  ▐░█▄▄▄▄▄▄▄█░▌▐░▌     ▐░▐░▌▐░█▄▄▄▄▄▄▄▄▄ \033[0m";
echo -e "\033[1;31m▐░░░░░░░░▌   ▐░░░░░░░░░░░▌▐░▌      ▐░░▌▐░░░░░░░░░░░▌\033[0m";
echo -e "\033[1;31m ▀▀▀▀▀▀▀▀     ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀  ▀▀▀▀▀▀▀▀▀▀▀ \033[0m";
echo -e "\033[1;31m                                                    \033[0m";

exit 0