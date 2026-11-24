process DOWNLOAD_TRANSCRIPTOME {

    tag "Mus musculus - Ensembl Release 100"

    container 'curlimages/curl:8.10.1'

    cpus 1

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
    val transcriptome_url

    output:
    path "transcripts.fa", emit: transcriptome

    script:
    """
    # Download the mouse transcriptome, not the parasite!
    curl -fL --retry 3 \
        "${transcriptome_url}" \
        -o transcripts.fa.gz

    # Make sure the download is not corrupted
    gzip -t transcripts.fa.gz

    gzip -dc transcripts.fa.gz > transcripts.fa

    test -s transcripts.fa
    grep -q '^>' transcripts.fa
    """
}
