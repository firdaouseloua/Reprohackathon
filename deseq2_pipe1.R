library(DESeq2) ###### Ajouter la version 1.16

counts_file <- "counts.txt"
#genes <- ## à lire avec genome.gff
outdir <- "results/"
dir.create(outdir)

# 1. Lecture des comptages featureCounts
fc <- read.delim(counts_file, comment.char = "#", check.names = FALSE)
counts <- as.matrix(fc[, grep("\\.bam$", colnames(fc))])
rownames(counts) <- fc$Geneid

# 2. Conditions : ordre des colonnes de counts.txt
condition <- factor(c("control", "control", "control",
                      "persister", "persister", "persister"),
                    levels = c("control", "persister"))
coldata <- data.frame(condition, row.names = colnames(counts))

# 3. DESeq2 (paramètres par défaut) : persister vs control
dds <- DESeqDataSetFromMatrix(counts, coldata, design = ~ condition)
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