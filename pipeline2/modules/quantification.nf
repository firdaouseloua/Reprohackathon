process quantification {

    container 'quay.io/biocontainers/salmon:1.2.0--hf69c8f4_0'
    cpus { Math.min(8, params.cpu as int) }
    publishDir "${params.outdir}/quantification", mode: 'copy'

    input:
    tuple val(sample), path(reads)
    path salmon_index
    
    output:
    tuple val(sample), path("${sample}_quant"), emit: quant_file

    script:

    """
    set -euo pipefail
    salmon quant -i ${salmon_index} -l A -1 ${reads[0]} -2 ${reads[1]} -p ${task.cpus} -o ${sample}_quant
    test -s ${sample}_quant/quant.sf

    """
}


