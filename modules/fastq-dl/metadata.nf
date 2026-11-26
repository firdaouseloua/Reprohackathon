process METADATA {

    container 'ottarein/fastq-dl'

    publishDir "${params.outdir}/metadata", mode: 'copy'

    output:
    path("*.tsv"), emit : metadata

    script:

    """
    fastq-dl --accession ${params.study_accession} --only-download-metadata 
    """
}