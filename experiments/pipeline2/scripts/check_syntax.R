files <- list.files(
    "/analysis/scripts",
    pattern = "[.]R$",
    full.names = TRUE
)

for (f in files) {
    parse(file = f)
    cat("Syntax OK:", basename(f), "\n")
}
