params.input = "./test/test.csv"
params.fantasia_dir = "$HOME/00_software/FantasiaLiteV0"
params.outdir = "results"

include { cpy_fasta, run_fantasia } from './modules/run_FANTASIA.nf'

// Workflow block
workflow {

    ch_samples= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta), row.fasta) }
                        .view()

    ch_fantasia_input = cpy_fasta(ch_samples)
    run_fantasia(ch_fantasia_input)
}
