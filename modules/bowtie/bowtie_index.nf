process BOWTIE_INDEX {

    container 'ottarein/bowtie:0.12.7'
    tag "CP000253.1"

    publishDir "${params.outdir}/bw_index", mode: 'copy'

    input:
    path genome

    output:
    path "index", emit: index_dir

    script:
    """
    mkdir -p index

    bowtie-build ${genome} index/genome
    """
}
