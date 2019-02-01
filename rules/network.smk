# Mapping reads to contigs
rule align:
    input: 
      ref = rules.assemble.output.contigs,
      in1 = rules.fastp.output[0],
      in2 = rules.fastp.output[1]
    output:
      out = "align/{sample}/aln.sam.gz",
      path = directory("index/{sample}")
    params:
      options = "kfilter=22 subfilter=15 maxindel=80"
    wrapper:
      "https://raw.githubusercontent.com/avilab/snakemake-wrappers/master/bbmap/bbwrap"

rule coverage:
    input: 
      rules.align.output.out
    output:
      out = "align/{sample}/coverage.tsv"
    log: "logs/{sample}_coverage.log"
    wrapper:
      "https://raw.githubusercontent.com/avilab/snakemake-wrappers/master/bbmap/pileup"

rule view:
    input:
        pipe(rules.align.output.out)
    output:
        "align/{sample}_raw.bam"
    params:
        "-b -F 4 -q 10"
    wrapper:
        "0.31.1/bio/samtools/view"

rule sort:
    input:
        rules.view.output
    output:
        "align/{sample}_sorted.bam"
    params:
        "-n"
    threads: 8
    wrapper:
        "0.31.1/bio/samtools/sort"

# Generating network from alignments
rule network:
    input:
        alignment = rules.sort.output,
        ref = rules.assemble.output.contigs
    output: 
        "network/{sample}/network.txt",
        "network/{sample}/idx_contig_hit_size_cov.txt"
    params:
      network_dir = "network/{sample}",
      q = 10,
      chunk_size = 1000,
      read_size = 65,
      size_chunk_threshold = 500
    conda: 
      "../envs/network.yaml"
    shell:
      "python {SNAKEMAKE_DIR}/scripts/network.py "
      "--input {input.alignment} "
      "--reference {input.ref} "
      "--output {params.network_dir} "
      "--map-quality {params.q} "
      "--chunk-size {params.chunk_size} "
      "--read-size {params.read_size} "
      "--size-chunk-threshold {params.size_chunk_threshold} "
      "--normalize"
