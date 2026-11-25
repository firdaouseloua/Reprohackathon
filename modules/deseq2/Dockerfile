FROM mambaorg/micromamba:1.5.8

RUN micromamba install -y -n base -c conda-forge -c bioconda \
    r-base=3.4.1 \
    libgfortran=3.0.0 \
    bioconductor-deseq2=1.16.1 \
    r-ggplot2 \
    r-ggrepel \
    bioconductor-rtracklayer \
    r-venndiagram \
    && micromamba clean --all --yes

USER root
RUN apt-get update && apt-get install -y --no-install-recommends procps \
    && rm -rf /var/lib/apt/lists/*
USER $MAMBA_USER

ENV PATH="/opt/conda/bin:$PATH"
ENV LD_LIBRARY_PATH="/opt/conda/lib:$LD_LIBRARY_PATH"
ENV LANG=C.UTF-8