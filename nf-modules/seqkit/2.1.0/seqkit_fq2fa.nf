process seqkit_fq2fa {
    tag { id }
    publishDir "${outdir}/adapter-removed-reads", mode: 'move'
    label "seqkit_fq2fa"

    conda "$projectDir/conf/seqkit.yaml"

    input:
        tuple val(id), file(hifi)
        val outdir
    
    output:
        path "${id}.fasta.gz"

    script:
        def cpus = task.cpus/2
        """
        seqkit fq2fa -w 80 -t dna -j ${cpus} ${hifi} | bgzip -l 9 -@ ${cpus} > ${id}.fasta.gz
        """
}