#!/bin/bash
# Usage: ./submitAll.sh

PBS_SCRIPT=pbs_case_job.sh

if [ ! -f "$PBS_SCRIPT" ]; then
  echo "Error: PBS job script '$PBS_SCRIPT' not found."
  exit 1
fi

for case_dir in */; do
  if [ -d "$case_dir" ]; then
    echo "Copying PBS script to $case_dir"
    cp "$PBS_SCRIPT" "$case_dir"

    echo "Submitting job for $case_dir"
    cd "$case_dir"
    msub "$PBS_SCRIPT"
    cd ..
  fi
done

