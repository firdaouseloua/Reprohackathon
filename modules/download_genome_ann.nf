process DOWNLOAD_GENOME_ANN {

    tag "CP000253.1"

    publishDir "${params.outdir}/ref_genome", mode: 'copy'

    output:
    path "genome.fasta", emit: genome
    path "genome.gff", emit: annotation

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
