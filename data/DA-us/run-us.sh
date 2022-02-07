#!/bin/bash
#SBATCH --job-name=umbrella
#SBATCH --partition=small
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=40
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2000
#SBATCH --account=project_2003752
#SBATCH --reservation=gmx1

unset SLURM_MEM_PER_NODE

export OMP_NUM_THREADS=1
export OMP_PLACES=cores
export GMX_MAXBACKUP=-1

# run GROMACS
srun gmx_cp2k mdrun -s md-us10.tpr