# To run
# nextflow run main.nf --sample_table assets/test_sample_table.csv --meta_data assets/test_meta_data.csv --project_name Test -resume -profile singularity

nextflow run /rsrch6/home/genomic_med/affaustino/Projects/btc-scrna-pipeline/main.nf --sample_table /rsrch6/home/genomic_med/affaustino/Projects/btc-scrna-pipeline/assets/test_sample_table.csv --meta_data /rsrch6/home/genomic_med/affaustino/Projects/btc-scrna-pipeline/assets/test_meta_data.csv --project_name Test --cancer_type Ovarian -resume -profile singularity
# nextflow run main.nf --sample_table assets/test_sample_table.csv --meta_data assets/test_meta_data.csv --project_name Test --cancer_type Ovarian -w /rsrch6/home/genomic_med/lwang22_lab/affaustino/ovarian1.0 -resume -profile seadragon

# To debug
# singularity shell scpackages_1.1.sif