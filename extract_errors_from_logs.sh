#!/bin/bash 

for file in data/*.log; do
  input_file=`basename "$file"`
  echo "Processing $input_file..."
  output_file="${input_file/.log/_errors.csv}"
  echo "Writing erroneous repos to $output_file..."

  # Side effects: trimming leading whitespace, interpreting backslash sequences, skipping the last line if it's missing a terminating linefeed
  # Source: https://stackoverflow.com/a/1521498
  while read line; do
    if [[ $line == "Error while cloning repo"* ]]; then
      repo=`echo "$line" | egrep -o '[^ ]+\/[^ ,]+' | head -n1 | tr -d '\n'`
      echo "$repo" >> "$output_file"
    fi
  done <"$file"
done
