// Import generic module functions
include { saveFiles; getProcessName } from './functions'

params.options = [:]

process GTF2BED {
    tag "$gtf"
    label 'process_low'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'genome', meta:[:], publish_by_meta:[]) }

    conda (params.enable_conda ? "conda-forge::perl=5.26.2" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/perl:5.26.2"
    } else {
        container "quay.io/biocontainers/perl:5.26.2"
    }

    input:
    path gtf

    output:
    path '*.bed'       , emit: bed
    path "versions.yml", emit: versions

    script: // This script is bundled with the pipeline, in nf-core/chipseq/bin/
    """
    gtf2bed \\
        $gtf \\
        > ${gtf.baseName}.bed

    cat <<-END_VERSIONS > versions.yml
    ${getProcessName(task.process)}:
        perl: \$(echo \$(perl --version 2>&1) | sed 's/.*v\\(.*\\)) built.*/\\1/')
    END_VERSIONS
    """
}
