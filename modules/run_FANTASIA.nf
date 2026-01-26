
process cpy_fasta {

    input:
        tuple val(species), path(fasta), val(fasta_path)

    output:
        tuple val(species), path(fasta)

    publishDir "${params.fantasia_dir}/fasta_tmp", mode: 'copy'

    script:
    """
    echo "Archivo $fasta copiado"
    """
}

process run_fantasia {

    publishDir "${params.outdir}/${species}", mode: 'copy'

    input:
        tuple val(species), path(fasta)

    output:
        path "*"

    script:
    """
    cd ${params.fantasia_dir}
    python3 fantasia_pipeline.py --serial-models --embed-models prot_t5 ${params.fantasia_dir}/fasta_tmp/${fasta.getName()}
    """
}