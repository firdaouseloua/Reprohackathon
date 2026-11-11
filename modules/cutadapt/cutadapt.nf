process FASTQDL {

    container 'ottarein/cutadapt'
    publishDir "${params.outdir}/fastqdl", mode: 'copy'

    input:
    tuple val(meta), path(fastq)

    output:
    tuple val(meta), path("*trimmed.{fq,fastq}{,.gz}"), emit : trimmed_fastq
    

    script:
    def sample = meta.name
    """
    cutadapt -q 20 -m 25 -o ${sample}.trimmed.fastq.gz ${fastq}
    """
}