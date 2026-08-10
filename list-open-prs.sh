#!/usr/bin/env bash

# List all open Pull Requests across all repositories with merge links
# Usage: ./list-open-prs.sh [--open]

set -euo pipefail

OPEN_IN_BROWSER=false

while [[ $# -gt 0 ]]; do
	case "$1" in
		--open|-o)
			OPEN_IN_BROWSER=true
			shift
			;;
		--help|-h)
			echo "Usage: $0 [--open]"
			exit 0
			;;
		*)
			echo "Unknown option: $1" >&2
			echo "Usage: $0 [--open]" >&2
			exit 1
			;;
	esac
done

if ! command -v gh &> /dev/null; then
	echo "Error: GitHub CLI (gh) is not installed." >&2
	exit 1
fi

echo "Fetching all your repositories..."
repos=$(gh repo list --limit 1000 --json nameWithOwner --jq '.[].nameWithOwner')

if [ -z "$repos" ]; then
	echo "No repositories found."
	exit 0
fi

echo ""
echo "Checking for open Pull Requests..."
echo "=================================="
echo ""

total_prs=0

while IFS= read -r repo; do
	prs=$(gh pr list --repo "$repo" --state open --json number,title,url,headRefName,author --jq '.[] | "\(.number)|\(.title)|\(.url)|\(.headRefName)|\(.author.login)"')
		
	if [ -n "$prs" ]; then
		echo "Repository: $repo"
		echo "-----------------------------------"

		while IFS='|' read -r number title url branch author; do
			((total_prs++))
			echo "  PR #$number: $title"
			echo "  Author: $author | Branch: $branch"
			echo "  View: $url"
			echo "  Files: $url/files"
			echo "  Quick merge command: gh pr merge $number --repo $repo --merge"
			echo ""
			if [ "$OPEN_IN_BROWSER" = true ]; then
				open "$url"
			fi
		done <<< "$prs"
		echo ""
	fi
done <<< "$repos"

if [ $total_prs -eq 0 ]; then
	echo "No open Pull Requests found across all repositories."
else
	echo "=================================="
	echo "Total open Pull Requests: $total_prs"
fi
