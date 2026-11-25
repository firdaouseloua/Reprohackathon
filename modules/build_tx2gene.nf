process BUILD_TX2GENE {

    tag "Validate mouse reference annotations"

    container 'python:3.12'

    cpus 1
    memory '2 GB'

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
    path annotation
    path transcriptome
    path validation_script

    output:
    path "tx2gene.tsv", emit: mapping
    path "reference_validation.txt", emit: report

    script:
    """
    set -euo pipefail

    # No missing transcripts allowed this time
    python3 ${validation_script} \
        ${annotation} \
        ${transcriptome} \
        tx2gene.tsv > reference_validation.txt

    cat reference_validation.txt
    test -s tx2gene.tsv
    """
}
