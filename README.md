Step 1. Install HISAT-3N.
```
git clone https://github.com/DaehwanKimLab/hisat2.git hisat-3n
cd hisat-3n
git checkout -b hisat-3n origin/hisat-3n
make
```
Step 2. Set up config.yaml (see example in config_example folder.

Step 3. Run BaseCodeGenerate:
```
snakemake -s /path/to/repo/generate_basecode_reference_files.smk -j {threads} --use-conda
```
