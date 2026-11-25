process DOWNLOAD_TRANSCRIPTOME {

    tag "Mus musculus - Ensembl Release 100"

    container 'reprohack-reference:1.0'

    cpus 1

    publishDir "${params.outdir}/reference", mode: 'copy'

    input:
    val transcriptome_url

    output:
    path "transcripts.fa", emit: transcriptome
    path "reference.sha256", emit: checksum
    path "reference_stats.txt", emit: stats

    script:
    """
    set -euo pipefail
    # Download the mouse transcriptome, not the parasite!
    curl -fL --retry 3 \
        "${transcriptome_url}" \
        -o transcripts.fa.gz

    gzip -t transcripts.fa.gz
    gzip -dc transcripts.fa.gz > transcripts.fa

    test -s transcripts.fa
    grep -q '^>' transcripts.fa

    # Make sure everyone is working with the same reference
    sha256sum transcripts.fa > reference.sha256

    # Count the transcript sequences
    echo "Organism: Mus musculus" > reference_stats.txt
    echo "Ensembl release: 100" >> reference_stats.txt
    echo "Assembly: GRCm38" >> reference_stats.txt

    printf "Number of transcripts: " >> reference_stats.txt
    grep -c '^>' transcripts.fa >> reference_stats.txt
    """
}