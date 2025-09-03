#!/bin/bash

# Targeted Sequencing Pipeline Execution Script
# Usage: ./run_pipeline.sh

set -euo pipefail

# Configuration variables - EDIT THESE
SAMPLESHEET="assets/samplesheet.csv"
OUTPUT_DIR="s3://your-output-bucket/results"
REFERENCE_GENOME="s3://your-reference-bucket/genome.fa"
TARGET_BED="s3://your-reference-bucket/target_regions.bed"
PROBE_BED="s3://your-reference-bucket/probe_regions.bed"  # Optional
TARGET_COVERAGE=150
READ_LENGTH=150

# Pipeline parameters
NEXTFLOW_PARAMS=(
    --input "$SAMPLESHEET"
    --outdir "$OUTPUT_DIR"
    --fasta "$REFERENCE_GENOME"
    --target_bed "$TARGET_BED"
    --target_coverage "$TARGET_COVERAGE"
    --read_length "$READ_LENGTH"
    --merge_beds true
    --save_mapped true
    --tools "freebayes,mutect2,strelka"
    -profile docker
    -resume
    -with-report "${OUTPUT_DIR}/pipeline_info/execution_report.html"
    -with-timeline "${OUTPUT_DIR}/pipeline_info/execution_timeline.html"
    -with-dag "${OUTPUT_DIR}/pipeline_info/pipeline_dag.svg"
)

# Add probe BED if provided
if [[ -n "${PROBE_BED}" ]]; then
    NEXTFLOW_PARAMS+=(--probe_bed "$PROBE_BED")
fi

# Check if Nextflow is installed
if ! command -v nextflow &> /dev/null; then
    echo "ERROR: Nextflow is not installed or not in PATH"
    echo "Please install Nextflow: https://www.nextflow.io/docs/latest/getstarted.html"
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not available"
    echo "Please install Docker or use a different profile (-profile singularity/conda)"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS CLI is not configured or credentials are invalid"
    echo "Please configure AWS CLI with: aws configure"
    exit 1
fi

# Create output directory if it doesn't exist
echo "Creating output directory..."
aws s3 mb "${OUTPUT_DIR%/*}" 2>/dev/null || true

echo "=========================================="
echo "Starting Targeted Sequencing Pipeline"
echo "=========================================="
echo "Input: $SAMPLESHEET"
echo "Output: $OUTPUT_DIR"
echo "Reference: $REFERENCE_GENOME"
echo "Target BED: $TARGET_BED"
echo "Target Coverage: ${TARGET_COVERAGE}x"
echo "=========================================="

# Run the pipeline
nextflow run main.nf "${NEXTFLOW_PARAMS[@]}"

echo "=========================================="
echo "Pipeline completed successfully!"
echo "Results are available at: $OUTPUT_DIR"
echo "=========================================="
