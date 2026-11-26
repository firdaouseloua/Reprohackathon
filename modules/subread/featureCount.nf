process FEATURECOUNT {

    cpus { Math.min(8, params.cpus as int) }
    container 'ottarein/featurecounts:1.4.6-p3'
    publishDir "${params.outdir}/featurecount", mode: 'copy'

    input:
    path gff
    tuple val(metadata), path(bam)

    output:
    tuple val(metadata), path("*.txt"), emit: count_file

    script:
    def name = metadata.new_name

    """
    featureCounts -t gene -g ID -s 2 -F GTF -T ${task.cpus} -a ${gff} -o ${name}_count.txt $bam
    """
}
