process CUTADAPT {

    container 'ottarein/cutadapt:1.11'
    publishDir "${params.outdir}/cutadapt", mode: 'copy'

    input:
    tuple val(metadata), path(fastq)

    output:
    tuple val(metadata), path("*trimmed.{fq,fastq}{,.gz}"), emit : trimmed_reads
    

    script:
    def name = metadata.new_name
    """
    cutadapt -q 20 -m 25 \\
        -o ${name}.trimmed.fastq.gz \\
        ${fastq} 
    """
}