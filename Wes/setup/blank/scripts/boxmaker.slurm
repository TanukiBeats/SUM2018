#!/bin/bash

## Job Name
#SBATCH --job-name=b.num

## Error and Output Files
#SBATCH --error=ff.e
#SBATCH --output=ff.o

## Allocation Definition

## On mox and ikt, the account and partition options should be the same.
#SBATCH --account=pfaendtner
#SBATCH --partition=pfaendtner

## Resources

## Nodes
#SBATCH --nodes=1   

## Walltime (3 hours). Do not specify a walltime substantially more than your job needs.
#SBATCH --time=24:00:00

## Memory per node. It is important to specify the memory since the default memory is very small.
## For mox, --mem may be more than 100G depending on the memory of your nodes.
## For ikt, --mem may be 60G or more depending on the memory of your nodes.
## See above section on "Specifying memory" for choices for --mem.
#SBATCH --mem=22G

## Specify the working directory for this job






