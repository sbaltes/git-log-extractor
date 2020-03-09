#!/bin/bash

# Clone all repos and save git logs

filename="$1"
targetdir="${2%/}" # remove trailing slash, absolute path must be used
classdir="$3" # absolute path to directory containing Java class file of filtering tool
classname="$4"
counter=0

# create target dir if it does not exist
mkdir -p "$targetdir"

while read -r line || [[ -n "$line" ]]; # do not ignore last line (see https://stackoverflow.com/a/10929511)
do
  counter=$((counter+1))
  echo "##################################### Now we process project #$counter ###############################################"
  echo "The time is: "
  date
  echo "###############################################################################################################"
  name="$line"
  name=`echo "$name" | xargs` # trim string
  echo "Name read from file: $name"

  github="https://github.com/"
  git=".git"
  gitlink=$github$name$git

  clearname=${name//[\/]/_}
  echo "Clearname: $clearname"

  # try to clone repo
  git clone $gitlink $clearname

  if [ ! -d "$clearname" ]; then
    echo "Error while cloning repo $name, continuing with next repo..."
    continue
  fi

  # change directory to current repo if clone was successful
  cd $clearname

  # save same of default branch (automatically checked out after clone)
  branch=`git rev-parse --abbrev-ref HEAD`

  # file names for output
  targetfile_commits=$targetdir"/"$clearname"§"$branch"_commits.csv"
  targetfile_merges=$targetdir"/"$clearname"§"$branch"_merges.csv"

  echo "Branch name: $branch"
  echo "Target file commits: $targetfile_commits"
  echo "Target file merges: $targetfile_merges"

  git config merge.renameLimit 999999
  git config diff.renameLimit 999999

  # save commit logs
  #git log --pretty=fuller --no-merges --date=iso --numstat --diff-filter=ADM > $targetfile_commits
  git log --pretty=fuller --no-merges --date=iso --numstat --diff-filter=ADM | java -cp "$classdir" "$classname" > $targetfile_commits
  # remove empty log files
  if [ ! -s "$targetfile_commits" ]; then
    rm "$targetfile_commits"
  fi

  # save merge logs
  # see https://stackoverflow.com/a/37802111
  # see https://git-scm.com/docs/git-log#git-log--m
  # see http://marcgg.com/blog/2015/08/04/git-first-parent-log/
  git log --pretty=fuller --merges --date=iso --numstat -m --first-parent | java -cp "$classdir" "$classname" > $targetfile_merges
  # remove empty log files
  if [ ! -s "$targetfile_merges" ]; then
    rm "$targetfile_merges"
  fi

  cd ..

  rm -rf $clearname

done < "$filename"

echo "Finished."
