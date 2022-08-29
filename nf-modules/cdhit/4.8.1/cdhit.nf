process cdhit {
    tag { 'CD-HIT - ' + id }
    publishDir "${outdir}/cdhit/${id}", mode: 'copy'
    label "parallel_low"

    input:
        tuple val(id), file(transcripts)
        val pid
        val outdir
    
    output:
        tuple val(id), path("*.cdhit.fasta"), emit: fasta
        file "*.clstr"

    script:
        """
        cd-hit-est \
            -o ${id}.cdhit.fasta \
            -c ${pid} \
            -i "${transcripts}" \
            -p 1 \
            -d 0 \
            -b 3 \
            -T ${task.cpus}
         """
}