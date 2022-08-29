process arima_map_filter_combine {
    tag { id_asm }
    publishDir enabled: false
    label "arima_1"

    conda "$projectDir/conf/bwa2.yaml"

    input:
        tuple val(id_asm), 
              file(asm), 
              file(fai), 
              file(bwa_idx),
              val(id_hic),
              file(reads)

    output:
        tuple val(id_asm), file(fai), file("${id_asm}-${id_hic}.combined.bam"), emit: bam
        
    script:
        def cpus = task.cpus/4 // Running background processes with shared resources
        """
        # R1 alignment and filter
        bwa-mem2 mem \
            -t ${cpus} \
            -B 10 \
            ${asm} \
            ${reads[0]} | 
        samtools view -h - |
        filter_five_end.pl |
        samtools view -@ ${cpus} -Sb - > ${id_asm}-${id_hic}_R1.filter.bam || exit 1 &

        # R2 alignment and filter
        bwa-mem2 mem \
            -t ${cpus} \
            -B 10 \
            ${asm} \
            ${reads[1]} | 
        samtools view -h - |
        filter_five_end.pl |
        samtools view -@ ${cpus} -Sb - > ${id_asm}-${id_hic}_R2.filter.bam || exit 1 &

        # Wait for both background processes to finish
        wait

        # Merge output into paired BAM
        two_read_bam_combiner.pl ${id_asm}-${id_hic}_R1.filter.bam ${id_asm}-${id_hic}_R2.filter.bam |
        samtools view -@ ${task.cpus} -Sb > ${id_asm}-${id_hic}.combined.bam || exit 1

        # Remove temporary BAM files to save space
        rm *_R1.filter.bam 
        rm *_R2.filter.bam
        """
}
