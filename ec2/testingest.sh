#!/bin/bash

# Test the ingest capabilities by copying sample documents into the ambar intake directory

input_dir="./SampleDocuments"
intake_dir="/opt/ambar/intake"

echo -e "Ingesting test documents from ${input_dir} to ${intake_dir}...\n"
cp ${input_dir}/* ${intake_dir}

echo "${intake_dir}:"
ls -1 $intake_dir