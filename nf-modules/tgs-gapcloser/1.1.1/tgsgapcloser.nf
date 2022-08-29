process tgsgapcloser {
    tag { id }
    publishDir "${outdir}/assembly-gapClosed/${id}", mode: 'copy'
    label "tgs"

    conda "$projectDir/conf/tgsgapcloser.yaml"

    input:
        tuple val(id), file(asm), file(hifi)
        val outdir
    
    output:
        tuple val(id), path("${id}.fa"), emit: asm
        path "${id}.fa", emit: asm_fa
        path "*"

    script:
        """
        # Actual gap-closing software
        TGSSEQSPLIT=\$(dirname \$(which tgsgapcloser))/tgsgapcloserbin/tgsseqsplit
        TGSGAPCLOSER=\$(dirname \$(which tgsgapcloser))/tgsgapcloserbin/tgsgapcloser
        TGSSEQGEN=\$(dirname \$(which tgsgapcloser))/tgsgapcloserbin/tgsseqgen

        # Split sequences
        \${TGSSEQSPLIT} \
            --input_scaff ${asm} \
            --prefix ${id} || exit 1 

        # Identical command to TGS-GapCloser
        minimap2 \
            -x map-hifi \
            -t ${task.cpus} \
            -o ${id}.fill.paf \
            ${hifi} ${id}.contig || exit 1
        
        # Run the GapClosing tool
        \${TGSGAPCLOSER} \
            --ont_reads_a ${hifi} \
            --contig2ont_paf ${id}.fill.paf \
            --min_match=200 \
            --min_idy=0.2 \
            --prefix ${id} \
            --use_gapsize_check 1>${id}.fill.log  2>&1|| exit 1
        
        # Generate output sequences
        \${TGSSEQGEN} \
            --prefix ${id} 1>${id}.i2s.log 2>&1 || exit 1

        # Rename the output file
        mv ${id}.scaff_seqs ${id}.fa
        """
}

/*
This is the original code. I'm testing to see if I can gap close using the latest version
of minimap2 which has pacbio-hifi support. Plust, it might be a bit faster...
        EX=\$(which tgsgapcloser)
        sed -i 's/MINIMAP2_PARAM=\" -x ava-pb \"/MINIMAP2_PARAM=\" -x asm20 \"/' \${EX}
        
        tgsgapcloser \
            --scaff ${asm} \
            --reads ${hifi} \
            --output ${id}-tgs \
            --ne \
            --tgstype pb \
            --thread ${task.cpus}

        mv ${id}-tgs.scaff_seqs ${id}.fa
*/