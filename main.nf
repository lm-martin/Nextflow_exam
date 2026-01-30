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
    conda "mafft=7.526"

    input:
        path merged_data

    output:
        path "alignment.fasta"

    script:
        """
        mafft $merged_data > alignment.fasta
        """
}

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
    
    def ch_local_data = channel.fromPath(params.in)
    ch_reference
        .mix(ch_local_data)
        .collect()
        | get_merge_data
        | mafft_aligner
      
}