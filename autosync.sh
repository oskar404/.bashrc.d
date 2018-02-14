#!/bin/bash
#
# Sync git repositories
#
# This script is intended to be used with crontab
#

SCRIPT=$(basename "$0")
REPOS=()
PUSH="yes"

function usage() {
    echo "usage: ${SCRIPT} [-n] <git-dir> [<git-dir> ..]"
    echo ""
    echo "  -h/--help       Produce this help"
    echo "  -n/--dry-run    Do all steps except do not push to remote"
    echo ""
    echo "This script synchronizes git repositories with remote. The steps"
    echo "taken are:"
    echo ""
    echo "  git pull --rebase"
    echo "  git commit -a -m \"Auto-commit\""
    echo "  git push"
    echo ""
    exit 1
}

# Check that all references are git repositories
function validate() {
    for repo in $@
    do
        [ ! -d "${repo}"/.git ] && echo "Invalid git repo: ${repo}" && exit 3
    done
}

# Sync the git repositories
function synchronize() {
    for repo in $@
    do
        cd "$1"
        git pull --rebase
        git commit -a -m "Auto-commit"
        [ -n ${PUSH} ] && git push
        cd -
    done
}

# Handle args
while [ "$1" != "" ]; do
    case "$1" in
      -h)
        usage
        ;;
      --help)
        usage
        ;;
      -n)
        unset PUSH
        ;;
      --dry-run)
        unset PUSH
        ;;
      *)
        REPOS=("${REPOS[@]}" "$1")
    esac
    shift
done

[ ${#REPOS[@]} -eq 0 ] && echo "No git repos defined" && exit 2

validate ${REPOS[@]}
synchronize ${REPOS[@]}

