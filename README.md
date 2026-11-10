# copy-utils.wezterm

Extra copy actions for [WezTerm](https://wezterm.org/):

- `CopyLastCommandOutput` — copy the output of the last command, located via
  the semantic zones provided by shell integration (OSC 133)
- `CopyWithoutLeadingSpaces` — copy the current selection without the left
  margin and trailing padding that TUIs (e.g. coding agents) render, keeping
  relative indentation

## Installation and usage

```lua
local copy_utils = wezterm.plugin.require("https://github.com/yutkat/copy-utils.wezterm")

config.keys = {
 { key = "c", mods = "ALT|SHIFT|CTRL", action = copy_utils.action.CopyLastCommandOutput },
 { key = "c", mods = "ALT|CTRL", action = copy_utils.action.CopyWithoutLeadingSpaces },
}
```

`CopyLastCommandOutput` requires shell integration that emits OSC 133
semantic zones (see the WezTerm shell integration documentation).
