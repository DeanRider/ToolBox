#!/bin/bash

#######################################################################
# 
# This script will scan a folder to create a list of input microhomology,txt files 
# It will then use each file in the list it created
# and evaluate field 1 to make a list of reads to extract from a paf file.
#
# Requirements:
# .MicroHomology.txt file
# 
# Use: bash getMicroHomPaf.sh
#
# written January 3, 2023 by S. Dean Rider Jr. 
# 
#######################################################################

# scan directory structure for sam results and store as a list
rm MicroHomologyList.txt
find . -name "*.MicroHomology.txt" -type file -exec echo '{}' >> MicroHomologyList.txt \;

#loop through list in the file and parse data for RG
while read parseref; do

echo $parseref
location=$(dirname "$parseref")
awk -F "\t" '{print $1}' $parseref | sort -u > readslisttoget.txt
#awk -v FS="\t" 'NR==FNR{rows[$1]++;next}(substr($NF,1,length($NF)-1) in rows)' readslisttoget.txt $location/*.sam.paf
echo $location/*.sam.paf
grep -f readslisttoget.txt $location/*.sam.paf | awk -F "\t" 'BEGIN {OFS="\t"}{print $1,$2,$3,$4,$5,$6,$7,$8,$9}' > $location/MicroHomologyPartialPafData.txt
rm readslisttoget.txt
echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";

done < "MicroHomologyList.txt"

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




