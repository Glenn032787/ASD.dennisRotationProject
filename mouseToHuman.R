library(biomaRt)
library(tidyverse)
library(readxl)

human = useMart("ensembl", dataset = "hsapiens_gene_ensembl")
mouse = useMart("ensembl", dataset = "mmusculus_gene_ensembl")

diffExpress.excel_data <- read_excel("diffExpressionRegion.xlsx", sheet="DE genes")
diffMethy.excel_data <- read_excel("diffMethylatedRegion.xlsx", sheet="1184FilteredDMRs_withHOMERgenes")

diffExp_genes <- diffExpress.excel_data %>%
  select(Geneid) %>%
  pull()

diffMethyl_genes <- diffMethy.excel_data %>%
  select(`Gene symbol`) %>%
  drop_na() %>%
  pull()

mouseGene <- c(diffExp_genes, diffMethyl_genes) %>%
  unique()

Duplicated_genes <- data.frame(table(c(diffExp_genes, diffMethyl_genes))) %>%
  filter(Freq > 1)


mouseToHuman <- mouseGene %>%
  getLDS(attributes = c("mgi_symbol"), filters = "mgi_symbol", values = . , mart = mouse, attributesL = c("hgnc_symbol"), martL = human, uniqueRows=T) %>%
  as_tibble() 

BED_file <- mouseToHuman %>%
  select(HGNC.symbol) %>%
  drop_na(HGNC.symbol) %>%
  pull() %>%
  getBM(mart = human, attributes = c("hgnc_symbol", "chromosome_name", "start_position", "end_position"), 
        filters = "hgnc_symbol", value = .) %>%
  filter(!is.na(as.numeric(chromosome_name)) | chromosome_name %in% c("X", "Y"))

BED_file.FINAL <- BED_file %>%
  mutate(chrom = str_c("chr",chromosome_name )) %>%
  rename("chromStart" = start_position, 
         "chromEnd" = end_position) %>%
  select(chrom, chromStart, chromEnd) %>%
  mutate(chromStart = chromStart - 1000, 
         chromEnd = chromEnd + 1000)

write_delim(BED_file.FINAL, "maternalInflamationGenes.bed", delim = "\t", col_names = FALSE)
