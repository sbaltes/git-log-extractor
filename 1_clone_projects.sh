#!/bin/bash

# Clone all repos and save git logs

filename="$1"
targetdir="${2%/}" # remove trailing slash, absolute path must be used
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

    # REMOTE BRANCHES
    branch_output=`git branch -r`

    branches=""
    next_is_default=false
    default_branch=""
    default_branch_latest_commit=""

    # iterate over branch output to determine default branch
    for item in ${branch_output:2}
    do
      # determine default branch
      if [ "$item" == "origin/HEAD" ]; then 
        continue
      fi

      if [ "$item" == "->" ]; then
        next_is_default=true
        continue
      fi

      if [ "$next_is_default" == true ] ; then
        default_branch="$item"
        default_branch_latest_commit=`git log -n 1 $item --pretty=format:"%H"`
        next_is_default=false
        echo "Default branch: $default_branch"
        continue    
      fi

      branches=$branches$item$'\n'
    done

    # write header for branches csv
    branches_csv=$targetdir"/"$clearname"_branches.csv"
    echo $'project,branch,default_branch,latest_commit,merge_base' > $branches_csv 

    # iterate over branches to save git log, latest commit, and merge-base
    for remote_branch in ${branches}
    do
      branch="${remote_branch/origin\/}"

      # check out current branch and save git log
      if [ "$remote_branch" == "$default_branch" ] ; then
        git checkout $branch
      else
        git checkout -b $branch $remote_branch 
      fi

      clearbranch=${branch//[\/]/_}
      targetfile_commits=$targetdir"/"$clearname"§"$clearbranch"_commits.log"
      targetfile_merges=$targetdir"/"$clearname"§"$clearbranch"_merges.log"
      echo "Remote branch: $remote_branch"
      echo "Branch name: $branch"
      echo "Target file commits: $targetfile_commits"
      echo "Target file merges: $targetfile_merges"
      
      git config merge.renameLimit 999999
      git config diff.renameLimit 999999

      # save commit logs
      git log --pretty=fuller --no-merges --date=iso --numstat --diff-filter=ADM > $targetfile_commits

      # save merge logs
	  # see https://stackoverflow.com/a/37802111
	  # see https://git-scm.com/docs/git-log#git-log--m
	  # see http://marcgg.com/blog/2015/08/04/git-first-parent-log/
      git log --pretty=fuller --merges --date=iso --numstat -m --first-parent > $targetfile_merges

      # generate row for branch CSV
      output=$name","$branch
      if [ "$remote_branch" == "$default_branch" ]; then
        output=$output",true"
      else
        output=$output",false"
      fi

      # append latest commit
      latest_commit=`git log -n 1 $remote_branch --pretty=format:"%H"`
      output=$output","$latest_commit

      # append merge-base
      args=$default_branch_latest_commit" "$latest_commit
      merge_base=`git merge-base $args`
      output=$output","$merge_base$'\n'

      # write row to branch csv
      echo $output >> $branches_csv
    done

    cd ..

    rm -rf $clearname

done < "$filename"

echo "Finished."
