//
// Description
//

include { SCBTC_DOUBLET       } from '../../modules/local/btcmodules/doublet/main.nf'
include { SCBTC_NORMALIZATION } from '../../modules/local/btcmodules/normalization/main.nf'
include { SCBTC_INTEGRATION   } from '../../modules/local/btcmodules/integration/main.nf'
include { SCBTC_EVALUATION    } from '../../modules/local/btcmodules/evaluation/main.nf'
include { SCBTC_CLUSTERING    } from '../../modules/local/btcmodules/clustering/main.nf'
include { SCBTC_DIFFERENTIAL  } from '../../modules/local/btcmodules/differential/main.nf'
include { SCBTC_COMMUNICATION  } from '../../modules/local/btcmodules/communication/main.nf'


workflow SC_INTERMEDIATE_NORMAL {

    take:
        ch_annotated
        input_task_step

    main:
        // Rmarkdown scripts
        doublet_script        = "${workflow.projectDir}/notebook/notebook_doublet_detection.Rmd"
        normalization_script  = "${workflow.projectDir}/notebook/notebook_dimensionality_reduction.Rmd"
        integration_script    = "${workflow.projectDir}/notebook/notebook_batch_correction.Rmd"
        evaluation_script     = "${workflow.projectDir}/notebook/notebook_batch_evaluation.Rmd"
        cluster_script        = "${workflow.projectDir}/notebook/notebook_cell_clustering.Rmd"
        differential_script   = "${workflow.projectDir}/notebook/notebook_differential_expression.Rmd"
        communication_script  = "${workflow.projectDir}/notebook/notebook_cell_communication.Rmd"

        // Description
        SCBTC_DOUBLET(          
            ch_annotated,
            doublet_script,
            input_task_step
        )

        // Description
        SCBTC_COMMUNICATION(
            ch_annotated,
            communication_script
        )

        // Description
        SCBTC_NORMALIZATION(
            ch_annotated,
            normalization_script,
            input_task_step
        )

        // Description
        SCBTC_INTEGRATION(
            SCBTC_NORMALIZATION.out.project_rds,
            integration_script,
            input_task_step
        )

        // Description
        SCBTC_EVALUATION(
            SCBTC_INTEGRATION.out.project_rds,
            evaluation_script,
            input_task_step
        )

        // Description
        SCBTC_CLUSTERING(          
            SCBTC_INTEGRATION.out.project_rds,
            SCBTC_EVALUATION.out.integration_method,
            cluster_script,
            input_task_step
        )

        // Description
        SCBTC_DIFFERENTIAL(
            SCBTC_CLUSTERING.out.project_rds,
            differential_script,
            input_task_step
        )

        ch_normal = SCBTC_CLUSTERING.out.project_rds

    emit:
        ch_normal
    
}