process matlock_bam2 {
    tag { bam.simpleName }
    publishDir enabled: false
    label "bam2mnd"

    conda "$projectDir/conf/3ddna.yaml"

    input:
        tuple val(id), file(bam)
    
    output:
        tuple val(id), path("${id}.sorted.links.txt")
        
    script:
        """
        matlock bam2 juicer ${bam} ${id}.links.txt || exit 1
        sort -T \$PWD --parallel=${task.cpus} -k2,2 -k6,6 ${id}.links.txt > ${id}.sorted.links.txt || exit 1
        rm -v ${id}.links.txt
        """
}
