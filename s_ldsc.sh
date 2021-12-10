#!/bin/bash
#PBS -l walltime=8:00:00,select=1:ncpus=16:mem=64gb
#PBS -N test.make_annot
#PBS -A st-dennisjk-1
#PBS -M glenn03@student.ubc.ca 
#PBS -m bea

plink_dir="resources/1000G_EUR_Phase3_plink"
snpList_dir="resources/listHM3.txt"
weights_dir="resources/weights_hm3_no_hla"
freq_dir="resources/1000G_Phase3_frq"
baselineLD_dir="resources/baselineLD"

source activate ldsc
module load bedtools2

bedtools sort -i maternalInflamationGenes.bed > sorted.maternalInflamationGenes.bed

mkdir inflammation.annotation

for i in {1..22}; do 
	echo "Starting annotation of CHR $i"
	python ldsc/make_annot.py \
		--bed-file sorted.maternalInflamationGenes.bed \
		--bimfile ${plink_dir}/1000G.EUR.QC.${i}.bim \
		--annot-file inflammation.annotation/inflammation.${i}.annot.gz
	echo "Finish annotation of CHR $i"

	echo "Starting ld score estimation of CHR $i"	
	python ldsc/ldsc.py \
		--l2 \
		--bfile ${plink_dir}/1000G.EUR.QC.${i} \
		--ld-wind-cm 1 \
		--annot inflammation.annotation/inflammation.${i}.annot.gz \
		--thin-annot \
		--out inflammation.annotation/inflammation.${i} \
		--print-snps ${snpList_dir}
	echo "Finish ld score estimation of CHR $i"	
done


python ldsc/ldsc.py \
	--h2 ASD.sumstats.gz \
	--w-ld-chr ${weights_dir}/weights. \
	--ref-ld-chr inflammation.annotation/inflammation.,${baselineLD_dir}/baselineLD. \
	--overlap-annot \
	--frqfile-chr ${freq_dir}/1000G.EUR.QC. \
	--out ASD_inflammation \
	--print-coefficients \
	--thin-annot 




