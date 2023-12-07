//
// Description
//

include { SCBTC_FILTERING          } from '../../modules/local/btcmodules/filtering/main'
include { SCBTC_QCRENDER           } from '../../modules/local/btcmodules/report/main'

workflow SC_BASIC_QC {

    take:
        ch_cell_matrices // channel: [ val(sample), [ fastq ] ]
        ch_meta_data    // channel

    main:
        // Channel definitions
        ch_versions  = Channel.empty()

        // Rmarkdown scripts
        scqc_script     = "${workflow.projectDir}/notebook/notebook_quality_control.Rmd"
        qc_table_script = "${workflow.projectDir}/notebook/notebook_quality_table_report.Rmd"

        // Combining
        ch_cell_matrices = ch_cell_matrices
            .combine(ch_meta_data)

        // Performing QC steps
        SCBTC_FILTERING(ch_cell_matrices, scqc_script)

        // Writing QC check
        ch_quality_report = SCBTC_FILTERING.out.metrics
            .collect()

        // Generating QC table
        SCBTC_QCRENDER(ch_quality_report, qc_table_script)

        // Filter poor quality samples
        ch_qc_approved = SCBTC_FILTERING.out.status
            .filter{sample, object, status -> status.toString().endsWith('SUCCESS.txt')}
            .map{sample, object, status -> object}
            .collect()

        ch_qc_approved
            .ifEmpty{error 'No samples matched QC expectations.'}
            .view{'Done'}

    emit:
        ch_qc_approved = ch_qc_approved // channel: [ objects ]

}
