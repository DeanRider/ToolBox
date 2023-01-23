#!/bin/bash
#######################################################################
#
# This script will read a list of input reference genomes 
# with corresponding reads files from 'maplist.txt'
# and submit them to BWA-mem to map Pac-Bio reads against a reference.
# If a pair in the list causes errors, the next set is then processed.
# All packages made will be moved into a new folder and
# all of the current post mapping analyses will be done as well.
# This script, maplist, referemces, reads and TOOLS are to be placed into the bwa directory
# 
#
# Requirements:
# bwa-mem, samtools, maplist.txt, reads, references, TOOLS
#
# TOOLS contains:
# Megaparse2.1.sh
# NewSummaryStatsEct.sh
# InsertedBasesPerThousand.sh
# Megapaf2.sh
# paf2circos2.1.sh
# MegaPafChunks2.sh 
# MegaAlvis2.sh 
# BrokenEnds.sh
# Pub2Circos.sh
# getMicroHomPaf.sh
# Pacbio2SnapgeneNames.sh (optional)
# k8
# /misc
# pileup2baseindel.pl
# AlvisYB.jar# AlvisBR.jar# Alvis.jar
# BaseChangeCounter.sh
# BreakpointBases.sh
# OverlapEnds.sh
# pileup2base.pl
#
# Make sure to modify MegaAlvis2.sh to use the flavor of alvis you want
# Make sure to modify Megapaf.sh to rem out the copying of paf files
# Make sure to modify paf2circos2.sh to include any new ectopic site renaming needed
# Make sure to modify Pub2Circos2.1.sh to include any new ectopic site renaming needed
#
# use: bash DoEverything.sh
#
# written January 21, 2023 by S. Dean Rider Jr.
#
#######################################################################


# #########################################################################
#
# set path as a precaution and exit script if anything fails
#
# #########################################################################

cd
cd /Volumes/My\ Passport/bwa
# change the above as needed
echo $PATH
set -e

# #########################################################################
#
# Make date based folder to place the mapping packages into
# use a variable so if date changes during mapping, variable does not
# copy all tools into this folder too
#
# #########################################################################

now=$(date +"%I%p_%m_%d_%Y")
mkdir Mapping_results_$now
cp -a TOOLS/. ./Mapping_results_$now

# #########################################################################
#
# assign filenames to arguments passed in from maplist.txt
#
# #########################################################################

while read referencefile readsfile; do

echo 
echo -e "\033[1;30m ▄▄       ▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄       ▄▄       ▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ \033[0m";
echo -e "\033[1;30m ▐░░▌     ▐░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░░▌     ▐░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌\033[0m";
echo -e "\033[1;30m ▐░▌░▌   ▐░▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌     ▐░▌░▌   ▐░▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌\033[0m";
echo -e "\033[1;30m ▐░▌▐░▌ ▐░▌▐░▌▐░▌          ▐░▌          ▐░▌       ▐░▌     ▐░▌▐░▌ ▐░▌▐░▌▐░▌       ▐░▌▐░▌       ▐░▌\033[0m";
echo -e "\033[1;30m ▐░▌ ▐░▐░▌ ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░▌ ▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌     ▐░▌ ▐░▐░▌ ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌\033[0m";
echo -e "\033[1;30m ▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░▌▐░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌\033[0m";
echo -e "\033[1;30m ▐░▌   ▀   ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌ ▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌     ▐░▌   ▀   ▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ \033[0m";
echo -e "\033[1;30m ▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          \033[0m";
echo -e "\033[1;30m ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          \033[0m";
echo -e "\033[1;30m ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          \033[0m";
echo -e "\033[1;30m  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀       ▀         ▀  ▀         ▀  ▀           \033[0m";
echo -e "\033[1;30m                                                                                                \033[0m";
echo



# #########################################################################
#
# continue script with input parameters of reference and reads file names
#
# #########################################################################

echo "Mapping Run Progress Log" > $referencefile.$readsfile.log
echo "Using DoEverything.sh " >> $referencefile.$readsfile.log
echo Reference file is $referencefile >> $referencefile.$readsfile.log
echo Reads file is $readsfile >> $referencefile.$readsfile.log
date >> $referencefile.$readsfile.log
echo " " >> $referencefile.$readsfile.log

# #########################################################################
#
# index and align reads to reference if not already done
#
# #########################################################################

