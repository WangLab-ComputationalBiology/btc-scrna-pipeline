process BTCMODULES_INDEX {
    
    tag "Retrieving ${genome}"
    label 'process_single'

    container "oandrefonseca/scaligners:1.0"

    input:
        val(genome) // variable: GENOME

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
            btcmodules: ${genome} ${indexes[genome]}
        END_VERSIONS
        """
    stub:
        def indexes = ["GRCh38" : "https://www.dropbox.com/s/9bvocucv9qg5cn2/GRCh38.tar.gz?dl=0"]
        """
        mkdir -p ./indexes/${genome}
        
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            btcmodules: ${genome} ${indexes[genome]}
        END_VERSIONS


        """
}