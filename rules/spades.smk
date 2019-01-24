# Runs spades metagenome+assembly module only
rule preliminary_assembly:
    input: 
      rules.fastp.output
    output: 
      scaffolds = "preliminary_assembly/{sample}/scaffolds.fasta"
    params:
      options = "--meta --only-assembler",
      dir = "preliminary_assembly/{sample}"
    log: "logs/{sample}_spades.log"
    wrapper:
      "file:wrappers/spades"