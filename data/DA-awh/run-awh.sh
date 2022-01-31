#!/bin/bash

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PLACES=cores
export GMX_MAXBACKUP=-1
export GMX_PULL_PARTICIPATE_ALL=1

# prepare directory for GROMACS run
mkdir opt
cd opt
rm rsurf.xvg

# backup itp file
cp ../topol.top topol.top
cp ../conf.gro confout.gro

# loop over distances from  0.12 nm to 0.32 nm
for d in $(seq 0.13 0.005 0.45)
do

   # replace constraint length with the actual number
   sed "s/@LEN@/${d}/g" ../dat.itp > dat.itp

   # generate tpr using previous step coordinates
   gmx_mpi_d grompp -f ../LT.mdp -p topol.top -c confout.gro -n ../index.ndx -o dat-opt.tpr -maxwarn 10

   # run GROMACS
   srun gmx_mpi_d mdrun -s dat-opt.tpr -v

   # extract data to xvg file
   echo -e "${d}\t`grep 'Potential Energy  =' md.log | awk '{printf("%f\n",$4)}'`" >> rsurf.xvg

done
