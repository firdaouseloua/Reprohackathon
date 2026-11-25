include { FASTQ } from './modules/fastq-dl/fastq'
include { FASTQC } from './modules/fastqc/fastqc'
include { METADATA } from './modules/fastq-dl/metadata'
include { CUTADAPT } from './modules/cutadapt/cutadapt'
include { DOWNLOAD_GENOME_ANN } from './modules/download_genome_ann'
include { BOWTIE_INDEX } from './modules/bowtie/bowtie_index'
include { BOWTIE_ALIGN } from './modules/bowtie/bowtie_align'
include { FEATURECOUNT } from './modules/subread/featureCount'
include { SAM_TO_BAM } from './modules/samtools/sam_to_bam'

workflow {

    DOWNLOAD_GENOME_ANN()
    METADATA()

    metadata = METADATA.out.metadata
        .splitCsv(header: true, sep: '\t', strip: true)
    .map { row -> row + [new_name: row[params.meta_column].replace(' ', '_')] }

    if(params.study_accession=="PRJNA586837"){
        BOWTIE_INDEX(DOWNLOAD_GENOME_ANN.out.genome)
        FASTQ(metadata)
        FASTQC(FASTQ.out.fastq)
        CUTADAPT(FASTQ.out.fastq)
        BOWTIE_ALIGN(BOWTIE_INDEX.out.index_dir, CUTADAPT.out.trimmed_reads)
        SAM_TO_BAM(BOWTIE_ALIGN.out.sam)
        FEATURECOUNT(DOWNLOAD_GENOME_ANN.out.annotation, SAM_TO_BAM.out.bam)
    }
    else if(params.study_accession=="PRJNA483261"){
        FASTQ(metadata)
        FASTQC(FASTQ.out.fastq)
    }

}
