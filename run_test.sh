# To run
nextflow run main.nf --sample_table assets/test_sample_table.csv --meta_data assets/test_meta_data.csv --project_name Test -resume -profile singularity

# To debug
# singularity shell scpackages_1.1.sif