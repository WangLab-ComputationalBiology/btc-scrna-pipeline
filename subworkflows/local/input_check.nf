//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'
include { METADATA_CHECK    } from '../../modules/local/metadata_check'

workflow INPUT_CHECK {
    take:
        samplesheet // file: /path/to/samplesheet.csv
        meta_data

    main:
        SAMPLESHEET_CHECK(samplesheet)
            .csv
            .splitCsv(header:true, sep:',')
            .map{ row -> tuple row.sample, row.fastq_1, row.fastq_2 }
            .set{ reads }

        METADATA_CHECK(meta_data)

    emit:
        reads                                     // channel: [ val(meta), [ reads ] ]
        metadata = METADATA_CHECK.out.csv         // channel
        versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
// REMOVED - .map{create_fastq_channel(it)}

def create_fastq_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample
    meta.single_end = row.single_end.toBoolean()

    // add path(s) of the fastq file(s) to the meta map
    def fastq_meta = []
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }
    if (meta.single_end) {
        fastq_meta = [ meta, [ file(row.fastq_1) ] ]
    } else {
        if (!file(row.fastq_2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
        }
        fastq_meta = [ meta, [ file(row.fastq_1), file(row.fastq_2) ] ]
    }
    return fastq_meta
}
