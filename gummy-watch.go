package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/atotto/clipboard"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/glamour"
	"github.com/charmbracelet/lipgloss"
)

// Styles
var (
	titleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("212")).
			Bold(true).
			Padding(1, 2).
			Border(lipgloss.DoubleBorder()).
			BorderForeground(lipgloss.Color("212"))

	panelStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			Padding(1, 2).
			Width(78)

	plannerBorder = lipgloss.Color("212")
	executorBorder = lipgloss.Color("51")

	statusRunning   = lipgloss.NewStyle().Foreground(lipgloss.Color("46")).Render("● Running")
	statusCompleted = lipgloss.NewStyle().Foreground(lipgloss.Color("82")).Render("✓ Completed")
	statusFailed    = lipgloss.NewStyle().Foreground(lipgloss.Color("196")).Render("✗ Failed")
	statusStopped   = lipgloss.NewStyle().Foreground(lipgloss.Color("208")).Render("◼ Stopped")
	statusWaiting   = lipgloss.NewStyle().Foreground(lipgloss.Color("240")).Render("○ Waiting")

	helpStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("240"))
)

type agentState struct {
	status       string
	sessionID    string
	turns        int
	cost         float64
	duration     int
	currentTool  string
	latestText   string
	finalMessage string // Complete final message when completed
}

type model struct {
	taskID       string
	planner      agentState
	executor     agentState
	taskRunner   agentState // For task mode
	width        int
	height       int
	copyFeedback string
}

type tickMsg time.Time

func (m model) Init() tea.Cmd {
	return tick()
}

func tick() tea.Cmd {
	return tea.Tick(time.Second, func(t time.Time) tea.Msg {
		return tickMsg(t)
	})
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "q", "ctrl+c":
			return m, tea.Quit
		case "c":
			// Copy final message to clipboard
			var textToCopy string
			if m.taskRunner.status == "completed" && m.taskRunner.finalMessage != "" {
				textToCopy = m.taskRunner.finalMessage
			} else if m.planner.status == "completed" && m.planner.finalMessage != "" {
				textToCopy = m.planner.finalMessage
			} else if m.executor.status == "completed" && m.executor.finalMessage != "" {
				textToCopy = m.executor.finalMessage
			}

			if textToCopy != "" {
				if err := clipboard.WriteAll(textToCopy); err == nil {
					m.copyFeedback = "✓ Copied to clipboard!"
				} else {
					m.copyFeedback = "✗ Failed to copy"
				}
				// Clear feedback after 2 seconds
				return m, tea.Tick(2*time.Second, func(t time.Time) tea.Msg {
					return tickMsg(t)
				})
			}
		}
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
	case tickMsg:
		// Clear copy feedback after delay
		if m.copyFeedback != "" {
			m.copyFeedback = ""
		}

		// Update state from log files (fixed ~/.claude paths)
		homeDir, _ := os.UserHomeDir()
		logsDir := filepath.Join(homeDir, ".claude", "logs", "gummy")
		commsDir := filepath.Join(homeDir, ".claude", "agent_comms", "gummy")

		m.planner = readAgentState(filepath.Join(logsDir, fmt.Sprintf("%s-plan.log", m.taskID)), filepath.Join(commsDir, fmt.Sprintf("%s-plan-report.md", m.taskID)))
		m.executor = readAgentState(filepath.Join(logsDir, fmt.Sprintf("%s-execute.log", m.taskID)), filepath.Join(commsDir, fmt.Sprintf("%s-execution-report.md", m.taskID)))
		m.taskRunner = readAgentState(filepath.Join(logsDir, fmt.Sprintf("%s-task.log", m.taskID)), filepath.Join(commsDir, fmt.Sprintf("%s-task-report.md", m.taskID)))
		return m, tick()
	}
	return m, nil
}

