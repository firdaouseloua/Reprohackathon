process BOWTIE_ALIGN_BAM {

    tag "${metadata.new_name}"

    cpus { Math.min(8, params.cpus as int) }

    container 'reprohack-bowtie-samtools:1.0'

    publishDir "${params.outdir}/bam", mode: 'copy'

    input:
    path index_dir
    tuple val(metadata), path(trimmed_reads)

    output:
    tuple val(metadata), path("*.bam"), emit: bam
    tuple val(metadata), path("*.bai"), emit: bam_index
    tuple val(metadata), path("*.bowtie.log"), emit: log
    tuple val(metadata), path("*.flagstat.txt"), emit: stats

    script:
    def name = metadata.new_name
    def bowtie_threads = Math.max(1, task.cpus - 2)

    """
    set -euo pipefail

    # No huge SAM file taking over the disk today
    zcat "${trimmed_reads}" | \\
        bowtie -p ${bowtie_threads} -S \\
        ${index_dir}/genome - \\
        2> "${name}.bowtie.log" | \\
        samtools sort -o "${name}.bam" -

    # Index the sorted BAM
    samtools index "${name}.bam"

    # Trust the pipeline, but check the BAM anyway
    samtools quickcheck -v "${name}.bam"

    # Mapping statistics for later comparison
    samtools flagstat "${name}.bam" > "${name}.flagstat.txt"
    """
}