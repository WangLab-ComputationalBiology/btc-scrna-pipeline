process SEURAT_ANNOTATION {
    /* Description */

    tag "Cell annotation"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(project_object)
        path(cluster_script)

    output:
        path("${params.project_name}_annotation_object_*.RDS"), emit: project_rds
        path("${params.project_name}_annotation_report.html")
        path("figures/*")
        path("data/*")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${cluster_script}",
            params = list(
                project_name = "${params.project_name}",
                project_object = "${project_object}",
                thr_resolution = ${params.thr_resolution},
                workdir = here,
                timestamp = "${workflow.runName}"

            ), 
            output_dir = here,
            output_file = "${params.project_name}_cluster_report.html"
            )           

        """
    stub:
        """
        touch ${params.project_name}_annotation_report.html
        touch ${params.project_name}_annotation_object_${workflow.runName}.RDS

        mkdir -p figures
        touch figures/EMPTY
        """
}
