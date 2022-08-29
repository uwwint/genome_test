process kmc {
    tag { id }
    // publishDir "${outdir}/genome-size/kmc-${id}", mode: 'copy'
    publishDir enabled: false
    label "kmc"

    conda "$projectDir/conf/kmc.yaml"
    
    input:
        tuple val(id), file(fastq)
        val prefix
        val outdir
    
    output:
        tuple val(prefix), path("${prefix}.kmc.histo"), path("${prefix}.{kmc_pre,kmc_suf}"), emit: histo

    script:
        """
        kmc \
            -k31 \
            -t${task.cpus} \
            -m64 \
            -ci2 \
            -cs100000 \
            ${fastq} ${prefix} .
        
        kmc_tools transform \
            ${prefix} \
            histogram \
            ${prefix}.kmc.histo \
            -ci2 \
            -cx100000
        """
}