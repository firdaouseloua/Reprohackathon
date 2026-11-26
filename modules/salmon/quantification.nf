process QUANTIFICATION {

    tag "${metadata.new_name}"
    container 'quay.io/biocontainers/salmon:1.2.0--hf69c8f4_0'
    cpus { Math.min(8, (params.cpus ?: 1) as int) }
    publishDir "${params.outdir}/quantification", mode: 'copy'

    input:
    tuple val(metadata), path(reads)
    path salmon_index

    output:
    tuple val(metadata), path("${metadata.new_name}_quant.sf"), emit: quant_file

    script:
    def new_name = metadata.new_name
    """
    salmon quant \\
        -i ${salmon_index} \\
        -l A \\
        -1 ${reads[0]} \\
        -2 ${reads[1]} \\
        -p ${task.cpus} \\
        --gcBias \\
        --seqBias \\
        --numBootstraps 30 \\
        -o ${new_name}_quant

    test -s ${new_name}_quant/quant.sf
    mv ${new_name}_quant/quant.sf ${new_name}_quant.sf
    """
}