process SEURAT_NORMALIZATION {
    tag "Running normalization"
    label 'process_high'

    container "oandrefonseca/scpackages:1.0"

    input:
        path(ch_qc_approved)
        path(merge_script)

    output:
        path("${params.project_name}_normalize_object.RDS"), emit: project_rds
        path("${params.project_name}_normalize_report.html")
        path("figures/*")

    script:
        """
        #!/usr/bin/env Rscript

        # Getting run work directory
        here <- getwd()

        # Rendering Rmarkdown script
        rmarkdown::render("${merge_script}",
            params = list(
                project_name = "${params.project_name}",
                input_qc_approved = "${ch_qc_approved.join(';')}",
                workdir = here
            ), 
            output_dir = here,
            output_file = "${params.project_name}_normalize_report.html")
        """
    stub:
        """
        touch ${params.project_name}_normalize_report.html
        touch ${params.project_name}_normalize_object.RDS

        mkdir -p figures
        touch figures/EMPTY
        """
}
