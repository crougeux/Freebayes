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
INFO="01_info_files" 
BPVCF="04_filtered_VCFs"
IN=""							#VCF file pre-filtered with Basic Filters
OUT=""							#VCF file name prefix

# Let's filter out low QUALity SNPs with vcflib suite - 
echo "
>	Filtering VCF file with vcflib
"
vcffilter -o -f "TYPE = snp" \
    -f "QUAL > 30" \
    -g "GQ > 20" "$BPVCF"/"$IN" \ 
    | vcfbiallelic \
    > "$BPVCF"/"$OUT"_biallelic.vcf

#'''
# high quality SNPs 
# keep only SNPs (strip away complex extra haplotype info)
# discard multi-allelic SNPs
# keep the filtered information into final VCF
#'''

# Since we allow NAs, we apply a threshold of missing data with VCFTOOLS
echo "
>>	Filtering out NAs from the VCF file & generatin GT file
"
vcftools --vcf "$BPVCF"/"$OUT"_biallelic.vcf --max-missing 0.5 --recode --out "$BPVCF"/"$OUT"_hard && \
vcftools --vcf "$BPVCF"/"$OUT"_hard.recode.vcf --extract-FORMAT-info GT --out "$BPVCF"/"$OUT"_hard 

# We want SNPs comparable to our truth set, so let's keep shared posisions from the output of "find_impossible_GTs.R"
echo "
>>>	Looking for SNPs shared amont Parent and offsprings
"
grep -v "\." site_num_mismatch_GT_test_hard.txt | cut -f1,2 > shared_pos_P1F1.txt

echo "
>>>>	Generating VCF file for shared positions & associated GT file
"
vcftools --vcf "$BPVCF"/"$OUT"_hard.recode.vcf --positions "$INFO"/shared_pos_P1F1.txt --recode --out "$BPVCF"/"$OUT"_hard_shared_F1P1 && \
vcftools --vcf "$BPVCF"/"$OUT"_hard_shared_F1P1.recode.vcf --extract-FORMAT-info GT --out test_hard_shared_F1P1



