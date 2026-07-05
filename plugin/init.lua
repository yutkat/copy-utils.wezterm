local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Copy the output of the last command, located via the semantic zones
-- provided by shell integration (OSC 133).
function M.copy_last_command_output(window, pane)
	window:perform_action(act.ActivateCopyMode, pane)
	window:perform_action(act.CopyMode({ MoveBackwardZoneOfType = "Input" }), pane)
	window:perform_action(act.CopyMode({ SetSelectionMode = "Cell" }), pane)
	window:perform_action(act.CopyMode({ MoveForwardZoneOfType = "Prompt" }), pane)
	window:perform_action(act.CopyMode("MoveUp"), pane)
	window:perform_action(act.CopyMode("MoveToEndOfLineContent"), pane)
	window:perform_action(
		act.Multiple({
			{ CopyTo = "ClipboardAndPrimarySelection" },
			{ Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
		}),
		pane
	)

	window:toast_notification("wezterm", "Copied!", nil, 3000)
end

local function strip_leading_spaces(text)
	local lines = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		table.insert(lines, (line:gsub("^[ \t]+", "")))
	end
	return table.concat(lines, "\n")
end

-- Copy the current selection with the leading whitespace of each line
-- removed. Useful for pasting TUI output that is rendered with a left margin.
function M.copy_without_leading_spaces(window, pane)
	local text = window:get_selection_text_for_pane(pane)
	if text == nil or text == "" then
		return
	end
	window:copy_to_clipboard(strip_leading_spaces(text), "ClipboardAndPrimarySelection")
	window:toast_notification("wezterm", "Copied!", nil, 3000)
end

M.action = {
	CopyLastCommandOutput = wezterm.action_callback(M.copy_last_command_output),
	CopyWithoutLeadingSpaces = wezterm.action_callback(M.copy_without_leading_spaces),
}

return M
