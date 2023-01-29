#!/bin/bash

#######################################################################
# 
# This script will scan a folder to create a list of input .paf files 
# It will then use each file in the list it created.
# 
# So, since I don't know how to handle row-column stuff in awk, but 
# I do know how to deal with columns, I will merge pairs of lines 
# together and deal with the resulting columns. 
# from: https://stackoverflow.com/questions/3194534/joining-two-consecutive-lines-using-awk-or-sed
#
# Generates tabular list of all linkages present in the .paf file and removes 
# ectopic to ectpoic linkages to simplify the appearance of the circos plots.
#
# Requirements:
# .paf file, .sam, a custom karyotype file is to be used with Circos.
#
# Best file to use ends with "CircosSimplifiedThickness.tsv".
# Other files are more for information than graphing
#
# use: bash Pub2Circos2.1.sh
#
# written January 9, 2023 by S. Dean Rider Jr. 
# REVISED JANUARY 29, 2023
#######################################################################

# scan directory structure for sam results and store as a list
find . -name "*.paf" -type file -exec echo '{}' >> CircosPubList.txt \;

#loop through list in the file and parse data for circos
while read parseref; do

echo $parseref

##### working scripts  ##########

# ################
# need to sort lines based on read name and order of chunks based on starting position as a number
# need to keep only useful columns

sort -k 1,1 -k 3,3n $parseref | awk '{print $1, $3, $4, $6, $8, $9}' > $parseref.Sorted.cropped.tmp

# ok for now 
# ################


# ################
# want to merge lines together so columns can be compared from adjacent lines

awk 'BEGIN{i=1}{line[i++]=$0}END{j=1; while (j<i) {print line[j], line[j+1]; j+=1}}' $parseref.Sorted.cropped.tmp > $parseref.Sorted.cropped.merged.tmp

# merges each line with the next as desired
# ################


# ################
# need to check if col 1 and 7 are the same and that col 2 is less than col 8
# if above is true, print col 4,5,6 and col 10,11,12

# awk ' $1 == $7 && $2 <= $8 { print $4,$ 5, $6, $10, $11, $12 ; } '  $parseref.Sorted.cropped.merged.tmp

# Seems to work as expected
# ################


# ################
# Now to keep only lines with chr

grep "chr" $parseref.Sorted.cropped.merged.tmp > $parseref.ChrOnly.tmp

# ################
# Now to rename ectopic sites 
# We can use variables in sed using double quotes:
# sed "s/$var/r_str/g" file_name
# to get ectopic site name, look into sam file first line if tab and colon are field separators, use field 3 of first line
# a=$(echo '111 222 33' | awk '{print $3;}' )
# 

location=$(dirname "$parseref")
echo $location/*.parsed1.txt

EctName=$(awk -F"\t|:" 'NR==1{print $3;}' $location/*.sam)
echo $EctName

cat $parseref.ChrOnly.tmp | sed 's/chr23/chrX/g; s/chr24/chrY/g; s/HyTK_406/HyTK/g' | sed "s/$EctName/ECT/g" > $parseref.ChrOnlyRenamed.tmp

# ################
# still need to check if col 1 and 7 are the same and that col 2 is less than col 8
# if above is true, print col 4,5,6 and col 10,11,12
# to keep only start and end and for ect, chr
awk ' $1 == $7 && $2 <= $8 { print $4,$ 5, $6, $10, $11, $12 ; } ' $parseref.ChrOnlyRenamed.tmp > $parseref.ChrOnlystartend.tmp
awk ' $1~/ECT/ { print $1, 100, 10000, $4, $5, $6 ; } ' $parseref.ChrOnlystartend.tmp > $parseref.Simplifiedtartend.tmp
awk ' $4~/ECT/ { print $1, $2, $3, $4, 100, 10000 ; } ' $parseref.ChrOnlystartend.tmp >> $parseref.Simplifiedtartend.tmp
awk ' $4~/chr/ && $1~/chr/ { print $1, $2, $3, $4, $5, $6 ; } ' $parseref.ChrOnlystartend.tmp >> $parseref.Simplifiedtartend.tmp

awk '{ print $1, int($2/10000)*10000, int($3/10000)*10000, $4, int($5/10000)*10000, int($6/10000)*10000 ; } ' $parseref.Simplifiedtartend.tmp >> $parseref.SimplifiedtartendInteger.tmp
sort $parseref.SimplifiedtartendInteger.tmp | uniq -c | awk '{ print $2,$3,$4,$5,$6,$7,$1 ; } ' > $parseref.CircosSimplifiedCounts.txt



sort $parseref.SimplifiedtartendInteger.tmp | uniq -c | awk '{
if($1 >= 10000)
	thick="22";
else if($1 >= 1000)
	thick="18";
else if($1 >= 100)
	thick="12";
else if($1 >= 10)
	thick="5";
else
	thick="2";
}
BEGIN{OFS="\t";} {print $2,$3,$4,$5,$6,$7,"thickness="thick}' > $parseref.CircosSimplifiedThickness.tsv || true

rm $parseref.*.tmp

echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";

done < "CircosPubList.txt"

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
