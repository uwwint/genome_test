process hifiadapterfilt {
    tag { id }
    publishDir "${outdir}/adapter-removed-reads", mode: 'copy'
    label "hififilter"

    conda "$projectDir/conf/hifiadapterfilt.yaml"

    input:
        tuple file(id), value(reads)
        file outdir
    
    output:
        tuple val(id), file("${reads.getName()}.filt.fastq.gz"), emit: clean
        path "${reads.getName()}.{blocklist,stats}"
        
    script:
        """
        hifiadapterfilt.sh \
            -p ${reads} \
            -t ${task.cpus}
        """
}
