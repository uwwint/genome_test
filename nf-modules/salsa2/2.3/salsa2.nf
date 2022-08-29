process salsa2 {
    tag { id }
    publishDir "${outdir}/assembly-scaffold/salsa2-${id}", mode: 'copy'
    label "salsa2"

    conda "$projectDir/conf/salsa2.yaml"

    input:
        tuple val(id), 
              file(ctg), 
              file(fai), 
              file(bam)
        val outdir
    
    output:
        tuple val(id), file("${id}.scaffold.fa"), emit: scaffolds
        tuple val(id), path("${id}.agp"), emit: juicebox
        
    script:
        """
        bedtools bamtobed -i ${bam} > ${bam.baseName}.bed
        run_pipeline.py \
            -a ${ctg} \
            -l ${fai} \
            -b ${bam.baseName}.bed \
            -o salsa-out \
            -e 'GATC,GANTC,CTNAG,TTAA' \
            -m yes || exit 1

        rm ${bam.baseName}.bed
        cp salsa-out/scaffolds_FINAL* \$PWD

        # Rename files
        mv scaffolds_FINAL.fasta ${id}.scaffold.fa
        mv scaffolds_FINAL.agp ${id}.agp
        """
}
