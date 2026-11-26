library(DESeq2) ###### Ajouter la version 1.16
library(rtracklayer)

genome_annot <- import("results/ref_genome/genome.gff")
genes <- genome_annot[genome_annot$type=="gene"]

count_files <- list.files("results/featurecount/", full.names = T)

# 1. Lecture des comptages featureCounts
countMatrix <- do.call(cbind, lapply(count_files, function(f) {
  df <- read.table(f, header = TRUE, row.names = 1, stringsAsFactors = FALSE)
  df[, ncol(df), drop = FALSE]
}))
colnames(countMatrix) <- sub("replicate", "R", sub("\\..*", "", colnames(countMatrix)))

# 2. Conditions : ordre des colonnes de counts.txt
condition <- factor(c("control", "control", "control",
                      "persister", "persister", "persister"),
                    levels = c("control", "persister"))

coldata <- data.frame(condition, row.names = colnames(countMatrix))

# 3. DESeq2 (paramètres par défaut) : persister vs control
dds <- DESeqDataSetFromMatrix(countMatrix, coldata, design = ~ condition)
dds <- DESeq(dds)
res <- as.data.frame(results(dds))
res$significant <- !is.na(res$padj) & res$padj < 0.05

write.table(res, file.path(outdir, "results.tsv"), sep = "\t", quote = FALSE)
cat("DEG (padj < 0.05) :", sum(res$significant),
    "(up :", sum(res$significant & res$log2FoldChange > 0),
    ", down :", sum(res$significant & res$log2FoldChange < 0), ")\n")

# 4. MA-plot
ma_plot <- function(df, title) {
  plot(log2(df$baseMean), df$log2FoldChange,
       col = ifelse(df$significant, "red", "grey"), pch = 16,
       xlab = "Log2 base mean", ylab = "Log2 Fold Change", main = title)
  abline(h = 0, lty = 3)
  legend("topright", c("Significant", "Non-significant"),
         col = c("red", "grey"), pch = 16, bty = "n")
}

# Fig. 3c : gènes de traduction
#ids <- readLines(genes)
#png(file.path(outdir, "MAplot_translation.png"), width = 1800, height = 1400, res = 250)
#ma_plot(res[rownames(res) %in% ids, ], "Translation-related genes")
#dev.off()

# Supp. Fig. 3 : tous les gènes
png(file.path(outdir, "MAplot_all.png"), width = 1800, height = 1400, res = 250)
ma_plot(res, "All genes")
dev.off()