#!/bin/bash

# i. Ask the user for the full path of the log file to monitor
read -p "Please enter the full path of an existing log file (e.g., /var/log/syslog or /var/log/auth.log): " SOURCE_FILE

# Validate if the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: The file '$SOURCE_FILE' does not exist !"
    exit 1
fi

# Validate if the source file is readable
if [ ! -r "$SOURCE_FILE" ]; then
    echo "Error: The file '$SOURCE_FILE' is not readable !"
    exit 1
fi

echo "Monitoring log file: $SOURCE_FILE"

# Create report file name
REPORT_FILE="$HOME/important_$(basename "$SOURCE_FILE")_$(date +%Y%m%d).log"
if [ -f "$REPORT_FILE" ]; then
    echo "Warning: Report file '$REPORT_FILE' already exists. It will be overwritten"
fi

# ii. Search and save all lines containing specific keywords
echo "Searching for important log entries (error, warning, critical)..."

# iii. Check if any entries were found and save them to a report file
if grep -i "error\|warning\|critical" "$SOURCE_FILE" > "$REPORT_FILE" 2>/dev/null; then
    if [ -s "$REPORT_FILE" ]; then
        echo "Important log entries found and saved to: $REPORT_FILE"
        echo "Number of entries found: $(wc -l < "$REPORT_FILE")"
        
        # iv. Show a preview of found entries
        echo "Preview of found entries:"
        head -n 5 "$REPORT_FILE"
        if [ "$(wc -l < "$REPORT_FILE")" -gt 5 ]; then
            echo "... (showing first 5 entries)"
        fi
    else
        echo "No important log entries found in '$SOURCE_FILE'"
        rm -f "$REPORT_FILE"  # Remove the empty report file
        exit 0
    fi
else
    echo "No important log entries found in '$SOURCE_FILE'."
    rm -f "$REPORT_FILE"  # Remove any empty file that might have been created
    exit 0
fi

# Delete report files older than 7 days
echo "Cleaning up old report files..."
find "$HOME" -name "important_*.log" -type f -mtime +7 -delete 2>/dev/null || {
    echo "Warning: Could not clean up some old report files. Manual cleanup may be needed"
}

echo "Log monitoring process completed successfully !"