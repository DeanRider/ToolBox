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
# Generates tabular list of all linkages present in the .paf file
#
# Requirements:
# .paf file, a custom karyotype file is to be used with Circos.
#
# Best file to use ends with ".newRenamed.tsv".
# Other files are more for information than graphing
#
# use: bash paf2circos2.1.sh
#
# written December 10, 2022 by S. Dean Rider Jr. 
# 
#######################################################################

# scan directory structure for paf results and store as a list
find . -name "*.paf" -type file -exec echo '{}' >> CircosPafList.txt \;

#loop through list in the file and parse data for circos
while read parseref; do

echo $parseref

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

# awk ' $1 == $7 && $2 <= $8 { print $4, $5, $6, $10, $11, $12 } '  $parseref.Sorted.cropped.merged.tmp

# Seems to work as expected
# ################


# ################
# Now to add a sort and count and make thickness

awk ' $1 == $7 && $2 <= $8 { print $4, $5, $6, $10, $11, $12 } '  $parseref.Sorted.cropped.merged.tmp | sort | uniq -c | awk ' BEGIN{OFS="\t";}{print $2,$3,$4,$5,$6,$7,"count = " $1}' > $parseref.Circos.newCounts.tsv || true


awk ' $1 == $7 && $2 <= $8 { print $4, $5, $6, $10, $11, $12 } '  $parseref.Sorted.cropped.merged.tmp | sort | uniq -c | awk '{
if($1 >= 10000)
	thick="16";
else if($1 >= 1000)
	thick="8";
else if($1 >= 100)
	thick="4";
else if($1 >= 10)
	thick="2";
else
	thick="1";
}
BEGIN{OFS="\t";} {print $2,$3,$4,$5,$6,$7,"thickness="thick}' > $parseref.Circos.newThickness.tsv || true

# Seems to work as expected
# ################

# ################
# Now to remove tmp files

rm $parseref.Sorted.cropped.tmp
rm $parseref.Sorted.cropped.merged.tmp

# ################

# ################
# Now Rename different ectopic sites to ECT
# insert new ones as needed with format 
# space semicolon space s/NameOfSiteToReplace/ECT/g
# the final one has no space or semicolon after it
# We can use variables in sed using double quotes:
# sed "s/$var/r_str/g" file_name
# to get ectopic site name, look into sam file first line if tab and colon are field separators, use field 3 of first line
# a=$(echo '111 222 33' | awk '{print $3;}' )
# 

location=$(dirname "$parseref")
echo $location/*.parsed1.txt

EctName=$(awk -F"\t|:" 'NR==1{print $3;}' $location/*.sam)
echo $EctName


cat $parseref.Circos.newThickness.tsv | sed 's/chr23/chrX/g; s/chr24/chrY/g; s/HyTK_406/HyTK/g ; s/A35_EctopicKpnIHouston/ECT/g ; s/A35_Uncut/ECT/g ; s/B38_EctopicKpnIHouston/ECT/g ; s/B38_Uncut/ECT/g ; s/C12_EctopicKpnIHouston/ECT/g ; s/C12_Uncut/ECT/g ; s/Dean_iPCR/ECT/g ; s/EctopicHindIIIdeltaY6/ECT/g ; s/DeltaY6_ATTCT48/ECT/g ; s/N3_EctopicKpnIHouston/ECT/g ; s/N3_Uncut/ECT/g ; s/CAG102RSUNCUT/ECT/g ; s/CAG102RS1/ECT/g ; s/CAG102RS2/ECT/g ; s/CAG102RS_integrated/ECT/g ; s/C12_integrant/ECT/g ; s/A35_integrant/ECT/g ; s/B38_integrant/ECT/g ; s/DF2_CAG102_integrant/ECT/g ; s/DeltaY6_integrant/ECT/g ; s/N3_integrant/ECT/g' | sed "s/$EctName/ECT/g" > $parseref.Circos.newRenamed.tsv

#
# ################

#######################################################################
# Generate stats on microhomology between linked regions
# need to sort lines based on read name and order of chunks based on starting position as a number
# need to keep only useful columns
# want to merge lines together so columns can be compared from adjacent lines
# need to check if col 1 and 7 are the same read and that col 2 is less than col 8 (chunks in order)
# and ask if col 8 is less than or equal to col 3 (BEGINNING OF SECOND CHUNK IS BEFORE END OF FIRST CHUNK)
# if above is true, print col $7,$8,$3,($3-$8+1),$4,$10 
# the +1 in $3-$8+1 handles an "open fence post error"
#######################################################################
echo $'Read\tStart\tEnd\tLength\tFrom\tTo' > $parseref.MicroHomology.txt
sort -k 1,1 -k 3,3n $parseref | awk '{print $1, $3, $4, $6, $8, $9}' | awk 'BEGIN{i=1}{line[i++]=$0}END{j=1; while (j<i) {print line[j], line[j+1]; j+=1}}' | awk ' BEGIN{OFS="\t"} $1 == $7 && $2 <= $8 && $8 <= $3 { print $7, $8, $3, $3-$8+1, $4, $10 ; } ' >> $parseref.MicroHomology.txt


echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";

done < "CircosPafList.txt"

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