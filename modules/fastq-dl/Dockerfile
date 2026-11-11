FROM mambaorg/micromamba:1.5.8

RUN micromamba install -y -n base -c conda-forge -c bioconda fastq-dl \
    && micromamba clean --all --yes

USER root
RUN apt-get update && apt-get install -y --no-install-recommends procps \
    && rm -rf /var/lib/apt/lists/*
USER $MAMBA_USER

ENV PATH="/opt/conda/bin:$PATH"