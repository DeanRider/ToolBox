# ToolBox
Contains all tools in the pipeline from mapping rebuilt, deduplicated reads to reformatting data for use with graphing software.

Place the DoEverything.sh script, maplist.txt file and TOOLS folder into the bwa directory along with your reference genomes and rebuilt deduplicated readsets. Each script has sufficient annotation at the beginning and throughout to determine what it does. A summary pdf will be added to this repository. The DoEverything.sh script is able to be ammended to add new scripts to the pipeline.

If a preliminary mapping run was already performed (i.e. via Megamap2.sh), the scripts for rebuilding the .sam file and deduplicating the reads are included. This should be done before using the DoEverything.sh pipeline script.
