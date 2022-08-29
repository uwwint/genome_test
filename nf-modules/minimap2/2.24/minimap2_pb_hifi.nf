process minimap2_pb_hifi {
    tag { id }
    publishDir enabled: false
    label "mm2_pb"

    conda "$projectDir/conf/minimap2.yaml"

    input:
        tuple val(id), file(asm), file(reads)
    
    output:
        tuple val(id), path("${id}.{bam,bam.bai}"), emit: mosdepth
        path "${id}.{bam,bam.bai}", emit: flagstat

    script:
        """
        minimap2 \
            -ax map-hifi \
            -t ${task.cpus} \
            ${asm} \
            ${reads} | \
        samtools sort \
            -u | \
        samtools view \
            -b \
            -o ${id}.bam

        samtools index -@ ${task.cpus} ${id}.bam
        """
}