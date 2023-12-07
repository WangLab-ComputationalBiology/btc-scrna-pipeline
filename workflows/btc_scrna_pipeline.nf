/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)

// Validate input parameters
WorkflowBtcscrnapipeline.initialise(params, log)

// TODO nf-core: Add all file path parameters for the pipeline to the list below
// Check input path parameters to see if they exist
def checkPathParamList = [ params.sample_table, params.meta_data ]
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: false) } }

// Check mandatory parameters
if (params.sample_table) { sample_table = file(params.sample_table) } else { exit 1, 'Sample sheet not specified. Please, provide a --sample_table <PATH/TO/SAMMPLE_TABLE.csv> !' }
if (params.meta_data) { meta_data = file(params.meta_data) } else { exit 1, 'Meta-data not specified. Please, provide a --meta_data <PATH/TO/META_DATA.csv>' }
if (params.project_name) { project_name = params.project_name } else { exit 1, 'Project name not specified. Please, provide a --project_name <NAME>.' }
if (params.cancer_type) { cancer_type = params.cancer_type } else { exit 1, 'Cancer type not specified. Please, provide a --cancer_type <NAME>.' }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// SUBWORKFLOW: Consisting of a mix of local and nf-core/modules
//
include { INPUT_CHECK              } from '../subworkflows/local/input_check'
include { SC_ALIGNMENT             } from '../subworkflows/local/sc_alignment'
include { SC_BASIC_QC              } from '../subworkflows/local/sc_basic_qc'
include { SC_BASIC_PROCESSING      } from '../subworkflows/local/sc_basic_processing'
include { SC_BASIC_STRATIFICATION  } from '../subworkflows/local/sc_basic_stratification'
include { SC_BASIC_CELL_ANNOTATION } from '../subworkflows/local/sc_basic_annotation'
include { SC_INTERMEDIATE_NORMAL   } from '../subworkflows/local/sc_intermediate_normal'
include { SC_INTERMEDIATE_CANCER   } from '../subworkflows/local/sc_intermediate_cancer'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BTC_SCRNA_PIPELINE {

    ch_versions = Channel.empty()

    // Cirro-related edition
    if(params.meta_data == "assets/test_meta_data.csv") {
        meta_data = "${workflow.projectDir}/${params.meta_data}"
    } else {
        meta_data = file("${params.meta_data}")
    }

    println(meta_data)

    // Preparing databases
    meta_programs_db  = Channel.fromPath("${workflow.projectDir}/${params.input_meta_programs_db}")
    annotation_db     = Channel.fromPath("${workflow.projectDir}/${params.input_cell_markers_db}")

    if(params.workflow_level =~ /\b(Basic|Stratification|Annotation|nonMalignant|Malignant|Complete)/) {

        // Checking sample input
        INPUT_CHECK(
            sample_table,
            meta_data
        )

        // Download index and Cellranger alignment
        SC_ALIGNMENT(
            INPUT_CHECK.out.reads,
            params.genome
        )

        // Basic quality control
        SC_BASIC_QC(
            SC_ALIGNMENT.out,
            INPUT_CHECK.out.metadata
        )

        // Normalization and clustering
        SC_BASIC_PROCESSING(
            SC_BASIC_QC.out,
            "main"
        )

    }

    if(params.workflow_level =~ /\b(Stratification|Annotation|nonMalignant|Malignant|Complete)/) {

        // Performing cell stratification
        SC_BASIC_STRATIFICATION(
            SC_BASIC_PROCESSING.out,
            cancer_type
        )

    }

    if(params.workflow_level =~ /\b(Annotation|nonMalignant|Complete)/) {

        // Loading nonMalignant
        ch_normal = SC_BASIC_STRATIFICATION.out.
            map{files -> [files.find{ it.toString().contains("nonMalignant") }]}

        SC_BASIC_CELL_ANNOTATION(
            ch_normal,
            annotation_db
        )

    }

    if(params.workflow_level =~ /\b(nonMalignant|Complete)/) {

        // Analyzing normal/nonMalignant cells
        SC_INTERMEDIATE_NORMAL(
            SC_BASIC_CELL_ANNOTATION.out,
            "nonMalignant"
        )

    }

    if(params.workflow_level =~ /\b(Malignant|Complete)/) {

        // Loading Malignant cells
        ch_cancer = SC_BASIC_STRATIFICATION.out.
            map{files -> [files.find{ it.toString().contains("Malignant") }]}

        // Analyzing cancer/Malignant cells
        SC_INTERMEDIATE_CANCER(
            ch_cancer,
            meta_programs_db,
            "Malignant"
        )

    }

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION MESSAGE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {

    log.info(workflow.success ? "All done!" : "Please check your inputs.")

}
