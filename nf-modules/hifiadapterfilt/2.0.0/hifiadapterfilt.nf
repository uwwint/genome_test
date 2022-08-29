process hifiadapterfilt {
    tag { id }
    publishDir "${outdir}/adapter-removed-reads", mode: 'copy'
    label "hififilter"

    conda "$projectDir/conf/hifiadapterfilt.yaml"

    input:
        tuple val(id), file(reads)
        val outdir
    
    output:
        tuple val(id), path("${id}.filt.fastq.gz"), emit: clean
        path "${id}.{blocklist,stats}"
        
    script:
        """
        hifiadapterfilt.sh \
            -p ${id} \
            -t ${task.cpus}
        """
}
