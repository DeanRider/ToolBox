#!/bin/bash

#######################################################################
# 
# This script will scan a folder to create a list of input parsed1 files 
# It will then use the list it created
# and manipulate fields to count characters.
# The sum and per thousand of each type will be presented for each package
# for xy graph type plots for bases inserted at a given site
# Which is not in the previous newCounts or perThousand data set.
#
# Requirements:
# parsed1.txt file
#
# Use: bash InsertedBasesPerThousand.sh
#
# revised December 22, 2022 by S. Dean Rider Jr.
# 
#######################################################################

# scan directory structure for pileup2baseindel results and store as a list
find . -name "*pileup.txt.parsed1.txt" -type file -exec echo '{}' >> insertionlist.txt \;

while read filename; do

echo $filename
echo $'LOCATION\tPOSITION\tCOVERAGE\tINSERTED_BASES' > $filename.InsertedBasesByPosition.txt
awk 'BEGIN{FS=OFS="\t"} { print $1, $2, $4+$5+$6+$7+$8+$9+$10+$11, $12 }' $filename | grep -ivw "NA" | grep -iv "loc" > starthere.txt

awk 'BEGIN{FS="[||\t]"; totchars=0; numchars=0}{for(i=1; i<=NF; i++) {if($i~/:/){fieldlength=length($i); stoplocation=index($i,":")-1; multiplicand=substr($i,1,stoplocation); insertlength=fieldlength-stoplocation-1; numchars=multiplicand*insertlength; totchars+=numchars; OFS="\t" } } print $1,$2,$3,totchars } totchars=0' starthere.txt >> $filename.InsertedBasesByPosition.txt

grep -iv "chr*" $filename.InsertedBasesByPosition.txt > $filename.InsertedBasesByPositionECT.txt

# NOW PER THOUSAND:
echo $'LOCATION\tPOSITION\tINSERTED_BASES_PER_THOUSAND_READS' > $filename.InsertedBasesPerThousand.txt
grep -iv "loc*" $filename.InsertedBasesByPosition.txt | awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$4/$3*1000}' >> $filename.InsertedBasesPerThousand.txt

grep -iv "chr*" $filename.InsertedBasesPerThousand.txt > $filename.InsertedBasesPerThousandECT.txt

# rm starthere.txt

echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";


done < "insertionlist.txt"



exit 0
