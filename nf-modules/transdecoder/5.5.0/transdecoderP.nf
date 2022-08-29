process transdecoderP {
    tag { 'TD: Predict - ' + id }
    publishDir "${outdir}/transdecoder/${id}", mode: 'copy'
    label "parallel_low"

    input:
        tuple val(id), file(transcripts), file(genetransmap), file(files), file(blast), file(hmmer)
        val outdir
    
    output:
        tuple val(id), file(transcripts), file("*.gff3"), emit: complete
        file "${id}*.{gff3,bed,pep,cds}"

    script:
        """
        TransDecoder.Predict \
            -t ${transcripts} \
            --retain_blastp_hits ${blast} \
            --retain_pfam_hits ${hmmer} \
            --single_best_only \
            --output_dir \$PWD
        """
}

