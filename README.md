Targeted Sequencing Analysis Pipeline
A comprehensive Nextflow pipeline for targeted sequencing analysis using nf-core/sarek with customized subsampling and Picard metrics collection.
🔬 Pipeline Overview
This pipeline performs:

BED file merging - Combines target and probe BED files
Coverage calculation - Determines required reads for target coverage (150x default)
FASTQ subsampling - Uses seqtk to subsample to target coverage
Quality control - FastQC on subsampled reads
Alignment - BWA-MEM alignment to reference genome
Comprehensive metrics - Extensive Picard metrics collection:

Alignment summary metrics
GC bias metrics with plots
Insert size metrics with plots
Hybrid selection (HS) metrics for targeted sequencing
Duplicate marking and metrics


Variant calling - Using multiple callers (FreeBayes, Mutect2, Strelka)
Quality reporting - MultiQC reports with all metrics and plots

📁 Output Structure


Results are organized by sample in separate folders:

results/

├── sample1/
│   ├── quality_control/     # FastQC reports
│   ├── metrics/            # All Picard metrics files
│   ├── plots/              # GC bias and insert size plots
│   ├── alignments/         # BAM files (if enabled)
│   └── variants/           # VCF files

├── sample2/
│   └── ...
├── multiqc_report.html     # Combined quality report
└── pipeline_info/          # Execution reports
🚀 Quick Start
Prerequisites

Nextflow (≥21.10.3)
Docker or Singularity
AWS CLI configured with S3 access
EC2 instance with sufficient resources

1. Clone and Setup
bash# Clone the repository
git clone https://github.com/yourusername/targeted-seq-pipeline.git
cd targeted-seq-pipeline

# Make run script executable
chmod +x run_pipeline.sh

2. Prepare Input Files
   
Create your samplesheet (assets/samplesheet.csv):
csvsample,fastq_1,fastq_2,strandedness
sample1,s3://your-bucket/sample1_R1.fastq.gz,s3://your-bucket/sample1_R2.fastq.gz,unstranded
sample2,s3://your-bucket/sample2_R1.fastq.gz,s3://your-bucket/sample2_R2.fastq.gz,unstranded

3. Configure Pipeline
   
Edit run_pipeline.sh with your specific paths:
bash# Your S3 paths
SAMPLESHEET="assets/samplesheet.csv"
OUTPUT_DIR="s3://your-output-bucket/results"
REFERENCE_GENOME="s3://your-reference-bucket/genome.fa"
TARGET_BED="s3://your-reference-bucket/target_regions.bed"
PROBE_BED="s3://your-reference-bucket/probe_regions.bed"

4. Run Pipeline
bash./run_pipeline.sh
Or run directly with Nextflow:
bashnextflow run main.nf \
  --input assets/samplesheet.csv \
  --outdir s3://your-bucket/results \
  --fasta s3://your-bucket/genome.fa \
  --target_bed s3://your-bucket/targets.bed \
  --probe_bed s3://your-bucket/probes.bed \
  --target_coverage 150 \
  --read_length 150 \
  --merge_beds true \
  -profile docker \
  -resume
