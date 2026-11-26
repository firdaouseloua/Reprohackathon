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
      -o genome.fasta

    test -s genome.fasta

    curl -fL --retry 3 \\
      "https://www.ncbi.nlm.nih.gov/sviewer/viewer.cgi?db=nuccore&report=gff3&id=CP000253.1" \\
      -o genome.gff

    test -s genome.gff
    """
}
