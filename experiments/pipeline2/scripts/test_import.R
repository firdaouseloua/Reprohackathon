library(tximport)
library(DESeq2)

# Tiny fake Salmon output, because real data is still missing
q <- data.frame(
    Name = c("TX001", "TX002", "TX003"),
    Length = c(1000, 1500, 2000),
    EffectiveLength = c(800, 1300, 1800),
    TPM = c(400000, 350000, 250000),
    NumReads = c(100, 150, 200)
)

f <- tempfile(fileext = ".sf")

write.table(q, f, sep = "\t",
            quote = FALSE, row.names = FALSE)

files <- c(sample1 = f)

txi <- tximport(
    files,
    type = "salmon",
    txOut = TRUE,
    importer = read.delim
)

print(txi$counts)

stopifnot(
    nrow(txi$counts) == 3,
    all(txi$counts[, 1] == q$NumReads)
)

coldata <- data.frame(
    group = factor("control"),
    row.names = "sample1"
)

dds <- DESeqDataSetFromTximport(
    txi, coldata, design = ~ 1
)

cat("PASS: Transcript-level import\n")
cat("PASS: Count preservation\n")
cat("PASS: DESeq2 dataset construction\n")
