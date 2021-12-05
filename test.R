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

saveRDS(homolog, "mouse_human_joint_data.RDS")

getBM(mart = human, attributes = c("hgnc_symbol", "chromosome_name", "start_position", "end_position", "strand"), 
      filters = "hgnc_symbol", value = "ALK")

