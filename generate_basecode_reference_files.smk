configfile: "config.yaml"

rule all:
    input: "{}/geneannotations.positive.gff3".format(config["outdir"]), "{}/reference.fa".format(config["outdir"]), "{}/reference.fa.fai".format(config["outdir"]), "{}/genomeref.3n.GA.1.ht2".format(config["outdir"])

rule move_reference:
    input: config["fasta"]
    output: "{}/reference.fa".format(config["outdir"])
    threads: 1
    conda: "{workflow.basedir}/envs/full.yaml"
    shell: "cp {input} {output}"

rule index_reference:
    input: "{}/reference.fa".format(config["outdir"])
    output: "{}/reference.fa".format(config["outdir"])
    threads: 1
    conda: "{workflow.basedir}/envs/full.yaml"
    shell: "samtools faidx {input}"

rule agat_add_introns:
    input: config["gtf_file"]
    output: "{}/geneannotations.gff3".format(config["outdir"])
    threads: 1
    conda: "{workflow.basedir}/envs/full.yaml"
    shell: "agat_sp_add_introns.pl --gff {input} --out {output}"

rule split_gff_file:
    input: "{}/geneannotations.gff3".format(config["outdir"])
    output: "{}/geneannotations.positive.gff3".format(config["outdir"]), "{}/geneannotations.negative.gff3".format(config["outdir"])
    threads: 1
    conda: "{workflow.basedir}/envs/full.yaml"
    shell: "bash {workflow.basedir}/scripts/split_gff_file.sh {input}"

rule extract_splice_sites:
    input: "{}/geneannotations.gff3".format(config["outdir"])
    output: "{}/splicesites.ss".format(config["outdir"])
    threads: 1
    conda: "{workflow.basedir}/envs/full.yaml"
    shell: "python3 {workflow.basedir}/scripts/hisat2_extract_splice_sites.py {input} > {output}"

rule extract_exons:
    input: "{}/geneannotations.gff3".format(config["outdir"])
    output: "{}/genome.exons".format(config["outdir"])
    threads: 1
    conda: "{workflow.basedir}/envs/full.yaml"
    shell: "python3 {workflow.basedir}/scripts/hisat2_extract_exons.py {input} > {output}"

rule hisat3n_build:
    input: ss = "{}/splicesites.ss".format(config["outdir"]), exon = "{}/genome.exons".format(config["outdir"]), reference = "{}/reference.fa".format(config["outdir"])
    output: "{}/genomeref.3n.GA.1.ht2".format(config["outdir"])
    threads: config["threads"]
    conda: "{workflow.basedir}/envs/full.yaml"
    shell: "config[hisat_3n_build] --base-change G,A --ss {input.ss} --exon {input.exon} -p {threads} {input.reference} genomeref"
