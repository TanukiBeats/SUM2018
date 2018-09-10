#!/bin/bash

## Job Name
#SBATCH --job-name=g.num

## Error and Output Files
#SBATCH --error=GRO.e
#SBATCH --output=GRO.o

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

module unload icc_14.0.2-impi_4.1.3.049
module load icc_15.0.3-impi_5.0.3

export PATH=$PATH:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/bin
export INCLUDE=$INCLUDE:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gscratch/pfaendtner/codes/plumed2-BayesBias/bin/lib
source /gscratch/pfaendtner/codes/gromacs-5.1.2/inst/bin/GMXRC
EXEC=/gscratch/pfaendtner/codes/gromacs-5.1.2/inst/bin/gmx_mpi


cd $SLURM_SUBMIT_DIR

mpiexec.hydra $EXEC mdrun -cpi restart -cpo restart -append -cpt 1.0 

