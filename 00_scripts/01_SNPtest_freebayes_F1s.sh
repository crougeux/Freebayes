#!/bin/bash

#SBATCH --job-name=""
#SBATCH -o log-f_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH --time=12-00:00
#SBATCH --mem=20G

module load nixpkgs/16.09
module load gcc/7.3.0
module load intel/2018.3
module load samtools/1.9

cd $SLURM_SUBMIT_DIR

TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
echo "$SCRIPT"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

# Variables
REF="01_reference"
IREF="01_reference"
BAM="02_bam_files"
POP=""							# See Freebayes requirements for population map
PLD="1 "							# Ploidy level
VCF="03_raw_VCFs"


# SNP calling - Genotype haploid Offspring 
time freebayes -f "$REF" \
	--populations "$POP" \
	-p "$PLD" \
	-L "$BAM" \
	--genotype-qualities \
	--min-alternate-fraction 0.1 > "$VCF"/LP_POPlist_freebayes_RAW.vcf

