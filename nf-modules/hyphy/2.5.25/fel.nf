process fel {
    tag { 'HyPhy - FEL' }
    publishDir "${outdir}/hyphy/fel", mode: 'copy'
    label "parallel_med"

    input:
        tuple file(aln), file(tree)
        val outdir
        val fel_optional

    output:
        file "*.json"
        file "*.log"

    script:
        def opt = fel_optional ?: ''
        """
        parallel -j ${task.cpus} \\
        --joblog parallel_hyphy-FEL.log \\
        hyphy fel --alignment {} --tree ${tree} --output FEL-{/.}_${tree.baseName}.json ${opt} ::: ${aln}
        """
}