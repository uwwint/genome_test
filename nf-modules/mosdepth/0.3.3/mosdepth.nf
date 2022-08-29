process mosdepth {
    tag { id }
    publishDir "${outdir}/qc/mosdepth", mode: 'copy'
    label "mosdepth"

    conda "$projectDir/conf/mosdepth.yaml"

    input:
        tuple val(id), file(bam)
        val outdir
    
    output:
        path "*.{txt,gz,csi}"
        path "*global.dist.txt", emit: multiqc

    script:
        """
        mosdepth \
            -t ${task.cpus} \
            --fast-mode \
            --mapq 20 \
            ${id} \
            ${bam[0]}
        """
}