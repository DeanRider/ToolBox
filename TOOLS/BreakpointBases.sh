#!/bin/bash

#######################################################################
# 
# This script will scan a folder to create a list of input
# files for BrokenEnds.txt and print lines for sites as a list
# the list will be non redundant to save compute time
# those lines will be used by grep to extract positions from
# the parsed1 files and the output will be a new list of
# site, position, base that is not reduced in complexity
# but will be sorted on column 1 and 2
#
# Requirements:
# *BrokenEnds.txt files
#
# Use: bash BreakpointBases.sh
#
# Written January 13, 2023 by S. Dean Rider Jr.
#
#######################################################################

#rm BrokenList.txt
# scan directory structure for sam results and store as a list
find . -name "*BrokenEnds.txt" -type file -exec echo '{}' \; >> BrokenList.txt

while read parseref; do

awk '{if (NR!=1) {print $12"x"$13+1"\n"$14"x"$15+1} }' $parseref | sort | uniq > $parseref.BasesToGet.txt
awk 'BEGIN{OFS="\t";} {if (NR!=1) {print $12"x"$13+1"\n"$14"x"$15+1} }' $parseref | sort | uniq -c | awk 'BEGIN{OFS="\t";} {print $2,$1 }'> $parseref.CountedBasesToGet.txt

location=$(dirname "$parseref")
echo $location/*.parsed1.txt
awk 'BEGIN{OFS="\t";} {print $1"x"$2,$3} ' $location/*.parsed1.txt | sort > $parseref.BasesFromParsed1.txt

# grep -F -f BasesToGet.txt BasesFromParsed1.txt | sort | uniq > $parseref.BasesNeeded.txt
# above is not needed if join is used properly

echo $'Reference\tPosition\tBase\tCount' > $parseref.CountedBrokenBases.txt
join -1 1 -2 1 $parseref.BasesFromParsed1.txt $parseref.CountedBasesToGet.txt | sed 's/x/ /g' | awk 'BEGIN{OFS="\t";} {print $1,$2,$3,$4 }' >> $parseref.CountedBrokenBases.txt

rm $parseref.BasesToGet.txt
rm $parseref.CountedBasesToGet.txt
rm $parseref.BasesFromParsed1.txt
echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";


done < "BrokenList.txt"
