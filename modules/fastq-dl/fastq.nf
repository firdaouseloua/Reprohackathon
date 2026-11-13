process FASTQ {

    container 'ottarein/fastq-dl'
    maxForks 3

    publishDir "${params.outdir}/fastqdl", mode: 'copy'

    input:
    val metadata

    output:
    tuple val(metadata), path("*.{fq,fastq}{,.gz}"), emit : fastq

    script:
    def accession = metadata.run_accession
    def name = metadata.new_name
    def is_paired = metadata.library_layout == "PAIRED" ? true : false
    
    """
    fastq-dl --accession ${accession}

    if [ "${is_paired}" == "false" ]; then
        mv *.fastq.gz ${name}.fastq.gz
    else
        mv *_1*.fastq.gz ${name}_1.fastq.gz 2>/dev/null || mv *_R1*.fastq.gz ${name}_1.fastq.gz
        mv *_2*.fastq.gz ${name}_2.fastq.gz 2>/dev/null || mv *_R2*.fastq.gz ${name}_2.fastq.gz
    fi
    """
}