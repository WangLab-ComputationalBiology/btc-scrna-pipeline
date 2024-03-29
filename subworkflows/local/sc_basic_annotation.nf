//
// Description
//

include { SCBTC_ANNOTATION } from '../../modules/local/btcmodules/annotation/main.nf'

workflow SC_BASIC_CELL_ANNOTATION {

    take:
        ch_nonmalignant
        annotation_db

    main:
        // Rmarkdown scripts 
        annotation_script = "${workflow.projectDir}/notebook/notebook_cell_annotation.Rmd"

        // Description
        SCBTC_ANNOTATION(
            ch_nonmalignant,
            annotation_script,
            annotation_db
        )

        ch_annotation = SCBTC_ANNOTATION.out.project_rds

    emit:
        ch_annotation
    
}