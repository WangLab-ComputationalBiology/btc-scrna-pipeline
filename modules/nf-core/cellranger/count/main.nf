process CELLRANGER_COUNT {
    tag "${sample}"
    label 'process_medium'

    container "oandrefonseca/scaligners:1.0"

    input:
        tuple val(sample), path(reads)
        path  reference

    output:
        tuple val(sample), path("sample/${sample}/outs/*"), emit: outs
        path "versions.yml"                               , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def reference_name = reference.name
        """
            cellranger \\
                count \\
                --id='${sample}' \\
                --fastqs=. \\
                --transcriptome=${reference_name} \\
                --sample=${sample} \\
                --include-introns=false \\
                --localcores=${task.cpus} \\
                --localmem=${task.memory.toGiga()} \\
                $args

            cat <<-END_VERSIONS > versions.yml
            "${task.process}":
                cellranger: \$(echo \$( cellranger --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*\\).*\$/\\1/' )
            END_VERSIONS
        """

    stub:
        """
        mkdir -p "sample/${sample}/outs/"
        touch sample/${sample}/outs/fake_file.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            cellranger: \$(echo \$( cellranger --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*\\).*\$/\\1/' )
        END_VERSIONS
        """
}
