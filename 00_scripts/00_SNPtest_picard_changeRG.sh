#!/bin/bash

#SBATCH --job-name="" 
#SBATCH -o log-_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH --time=0-10:00
#SBATCH --mem=7G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

# Global variables
INBAM="03_bam_files"
OUTBAM="03_bam_files"

cd $SLURM_SUBMIT_DIR

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="99_log_files"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

# Load needed modules
module load nixpkgs/16.09
module load java/1.8.0_192
module load picard/2.20.6

# Remove duplicates from bam alignments
echo "
Removing duplicates...
"

ls -1 "$INBAM"/*_rd.bam |
    while read file
    do
        echo "Changing RG sample $file"
        java -jar $EBROOTPICARD/picard.jar AddOrReplaceReadGroups \
	    I="$file" \
	    O="$OUTBAM"/$(basename "$file" .bam)_RG.bam \
	    RGID=$(basename "$file" _rd.bam) \
	    RGLB=$(basename "$file" _rd.bam)_LB \
	    RGPL=ILLUMINA \
	    RGPU=unit1 \
	    RGSM=$(basename "$file" _rd.bam)
done

echo "DONE! Check your files"
