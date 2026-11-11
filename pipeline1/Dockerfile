FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bowtie \
    curl \
    ca-certificates \
    bash && \
    rm -rf /var/lib/apt/lists/*

CMD ["bash"]
