#!/usr/bin/env bash
# Generate a markdown image gallery from images in a directory.
# Usage: readme-maker.sh [dir] [columns] > README.md

set -euo pipefail

dir="${1:-.}"
cols="${2:-3}"

# Collect image files (sorted, case-insensitive extension match)
shopt -s nullglob nocaseglob
cd "$dir"
files=()
for f in *.png *.jpg *.jpeg *.gif *.webp *.bmp; do
    files+=("$f")
done
shopt -u nullglob nocaseglob

if [ ${#files[@]} -eq 0 ]; then
    echo "No images found in '$dir'." >&2
    exit 1
fi

# Sort
IFS=$'\n' files=($(sort <<<"${files[*]}")); unset IFS

echo "# Gallery"
echo

# Header row + separator
printf '|'; for ((i=0; i<cols; i++)); do printf ' |'; done; echo
printf '|'; for ((i=0; i<cols; i++)); do printf ':---:|'; done; echo

# Body
col=0
for f in "${files[@]}"; do
    name="${f%.*}"
    [ "$col" -eq 0 ] && printf '|'
    printf ' ![%s](%s)<br>`%s` |' "$name" "$f" "$f"
    col=$((col + 1))
    if [ "$col" -eq "$cols" ]; then
        echo
        col=0
    fi
done

# Pad and close the last partial row
if [ "$col" -ne 0 ]; then
    while [ "$col" -lt "$cols" ]; do printf ' |'; col=$((col + 1)); done
    echo
fi
