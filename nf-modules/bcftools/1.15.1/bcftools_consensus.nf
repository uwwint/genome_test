process bcftools_consensus {
    tag { id }
    publishDir "${outdir}/consensus", mode: 'move', pattern: "*.{fa,stats}"
    publishDir "${outdir}/vcf-filtered", mode: 'move', pattern: "*filtered.vcf.gz"
    label "bcftools"

    conda "$projectDir/conf/bcftools.yaml"

    input:
        tuple val(id), file(vcf), file(asm)
        val filteropt
        val viewopt
        val normopt
        val sortopt
        val consensusopt
        val outdir
        
    output:
        path "${id}-consensus.fa"
        path "${id}-consensus.stats"
        path "${id}.filtered.vcf.gz"
        
    script:
        """
        bcftools filter \
            -Ou \
            ${filteropt} \
            ${vcf} |
        bcftools view \
            -Ou \
            ${viewopt} |
        bcftools norm \
            -f ${asm} \
            -Ou \
            ${normopt} |
        bcftools sort \
            -Oz \
            -o ${id}.filtered.vcf.gz
            ${sortopt}

        tabix -p vcf ${id}.filtered.vcf.gz

        bcftools consensus \
            -f ${asm} \
            -o ${id}-consensus.fa \
            ${consensusopt} \
            ${id}.filtered.vcf.gz

        # Keep statistics from consensus
        cp .command.log ${id}-consensus.stats
        """
}
