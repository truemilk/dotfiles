local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Hide window decorations (app bar)
config.window_decorations = "RESIZE"

-- Larger default window size (columns x rows)
config.initial_cols = 160
config.initial_rows = 45

-- Appearance

config.color_scheme = "Tokyo Night"
--config.color_scheme = 'Vacuous 2 (terminal.sexy)'
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 15
--config.line_height = 1.3
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
--config.window_background_opacity = 0.95
--config.macos_window_background_blur = 20

config.native_macos_fullscreen_mode = true

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.tab_max_width = 50
--config.show_tab_index_in_tab_bar = true
--config.colors = {
--	tab_bar = {
--		background = "#333333",
--		new_tab = { bg_color = "#333333", fg_color = "#808080" },
--		new_tab_hover = { bg_color = "#444444", fg_color = "#c0c0c0" },
--	},
--}

-- Performance
config.max_fps = 120
config.animation_fps = 60

-- Cursor
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- Scrollback
config.scrollback_lines = 10000

-- Workspace name
-- config.default_workspace = "main"

-- Long-running command notifications (alert after 10 seconds)
config.audible_bell = "Disabled"
config.visual_bell = {
	fade_in_duration_ms = 75,
	fade_out_duration_ms = 75,
	target = "CursorColor",
}

-- Tab title formatting with padding and active tab highlight
--wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
--	local title = tab.tab_title and #tab.tab_title > 0 and tab.tab_title or tab.active_pane.title
--
--	-- Fallback when title is empty (e.g. after exiting claude)
--	if not title or #title == 0 then
--		local process = tab.active_pane.foreground_process_name or ""
--		title = process:match("([^/]+)$") or "" -- basename only
--	end
--	if not title or #title == 0 then
--		local cwd = tab.active_pane.current_working_dir
--		if cwd then
--			title = (cwd.file_path or ""):match("([^/]+)/?$") or "shell"
--		else
--			title = "shell"
--		end
--	end
--
--	if tab.is_active then
--		return {
--			{ Background = { Color = "#3a9a5c" } },
--			{ Foreground = { Color = "#000000" } },
--			{ Attribute = { Intensity = "Bold" } },
--			{ Text = " " .. title .. " " },
--		}
--	end
--	return {
--		{ Background = { Color = "#333333" } },
--		{ Foreground = { Color = "#808080" } },
--		{ Text = " " .. title .. " " },
--	}
--end)

-- Status bar configuration
--config.status_update_interval = 1000
--
--wezterm.on("update-status", function(window, pane)
--	-- Get current working directory
--	local cwd = pane:get_current_working_dir()
--	local cwd_str = ""
--	if cwd then
--		cwd_str = cwd.file_path or ""
--		-- Shorten home directory to ~
--		cwd_str = cwd_str:gsub(wezterm.home_dir, "~")
--		-- Shorten long paths
--		if #cwd_str > 40 then
--			cwd_str = "..." .. cwd_str:sub(-37)
--		end
--	end
--
--	-- Get git branch (if in a git repo)
--	local git_branch = ""
--	local success, stdout, stderr = wezterm.run_child_process({
--		"git",
--		"-C",
--		cwd and cwd.file_path or ".",
--		"branch",
--		"--show-current",
--	})
--	if success then
--		git_branch = stdout:gsub("%s+", "")
--	end
--
--	-- Build status bar elements
--	local status_elements = {}
--
--	if git_branch ~= "" then
--		table.insert(status_elements, { Foreground = { Color = "#7aa2f7" } })
--		table.insert(status_elements, { Text = "[" .. git_branch .. "] " })
--	end
--
--	if cwd_str ~= "" then
--		table.insert(status_elements, { Foreground = { Color = "#9ece6a" } })
--		table.insert(status_elements, { Text = cwd_str .. " " })
--	end
--
--	window:set_right_status(wezterm.format(status_elements))
--end)

-- Key bindings
--config.disable_default_key_bindings = true
config.keys = {

	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },

	{ key = "h", mods = "CMD|SHIFT", action = wezterm.action.SplitPane({ direction = "Left" }) },
	{ key = "l", mods = "CMD|SHIFT", action = wezterm.action.SplitPane({ direction = "Right" }) },
	{ key = "k", mods = "CMD|SHIFT", action = wezterm.action.SplitPane({ direction = "Up" }) },
	{ key = "j", mods = "CMD|SHIFT", action = wezterm.action.SplitPane({ direction = "Down" }) },

	{ key = "h", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "l", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "k", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "j", mods = "CMD|CTRL", action = act.AdjustPaneSize({ "Down", 5 }) },

	{ key = "[", mods = "CMD|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "CMD|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "[", mods = "CMD|CTRL", action = act.MoveTabRelative(-1) },
	{ key = "]", mods = "CMD|CTRL", action = act.MoveTabRelative(1) },

	{ key = "o", mods = "CMD", action = act.RotatePanes("Clockwise") },
	{ key = "i", mods = "CMD", action = act.RotatePanes("CounterClockwise") },

	{ key = "s", mods = "CMD", action = act.PaneSelect({ mode = "SwapWithActive" }) },

	-- Close pane (Cmd + W)
	--{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = true }) },

	-- New tab (Cmd + T)
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },

	-- Search (Cmd + F)
	{ key = "f", mods = "CMD", action = act.Search({ CaseInSensitiveString = "" }) },

	-- Zoom current pane (Cmd + Z)
	{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },

	-- Command palette (Cmd + Shift + P)
	{ key = "p", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },
}

-- Mouse bindings - ONLY Cmd+Click opens URLs (disable default click-to-open)
config.mouse_bindings = {
	-- Cmd+Click to open links
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CMD",
		action = act.OpenLinkAtMouseCursor,
	},
	-- Disable default click on links (just move cursor instead)
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = act.CompleteSelection("ClipboardAndPrimarySelection"),
	},
}

return config
