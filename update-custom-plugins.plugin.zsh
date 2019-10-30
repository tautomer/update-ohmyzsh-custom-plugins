function update-custom-plugins() {

    omz_url=$(git -C $ZSH_CUSTOM config --get remote.origin.url)

    function update() {
		dirs=$(find $1 -maxdepth 1 -mindepth 1 -type d)
        for i in $(echo $dirs)
        do
            url=$(git -C $i config --get remote.origin.url)
            if [[ -n $url ]] && [[ $url != $omz_url ]]; then
                echo "Checking updte for $(basename $i)"
                git -C $i pull origin master
            fi
        done
    }

    update $ZSH_CUSTOM/plugins
    update $ZSH_CUSTOM/themes
}
