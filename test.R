library(biomaRt)
library(tidyverse)
library(readxl)

human = useMart("ensembl", dataset = "hsapiens_gene_ensembl")
mouse = useMart("ensembl", dataset = "mmusculus_gene_ensembl")

excel_data <- read_excel("diffExpressionRegion.xlsx", sheet="DE genes")

mouseToHuman <- excel_data %>%
  select(Geneid) %>%
  pull() %>%
  getLDS(attributes = c("mgi_symbol"), filters = "mgi_symbol", values = . , mart = mouse, attributesL = c("hgnc_symbol"), martL = human, uniqueRows=T)

mouseToHuman <- as_tibble(mouseToHuman)

homolog <- full_join(excel_data, mouseToHuman, by = c("Geneid" = "MGI.symbol"))

homolog %>% 
  select(Geneid, HGNC.symbol, `logFC MAA-PBS`)

homolog <- readRDS("mouse_human_joint_data.RDS")

BED_file <- homolog %>%
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
  select(chrom, chromStart, chromEnd)

write_delim(BED_file.FINAL, "diffExpressionRegion.bed", delim = "\t", col_names = FALSE)
