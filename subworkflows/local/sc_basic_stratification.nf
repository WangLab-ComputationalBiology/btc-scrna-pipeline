//
// Description
//

include { SCBTC_STRATIFICATION    } from '../../modules/local/btcmodules/stratification/main'

workflow SC_BASIC_STRATIFICATION {

    take:
        ch_cluster_object
        input_cancer_type

    main:
        // Rmarkdown scripts 
        stratification_script   = "${workflow.projectDir}/notebook/notebook_cell_stratification.Rmd"

        // Description
        SCBTC_STRATIFICATION(
            ch_cluster_object,
            stratification_script,
            input_cancer_type
        )
        
        ch_stratifcation = SCBTC_STRATIFICATION.out.project_rds

    emit:
        ch_stratifcation
}

