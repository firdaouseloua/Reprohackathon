include { FASTQ } from './modules/fastq-dl/fastq'
include { FASTQC } from './modules/fastqc/fastqc'
include { METADATA } from './modules/fastq-dl/metadata'
include { CUTADAPT } from './modules/cutadapt/cutadapt'
include { DOWNLOAD_GENOME_ANN } from './modules/download_genome_ann'
include { BOWTIE_INDEX } from './modules/bowtie/bowtie_index'
include { BOWTIE_ALIGN_BAM } from './modules/bowtie/bowtie_align_bam'
include { FEATURECOUNT } from './modules/subread/featureCount'

workflow {

    DOWNLOAD_GENOME_ANN()
    BOWTIE_INDEX(DOWNLOAD_GENOME_ANN.out.genome)
    METADATA()

    metadata = METADATA.out.metadata
        .splitCsv(header: true, sep: '\t', strip: true)
	.map { row ->
            row + [new_name: row[params.meta_column].replace(' ', '_')]
        }

    // Small test runs before downloading the whole study
    def sample_limit = params.max_samples.toString().toInteger()

	if (sample_limit > 0) {
		metadata = metadata.take(sample_limit)
	}

    FASTQ(metadata)
    FASTQC(FASTQ.out.fastq)
    CUTADAPT(FASTQ.out.fastq)

    // One reference index for all samples
    BOWTIE_ALIGN_BAM(
        BOWTIE_INDEX.out.index_dir.first(),
        CUTADAPT.out.trimmed_reads
    )

    FEATURECOUNT(
        DOWNLOAD_GENOME_ANN.out.annotation.first(),
        BOWTIE_ALIGN_BAM.out.bam
    )
}
