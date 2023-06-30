BTC scRNA Pipeline

## Project parameters

Reference genome related files and options required for the workflow.

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `sample_table` | Path to sample table | `string` | ./assets/test_sample_table.csv |  |  |
| `meta_data` | Path to meta-data | `string` | ./assets/test_meta_data.csv |  |  |
| `project_name` | Project name | `string` | Test |  |  |
| `cancer_type` | Enter the cancer type | `string` | None |  |  |
| `genome` | Genome ID <details><summary>Help</summary><small>If using a reference genome configured in the pipeline using iGenomes, use this parameter to give the ID fo
| `fasta` | Path to FASTA genome file. <details><summary>Help</summary><small>This parameter is *mandatory* if `--genome` is not specified. If you don't have a BWA index

## Quality Control parameters

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `thr_estimate_n_cells` | Estimated number of cells | `integer` | 300 |  |  |
| `thr_mean_reads_per_cells` | Mean reads per cell | `integer` | 25000 |  |  |
| `thr_median_genes_per_cell` | Median genes per cell | `integer` | 900 |  |  |
| `thr_median_umi_per_cell` | Median UMI per cell | `integer` | 1000 |  |  |
| `thr_n_feature_rna_min` | Minimum features per cell | `integer` | 300 |  |  |
| `thr_n_feature_rna_max` | Maximum features per cell | `integer` | 7500 |  |  |
| `thr_percent_mito` | Percentage of mitochondrial genes | `integer` | 25 |  |  |
| `thr_n_observed_cells` | Number of observed cells | `integer` | 300 |  |  |

## Normalization parameters

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input_reduction_step` | Internal pipeline parameter. Do not customize it. | `string` | None |  | True |
| `thr_n_features` | Number features for FindVariableFeatures | `integer` | 2000 |  |  |

## Clustering parameters

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input_cluster_step` | Internal pipeline parameter. Do not customize it. | `string` | None |  | True |
| `input_features_plot` | Genes to be displayed on Feature plot | `string` | LYZ;CCL5;IL32;PTPRCAP;FCGR3A;PF4;PTPRC |  |  |
| `input_integration_dimension` | Embeddings for Louvain clustering | `string` | auto |  |  |
| `input_group_plot` | Meta-data columns for UMAP plot | `string` | source_name;Sort |  |  |
| `thr_resolution` | Resolution threshold | `number` | 0.25 |  |  |
| `thr_proportion` | Cell proportion for ROGUE calculation | `number` | 0.25 |  |  |

## Stratification parameters

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input_stratification_method` | Method to define stratification labels | `string` | infercnv_label |  |  |
| `thr_cluster_size` | Defining cluster size limit | `integer` | 1000 |  |  |
| `thr_consensus_score` | Consensus score threshold (Beta) | `integer` | 2 |  |  |

## Cell annotations parameters

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input_cell_markers_db` | Path to cell annotation CSV file | `string` | ./assets/cell_markers_database.csv |  |  |
| `input_annotation_level` | Define annotation level. Currently, only Major cells are available. | `string` | Major cells |  |  |

## Batch correction parameters

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input_batch_step` | Internal pipeline parameter. Do not customize it. | `string` | None |  | True |
| `input_integration_method` | Batch correction / Integration methods. Default (all). | `string` | all |  |  |
| `input_target_variables` | Meta-data target variable for batch correction | `string` | batch |  |  |

## Batch Evaluation parameters



| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input_integration_evaluate` | Define methods to be evaluated | `string` | all |  |  |
| `thr_cell_proportion` | Cell proportion for Batch evaluation | `number` | 0.3 |  |  |
| `input_lisi_variables` | Define LISI types for Density plot | `string` | cLISI;iLISI |  |  |
| `input_auto_selection` | Internal pipeline parameter. Do not customize it. | `boolean` | True |  | True |

## Differential Expression parameters



| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input_deg_step` | Internal pipeline parameter. Do not customize it. | `string` | None |  | True |
| `input_deg_method` | Define DEG method (check options at Seurat documentation) | `string` | wilcox |  |  |
| `input_top_deg` | Number of DEG to be displayed | `integer` | 20 |  |  |
| `thr_fold_change` | Fold-change threshold | `number` | 0.25 |  |  |
| `thr_min_percentage` | Minimum cell percentage per DEG | `number` | 0.1 |  |  |
| `opt_hgv_filter` | Filtering only HGV genes (Optional) | `boolean` |  |  |  |

## Meta-program parameters

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `input_meta_step` | Internal pipeline parameter. Do not customize it. | `string` | None |  | True |
| `input_meta_programs_db` | Path to meta-program CSV file | `string` | ./assets/meta_programs_database.csv |  |  |
| `input_cell_category` | Meta-program cell category | `string` | Malignant |  |  |
| `input_heatmap_annotation` | Meta-data columns to be displayed on heatmap | `string` | source_name;seurat_clusters |  |  |

## Max job request options

Set the top limit for requested resources for any single job.

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `max_cpus` | Maximum number of CPUs that can be requested for any single job. <details><summary>Help</summary><small>Use to set an upper-limit for the CPU requirement
| `max_memory` | Maximum amount of memory that can be requested for any single job. <details><summary>Help</summary><small>Use to set an upper-limit for the memory requi
| `max_time` | Maximum amount of time that can be requested for any single job. <details><summary>Help</summary><small>Use to set an upper-limit for the time requirement

## Generic options

Less common options for the pipeline, typically set in a config file.

| Parameter | Description | Type | Default | Required | Hidden |
|-----------|-----------|-----------|-----------|-----------|-----------|
| `help` | Display help text. | `boolean` |  |  | True |
| `version` | Display version and exit. | `boolean` |  |  | True |
| `publish_dir_mode` | Method used to save pipeline results to output directory. <details><summary>Help</summary><small>The Nextflow `publishDir` option specifies which
| `monochrome_logs` | Do not use coloured log outputs. | `boolean` |  |  | True |
| `tracedir` | Directory to keep pipeline Nextflow logs and reports. | `string` | ${params.outdir}/pipeline_info |  | True |
| `validate_params` | Boolean whether to validate parameters against the schema at runtime | `boolean` | True |  | True |
| `show_hidden_params` | Show all params when using `--help` <details><summary>Help</summary><small>By default, parameters set as _hidden_ in the schema are not shown on