echo -e "\033[1;37m ██████╗ ██╗    ██╗ █████╗ \033[0m";
echo -e "\033[1;37m ██╔══██╗██║    ██║██╔══██╗\033[0m";
echo -e "\033[1;37m ██████╔╝██║ █╗ ██║███████║\033[0m";
echo -e "\033[1;37m ██╔══██╗██║███╗██║██╔══██║\033[0m";
echo -e "\033[1;37m ██████╔╝╚███╔███╔╝██║  ██║\033[0m";
echo -e "\033[1;37m ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝\033[0m";
echo -e "\033[1;37m                           \033[0m";
echo
echo Checking for index files
echo Checking for index files >> $referencefile.$readsfile.log

if [ -e $referencefile.bwt ]
then
echo -e "\033[1;37m ███████╗██╗  ██╗██╗██████╗     ██╗███╗   ██╗██████╗ ███████╗██╗  ██╗\033[0m";
echo -e "\033[1;37m ██╔════╝██║ ██╔╝██║██╔══██╗    ██║████╗  ██║██╔══██╗██╔════╝╚██╗██╔╝\033[0m";
echo -e "\033[1;37m ███████╗█████╔╝ ██║██████╔╝    ██║██╔██╗ ██║██║  ██║█████╗   ╚███╔╝ \033[0m";
echo -e "\033[1;37m ╚════██║██╔═██╗ ██║██╔═══╝     ██║██║╚██╗██║██║  ██║██╔══╝   ██╔██╗ \033[0m";
echo -e "\033[1;37m ███████║██║  ██╗██║██║         ██║██║ ╚████║██████╔╝███████╗██╔╝ ██╗\033[0m";
echo -e "\033[1;37m ╚══════╝╚═╝  ╚═╝╚═╝╚═╝         ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝\033[0m";
echo -e "\033[1;37m                                                                     \033[0m";
  echo $referencefile.bwt found, Skipping Indexing of Reference
  echo $referencefile.bwt found, Skipping Indexing of Reference >> $referencefile.$readsfile.log
else
echo -e "\033[1;37m ██╗███╗   ██╗██████╗ ███████╗██╗  ██╗\033[0m";
echo -e "\033[1;37m ██║████╗  ██║██╔══██╗██╔════╝╚██╗██╔╝\033[0m";
echo -e "\033[1;37m ██║██╔██╗ ██║██║  ██║█████╗   ╚███╔╝ \033[0m";
echo -e "\033[1;37m ██║██║╚██╗██║██║  ██║██╔══╝   ██╔██╗ \033[0m";
echo -e "\033[1;37m ██║██║ ╚████║██████╔╝███████╗██╔╝ ██╗\033[0m";
echo -e "\033[1;37m ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝\033[0m";
echo -e "\033[1;37m                                      \033[0m";
  echo Indexing reference $referencefile with bwa
  echo Indexing reference $referencefile with bwa >> $referencefile.$readsfile.log
  echo
  ./bwa index $referencefile
  echo Indexing completed successfully >> $referencefile.$readsfile.log
  date >> $referencefile.$readsfile.log
echo " " >> $referencefile.$readsfile.log
  echo
# #########################################################################
#
# Generate .fai, .dict files 
#
# #########################################################################

echo -e "\033[1;37m ███████╗ █████╗ ██╗\033[0m";
echo -e "\033[1;37m ██╔════╝██╔══██╗██║\033[0m";
echo -e "\033[1;37m █████╗  ███████║██║\033[0m";
echo -e "\033[1;37m ██╔══╝  ██╔══██║██║\033[0m";
echo -e "\033[1;37m ██║     ██║  ██║██║\033[0m";
echo -e "\033[1;37m ╚═╝     ╚═╝  ╚═╝╚═╝\033[0m";
echo -e "\033[1;37m                    \033[0m";
echo
echo Generating $referencefile .fai file for future use
samtools fqidx $referencefile -o $referencefile.fai
echo

echo -e "\033[1;37m ██████╗ ██╗ ██████╗████████╗\033[0m";
echo -e "\033[1;37m ██╔══██╗██║██╔════╝╚══██╔══╝\033[0m";
echo -e "\033[1;37m ██║  ██║██║██║        ██║   \033[0m";
echo -e "\033[1;37m ██║  ██║██║██║        ██║   \033[0m";
echo -e "\033[1;37m ██████╔╝██║╚██████╗   ██║   \033[0m";
echo -e "\033[1;37m ╚═════╝ ╚═╝ ╚═════╝   ╚═╝   \033[0m";
echo -e "\033[1;37m                             \033[0m";
echo Making .dict file for future use
samtools dict $referencefile > $referencefile.dict

