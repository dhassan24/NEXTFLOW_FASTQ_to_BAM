# HISAT2 Mouse Chr1 Alignment Pipeline

A [Nextflow](https://www.nextflow.io/) pipeline for aligning RNA-seq reads to the mouse chromosome 1 reference genome using HISAT2.

## Overview

This pipeline takes a gzipped FASTQ file and a gzipped reference genome, performs quality control, aligns reads, and outputs sorted, indexed BAM files ready for downstream analysis.

## Pipeline Steps

```
FASTQ.gz ──► Unzip ──► FastQC (QC report)
                  │
Genome.gz ──► Index Genome
                  │
              HISAT2 Align ──► SAM ──► BAM (sorted + indexed)
```

| Step | Process | Tool | Description |
|------|---------|------|-------------|
| 1 | `unzipFastq` | gzip | Decompresses the input FASTQ file |
| 2 | `indexGenome` | HISAT2 | Decompresses and indexes the reference genome |
| 3 | `fastqc` | FastQC | Runs quality control on the unzipped reads |
| 4 | `hisat2Align` | HISAT2 | Aligns reads to the indexed reference genome |
| 5 | `SamToBam` | SAMtools | Converts SAM to sorted BAM and indexes it |

## Requirements

- [Nextflow](https://www.nextflow.io/) ≥ 21.04
- [HISAT2](http://daehwankimlab.github.io/hisat2/)
- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- [SAMtools](http://www.htslib.org/)
- gzip

> **Tip:** You can manage dependencies with [Conda](https://docs.conda.io/) or run the pipeline inside a container (Docker/Singularity) to avoid manual installations.

## Usage

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### 2. Provide input files

Place your input files in the project directory (or update the paths in `nextflow.config` / via command-line flags):

- `chr1.fa.gz` — gzipped reference genome (mouse chromosome 1)
- `SRR1552445.fastq.gz` — gzipped RNA-seq reads

### 3. Run the pipeline

```bash
nextflow run hisat.nf
```

To override the default input paths:

```bash
nextflow run hisat.nf \
  --genome /path/to/your_genome.fa.gz \
  --input_file /path/to/your_reads.fastq.gz
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--genome` | `chr1.fa.gz` | Path to the gzipped reference genome |
| `--input_file` | `SRR1552445.fastq.gz` | Path to the gzipped input FASTQ file |

## Outputs

All results are written to the `results/` directory:

```
results/
├── unzipped/        # Decompressed FASTQ file
├── genome_index/    # HISAT2 index files (chr1_index.*)
├── fastqc/          # FastQC HTML reports and ZIP archives
├── aligned/         # Aligned reads in SAM format
└── bam/             # Sorted BAM files and their indexes (.bai)
```

## Example Data

The default parameters use publicly available data from NCBI SRA:

- **Sample:** [SRR1552445](https://www.ncbi.nlm.nih.gov/sra/SRR1552445) — mouse RNA-seq
- **Reference:** Mouse chromosome 1 (`chr1.fa.gz`)

## License

This project is open source. See [LICENSE](LICENSE) for details.
