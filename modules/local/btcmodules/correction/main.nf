process SEURAT_BATCH_CORRECTION {
    tag "Batch correction"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(batch_script)

    output:
        path("${params.project_name}_batch_object_*.RDS"), emit: project_rds
        path("${params.project_name}_batch_report.html")
        path("figures/*")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${batch_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                input_target_variables = 'batch',
                workdir = here,
                timestamp = "${workflow.runName}"
            ), 
            output_dir = here,
            output_file = "${params.project_name}_batch_report.html")           

        """
    stub:
        """
        touch ${params.project_name}_batch_report.html
        touch ${params.project_name}_batch_object_${workflow.runName}.RDS

        mkdir -p figures
        touch figures/EMPTY
        """
}
