nextflow.enable.dsl = 2

include { DOWNLOAD_TRANSCRIPTOME } from './modules/download_transcriptome'
include { SALMON_INDEX } from './modules/salmon_index'
include { quantification } from './modules/quantification'

workflow {

    // Download the mouse reference once
    transcriptome_ch = DOWNLOAD_TRANSCRIPTOME(
        Channel.value(params.transcriptome_url)
    )

    // Build the index once, no need to suffer twice
    index_ch = SALMON_INDEX(
        transcriptome_ch.transcriptome
    )

    // Optional quantification with already trimmed reads
    if (params.reads) {

        reads_ch = Channel.fromFilePairs(
            params.reads,
            size: 2,
            checkIfExists: true
        )

        quantification(
            reads_ch,
            index_ch.index.first()
        )
    }
}