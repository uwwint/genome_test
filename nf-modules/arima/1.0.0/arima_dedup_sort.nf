process arima_dedup_sort {
    tag { id }
    publishDir enabled: false
    label "arima_2"

    conda "$projectDir/conf/sort_dedup.yaml"

    input:
        tuple val(id), 
              file(fai), 
              file(bam)

    output:
        tuple val(id), file(fai), file("${id}.hic.bam"), emit: bam
        tuple val(id), file("${id}.hic.bam"), emit: hic_to_ctg_bam
        
    script:
        """
        # Sort input bam
        sambamba sort \
            --tmpdir=\$PWD \
            -o ${id}.sort.bam \
            -t ${task.cpus} \
            ${bam} || exit 1

        # Deduplicate BAM ---
        sambamba markdup \
            --remove-duplicates \
            -t ${task.cpus} \
            --tmpdir=\$PWD \
            ${id}.sort.bam \
            ${id}.dedup.bam || exit 1

        rm ${id}.sort.bam

        # Sort by read ID ---
        samtools sort \
            -@ ${task.cpus} \
            -n \
            -T \$PWD/sort-temp \
            -m 2G \
            -O BAM \
            -o ${id}.hic.bam \
            ${id}.dedup.bam || exit 1

        rm ${id}.dedup.bam
        """
}
