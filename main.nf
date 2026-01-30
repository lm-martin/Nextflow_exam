/*
--accession :Enter accession number to override the default value. Default M21012
--in :Provide a file path or a glob pattern, e.g., "data/<filename.fasta>" or 
     "data/<filename.fa>" or "data/*.fasta" or "data/*.fa"
--profile apple_silicon :Include this option if you run this pipline on macOS
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
process ref_get {
    conda "bioconda::entrez-direct=24.0"

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
        path "merged_data.fasta"
    script:
        """
        cat ${fasta_files} > merged_data.fasta
        """
}

// // aligning fasta seqs
// process mafft_aligner {
//     input:

//     output:

//     script:
// }

// // cleaning alignment
// process trimal_cleanup {
//     input:

//     output:

//     script:
// }

//

// _______________________________
//         Workflow
// _______________________________

workflow {
    if (params.in == null) {
        println("Missing input data")
        exit 1
    }

    //println("$params.accession, $params.in")

    def ch_reference = ref_get(params.accession)
        //| view
    
    def ch_merge_data = channel.fromPath(params.in)
    .collect()
        | get_merge_data
        
}