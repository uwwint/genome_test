process flagstat {
    tag { bam[0].simpleName }
    publishDir "${outdir}/qc/alignment-statistics", mode: 'copy'
    label "flagstat"

    conda "$projectDir/conf/samtools.yaml"

    input:
        file bam
        val outdir
    
    output:
        path "${bam[0].simpleName}.flagstat"
        path "${bam[0].simpleName}.flagstat", emit: multiqc

    script:
        """
        samtools flagstat \
            -@ ${task.cpus} \
            ${bam[0]} > ${bam[0].simpleName}.flagstat
         """
}