function update-custom-plugins() {

    # find all 2nd-level directories in $ZSH_CUSTOM
    dirs=$(find $ZSH_CUSTOM -mindepth 2 -maxdepth 2 -type d -not -path '*example*')
    nrepos=$(echo $dirs | wc -l)
    omz_url=$(git -C $ZSH_CUSTOM config --get remote.origin.url)
    # for output purpose
    uptodate=""
    dirty=""
    conflict=""
    updated=""
    notrepo=""
    n=0

    for i in $(echo $dirs)
    do
        url=$(git -C $i config --get remote.origin.url)
        repo_name=$(basename $i)
        # skip if the folder is not a git repo
        if [[ -n $url ]] && [[ $url != $omz_url ]]; then
            echo "Checking update for $repo_name"
            if [[ -n $(git -C $i status --untracked-files=no --porcelain) ]]; then
                dirty+="$repo_name "
                echo "$repo_name is dirty, no update will be made"
                continue
            fi
            git -C $i remote update > /dev/null
            nc=$(git -C $i log HEAD..origin/master --oneline | wc -l)
            if [[ $nc != 0 ]]; then
                echo "The local version is $nc commits behind the remote"
                git -C $i merge origin/master --no-commit
                if [[ $? == 0 ]]; then
                    updated+="$repo_name "
                    ((n++))
                else
                    conflict+="$repo_name "
                    git -C $i merge --abort
                fi
            else
                echo "$repo_name is up-to-date"
                uptodate+="$repo_name "
            fi
        else
            echo "Skip $repo_name which is NOT a git repo"
            notrepo+="$repo_name "
        fi

    done

    # print summary
    msg="\nSummary:"
    if [[ $n == 0 ]]; then
        msg+="\n All repos are already up-to-date!"
    elif [[ $n == $nrepos ]]; then
        msg+="\n All repos have been updated to the latest version!"
    else
        msg+="\n The following repos are already up-to-date: $uptodate"
        msg+="\n $n out of $nrepos repos updated: $updated"
        [[ -n "$notrepo" ]] && msg+="\n The following folders are not git repos: $notrepo"
        [[ -n $conflict ]]  && msg+="\n The following repos will have merge conflicts : $conflict\n Please resolve the conflict first and then update"
        [[ -n $dirty ]]     && msg+="\n The following repos are dirty: $dirty\n Please take care of your local changes and then update once again"
    fi
    echo $msg
}
