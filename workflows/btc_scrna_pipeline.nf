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
for (param in checkPathParamList) { if (param) { file(param, checkIfExists: true) } }

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
include { SC_BASIC_QC              } from '../subworkflows/local/sc_basic_qc'
include { SC_BASIC_PROCESSING      } from '../subworkflows/local/sc_basic_processing'
include { SC_BASIC_STRATIFICATION  } from '../subworkflows/local/sc_basic_stratification'
include { SC_BASIC_CELL_ANNOTATION } from '../subworkflows/local/sc_basic_annotation'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BTC_SCRNA_PIPELINE {

    ch_versions = Channel.empty()

    // Description
    INPUT_CHECK(sample_table)

    // Description
    SC_BASIC_QC(
        INPUT_CHECK.out.reads,
        meta_data,
        params.genome
    )
    
    // Description
    SC_BASIC_PROCESSING(
        SC_BASIC_QC.out,
        "main"
    )

    // Description
    SC_BASIC_STRATIFICATION(
        SC_BASIC_PROCESSING.out,
        cancer_type
    )
    
    // Description
    SC_BASIC_CELL_ANNOTATION(
        SC_BASIC_STRATIFICATION.out
    )

    /* 
    // Description

    // Description
    SC_INTERMEDIATE_NORMAL(
        SC_BASIC_STRATIFICATION.out.tme
    )

    SC_INTERMEDIATE_MALIGNANT()

    /*    
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    ch_versions
    */
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    COMPLETION MESSAGE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow.onComplete {

    log.info(workflow.success ? "May the Force be with you!" : "Please check your inputs.")

}