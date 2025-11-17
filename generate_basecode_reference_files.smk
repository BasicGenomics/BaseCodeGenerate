configfile: "config.yaml"

rule all:
    input:
        "geneannotations.positive.gff3",
        "reference.fa",
        "reference.fa.fai",
        "genomeref.3n.GA.1.ht2"

rule move_reference:
    input: config["fasta"]
    output: "reference.fa"
    threads: 1
    conda: "envs/full.yaml"
    shell: "cp {input} {output}"

rule index_reference:
    input: "reference.fa"
    output: "reference.fa.fai"
    threads: 1
    conda: "envs/full.yaml"
    shell: "samtools faidx {input}"

rule agat_add_introns:
    input: config["gtf_file"]
    output: "geneannotations.gff3"
    threads: 1
    conda: "envs/full.yaml"
    shell: "agat_sp_add_introns.pl --gff {input} --out {output}"

rule split_gff_file:
    input: "geneannotations.gff3"
    output:
        "geneannotations.positive.gff3",
        "geneannotations.negative.gff3"
    threads: 1
    conda: "envs/full.yaml"
    shell: "bash {workflow.basedir}/scripts/split_gff_file.sh {input}"

rule extract_splice_sites:
    input: "geneannotations.gff3"
    output: "splicesites.ss"
    threads: 1
    conda: "envs/full.yaml"
    shell: "python3 {workflow.basedir}/scripts/hisat2_extract_splice_sites.py {input} > {output}"

rule extract_exons:
    input: "geneannotations.gff3"
    output: "genome.exons"
    threads: 1
    conda: "envs/full.yaml"
    shell: "python3 {workflow.basedir}/scripts/hisat2_extract_exons.py {input} > {output}"

rule hisat3n_build:
    input:
        ss = "splicesites.ss",
        exon = "genome.exons",
        reference = "reference.fa"
    output: "genomeref.3n.GA.1.ht2"
    threads: config["threads"]
    conda: "envs/full.yaml"
    shell: "{config[hisat_3n_build]} --base-change G,A --ss {input.ss} --exon {input.exon} -p {threads} {input.reference} genomeref"
