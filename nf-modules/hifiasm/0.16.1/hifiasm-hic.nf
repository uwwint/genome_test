process hifiasm_hic {
    tag { prefix }
    publishDir "${outdir}/assembly-contigs/${prefix}", mode: 'copy', pattern: "*.fa"
    publishDir "${outdir}/assembly-contigs/${prefix}", mode: 'move', pattern: "*.{gfa,bed,bin}"
    label "hifiasm"

    conda "$projectDir/conf/hifiasm.yaml"

    input:
        tuple val(id), file(fastq)
        tuple val(id_hic), file(hic)
        val prefix
        val outdir
    
    output:
        path '*'
        path '*.fa', emit: contigs

    script:
        """
        hifiasm \
            -o ${prefix} \
            -t ${task.cpus} \
            --h1 ${hic[0]} \
            --h2 ${hic[1]} \
            ${fastq}

        # Convert GFA outputs to FASTA format
        gfatools gfa2fa -l 80 ${prefix}.hic.hap1.p_ctg.gfa > ${prefix}-hap1.fa
        gfatools gfa2fa -l 80 ${prefix}.hic.hap2.p_ctg.gfa > ${prefix}-hap2.fa
        gfatools gfa2fa -l 80 ${prefix}.hic.p_ctg.gfa > ${prefix}-p_ctg.fa
        """
}
