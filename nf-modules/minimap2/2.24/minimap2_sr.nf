process minimap2_sr {
    tag { id }
    publishDir enabled: false
    label "mm2_pb"

    conda "$projectDir/conf/minimap2.yaml"

    input:
        tuple val(id),
              file(reads),
              file(asm)
        val platform
        val mapq
    
    output:
        tuple val(id), path("${id}.raw.bam")

    script:
        """
        minimap2 \
            -ax sr \
            -t ${task.cpus} \
            -R \"@RG\\tID:${id}\\tSM:${id}\\tPL:${platform}\\tLB:LIB.${id}\" \
            ${asm} \
            ${reads} | \
        samtools sort -u | \
        samtools view \
            --bam \
            --require-flags 3 \
            --exclude-flags 4 \
            --min-MQ ${mapq} \
            -o ${id}.raw.bam 
        """
}