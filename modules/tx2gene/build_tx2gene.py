import re
import sys
import csv

gtf_file = sys.argv[1]
fasta_file = sys.argv[2]
output_file = sys.argv[3]

mapping = {}

# Read transcript annotations from the GTF
with open(gtf_file) as gtf:
    for line in gtf:
        if line.startswith("#"):
            continue

        fields = line.rstrip("\n").split("\t")

        if len(fields) != 9 or fields[2] != "transcript":
            continue

        attrs = dict(re.findall(r'(\w+) "([^"]+)"', fields[8]))

        transcript = attrs["transcript_id"]
        version = attrs.get("transcript_version")

        if version:
            transcript += "." + version

        mapping[transcript] = attrs["gene_id"]

# Check the actual FASTA identifiers, because assumptions hurt
fasta_mapping = {}

with open(fasta_file) as fasta:
    for line in fasta:
        if line.startswith(">"):
            transcript = line[1:].split()[0]
            gene = re.search(r'\bgene:(\S+)', line)

            if gene is None:
                raise ValueError(f"Missing gene ID: {transcript}")

            fasta_mapping[transcript] = gene.group(1).split(".")[0]

missing = fasta_mapping.keys() - mapping.keys()

mismatches = [
    tx for tx, gene in fasta_mapping.items()
    if tx in mapping and mapping[tx] != gene
]

print(f"GTF transcripts: {len(mapping)}")
print(f"FASTA transcripts: {len(fasta_mapping)}")
print(f"Missing transcripts: {len(missing)}")
print(f"Gene mismatches: {len(mismatches)}")

if missing or mismatches:
    print("Reference consistency check failed.")
    print("Missing examples:", sorted(missing)[:5])
    print("Mismatch examples:", mismatches[:5])
    sys.exit(1)

# Only keep transcripts actually present in our Salmon reference
with open(output_file, "w") as output:
    writer = csv.writer(output, delimiter="\t", lineterminator="\n")
    writer.writerow(["TXNAME", "GENEID"])

    for transcript in sorted(fasta_mapping):
        writer.writerow([transcript, mapping[transcript]])

print(f"Unique genes: {len(set(fasta_mapping.values()))}")
print(f"Mapping saved to {output_file}")
