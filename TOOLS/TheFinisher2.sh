#!/bin/bash

############################################################################
#
# This script runs the post mapping scripts
# Make sure all of the following tools are in the
# quarantine folder before starting:
# TheFinisher.sh
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
# Make sure to modify Pub2Circos.sh to include any new ectopic site renaming needed
#
# written December 31, 2022 by S. Dean Rider,  Jr.
#
############################################################################

bash Megaparse2.1.sh || true
bash NewSummaryStatsEct.sh || true
bash InsertedBasesPerThousand.sh || true
bash Megapaf2.sh || true
bash paf2circos2.1.sh || true
bash MegaPafChunks2.sh || true
bash MegaAlvis2.sh || true
bash BrokenEnds.sh || true
bash Pub2Circos.sh || true
bash getMicroHomPaf.sh || true
bash BaseChangeCounter.sh || true
bash BreakpointBases.sh || true
bash OverlapEnds.sh || true

mkdir ListFiles
find . -name "*ist.txt" -type file -exec mv '{}' ./ListFiles/ \; 
rm starthere.txt
# rm *.ist.txt
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
