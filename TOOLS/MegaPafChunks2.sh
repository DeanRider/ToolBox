#!/bin/bash
#######################################################################
# 
# This script will scan a folder to create a list of input paf files 
# It will then use each file in the list it created
# lines corresponding to types of read chunks will be made into 
# separate files and each file will be used by awk
# and manipulate field 11 to generate an average, stdev, histogram.
# this is preliminary data for trends and histograms will
# likely be more informative
#
# Requirements:
# .paf file
#
# Use: bash MegaPafChunks2.sh
#
# written November 18, 2022 by S. Dean Rider Jr.
#
#######################################################################

# scan directory structure for .paf results and store as a list
find . -name "*.paf" -type file -exec echo '{}' >> pafchunkslist.txt \;

while read paffile; do

echo $paffile
grep -iv "chr" $paffile >> $paffile.notchr.tmp
grep -iv "Hy" $paffile.notchr.tmp >> $paffile.Ectopic.tmp
grep -i "chr" $paffile >> $paffile.chr.tmp
grep -i "Hy" $paffile >> $paffile.Hy.tmp


echo $paffile >> $paffile.chunklengths.txt
echo "Ectopic " >> $paffile.chunklengths.txt
echo "mean " >> $paffile.chunklengths.txt
awk '{x+=$11}END{print x/NR}' $paffile.Ectopic.tmp >> $paffile.chunklengths.txt
echo "stdev " >> $paffile.chunklengths.txt
awk '{x+=$11;y+=$11^2}END{print sqrt(y/NR-(x/NR)^2)}' $paffile.Ectopic.tmp >> $paffile.chunklengths.txt
echo "histogram " >> $paffile.chunklengths.txt
awk '{counts[$11]++} END {for (c in counts) print c, counts[c]}' $paffile.Ectopic.tmp | sort -nk1 >> $paffile.chunklengths.txt
echo " " >> $paffile.chunklengths.txt
echo " " >> $paffile.chunklengths.txt

echo "Chr " >> $paffile.chunklengths.txt
echo "mean " >> $paffile.chunklengths.txt
awk '{x+=$11}END{print x/NR}' $paffile.chr.tmp >> $paffile.chunklengths.txt
echo "stdev " >> $paffile.chunklengths.txt
awk '{x+=$11;y+=$11^2}END{print sqrt(y/NR-(x/NR)^2)}' $paffile.chr.tmp >> $paffile.chunklengths.txt
echo "histogram " >> $paffile.chunklengths.txt
awk '{counts[$11]++} END {for (c in counts) print c, counts[c]}' $paffile.chr.tmp | sort -nk1 >> $paffile.chunklengths.txt
echo " " >> $paffile.chunklengths.txt
echo " " >> $paffile.chunklengths.txt

echo "Hy-TK " >> $paffile.chunklengths.txt
\echo "mean " >> $paffile.chunklengths.txt
awk '{x+=$11}END{print x/NR}' $paffile.Hy.tmp >> $paffile.chunklengths.txt
echo "stdev " >> $paffile.chunklengths.txt
awk '{x+=$11;y+=$11^2}END{print sqrt(y/NR-(x/NR)^2)}' $paffile.Hy.tmp >> $paffile.chunklengths.txt
echo "histogram " >> $paffile.chunklengths.txt
awk '{counts[$11]++} END {for (c in counts) print c, counts[c]}' $paffile.Hy.tmp | sort -nk1 >> $paffile.chunklengths.txt
echo " " >> $paffile.chunklengths.txt
echo " " >> $paffile.chunklengths.txt

rm $paffile.notchr.tmp
rm $paffile.Ectopic.tmp
rm $paffile.Hy.tmp
rm $paffile.chr.tmp

done < "pafchunkslist.txt"

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

