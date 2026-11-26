library(DESeq2) ###### Ajouter la version 1.16
library(rtracklayer)
library(rjson)

genome_annot <- import("reference_files/aureus.gff")
genes <- genome_annot[genome_annot$type=="gene"]
kegg_orthology <- fromJSON(file="reference_files/kegg_orthology.json")

count_files <- list.files("featurecount", full.names = T)
count_files <- count_files[grep("*.txt$", count_files)]

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

write.table(res, file.path("results.tsv"), sep = "\t", quote = FALSE)
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
ma_plot(res, "MA-plot")

# 5. Fonction pour trouver un noeud
find_node <- function(node, prefix) {
  if (startsWith(node$name, prefix)) {
    return(node)
  }
  for (child in node$children) {
    result <- find_node(child, prefix)
    if (!is.null(result)) {
      return(result)
    }
  }
  return(NULL)
}

# 6. Fonction de collection des feuilles d'un noeud
collect_leaves <- function(node) {
  if (is.null(node$children)){
    return(node$name)
  }
  unlist(lapply(node$children, collect_leaves))
}

genes_translation <- find_node(kegg_orthology, "09122")
genes_translation_leaves <- collect_leaves(genes_translation)

rownames(res) <- sub("^gene-", "", rownames(res))
translation_genes <- res[genes_translation_leaves,]

# Fig. 3c : gènes de traduction
png(file.path("MAplot_translation.png"), width = 1800, height = 1400, res = 250)
ma_plot(translation_genes, "Translation-related genes")
dev.off()

# Supp. Fig. 3 : tous les gènes
png(file.path("MAplot_all.png"), width = 1800, height = 1400, res = 250)
ma_plot(res, "All genes")
dev.off()
