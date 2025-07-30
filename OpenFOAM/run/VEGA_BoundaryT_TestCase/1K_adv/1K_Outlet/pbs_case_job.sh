#!/bin/bash
#PBS -S /bin/bash
#PBS -q longq
#PBS -l walltime=120:00:00
#PBS -l nodes=1:ppn=192
#PBS -N 1K_Outlet_adv
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

echo "[1/5] Running dsmcInitialise..."
dsmcInitialise > log.initialise 2>&1

echo "[2/5] Running decomposePar -force..."
decomposePar -force > log.decompose 2>&1

echo "[3/5] Running dsmcFoam with $PBS_NP cores..."
mpirun -np 192 dsmcFoam -parallel > log.dsmcFoam 2>&1

echo "[4/5] Reconstructing results..."
reconstructPar > log.reconstruct 2>&1

# === Check reconstruction success ===
if grep -q "End" log.reconstruct && [ $? -eq 0 ]; then
    echo "[SUCCESS] Reconstruction completed successfully."

    echo "[5/5] Cleaning up processor directories..."
    rm -rf processor*

    echo "[5/5] Compressing case directory..."
    cd ..
    tar -czf ${PBS_JOBNAME}_Results.tar.gz $(basename $PBS_O_WORKDIR)
    echo "[COMPLETE] Archive saved as ${PBS_JOBNAME}.tar.gz"
else
    echo "[WARNING] Reconstruction may have failed. Skipping cleanup and compression."
fi
echo "[PBS_JOBID: $PBS_JOBID] Job complete"