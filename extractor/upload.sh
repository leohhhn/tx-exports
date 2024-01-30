#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <extractor_dir>"
    exit 1
fi

root_dir="$1"

go run . --source-dir ../test3.gno.land --file-type .log --output-dir "$root_dir"

cd "$root_dir" || { echo "Failed to change to directory $root_dir"; exit 1; }

find . -type f -name "*.json" | while read json_file; do
    pkg_dir=$(dirname "$json_file")
    git add "$pkg_dir"
    git commit -m "Add package: $pkg_dir"
done