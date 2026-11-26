process DOWNLOAD_TRANSCRIPTOME {

    tag "Mus musculus - Ensembl Release 100"
    container 'ottarein/general:0.1'
    cpus 1
    publishDir "${params.outdir}/reference_files", mode: 'copy'

    output:
    path "mouse_transcripts.fa", emit: transcriptome
    path "reference.sha256", emit: checksum
    path "reference_stats.txt", emit: stats

    script:
    """
    # Download the mouse transcriptome, not the parasite!
    curl -fL --retry 3 \\
        "https://ftp.ensembl.org/pub/release-100/fasta/mus_musculus/cdna/Mus_musculus.GRCm38.cdna.all.fa.gz" \\
        -o mouse_transcripts.fa.gz

    gzip -t mouse_transcripts.fa.gz
    gzip -dc mouse_transcripts.fa.gz > mouse_transcripts.fa

    test -s mouse_transcripts.fa
    grep -q '^>' mouse_transcripts.fa

    # Make sure everyone is working with the same reference
    sha256sum mouse_transcripts.fa > reference.sha256

    # Count the transcript sequences
    echo "Organism: Mus musculus" > reference_stats.txt
    echo "Ensembl release: 100" >> reference_stats.txt
    echo "Assembly: GRCm38" >> reference_stats.txt

    printf "Number of transcripts: " >> reference_stats.txt
    grep -c '^>' mouse_transcripts.fa >> reference_stats.txt
    """
}