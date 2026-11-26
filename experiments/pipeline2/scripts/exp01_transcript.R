library(DESeq2) ###### Ajouter la version 1.16
library(tximport)
library(VennDiagram)
library(readr)

files <- list.files("quantification", pattern = "_quant\\.sf$", full.names = TRUE)
names(files) <- substr(basename(files), 1, regexpr("_post", basename(files)) - 1)

txi <- tximport(files, type = "salmon", txOut = TRUE)

samples <- data.frame(
  sample    = names(files),
  infection = ifelse(grepl("^control", names(files)), "WT", "In"),
  day       = ifelse(grepl("11_day$", names(files)), "d11", "d33"),
  stringsAsFactors = FALSE
)

group <- factor(paste(samples$infection, samples$day, sep = "_"),
                levels = c("WT_d11", "In_d11", "WT_d33", "In_d33"))
coldata <- data.frame(group, row.names = samples$sample)
stopifnot(identical(rownames(coldata), colnames(txi$counts)))

dds <- DESeqDataSetFromTximport(txi, coldata, design = ~ group)
dds <- DESeq(dds)

res_d11 <- results(dds, contrast = c("group", "In_d11", "WT_d11"))
res_d33 <- results(dds, contrast = c("group", "In_d33", "WT_d33"))


# DETs
deg <- function(infected, control) {
  r <- as.data.frame(results(dds, contrast = c("group", infected, control)))
  r$transcript <- rownames(r)
  r[!is.na(r$pvalue) & r$pvalue < 0.05 & abs(r$log2FoldChange) >= 1.5, ]
}

## article : pval < 0.05 et |log2FC| >= 1.5


d11 <- deg("In_d11", "WT_d11")
d33 <- deg("In_d33", "WT_d33")
write.table(d11, file.path("DET_d11.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(d33, file.path("DET_d33.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

# 3. Venn (Fig. 2B)
sets <- list(
  Acute_upregulated     = d11$transcript[d11$log2FoldChange > 0], 
  Chronic_downregulated = d33$transcript[d33$log2FoldChange < 0], 
  Acute_downregulated   = d11$transcript[d11$log2FoldChange < 0], 
  Chronic_upregulated   = d33$transcript[d33$log2FoldChange > 0])
print(sapply(sets, length))

### valeurs à checker, comparer avec les valeurs de l'article : 789, 147, 1908, 173
### avoir similaire évidemment, pas besoin de exact


futile.logger::flog.threshold(futile.logger::ERROR, name = "VennDiagramLogger")

venn.diagram(
  x = sets,
  filename = "Venn_Fig2B.png",
  imagetype = "png",
  col = rep("#000000", 4),
  fill = c("#b3e2ff", "#b1ffc5", "#f4ffb1", "#ffb2b2"),
  alpha = 0.5,
  height = 2000,
  width = 2400,
  resolution = 300
)

