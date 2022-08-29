process codeml {
    tag { id }
    publishDir "${outdir}/codeml/${id}", mode: 'copy'
    conda "$projectDir/conf/ete3.yaml"
    label 'ete'

    input:
        tuple val(id), file(alignment), file(tree)
        val models
        val outdir

    output:
        file "*" // Should be output directories
        file "results_codeml.txt" // Should have a summary of the run

    script:
        """
        ete3 evol \
            --alg ${alignment} \
            -t ${tree} \
            --models ${models} \
            --cpu ${task.cpus} \
            -o \${PWD} \
            -v 1
        
        cp .command.out results_codeml.txt
        """        
}