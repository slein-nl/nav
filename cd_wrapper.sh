# add this function to your .zshrc/.bashrc and call nav with "n" to cd on esc
function n() {
    local tmp="$(mktemp -t "navcd.XXXXX")"
    nav "$@" --cd="$tmp"
    local nav_status=$?
    
    if [ $nav_status -eq 0 ]; then
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        	cd -- "$cwd"
        fi
    fi
    rm -f -- "$tmp"
}
