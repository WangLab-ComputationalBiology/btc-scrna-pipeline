//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'
include { METADATA_CHECK    } from '../../modules/local/metadata_check'

workflow COUNTS_INPUT_CHECK {
    take:
        samplesheet // file: /path/to/samplesheet.csv
        meta_data

    main:
        SAMPLESHEET_CHECK(samplesheet)
            .csv
            .splitCsv(header:true, sep:',')
            .map{ row -> tuple row.sample, row.seurat_project }
            .set{ reads }

        METADATA_CHECK(meta_data)

    emit:
        counts                                    // channel: [ val(meta), [ seurat_project ] ]
        metadata = METADATA_CHECK.out.csv         // channel
        versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}
