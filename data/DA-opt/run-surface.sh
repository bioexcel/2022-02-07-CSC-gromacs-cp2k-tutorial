#!/bin/bash
#SBATCH --job-name=rsurface
#SBATCH --partition=small
#SBATCH --time=00:10:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=40
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=2000
#SBATCH --reservation=gmx1

unset SLURM_MEM_PER_NODE

export OMP_NUM_THREADS=1
export OMP_PLACES=cores
export GMX_MAXBACKUP=-1

#module purge
#module load gromacs-course/gromacs-cp2k

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
   gmx_cp2k grompp -f ../LT.mdp -p topol.top -c confout.gro -n ../index.ndx -o opt${d}/dat-opt${d}.tpr -maxwarn 10

   cd opt${d}

   # run GROMACS
   srun gmx_cp2k mdrun -s dat-opt${d}.tpr -v

   # extract data
   gmx_cp2k distance -s *.tpr -f traj.trr -n ../../index.ndx -select "com of group 4 plus com of group 5" -oav -oall
   gmx_cp2k energy << EOF
12
EOF
   echo -e "`tail -n1 dist.xvg | grep '.' | awk '{printf("%f\n",$2)}'`\t`tail -n1 energy.xvg | awk '{printf("%f\n",$2)}'`" >> ../rsurf.xvg

   cp -f confout.gro ../
   
   cd ..

done
