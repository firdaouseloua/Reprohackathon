process TRIMMOMATIC {

    cpus { Math.min(4, (params.cpus ?: 1) as int) }
    container 'ottarein/trimmomatic:0.39'
    publishDir "${params.outdir}/trimmomatic", mode: 'copy'

    input:
    tuple val(metadata), path(fastq)

    output:
    tuple val(metadata), path("*trimmed.{fq,fastq}{,.gz}"), emit : trimmed_reads
    tuple val(metadata), path("*trimmed.unpaired.{fq,fastq}{,.gz}"), emit : unpaired_reads

    script:
    def name = metadata.new_name
    """
    trimmomatic PE -threads 4 \\
    ${fastq} \\
    ${name}_R1_paired.trimmed.fastq.gz ${name}_R1_trimmed.unpaired.fastq.gz \\
    ${name}_R2_paired.trimmed.fastq.gz ${name}_R2_trimmed.unpaired.fastq.gz \\
    HEADCROP:14 \
    AVGQUAL:30
    """
}