# Some cool and maybe usefull bash functions
# 
# source ${HOME}/.bashrc.d/bash_functions
#

# cd multiple levels down
# usage: cdn <number>
function cdn(){
    local LVL=${1:-0}
    local ARG=""
    for (( i=0; i<${LVL}; i++)) 
    do  
        ARG="${ARG}../"
    done
    cd "${ARG:-$HOME}"
}

# Convert uppercase file and folder names to lower case.
# usage: lcffile [-r] <dir>
function lcfile(){
    local DEPTH="-maxdepth 1"

    while [ "$1" != "" ];
    do
        case "$1" in
          -r)
            local DEPTH=""
            ;;
          *)
            local DIR=$1
        esac
        shift
    done

    if [ -z "${DIR}" ]; then
        echo "lcfile [-r] <dir>"
        return
    fi

    for SRC in $(find ${DIR} -depth ${DEPTH})
    do
        DST=$(dirname "${SRC}")/$(basename "${SRC}" | tr '[A-Z]' '[a-z]')
        if [ "${SRC}" != "${DST}" ]
        then
            echo ${DST}
            [ ! -e "${DST}" ] && mv -T "${SRC}" "${DST}" || echo "${SRC} was not renamed"
        fi
    done
}

# Generate a random password 
# usage: genpasswd [length]
function genpasswd() {
    local PWDLEN=${1:-32}
    tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${PWDLEN} | xargs
}

# Generate a PIN code
# usage: genpin [length]
function genpin() {
    local PINLEN=${1:-4}
    tr -dc 0-9 < /dev/urandom | head -c ${PINLEN} | xargs
}

# Ceasar cipher / ROT-13
# usage: rot13 [filename]
function rot13()
{
    if [  $# = 0 ] ; then
        tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
    else
        tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
    fi
}

# Show threads of a process
function atop() {
    local TESTAPP=$1
    if [ -n "${TESTAPP}" ]; then
        top -H -p $(pgrep ${TESTAPP})
    else
        echo "usage: atop <process-name>"
    fi
}

# List of most used commands in history 
# NB! If ignoredups and erasedups is used then the output may not be usefull
# usage: xtop [number]
function xtop() {
    local N=${1:-10}
    history | awk '{a[$2]++ } END{for(i in a){print a[i] " " i}}' | sort -rn | head -n $N; 
}

# Search with google / open browser
function @google {
    xdg-open "https://google.com/search?q=$*"
}

# For completeness: search with duckduckgo.com / open browser
function @duckduckgo {
    xdg-open "https://duckduckgo.com/?q=$*"
}

# Search from sanakirja.org. Translate from Finnish to English
function @sanakirja {
    xdg-open "https://www.sanakirja.org/search.php?l=17&l2=3&q=$*"
}
