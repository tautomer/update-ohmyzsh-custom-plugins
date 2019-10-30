function update-custom-plugins() {

    omz_url=$(git -C $ZSH_CUSTOM config --get remote.origin.url)
    # find all 2nd-level directories in $ZSH_CUSTOM
    dirs=$(find $ZSH_CUSTOM -mindepth 2 -maxdepth 2 -type d)

    for i in $(echo $dirs)
    do
        url=$(git -C $i config --get remote.origin.url)
        # skip if the folder is not a git repo
        if [[ -n $url ]] && [[ $url != $omz_url ]]; then
            echo "Checking update for $(basename $i)"
            git -C $i remote update > /dev/null
            nc=$(git -C $i log HEAD..origin/master --oneline | wc -l)
            if [[ $nc != 0 ]]; then
                echo "The local version is $nc commits behind the remote"
                git -C $i pull origin master
            else
            echo "$(basename $i) is up-to-date"
            fi
        else
            echo "Skip $(basename $i) which is NOT a git repo"
        fi
    done
}
