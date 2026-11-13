process BOWTIE_ALIGN {

    cpus 8
    container 'ottarein/bowtie:0.12.7'
    publishDir "${params.outdir}/bw_mapping", mode: 'copy'

    input:
    path index_dir
    tuple val(metadata), path(trimmed_reads)

    output:
    tuple val(metadata), path("*.sam"), emit: sam
    tuple val(metadata), path ("*.bowtie.log"), emit: log

    script:
    def name = metadata.new_name
    """
    zcat ${trimmed_reads} | bowtie -p ${task.cpus} \\
                        -S \\
                        ${index_dir}/genome \\
                        ${trimmed_reads} \\
                        > ${name}.sam \\
                        2> ${name}.bowtie.log
    """
}
