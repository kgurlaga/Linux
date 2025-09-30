#!/usr/bin/env bash
set -euo pipefail

# permtool.sh - prosty skrypt do tworzenia plików/katalogów i nadawania uprawnień
# Usage: permtool.sh [options] --action create|apply --target <path> [--owner user:group] [--mode 750]
# or: permtool.sh --batch sample.conf

VERSION = "0.1"
DRY_RUN = 0
VERBOSE = 0
ACTION = ""
TARGET = ""
OWNER = ""
MODE = ""
BATCH_FILE = ""

usage(){
    cat <<EOF
permtool.sh v${VERSION}

Usage:
    permtool.sh --action create --target /path/to/dir --owner user:group --mode 700 [--dry-run] [--verbose]
    permtool.sh --action apply  --target /path/to/file --owner user:group --mode 644
    permtool.sh --batch sample.conf

Options:
    --action create|apply   Create parent(s) and apply permissions
    --target PATH           Target path (file or directory)
    --owner user:group      Owner and group (optional)
    --mode MODE             Permission mode (numeric like 700 or symbolic lie u+rwx)
    --dry-run               Show what would be done
    --verbose               Verbose output
    --batch FILE            Process a config file (see sample.conf)
    -h, --help              Show this help
EOF
}

_log(){
    if [[ $VERBOSE -eq 1 ]]; then
        echo "[permtool] $*"
    fi
}

_run(){
    if [[ $DRY_RUN -eq 1 ]]; then
        echo "DRY-RUN: $*"
    else
        eval "$@"
    fi
}

apply_one(){
    local path = "$1"
    local owner = "$2"
    local mode = "$3"

    if [[ -z "$path" ]]; then
        echo "Empty path" > &2
        return 1
    fi

    # jeśli action=create to utwórz (jako katalog jeśli kończy się / lub nie istnieje)
    if [[ "$ACTION" == "create" ]]; then
        if [[ -e "$path" ]]; then
            _log "$path already exists"
        else
            if [[ "${path: -1}" == "/" ]]; then
                _run mkdir -p -- "$path"
            else
                # jeśli ma rozszerzenie, utwórz plik, inaczej katalog
                if [[ "$path" == *.* ]]; then
                    dirname = "$(dirname "$path")"
                    _run mkdir -p -- "$dirname"
                    _run touch -- "$path"
                else
                    _run mkdir -p -- "$path"
                fi
            fi
        fi
    fi

    # chown
    if [[ -n "$owner" ]]; then
        _log "chown $owner '$path'"
        _run sudo chown "$owner" -- "$path"
    fi

    # chmod
    if [[ -n "$mode" ]]; then
    _log "chmod $mode '$path'"
    _run chmod "$mode" -- "$path"
    fi

    return 0
}
