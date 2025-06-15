#!/bin/bash

# i. Ask the user for the full path of the directory to back up
read -p "Please enter the full path of an existing directory you want to back up (e.g., /home/user/Desktop/MyPictures): " SOURCE_DIR

# Validate if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: The directory '$SOURCE_DIR' does not exist !"
    exit 1
fi

# Validate if the source directory is readable
if [ ! -r "$SOURCE_DIR" ]; then
    echo "Error: The directory '$SOURCE_DIR' is not readable !"
    exit 1
fi

# Define the backup directory
BACKUP_DIR="$HOME/backups"

# Create the backup directory if it doesn't exist
if ! mkdir -p "$BACKUP_DIR"; then
    echo "Error: Failed to create backup directory '$BACKUP_DIR'"
    exit 1
fi
echo "Backup directory set to '$BACKUP_DIR'."

# Extract the basename (the actual directory name) from SOURCE_DIR
DIR_BASENAME=$(basename "$SOURCE_DIR")

# Extract the parent directory of SOURCE_DIR
PARENT_DIR=$(dirname "$SOURCE_DIR")

# Get the current date and time for the backup file name
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# ii. Create the backup file name using the DIR_BASENAME
BACKUP_FILE="${BACKUP_DIR}/backup_${DIR_BASENAME}_${TIMESTAMP}.tar.gz"

echo "Creating backup of '$SOURCE_DIR'..."
# Create the backup file using tar
if ! tar -czf "$BACKUP_FILE" -C "$PARENT_DIR" "$DIR_BASENAME"; then
    echo "Error: Backup creation failed for '$SOURCE_DIR'."
    rm -f "$BACKUP_FILE" # Clean up partially created file
    exit 1
fi

echo "Backup of '$SOURCE_DIR' created successfully at '$BACKUP_FILE'"

echo "Backup completed successfully !"
echo "Backup saved to: $BACKUP_FILE"

# iii. Delete backups older than 7 days
echo "Cleaning up old backups..."

if ! find "$BACKUP_DIR" -name "backup_*.tar.gz" -type f -mtime +7 -delete; then
    echo "Warning: Failed to clean up some or all old backups. Manual check might be needed"
    exit 1
fi

echo "Old backups cleaned up successfully !"

# iv. Inform the user about the result (already done in the script)
echo "Backup process finished successfully !"