# Reprohackathon

This project was developed as part of our M2 BIBS-IA workflow course.

The objective is to reproduce parts of two published RNA-Seq studies using Nextflow and Docker. We wanted to make the analyses reproducible and easier to run without having to manually install every bioinformatics tool.

Both pipelines share the same `main.nf` and `nextflow.config`. The workflow to execute is selected using the study accession.

## 1. Biological context and objectives

### Pipeline 1 - Staphylococcus aureus

Based on a study published in Nature Communications (2020) about intracellular S. aureus persister cells.

The objective is to study the changes in gene expression associated with bacterial persistence after antibiotic treatment.

We aim to reproduce:

- Figure 3c: MA-plot of genes related to translation.
- Supplementary Figure 3: MA-plot of the complete dataset.

Study accession: `PRJNA586837`

### Pipeline 2 - Toxoplasma gondii

Based on a study published in Frontiers in Microbiology (2020) about the response of the mouse brain to Toxoplasma gondii infection.

The objective is to study changes in the host transcriptome following infection.

We aim to reproduce:

- Figure 2B: Venn diagram of differentially expressed transcripts.

Study accession: `PRJNA483261`

## 2. Team and task distribution

The project is divided between four people. Each person is responsible for similar steps in both pipelines.

| Person | Pipeline 1: S. aureus | Pipeline 2: T. gondii |
|---|---|---|
| Franck | Metadata, FASTQ download and Cutadapt | Metadata, FASTQ download and Trimmomatic |
| Firdaous | Reference genome, Bowtie indexing and mapping | Mouse transcriptome, annotations, Salmon indexing and reference validation |
| Klervi | Samtools, featureCounts and count preparation | Salmon quantification and count preparation |
| Eloise | DESeq2, MA-plots and DEG analysis | DESeq2, Venn diagram and DET analysis |

## 3. Workflow overview

### Pipeline 1

```text
Metadata
    |
FASTQ download
    |
FastQC
    |
Cutadapt
    |
Bowtie alignment <--- Reference genome + Bowtie index
    |
Samtools
    |
featureCounts <--- Genome annotations
    |
DESeq2
    |
MA-plots
```

Bowtie and Samtools can be combined to avoid storing large intermediate SAM files.

### Pipeline 2

```text
Metadata
    |
FASTQ download
    |
FastQC
    |
Trimmomatic
    |
Salmon quantification <--- Mouse transcriptome + Salmon index
    |
Count preparation
    |
DESeq2
    |
Venn diagram
```

The mouse annotations are also downloaded and checked against the reference transcriptome.

A transcript-to-gene correspondence table (`tx2gene.tsv`) is generated and made available for downstream analysis.

These diagrams represent the intended complete workflows.

## 4. Repository structure

Both pipelines use a common entry point and configuration.

```text
Reprohackathon/
├── main.nf
├── nextflow.config
├── README.md
├── .gitignore
├── modules/
│   ├── fastq-dl/
│   ├── fastqc/
│   ├── cutadapt/
│   ├── bowtie/
│   ├── samtools/
│   ├── subread/
│   ├── salmon/
│   │   ├── salmon_index.nf
│   │   └── quantification.nf
│   ├── deseq2/
│   ├── Dockerfile.reference
│   ├── download_genome_ann.nf
│   ├── download_transcriptome.nf
│   ├── download_mouse_annotation.nf
│   └── build_tx2gene.nf
├── scripts/
│   └── build_tx2gene.py
└── tests/
    ├── test_annotation.nf
    └── test_reference.nf
```

- `main.nf`: selects and connects the processes for each study.
- `nextflow.config`: contains the common parameters and execution settings.
- `modules/`: contains the different Nextflow processes and Dockerfiles.
- `scripts/`: contains additional scripts used by the workflow.
- `tests/`: contains smaller workflows to test specific steps independently.

The Trimmomatic module will be added during the remaining integration.

## 5. Requirements

The workflows were developed and tested on an IFB virtual machine running Ubuntu.

The main requirements are:

- Git
- Java 21
- Nextflow
- Docker
- Internet access to download the data and Docker images

Versions used during our reference preparation tests:

| Tool | Version |
|---|---|
| Java | 21 |
| Nextflow | 26.10.7 |
| Salmon | 1.2.0 |
| Bowtie | 0.12.7 |

Check that the required tools are available:

```bash
java -version
nextflow -version
docker --version
```

## 6. How to run the workflows

### Clone the repository

```bash
git clone https://github.com/firdaouseloua/Reprohackathon.git
cd Reprohackathon
```

### Build the custom Docker images

Some processes use our own Docker images.

```bash
docker build -t reprohack-reference:1.0 \
    -f modules/Dockerfile.reference modules/

docker build -t reprohack-bowtie-samtools:1.0 \
    -f modules/bowtie/Dockerfile.combined modules/bowtie/
```

### Pipeline 1

```bash
nextflow run main.nf \
    --study_accession PRJNA586837 \
    --outdir results/pipeline1 \
    --cpus 4
```

### Pipeline 2

