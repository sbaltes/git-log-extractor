#!/bin/bash 

output_file="output.csv"

for file in output/*.csv;
do
  repo_info=`basename $file | egrep -o '[^§]+' | head -n1 | tr -d '\n'`
  repo_owner=`echo "$repo_info" | egrep -o '[^_]+' | head -n1 | tr -d '\n'`
  repo_name=${repo_info/${repo_owner}_/''} 

  commit_info=`echo "$file" | egrep -o '[^§]+' | tail -n1 | tr -d '\n'`
  branch=`echo "$commit_info" | egrep -o '[^_]+' | head -n1 | tr -d '\n'`
  commit_type=${commit_info/${branch}_/''}
  commit_type=${commit_type/s.csv/''}

  prefix="$repo_owner,$repo_name,$branch,$commit_type"

  while read line; do
    echo "$prefix,$line" >> $output_file
  done <"$file"
done
