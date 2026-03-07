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
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 15
--config.line_height = 1.3
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
--config.window_background_opacity = 0.97
--config.macos_window_background_blur = 20

-- Tab bar
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.tab_max_width = 50
config.show_tab_index_in_tab_bar = false

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
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.active_pane.title
	if tab.tab_title and #tab.tab_title > 0 then
		title = tab.tab_title
	end

	if tab.is_active then
		return {
			--{ Background = { Color = "#555555" } },
			{ Foreground = { Color = "#9ece6a" } },
			{ Attribute = { Intensity = "Bold" } },
			{ Text = " [" .. title .. "] " },
		}
	end
	return "  " .. title .. "  "
end)

-- Status bar configuration
config.status_update_interval = 1000

wezterm.on("update-status", function(window, pane)
	-- Get current working directory
	local cwd = pane:get_current_working_dir()
	local cwd_str = ""
	if cwd then
		cwd_str = cwd.file_path or ""
		-- Shorten home directory to ~
		cwd_str = cwd_str:gsub(wezterm.home_dir, "~")
		-- Shorten long paths
		if #cwd_str > 40 then
			cwd_str = "..." .. cwd_str:sub(-37)
		end
	end

	-- Get git branch (if in a git repo)
	local git_branch = ""
	local success, stdout, stderr = wezterm.run_child_process({
		"git",
		"-C",
		cwd and cwd.file_path or ".",
		"branch",
		"--show-current",
	})
	if success then
		git_branch = stdout:gsub("%s+", "")
	end

	-- Get current time
	-- local time = wezterm.strftime("%H:%M")

	-- Get battery info
	--local battery = ""
	--for _, b in ipairs(wezterm.battery_info()) do
	--	local icon = ""
	--	if b.state == "Charging" then
	--		icon = "🔌"
	--	elseif b.state_of_charge >= 0.8 then
	--		icon = "🔋"
	--	elseif b.state_of_charge >= 0.4 then
	--		icon = "🪫"
	--	else
	--		icon = "⚠️"
	--	end
	--	battery = string.format("%s %.0f%%", icon, b.state_of_charge * 100)
	--end

	-- Build status bar elements
	local status_elements = {}

	if git_branch ~= "" then
		table.insert(status_elements, { Foreground = { Color = "#7aa2f7" } })
		table.insert(status_elements, { Text = "[" .. git_branch .. "] " })
	end

	if cwd_str ~= "" then
		table.insert(status_elements, { Foreground = { Color = "#9ece6a" } })
		table.insert(status_elements, { Text = cwd_str .. " " })
	end

	--if battery ~= "" then
	--	table.insert(status_elements, { Foreground = { Color = "#e0af68" } })
	--	table.insert(status_elements, { Text = " " .. battery })
	--end

	--table.insert(status_elements, { Foreground = { Color = "#bb9af7" } })
	--table.insert(status_elements, { Text = " 🕐 " .. time .. " " })

	window:set_right_status(wezterm.format(status_elements))
end)

-- Key bindings
--config.disable_default_key_bindings = true
config.keys = {
	-- Word navigation (Option + Arrow)
	--{
	--	key = "LeftArrow",
	--	mods = "OPT",
	--	action = act.Multiple({
	--		act.SendKey({ key = "Escape" }),
	--		act.SendKey({ key = "b" }),
	--	}),
	--},
	--{
	--	key = "RightArrow",
	--	mods = "OPT",
	--	action = act.Multiple({
	--		act.SendKey({ key = "Escape" }),
	--		act.SendKey({ key = "f" }),
	--	}),
	--},

	-- Line navigation (Cmd + Arrow)
	--{ key = "LeftArrow", mods = "CMD", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	--{ key = "RightArrow", mods = "CMD", action = act.SendKey({ key = "e", mods = "CTRL" }) },

	-- Delete whole line (Cmd + Backspace)
	--{ key = "Backspace", mods = "CMD", action = act.SendKey({ key = "u", mods = "CTRL" }) },

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

	-- Tab navigation (Cmd + Shift + Arrow)

	-- Clear scrollback (Cmd + K)
	--{ key = "k", mods = "CMD", action = act.ClearScrollback("ScrollbackAndViewport") },

	-- Quick select mode (Cmd + Shift + Space) - select URLs, paths, etc.
	--{ key = "Space", mods = "CMD|SHIFT", action = act.QuickSelect },

	-- Copy mode / vim-like selection (Cmd + Shift + X)
	--{ key = "x", mods = "CMD|SHIFT", action = act.ActivateCopyMode },

	-- Search (Cmd + F)
	{ key = "f", mods = "CMD", action = act.Search({ CaseInSensitiveString = "" }) },

	-- Toggle fullscreen
	--{ key = "Enter", mods = "CMD|SHIFT", action = act.ToggleFullScreen },

	-- Zoom current pane (Cmd + Z)
	{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },

	-- Move tab left/right (Cmd + Ctrl + Arrow)

	-- Resize panes (Cmd + Ctrl + Shift + Arrow)

	-- Command palette (Cmd + Shift + P)
	{ key = "p", mods = "CMD|SHIFT", action = act.ActivateCommandPalette },

	-- Save/restore workspace
	-- { key = "s", mods = "CMD|CTRL", action = act.ShowLauncherArgs({ flags = "WORKSPACES" }) },

	-- Rename tab (Cmd + Shift + R)
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = act.PromptInputLine({
			description = "Enter new tab name:",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
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

--local mux = wezterm.mux

--wezterm.on("gui-startup", function()
--	local tab, pane, window = mux.spawn_window({})
--	window:gui_window():maximize()
--e

--wezterm.on("gui-startup", function(cmd)
--	-- allow `wezterm start -- something` to affect what we spawn
--	-- in our initial window
--	local args = {}
--	if cmd then
--		args = cmd.args
--	end
--
--	-- Set a workspace for coding on a current project
--	-- Top pane is for the editor, bottom pane is for the build tool
--	local project_dir = wezterm.home_dir .. "/wezterm"
--	local tab, build_pane, window = mux.spawn_window({
--		workspace = "coding",
--		cwd = project_dir,
--		args = args,
--	})
--	local editor_pane = build_pane:split({
--		direction = "Top",
--		size = 0.6,
--		cwd = project_dir,
--	})
--	-- may as well kick off a build in that pane
--	build_pane:send_text("cargo build\n")
--
--	-- A workspace for interacting with a local machine that
--	-- runs some docker containers for home automation
--	local tab, pane, window = mux.spawn_window({
--		workspace = "automation",
--		args = { "ssh", "vault" },
--	})
--
--	-- We want to startup in the coding workspace
--	mux.set_active_workspace("coding")
--end)

return config
