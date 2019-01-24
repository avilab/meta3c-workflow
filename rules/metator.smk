
rule metator_align:
    input:
      reads = rules.fastp.output, 
      scaffolds = rules.spades.output.scaffolds
    output:
      "align/{sample}/network.txt"
    params: 
      extra = "-C 100000000 -Q 10 --clean-up",
      output_dir = "align/{sample}"
    singularity: "shub://avilab/metaTOR:8fcb868"
    shell:
      """
      metator align -1 {input.reads[0]} -2 {input.reads[1]} -a {input.scaffolds} {params.extra} -p {params.output_dir}
      """
