process install_cogent3 {
    tag { 'Install Cogent3' }

    input:
        val logical

    output:
        val 'created'
    
    when:
        logical == false

    script:
        """
        pip3 install cogent3
        if [[ \$? == 0 ]]; then
            touch /hpcfs/users/\$LOGNAME/nf-condaEnvs/cogentInstallCheck.ok
        fi
        """

}
