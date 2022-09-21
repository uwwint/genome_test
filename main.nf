#!/usr/bin/env nextflow

/*
################################################################################
Nextflow pipeline
################################################################################
*/

nextflow.enable.dsl = 2

/*
################################################################################
Check inputs
################################################################################
*/

// Validate/Help page
 WorkflowMain.initialise(params, workflow, log)

/*
################################################################################
Main workflow
################################################################################
*/

include {QC} from './nf-workflows/qc'
include {ASSEMBLY} from "./nf-workflows/assembly"
include {ASSEMBLY_ASSESSMENT} from './nf-workflows/assembly_assessment'
include {ALIGNMENT} from './nf-workflows/alignment'
include {CONSENSUS} from './nf-workflows/consensus'
include {CODEML} from './nf-workflows/codeml'

workflow {
    switch(params.pipeline) {
        case 'qc':
            QC()
            break;
        case 'assembly':
            ASSEMBLY()
            break;
        case 'assembly_assessment':
            ASSEMBLY_ASSESSMENT()
            break;
        case 'alignment':
            ALIGNMENT()
            break;
        case 'consensus':
            CONSENSUS()
            break;
        case 'codeml':
            CODEML()
            break;
    }
}