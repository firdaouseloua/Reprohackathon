nextflow.enable.dsl = 2

params.outdir = 'results'
params.reads = 'data/test/*.fastq'

include { DOWNLOAD_REFERENCE } from './modules/download_reference'
include { BOWTIE_INDEX } from './modules/bowtie_index'
include { BOWTIE_ALIGN } from './modules/bowtie_align'

workflow {

    genome = DOWNLOAD_REFERENCE()
    index_dir = BOWTIE_INDEX(genome)
    
    reads = Channel.fromPath(params.reads, checkIfExists: true)
    BOWTIE_ALIGN(index_dir, reads)
}
