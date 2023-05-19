process BTCMODULES_QCREPORT {
    /* Description */
    
    tag "${project_name} - QC report"
    label 'process_single'

    container 'oandrefonseca/scpackages:1.0'

    input:
        tuple val(sample_id), path(matrices), path(csv_metrics), path(meta_data)
        path(scqc_script)

    output:
        tuple val(sample_id), path("objects/*"), path("log/*.txt"), emit: status
        path("${sample_id}_metrics_upgrade*.csv"), emit: metrics
        path("${sample_id}_report.html")
        path("figures/*")

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        """
    stub:
        """
        """
}