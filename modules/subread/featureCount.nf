process FEATURECOUNT {

    cpus 8
    container 'ottarein/featurecounts:1.4.6-p3'

    input:
    path gff
    tuple val(metadata), path(bam)

    output:
    tuple val(metadata), path("*.txt"), emit: count_file

    script:
    def name = metadata.new_name

    """
    featureCounts -t exon -g ID -s 1 -F GTF -T ${task.cpus} -a ${gff} -o ${name}_count.txt $bam
    """
}
