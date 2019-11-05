#!/bin/bash

#SBATCH --job-name=""
#SBATCH -o log-_%j.out
#SBATCH --mail-type=ALL
#SBATCH --mail-user=
#SBATCH --time=2-00:00
#SBATCH --mem=4G
 

cd $SLURM_SUBMIT_DIR

TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
echo "$SCRIPT"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"


# Variables
FILTVCF="04_filtered_VCFs/" 
BPVCF="04_filtered_VCFs/"


vcffilter -s -f "TYPE = snp & QUAL > 30" \
    -g "GQ > 20" "$FILTVCF" \ #Making sure (filter overlapping with VCFtools for basic filters)
    "AB > 0.25 & AB < 0.75 | AB < 0.01" \ #Test for allelic imbalance (not supposed in our data)
    | vcfallelicprimitives \
    | vcfbiallelic \
    | vcfnulldotslashdot \
    #| grep -vF './.' | grep -vF '.|.' \ #Hide this line if you dont want to remove all SNPs with missing genotypes. Different threshold can be applied in VCFtools
    > "$BPVCF"


# high quality SNPs 
# keep only SNPs (strip away complex extra haplotype info)
# discard multi-allelic SNPs
# allele balance test. Include variants that are close to zero
# mark SNPs with missing genotypes
# remove snps with missing genotypes (not applied here)
# keep the filtered information into final VCF
