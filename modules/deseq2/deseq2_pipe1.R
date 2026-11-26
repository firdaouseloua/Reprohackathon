library(DESeq2) ###### Ajouter la version 1.16
library(rtracklayer)
library(rjson)
library(ggplot2)

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
genes_translation_leaves <- sub(" .*", "", genes_translation_leaves)
genes_translation_leaves[!grepl("^SAOUHSC_", genes_translation_leaves)] <- paste0("SAOUHSC_", genes_translation_leaves[!grepl("^SAOUHSC_", genes_translation_leaves)])
rownames(res) <- sub("^gene-", "", rownames(res))
translation_genes <- res[genes_translation_leaves,]
translation_genes <- translation_genes[!is.na(translation_genes$log2FoldChange), ]

plot1 <- translation_genes[,c("baseMean","log2FoldChange","significant")]
df <- as.data.frame(plot1)

p <- ggplot(df, aes(x = log2(baseMean + 1), y = log2FoldChange, color = significant)) +
  geom_point(alpha = 0.75, size = 1.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black", size = 1) +
  coord_cartesian(xlim = c(0, 20), ylim = c(-6, 5)) +
  scale_color_manual(
    values = c("FALSE" = "black", "TRUE" = "red"),
    name = "padj < 0.05") +
  labs(
    title = "Translation-related genes",
    x = expression(log[2](baseMean)),
    y = expression(log[2]~fold~change)) +
  theme_classic(base_size = 14)

ggsave(
  filename = "MAplot_translation.png",
  plot = p,
  width = 8,
  height = 4,
  dpi = 300
)
# Fig. 3c : gènes de traduction
png(file.path("MAplot_translation.png"), width = 1800, height = 1200, res = 300)
plotMA(plot1, main = "Translation-related genes", ylim = c(-6, 5), xlim = c(0.1, 20))
dev.off()

# Supp. Fig. 3 : tous les gènes
png(file.path("MAplot_all.png"), width = 1800, height = 1400, res = 250)
plotMA(res, main = "All genes", ylim = c(-4, 4))
dev.off()
