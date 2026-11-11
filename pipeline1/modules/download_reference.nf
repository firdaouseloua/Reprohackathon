process DOWNLOAD_REFERENCE {

    tag "CP000253.1"

    publishDir "${params.outdir}/reference", mode: 'copy'

    output:
    path "genome.fasta"

    script:
    """
    curl -fL --retry 3 \
      https://www.ebi.ac.uk/ena/browser/api/fasta/CP000253.1 \
      -o genome.fasta

    test -s genome.fasta
    """
}
