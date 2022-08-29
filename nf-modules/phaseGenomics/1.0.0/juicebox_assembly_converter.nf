process juicebox_assembly_converter {
    tag { id }
    publishDir "${outdir}/assembly-manual/${scafftool}", mode: 'copy'
    label "jb2fa"

    conda "$projectDir/conf/seqkit.yaml"

    input:
        tuple val(id), 
              val(asm_type),
              val(scafftool),
              file(assembly),
              file(ctg)
        val len
        val prefix
        val outdir
    
    output:
        tuple val("${prefix}-${asm_type}"), 
              path("${prefix}-${asm_type}-${scafftool}.fa"), emit: manual
        path "*"
        
    script:
        """
        # Convert Juicebox '.assembly' file to fasta
        python ${projectDir}/bin/juicebox_assembly_converter.py \
            -a ${assembly} \
            -f ${ctg} \
            -p ${id}
        
        # Sort long -> short
        seqkit sort -l -r -w 100 ${id}.fasta > ${id}.sort.fasta

        # Store original headers in file
        echo "# Original Juicebox headers produced by 'juicebox_assembly_converter.py in the same order as the cleaned output file" > ${id}.headers
        grep "^>" ${id}.sort.fasta | sed 's/>//' >> ${id}.headers

        # Filter by specified length
        seqkit seq --min-len ${len} -w 100 ${id}.sort.fasta > ${id}.length.fasta

        # Rename to 'scaffold_{nr}'
        seqkit replace -p '.+' -r 'scaffold_{nr}' ${id}.length.fasta > ${prefix}-${asm_type}-${scafftool}.fa

        # Remove intermediate files
        rm -v ${id}.fasta ${id}.sort.fasta ${id}.length.fasta
        """
}
