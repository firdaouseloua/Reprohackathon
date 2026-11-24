# Reprohackathon
This repository contains two reproducible RNA-Seq workflows that reimplement parts of the analyses of 2 published papers. The first pipeline reproduces the analysis of Nature Communications 2020 on Staphylococcus aureus persister cells, and aims at recovering Fig.3c (MA-plot of the genes related to translation) and Supplementary Fig. 3 (MA-plot of the complete dataset). \
The second pipeline reproduces the analysis of Frontiers in Microbiology 2020 on the response of the mouse brain to Toxoplasma gondii infection, and aims at recovering the Venn diagram of differentially expressed transcripts shown in Fig. 2B.\
Every step of each workflow runs inside a Docker container.

## Team and task distribution
The work is shared between 4 people. Each person is in charge of one block of steps similar in both pipelines.
| Person | Pipeline 1: *S. aureus* | Pipeline 2: *Toxoplasma gondii* |
|---|---|---|
| Person 1 (Franck) | FASTQ download + Cutadapt | SRA metadata + FASTQ download + Trimmomatic |
| Person 2 (Firdaous) | Reference genome + Bowtie index + mapping | Reference transcriptome + Salmon index |
| Person 3 (Klervi) | Samtools + featureCounts + count preparation | Salmon quantification + per-transcript count preparation |
| Person 4 (Eloise) | DESeq2 + MA-plots + DEG analysis | DESeq2 + Venn diagram + DET analysis |

## Repository structure
