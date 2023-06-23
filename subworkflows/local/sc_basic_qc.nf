//
// Description
//

include { CELLRANGER_COUNT         } from '../../modules/nf-core/cellranger/count/main'
include { CELLRANGER_MKGTF         } from '../../modules/nf-core/cellranger/mkgtf/main'
include { SCBTC_INDEX              } from '../../modules/local/btcmodules/indexes/main'
include { SCBTC_FILTERING          } from '../../modules/local/btcmodules/filtering/main'
include { SCBTC_QCRENDER           } from '../../modules/local/btcmodules/report/main'

workflow SC_BASIC_QC {

    take:
        // TODO nf-core: edit input (take) channels
        ch_sample_table // channel: [ val(sample), [ fastq ] ]
        meta_data // path: /path/to/meta_data
        genome // string: genome code

    main:

        // Channel definitions
        ch_versions = Channel.empty()
        ch_meta_data = Channel.fromPath(meta_data)

        // Rmarkdown scripts 
        scqc_script = "${workflow.projectDir}/notebook/notebook_quality_control.Rmd"
        qc_table_script = "${workflow.projectDir}/notebook/notebook_quality_table_report.Rmd"

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

        // Performing QC steps
        SCBTC_FILTERING(ch_cell_matrices, scqc_script)

        // Writing QC check
        ch_quality_report = SCBTC_FILTERING.out.metrics
            .collect()

        // Generating QC table
        BTCMODULES_QC_RENDER(ch_quality_report, qc_table_script)

        // Filter poor quality samples
        ch_qc_approved = SCBTC_FILTERING.out.status
            .filter{sample, object, status -> status.toString().endsWith('SUCCESS.txt')}
            .map{sample, object, status -> object}
            .collect()

        ch_qc_approved
            .ifEmpty{error 'No samples matched QC expectations.'}
            .view{'Done'}

        /* 
        ch_versions = ch_versions.mix(BTCMODULES_INDEX.out.versions.first())
        */

    emit:
        // TODO nf-core: edit emitted channels
        ch_qc_approved = ch_qc_approved // channel: [ objects ]
        //versions = ch_versions          // channel: [ versions.yml ]
}