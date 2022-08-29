process gblocks {
    tag { 'Gblocks' }
    publishDir "${outdir}/clean_alignments", mode: 'copy'
    label "parallel_low"

    input:
        file aln
        val outdir
        val seq_type
        val gblocks_args

    output:
        file "*_gb.fasta"
        file "*"

    script:
        def opt_args = gblocks_args ?: ''
        """
        parallel -j ${task.cpus} \\
        --joblog parallel_gblocks.log \\
        "Gblocks {} -t=${seq_type} ${opt_args}; mv {/}-gb {/.}_gb.fasta" ::: ${aln}
        """

}