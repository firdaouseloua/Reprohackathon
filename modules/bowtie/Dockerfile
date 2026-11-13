FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
      wget unzip ca-certificates perl procps \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /tmp/bowtie.zip \
      "https://sourceforge.net/projects/bowtie-bio/files/bowtie/0.12.7/bowtie-0.12.7-linux-x86_64.zip/download" \
    && unzip -q /tmp/bowtie.zip -d /opt \
    && rm /tmp/bowtie.zip

ENV PATH="/opt/bowtie-0.12.7:${PATH}"