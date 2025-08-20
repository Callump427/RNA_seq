#!/usr/bin/nextflow

// default reads path
params.reads = "./metadata/Reads/*.fastq.gz"

// Make a channel of FASTQ files, this will be called at the worflow stage
Channel
    .fromPath(params.reads, checkIfExists: true)
    .ifEmpty { error "No FASTQ files found in: ${params.reads}" }
    .set { reads_ch }



process FASTQC {
    cpus 4 // Allocate 4 CPUs for the process
    tag "Current read: ${reads}"

    publishDir "fastqc", mode: 'copy'  // save results in fastqc/
    
    input:
        path reads

    output:
        path "*_fastqc.html", emit: fastqc_html
        path "*_fastqc.zip", emit: fastqc_zip

    script:
    """
    fastqc --outdir . ${reads}
    """
}

process MULTIQC {
    tag "MultiQC report generation"
    publishDir "multiqc", mode: 'copy'  // save results in multiqc/
 

    input:
        path fastqc_zips
    
    output:
        path "multiqc_report.html"
        path "multiqc_data"
    
    script:
    """
    multiqc . -o .
    """
}

workflow {
    // Run FASTQC on the reads
   output = FASTQC(reads_ch)
   MULTIQC(output.fastqc_zip.collect())

}