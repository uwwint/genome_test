process fastp_paired {
    tag { id }
    publishDir "${outdir}/fastp", mode: 'copy'
    label "fastp"

    conda "$projectDir/conf/fastp.yaml"

    input:
        tuple val(id), file(reads)
        val platform
        val bqp
        val nbl
        val aq
        val lr
        val outdir
    
    output:
        path "${id}.fastp.json", emit: json
        path "*"

    script:
        def mgi = platform == 'mgi' ? '--fix_mgi_id' : ''
        """
        fastp \
            --in1 ${reads[0]} \
            --in2 ${reads[1]} \
            --out1 ${id}_R1.fastq.gz \
            --out2 ${id}_R2.fastq.gz \
            --unpaired1 ${id}_R1.unpaired \
            --unpaired2 ${id}_R2.unpaired \
            --detect_adapter_for_pe \
            --qualified_quality_phred ${bqp} \
            --n_base_limit ${nbl} \
            --average_qual ${aq} \
            --length_required ${lr} \
            --json ${id}.fastp.json \
            --html ${id}.fastp.html \
            --thread ${task.cpus} \
            ${mgi}
        
        pigz -p ${task.cpus} -9 *.unpaired
        """
    
    stub:
        """
        touch ${id}_R1.fastq.gz ${id}_R2.fastq.gz ${id}_R1.unpaired.gz ${id}_R2.unpaired.gz ${id}-fastp.json ${id}-fastp.html
        """
}