echo .fai, .dict files completed successfully >> $referencefile.$readsfile.log
date >> $referencefile.$readsfile.log
echo " " >> $referencefile.$readsfile.log

fi

echo
echo Checking for existing .sam files

if [ -e $referencefile.$readsfile.sam ]
then
echo -e "\033[1;37m ███████╗██╗  ██╗██╗██████╗     ███╗   ███╗ █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗ \033[0m";
echo -e "\033[1;37m ██╔════╝██║ ██╔╝██║██╔══██╗    ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝ \033[0m";
echo -e "\033[1;37m ███████╗█████╔╝ ██║██████╔╝    ██╔████╔██║███████║██████╔╝██████╔╝██║██╔██╗ ██║██║  ███╗\033[0m";
echo -e "\033[1;37m ╚════██║██╔═██╗ ██║██╔═══╝     ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██║██║╚██╗██║██║   ██║\033[0m";
echo -e "\033[1;37m ███████║██║  ██╗██║██║         ██║ ╚═╝ ██║██║  ██║██║     ██║     ██║██║ ╚████║╚██████╔╝\033[0m";
echo -e "\033[1;37m ╚══════╝╚═╝  ╚═╝╚═╝╚═╝         ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ \033[0m";
echo -e "\033[1;37m                                                                                         \033[0m";
  echo $referencefile.$readsfile.sam found, Skipping Mapping of Reads
  echo $referencefile.$readsfile.sam found, Skipping Mapping of Reads >> $referencefile.$readsfile.log
else
echo -e "\033[1;37m ███╗   ███╗ █████╗ ██████╗ \033[0m";
echo -e "\033[1;37m ████╗ ████║██╔══██╗██╔══██╗\033[0m";
echo -e "\033[1;37m ██╔████╔██║███████║██████╔╝\033[0m";
echo -e "\033[1;37m ██║╚██╔╝██║██╔══██║██╔═══╝ \033[0m";
echo -e "\033[1;37m ██║ ╚═╝ ██║██║  ██║██║     \033[0m";
echo -e "\033[1;37m ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     \033[0m";
echo -e "\033[1;37m                            \033[0m";
  echo Mapping reads $readsfile onto reference $referencefile with bwa mem
  echo Mapping reads $readsfile onto reference $referencefile with bwa mem >> $referencefile.$readsfile.log
  echo
  ./bwa mem $referencefile $readsfile > $referencefile.$readsfile.sam  #./bwa changed to bwa and back
  echo Mapping completed successfully >> $referencefile.$readsfile.log
  date >> $referencefile.$readsfile.log
echo " " >> $referencefile.$readsfile.log



fi

# #########################################################################
#
# while you are here, might as well get some stats collected
# the mpileup is using old samtools, will need piped through to
# bcftools for use in VCF conversions
#
# #########################################################################

