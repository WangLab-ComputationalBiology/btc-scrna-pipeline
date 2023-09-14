//
// Description
//

include { SCBTC_DOUBLET       } from '../../modules/local/btcmodules/doublet/main.nf'
include { SCBTC_NORMALIZATION } from '../../modules/local/btcmodules/normalization/main.nf'
include { SCBTC_CLUSTERING    } from '../../modules/local/btcmodules/clustering/main.nf'
include { SCBTC_DIFFERENTIAL  } from '../../modules/local/btcmodules/differential/main.nf'
include { SCBTC_METAPROGRAM   } from '../../modules/local/btcmodules/metaprogram/main.nf'

workflow SC_INTERMEDIATE_CANCER {

    take:
        ch_cancer
        input_task_step

    main:
        // Rmarkdown scripts
        normalization_script = "${workflow.projectDir}/notebook/notebook_dimensionality_reduction.Rmd"
        cluster_script       = "${workflow.projectDir}/notebook/notebook_cell_clustering.Rmd"
        metaprogram_script   = "${workflow.projectDir}/notebook/notebook_meta_programs.Rmd"
        differential_script  = "${workflow.projectDir}/notebook/notebook_differential_expression.Rmd"
        meta_programs_db     = "${workflow.projectDir}/${params.input_meta_programs_db}"

        // Description
        SCBTC_NORMALIZATION(
            ch_cancer,
            normalization_script,
            input_task_step
        )

        // Description
        ch_integration = 'path/to/dummy'

        SCBTC_CLUSTERING(          
            SCBTC_NORMALIZATION.out.project_rds,
            ch_integration,
            cluster_script,
            input_task_step
        )

        // Description
        SCBTC_METAPROGRAM(          
            SCBTC_CLUSTERING.out.project_rds,
            metaprogram_script,
            meta_programs_db,
            input_task_step
        )

        // Description
        SCBTC_DIFFERENTIAL(
            SCBTC_CLUSTERING.out.project_rds,
            differential_script,
            input_task_step
        )

        ch_cancer = SCBTC_METAPROGRAM.out.project_rds

    emit:
        ch_cancer
}

