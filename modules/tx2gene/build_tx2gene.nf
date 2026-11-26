process BUILD_TX2GENE {

    tag "Validate mouse reference annotations"
    container 'python:3.12'
    cpus 1
    publishDir "${params.outdir}/reference_files", mode: 'copy'

    input:
    path annotation
    path transcriptome

    output:
    path "tx2gene.tsv", emit: mapping
    path "reference_validation.txt", emit: report

    script:
    """
    # No missing transcripts allowed this time
    python3 build_tx2gene.py \\
        ${annotation} \\
        ${transcriptome} \\
        tx2gene.tsv > reference_validation.txt

    cat reference_validation.txt
    test -s tx2gene.tsv
    """
}
