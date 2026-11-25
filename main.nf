include { FASTQ } from './modules/fastq-dl/fastq'
include { FASTQC } from './modules/fastqc/fastqc'
include { FASTQC as FASTQC_TRIMMED} from './modules/fastqc/fastqc'
include { METADATA } from './modules/fastq-dl/metadata'
include { CUTADAPT } from './modules/cutadapt/cutadapt'
include { TRIMMOMATIC } from './modules/trimmomatic/trimmomatic'
include { REF_GENOME_AUREUS } from './modules/download_genome_ann'
include { BOWTIE_INDEX } from './modules/bowtie/bowtie_index'
include { BOWTIE_ALIGN } from './modules/bowtie/bowtie_align'
include { FEATURECOUNT } from './modules/subread/featureCount'
include { SAM_TO_BAM } from './modules/samtools/sam_to_bam'

workflow {

    METADATA()

    metadata = METADATA.out.metadata
    .splitCsv(header: true, sep: '\t', strip: true)
    .map { row -> row + [new_name: row[params.meta_column].replace(' ', '_')] }

    if(params.study_accession=="PRJNA586837"){
        REF_GENOME_AUREUS()
        BOWTIE_INDEX(REF_GENOME_AUREUS.out.genome)
        FASTQ(metadata)
        FASTQC(FASTQ.out.fastq)
        CUTADAPT(FASTQ.out.fastq)
        BOWTIE_ALIGN(BOWTIE_INDEX.out.index_dir, CUTADAPT.out.trimmed_reads)
        SAM_TO_BAM(BOWTIE_ALIGN.out.sam)
        FEATURECOUNT(REF_GENOME_AUREUS.out.annotation, SAM_TO_BAM.out.bam)
    }
    else if(params.study_accession=="PRJNA483261"){
        FASTQ(metadata)
        FASTQC(FASTQ.out.fastq)
        TRIMMOMATIC(FASTQ.out.fastq)
        FASTQC_TRIMMED(TRIMMOMATIC.out.trimmed_reads)
    }

}
