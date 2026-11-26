process BUILD_TX2GENE {

    tag "Validate mouse reference annotations"
    container 'quay.io/biocontainers/python:3.12.12'
    cpus 1
    publishDir "${params.outdir}/reference_files", mode: 'copy'

    input:
    path annotation
    path transcriptome
    path tx2gene_script

    output:
    path "tx2gene.tsv", emit: mapping
    path "reference_validation.txt", emit: report

    script:
    """
    # No missing transcripts allowed this time
    python3 ${tx2gene_script} \\
        ${annotation} \\
        ${transcriptome} \\
        tx2gene.tsv > reference_validation.txt

    cat reference_validation.txt
    test -s tx2gene.tsv
    """
}
