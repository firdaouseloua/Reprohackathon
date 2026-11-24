# Base image: Ubuntu 22.04
FROM ubuntu:22.04
# Install dependencies, download and install FastQC, then clean up,
# all in a single RUN instruction (see below why)
RUN apt-get update \
&& apt-get install -y --no-install-recommends openjdk-11-jre-headless perl wget unzip ca-certificates \
&& cd /opt \
&& wget -q https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip \
&& unzip fastqc_v0.12.1.zip \
&& rm fastqc_v0.12.1.zip \
&& chmod +x /opt/FastQC/fastqc \
&& apt-get remove -y wget unzip \
&& apt-get autoremove -y \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*
# Make fastqc available in the PATH, and avoid perl locale warnings
ENV PATH=/opt/FastQC:$PATH
ENV LANG=C.UTF-8
# Command executed by default when running the container
CMD ["fastqc", "--help"]