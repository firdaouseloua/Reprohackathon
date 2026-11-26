process DOWNLOAD_MOUSE_ANNOTATION {

    tag "Mouse annotation - Ensembl Release 100"
    container 'ottarein/general:0.1'
    cpus 1
    publishDir "${params.outdir}/reference_files", mode: 'copy'

    output:
    path "mouse_annotation.gtf", emit: annotation
    path "annotation.sha256", emit: checksum

    script:
    """
    set -euo pipefail

    # Same release as the transcriptome, no mixing references today
    curl -fL --retry 3 \\
        "https://ftp.ensembl.org/pub/release-100/gtf/mus_musculus/Mus_musculus.GRCm38.100.chr_patch_hapl_scaff.gtf.gz" \\
        -o mouse_annotation.gtf.gz

    gzip -t mouse_annotation.gtf.gz
    gzip -dc mouse_annotation.gtf.gz > mouse_annotation.gtf

    test -s mouse_annotation.gtf
    grep -q 'gene_id' mouse_annotation.gtf
    grep -q 'transcript_id' mouse_annotation.gtf

    sha256sum mouse_annotation.gtf > annotation.sha256
    """
}
