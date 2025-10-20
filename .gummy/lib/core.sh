#!/bin/bash
# .gummy/lib/core.sh - Core functions for persistent specialists

set -euo pipefail

GUMMY_DIR="${GUMMY_DIR:-.gummy}"
SPECIALISTS_DIR="$GUMMY_DIR/specialists"
REPORTS_DIR="$GUMMY_DIR/reports"

# Find specialist directory (project first, then global)
find_specialist() {
  local name="$1"

  if [[ -d "$SPECIALISTS_DIR/$name" ]]; then
    echo "$SPECIALISTS_DIR/$name"
  elif [[ -d "$HOME/.gummy/specialists/$name" ]]; then
    echo "$HOME/.gummy/specialists/$name"
  else
    echo ""
  fi
}

# Create a new specialist
create_specialist() {
  local name="$1"
  local initial_prompt="$2"
  local scope="${3:-project}"  # project or global

  if [[ "$scope" == "global" ]]; then
    local spec_dir="$HOME/.gummy/specialists/$name"
  else
    local spec_dir="$SPECIALISTS_DIR/$name"
  fi

  mkdir -p "$spec_dir"

  # Create system prompt
  cat > "$spec_dir/prompt.txt" <<EOF
You are $name, a specialized AI assistant.

$initial_prompt

## Your Workflow
At the end of each task, save a YAML report to:
$REPORTS_DIR/$name-{session_id}.yaml

Include:
- summary: What you accomplished
- files_modified: List of files changed
- learnings: Key discoveries or patterns
- recommendations: Suggestions for next steps
EOF

  # Create metadata
  cat > "$spec_dir/meta.yaml" <<EOF
name: $name
created: $(date -u +%Y-%m-%dT%H:%M:%SZ)
session_id: null
status: new
turns: 0
last_active: null
EOF

  echo "✓ Created $scope specialist: $name"
  echo "  Location: $spec_dir/"
}

# Resume or start a specialist session
resume_specialist() {
  local name="$1"
  local task="$2"
  local model="${3:-haiku}"

  # Find specialist
  local spec_dir=$(find_specialist "$name")

  if [[ -z "$spec_dir" ]]; then
    echo "Error: Specialist '$name' not found"
    echo "Create it first with: create_specialist '$name' 'description'"
    return 1
  fi

  local prompt_file="$spec_dir/prompt.txt"
  local session_file="$spec_dir/session.txt"
  local meta_file="$spec_dir/meta.yaml"

  # Read system prompt
  if [[ ! -f "$prompt_file" ]]; then
    echo "Error: No prompt file found for $name"
    return 1
  fi

  local system_prompt=$(cat "$prompt_file")

  # Check for existing session
  local session_id=""
  if [[ -f "$session_file" ]]; then
    session_id=$(cat "$session_file")
  fi

  if [[ -z "$session_id" ]]; then
    echo "=== Starting NEW session for $name ==="

    # New session with system prompt
    local response=$(claude -p \
      --model "$model" \
      --output-format json \
      --append-system-prompt "$system_prompt" \
      "$task" 2>&1)

    # Parse JSON array and extract result object (type:"result")
    session_id=$(echo "$response" | jq -r '.[] | select(.type == "result") | .session_id')
    local result_text=$(echo "$response" | jq -r '.[] | select(.type == "result") | .result')

    echo "$session_id" > "$session_file"

    # Update metadata
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    cat > "$meta_file" <<EOF
name: $name
created: $current_time
session_id: $session_id
status: active
turns: 1
last_active: $current_time
EOF

    echo "  Session ID: $session_id"
    echo ""
    echo "$result_text"
  else
    echo "=== Resuming session $session_id for $name ==="

    # Resume with same system prompt
    local response=$(claude -p \
      --resume "$session_id" \
      --append-system-prompt "$system_prompt" \
      --model "$model" \
      --output-format json \
      "$task" 2>&1)

    # Parse JSON array and extract result object (type:"result")
    local result_text=$(echo "$response" | jq -r '.[] | select(.type == "result") | .result')

    echo "$result_text"

    # Update metadata
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local created_time=$(grep "^created:" "$meta_file" | cut -d' ' -f2-)
    local current_turns=$(grep "^turns:" "$meta_file" | cut -d' ' -f2)
    ((current_turns++))

    cat > "$meta_file" <<EOF
name: $name
created: $created_time
session_id: $session_id
status: active
turns: $current_turns
last_active: $current_time
EOF
  fi
}

# Update specialist's knowledge base
update_specialist_knowledge() {
  local name="$1"
  local learning="$2"

  local spec_dir=$(find_specialist "$name")

  if [[ -z "$spec_dir" ]]; then
    echo "Error: Specialist '$name' not found"
    return 1
  fi

  local prompt_file="$spec_dir/prompt.txt"

  # Append to prompt (create learnings section if doesn't exist)
  if ! grep -q "## Learnings" "$prompt_file"; then
    echo -e "\n## Learnings" >> "$prompt_file"
  fi

  echo "- $(date +%Y-%m-%d): $learning" >> "$prompt_file"

  echo "✓ Updated $name's knowledge base"
}

# List all specialists
list_specialists() {
  echo "Available specialists:"
  echo ""

  # Project-level
  if [[ -d "$SPECIALISTS_DIR" ]]; then
    for spec_dir in "$SPECIALISTS_DIR"/*; do
      if [[ -d "$spec_dir" ]]; then
        local name=$(basename "$spec_dir")
        local meta_file="$spec_dir/meta.yaml"

        if [[ -f "$meta_file" ]]; then
          local status=$(grep "^status:" "$meta_file" | cut -d' ' -f2 || echo "unknown")
          local session=$(grep "^session_id:" "$meta_file" | cut -d' ' -f2 || echo "none")
          local turns=$(grep "^turns:" "$meta_file" | cut -d' ' -f2 || echo "0")

          echo "  📁 $name [project]"
          echo "     Status: $status | Turns: $turns"
          if [[ "$session" != "null" && "$session" != "none" ]]; then
            echo "     Session: ${session:0:12}..."
          fi
          echo ""
        fi
      fi
    done
  fi

  # Global
  if [[ -d "$HOME/.gummy/specialists" ]]; then
    for spec_dir in "$HOME/.gummy/specialists"/*; do
      if [[ -d "$spec_dir" ]]; then
        local name=$(basename "$spec_dir")
        echo "  🌍 $name [global]"
      fi
    done
  fi
}

# Get specialist info
specialist_info() {
  local name="$1"

  local spec_dir=$(find_specialist "$name")

  if [[ -z "$spec_dir" ]]; then
    echo "Error: Specialist '$name' not found"
    return 1
  fi

  echo "=== Specialist: $name ==="
  echo ""

  # Show metadata
  if [[ -f "$spec_dir/meta.yaml" ]]; then
    echo "Metadata:"
    cat "$spec_dir/meta.yaml"
  fi

  echo ""
  echo "System Prompt Preview:"
  echo "---"
  head -20 "$spec_dir/prompt.txt"
  echo "---"
}

# Mark specialist as complete (dormant)
complete_specialist() {
  local name="$1"

  local spec_dir=$(find_specialist "$name")

  if [[ -z "$spec_dir" ]]; then
    echo "Error: Specialist '$name' not found"
    return 1
  fi

  local meta_file="$spec_dir/meta.yaml"

  # Update status to dormant (simple sed replacement)
  sed -i.bak 's/^status: .*/status: dormant/' "$meta_file"
  rm -f "$meta_file.bak"

  echo "✓ Marked $name as dormant"
  echo "  Resume anytime with: resume_specialist '$name' 'new task'"
}
