nextflow.enable.dsl = 2

include { DOWNLOAD_TRANSCRIPTOME } from './modules/download_transcriptome'
include { SALMON_INDEX } from './modules/salmon_index'

params.outdir = "${projectDir}/results"

params.transcriptome_url = 'https://ftp.ensembl.org/pub/release-100/fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz'

workflow {

    transcriptome_ch = DOWNLOAD_TRANSCRIPTOME(
    	Channel.value(params.transcriptome_url)
    )

    index_ch = SALMON_INDEX(
        transcriptome_ch.transcriptome
    )
}
