# nav 
**Efficiently navigate the filesystem in the terminal with the power of typing!**

https://github.com/slein-nl/nav/assets/13536345/23b38b11-0635-4cd8-b6b3-e0c492727503

## Keymaps
 ```
enter/down - enter directory/open file in $EDITOR (depending on file type)
up         - enter previous directory
tab        - move file selection forwards
shift+tab  - move file selection backwards
ctrl+u     - move one page up
ctrl+d     - move one page down
ctrl+c     - exit without changing directory
esc        - exit and change directory*
 ```
*nav spawns a new shell by default when pressing esc unless nav is run with the wrapper

## cd on exit wrapper
add this to your bashrc/zshrc and launch nav with "n" to enable in-shell cd on exit
```
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
```

## Building
To install:
```
sudo make release install
```
To make debug build:
```
make debug 
```
you can also compile with time measurements by adding TIME=1 to the command, for example:
```
sudo make release TIME=1
```
