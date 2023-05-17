process CELLRANGER_COUNT {
    tag "$meta.id"
    label 'process_high'

    container "oandrefonseca/scaligners:1.0"

    input:
        tuple val(meta), path(reads)
        path  reference

    output:
        tuple val(meta), path("sample/${meta.id}/outs/*"), emit: outs
        path "versions.yml"                              , emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        def sample_arg = meta.samples.unique().join(",")
        def reference_name = reference.name
        """
            cellranger \\
                count \\
                --id='${meta.id}' \\
                --fastqs=. \\
                --transcriptome=${reference_name} \\
                --sample=${sample_arg} \\
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
        mkdir -p "sample/${meta.id}/outs/"
        touch sample/${meta.id}/outs/fake_file.txt

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            cellranger: \$(echo \$( cellranger --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*\\).*\$/\\1/' )
        END_VERSIONS
        """
}
