/*
--accession Enter accession number to override the default value. Default M21012
--in Provide a file path or a glob pattern, e.g., "data/<filename.fasta>" or 
     "data/<filename.fa>" or "data/*.fasta" or "data/*.fa"
--profile apple_silicon Include this option if you run this pipline on macOS
*/

// _______________________________
//         Parameters
// _______________________________

params.accession = "M21012" //set to default
params.in = null

// _______________________________
//         Processes
// _______________________________

// download the reference genome
process ref_get{
    input:

    output:

    script:
        
}

// get merge input data
process get_merge_data{
    input:

    output:

    script:
        
}

// aligning fasta seqs
process mafft_aligner{
    input:

    output:

    script:
}

// cleaning alignment
process trimal_cleanup{
    input:

    output:

    script:
}

//

// _______________________________
//         Workflow
// _______________________________

workflow {
    if (params.in == null) {
        println("Missing input data")
        exit 1
    }

    println("$params.accession, $params.in")

    
}