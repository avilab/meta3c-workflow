__author__ = "Taavi Päll"
__copyright__ = "Copyright 2018, Taavi Päll"
__email__ = "tapa741@gmail.com"
__license__ = "MIT"

from snakemake.shell import shell

# Check inputs/arguments.
if not isinstance(snakemake.input, str) and len(snakemake.input) not in 2:
    raise ValueError("input must have 2 (paired-end) elements")

# Extract arguments
options = snakemake.params.get("options", "")

# Setup log
log = snakemake.log_fmt_shell(stdout = False, stderr = True)

shell("mkdir -p {params.dir}")
shell("spades.py {options} -1 {input[0]} -2 {input[1]} -o {params.dir} 2> {log}")
