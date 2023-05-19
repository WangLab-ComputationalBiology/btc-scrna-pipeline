// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { CELLRANGER_COUNT         } from '../../modules/nf-core/cellranger/count/main'
include { CELLRANGER_MKGTF         } from '../../modules/nf-core/cellranger/mkgtf/main'
include { BTCMODULES_INDEX         } from '../../modules/local/btcmodules/indexes/main'
include { BTCMODULES_SEURAT_FILTER } from '../../modules/local/seurat/filtering/main'

workflow SC_BASIC_QC {

    take:
        // TODO nf-core: edit input (take) channels
        ch_sample_table // channel: [ val(meta), [ bam ] ]
        ch_meta_data // path: /path/to/meta_data
        genome

    main:

        // Channel definitions
        ch_versions = Channel.empty()
        ch_meta_data = Channel.fromPath(ch_meta_data)

        // Rmarkdown scripts 
        scqc_script = "${workflow.projectDir}/notebook/01_quality_control.Rmd"
        qc_table_script = "${workflow.projectDir}/notebook/02_quality_table_report.Rmd"
        merge_script = "${workflow.projectDir}/notebook/03_merge_and_normalize.Rmd"
        batch_script = "${workflow.projectDir}/notebook/04_batch_correction.Rmd"
        cluster_script = "${workflow.projectDir}/notebook/05_cell_clustering.Rmd"

        // Retrieving Cellranger indexes
        BTCMODULES_INDEX(genome)

        // Grouping fastq based on sample id
        ch_samples_grouped = ch_sample_table
            .map { row -> tuple row[0], row[1], row[2] }
            .groupTuple(by: [0])
            .map { row -> tuple row[0], row[1 .. 2].flatten() }

        // Cellranger alignment
        ch_alignment = CELLRANGER_COUNT(ch_samples_grouped, BTCMODULES_INDEX.out.index)
        ch_cell_matrices = ch_alignment.outs
            .map{sample, files -> [sample, files.findAll{ it.toString().endsWith("metrics_summary.csv") || it.toString().endsWith("filtered_feature_bc_matrix") }]}
            .map{sample, files -> [sample, files[0], files[1]]}

        ch_cell_matrices = ch_cell_matrices
            .combine(ch_meta_data)
        
        ch_cell_matrices
            .view()

        // Performing QC steps
        BTCMODULES_SEURAT_FILTER(ch_cell_matrices, scqc_script)

        /*
        // Writing QC check
        ch_quality_report = SAMPLE_CELL_QC.out.metrics
            .collect()
    
        // Generating QC table
        QUALITY_TABLE(ch_quality_report, qc_table_script)

        // Filter poor quality samples
        ch_qc_approved = SAMPLE_CELL_QC.out.status
            .filter{sample, object, status -> status.toString().endsWith('SUCCESS.txt')}
            .map{sample, object, status -> object}
            .collect()

        ch_qc_approved
            .ifEmpty{error 'No samples matched QC expectations.'}
            .view{'Done'}

        ch_versions = ch_versions.mix(BTCMODULES_INDEX.out.versions.first())
        */

    emit:
        // TODO nf-core: edit emitted channels
        //ch_qc_approved = ch_qc_approved // channel: [ val(meta), [ bam ] ]
        //versions = ch_versions          // channel: [ versions.yml ]
        ch_cell_matrices
}