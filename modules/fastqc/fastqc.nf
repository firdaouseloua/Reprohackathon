process FASTQC {

    container 'ottarein/fastqc:0.12.1'
    publishDir "${params.outdir}/fastqc", mode: 'copy'

    input:
    tuple val(metadata), path(fastq)

    output:
    tuple val(metadata), path("*.html"), emit : rapport
    tuple val(metadata), path("*.zip"), emit : zip
    

    script:
    """
    fastqc ${fastq}  
    """
}