func readAgentState(logPath, reportPath string) agentState {
	state := agentState{status: "not_started"}

	file, err := os.Open(logPath)
	if err != nil {
		return state
	}
	defer file.Close()

	hasSystemEvent := false
	hasResultEvent := false

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		var event map[string]interface{}
		if err := json.Unmarshal(scanner.Bytes(), &event); err != nil {
			continue
		}

		eventType, _ := event["type"].(string)

		switch eventType {
		case "system":
			if sessionID, ok := event["session_id"].(string); ok {
				state.sessionID = sessionID
				hasSystemEvent = true
			}

		case "result":
			hasResultEvent = true
			if turns, ok := event["num_turns"].(float64); ok {
				state.turns = int(turns)
			}
			if cost, ok := event["total_cost_usd"].(float64); ok {
				state.cost = cost
			}
			if duration, ok := event["duration_ms"].(float64); ok {
				state.duration = int(duration)
			}
			if isError, ok := event["is_error"].(bool); ok && isError {
				state.status = "failed"
			} else {
				state.status = "completed"
			}

		case "assistant":
			if msg, ok := event["message"].(map[string]interface{}); ok {
				if content, ok := msg["content"].([]interface{}); ok {
					for _, item := range content {
						if contentItem, ok := item.(map[string]interface{}); ok {
							if contentType, ok := contentItem["type"].(string); ok {
								if contentType == "text" {
									if text, ok := contentItem["text"].(string); ok && text != "" {
										// Store full text for final message
										state.finalMessage = text
										// Truncate for live display
										displayText := text
										if len(displayText) > 150 {
											displayText = displayText[:150] + "..."
										}
										state.latestText = displayText
									}
								}
								if contentType == "tool_use" {
									if name, ok := contentItem["name"].(string); ok {
										state.currentTool = name
									}
								}
							}
						}
					}
				}
			}
		}
	}

	// Determine final status
	if hasResultEvent {
		// Status already set from result event (completed or failed)
	} else if hasSystemEvent {
		// Started but no result yet - check if still active
		fileInfo, err := os.Stat(logPath)
		if err == nil {
			// If log hasn't been modified in 30+ seconds and no result, likely stopped
			if time.Since(fileInfo.ModTime()) > 30*time.Second {
				state.status = "stopped"
			} else {
				state.status = "running"
			}
		}
	}

	// Check if report exists (overrides to completed)
	if _, err := os.Stat(reportPath); err == nil && state.status != "failed" {
		state.status = "completed"
	}

	return state
}

func (m model) View() string {
	if m.width == 0 {
		return "Loading..."
	}

	var b strings.Builder

	// Title
	b.WriteString(titleStyle.Render("GUMMY AGENT MONITOR\nTask ID: "+m.taskID) + "\n\n")

	// Calculate panel width based on terminal width
	panelWidth := m.width - 6
	if panelWidth < 40 {
		panelWidth = 40
	}

	// Show only the active agent at any time
	if m.taskRunner.status != "not_started" {
		// Task mode
		taskBorder := lipgloss.Color("208") // Orange
		b.WriteString(lipgloss.NewStyle().Foreground(taskBorder).Bold(true).Render("═══ TASK (HAIKU) ═══") + "\n")
		b.WriteString(panelStyle.Width(panelWidth).BorderForeground(taskBorder).Render(renderAgent(m.taskRunner, panelWidth-4)) + "\n\n")
	} else if m.executor.status == "running" || m.executor.status == "completed" || m.executor.status == "failed" {
		// Execute mode - show only executor
		b.WriteString(lipgloss.NewStyle().Foreground(executorBorder).Bold(true).Render("═══ EXECUTE (HAIKU) ═══") + "\n")
		b.WriteString(panelStyle.Width(panelWidth).BorderForeground(executorBorder).Render(renderAgent(m.executor, panelWidth-4)) + "\n\n")
	} else if m.planner.status != "not_started" {
		// Plan mode - show only planner
		b.WriteString(lipgloss.NewStyle().Foreground(plannerBorder).Bold(true).Render("═══ PLAN (HAIKU) ═══") + "\n")
		b.WriteString(panelStyle.Width(panelWidth).BorderForeground(plannerBorder).Render(renderAgent(m.planner, panelWidth-4)) + "\n\n")
	}

	// Status
	if m.taskRunner.status == "completed" {
		b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color("82")).Bold(true).Width(m.width).Align(lipgloss.Center).Render("✓ TASK COMPLETED") + "\n\n")
	} else if m.taskRunner.status == "failed" {
		b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color("196")).Bold(true).Width(m.width).Align(lipgloss.Center).Render("✗ TASK FAILED") + "\n\n")
	} else if m.planner.status == "completed" && m.executor.status == "completed" {
		b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color("82")).Bold(true).Width(m.width).Align(lipgloss.Center).Render("✓ ALL AGENTS COMPLETED") + "\n\n")
	} else if m.planner.status == "failed" || m.executor.status == "failed" {
		b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color("196")).Bold(true).Width(m.width).Align(lipgloss.Center).Render("✗ AGENT FAILED") + "\n\n")
	}

	// Copy feedback
	if m.copyFeedback != "" {
		feedbackStyle := lipgloss.NewStyle().Foreground(lipgloss.Color("82")).Bold(true).Width(m.width).Align(lipgloss.Center)
		b.WriteString(feedbackStyle.Render(m.copyFeedback) + "\n")
	}

	// Help
	helpText := "[q] Quit  [c] Copy final message  [ctrl+c] Exit"
	b.WriteString(helpStyle.Width(m.width).Align(lipgloss.Center).Render(helpText))

	return b.String()
}

