process genomescope {
    tag { id }
    publishDir "${outdir}/genome-size", mode: 'copy'
    label "gs2"

    conda "$projectDir/conf/genomescope2.yaml"

    input:
        tuple val(id), file(histo), file(db)
        val outdir
    
    output:
        path "genomescope-${id}"


    script:
        """
        genomescope2 \
            --input ${histo} \
            --output genomescope-${id} \
            --ploidy 2 \
            --kmer_length 31 \
            --name_prefix ${id} \
            --verbose
        """
}