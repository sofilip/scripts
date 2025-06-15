#!/bin/bash

read -p "Please enter the full path of the directory to organize: " TARGET_DIR

# i. Validate if the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: The directory '$TARGET_DIR' does not exist !"
    exit 1
fi

echo "Starting file organization in directory: '$TARGET_DIR'"

NO_EXTENSION_DIR="$TARGET_DIR/no_extension"
# ii. Create the 'no_extension' subdirectory if it doesn't exist
if [ ! -d "$NO_EXTENSION_DIR" ]; then
    mkdir -p "$NO_EXTENSION_DIR" || { echo "Error: Failed to create subdirectory '$NO_EXTENSION_DIR'"; exit 1; }
    echo "Created subdirectory: '$NO_EXTENSION_DIR'"
fi

find "$TARGET_DIR" -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' FILE; do
    FILENAME=$(basename "$FILE")
    TARGET_SUBDIR=""

    if [[ "$FILENAME" == .* && "${FILENAME:1}" != *.* && "$FILENAME" != "." && "$FILENAME" != ".." ]]; then
        TARGET_SUBDIR="$NO_EXTENSION_DIR"
        echo "Detected dotfile '$FILENAME' without a standard extension. Moving to 'no_extension'"
    else
        EXTENSION="${FILENAME##*.}"

        # iv. Files with no extension
        if [ "$EXTENSION" = "$FILENAME" ] || [ -z "$EXTENSION" ]; then
            TARGET_SUBDIR="$NO_EXTENSION_DIR"
            echo "Detected file '$FILENAME' with no extension or an empty extension. Moving to 'no_extension'"
        else
            TARGET_SUBDIR="$TARGET_DIR/$EXTENSION"
            if [ ! -d "$TARGET_SUBDIR" ]; then
                mkdir -p "$TARGET_SUBDIR" || { echo "Error: Failed to create subdirectory '$TARGET_SUBDIR'"; continue; }
                # Create the subdirectory for the extension if it doesn't exist
                echo "Created subdirectory: '$TARGET_SUBDIR'"
            fi
            echo "Detected file '$FILENAME' with extension '$EXTENSION'. Moving to '$EXTENSION'"
        fi
    fi
    # iii. Move the file to the appropriate subdirectory
    mv "$FILE" "$TARGET_SUBDIR/" 2>/dev/null || echo "Warning: Could not move '$FILENAME'. Permissions issue, file already exists, or destination is a file !"
done

# v. Inform the user about the completion of the process
echo "File organization process completed successfully !"