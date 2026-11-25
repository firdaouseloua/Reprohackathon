include { DOWNLOAD_TRANSCRIPTOME } from '../modules/download_transcriptome'
include { DOWNLOAD_MOUSE_ANNOTATION } from '../modules/download_mouse_annotation'
include { SALMON_INDEX } from '../modules/salmon/salmon_index'
include { BUILD_TX2GENE } from '../modules/build_tx2gene'

workflow {

    DOWNLOAD_TRANSCRIPTOME(
        Channel.value(params.transcriptome_url)
    )

    DOWNLOAD_MOUSE_ANNOTATION(
        Channel.value(params.annotation_url)
    )

    SALMON_INDEX(
        DOWNLOAD_TRANSCRIPTOME.out.transcriptome
    )

    BUILD_TX2GENE(
        DOWNLOAD_MOUSE_ANNOTATION.out.annotation,
        DOWNLOAD_TRANSCRIPTOME.out.transcriptome,
        file("${projectDir}/../scripts/build_tx2gene.py")
    )
}
