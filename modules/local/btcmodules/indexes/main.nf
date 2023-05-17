process BTCMODULES_INDEX {
    
    tag 'download'
    label 'process_single'

    container "oandrefonseca/scaligners:1.0"

    input:
        val(genome)

    output:
        path("indexes/${genome}"), emit: index
        path "versions.yml"      , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def indexes = ["GRCh38" : "https://www.dropbox.com/s/9bvocucv9qg5cn2/GRCh38.tar.gz?dl=0"]
        """
        wget ${indexes[genome]} -O ${genome}.tar.gz
        mkdir ./indexes 
        tar -zxvf ${genome}.tar.gz -C ./indexes
        rm -Rf ${genome}.tar.gz

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            btcmodules: https://storage.googleapis.com/btc-dshub-pipelines/scRNA/refData/GRCh38.tar
        END_VERSIONS
        """
    stub:
        """
        mkdir ./indexes
        touch ${indexes[genome]}
        """
}