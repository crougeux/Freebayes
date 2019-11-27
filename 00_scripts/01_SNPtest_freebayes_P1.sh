#!/bin/bash

#SBATCH --job-name=""
#SBATCH -o log-_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH --time=2-00:00
#SBATCH --mem=6G

module load nixpkgs/16.09 
module load gcc/7.3.0
module load intel/2018.3
module load gcccore/.5.4.0
module load samtools/1.9

cd $SLURM_SUBMIT_DIR

TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
echo "$SCRIPT"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"


# Variables
REF="02_reference"
BAM="03_bam_files"
PLDP="2"						# Ploidy Parents
VCFP="04_raw_VCFs"						

# SNP calling - Genotype diploid Parent
echo "
Calling SNPs in diploid parent...
"

time freebayes -f "$REF" \
    --genotype-qualities \
    -p "$PLDP" \
    "$BAM"/LP_mg0P1_rd.bam > "$VCFP"/LP_P1_rd_RAW.vcf

echo "DONE! Check your files"