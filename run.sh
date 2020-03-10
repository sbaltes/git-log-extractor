#!/bin/bash

# configure this:
base_dir="/Users/sebastian/git/tools/git-log-extractor" # remove trailing slash
input_file="c++.csv"

# keep this:
input_dir="$base_dir/input"
input_file="$input_dir/$input_file"
output_dir="$base_dir/output"
mkdir -p "$output_dir"
java_dir="$base_dir/java"
filter_class="GitLogFilter"
log_file="$base_dir/output.log"

echo "Input file: $input_file"
echo "Output dir: $output_dir"
echo "Java dir: $java_dir"
echo "Filter class: $filter_class"
echo "Log file: $log_file"

# always use absolute path for output directory
echo "Retrieving commits..."
./retrieve_commits.sh "$input_file" "$output_dir" "$java_dir" "$filter_class" > "$log_file" 2>&1
