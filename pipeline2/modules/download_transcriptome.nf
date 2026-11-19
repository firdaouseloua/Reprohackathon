process DOWNLOAD_TRANSCRIPTOME {

    tag "Toxoplasma reference transcriptome"

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
    val transcriptome_url

    output:
    path "transcripts.fa", emit: transcriptome

    script:
    """
    curl -fL "${transcriptome_url}" -o reference_download

    if gzip -t reference_download 2>/dev/null; then
        gzip -dc reference_download > transcripts.fa
    else
        cp reference_download transcripts.fa
    fi

    test -s transcripts.fa
    """
}
