#!/bin/bash

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_PLACES=cores
export GMX_MAXBACKUP=-1
export GMX_PULL_PARTICIPATE_ALL=1

# prepare directory for GROMACS run
mkdir opt
cd opt
rm rsurf.xvg

# copy conf.gro
cp ../topol.top topol.top
cp ../conf.gro confout.gro

# loop over distances from  0.12 nm to 0.45 nm
for d in $(seq 0.12 0.005 0.45)
do

   # replace constraint length with the actual number
   sed "s/@LEN@/${d}/g" ../dat.itp > dat.itp

   mkdir opt${d}

   # generate tpr using previous step coordinates
   gmx_mpi_d grompp -f ../LT.mdp -p topol.top -c confout.gro -n ../index.ndx -o opt${d}/dat-opt${d}.tpr -maxwarn 10

   cd opt${d}

   # run GROMACS
   srun gmx_mpi_d mdrun -s dat-opt${d}.tpr -v

   gmx_mpi_d distance -s *.tpr -f traj.trr -n ../../index.ndx -select "com of group 4 plus com of group 5" -oav -oall

   # extract data to xvg file
   echo -e "`tail -n1 dist.xvg | grep '.' | awk '{printf("%f\n",$2)}'`\t`grep 'Potential Energy  =' md.log | awk '{printf("%f\n",$4)}'`" >> ../rsurf.xvg

   cp -f confout.gro ../
   
   cd ..

done
