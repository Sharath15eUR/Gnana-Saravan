#!/bin/bash
#Author : Sri Gnana Saravan.N 
#Date : 31.01.2025
#This Script is written to automate the file creation tasks based on the user input

clear
b=0
echo How many files do you wanna create?
read a
if [ "$a" -eq  0 ]
then 
   echo No file has been created
elif [ "$a" -gt 0 ]
then 
   mkdir "file_$b"
   cd "file_$b/"
   for i in $(seq 1 $a)
   do
      touch file$i.txt
   done
echo Files created successfully
b=$((b+1))
else
      echo Enter the valid no of files
fi




#!/bin/bash
# Author: Sri Gnana Saravan.N 
# Date: 27.01.2025
# This script is written to backup text files to another directory.

clear
echo "Mention the Source directory, Destination directory, and the file extension (e.g., .txt)"
read SOURCE_DIR DES_DIR EXT
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Source directory does not exist."
    exit 1
fi
if [ ! -d "$DES_DIR" ]; then
    echo "Destination directory does not exist. Creating new destination directory"
    mkdir -p "$DES_DIR"
    
    if [ $? -ne 0 ]; then
        echo "Failed to create destination directory."
        exit 1
    fi
    echo "Destination directory created."
fi
cd "$SOURCE_DIR" || { echo "Failed to navigate to source directory."; exit 1; }
FILES=(*"$EXT")
if [ ${#FILES[@]} -eq 0 ]; then
    echo "No files with the extension $EXT found in the source directory."
    exit 1
fi
BACKUP_COUNT=0
TOTAL_SIZE=0
export BACKUP_COUNT=0

echo "Files to be backed up:"
for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        FILE_SIZE=$(stat -c %s "$FILE")
        echo "File: $FILE, Size: $FILE_SIZE bytes"
        TOTAL_SIZE=$((TOTAL_SIZE + FILE_SIZE))
        BACKUP_COUNT=$((BACKUP_COUNT + 1))
    fi
done
echo "Starting the backup process..."
for FILE in "${FILES[@]}"; do
    if [ -f "$FILE" ]; then
        BACKUP_FILE="$DES_DIR/$(basename "$FILE")"

        # If file exists in the destination, compare timestamps
        if [ -e "$BACKUP_FILE" ]; then
            SOURCE_TIME=$(stat -c %Y "$FILE")
            BACKUP_TIME=$(stat -c %Y "$BACKUP_FILE")

            if [ "$SOURCE_TIME" -gt "$BACKUP_TIME" ]; then
                echo "Overwriting $BACKUP_FILE with newer version of $FILE"
                cp -f "$FILE" "$BACKUP_FILE"
            else
                echo "Skipping $FILE as backup is up to date."
            fi
        else
            echo "Backing up $FILE to $DES_DIR"
            cp "$FILE" "$BACKUP_FILE"
        fi
    fi
done

# Generate the backup report
REPORT_FILE="$DES_DIR/backup_report.log"
{
    echo "Backup Report - $(date)"
    echo "--------------------------"
    echo "Total files processed: $BACKUP_COUNT"
    echo "Total size of files backed up: $TOTAL_SIZE bytes"
    echo "Backup directory: $DES_DIR"
    echo "--------------------------"
} > "$REPORT_FILE"

echo "Backup completed successfully. Report saved to $REPORT_FILE."
exit 0
