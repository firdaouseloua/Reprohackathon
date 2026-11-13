include { FASTQ } from './modules/fastq-dl/fastq'
include { METADATA } from './modules/fastq-dl/metadata'
include { CUTADAPT } from './modules/cutadapt/cutadapt'
include { DOWNLOAD_GENOME_ANN } from './modules/download_genome_ann'
include { BOWTIE_INDEX } from './modules/bowtie/bowtie_index'
include { BOWTIE_ALIGN } from './modules/bowtie/bowtie_align'
include { FEATURECOUNT } from './modules/subread/featureCount'
include { SAM_TO_BAM } from './modules/samtools/sam_to_bam'

workflow {

    DOWNLOAD_GENOME_ANN()
    BOWTIE_INDEX(DOWNLOAD_GENOME_ANN.out.genome)
    METADATA()

    metadata = METADATA.out.metadata
        .splitCsv(header: true, sep: '\t', strip: true)
        .map { row -> row + [new_name: row.sample_description.replace(' ', '_')] }
        .first()

    FASTQ(metadata)
    CUTADAPT(FASTQ.out.fastq)
    FASTQ.out.fastq.view()
    // BOWTIE_ALIGN(BOWTIE_INDEX.out.index_dir, CUTADAPT.out.trimmed_reads)
    // SAM_TO_BAM(BOWTIE_ALIGN.out.sam)
    // FEATURECOUNT(DOWNLOAD_GENOME_ANN.out.annotation, SAM_TO_BAM.out.bam)

}