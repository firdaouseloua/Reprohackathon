include { DOWNLOAD_MOUSE_ANNOTATION } from './modules/download_mouse_annotation'

workflow {

    DOWNLOAD_MOUSE_ANNOTATION(
        Channel.value(params.annotation_url)
    )

}
