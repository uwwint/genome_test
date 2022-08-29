process fubar {
    tag { 'HyPhy - FUBAR' }
    publishDir "${outdir}/hyphy/fubar", mode: 'copy'
    label "parallel_med"

    input:
        tuple file(aln), file(tree)
        val outdir
        val fubar_optional

    output:
        file "*.json"
        file "*.log"

    script:
        def opt = fubar_optional ?: ''
        """
        parallel -j ${task.cpus} \\
        --joblog parallel_hyphy-FUBAR.log \\
        hyphy fubar --alignment {} --tree ${tree} --output FUBAR-{/.}_${tree.baseName}.json ${opt} ::: ${aln}
        """
}