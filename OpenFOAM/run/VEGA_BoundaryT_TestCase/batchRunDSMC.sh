#!/bin/bash

# Set parent directory where all case folders are located
PARENT_DIR=$(pwd)

# Set number of processors to use per case
NUM_PROCS=4

echo "Starting DSMC batch run..."
echo "=========================="

# Loop through all subdirectories in the parent directory
for case_dir in "$PARENT_DIR"/*/; do
    case_name=$(basename "$case_dir")
    echo "Processing case: $case_name"
    echo "--------------------------"

    cd "$case_dir" || { echo "Failed to enter $case_dir"; exit 1; }

    # Step 1: Initialize particles
    echo "[1/4] Running dsmcInitialise..."
    dsmcInitialise > log.initialise 2>&1

    # Step 2: Decompose domain
    echo "[2/4] Running decomposePar -force..."
    decomposePar -force > log.decompose 2>&1

    # Step 3: Run dsmcFoam in parallel
    echo "[3/4] Running dsmcFoam with $NUM_PROCS cores..."
    mpirun -np $NUM_PROCS dsmcFoam -parallel > log.dsmcFoam 2>&1

    # Step 4: Reconstruct results
    echo "[4/4] Reconstructing results (reconstructPar)..."
    reconstructPar > log.reconstruct 2>&1

    # ✅ Check if reconstruction was successful
    LAST_TIME=$(grep '^Time = ' log.reconstruct | tail -1 | awk '{print $3}')
    if [[ -d "$case_dir/$LAST_TIME" && -f "$case_dir/$LAST_TIME/U" ]]; then
        echo "✅ Reconstruction successful for $case_name (time: $LAST_TIME)"

        # 🧹 Delete processor folders only if successful
        echo "🧹 Cleaning up processor directories..."
        rm -rf processor*
    else
        echo "❌ Reconstruction failed or incomplete for $case_name"
        echo "    Check log.reconstruct and processor folders manually."
    fi

    echo "✅ Finished case: $case_name"
    echo
done

echo "=========================="
echo "✅ All DSMC cases completed."
