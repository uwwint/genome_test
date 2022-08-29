process hmmer {
    tag { 'HMMER - ' + id }
    publishDir "${outdir}/transdecoder/${id}", mode: 'copy'
    label "parallel_low"

    input:
        tuple val(id), file(pep)
        path database
        val outdir
    
    output:
        tuple val(id), file("${id}.domtblout")

    script:
        """
        hmmscan \
            --cpu ${task.cpus} \
            --domtblout ${id}.domtblout \
            ${database}/Pfam-A.hmm \
            ${pep}
        """
}