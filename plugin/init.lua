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

-- Remove the left margin shared by the lines and trailing padding, keeping
-- relative indentation. The first line is excluded from the margin because a
-- selection usually starts in the middle of it.
local function strip_margin(text)
	local lines, margin = {}, nil
	for line in (text .. "\n"):gmatch("(.-)\n") do
		line = line:gsub("[ \t]+$", "")
		if #lines > 0 and line ~= "" then
			local indent = #line:match("^[ \t]*")
			margin = math.min(margin or indent, indent)
		end
		table.insert(lines, line)
	end
	lines[1] = lines[1]:gsub("^[ \t]+", "")
	for i = 2, #lines do
		lines[i] = lines[i]:sub((margin or 0) + 1)
	end
	return table.concat(lines, "\n")
end

-- Copy the current selection without the left margin and trailing padding
-- that TUIs (e.g. coding agents) render, keeping relative indentation.
function M.copy_without_leading_spaces(window, pane)
	local text = window:get_selection_text_for_pane(pane)
	if text == nil or text == "" then
		return
	end
	window:copy_to_clipboard(strip_margin(text), "ClipboardAndPrimarySelection")
	window:toast_notification("wezterm", "Copied!", nil, 3000)
end

M.action = {
	CopyLastCommandOutput = wezterm.action_callback(M.copy_last_command_output),
	CopyWithoutLeadingSpaces = wezterm.action_callback(M.copy_without_leading_spaces),
}

return M
