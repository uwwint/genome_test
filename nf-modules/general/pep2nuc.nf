process pep2nuc {
    tag { "Peptide to nucleotide" }
    publishDir "${outdir}/nucleotide_msa", mode: 'copy'
    label "parallel_low"

    input:
        val ids
        file aln
        file nuc
        val outdir

    output:
        path "*_translated.fasta", emit: translated
        file "parallel_p2n.log"
        file "*"

    script:
        """
        parallel -j ${task.cpus} \\
        --joblog parallel_p2n.log \\
        --link \\
        pep2nuc.py \\
        -n {1} \\
        -p {2} \\
        -i {3} ::: ${nuc} ::: ${aln} ::: ${ids}
        """
}