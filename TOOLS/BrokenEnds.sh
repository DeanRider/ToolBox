#!/bin/bash

#######################################################################
# 
# This script will scan a folder to create a list of input .paf files 
# It will then use each file in the list it created.
# Generates stats on starts and ends between linked regions.
#
# Requirements:
# .paf file
# 
# Use: bash BrokenEnds.sh
#
# written January 9, 2023 by S. Dean Rider Jr. 
# 
#######################################################################

# scan directory structure for paf results and store as a list
find . -name "*.paf" -type file -exec echo '{}' >> BreaksPafList.txt \;

#loop through list in the file and parse data for circos
while read parseref; do

echo $parseref


#######################################################################
# Generate stats on starts and ends between linked regions
# need to sort lines based on read name and order of chunks based on starting position as a number
# need to keep only useful columns
# want to merge lines together so columns can be compared from adjacent lines
# need to check if col 1 and 10 are the same read and that col 3 is less than col 12 (chunks in order)
# if above is true, print col $1, $6, $5 $7, $8, $9, $15, $14, $16, $17, $18, $19, $6, $9, $15, $17  
#######################################################################
echo $'Read\tSource1\tDirection\tLength\tStart\tEnd\tSource2\tDirection\tLength\tStart\tEnd\t\tSource1\tBreakPoint\tSource2\tBreakPoint' > $parseref.BrokenEnds.txt
sort -k 1,1 -k 3,3n $parseref | awk '{print $1, $2, $3, $4, $5, $6, $7, $8, $9}' | awk 'BEGIN{i=1}{line[i++]=$0}END{j=1; while (j<i) {print line[j], line[j+1]; j+=1}}' | awk ' BEGIN{OFS="\t"} $1 == $10 && $3 < $12 { print $1, $6, $5, $7, $8, $9, $15, $14, $16, $17, $18, $19, $6, $9, $15, $17 ; } ' >> $parseref.BrokenEnds.txt


echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";

done < "BreaksPafList.txt"

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