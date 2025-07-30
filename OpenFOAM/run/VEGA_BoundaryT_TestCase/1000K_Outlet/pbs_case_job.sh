#!/bin/bash
#PBS -S /bin/bash
#PBS -q normalq
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=192
#PBS -N 1000K_Outlet_Results
#PBS -j oe
#PBS -M bratte@my.erau.edu
#PBS -m abe
#PBS -e pbs_errors.out
#PBS -o pbs_output.out

# set up spack/lmod access
source  /apps/spack/share/spack/setup-env.sh
source  $(spack location -i lmod)/lmod/lmod/init/bash

# set up envirmont for openFOAM run
module load openmpi/5.0.2-gcc-8.5.0-diludms
module load openfoam/2312-gcc-8.5.0-rsh4eqx

# Change to the case directory
cd $PBS_O_WORKDIR

# === DSMC Workflow ===

echo "[1/4] Running dsmcInitialise..."
dsmcInitialise > log.initialise 2>&1

echo "[2/4] Running decomposePar -force..."
decomposePar -force > log.decompose 2>&1

echo "[3/4] Running dsmcFoam with $PBS_NP cores..."
mpirun -np 192 dsmcFoam -parallel > log.dsmcFoam 2>&1

echo "[4/4] Reconstructing results..."
reconstructPar > log.reconstruct 2>&1

echo "[PBS_JOBID: $PBS_JOBID] Job complete"