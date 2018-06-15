#!/bin/bash

# always use absolute path for output directory
./1_clone_projects.sh input/comparison_project_sample_800.csv /data/logs > output_clone.log 2>&1
./2_process_branches_and_compress.sh /data/logs /data/branches > output_extract-branch-info.log 2>&1
