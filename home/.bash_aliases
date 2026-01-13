possibly_cd () {
    if [ $# = 1 ]; then
        cd "$1"
    elif [ $# -gt 1 ]; then
        echo "too many arguments"
	false
    fi
}

_cd_then () {
    local to="$1"; shift
    if [ $# = 1 ]; then
        local old=$(pwd)
	local oldOLDPWD=$OLDPWD
        if cd "$to" && cd "$1"; then
	    OLDPWD=$old
	else
	    cd "$old"
	    OLDPWD=$oldOLDPWD
	fi
    elif [ $# -gt 1 ]; then
        echo "too many arguments"
	false
    else
	cd "$to"
    fi
}

u () { _cd_then .. "$@"; }
uu () { _cd_then ../.. "$@"; }
uuu () { _cd_then ../../.. "$@"; }
uuuu () { _cd_then ../../../.. "$@"; }
uuuuu () { _cd_then ../../../../.. "$@"; }
ul () { cd ..;  l "$@"; }
les () { less "$@"; }
c () { cd "$@"; }
cdnewdir () {
    if [ "$#" -eq 1 ]; then
        mkdir -p "$1" && cd "$1"
    else
        echo One argument required
	false
    fi
};
mvcdnewdir () {
    if [ "$#" -gt 1 ]; then
        mvnewdir "$@" && cd "${!#}"
    else
        echo At least two arguments expected
	false
    fi
};
mvcd () {
    if [ "$#" -gt 1 ]; then
        if [ -d "${!#}" ]; then
            mv "$@" && cd "${!#}"
        else
            # echo Last argument is not a directory
            if [ "$#" -eq 2 ]; then
                if [ -d "$1" ]; then
                    mv "$@" && cd "${!#}"
                else
                    echo Neither argument is a directory
		    false
                fi
            else
                echo More than two arguments and last one is not a directory
		false
            fi
        fi
    else
        echo At least two arguments expected
	false
    fi
}

cdgit() {
    local d
    if d=$(git rev-parse --git-dir); then
        cd "$d/.."
    else
        false
    fi
}

_ls_newest () {
    local n
    n="$1"
    local opts
    opts="$2"
    shift
    shift
    lastdir --depth "$n" --fullpath $opts -- "$@"
}
cd_newest_sisterfolder () {
    local n
    n="${1-0}"
    local opts
    opts="${2-}"
    cd "$(_ls_newest "$n" "$opts" ..)"
}
cd_newest () {
    local n
    n="${1-0}"
    local opts
    opts="${2-}"
    cd "$(_ls_newest "$n" "$opts" .)"
}
cdat() {
    cdnewdir "$(dat --day --week "$@")"
}
cdn () {
    local opts
    opts=""
    if [ "${1-}" = "-a" ]; then
        opts="-a"
        shift
    fi
    if [ $# -eq 0 ]; then
	cd_newest 0 "$opts"
    else
        cdnewdir "$@"
    fi
}
cdnn () {
    local opts
    opts=""
    if [ "${1-}" = "-a" ]; then
        opts="-a"
        shift
    fi
    if [ $# -eq 0 ]; then
	cd_newest 1 "$opts"
    else
	cd_newest 0 "$opts"
        cdnewdir "$@"
    fi
}
cdnnn () {
    local opts
    opts=""
    if [ "${1-}" = "-a" ]; then
        opts="-a"
        shift
    fi
    if [ $# -eq 0 ]; then
	cd_newest 2 "$opts"
    else
	cd_newest 1 "$opts"
        cdnewdir "$@"
    fi
}
cdnnnn () {
    local opts
    opts=""
    if [ "${1-}" = "-a" ]; then
        opts="-a"
        shift
    fi
    if [ $# -eq 0 ]; then
	cd_newest 3 "$opts"
    else
	cd_newest 2 "$opts"
        cdnewdir "$@"
    fi
}
cdnnnnn () {
    local opts
    opts=""
    if [ "${1-}" = "-a" ]; then
        opts="-a"
        shift
    fi
    if [ $# -eq 0 ]; then
	cd_newest 4 "$opts"
    else
	cd_newest 3 "$opts"
        cdnewdir "$@"
    fi
}
cdnnnnnn () {
    local opts
    opts=""
    if [ "${1-}" = "-a" ]; then
        opts="-a"
        shift
    fi
    if [ $# -eq 0 ]; then
	cd_newest 5 "$opts"
    else
	cd_newest 4 "$opts"
        cdnewdir "$@"
    fi
}
cdnnnnnnn () {
    local opts
    opts=""
    if [ "${1-}" = "-a" ]; then
        opts="-a"
        shift
    fi
    if [ $# -eq 0 ]; then
	cd_newest 6 "$opts"
    else
	cd_newest 5 "$opts"
        cdnewdir "$@"
    fi
}
