process DOWNLOAD_MOUSE_ANNOTATION {

    tag "Mouse annotation - Ensembl Release 100"

    container 'reprohack-reference:1.0'

    cpus 1

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
    val annotation_url

    output:
    path "mouse_annotation.gtf", emit: annotation
    path "annotation.sha256", emit: checksum

    script:
    """
    set -euo pipefail

    # Same release as the transcriptome, no mixing references today
    curl -fL --retry 3 \
        "${annotation_url}" \
        -o mouse_annotation.gtf.gz

    gzip -t mouse_annotation.gtf.gz
    gzip -dc mouse_annotation.gtf.gz > mouse_annotation.gtf

    test -s mouse_annotation.gtf
    grep -q 'gene_id' mouse_annotation.gtf
    grep -q 'transcript_id' mouse_annotation.gtf

    sha256sum mouse_annotation.gtf > annotation.sha256
    """
}
