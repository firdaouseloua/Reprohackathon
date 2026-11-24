process FASTQ {

    container 'ottarein/fastq-dl'
    maxForks 3

    publishDir "${params.outdir}/fastqdl", mode: 'copy'

    input:
    val metadata

    output:
    tuple val(metadata), path("${metadata.new_name}*.{fq,fastq}{,.gz}"), emit: fastq

    script:
    def accession = metadata.run_accession
    def name = metadata.new_name
    def is_paired = metadata.library_layout == "PAIRED"
    
    """
    fastq-dl --accession ${accession} --protocol HTTPS

    if [ "${is_paired}" == "false" ]; then
        [ -f "${accession}.fastq.gz" ] && [ "${accession}" != "${name}" ] && mv "${accession}.fastq.gz" "${name}.fastq.gz"
    else
        if [ -f "${accession}_1.fastq.gz" ] && [ "${accession}" != "${name}" ]; then
            mv "${accession}_1.fastq.gz" "${name}_1.fastq.gz"
            mv "${accession}_2.fastq.gz" "${name}_2.fastq.gz"
        elif [ -f "${accession}_R1.fastq.gz" ]; then
            mv "${accession}_R1.fastq.gz" "${name}_1.fastq.gz"
            mv "${accession}_R2.fastq.gz" "${name}_2.fastq.gz"
        fi
    fi
    """
}