echo
echo Generating Stats
echo -e "\033[1;37m ██████╗  █████╗ ███╗   ███╗\033[0m";
echo -e "\033[1;37m ██╔══██╗██╔══██╗████╗ ████║\033[0m";
echo -e "\033[1;37m ██████╔╝███████║██╔████╔██║\033[0m";
echo -e "\033[1;37m ██╔══██╗██╔══██║██║╚██╔╝██║\033[0m";
echo -e "\033[1;37m ██████╔╝██║  ██║██║ ╚═╝ ██║\033[0m";
echo -e "\033[1;37m ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝\033[0m";
echo -e "\033[1;37m                            \033[0m";
samtools view -S -b $referencefile.$readsfile.sam > $referencefile.$readsfile.bam
echo -e "\033[1;37m ███████╗ ██████╗ ██████╗ ████████╗\033[0m";
echo -e "\033[1;37m ██╔════╝██╔═══██╗██╔══██╗╚══██╔══╝\033[0m";
echo -e "\033[1;37m ███████╗██║   ██║██████╔╝   ██║   \033[0m";
echo -e "\033[1;37m ╚════██║██║   ██║██╔══██╗   ██║   \033[0m";
echo -e "\033[1;37m ███████║╚██████╔╝██║  ██║   ██║   \033[0m";
echo -e "\033[1;37m ╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   \033[0m";
echo -e "\033[1;37m                                   \033[0m";
samtools sort $referencefile.$readsfile.bam -o $referencefile.$readsfile.sorted.bam
wait
echo -e "\033[1;37m ██████╗ ███████╗██████╗ ████████╗██╗  ██╗\033[0m";
echo -e "\033[1;37m ██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██║  ██║\033[0m";
echo -e "\033[1;37m ██║  ██║█████╗  ██████╔╝   ██║   ███████║\033[0m";
echo -e "\033[1;37m ██║  ██║██╔══╝  ██╔═══╝    ██║   ██╔══██║\033[0m";
echo -e "\033[1;37m ██████╔╝███████╗██║        ██║   ██║  ██║\033[0m";
echo -e "\033[1;37m ╚═════╝ ╚══════╝╚═╝        ╚═╝   ╚═╝  ╚═╝\033[0m";
echo -e "\033[1;37m                                          \033[0m";
samtools depth -d 2000000 $referencefile.$readsfile.sorted.bam > $referencefile.$readsfile.DepthOfCoverage.out
wait
echo
echo Adding Headers to Data files and removing some unwanted files
echo reference position depth > DepthHeader
cat DepthHeader $referencefile.$readsfile.DepthOfCoverage.out > $referencefile.$readsfile.DepthOfCoverage.txt
rm DepthHeader
rm $referencefile.$readsfile.DepthOfCoverage.out
echo -e "\033[1;37m ██╗ ██████╗ ██╗   ██╗\033[0m";
echo -e "\033[1;37m ██║██╔════╝ ██║   ██║\033[0m";
echo -e "\033[1;37m ██║██║  ███╗██║   ██║\033[0m";
echo -e "\033[1;37m ██║██║   ██║╚██╗ ██╔╝\033[0m";
echo -e "\033[1;37m ██║╚██████╔╝ ╚████╔╝ \033[0m";
echo -e "\033[1;37m ╚═╝ ╚═════╝   ╚═══╝  \033[0m";
echo -e "\033[1;37m                      \033[0m";
samtools index $referencefile.$readsfile.sorted.bam
echo -e "\033[1;37m ███████╗████████╗ █████╗ ████████╗███████╗\033[0m";
echo -e "\033[1;37m ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝\033[0m";
echo -e "\033[1;37m ███████╗   ██║   ███████║   ██║   ███████╗\033[0m";
echo -e "\033[1;37m ╚════██║   ██║   ██╔══██║   ██║   ╚════██║\033[0m";
echo -e "\033[1;37m ███████║   ██║   ██║  ██║   ██║   ███████║\033[0m";
echo -e "\033[1;37m ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝\033[0m";
echo -e "\033[1;37m                                           \033[0m";
samtools idxstats $referencefile.$readsfile.sorted.bam > $referencefile.$readsfile.ContigLengthNumreads.txt
echo -e "\033[1;37m ██████╗ ██╗██╗     ███████╗██╗   ██╗██████╗ \033[0m";
echo -e "\033[1;37m ██╔══██╗██║██║     ██╔════╝██║   ██║██╔══██╗\033[0m";
echo -e "\033[1;37m ██████╔╝██║██║     █████╗  ██║   ██║██████╔╝\033[0m";
echo -e "\033[1;37m ██╔═══╝ ██║██║     ██╔══╝  ██║   ██║██╔═══╝ \033[0m";
echo -e "\033[1;37m ██║     ██║███████╗███████╗╚██████╔╝██║     \033[0m";
echo -e "\033[1;37m ╚═╝     ╚═╝╚══════╝╚══════╝ ╚═════╝ ╚═╝     \033[0m";
echo -e "\033[1;37m                                             \033[0m";
samtools mpileup -d 0 -f $referencefile $referencefile.$readsfile.sorted.bam > $referencefile.$readsfile.Mpileup.txt

echo Stats estimated successfully >> $referencefile.$readsfile.log
date >> $referencefile.$readsfile.log
echo " " >> $referencefile.$readsfile.log

# #########################################################################
#
# Moving files into package
#
# #########################################################################
echo -e "\033[1;37m ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗\033[0m";
echo -e "\033[1;37m ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝\033[0m";
echo -e "\033[1;37m ██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  \033[0m";
echo -e "\033[1;37m ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  \033[0m";
echo -e "\033[1;37m ██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗\033[0m";
echo -e "\033[1;37m ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝\033[0m";
echo -e "\033[1;37m                                                          \033[0m";


mkdir Mapping_results_$now/package.$referencefile.$readsfile
mv $referencefile.$readsfile.* ./Mapping_results_$now/package.$referencefile.$readsfile/

