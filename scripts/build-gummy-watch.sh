#!/usr/bin/env bash
# Build gummy-watch Go binary

set -euo pipefail

# Go to repo root (parent of scripts directory)
cd "$(dirname "$0")/.."

echo "Building gummy-watch..."
go build -o gummy-watch gummy-watch.go

echo "✓ Built successfully: gummy-watch"
