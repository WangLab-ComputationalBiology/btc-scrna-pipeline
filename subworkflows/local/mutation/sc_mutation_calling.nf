//
// Check input samplesheet and get read channels
//

include { SCOMATIC_SPLITBAM         } from '../../modules/local/scomatic/SCOMATIC_SPLITBAM'
include { SCOMATIC_BASECOUNTS_SPLIT } from '../../modules/local/scomatic/SCOMATIC_BASECOUNTS_SPLIT'
include { SCOMATIC_MERGECOUNTS      } from '../../modules/local/scomatic/SCOMATIC_MERGECOUNTS'
include { SCOMATIC_CALLABLE_PERCT   } from '../../modules/local/scomatic/SCOMATIC_CALLABLE_PERCT'
include { SCOMATIC_VARIANTCALLING   } from '../../modules/local/scomatic/SCOMATIC_VARIANTCALLING'
include { SCOMATIC_CALLABLESITES    } from '../../modules/local/scomatic/SCOMATIC_CALLABLESITES'
include { SCOMATIC_GENOTYPE_CELLS   } from '../../modules/local/scomatic/SCOMATIC_GENOTYPE_CELLS'

workflow INPUT_CHECK {
    take:
        bam
                

    main:


    emit:
}
