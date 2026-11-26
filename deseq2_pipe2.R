library(DESeq2) ###### Ajouter la version 1.16
library(tximport)
library(VennDiagram)

outdir <- "results/"
dir.create(outdir, showWarnings = FALSE)

# 1. Echantillons
samples <- read.delim("samples.tsv")
files <- file.path("quant", samples$sample, "quant.sf")
names(files) <- samples$sample
txi <- tximport(files, type = "salmon", txOut = TRUE)

group <- factor(paste(samples$infection, samples$day, sep = "_"),
                levels = c("WT_d11", "In_d11", "WT_d33", "In_d33"))
coldata <- data.frame(group, row.names = samples$sample)

# 2. DESeq2
dds <- DESeqDataSetFromTximport(txi, coldata, design = ~ group)
dds <- DESeq(dds)

# DETs
deg <- function(infected, control) {
  r <- as.data.frame(results(dds, contrast = c("group", infected, control)))
  r$transcript <- rownames(r)
  r[!is.na(r$pvalue) & r$pvalue < 0.05 & abs(r$log2FoldChange) >= 1.5, ]
}

## article : pval < 0.05 et |log2FC| >= 1.5


d11 <- deg("In_d11", "WT_d11")
d33 <- deg("In_d33", "WT_d33")
write.table(d11, file.path(outdir, "DET_d11.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(d33, file.path(outdir, "DET_d33.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

# 3. Venn (Fig. 2B)
sets <- list(Acute_upregulated     = d11$transcript[d11$log2FoldChange > 0],
             Acute_downregulated   = d11$transcript[d11$log2FoldChange < 0],
             Chronic_upregulated   = d33$transcript[d33$log2FoldChange > 0],
             Chronic_downregulated = d33$transcript[d33$log2FoldChange < 0])
print(sapply(sets, length))

### valeurs à checker, comparer avec les valeurs de l'article : 789, 147, 1908, 173
### avoir similaire évidemment, pas besoin de exact


futile.logger::flog.threshold(futile.logger::ERROR, name = "VennDiagramLogger")
venn.diagram(sets, filename = file.path(outdir, "Venn_Fig2B.png"),
             col = c("000000", "000000", "000000", "000000"),
             fill = c("b3e2ff", "f4ffb1", "ffb2b2", "b1ffc5"),
             alpha = 0.5, height = 2000, width = 2400, resolution = 300)