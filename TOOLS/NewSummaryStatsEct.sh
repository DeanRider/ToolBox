#!/bin/bash

#######################################################################
# 
# This script will scan a folder to create a list of input package files 
# It will then use two files inside each package in the list it created
# and manipulate fields to count characters.
# Each character represents a match or mismatch type 
# the sum and percent of each type will be presented for each package
# for bar graph type plots and includes bases inserted as a measurement
# which is not in the previous summary stats data set.
#
# Requirements:
# package containing parsed1.txt files
# 
# use: bash NewSummaryStatsEct.sh
# revised December 21, 2022 by S. Dean Rider Jr.
# 
# Notes:
# https://stackoverflow.com/questions/49927688/shell-scripting-is-there-a-way-to-use-variable-as-output-instead-of-a-file-for
# Capture output into variable
# output="$(command -f filename)"
# Print it / do whatever you want with it
# echo "$output"
#######################################################################

# scan directory structure for packages and store as a list
find . -name "package.*.fa" -type d -exec echo '{}' >> Packagelist.txt \;


while read packagename; do

echo $packagename

# scan package structure for parsed1 and pileups and store as lists
# find $packagename -name "*pileup.txt.parsed1.txt" -type file -exec echo '{}' >> p1list.txt \;
# find $packagename -name "*.newCounts.txt" -type file -exec echo '{}' >> nclist.txt \;
# while read parsed1name; do
# echo $parsed1name
# done < "p1list.txt"
# while read newcountname; do
# echo $newcountname
# done < "nclist.txt"
# echo "done with package"
# worked as proof of concept, but need to just use this idea for processing each file as needed


# totbase="$(grep -iv "chr*" $packagename/*pileup.txt.parsed1.txt | awk 'BEGIN{FS=OFS="\t"} {sumtot+=($4+$5+$6+$7+$8+$9+$10+$11)} END{print sumtot}')"
echo "$totbase"
# not used, use total bases derived from newCounts.txt


echo $packagename >> NewMutationSummaryStatsECT.txt
insertedbases="$(grep -iv "chr*" $packagename/*pileup.txt.parsed1.txt | awk 'BEGIN{FS=OFS="\t"} { print $12 }' | tr '|' '\n' | grep ":" | tr ':' '\t' | awk 'BEGIN{FS=OFS="\t"} {sum+=($1*(length($2)))} END{print sum}')"
echo "$insertedbases"

echo "NewMutationSummaryStatsECT.txt frequencies are in percentages" >> NewMutationSummaryStatsECT.txt
echo $'Total_Bases\tTotal_insertions\tInserted_bases\tTotal_Del_events\tTotal_Deletions\tTotal_mismatches\tIns_event_freq\tDel_event_freq\tIns_frequency\tDel_frequency\tMismatch_frequency' >> NewMutationSummaryStatsECT.txt

awk -v inserts=$insertedbases 'BEGIN{OFS="\t"}!/chr/{sum4+=$4; sum8+=$8; sum10+=$10; sum12+=$12; sum14+=$14;} END{print sum4, sum8, inserts, sum10, sum12, sum14, sum8/sum4*100, sum10/sum4*100, inserts/sum4*100, sum12/sum4*100, sum14/sum4*100 }' $packagename/*newCounts.txt >> NewMutationSummaryStatsECT.txt

echo " " >> NewMutationSummaryStatsECT.txt


done < "Packagelist.txt"
