include { BUILD_TX2GENE } from './modules/tx2gene/build_tx2gene'
include { DOWNLOAD_TRANSCRIPTOME } from './modules/download_transcriptome'
include { DOWNLOAD_MOUSE_ANNOTATION } from './modules/download_mouse_annotation'
include { SALMON_INDEX } from './modules/salmon/salmon_index'
include { QUANTIFICATION } from './modules/salmon/quantification'
include { FASTQ } from './modules/fastq-dl/fastq'
include { FASTQC } from './modules/fastqc/fastqc'
include { FASTQC as FASTQC_TRIMMED} from './modules/fastqc/fastqc'
include { METADATA } from './modules/fastq-dl/metadata'
include { CUTADAPT } from './modules/cutadapt/cutadapt'
include { TRIMMOMATIC } from './modules/trimmomatic/trimmomatic'
include { REF_GENOME_AUREUS } from './modules/ref_genome_aureus'
include { BOWTIE_INDEX } from './modules/bowtie/bowtie_index'
include { BOWTIE_ALIGN } from './modules/bowtie/bowtie_align'
include { FEATURECOUNT } from './modules/subread/featureCount'

workflow {

    def meta_column = params.study_accession == 'PRJNA483261'? 'library_name': 'sample_description'

    METADATA()

    metadata = METADATA.out.metadata
        .splitCsv(header: true, sep: '\t', strip: true)
        .map { row ->
            row + [new_name: row[meta_column].replace(' ', '_')]
        }

    if (params.study_accession == 'PRJNA586837') {

        REF_GENOME_AUREUS()

        // One reference index for all samples
        BOWTIE_INDEX(REF_GENOME_AUREUS.out.genome)

        FASTQ(metadata)
        FASTQC(FASTQ.out.fastq)
        CUTADAPT(FASTQ.out.fastq)

        // Avoid huge intermediate SAM files
        BOWTIE_ALIGN(BOWTIE_INDEX.out.index_dir, 
                     CUTADAPT.out.trimmed_reads)

        FEATURECOUNT(REF_GENOME_AUREUS.out.annotation,
                     BOWTIE_ALIGN.out.bam)

    } else if (params.study_accession == 'PRJNA483261') {

        FASTQ(metadata)
        FASTQC(FASTQ.out.fastq)

        TRIMMOMATIC(FASTQ.out.fastq)
        FASTQC_TRIMMED(TRIMMOMATIC.out.trimmed_reads)
        // Same Ensembl release for both reference files
        DOWNLOAD_TRANSCRIPTOME()
        DOWNLOAD_MOUSE_ANNOTATION()

        // Build the index once for all samples
        SALMON_INDEX(DOWNLOAD_TRANSCRIPTOME.out.transcriptome)

         // Validate the reference and prepare the gene mapping
        BUILD_TX2GENE(DOWNLOAD_MOUSE_ANNOTATION.out.annotation,
                      DOWNLOAD_TRANSCRIPTOME.out.transcriptome,
                      file("${projectDir}/modules/tx2gene/build_tx2gene.py"))

        QUANTIFICATION(TRIMMOMATIC.out.trimmed_reads, SALMON_INDEX.out.index)

    } else {
        error "Unknown study accession: ${params.study_accession}"
    }
}
