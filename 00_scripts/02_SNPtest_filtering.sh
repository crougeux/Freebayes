#!/bin/bash

#SBATCH --job-name=""
#SBATCH -o log-_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH --time=2-00:00
#SBATCH --mem=2G


module load tabix/0.2.6
module load vcftools

cd $SLURM_SUBMIT_DIR

TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
echo "$SCRIPT"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

# Variables
VCF="04_raw_VCFs" 											# Directory with raw VCFs
PVCF="04_raw_VCFs/"											# Parent VCF
FVCF="04_raw_VCFs/"											# F1s VCF
RAWVCF="04_raw_VCFs/"										# Merged raw VCF (i.e. parents + F1s)
FILTVCF="05_filtered_VCFs/"									# Filtered VCF
GT="06_GT"


# Merge vcf files from parents and F1s - Files have to be bgzip & tabix indexed
echo "
Preparing the VCFs for merging
"
for i in "$VCF"/LP_*_RAW.vcf 
    do bgzip $i && tabix -p vcf "$i".gz
done

# NOTE THAT DEPENDING ON THE TOOL USED< THE MERGING STEP MIGHT NOT BE NECESSARY!
echo "
Merging the VCFs....
"
vcf-merge $PVCF $FVCF | bgzip -c > $RAWVCF

# Filtering the merged vcf file - Quality (QG>20) . depth (>5) . SNP called in > 10 ind
echo "
Filtering the raw full VCF...can take some time...
"
vcftools --gzvcf $RAWVCF \
    --minGQ 20 \
    --minDP 5 \
    --mac 10 \
    --recode \
    --stdout | gzip -c > $FILTVCF 

# Generate .GT file for subsequent analyses
echo "
Generating the GT file from VCF...
" 
vcftools --gzvcf $FILTVCF --extract-FORMAT-info GT --out "$GT"/$(basename $FILTVCF .vcf.gz)

echo "DONE! Check your files"
