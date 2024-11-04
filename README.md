# GitHub User ID Fetcher

A bash script that fetches GitHub user IDs from a list of usernames and outputs the results to a CSV file. This tool is useful for bulk collecting GitHub user IDs for data analysis or integration purposes.

## Rate Limiting Warning ⚠️

This tool uses the GitHub API which has rate limiting restrictions:
- For unauthenticated requests: 60 requests per hour
- For authenticated requests: 5,000 requests per hour
- The script includes a built-in delay mechanism and rate limit handling

## Prerequisites

Before using this tool, you need to have the following installed:

1. `bash` (comes pre-installed on most Unix-based systems)
2. `curl` for making HTTP requests
3. `jq` for JSON parsing

### Installing Prerequisites

#### On Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install curl jq
```

#### On macOS (using Homebrew):
```bash
brew install jq
```

#### On CentOS/RHEL:
```bash
sudo yum install curl jq
```

## Installation

1. Clone this repository:
```bash
git clone [repository-url]
cd github-id-utils
```

2. Make the script executable:
```bash
chmod +x get_github_id.sh
```

## Usage

1. Create a CSV file containing GitHub usernames (one per line):
```bash
echo "torvalds" > github_users.csv
echo "octocat" >> github_users.csv
```

2. Run the script:
```bash
./get_github_id.sh github_users.csv
```

The script will:
- Process each username
- Create a new CSV file with results (named with timestamp)
- Show progress as it runs
- Provide a summary when complete

### Output Format

The output CSV file will contain:
- `username`: The GitHub username
- `github_id`: The user's GitHub ID (or NA if not found)
- `status`: Either "success" or an error message

Example output:
```csv
username,github_id,status
torvalds,1024025,success
octocat,583231,success
```

## Error Handling

The script handles several common issues:
- Rate limiting (waits if limit is reached)
- Malformed usernames
- Empty lines in input file
- API errors


## Contributing

Feel free to open issues or submit pull requests with improvements.

## License

MIT License - feel free to use this tool for any purpose.