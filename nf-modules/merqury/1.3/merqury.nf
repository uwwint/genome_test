// Single assembly
process merqury {
    tag { asm.baseName }
    publishDir "${outdir}/qc/merqury", mode: 'move'
    label 'merqury'

    conda "$projectDir/conf/merqury.yaml"

    input:
        file asm
        file merly_db
        val outdir
    
    output:
        path "*.{ploidy,hist,filt,png,qv,stats,bed,wig}"

    script:
        """
        cp ${projectDir}/bin/spectra-cn.sh \${MERQURY}/eval

        # Merqury on single assembly compared to hifi reads
        merqury.sh ${merly_db} ${asm} ${asm.baseName}-to-hifi
        """
}

// Two haplotypes
process merqury_haplotypes {
    tag { 'Haplotypes' }
    publishDir "${outdir}/post-assembly-qc/merqury", mode: 'copy'
    label 'merqury'

    conda "$projectDir/conf/merqury.yaml"

    input:
        file haps
        file merly_db
        val outdir
    
    output:
        path "*.{ploidy,hist,filt,png,qv,stats,bed,wig}"

    script:
        """
        cp ${projectDir}/bin/spectra-cn.sh \${MERQURY}/eval

        # Merqury on haplotypes
        merqury.sh ${merly_db} ${haps} haplotypes-to-hifi
        """
}