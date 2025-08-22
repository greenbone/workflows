#!/bin/sh
# SPDX-FileCopyrightText: 2025 Greenbone A G
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Purpose: Merge *HTML-only* artifacts (eg: html-en/, html-de) into a single pages site.
# Behavior: Finds index.html in sub-folders and writes a root index.html that links to them.
# Notes: 
#   - No wrapper; non-HTML outputs are ignored.
#   - Designed to run inside the workflow after artifacts are extracted to $BASE_DIR.

set -euo

#------------------------------------------------------------------------------------------------------------------------------
#   Configuration 
#------------------------------------------------------------------------------------------------------------------------------
BASE_DIR=${BASE_DIR:-./merged}                                  # where artifacts (html-en, html-de) are extracted.
BASE_URL=${BASE_URL:-http://localhost/}                         # only used for printing URLs to logs

if [ ! -d "$BASE_DIR" ]; then
    echo "ERROR: Base_DIR does not exist: $BASE_DIR" >&2
    exit 1
fi

# TEMPORARY FILES; auto-clean on exit
ITEMS_LIST_FILE="$(mktemp)"                                     # stores rendered <li> links
ENTRIES_LIST_FILE="$(mktemp)"                                   # stores entry relative paths (for logging)  
trap 'rm -f -- "$ITEMS_LIST_FILE" "$ENTRIES_LIST_FILE"' EXIT

FIRST_ENTRY_RELATIVE_PATH=""
#--------------------------------------------------------------------------------------------------------------------------------
#   Find index.html within directory (depth 0..2) Return path relative to directory or empty.
#--------------------------------------------------------------------------------------------------------------------------------
find_first_index_start() {
    directory_path=$1

    # Check depth 0, 1, 2
    for candidate_path in "$directory_path"/index.html "$directory_path"/*/index.html "$directory_path"/*/*/index.html
    do
        if [ -f "$candidate_path" ]; then
            case $candidate_path in
                "$directory_path"/*) relative_path=${candidate_path#"$directory_path"/};;
                *)                   relative_path=${candidate_path##*/};;
            esac
            echo "$relative_path"
            return 0 
        fi
    done
    return 1
}

#----------------------------------------------------------------------------------------------------------------------------------------------------
#   Collect HTML entries (eg: html-en/index.html, html-de/index.html)
#----------------------------------------------------------------------------------------------------------------------------------------------------

for artifact_directory in "$BASE_DIR"/*/; do
    [ -d "$artifact_directory" ] || continue
    artifact_folder_name="$(basename "$artifact_directory")"

    index_relative_path="$(find_first_index_start "$artifact_directory" || true)"
    [ -n "$index_relative_path" ] || continue       # skip non-HTML artifact folder

    # Record for the final URL printout
    entry_relative_path="$artifact_folder_name/$index_relative_path"
    printf '%s\n' "$entry_relative_path" >> "$ENTRIES_LIST_FILE"
    printf '%s\n' "<li><a href=\"./$entry_relative_path\">$artifact_folder_name</a></li>" >> "$ITEMS_LIST_FILE"

    if [ -z "$FIRST_ENTRY_RELATIVE_PATH" ]; then
        FIRST_ENTRY_RELATIVE_PATH="$entry_relative_path"
    fi
done

# Must have at least one HTML entry
if [ ! -s "$ITEMS_LIST_FILE" ]; then
    echo "ERROR: no index.* found under $BASE_DIR/*/" >&2
    rm -f -- "$ITEMS_LIST_FILE"
    exit 1 
fi

# Write root index.html next to merged content
cat > "$BASE_DIR/index.html" <<ROOT_EOF
<!doctype html>
<meta charset="utf-8">
<title>Docs</title>
<ul>
$(cat "$ITEMS_LIST_FILE")
</ul>
ROOT_EOF

# confirm root index.html
if [ -f "$BASE_DIR/index.html" ]; then
    echo " ROOT index created at $BASE_DIR/index.html"
    cat "$BASE_DIR/index.html"
else 
    echo " NO ROOT index created at $BASE_DIR/index.html"
    exit 1
fi

rm -f -- "$ITEMS_LIST_FILE"
# Print URLs for quick local check
echo "Base URL: $BASE_URL"
echo "Root: ${BASE_URL%/}/"
while IFS= read -r entry_relative_path; do
    [ -n "$entry_relative_path" ] || continue
    echo " - ${BASE_URL%}$entry_relative_path"
done <"$ENTRIES_LIST_FILE"