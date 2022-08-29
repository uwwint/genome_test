process runMSA {
    tag { 'MSA: ' + aligner }
    publishDir "${outdir}/alignment_out", mode: 'copy'
    label "parallel_low"

    input:
        val cogent_check
        file peptides
        val ids
        val outdir
        val aligner
        val aligner_args
    
    output:
        tuple val(ids), path("*_msa.fasta"), emit: alignments
        file "*"

    script:
        def opt = aligner_args ?: ''
        if(aligner == 'mafft'){
        """
            parallel -j ${task.cpus} \\
            --joblog parallel_msa.log \\
            "mafft --thread 1 ${opt} {} > {/.}_msa.fasta" ::: ${peptides}
        """
        } else if(aligner == 'tcoffee') {
            """
            parallel -j ${task.cpus} \\
            --joblog parallel_msa.log \\
            "t_coffee -thread 1 ${opt} -in {} -output=fasta_aln; mv {/.}.fasta_aln {/.}_msa. fasta" ::: ${peptides}
            """
        } else if(aligner == 'clustal') {
            """
            parallel -j ${task.cpus} \\
            --joblog parallel_msa.log \\
            "clustalo --threads=1 ${opt} -i {} -o {/.}_msa.fasta" ::: ${peptides}
            """
        } else if(aligner == 'muscle') {
            """
            parallel -j ${task.cpus} \\
            --joblog parallel_msa.log \\
            "muscle -in {} -out {/.}_msa.fasta ${opt}" ::: ${peptides}
            """
        }
}