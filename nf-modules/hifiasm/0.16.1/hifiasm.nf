process hifiasm {
    tag { prefix }
    publishDir "${outdir}/assembly-contigs/${prefix}", mode: 'copy'
    label "hifiasm"

    conda "$projectDir/conf/hifiasm.yaml"

    input:
        tuple val(id), file(fastq)
        val prefix
        val outdir
    
    output:
        path "*"
        tuple val(prefix), file("${prefix}.fa"), emit: contigs

    script:
        """
        hifiasm \
            -o ${prefix} \
            -t ${task.cpus}
            ${fastq}
        
        gfatools gfa2fa -l 80 ${prefix}.p_ctg.gfa > ${prefix}.fa
        """
}