configfile: "config.yaml"

rule all:
    input:
        "geneannotations.positive.gff3",
        "reference.fa",
        "reference.fa.fai",
        "genomeref.3n.GA.1.ht2",
        "canonical.txt"

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
    input: config["gff3"]
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
    threads: config.get("threads", 1)
    conda: "envs/full.yaml"
    shell: "hisat-3n-build --base-change G,A --ss {input.ss} --exon {input.exon} -p {threads} {input.reference} genomeref"

rule make_transcripts_bed:
    input: "geneannotations.gff3"
    output: "canonical.txt"
    params: gff_filtered_MANE = "geneannotations.canonical.MANE.level2.gff3",
            gff_discarded_MANE = "geneannotations.canonical.MANE.level2_discarded.gff",
            bed_discarded_MANE = "geneannotations.canonical.MANE.level2_discarded.bed",
            gff_filtered_Ensembl = "geneannotations.canonical.Ensembl.level2.gff3",
            gff_discarded_Ensembl = "geneannotations.canonical.Ensembl.level2_discarded.gff",
            bed_discarded_Ensembl = "geneannotations.canonical.Ensembl.level2_discarded.bed"
    threads: 1
    conda: "envs/full.yaml"
    shell: """
    if grep -q "MANE_Select" {input}; then
        echo "Using MANE Select transcripts." > {output}
        agat_sp_filter_feature_by_attribute_value.pl --gff {input} --attribute tag --value MANE_Select -p level2 --output {params.gff_filtered_MANE}
        agat_convert_sp_gff2bed.pl --gff {params.gff_discarded_MANE} -o {params.bed_discarded_MANE}
    elif grep -q "Ensembl_canonical" {input}; then
        echo "Using Ensembl canonical transcripts." > {output}
        agat_sp_filter_feature_by_attribute_value.pl --gff {input} --attribute tag --value Ensembl_canonical -p level2 --output {params.gff_filtered_Ensembl}
        agat_convert_sp_gff2bed.pl --gff {params.gff_discarded_Ensembl} -o {params.bed_discarded_Ensembl}
    else
        echo "No MANE Select nor Ensembl canonical transcripts found." > {output}
    fi
    """