// Documentation

params.help = null

def usage() {
    log.info"""

DESCRIPTION
This pipeline handles only fasta files.
It download a references genome seq from SRA and uses local stored data to perform
an aligment cleanup the alignment and report a final alignment.aln and html file from 
trimal.
Reports are push out to a default folder report

SYNOPSIS
nextflow run main.nf [options]
bash line: nextflow run main.nf  
run from github: nextflow run lm-martin/Nextflow_exam

OPTIONS
--accession :Enter accession number to override the default value. Default M21012

--in :Provide a file path or a glob pattern to override the default value, 
    e.g., "data/<filename.fasta>" or "data/<filename.fa>" 
    or "data/*.fasta" or "data/*.fa". default "data/*.fasta"

-profile apple_silicon :Include this option if you run this pipline on macOS
"""
}

// _______________________________
//         Parameters
// _______________________________

params.accession = "M21012" //set to default
params.in = "data/*.fasta"  //set to default

// _______________________________
//         Processes
// _______________________________

// download the reference genome
process ref_get {
    conda "bioconda::entrez-direct=24.0"
    //publishDir "data"

    input:
        val accession

    output:
        path "${accession}.fasta"

    script:
        """
        esearch -db nucleotide -query "$accession" \\
        | efetch -format fasta > "${accession}.fasta"
        """
}

// get merge input data
process get_merge_data {

    input:
        path fasta_files
        

    output:
        path "merged_data.fasta", emit: merged_file

    script:
        """
        cat ${fasta_files} > merged_data.fasta
        """
}

// aligning fasta seqs
process mafft_aligner {
    conda "mafft=7.525"

    input:
        path merged_data

    output:
        path "alignment.aln", emit: alignment_raw

    script:
        """
        mafft --clustalout $merged_data > alignment.aln
        """
}

// cleaning alignment
process trimal_cleanup {
    conda "trimal=1.5.0"
    publishDir "reports"

    input:
        path alignment_raw_data

    output:
        path "alignment_clean.fasta", emit: alignment_final
        path "alignment_report.html", emit: html_report

    script:
        """
        trimal -in $alignment_raw_data \\
        -out alignment_clean.fasta \\
        -htmlout alignment_report.html \\
        -automated1
        """
}

// _______________________________
//         Workflow
// _______________________________

workflow {
    if (params.help) {
    usage()
    exit 0
  }

    if (params.in == null) {
        println("Missing input data")
        exit 1
    }

    def ch_reference = ref_get(params.accession)
        //| view
    
    def ch_local_data = channel.fromPath(params.in)
    ch_reference
        .mix(ch_local_data)
        .collect()
        | get_merge_data
        | mafft_aligner
        | trimal_cleanup
}
