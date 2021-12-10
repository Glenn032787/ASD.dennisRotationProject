#!/bin/bash

# Download ldsc
git clone https://github.com/bulik/ldsc.git
cd ldsc
conda env create --file environment.yml
cd ..

# Create resource directory
mkdir resources
cd resources

# Download baseline files
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_baselineLD_v2.2_ldscores.tgz

# Download SNP list
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/list.txt
mv list.txt listHM3.txt

# Download plink files
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_plinkfiles.tgz

# Download weights file
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/weights_hm3_no_hla.tgz

# Download frequency file
wget https://storage.googleapis.com/broad-alkesgroup-public/LDSCORE/1000G_Phase3_frq.tgz

# Unzip files
gunzip *.tgz
tar -xf *.tar

