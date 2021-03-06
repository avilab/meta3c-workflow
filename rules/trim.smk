FTP = FTPRemoteProvider(username = config["username"], password = config["password"])

def get_fastq(wildcards):
    """Get fraction read file paths from samples.tsv"""
    urls = SAMPLES.loc[wildcards.sample, ['fq1', 'fq2']]
    return list(urls)

def get_frac(wildcards):
    """Get fraction of reads to be sampled from samples.tsv"""
    frac = SAMPLES.loc[wildcards.sample, ['frac']][0]
    return frac

# Imports local or remote fastq(.gz) files. Downsamples runs based on user-provided fractions in samples.tsv file.
rule sample:
  input:
    lambda wildcards: FTP.remote(get_fastq(wildcards), immediate_close=True) if config["remote"] else get_fastq(wildcards)
  output:
    temp("munge/{sample}_read1.fq.gz"),
    temp("munge/{sample}_read2.fq.gz")
  params:
    frac = lambda wildcards: get_frac(wildcards),
    seed = config["seed"]
  wrapper:
    "https://raw.githubusercontent.com/avilab/snakemake-wrappers/master/seqtk"

# Adapter trimming and quality filtering.
rule fastp:
  input:
    rules.sample.output
  output:
    temp("munge/{sample}_read1_trimmed.fq.gz"),
    temp("munge/{sample}_read2_trimmed.fq.gz")
  params:
    options = "--trim_front1 5 --trim_tail1 5 --length_required 50 --low_complexity_filter --complexity_threshold 8",
    html = "munge/{sample}_fastp_report.html",
    json = "munge/{sample}_fastp_report.json"
  threads: 8
  log: "logs/{sample}_fastp.log"
  wrapper:
    "https://raw.githubusercontent.com/avilab/snakemake-wrappers/master/fastp"
