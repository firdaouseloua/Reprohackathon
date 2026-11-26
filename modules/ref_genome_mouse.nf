process REF_GENOME_MOUSE {

    tag "Mus musculus - Ensembl Release 100"
    container 'ottarein/general:0.1'
    cpus 1
    publishDir "${params.outdir}/reference_files", mode: 'copy'

    output:
    path "gentrome.fa.gz", emit: gentrome
    path "decoys.txt", emit: decoy

    script:
    """
    # Download the mouse transcriptome, not the parasite!
    curl -fL --retry 3 \\
        "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/gencode.vM25.transcripts.fa.gz" \\
        -o mouse_transcript.fa.gz
    
    curl -fL --retry 3 \\
        "https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M25/GRCm38.primary_assembly.genome.fa.gz" \\
        -o mouse_genome.fa.gz
    
    grep "^>" <(gunzip -c mouse_genome.fa.gz) | cut -d " " -f 1 > decoys.txt
    
    sed -i.bak -e 's/>//g' decoys.txt   

    cat mouse_transcript.fa.gz mouse_genome.fa.gz > gentrome.fa.gz

    test -s mouse_transcripts.fa.gz
    test -s mouse_genome.fa.gz
    test -s decoys.txt
    test -s gentrome.fa.gz
    """
}