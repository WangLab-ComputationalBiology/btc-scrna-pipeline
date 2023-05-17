// TODO nf-core: If in doubt look at other nf-core/subworkflows to see how we are doing things! :)
//               https://github.com/nf-core/modules/tree/master/subworkflows
//               You can also ask for help via your pull request or on the #subworkflows channel on the nf-core Slack workspace:
//               https://nf-co.re/join
// TODO nf-core: A subworkflow SHOULD import at least two modules

include { CELLRANGER_COUNT } from '../../modules/nf-core/cellranger/count/main'
include { CELLRANGER_MKGTF } from '../../modules/nf-core/cellranger/mkgtf/main'
include { BTCMODULES_INDEX } from '../../modules/local/btcmodules/indexes/main'

workflow SC_BASIC_QC {

    take:
        // TODO nf-core: edit input (take) channels
        ch_sample_table // channel: [ val(meta), [ bam ] ]
        ch_meta_data // channel: path
        genome

    main:
        // Channel versions
        ch_versions = Channel.empty()

        // Retrieving Cellranger indexes
        BTCMODULES_INDEX(genome)

        ch_sample_table
            .view()

        // Grouping fastq based on sample id
        ch_samples_grouped = ch_sample_table
            .map {row -> tuple row.id, row.fastq_1, row.fastq_2 }
            //.groupTuple(by: [0])
            //.map { row -> tuple row[0], row[1 .. 2].flatten() }

        ch_samples_grouped
            .view()

        /*

        // Cellranger alignment
        CELLRANGER_COUNT(ch_samples_grouped, BTCMODULES_INDEX.out.index)

        ch_cell_matrices = CELLRANGER_COUNT.out.cell_out.map{sample, outs -> [sample, outs.findAll {
            it.toString().endsWith("metrics_summary.csv") || it.toString().endsWith("filtered_feature_bc_matrix")}]}
            .map{sample, files -> [sample, files[0], files[1]]}

        ch_cell_matrices = ch_cell_matrices
            .combine(meta_channel)

        // Performing QC steps
        SAMPLE_CELL_QC(ch_cell_matrices, scqc_script)

        // Writing QC check
        ch_quality_report = SAMPLE_CELL_QC.out.metrics
            .collect()
    
        // Generating QC table
        QUALITY_TABLE(ch_quality_report, qc_table_script)

        // Filter poor quality samples
        ch_qc_approved = SAMPLE_CELL_QC.out.status
            .filter{sample, object, status -> status.toString().endsWith('SUCCESS.txt')}
            .map{sample, object, status -> object}
            .collect()

        ch_qc_approved
            .ifEmpty{error 'No samples matched QC expectations.'}
            .view{'Done'}

        ch_versions = ch_versions.mix(BTCMODULES_INDEX.out.versions.first())
        */
    emit:
        // TODO nf-core: edit emitted channels
        //ch_qc_approved = ch_qc_approved // channel: [ val(meta), [ bam ] ]
        //versions = ch_versions          // channel: [ versions.yml ]
        //ch_samples_grouped
        ch_sample_table

}