# Provided by Sean Santos 7-10-13

# I wanted to send something out that I've found useful in Bash login
# scripts. The attachment defines three very short functions:

# declare_path - Using "declare_path PATH /sbin" will add /sbin to the
# end of PATH if and only if it's not already there. Also works with
# other colon-separated lists, e.g. "declare_path LD_LIBRARY_PATH
# ~/lib/foo".
#
# declare_path_early - Same as declare_path, except that if it adds a
# path, it will add it to the beginning.
#
# not_in_colon_list - Used by the other two
# functions. "not_in_colon_list $PATH /usr/bin" will exit 1 if
# /usr/bin is in your path, and exit 0 if it is not.

# These don't do anything smart like checking for extra slashes
# (e.g. "/usr//bin").


not_in_colon_list () {
    # Determines if $2 is in the list of colon-separated values $1.
    local regex="(^|:)$2(:|$)"
    if [[ "$1" =~ $regex ]]; then
        return 1
    else
        return 0
    fi
}

declare_path () {
    # If string $2 is not in the colon-separated list named $1, then
    # add it to that list variable.
    # Note that you provide the name, not the value, of the list variable.
    if not_in_colon_list "${!1}" "$2"; then
        if [[ -n "${!1}" ]]; then
            eval "$1+=\":$2\""
        else
            eval "$1=\"$2\""
        fi
        export "$1"
    fi
}

declare_path_early () {
    # Same as declare_path, only add to the beginning of the list.
    if not_in_colon_list "${!1}" "$2"; then
        if [[ -n "${!1}" ]]; then
            eval "$1=\"$2:${!1}\""
        else
            eval "$1=\"$2\""
        fi
        export "$1"
    fi
}
