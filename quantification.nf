process quantification {

    container 'https://zenodo.org/record/22118211/files/salmon_1.3.0-1.img'
    cpus 16

    input:
    tuple val(sample), path(reads)
    path salmon_index
    
    output:
    tuple val(sample), path("${sample}_quant"), emit: quant_file

    script:

    """
    salmon quant -i ${salmon_index} -l A -1 ${reads[0]} -2 ${reads[1]} -p ${task.cpus} -o ${sample}_quant
    """
}


