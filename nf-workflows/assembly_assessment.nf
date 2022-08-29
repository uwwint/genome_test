/*
Genome assembly assessment pipeline
    * PhaseGenomics: Convert Juicebox-edited '.assembly' files to sequence files
    * TGS-GapCloser: Close gaps with HiFi data
    * Flagstat: HiFi alignment statistics
    * MosDepth: Hifi coverage statistics
    * Meryl: K-mer composition assessment
    * BUSCO: Gene content assessment on gap-filled assembly
    * QUAST: Simple assembly metrics

NOTE: This pipeline assumes the input comes from the 'assembly' pipeline.
*/

include { juicebox_assembly_converter } from '../nf-modules/phaseGenomics/1.0.0/juicebox_assembly_converter'
include { tgsgapcloser } from '../nf-modules/tgs-gapcloser/1.1.1/tgsgapcloser'
include { busco as busco_tgs } from '../nf-modules/busco/5.2.2/busco'
include { busco_plot } from '../nf-modules/busco/5.2.2/busco_plot'
include { quast } from '../nf-modules/quast/5.0.2/quast'
include { meryl } from '../nf-modules/meryl/1.3/meryl'
include { merqury } from '../nf-modules/merqury/1.3/merqury'
include { merqury_haplotypes } from '../nf-modules/merqury/1.3/merqury'
include { mosdepth } from '../nf-modules/mosdepth/0.3.3/mosdepth'
include { minimap2_pb_hifi } from '../nf-modules/minimap2/2.24/minimap2_pb_hifi'
include { flagstat } from '../nf-modules/samtools/1.15/flagstat'

workflow ASSEMBLY_ASSESSMENT {
    main:

        // Strings to match on - dependent on naming from 'assembly' pipeline!
        switch(params.assembly) {
            case 'all':
                pattern = ['p_ctg', 'hap1', 'hap2' ]
                break;
            case 'primary':
                pattern = [ 'p_ctg' ]
                break;
            case 'haplotype1':
                pattern = [ 'hap1' ]
                break;
            case 'haplotype2':
                pattern = [ 'hap2' ]
                break;
            case 'haplotypes':
                pattern = [ 'hap1' ,'hap2' ]
                break;
        }

        // Get Juicer-edited assembly files
        // [ basename, assembly type, scaffolding tool, [file path] ]
        Channel
            .fromFilePairs(
                [params.reviewed_assembly.path, params.reviewed_assembly.pattern].join('/'),
                size: params.reviewed_assembly.nfiles
            )
            .ifEmpty { exit 1, "Can't find Juicer-edited assembly files"}
            .filter{
                pattern.any { val -> it[0].contains(val)}
            }
            .map { juice -> 
                asm_type = pattern.find { val -> juice[0].contains(val) } // Which assembly we're currently dealing with

                /*
                This expects that users don't go messing with filenames from the 'assembly' pipeline!
                The output format for Juicebox assembly files is: <out_prefix>-<asm_type>-<scafftool> e.g. <samplename-draft>-<p_ctg>-<pin_hic>.assembly
                I'm splitting the basename of the file (field [0]) on the assembly type (p_ctg,hap1,hap2). This should get around users using
                all sorts of separators in their file names.
                The assembly type is determined based on the string match above
                */
                str = juice[0].split('-' + asm_type + '-') // [ out_prefix, scaffold_tool ]

                // Return tuple: [ basename, asm_type, scaff_tool, [filepath] ]
                // I re-attatch the assembly type to the 'basename' as it is removed in the '.split' step above
                return tuple([str[0], asm_type].join('-'), asm_type, str[1], juice[1])
                
            }
            .set { ch_juicer_assembly }

        // Cleaned HiFi files: [ basename, [filepath] ]
        Channel
            .fromPath(
                [params.filtered_hifi.path, params.filtered_hifi.pattern].join('/'),
            )
            .ifEmpty { exit 1, "Can't find filtered HiFi datasets"}
            .branch {
                fastq: it.baseName.contains('filt')
                fasta: it.baseName.contains('fasta')
            }
            .set { ch_hifi }

        // Contig data channel: Filter based on assembly type
        // [ basename, [filepath] ]
        Channel
            .fromFilePairs(
                [params.contig.path, params.contig.pattern].join('/'),
                size: params.reviewed_assembly.nfiles
            )
            .ifEmpty { exit 1, "Can't find Hifiasm contig files"}
            .filter{
                pattern.any { val -> it[0].contains(val)}
            }
            .set { ch_contigs }

        // Minimum scaffold length
        length = params.containsKey("length") ? params.length : 0

        // Convert juicebox-ssembly files to fasta using PhaseGenomics scripts
        ch_juicer_assembly.join(ch_contigs).set { ch_assembly_ctg } // [ basename, asm_type, scafftool, [review.assembly], [contig.fa] ]
        juicebox_assembly_converter(ch_assembly_ctg, length, params.out_prefix, params.outdir)

        // TGS-GapCloser: Gap closing
        juicebox_assembly_converter.out.manual.combine(ch_hifi.fasta).set { ch_scaf_hifi }
        tgsgapcloser(ch_scaf_hifi, params.outdir)

        // Align reads to assemblie(s)
        tgsgapcloser.out.asm.combine(ch_hifi.fastq).set { ch_asm_hifi }
        minimap2_pb_hifi(ch_asm_hifi)

        // Alignment statistics
        flagstat(minimap2_pb_hifi.out.flagstat, params.outdir)
        
        // Mosdepth: HIFI alignment and coverage
        mosdepth(minimap2_pb_hifi.out.mosdepth, params.outdir)

        // Branch into haplotype/primary channels
        tgsgapcloser.out.asm_fa
            .branch{ val ->
                primary: val.baseName.contains('-p_ctg')
                haplotype: val.baseName.find('-hap?')
            }
            .set {ch_asm}

        // Merqury: K-mer assessment
        meryl(ch_hifi.fastq)
        switch(params.assembly) {
            case 'all':
                merqury(ch_asm.primary, meryl.out, params.outdir)
                merqury_haplotypes(ch_asm.haplotype.collect(), meryl.out, params.outdir)
                break;
            case 'primary':
                merqury(ch_asm.primary, meryl.out, params.outdir)
                break;
            case 'haplotype1':
                merqury(ch_asm.haplotype, meryl.out, params.outdir)
                break;
            case 'haplotype2':
                merqury(ch_asm.haplotype, meryl.out, params.outdir)
                break;
            case 'haplotypes':
                merqury_haplotypes(ch_asm.haplotype.collect(), meryl.out, params.outdir)
                break;
        }

        // BUSCO: Scaffold haplotype assemblies
        busco_tgs(tgsgapcloser.out.asm, params.busco_db, 'gapfilled', params.outdir)

        // QUAST - scaffold haplotype assemblies
        quast(tgsgapcloser.out.asm_fa.collect(), params.outdir)

        // Plot BUSCO results
        def pth = new File(params.outdir + '/post-assembly-qc/busco')
        if(pth.exists()) {
            Channel
                .fromPath(params.outdir + '/post-assembly-qc/busco/**/short_summary*', maxDepth: 1)
                .set { ch_busco_existing }

        } else {
            Channel.empty().set { ch_busco_existing }
        }

        // Join existing busco results with TGS-busco results
        busco_tgs.out.summary
            .concat(ch_busco_existing)
            .collect()
            .set { ch_busco_short }

        busco_plot(ch_busco_short, params.outdir)
}