process multiqc {
    tag { 'Report' }
    publishDir "${outdir}/multiqc", mode: 'move'

    conda "$projectDir/conf/multiqc.yaml"

    input:
        file files
        val intro
        val outdir
    
    output:
        path "multiqc_report.html"

    script:
        """
        multiqc --config ${projectDir}/conf/multiqc-config.yaml --cl_config '${intro}' .
        """
    
    stub:
        """
        touch multiqc_report.html
        """
}