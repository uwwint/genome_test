process kat_compare {
    tag { 'KAT' + id_assembly }
    publishDir "${outdir}/genome-completeness/${id_assembly}-${id_hifi}", mode: 'copy'
    label "highmem_multiCore_med"

    conda "$projectDir/conf/kat.yaml"

    input:
        tuple val(id_assembly), file(fasta), val(id_hifi), file(hifi)
        val outdir
    
    output:
        path "hifi-to-assembly.{hist,png,json,stats}"

    script:
        """
        kat comp \
            --output_prefix hifi-to-assembly
            --threads ${task.cpus} \
            --mer_len 31 \
            --output_hists \
            --verbose \
            --hash_size_1 10000000000 \
            --hash_size_2 10000000000 \
            ${hifi} ${fasta}
        """
}