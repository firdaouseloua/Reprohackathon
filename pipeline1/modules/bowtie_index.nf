process BOWTIE_INDEX {

    tag "CP000253.1"

    publishDir "${params.outdir}/index", mode: 'copy'

    input:
    path genome

    output:
    path "index"

    script:
    """
    mkdir -p index

    bowtie-build ${genome} index/genome
    """
}
