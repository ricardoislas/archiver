#!/bin/bash

# Configuration
default_backup_dir="/home/admin/backups"
backup_dir="${BACKUP_DIR:-$default_backup_dir}"
excluded_paths=(
    "node_modules"
    ".git"
)

# Remove trailing slash from backup_dir if present
backup_dir=${backup_dir%/}

# Function to create a backup
create_backup() {
    source_folder="$1"
    timestamp=$(date +"%Y%m%d%H%M%S")
    folder_name=$(basename "$source_folder")
    backup_name="${folder_name}_${timestamp}.tar.gz"
    backup_path="${backup_dir}/${backup_name}"

    # Check if source folder exists
    if [ ! -d "$source_folder" ]; then
        echo "Source folder not found: $source_folder"
        exit 1
    fi

    # Check if backup directory exists, if not exit
    if [ ! -d "$backup_dir" ]; then
        echo "Backup directory not found: $backup_dir"
        exit 1
    fi

    echo "Source folder: $source_folder"
    echo "Backup destination: $backup_path"

    echo "Excluded paths:"
    for path in "${excluded_paths[@]}"; do
        echo "- $path"
    done

    excluded_options=()
    for path in "${excluded_paths[@]}"; do
        excluded_options+=("--exclude=$path")
    done

    tar_command="tar czvf \"$backup_path\" ${excluded_options[*]} -C \"$source_folder\" ."
    echo "Preview of the tar command:"
    echo "$tar_command"

    while true; do
        read -p "Proceed with backup? (y/n): " choice
        case "$choice" in
            y|Y) break ;;
            n|N) echo "Backup canceled." && exit 0 ;;
            *) echo "Invalid choice. Please enter 'y' or 'n'." ;;
        esac
    done

    # Create a compressed archive of the source folder, excluding specified paths
    eval "$tar_command"

    if [ $? -eq 0 ]; then
        echo "Backup created successfully: $backup_path"
    else
        echo "Backup creation failed."
    fi
}

# Check if source folder argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <source_folder>"
    exit 1
fi

create_backup "$1"
