include { DOWNLOAD_TRANSCRIPTOME } from './modules/download_transcriptome'
include { DOWNLOAD_MOUSE_ANNOTATION } from './modules/download_mouse_annotation'
include { SALMON_INDEX } from './modules/salmon/salmon_index'
include { quantification } from './modules/salmon/quantification'
include { FASTQ } from './modules/fastq-dl/fastq'
include { FASTQC } from './modules/fastqc/fastqc'
include { METADATA } from './modules/fastq-dl/metadata'
include { CUTADAPT } from './modules/cutadapt/cutadapt'
include { DOWNLOAD_GENOME_ANN } from './modules/download_genome_ann'
include { BOWTIE_INDEX } from './modules/bowtie/bowtie_index'
include { BOWTIE_ALIGN_BAM } from './modules/bowtie/bowtie_align_bam'
include { FEATURECOUNT } from './modules/subread/featureCount'

workflow {

    def meta_column = params.meta_column ?: (
        params.study_accession == 'PRJNA483261'
            ? 'library_name'
            : 'sample_description'
    )

    METADATA()

    metadata = METADATA.out.metadata
        .splitCsv(header: true, sep: '\t', strip: true)
        .map { row ->
            row + [new_name: row[meta_column].replace(' ', '_')]
        }

    // Small test runs before downloading the whole study
    def sample_limit = params.max_samples.toString().toInteger()

    if (sample_limit > 0) {
        metadata = metadata.take(sample_limit)
    }

    if (params.study_accession == 'PRJNA586837') {

        DOWNLOAD_GENOME_ANN()

        // One reference index for all samples
        BOWTIE_INDEX(DOWNLOAD_GENOME_ANN.out.genome)

        FASTQ(metadata)
        FASTQC(FASTQ.out.fastq)
        CUTADAPT(FASTQ.out.fastq)

        // Avoid huge intermediate SAM files
        BOWTIE_ALIGN_BAM(
            BOWTIE_INDEX.out.index_dir.first(),
            CUTADAPT.out.trimmed_reads
        )

        FEATURECOUNT(
            DOWNLOAD_GENOME_ANN.out.annotation.first(),
            BOWTIE_ALIGN_BAM.out.bam
        )

    } else if (params.study_accession == 'PRJNA483261') {

        FASTQ(metadata)
        FASTQC(FASTQ.out.fastq)

        // Same Ensembl release for both reference files
        DOWNLOAD_TRANSCRIPTOME(
            Channel.value(params.transcriptome_url)
        )

        DOWNLOAD_MOUSE_ANNOTATION(
            Channel.value(params.annotation_url)
        )

        // Build the index once for all samples
        SALMON_INDEX(
            DOWNLOAD_TRANSCRIPTOME.out.transcriptome
        )

    } else {
        error "Unknown study accession: ${params.study_accession}"
    }
}
