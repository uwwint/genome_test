process transdecoderLO {
    tag { 'TD: LongOrfs - ' + id }
    publishDir "${outdir}/transdecoder/${id}", mode: 'copy'
    label "parallel_low"

    input:
        tuple val(id), file(transcripts)
        val outdir
    
    output:
        tuple val(id), file(transcripts), file("${id}.gene_trans_map"), file("*"), emit: all
        tuple val(id),  file("longest_orfs.pep"), emit: longstORF

    script:
        """
        get_Trinity_gene_to_trans_map.pl \
            ${transcripts} > ${id}.gene_trans_map
        
        TransDecoder.LongOrfs \
            -t ${transcripts} \
            --gene_trans_map ${id}.gene_trans_map \
            --output_dir \$PWD
        """
}