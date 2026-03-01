function update-custom-plugins() {
    # Initialize arrays for summary tracking
    local uptodate=() dirty=() conflict=() updated=()
    local total=0

    echo "Checking for custom plugin updates..."

    # Loop exactly 2 levels deep in ZSH_CUSTOM using shell globbing
    for repo in "$ZSH_CUSTOM"/*/*; do
        # Skip if not a git repository or is an example directory
        [[ -d "$repo/.git" ]] || continue
        [[ "$repo" == *example* ]] && continue

        ((total++))
        local name=$(basename "$repo")

        # 1. Check if repo is dirty
        if [[ -n $(git -C "$repo" status --short --untracked-files=no) ]]; then
            dirty+=("$name")
            echo "  -> $name is dirty, skipping."
            continue
        fi

        # 2. Fetch latest remote changes silently
        git -C "$repo" fetch --quiet

        # 3. Dynamically get the upstream tracking branch (e.g., origin/main or origin/master)
        local upstream=$(git -C "$repo" rev-parse --abbrev-ref '@{u}' 2>/dev/null)
        if [[ -z "$upstream" ]]; then
            echo "  -> $name has no upstream tracking branch, skipping."
            continue
        fi

        # 4. Check commit difference
        local nc=$(git -C "$repo" rev-list --count HEAD.."$upstream")
        if (( nc == 0 )); then
            uptodate+=("$name")
        else
            echo "  -> Updating $name ($nc commits behind)..."
            # Use --ff-only to safely update without unexpected merge commits
            if git -C "$repo" merge "$upstream" --ff-only >/dev/null 2>&1; then
                updated+=("$name")
            else
                conflict+=("$name")
                git -C "$repo" merge --abort >/dev/null 2>&1
                echo "  -> Merge conflict for $name!"
            fi
        fi
    done

    # Print Summary
    echo ""
    echo "=== Summary ==="
    if (( ${#updated[@]} == 0 && ${#dirty[@]} == 0 && ${#conflict[@]} == 0 )); then
        echo "All $total repos are already up-to-date!"
    else
        [[ ${#uptodate[@]} -gt 0 ]] && echo "   Up-to-date: ${uptodate[*]}"
        [[ ${#updated[@]} -gt 0 ]]  && echo "   Updated: ${updated[*]}"
        [[ ${#conflict[@]} -gt 0 ]] && echo "   Conflicts (needs manual fix): ${conflict[*]}"
        [[ ${#dirty[@]} -gt 0 ]]    && echo "   Dirty (needs manual fix): ${dirty[*]}"
    fi
}
