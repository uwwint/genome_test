process gffread {
    tag { 'Gffread - ' + id }
    publishDir "${outdir}/completeORF", mode: 'copy'
    label "parallel_low"

    input:
        tuple val(id), file(transcripts), file(gff3)
        val outdir
    
    output:
        file "${id}.completeORF.{cds,pep}"

    script:
        """
        gffread \
            ${gff3} \
            -g ${transcripts}
            -J \
            -x \
            -o ${id}.completeORF.cds

        gffread \
            ${gff3} \
            -g ${transcripts}
            -J \
            -y \
            -o ${id}.completeORF.pep
        """
}