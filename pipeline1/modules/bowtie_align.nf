process BOWTIE_ALIGN {

    tag "${reads.simpleName}"

    publishDir "${params.outdir}/mapping", mode: 'copy'

    input:
    path index_dir
    path reads

    output:
    path "${reads.simpleName}.sam"
    path "${reads.simpleName}.bowtie.log"

    script:
    """
    bowtie -S \
        -x ${index_dir}/genome \
        ${reads} \
        ${reads.simpleName}.sam \
        2> ${reads.simpleName}.bowtie.log
    """
}
