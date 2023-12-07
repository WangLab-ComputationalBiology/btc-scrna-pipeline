//
// Description
//

include { CELLRANGER_COUNT         } from '../../modules/nf-core/cellranger/count/main'
include { SCBTC_INDEX              } from '../../modules/local/btcmodules/indexes/main'

workflow SC_ALIGNMENT {

    take:
        ch_sample_table // channel: [ val(sample), [ fastq ] ]
        genome          // string: genome code

    main:
        // Retrieving Cellranger indexes
        if(genome == "GRCh38") {
            cellranger_indexes = params.genomes[genome].cellranger
        } else {
            cellranger_indexes = Channel.fromPath(genome)
        }

        // Saving indexes
        SCBTC_INDEX(cellranger_indexes)

        // Grouping fastq based on sample id
        ch_samples_grouped = ch_sample_table
            .map { row -> tuple row[0], row[1], row[2] }
            .groupTuple(by: [0])
            .map { row -> tuple row[0], row[1 .. 2].flatten() }

        // Cellranger alignment
        ch_alignment = CELLRANGER_COUNT(ch_samples_grouped, cellranger_indexes)

        ch_cell_matrices = ch_alignment.outs
            .map{sample, files -> [sample, files.findAll{ it.toString().endsWith("metrics_summary.csv") || it.toString().endsWith("filtered_feature_bc_matrix") }]}
            .map{sample, files -> [sample, files[0], files[1]]}

    emit:
        ch_cell_matrices = ch_cell_matrices // channel: [ matrices, filtered_feature_bc_matrix ]

}
