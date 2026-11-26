process REF_GENOME_AUREUS {

    tag "CP000253.1"

    publishDir "${params.outdir}/reference_files", mode: 'copy'

    output:
    path "aureus.fasta", emit: genome
    path "aureus.gff", emit: annotation

    script:
    """
    curl -fL --retry 3 \\
      "https://www.ebi.ac.uk/ena/browser/api/fasta/CP000253.1" \\
      -o aureus.fasta

    sed -i 's/^>.*/>CP000253.1/' aureus.fasta
    grep -q '^>CP000253\\.1\$' aureus.fasta
    test -s aureus.fasta

    curl -fL --retry 3 \\
      "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1" \\
      -o aureus.gff
    
    test  -s aureus.gff
    
    curl -fL --retry 3 \\
      "https://www.kegg.jp/kegg-bin/download_htext?htext=sao00001&format=json&filedir=" \\
      -o kegg_orthology.json

    test -s kegg_orthology.json
    """
}