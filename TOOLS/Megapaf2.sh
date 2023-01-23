#!/bin/bash
#######################################################################
# 
# This script will scan a folder to create a list of input sam files 
# It will then use each file in the list it created
# to make .paf files for use with Alvis
# need to copy k8 and minimap2 misc folder into location of use
# 
# Requirements:
# .sam file, k8, misc from minimap2
#
# Use: bash Megapaf2.sh
#
# written November 18, 2022 by S. Dean Rider Jr.
#
#######################################################################

# set path for running sam2paf
export PATH="$PATH:`pwd`:`pwd`/misc" 
# scan directory structure for sam results and store as a list
find . -name "*.sam" -type file -exec echo '{}' >> paflist.txt \;

while read mapref; do

echo $mapref
paftools.js sam2paf -p $mapref > $mapref.paf

done < "paflist.txt"

# mkdir paffiles
# find . -name "*.sam.paf" -type file -exec cp '{}' ./paffiles/ \;

exit 0