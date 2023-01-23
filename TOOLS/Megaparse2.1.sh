#!/bin/bash
#######################################################################
# 
# This script will scan a folder to create a list of input pileup files 
# It will then use each file in the list it created
# and count characters.
# Each character represents a match or mismatch type 
# awk will determine the counts of indels and matches; mismatch 
# is the difference between depth and matches + deletions.
# The data will then be printed out on a per line basis as
# pairs of position based xy data for scatter plots
#
# Requirements:
# *pileup.txt file
#
# use: bash Megaparse2.1.sh
#
# revised December 6, 2022 by S. Dean Rider Jr.
# 
#######################################################################

# scan directory structure for Mpile results and store as a list
find . -name "*pileup.txt" -type file -exec echo '{}' >> parselist.txt \;

echo 
echo " ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄            ▄▄▄▄▄▄▄▄▄▄▄                           ";
echo "▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌                          ";
echo "▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀█░█▀▀▀▀ ▐░▌          ▐░█▀▀▀▀▀▀▀▀▀                           ";
echo "▐░▌       ▐░▌     ▐░▌     ▐░▌          ▐░▌                                    ";
echo "▐░█▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░▌          ▐░█▄▄▄▄▄▄▄▄▄                           ";
echo "▐░░░░░░░░░░░▌     ▐░▌     ▐░▌          ▐░░░░░░░░░░░▌                          ";
echo "▐░█▀▀▀▀▀▀▀▀▀      ▐░▌     ▐░▌          ▐░█▀▀▀▀▀▀▀▀▀                           ";
echo "▐░▌               ▐░▌     ▐░▌          ▐░▌                                    ";
echo "▐░▌           ▄▄▄▄█░█▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄                           ";
echo "▐░▌          ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌                          ";
echo " ▀            ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀                           ";
echo "                                                                              ";
echo " ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ ";
echo "▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌";
echo "▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌";
echo "▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌          ▐░▌       ▐░▌";
echo "▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌";
echo "▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌";
echo "▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀█░█▀▀  ▀▀▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀█░█▀▀ ";
echo "▐░▌          ▐░▌       ▐░▌▐░▌     ▐░▌            ▐░▌▐░▌          ▐░▌     ▐░▌  ";
echo "▐░▌          ▐░▌       ▐░▌▐░▌      ▐░▌  ▄▄▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌      ▐░▌ ";
echo "▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌";
echo " ▀            ▀         ▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀ ";
echo "                                                                              ";
echo


while read pileref; do

echo $pileref

echo $'LOCATION\tPOSITION\tBASE\tDEPTH\tPOSITION\tMATCHES\tPOSITION\tINSERTION_EVENTS\tPOSITION\tDELETION_EVENTS\tPOSITION\tDELETIONS\tPOSITION\tMISMATCH_CALC' > $pileref.newCounts.txt
echo $'LOCATION\tPOSITION\tBASE\tDEPTH\tPOSITION\tMATCHES\tPOSITION\tINSERTION_EVENTS\tPOSITION\tDELETION_EVENTS\tPOSITION\tDELETIONS\tPOSITION\tMISMATCH_CALC' > $pileref.perThousand.txt

#  ####
# https://unix.stackexchange.com/questions/670184/how-can-i-count-number-of-a-specific-character-in-a-column-for-each-line-and-add
# The gsub() function returns the number of made substitutions. 
# You may use this fact to count the number of N characters in the 2nd field and to add this number as a new field on each line:
# example: awk -F '\t' '{ $3 = gsub("N","N",$2) }; 1' file
# ####

# current Mpileup.txt layout is \t separated
# LOCATION POSITION BASE DEPTH PILEUP BASE-QUALITIES
# pileup that counts as bases are .,* but not +-^$ However, ACGTacgt are problems because they can be mismatches or part of indels
# need to confirm that depth minus matches and deleted bases equals mismatches and then
# want to print LOCATION POSITION BASE DEPTH then calcs from gsub of the following: [\.\,] [\+] [\*] [\-] then depth minus .,*

# generate table that is easy to graph in excel using pairs of columns
awk 'BEGIN{FS=OFS="\t"} {depth=$4; insertion=gsub(/\+/,"",$5); deletion=gsub(/\*/,"",$5); delevent=gsub(/\-/,"",$5); commas=gsub(/,/,"",$5); periods=gsub(/\./,"",$5); matches=commas+periods; mismatch=depth-commas-periods-deletion} { print $1,$2,$3,$4,$2,matches,$2,insertion,$2,delevent,$2,deletion,$2,mismatch }' "$pileref" >> $pileref.newcounts.txt || true

# duplicate above and make new frequencies per thousand table
awk 'BEGIN{FS=OFS="\t"} {depth=$4; insertion=gsub(/\+/,"",$5); deletion=gsub(/\*/,"",$5); delevent=gsub(/\-/,"",$5); commas=gsub(/,/,"",$5); periods=gsub(/\./,"",$5); matches=commas+periods; mismatch=depth-commas-periods-deletion} { print $1,$2,$3,$4,$2,matches/depth*1000,$2,insertion/depth*1000,$2,delevent/depth*1000,$2,deletion/depth*1000,$2,mismatch/depth*1000 }' "$pileref" >> $pileref.perThousand.txt || true

# Extract only non chr site lines from above to graph more easily the Ectopic Sites
grep -v "chr" $pileref.perThousand.txt > $pileref.perThousandEctopicOnly.txt

echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";

perl pileup2baseindel.pl -i $pileref -bq -5 -prefix $pileref.parsed

done < "parselist.txt"


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




