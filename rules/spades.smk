# Runs spades metagenome+assembly module
rule spades:
    input: 
      rules.fastp.output
    output: 
      scaffolds = "spades/{sample}/scaffolds.fasta"
    params:
      options = "--meta --only-assembler"
    log: "logs/{sample}_spades.log"
    wrapper:
      "https://raw.githubusercontent.com/avilab/snakemake-wrappers/master/spades"