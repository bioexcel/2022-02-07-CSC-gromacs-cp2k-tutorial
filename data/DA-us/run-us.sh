#!/bin/bash

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PLACES=cores
export GMX_MAXBACKUP=-1
export GMX_PULL_PARTICIPATE_ALL=1

umbr=0.15

for i in $(seq 0 1 20); do
	mkdir us-window${i}
        sed "s/@umbr@/${umbr}/" qmmm-umbrella.mdp > us-window${i}/qmmm-window${i}.mdp
	cd us-window${i}

	gmx_mpi_d grompp -f qmmm-window${i}.mdp -p ../topol.top -n ../index.ndx -o md-us${i}.tpr -c ../eq_gro/md_eq${i}.gro -maxwarn 10

	srun gmx_mpi_d mdrun -s md-us${i}.tpr

        cp pullx.xvg ../profile/pullx${i}.xvg
        cp md-us${i}.tpr ../profile/md-us${i}.tpr
	cd ../

#	echo $i $umbr
	umbr=$(echo "$umbr + 0.019" | bc -l)
done