```bash
nextflow run main.nf \
    --study_accession PRJNA483261 \
    --outdir results/pipeline2 \
    --cpus 4
```

### Main parameters

| Parameter | Description |
|---|---|
| `--study_accession` | Select the study and the corresponding workflow |
| `--outdir` | Output directory |
| `--cpus` | Number of CPUs available |
| `--max_samples` | Limit the number of samples for testing |
| `--meta_column` | Override the metadata column used for sample names |
| `-resume` | Reuse previously completed processes |

By default, `max_samples = 0` means that all samples are selected.

## 7. Reference data and technical choices

### Pipeline 1

- Organism: Staphylococcus aureus NCTC 8325
- Reference accession: CP000253.1
- Alignment tool: Bowtie
- Counting tool: featureCounts

The reference index is built once and reused for all samples.

We also combined Bowtie alignment and Samtools sorting to reduce disk usage by avoiding large intermediate SAM files.

### Pipeline 2

For this study, we use the mouse transcriptome rather than the parasite transcriptome because we are interested in the host response to infection.

| Parameter | Choice |
|---|---|
| Organism | Mus musculus |
| Assembly | GRCm38 |
| Database | Ensembl |
| Release | 100 |
| Reference type | cDNA |
| Indexing tool | Salmon 1.2.0 |
| K-mer size | 31 |

The transcriptome and annotations come from the same Ensembl release.

We use the complete GTF file, including chromosomes, patches, haplotypes and scaffolds.

#### Reference validation

During our first test, we noticed that 1,686 transcripts from the FASTA file were missing from the standard GTF annotation.

After checking these transcripts, we found that the missing annotations included alternative regions of the genome.

We therefore switched to the complete Ensembl GTF file without changing the transcriptome.

| Validation | Standard GTF | Complete GTF |
|---|---:|---:|
| Annotated transcripts | 142,699 | 144,778 |
| FASTA transcripts | 119,414 | 119,414 |
| Missing transcripts | 1,686 | 0 |
| Gene ID mismatches | 0 | 0 |

The final reference validation gave:

- 119,414 transcripts with a gene correspondence.
- 36,727 unique genes.
- No missing transcripts.
- No gene ID mismatches.

This validation is now included in the workflow through the `BUILD_TX2GENE` process.

## 8. Testing

Downloading and processing all samples can take a lot of time, so we added some options to test smaller parts of the project.

### Preview a workflow

Check the workflow structure without executing the processes:

```bash
nextflow run main.nf -preview \
    --study_accession PRJNA586837 \
    --max_samples 1
```

```bash
nextflow run main.nf -preview \
    --study_accession PRJNA483261 \
    --max_samples 1
```

### Run with a limited number of samples

```bash
nextflow run main.nf \
    --study_accession PRJNA586837 \
    --max_samples 1 \
    --cpus 4 \
    --outdir results/test_pipeline1 \
    -resume
```

### Test the mouse annotations

```bash
nextflow run tests/test_annotation.nf \
    --outdir results/test_annotation
```

### Test the Pipeline 2 reference preparation

```bash
nextflow run tests/test_reference.nf \
    --outdir results/test_reference \
    --cpus 4 \
    -resume
```

This test runs four processes:

- `DOWNLOAD_TRANSCRIPTOME`
- `DOWNLOAD_MOUSE_ANNOTATION`
- `SALMON_INDEX`
- `BUILD_TX2GENE`

All four processes were successfully tested on the IFB VM.

## 9. Results and outputs

The output directory depends on the selected pipeline.

For example, the Pipeline 2 reference test produces:

```text
results/test_reference/
├── reference/
│   ├── transcripts.fa
│   ├── mouse_annotation.gtf
│   ├── reference.sha256
│   ├── annotation.sha256
│   ├── reference_stats.txt
│   ├── reference_validation.txt
│   └── tx2gene.tsv
├── index/
│   └── salmon_index/
└── pipeline_info/
```

Nextflow also generates execution reports, traces, timelines and workflow diagrams.

The downloaded data, indexes and working directories are not stored on GitHub. They are generated when running the workflows.

## 10. Reproducibility

To make our workflows reproducible, we use:

- Docker containers for the bioinformatics tools.
- Explicit reference accessions and database releases.
- Fixed versions for important analysis tools.
- Automatic reference downloads.
- Checksums and reference consistency checks.
- A common configuration for both studies.
- Nextflow reports and execution traces.
- Small test workflows for independent validation.

## 11. Current progress

- [x] Shared Nextflow configuration
- [x] Common workflow entry point
- [x] Pipeline 1 reference preparation and mapping implementation
- [x] Pipeline 2 transcriptome and annotation download
- [x] Salmon indexing
- [x] Transcriptome and annotation consistency validation
- [x] Automatic tx2gene generation
- [x] Pipeline 2 reference preparation test
- [x] Preview of both workflows
- [ ] Complete integration of the remaining analysis modules
- [ ] Full execution of both workflows
- [ ] Comparison with the figures from the original papers

## Authors

Franck, Firdaous, Klervi and Eloise.

Master 2 BIBS-IA - Université Paris-Saclay

2026-2027
