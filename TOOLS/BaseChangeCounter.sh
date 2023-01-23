#!/bin/bash

#######################################################################
# 
# This script will scan a folder to create a list of input *pile files 
# It will then use each file in the list it created and run the perl
# script pileup2base.pl, which is better at tabulating bases by position
# It then uses if-then statements in awk to determine what the reference
# base is and if mutations occurred.
# It then prints each of the totals for the 12 possible changes.
# It then combines pairs to represent the 6 mutation types for output.
# It then prints a sum of all the changes at the end of the file.
#
# Requirements:
# perl, pileup2base.pl, *pile.txt file
# 
# use: bash BaseChangeCounter.sh
#
# written January 12, 2023 by S. Dean Rider Jr. 
# 
#######################################################################

# scan directory structure for sam results and store as a list
find . -name "*pileup.txt" -type file -exec echo '{}' >> MutTypesList.txt \;

#loop through list in the file and parse data for circos
while read parseref; do

echo $parseref

perl pileup2base.pl $parseref 5 $parseref.parsed

# mutation types are: A>C, A>G, A>T, C>A, C>G, C>T, G>A, G>C, G>T, T>A, T>C, T>G
# A>C = t>g, A>G = t>c, A>T = t>a, C>A = g>t, C>G = g>c, C>T = g>a
#
# AKA
# A/T > C/G, A/T > G/C, A/T > T/A, C/G > A/T, C/G > G/C, C/G > T/A
#
#  order of bases in file is 	4	5	6	7	8	9	10	11
# 				A	T	C	G	a	t	c	g
#
# easiest to figure 12 change types first and condense second
# 

echo $'Reference\tPosition\tBase\tNo Change\tA>T\tA>C\tA>G\tT>A\tT>C\tT>G\tC>A\tC>T\tC>G\tG>A\tG>T\tG>C' > $parseref.MutationTypes.tmp
awk 'BEGIN{OFS="\t";} $3~/A|a/ {print $1,$2,$3, $4+$8, $5+$9,$6+$10,$7+$11,0,0,0,0,0,0,0,0,0} ' $parseref.parsed > $parseref.Types.tmp
awk 'BEGIN{OFS="\t";} $3~/T|t/ {print $1,$2,$3, $5+$9, 0,0,0,$4+$8,$6+$10,$7+$11,0,0,0,0,0,0} ' $parseref.parsed >> $parseref.Types.tmp
awk 'BEGIN{OFS="\t";} $3~/C|c/ {print $1,$2,$3, $6+$10, 0,0,0,0,0,0,$4+$8,$5+$9,$7+$11,0,0,0} ' $parseref.parsed >> $parseref.Types.tmp
awk 'BEGIN{OFS="\t";} $3~/G|g/ {print $1,$2,$3, $7+$11, 0,0,0,0,0,0,0,0,0,$4+$8,$5+$9,$6+$10} ' $parseref.parsed >> $parseref.Types.tmp

sort -k 1,1 -k 2,2n $parseref.Types.tmp > $parseref.MutationTypes.tmp

# 1 Reference, 2 position, 3 base, 4 no change
# mutation Cols are: 	5	6	7	8	9	10	11	12	13	14	15	16
#			A>T	A>C	A>G	T>A	T>C	T>G	C>A	C>T	C>G	G>A	G>T	G>C
	
# combine type 	A>C=t>g	A>G=t>c	A>T=t>a	C>A=g>t	C>G=g>c	C>T=g>a	
# column number	6+10	7+9	5+8	11+15	13+16	12+14

# echo " " > $parseref.MutationTypes.txt
echo $'Reference\tPosition\tBase\tNo Change\tA/T>C/G\tA/T>G/C\tA/T>T/A\tC/G>A/T\tC/G>G/C\tC/G>T/A' > $parseref.MutationTypes.txt
awk 'BEGIN{OFS="\t";}{print $1,$2,$3,$4, $6+$10,$7+$9,$5+$8,$11+$15,$13+$16,$12+$14} ' $parseref.MutationTypes.tmp | sort -k 1,1 -k 2,2n >> $parseref.MutationTypes.txt
awk 'BEGIN{OFS="\t";}{sum4+=$4; sum5+=$5; sum6+=$6; sum7+=$7; sum8+=$8; sum9+=$9; sum10+=$10 ;} END{print "totals","","",sum4,sum5,sum6,sum7,sum8,sum9,sum10;}' $parseref.MutationTypes.txt >> $parseref.MutationTypes.txt

rm $parseref.Types.tmp
rm $parseref.MutationTypes.tmp

echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";


done < "MutTypesList.txt"

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