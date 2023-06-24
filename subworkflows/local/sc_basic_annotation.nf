//
// Description
//

include { SCBTC_ANNOTATION } from '../../modules/local/btcmodules/annotation/main.nf'

workflow SC_BASIC_CELL_ANNOTATION {

    take:
        ch_stratifcation

    main:

        // Rmarkdown scripts 
        annotation_script = "${workflow.projectDir}/notebook_cell_annotation.Rmd"

        // Loading nonMalignant
        ch_nonmalignant = ch_stratifcation.out.
            map{files -> [files.find{ it.toString().contains("nonMalignant") }]}

        // Description
        SCBTC_ANNOTATION(
            ch_nonmalignant,
            annotation_script
        )

        ch_annotation_object = SCBTC_ANNOTATION.out.project_rds

    emit:
        ch_annotation_object
}