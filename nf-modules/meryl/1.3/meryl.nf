process meryl {
    tag { hifi.simpleName }
    publishDir enabled: false
    label 'meryl'

    conda "$projectDir/conf/merqury.yaml"

    input:
        file hifi
    
    output:
        path "reads.meryl"

    script:
        """
        meryl count \
            k=21 \
            threads=${task.cpus} \
            memory=50 \
            ${hifi} \
            output reads.meryl
        """
}