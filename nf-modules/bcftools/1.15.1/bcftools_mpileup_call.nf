process bcftools_mpileup_call {
    tag { id }
    publishDir "${outdir}/vcf", mode: 'copy', pattern: '*.vcf.gz'
    label "bcftools"

    conda "$projectDir/conf/bcftools.yaml"

    input:
        tuple val(id), file(bam), file(asm)
        val mapq
        val baseq
        val ploidy
        val mpileupopt
        val callopt
        val outdir

    output:
        tuple val(id), path("${id}.vcf.gz"), file(asm)
        
    script:
        """
        bcftools mpileup \
            -q ${mapq} \
            -Q ${baseq} \
            -Ou \
            -f ${asm} ${bam} ${mpileupopt} |
        bcftools call \
            -c \
            --ploidy ${ploidy} \
            -Oz \
            -o ${id}.vcf.gz \
            ${callopt}
        """
}


