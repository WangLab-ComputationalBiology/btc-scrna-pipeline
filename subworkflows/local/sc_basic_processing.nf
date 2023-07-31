//
// Description
//

include { SCBTC_MERGE         } from '../../modules/local/btcmodules/merge/main'
include { SCBTC_CLUSTERING    } from '../../modules/local/btcmodules/clustering/main'

workflow SC_BASIC_PROCESSING {

    take:
        // TODO nf-core: edit input (take) channels
        ch_qc_approved // channel: [ val(meta), [ bam ] ]
        input_cluster_step

    main:

        // Rmarkdown scripts 
        merge_script   = "${workflow.projectDir}/notebook/notebook_merge.Rmd"
        cluster_script = "${workflow.projectDir}/notebook/notebook_cell_clustering.Rmd"

        // Description
        SCBTC_MERGE(
            ch_qc_approved,
            merge_script
        )

        ch_normalize = SCBTC_MERGE.out.project_rds

        // Description        
        SCBTC_CLUSTERING(          
            ch_normalize,
            cluster_script,
            input_cluster_step
        )

        ch_cluster = SCBTC_CLUSTERING.out.project_rds      

    emit:
        // TODO nf-core: edit emitted channels
        ch_cluster
}