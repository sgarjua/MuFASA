params.input = "./test/test.csv"
params.fantasia_dir = "$HOME/00_software/FantasiaLiteV0"
params.outdir = "results"
params.dbsprot = "/data/shared_dbs/swissprot/uniprot_sprot_r2025_01.dmnd"
params.dbtrembl = "/data/shared_dbs/swissprot/uniprot_trembl_r2025_01.dmnd"

include { cpy_fasta } from './modules/run_FANTASIA.nf'
include { run_fantasia } from './modules/run_FANTASIA.nf'

process run_diamond {

    publishDir "${params.outdir}/${species}", mode: 'copy'

    input:
        tuple val(species), path(fasta), val(db)

    output:
        path "*"

    script:
    """
    python3 diamond blastp --query $fasta--db $db --outfmt 6 --max-target-seqs 1 --evalue 1e-20 --out ${params.outdir}/${species} --threads 24 --sensitive
    """
}

workflow diamond_run {

    take:
        ch_input

    main:
        run_diamond(ch_input)

    emit:
        out = run_diamond.out
}


// Workflow block
workflow {

    ch_samples= Channel.fromPath(params.input)
                        .splitCsv(header: true)
                        .map { row -> tuple(row.species, file(row.fasta), row.fasta) }
                        .view()

    // ch_fantasia_input = cpy_fasta(ch_samples)
    // run_fantasia(ch_fantasia_input)

    ch_diamond_sprot = ch_samples.map { species, fasta ->
        tuple(species, fasta, params.dbsprot)
    }

    ch_diamond_trembl = ch_samples.map { species, fasta ->
        tuple(species, fasta, params.dbtrembl)
    }

    diamond_run(ch_diamond_sprot)
    diamond_run(ch_diamond_trembl)

}
