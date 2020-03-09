#!/bin/bash

base_dir="/Users/sebastian/git/tools/git-log-extractor" # remove trailing slash
input_file="input/c.csv"
output_dir="$base_dir/output"
mkdir -p "$output_dir"
java_dir="$base_dir/java"
java_class="GitLogFilter"
log_file="output.log"

# always use absolute path for output directory
./retrieve_commits.sh "$input_file" "$output_dir" "$java_dir" "$java_class" > "$log_file" 2>&1