func wrapText(text string, width int) string {
	if width <= 0 {
		return text
	}

	var wrapped strings.Builder
	lines := strings.Split(text, "\n")

	for _, line := range lines {
		if len(line) <= width {
			wrapped.WriteString(line)
			wrapped.WriteString("\n")
			continue
		}

		// Wrap long lines
		for len(line) > 0 {
			if len(line) <= width {
				wrapped.WriteString(line)
				wrapped.WriteString("\n")
				break
			}

			// Find last space before width
			cutoff := width
			spaceIdx := strings.LastIndex(line[:cutoff], " ")
			if spaceIdx > 0 {
				cutoff = spaceIdx
			}

			wrapped.WriteString(line[:cutoff])
			wrapped.WriteString("\n")
			line = strings.TrimLeft(line[cutoff:], " ")
		}
	}

	return strings.TrimRight(wrapped.String(), "\n")
}

func renderAgent(a agentState, width int) string {
	var b strings.Builder

	// Status
	status := statusWaiting
	switch a.status {
	case "running":
		status = statusRunning
	case "completed":
		status = statusCompleted
	case "failed":
		status = statusFailed
	case "stopped":
		status = statusStopped
	}
	b.WriteString("Status: " + status)

	if a.turns > 0 {
		b.WriteString(fmt.Sprintf(" | Turn: %d", a.turns))
	}
	if a.cost > 0 {
		b.WriteString(fmt.Sprintf(" | Cost: $%.4f", a.cost))
	}
	if a.duration > 0 {
		b.WriteString(fmt.Sprintf(" | Duration: %.1fs", float64(a.duration)/1000))
	}
	b.WriteString("\n\n")

	if a.sessionID != "" {
		shortID := a.sessionID
		if len(shortID) > 8 {
			shortID = shortID[:8] + "..."
		}
		b.WriteString("Session: " + shortID + "\n")
	}

	if a.currentTool != "" {
		b.WriteString("\nCurrent Tool: " + lipgloss.NewStyle().Foreground(lipgloss.Color("212")).Render(a.currentTool) + "\n")
	}

	// Show complete final message if completed, otherwise show truncated latest
	if a.status == "completed" && a.finalMessage != "" {
		b.WriteString("\n" + lipgloss.NewStyle().Foreground(lipgloss.Color("82")).Bold(true).Render("Final Message:") + "\n")

		// Render markdown with glamour
		renderer, err := glamour.NewTermRenderer(
			glamour.WithAutoStyle(),
			glamour.WithWordWrap(width),
		)
		if err == nil {
			rendered, err := renderer.Render(a.finalMessage)
			if err == nil {
				b.WriteString(rendered)
				return b.String()
			}
		}

		// Fallback to plain text if markdown rendering fails
		wrapped := wrapText(a.finalMessage, width)
		b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color("250")).Render(wrapped))
	} else if a.latestText != "" {
		b.WriteString("\nLatest Activity:\n")
		wrapped := wrapText(a.latestText, width)
		b.WriteString(lipgloss.NewStyle().Foreground(lipgloss.Color("250")).Render(wrapped))
	}

	return b.String()
}

func main() {
	taskID := ""
	if len(os.Args) > 1 {
		taskID = os.Args[1]
	} else {
		// Auto-detect latest task from fixed ~/.claude path
		homeDir, _ := os.UserHomeDir()
		logsDir := filepath.Join(homeDir, ".claude", "logs", "gummy")
		files, _ := filepath.Glob(filepath.Join(logsDir, "gummy-*-plan.log"))
		if len(files) > 0 {
			base := filepath.Base(files[len(files)-1])
			taskID = strings.TrimSuffix(base, "-plan.log")
		}
	}

	if taskID == "" {
		fmt.Println("Error: No task ID provided and no logs found")
		fmt.Println("Usage: gummy-watch [task-id]")
		os.Exit(1)
	}

	p := tea.NewProgram(model{taskID: taskID})
	if _, err := p.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}
