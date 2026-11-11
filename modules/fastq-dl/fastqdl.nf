process FASTQDL {

    container 'ottarein/fastq-dl'
    publishDir "${params.outdir}/fastqdl", mode: 'copy'


    output:
    path("*.{fq,fastq}{,.gz}"), emit : fastq
    path("*"), emit : metadata

    script:

    """
    fastq-dl --accession GSE139659
    """
}