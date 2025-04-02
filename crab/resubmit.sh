#!/bin/bash

# Define directories, token, and chat ID
CRAB_DIR="crab_projects"
TOKEN="8000474220:AAEYEKs0Iw-TwIIUkkGgFDyjLkv2z-VkXW4"
CHATID="854572446"
UNFINISHED="unfinished_tasks.txt"
TEMP_FILE="unfinished_tasks.tmp"  # Fixed variable name
NTHREAD=20

# Initialize temporary file
: > "$TEMP_FILE"

if [ ! -f "$UNFINISHED" ]; then
    echo "No ${UNFINISHED} found. Checking all crab jobs..."
    ls -d ${CRAB_DIR}/crab_* | xargs -P $NTHREAD -I{} bash -c '
        project="{}"
        # Run crab status and redirect output to a log file
        crab status -d "$project" > "$project/crab_status.log" 2>&1
        # Check for unfinished tasks
        if ! grep -Eq "Jobs status:\s+finished\s+.*100\.0%" "$project/crab_status.log"; then
            echo "Unfinished tasks detected in $project, resubmitting..."
            crab resubmit -d "$project"
            echo "$project" >> '"$TEMP_FILE"'
        else
            echo "All tasks complete in $project."
        fi
    '
else
    echo "Using existing $UNFINISHED to check tasks..."
    cat "$UNFINISHED" | xargs -P $NTHREAD -I{} bash -c '
        project="{}"
        crab status -d "$project" > "$project/crab_status.log" 2>&1
        if ! grep -Eq "Jobs status:\s+finished\s+.*100\.0%" "$project/crab_status.log"; then
            echo "Still unfinished: $project, resubmitting..."
            crab resubmit -d "$project"
            echo "$project" >> '"$TEMP_FILE"'
        else
            echo "Finished: $project"
        fi
    '
fi

# Update unfinished_tasks.txt with the temporary file contents
mv "$TEMP_FILE" "$UNFINISHED"

# Send Telegram notification if there are no unfinished tasks
if [ ! -s "$UNFINISHED" ]; then
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        -d chat_id="${CHATID}" \
        -d text="Notification: All CRAB tasks completed successfully."
    echo "All tasks finished. Notification sent."
else
    echo "Remaining unfinished tasks:"
    cat "$UNFINISHED"
fi
