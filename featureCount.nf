process featureCount {

    container https://zenodo.org/record/8037099/files/subread_2.0.3.img

    input:
    path gtf
    tuple (path bam, path metadata)
    
    output:
    tuple (path "*.txt", path metadata), emit: count_file

    script:
    def sample = metadata.sample_name

    """
    featureCounts -t exon -g ID -s 1 -F GTF -T $task.cpus -a ${gtf} -o ${sample}_count.txt $bam
    """
}
