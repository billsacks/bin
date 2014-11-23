#!/bin/sh
# From https://thomashunter.name/blog/set-opendiff-filemerge-as-your-git-diff-tool-on-os-x/

/usr/bin/opendiff "$2" "$5" -merge "$1"
