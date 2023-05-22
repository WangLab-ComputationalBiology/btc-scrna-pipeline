// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { SEURAT_NORMALIZATION } from '../../modules/local/btcmodules/normalization/main'
include { SEURAT_CLUSTERING    } from '../../modules/local/btcmodules/clustering/main'

workflow SC_BASIC_PROCESSING {

    take:
        // TODO nf-core: edit input (take) channels
        ch_qc_approved // channel: [ val(meta), [ bam ] ]

    main:

        // Rmarkdown scripts 
        merge_script = "${workflow.projectDir}/notebook/03_merge_and_normalize.Rmd"
        cluster_script = "${workflow.projectDir}/notebook/05_cell_clustering.Rmd"

        // Description
        SEURAT_NORMALIZATION(
            ch_qc_approved,
            merge_script
        )
        ch_normalize_object = SEURAT_NORMALIZATION.out.project_rds

        // Description        
        SEURAT_CLUSTERING(          
            ch_normalize_object,
            cluster_script
        )
        ch_cluster_object = SEURAT_CLUSTERING.out.project_rds

    emit:
        // TODO nf-core: edit emitted channels
        ch_cluster_object
}

