#!/bin/bash

# Check if input file was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_csv_file>"
    exit 1
fi

input_file="$1"
output_file="github_ids_$(date +%Y%m%d_%H%M%S).csv"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq to parse JSON responses."
    exit 1
fi

# Create output CSV with headers
echo "username,github_id,status" > "$output_file"

# Function to handle rate limiting
handle_rate_limit() {
    local reset_time=$(curl -s -I "https://api.github.com/users/dummy" | grep "x-ratelimit-reset:" | cut -d: -f2- | tr -d ' \r')
    local current_time=$(date +%s)
    local wait_time=$((reset_time - current_time))
    
    if [ $wait_time -gt 0 ]; then
        echo "Rate limit reached. Waiting for $wait_time seconds..."
        sleep $wait_time
    fi
}

# Process each username
while IFS=, read -r username || [ -n "$username" ]; do
    # Remove any whitespace or quotes
    username=$(echo "$username" | tr -d ' "')
    
    # Skip empty lines
    [ -z "$username" ] && continue
    
    echo "Processing username: $username"
    
    # Make API request to GitHub
    response=$(curl -s "https://api.github.com/users/$username")
    
    # Check for rate limiting
    if echo "$response" | grep -q "API rate limit exceeded"; then
        handle_rate_limit
        response=$(curl -s "https://api.github.com/users/$username")
    fi
    
    # Process the response
    if echo "$response" | jq -e 'has("id")' &> /dev/null; then
        user_id=$(echo "$response" | jq -r .id)
        echo "$username,$user_id,success" >> "$output_file"
        echo "✓ Found ID for $username: $user_id"
    else
        error_msg=$(echo "$response" | jq -r '.message // "Unknown error"')
        echo "$username,NA,error: $error_msg" >> "$output_file"
        echo "✗ Error processing $username: $error_msg"
    fi
    
    # Add a small delay to be nice to GitHub's API
    sleep 1
done < "$input_file"

echo "Processing complete! Results saved to: $output_file"
echo "Summary:"
echo "----------------------------------------"
echo "Total processed: $(grep -c "," "$output_file")"
echo "Successful: $(grep -c ",success" "$output_file")"
echo "Failed: $(grep -c ",error" "$output_file")"