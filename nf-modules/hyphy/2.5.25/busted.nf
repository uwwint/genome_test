process busted {
    tag { 'HyPhy - BUSTED' }
    publishDir "${outdir}/hyphy/busted", mode: 'copy'
    label "parallel_high"

    input:
        tuple file(aln), file(tree)
        val outdir
        val busted_optional

    output:
        file "*.json"
        file "*.log"

    script:
        def opt = busted_optional ?: ''
        """
        parallel -j ${task.cpus} \\
        --joblog parallel_hyphy-BUSTED.log \\
        hyphy busted --alignment {} --tree ${tree} --output BUSTED-{/.}_${tree.baseName}.json ${opt} ::: ${aln}
        """
}