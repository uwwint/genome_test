process kraken2 {
    tag { id }
    publishDir "${outdir}/kraken2", mode: 'copy'
    label "kraken2"

    conda "$projectDir/conf/kraken2.yaml"

    input:
        tuple val(id), file(reads)
        val krakendb
        val outdir
    
    output:
        tuple val(id), file("${id}_{1,2}.fastq.gz"), emit: unclassified
        path "${id}.report", emit: report
        path "*"

    script:
        """
        kraken2 \
            --db ${krakendb} \
            --threads ${task.cpus} \
            --gzip-compressed \
	        --paired \
            --unclassified-out ${id}#.fastq \
            --classified-out ${id}-classified#.fastq \
            --report ${id}.report \
            --use-names \
            ${reads[0]} ${reads[1]}

        rm .command.log .command.out

        pigz -p ${task.cpus} -9 *.fastq
        """

    stub:
        """
        touch ${id}_1.fastq.gz ${id}_2.fastq.gz
        touch ${id}-classified_1.fastq.gz ${id}-classified_2.fastq.gz
        touch ${id}.report
        """
}