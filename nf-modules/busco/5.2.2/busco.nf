process busco {
    tag { "${id}_${stage}" }
    publishDir "${outdir}/qc/busco", mode: 'copy'
    label "busco"

    conda "$projectDir/conf/busco.yaml"

    input:
        tuple val(id), file(fasta)
        val buscoDB
        val stage
        val outdir
    
    output:
        path "${stage}-${id}"
        path "${stage}-${id}/short_summary*", emit: summary

    script:
        """
        ulimit -u 100000

        busco \
            -i ${fasta} \
            -o ${stage}-${id} \
            -m geno \
            -l ${buscoDB} \
            --cpu ${task.cpus} \
            --metaeuk_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
            --metaeuk_rerun_parameters="--disk-space-limit=10G,--remove-tmp-files=1" \
            --out_path \$PWD \
            --tar \
            --offline
        """
}