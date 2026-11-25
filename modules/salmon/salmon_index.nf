process SALMON_INDEX {

    tag "Mouse transcriptome indexing"

    container 'quay.io/biocontainers/salmon:1.2.0--hf69c8f4_0'

    cpus 4

    publishDir "${params.outdir}/index", mode: 'copy'

    input:
    path transcriptome

    output:
    path "salmon_index", emit: index

    script:
    """
    salmon index \
        -t ${transcriptome} \
        -i salmon_index \
        -p ${task.cpus}
    """
}
