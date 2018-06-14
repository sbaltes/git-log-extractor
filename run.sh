#!/bin/bash

# always use absolute path for output directory
./clone_projects.sh input/comparison_project_sample_200.csv /data/logs > output_clone.log 2>&1
./extract_and_merge_branch_csvs.sh /data/logs /data/branches > output_extract-branch-info.log 2>&1
