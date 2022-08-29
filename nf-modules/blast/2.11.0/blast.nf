process blast {
    tag { 'BLAST - ' + id }
    publishDir "${outdir}/transdecoder/${id}", mode: 'copy'
    label "parallel_low"

    input:
        tuple val(id), file(pep)
        path database
        val outdir
    
    output:
        tuple val(id), file("${id}.outfmt6")

    script:
        """
        blastp \
            -query ${pep}  \
            -db ${database}/uniprot_sprot.fasta  \
            -max_target_seqs 1 \
            -outfmt 6 \
            -evalue 1e-5 \
            -num_threads ${task.cpus} > ${id}.outfmt6
        """
}