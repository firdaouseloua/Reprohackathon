process SALMON_INDEX {

    tag "Mouse transcriptome - Salmon 1.2.0"
    container 'quay.io/biocontainers/salmon:1.2.0--hf69c8f4_0'
    cpus { Math.min(4, params.cpus as int) }
    publishDir "${params.outdir}/index", mode: 'copy'

    input:
    path gentrome
    path decoy

    output:
    path "salmon_index", emit: index

    script:
    """
    
    # Explicit k-mer size for reproducibility
    salmon index \\
        -t ${gentrome} \\
        -i salmon_index \\
        -d decoy.txt \\
        --gencode \\
        -k 31 \\
        -p ${task.cpus}

    # At least make sure we actually built an index
    test -s salmon_index/versionInfo.json
    test -s salmon_index/info.json
    """
}
