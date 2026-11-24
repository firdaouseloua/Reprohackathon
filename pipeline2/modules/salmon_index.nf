process SALMON_INDEX {

    tag "Mouse transcriptome - Salmon 1.2.0"

    container 'quay.io/biocontainers/salmon:1.2.0--hf69c8f4_0'

    cpus 4
    memory '8 GB'

    publishDir "${params.outdir}/index", mode: 'copy'

    input:
    path transcriptome

    output:
    path "salmon_index", emit: index

    script:
    """
    # Keeping the paper's Salmon version
    salmon --version

    # Explicit k-mer size for reproducibility
    salmon index \
        -t ${transcriptome} \
        -i salmon_index \
        -k 31 \
        -p ${task.cpus}

    # At least make sure we actually built an index
    test -s salmon_index/versionInfo.json
    test -s salmon_index/info.json
    """
}
