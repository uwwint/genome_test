process pin_hic {
    tag { id }
    publishDir "${outdir}/assembly-scaffold/pin_hic-${id}", mode: 'copy', pattern: "*.{fa,wig,sat,mat,agp}"
    label "pinhic"

    input:
        tuple val(id), 
              file(ctg), 
              file(fai), 
              file(bam)
        val outdir
    
    output:
        tuple val(id), path("${id}.scaffold.fa"), emit: scaffolds
        path "*.{wig,sat,mat,agp}"
        tuple val(id), path("${id}.agp"), emit: juicebox
        
    script:
        """
        pin_hic_it \
		    -O . \
		    -q 20 \
		    -x ${fai} \
		    -r ${ctg} \
		    ${bam} || exit 1

        mv scaffolds_final.fa ${id}.scaffold.fa

        # Convert breaks SAT file into AGP format
        satool agp scaffs.bk.sat > ${id}.agp
        """
}