process busco_plot {
    tag { 'BUSCO plot' }
    publishDir "${outdir}/qc/busco", mode: 'move'

    conda "$projectDir/conf/R.yaml"

    input:
        file summaries
        val outdir
    
    output:
        path "*.png"

    script:
        """
        Rscript --vanilla ${projectDir}/bin/busco-plot-updated.R
        """
}