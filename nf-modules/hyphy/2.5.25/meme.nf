process meme {
    tag { 'HyPhy - MEME' }
    publishDir "${outdir}/hyphy/meme", mode: 'copy'
    label "parallel_med"

    input:
        tuple file(aln), file(tree)
        val outdir
        val meme_optional

    output:
        file "*.json"
        file "*.log"

    script:
        def opt = meme_optional ?: ''
        """
        parallel -j ${task.cpus} \\
        --joblog parallel_hyphy-MEME.log \\
        hyphy meme --alignment {} --tree ${tree} --output MEME-{/.}_${tree.baseName}.json ${opt} ::: ${aln}
        """
}