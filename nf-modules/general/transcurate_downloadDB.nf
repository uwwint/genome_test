process downloadDB {
    tag { 'Download Databases' }
    publishDir "${outdir}", mode: 'copy'
    label "singleCore_low"

    input:
        val outdir
    
    output:
        path "databases", emit: database_files

    script:
        """
        wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
        gunzip uniprot_sprot.fasta.gz
        makeblastdb \
            -in uniprot_sprot.fasta \
            -input_type fasta \
            -dbtype prot \
            -parse_seqids

        wget ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz
        gunzip Pfam-A.hmm.gz
        hmmpress Pfam-A.hmm

        mkdir databases
        mv uniprot_sprot.* Pfam* databases
        """
}