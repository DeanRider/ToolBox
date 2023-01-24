#!/bin/bash

#######################################################################
# 
# This script will scan a folder to create a list of input .paf files 
# It will then use each file in the list it created.
# 
# Generates a tabular list of all overlaps present in the .paf file
# Each overlap includes read, first chunk, second chunk coordinates.
#
# Requirements:
# .paf files as input
#
# use: bash OvelapEnds.sh
#
# written January 18, 2022 by S. Dean Rider Jr. 
# 
#######################################################################

# scan directory structure for paf results and store as a list
find . -name "*.paf" -type file -exec echo '{}' >> OverlapsPafList.txt \;

#loop through list in the file and parse data for overlapping end data
while read parseref; do

echo $parseref


#######################################################################
# Generate stats on microhomology between linked regions
# need to sort lines based on read name and order of chunks based on starting position as a number
# need to keep only useful columns and add 1 to each value because of zero based counting in paf files
# want to merge lines together so columns can be compared from adjacent lines
# need to check if col 1 and 7 are the same read and that col 2 is less than col 8 (chunks in order)
# and ask if col 8 is less than or equal to col 3 (BEGINNING OF SECOND CHUNK IS BEFORE END OF FIRST CHUNK)
# if above is true, print col $7,$8,$3,($3-$8+1),$4,$10 
# the +1 in $3-$8+1 handles an "open fence post error"
#######################################################################


# want read name, start of micro, end of micro, from, start of micro, end of micro, to, start of micro, end of micro
# have 14 columns: read name, start, end, direction, reference1 name, start, end, read name, start, end, direction, reference2 name, start, end
# 
# Examples Joined Lines With MicroHomology:
# m64296e_220610_145044/100467962/ccs 1 342 - GQ6_integrant 13163 13506 m64296e_220610_145044/100467962/ccs 341 1330 - GQ6_integrant 13740 14729
# m64296e_220610_145044/100731382/ccs 5 98 + GQ6_integrant 13740 13833 m64296e_220610_145044/100731382/ccs 94 149 + chr23 150824120 150824173
# m64296e_220610_145044/100991223/ccs 1 343 - GQ6_integrant 13163 13506 m64296e_220610_145044/100991223/ccs 342 1325 - GQ6_integrant 13740 14729
# read name ($1)
# no math to get start of micro in read ($9)
# no math to get end of micro in read ($3)
#
# no math to get reference1 ($5)
# math to get reference1 start of micro ($7-($3-$9)) if $4~/f/
# no math to get end of micro ($7) if $4~/f/ 
#
# no math to get start of micro ($7) if $4~/r/ 
# same math to get reference1 end of micro ($7-($3-$9)) if $4~/r/
#
# no math to get reference2 ($12)
# no math to get start of micro ($13) if $11~/f/ 
# math to get end of micro in reference1 ($13+($3-$9)) if $11~/f/ 
#
# no math to get reference2 start of micro ($14) if $11~/r/
# math to get end of micro ($14-($3-$9)) if $11~/r/ 
#
# 4 possible orientations: + +, + -, - +, - -
sort -k 1,1 -k 3,3n $parseref | awk 'BEGIN{OFS="\t"} {print $1, $3+1, $4+1, $5, $6, $8+1, $9+1}' | awk 'BEGIN{i=1}{line[i++]=$0}END{j=1; while (j<i) {print line[j], line[j+1]; j+=1}}' | awk ' BEGIN{OFS="\t"} $1 == $8 && $2 <= $9 && $9 <= $3 { print $0 ; } ' | sed 's/\+/f/g ; s/\-/r/g ' > $parseref.JoinedLinesWithMicroHomology.tmp

awk ' BEGIN{OFS="\t"}  $4~/f/ && $11~/f/ { print $1, $9, $3, $5, $7-($3-$9), $7, $12, $13, $13+($3-$9) ; } ' $parseref.JoinedLinesWithMicroHomology.tmp > $parseref.SixSets.tmp


awk ' BEGIN{OFS="\t"}  $4~/f/ && $11~/r/ { print $1, $9, $3, $5, $7-($3-$9), $7, $12, $14, $14-($3-$9) ; } ' $parseref.JoinedLinesWithMicroHomology.tmp >> $parseref.SixSets.tmp


awk ' BEGIN{OFS="\t"}  $4~/r/ && $11~/f/ { print $1, $9, $3, $5, $7, $7-($3-$9), $12, $13, $13+($3-$9) ; } ' $parseref.JoinedLinesWithMicroHomology.tmp >> $parseref.SixSets.tmp


awk ' BEGIN{OFS="\t"}  $4~/r/ && $11~/r/ { print $1, $9, $3, $5, $7, $7-($3-$9), $12, $14, $14-($3-$9) ; } ' $parseref.JoinedLinesWithMicroHomology.tmp >> $parseref.SixSets.tmp
echo $'Read\tStart\tEnd\tReference1\tStart\tEnd\tReference2\tStart\tEnd' > $parseref.OverlappingEnds.txt
sort -k 1,1 -k 2,2n $parseref.SixSets.tmp >> $parseref.OverlappingEnds.txt

echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";

rm $parseref.SixSets.tmp
rm $parseref.JoinedLinesWithMicroHomology.tmp

done < "OverlapsPafList.txt"

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
