#!/bin/bash

# Function to recursively rename .ts files to .js and .tsx files to .jsx
rename_files() {
    local dir="$1"
    local files=()
    local subdirs=()

    # Read all files and subdirectories in the current directory
    while IFS= read -r file; do
        if [[ -d "$file" ]]; then
            # Exclude the 'node_modules' directory
            if [[ "$file" != *"node_modules"* ]]; then
                # Add subdirectory to the list for recursive renaming
                subdirs+=("$file")
            fi
        elif [[ -f "$file" ]]; then
            # Check if the file has .ts or .tsx extension and rename it accordingly
            if [[ "$file" == *.ts ]]; then
                new_name="${file%.ts}.js"
                mv "$file" "$new_name"
                echo "Renamed: $file -> $new_name"
            elif [[ "$file" == *.tsx ]]; then
                new_name="${file%.tsx}.jsx"
                mv "$file" "$new_name"
                echo "Renamed: $file -> $new_name"
            fi
        fi
    done < <(find "$dir" -mindepth 1 -not -path "*/node_modules/*")

    # Recursively call the function for subdirectories
    for subdir in "${subdirs[@]}"; do
        rename_files "$subdir"
    done
}

# Start renaming files from the current directory
rename_files .

echo "File renaming complete."
