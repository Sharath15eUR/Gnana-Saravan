#!/bin/bash

# Function to recursively search for files containing a specific keyword
search_files() {
    local directory="$1"
    local keyword="$2"
    if [ ! -d "$directory" ]; then
        echo "Error: Directory '$directory' not found." | tee -a errors.log
        return 1
    fi
    
    # Iterate over the files and subdirectories
    for file in "$directory"/*; do
        if [ -d "$file" ]; then
            # If it's a directory, call search_files recursively
            search_files "$file" "$keyword"
        elif [ -f "$file" ]; then
            # If it's a file, search for the keyword
            if grep -q "$keyword" "$file"; then
                echo "Keyword '$keyword' found in: $file"
            fi
        fi
    done
}

# Search for a keyword in a specific file
search_in_file() {
    local file="$1"
    local keyword="$2"
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found." | tee -a errors.log
        return 1
    fi
    if grep -q "$keyword" <<< "$(<"$file")"; then
        echo "Keyword '$keyword' found in: $file"
    else
        echo "Keyword '$keyword' not found in: $file"
    fi
}

# Function to display the help menu using a here document
show_help() {
    cat <<EOF
Usage: $0 [options]

Options:
  -d <directory>  Directory to search for files containing the keyword
  -k <keyword>    Keyword to search for in the files
  -f <file>       File to search for the keyword directly
  --help          Display this help menu

Examples:
  $0 -d logs -k error   # Recursively search 'logs' directory for 'error'
  $0 -f script.sh -k TODO   # Search 'script.sh' file for 'TODO'
  $0 --help   # Display this help menu
EOF
}

# Regular expression to validate non-empty keyword
keyword_regex="^[^[:space:]]+$"

if [ $# -eq 0 ]; then
    echo "Error: No arguments provided." | tee -a errors.log
    show_help
    exit 1
fi

while getopts "d:k:f:" opt; do
    case "$opt" in
        d)
            directory="$OPTARG"
            ;;
        k)
            keyword="$OPTARG"
            ;;
        f)
            file="$OPTARG"
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
done

if [[ -z "$keyword" || ! "$keyword" =~ $keyword_regex ]]; then
    echo "Error: Invalid or empty keyword." | tee -a errors.log
    exit 1
fi

if [ -n "$directory" ] && [ -n "$file" ]; then
    echo "Error: Cannot specify both directory and file to search." | tee -a errors.log
    exit 1
fi

# Handle missing or incorrect arguments
if [ -n "$directory" ] && [ -n "$keyword" ]; then
    # Recursively search the directory
    search_files "$directory" "$keyword"
elif [ -n "$file" ] && [ -n "$keyword" ]; then
    # Search directly in the specified file
    search_in_file "$file" "$keyword"
elif [ "$1" == "--help" ]; then
    # Display the help menu
    show_help
else
    echo "Error: Invalid arguments." | tee -a errors.log
    show_help
    exit 1
fi

# Display script feedback using special parameters
echo "Script name: $0"
echo "Number of arguments: $#"
echo "Arguments: $@"

# Exit with success status
exit 0
