include { CELLRANGER_MULTI } from '../../modules/nf-core/cellranger/multi/main'                                                                                                                                                                                                                           

workflow SC_BASIC_MULTI {

    take:
        ch_config

    main:

        ch_alignment = CELLRANGER_MULTI(
            ch_config
        )

    emit:
        ch_alignment
    
}