#!/bin/bash

# Simple installation script for gummy-agent

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "Installing gummy-agent..."
echo ""

# Build the TUI
echo -e "${BLUE}→${NC} Building gummy-watch..."
./build-gummy-watch.sh

# Install to /usr/local/bin
echo -e "${BLUE}→${NC} Installing binaries..."
sudo cp gummy /usr/local/bin/gummy
sudo cp gummy-watch /usr/local/bin/gummy-watch
sudo chmod +x /usr/local/bin/gummy
sudo chmod +x /usr/local/bin/gummy-watch

# Create directories
echo -e "${BLUE}→${NC} Creating directories..."
mkdir -p ~/.claude/logs/gummy
mkdir -p ~/.claude/agent_comms/gummy
mkdir -p ~/.claude/commands

# Install slash commands
echo -e "${BLUE}→${NC} Installing slash commands..."
cp commands/*.md ~/.claude/commands/

echo ""
echo -e "${GREEN}✓${NC} Installation complete!"
echo ""
echo "Slash commands installed:"
echo "  /gummy-plan - Plan complex tasks"
echo "  /gummy-execute - Execute approved plans"
echo "  /gummy-task - Run simple tasks"
echo ""
echo "Direct usage:"
echo "  gummy plan \"your task description\""
echo "  gummy task \"simple task description\""
echo "  gummy-watch [task-id]"
echo ""
