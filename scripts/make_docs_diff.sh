#!/usr/bin/env bash
# create a git diff of the docs files

# space-separated list of files
FILES=${FILES:-"README.md docs.md"}
# regex of authors
AUTHORS=${AUTHORS:-$(git config user.name)}
MAXDATE=${MAXDATE:-$(date -u +"%Y-%m-%dT%H:%M:%S")}
MINDATE=${MINDATE:-$(date -d "$(date -d "$MAXDATE" "+%Y-%m-%d") -$(( ($(date -d "$MAXDATE" "+%u") + 7 - 4) % 7 + ($(date -d "$MAXDATE" "+%u") == 4 && $(date -d "$MAXDATE" "+%H") < 11) * 7)) days 11:00:00" "+%Y-%m-%dT%H:%M:%S")}

# shellcheck disable=SC2086
git log --pretty=format:"%h%x09%ad" --patch --date=iso --reverse --since="$MINDATE" --until="$MAXDATE" --perl-regexp --author="$AUTHORS" -- $FILES 
