process assembly_visualiser {
    tag { id }
    publishDir "${outdir}/assembly-scaffold/${scafftool}-${id}/juicebox-files", mode: 'copy'
    label "juicertools"

    conda "$projectDir/conf/3ddna.yaml"

    input:
        tuple val(id), file(agp), file(links)
        val scafftool
        val outdir
    
    output:
        tuple path("${id}-${scafftool}.assembly"), path("${id}-${scafftool}.hic")
        
    script:
        """
        # the sorting step in the visualiser script uses a decent amount of memory
        export TMPDIR=\$PWD

        # Convert AGP file to '.assembly' file used by Juicer/Juicebox etc...
        python ${projectDir}/bin/agp2assembly.py ${agp} ${id}-${scafftool}.assembly
        
        ${projectDir}/bin/run-assembly-visualizer.sh ${id}-${scafftool}.assembly ${links}

        rm -v temp.${id}-${scafftool}.asm_mnd.txt
        """
}
