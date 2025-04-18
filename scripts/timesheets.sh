#!/bin/bash

# Hardcoded variables for Harvest API
ACCESS_TOKEN=$HARVEST_PAT
ACCOUNT_ID="147488"
USER_ID="5087166"
PROJECT_ID="44185352" # Palma
TASK_ID="15929584" # Entwicklung
HOURS=8

# Default date is today
SPENT_DATE=$(date +"%Y-%m-%d")

# Function to validate date format (YYYY-MM-DD)
validate_date() {
    if [[ ! $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "Error: Date '$1' is not in ISO 8601 format (YYYY-MM-DD)"
        exit 1
    fi
}

# Function to log time for a specific date
log_time() {
    local date=${1:-$SPENT_DATE}
    local notes=$(bash ./gitlab-activity.sh $date)
    
    if [ -z "$notes" ] || [ "$notes" = "null" ]; then
        notes="\"No coding activity\""
    fi
     
    curl "https://api.harvestapp.com/v2/time_entries" \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -H "Harvest-Account-Id: $ACCOUNT_ID" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "{\"user_id\":$USER_ID,\"project_id\":$PROJECT_ID,\"task_id\":$TASK_ID,\"spent_date\":\"$date\",
          \"notes\":$notes, \"hours\":$HOURS}"
    
    echo "Time entry logged for $date"
}

# Function to log time for a date range
log_time_range() {
    local start_date=$1
    local end_date=$2
    
    # Extract year, month, and day parts
    local year_month="${start_date:0:8}"
    local start_day="${start_date:8:2}"
    local end_day="${end_date:8:2}"       # Get DD part (last 2 chars)
    
    local start_day_int=$((10#$start_day))
    local end_day_int=$((10#$end_day))
    
    if [ $start_day_int -gt $end_day_int ]; then
        echo "Error: Start date must be before end date"
        exit 1
    fi
    
    for ((day=start_day_int; day<=end_day_int; day++)); do
        # Format day with leading zero if needed
        local day_formatted=$(printf "%02d" $day)
        local current_date="${year_month}${day_formatted}"
        log_time "$current_date"
    done
    
    echo "Time entries logged for all dates from $start_date to $end_date"
}

# Display usage information
usage() {
    echo "Usage:"
    echo "  $0                          # Log time for today"
    echo "  $0 YYYY-MM-DD               # Log time for specific date"
    echo "  $0 YYYY-MM-DD YYYY-MM-DD    # Log time for date range (inclusive)"
    exit 1
}

# Main script logic
case $# in
    0)
        # No arguments, use today's date
        log_time
        ;;
    1)
        # Single date provided
        validate_date "$1"
        log_time "$1"
        ;;
    2)
        # Date range provided
        validate_date "$1"
        validate_date "$2"
        log_time_range "$1" "$2"
        ;;
    *)
        usage
        ;;
esac

