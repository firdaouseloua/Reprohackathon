process SAM_TO_BAM {
    cpus 4
    container 'ottarein/samtools:1.21'

    input:
    tuple val(metadata), path(sam)

    output:
    tuple val(metadata), path("*.bam"), emit: bam

    script:
    def name = metadata.new_name

    """
    samtools sort -@ ${task.cpus} -o ${name}.bam ${sam}
    """
}
