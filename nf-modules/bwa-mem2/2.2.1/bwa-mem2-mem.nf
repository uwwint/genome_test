process bwa_mem2_mem {
    tag { id }
    publishDir enabled: false // Don't need big bam file saved
    label "bwa"

    conda "$projectDir/conf/bwa2.yaml"

    input:
        tuple val(id), 
              file(reads),
              file(asm),
              file(fai),
              file(idx)
        val platform
        val mapq
    
    output:
        tuple val(id), path("${id}.raw.bam")
        
    script:
        """
        # Align reads
        bwa-mem2 mem \
		    -t ${task.cpus} \
            -R \"@RG\\tID:${id}\\tSM:${id}\\tPL:${platform}\\tLB:LIB.${id}\" \
		    ${asm} \
		    ${reads} |
        samtools sort -u |
        samtools view \
            --bam \
            --require-flags 3 \
            --exclude-flags 4 \
            --min-MQ ${mapq} \
            -o ${id}.raw.bam
        """
}
