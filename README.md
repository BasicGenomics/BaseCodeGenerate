# <span style="color:#583092">BaseCodeGenerate</span>

## Usage

### <span style="color:#EC008C">1. Install snakemake</span>

Installation via Conda or Mamba is the recommended way to install Snakemake, as it enables Snakemake to automatically manage software dependencies required by the workflow. For alternative installation methods, please see the official [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

```
conda create -c conda-forge -c bioconda -c nodefaults -n snakemake snakemake
conda activate snakemake
```

### <span style="color:#EC008C">2. Clone the repository</span>

Clone the BaseCodeGenerate repository and move into the project directory:

```
git clone --branch conda https://github.com/BasicGenomics/BaseCodeGenerate.git
cd BaseCodeGenerate
```

### <span style="color:#EC008C">3. Configure the workflow</span>

Set up a config.yaml file (see config/ for a template).

Required input files include:
- a reference genome in FASTA format
- an annotation file in GFF3 format

Note: GTF format is also supported. However, since the pipeline outputs annotations in GFF3 format, we recommend starting with a GFF3 file to ensure consistency and avoid potential conversion issues.

We recommend fetching reference genome and annotation files from either
[Ensembl](https://www.ensembl.org/info/data/ftp/index.html) or
[GENCODE](https://www.gencodegenes.org).

### <span style="color:#EC008C">4. Run BaseCodeGenerate</span>

Execute the Snakemake workflow:

```
snakemake -s /path/to/repo/generate_basecode_reference_files.smk -j {threads} --use-conda
```

Copyright © 2026 Basic Genomics AB