echo Packaging completed successfully >> Mapping_results_$now/package.$referencefile.$readsfile/$referencefile.$readsfile.log
  date >> Mapping_results_$now/package.$referencefile.$readsfile/$referencefile.$readsfile.log
echo " " >> Mapping_results_$now/package.$referencefile.$readsfile/$referencefile.$readsfile.log

echo "A snapshot of the reference file is here:" >> Mapping_results_$now/package.$referencefile.$readsfile/$referencefile.$readsfile.log
head -2 $referencefile >> Mapping_results_$now/package.$referencefile.$readsfile/$referencefile.$readsfile.log

# #########################################################################
#
# The End of mapping and packaging
#
# #########################################################################

echo -e "\033[1;37m ███╗   ██╗███████╗██╗  ██╗████████╗\033[0m";
echo -e "\033[1;37m ████╗  ██║██╔════╝╚██╗██╔╝╚══██╔══╝\033[0m";
echo -e "\033[1;37m ██╔██╗ ██║█████╗   ╚███╔╝    ██║   \033[0m";
echo -e "\033[1;37m ██║╚██╗██║██╔══╝   ██╔██╗    ██║   \033[0m";
echo -e "\033[1;37m ██║ ╚████║███████╗██╔╝ ██╗   ██║   \033[0m";
echo -e "\033[1;37m ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝   \033[0m";
echo -e "\033[1;37m                                    \033[0m";


done < "maplist.txt"


# #########################################################################
#
# Post mapping analyses
#
# #########################################################################

echo -e "\033[1;37m ██████╗  ██████╗ ███████╗████████╗                           \033[0m";
echo -e "\033[1;37m ██╔══██╗██╔═══██╗██╔════╝╚══██╔══╝                           \033[0m";
echo -e "\033[1;37m ██████╔╝██║   ██║███████╗   ██║                              \033[0m";
echo -e "\033[1;37m ██╔═══╝ ██║   ██║╚════██║   ██║                              \033[0m";
echo -e "\033[1;37m ██║     ╚██████╔╝███████║   ██║                              \033[0m";
echo -e "\033[1;37m ╚═╝      ╚═════╝ ╚══════╝   ╚═╝                              \033[0m";
echo -e "\033[1;37m                                                              \033[0m";
echo -e "\033[1;37m ███╗   ███╗ █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗     \033[0m";
echo -e "\033[1;37m ████╗ ████║██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝     \033[0m";
echo -e "\033[1;37m ██╔████╔██║███████║██████╔╝██████╔╝██║██╔██╗ ██║██║  ███╗    \033[0m";
echo -e "\033[1;37m ██║╚██╔╝██║██╔══██║██╔═══╝ ██╔═══╝ ██║██║╚██╗██║██║   ██║    \033[0m";
echo -e "\033[1;37m ██║ ╚═╝ ██║██║  ██║██║     ██║     ██║██║ ╚████║╚██████╔╝    \033[0m";
echo -e "\033[1;37m ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝     \033[0m";
echo -e "\033[1;37m                                                              \033[0m";

# #########################################################################
#
# Change Directory and run scripts copied from tools folder
#
# #########################################################################

cd ./Mapping_results_$now
bash Megaparse2.1.sh || true
bash NewSummaryStatsEct.sh || true
bash InsertedBasesPerThousand.sh || true
bash Megapaf2.sh || true
bash paf2circos2.1.sh || true
bash MegaPafChunks2.sh || true
bash MegaAlvis2.sh || true
bash BrokenEnds.sh || true
bash Pub2Circos2.1.sh || true
bash getMicroHomPaf.sh || true
bash BaseChangeCounter.sh || true
bash BreakpointBases.sh || true
bash OverlapEnds.sh || true

mkdir ListFiles
find . -name "*ist.txt" -type file -exec mv '{}' ./ListFiles/ \; 
rm *.sh
rm *.pl
rm *.jar
rm k8
rm starthere.txt
chmod -R u+w misc
rm -rf misc

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

echo -e "\033[1;34m -. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .-. .-.   .\033[0m";
echo -e "\033[1;30m ||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|||\|||\ /|\033[0m";
echo -e "\033[1;30m |/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\|||/ \|||\||\033[0m";
echo -e "\033[1;31m ~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-~   \`-~ \`-\`   \`-~ \`-\`   \`-~ \`-\033[0m";
exit 0