--[[
    RebelUI v1.0.0 · demo panel (the Rebelwar look)

    Run this file to SEE what RebelUI can do: a loading screen, the panel with its spinning ring,
    a top bar (FPS + logo + timer), tabs with Roblox images next to the name, every kind of toggle,
    sliders, colors, dropdowns, notifications, themes and saving.

    Tabs: Elements (one of everything), Tools, Alerts, Discord and Settings.
    Copy any part you like into your own script. The tutorial is in README.md.
]]

-- To pin the library to one exact version (so a later push to the repo can never change what runs), replace "main" with a
-- commit id from GitHub (the long code next to a commit), e.g. REF = "3f2a9c1d...". "main" always loads the newest file.
local REF = "main"
local URL = "https://raw.githubusercontent.com/RebelUI/Library/" .. REF .. "/source.lua"

-- shows a message on screen (phones can't see the console) and in the console
local function problem(msg)
	warn("[Rebelwar] " .. msg)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Rebelwar", Text = msg, Duration = 10 })
	end)
end

-- 1. download the library, and say clearly if something is wrong
local okGet, src = pcall(function()
	return game:HttpGet(URL)
end)
if not okGet or type(src) ~= "string" or #src < 2000 then
	problem("Could not download source.lua. Is the repo public and is the file on the main branch?")
	return
end
local fn, err = loadstring(src)
if not fn then
	problem("source.lua has an error: " .. tostring(err))
	return
end
local okRun, UI = pcall(fn)
if not okRun or type(UI) ~= "table" or not UI.Loading or not UI.CreateWindow or not UI.KeyGate or not UI.Activate or not UI.Icons then
	problem("source.lua in the repo is an OLD version. Upload the new source.lua (it must contain UI.Activate / UI.Icons) to the main branch.")
	return
end

-- normal text everywhere (some phones draw fancy letters as boxes). Optional: UI.FancyText = "Bold" turns on styled letters.

-- Your own icon copies (upload your PNGs to Roblox): paste their asset ids here and they replace the built-in ones.
-- Leave a name out (or 0) to use the built-in icon (plain black by default; set UI.IconMode = "White" or "Glow" for the other looks).
local WHITE = {
	-- key = 0, padlock = 0, openpadlock = 0, notification = 0, wrench = 0, elements = 0, star = 0, right = 0, down = 0,
	-- copy = 0, refresh = 0, printer = 0, save = 0, link = 0, info = 0, share = 0, calendar = 0, downloads = 0, loading = 0,
}
for name, id in pairs(WHITE) do
	if id and id ~= 0 then
		UI.Icons[name] = id
	end
end

-- ============================================================ DEVELOPER SWITCH
-- SCRIPT_ON = true  -> the script works.   SCRIPT_ON = false -> it does nothing when someone runs it.
-- SWITCH_URL (optional): a link to a text file that says "on" or "off". Change that file any time to turn the script on or off
-- for everyone without re-uploading anything (for example a GitHub raw link to switch.txt). nil = only SCRIPT_ON counts.
local SCRIPT_ON = true
local SWITCH_URL = nil -- e.g. "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/switch.txt"
if not UI:Switch({ On = SCRIPT_ON, Url = SWITCH_URL, Name = "Rebelwar", Message = "Rebelwar is switched off right now. Check the Discord for news." }) then
	return
end

-- Setup: "Auto" picks the Mobile or PC layout by itself (touch and no keyboard = Mobile). Force one with "Mobile" or "PC".
local SETUP = "Auto"

local Load, Win -- made inside main()

local function main()
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Roblox image ids. Swap them for your own. A bare number works too.
local LOGO = 114659273298746
local BANNER = 125144167121839
-- Videos are OFF by default because a phone has to download and decode them while the game is starting.
-- Turn them on (USE_VIDEOS = true) only after the panel opens fine without them.
local USE_VIDEOS = true
-- Loading videos. Paste a direct .mp4 link (a GitHub raw link is the most reliable) or a video page link:
-- the library downloads it first (once), then plays it. Set to nil to turn a video off. Keep each under ~20 MB.
local VIDEO = USE_VIDEOS and "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/assets/Logo-loading.png.mp4" or nil -- the Rebelwar logo loading video
local ICON = {
	ESP = 71415024616002,
	Settings = 81306187910490,
	Discord = 106575470880507,
}
-- Key screen. The panel is keyless by default. Set USE_KEY_GATE = true to ask for a key before the panel opens.
-- Put your own LootLabs (or any) link in GET_KEY_LINK. The "Get key" button copies it so the player can open it in a browser.
-- Honest note: a key that is checked inside this file can be read by someone who looks hard. For real protection
-- check the key on your own server with Check = function(key) ... end.
local USE_KEY_GATE = false
local GET_KEY_LINK = "https://lootlabs.gg/your-link-here" -- <- replace with your LootLabs link
local KEYS = { "REBEL-DEMO" } -- keys that are accepted (or use Check)
local function keyGateOptions(save)
	return {
		Name = "Rebelwar",
		Title = "REBELWAR",
		Subtitle = "Get your key, then paste it below.",
		Logo = LOGO, -- the picture at the top-left (an emoji works too: Emoji = "😃")
		LogoEffect = "Pulse",
		Background = BANNER, -- a faint picture behind the card
		BackgroundOpacity = 0.2,
		Video = VIDEO, -- optional looping video behind the card
		Note = "Tap a button below, finish the steps, then paste the key here.\nThe key works for the whole day.",
		NoteIcon = "📌",
		NoteColor = "Gold", -- Green, Blue, Red, Gold, Purple, Pink, Orange, Cyan, Gray or a Color3
		Tagline = "Rebelwar  |  by prorizz196",
		Setup = SETUP, -- Auto / Mobile / PC: the key panel sizes itself for the device
		-- get-key buttons (two to start with, more are allowed). Put your own link in each one (tap = the link is copied).
		Providers = {
			{ "Linkvertise", "https://linkvertise.com/your-link-here" },
			{ "LootLabs", GET_KEY_LINK },
			-- two buttons to start with. Add more any time, for example:
			-- { "Platoboost", "https://auth.platoboost.com/your-link-here" },
			-- { "Rekonise", "https://rekonise.com/your-link-here" },
		},
		ProvidersText = "GET YOUR KEY  (tap a button: the link is copied)",
		Buttons = {
			{ Name = "Discord", Color = "Discord", Link = "https://discord.gg/8s7RR3wZ6b" },
			{ Name = "Help", Color = "Blue", Link = "https://discord.gg/8s7RR3wZ6b" },
		},
		Keys = KEYS,
		RememberFor = 24 * 60 * 60, -- a remembered key lasts 24 hours, then the panel comes back (nil = never expires)
		Save = save, -- true remembers the key on this device
		Boom = true, -- explosion effect when the key is right
		Theme = "Red",
	}
end
local DISCORD = "https://discord.gg/8s7RR3wZ6b" -- the official RebelUI & Resources server

-- the player's saved loading choice (Settings > Loading screen): Full cover, Video, Logo only, Minimal or Custom
local PREFS_FILE = "Rebelwar_prefs.json"
local prefs = UI.LoadPrefs(PREFS_FILE, { Style = VIDEO and "Video" or "Full cover", Custom = "" })
local startup = UI.StartupOptions({ Title = "Rebelwar", Subtitle = "made by prorizz196", Logo = LOGO, Banner = BANNER, Video = VIDEO, Theme = "Red" }, prefs)
VIDEO = startup.Video

-- ============================================================ 0. start downloading the video RIGHT NOW (first run only, kept after that)
local vidReady, vidPath = not VIDEO, nil
if VIDEO then
	task.spawn(function()
		local okV, a = pcall(UI.ResolveMedia, VIDEO)
		vidPath = okV and a or nil
		vidReady = true
	end)
end

-- ============================================================ 1. loading screen
if USE_KEY_GATE then
	local okKey = UI:KeyGate(keyGateOptions(true))
	if not okKey then
		return
	end
end
local gameName = "Unknown game"
pcall(function()
	gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

startup.Footer = "discord.gg/8s7RR3wZ6b  |  RebelUI v" .. UI.Version
Load = UI:Loading(startup) -- Logo = the round logo with the spinning ring, Banner = the slow zooming picture behind everything
Load:Badge(gameName) -- the small pill at the top

-- Boot log + watchdog. Every step is written to RebelUI_boot.txt (in your executor's workspace folder) and shown on
-- the loading screen. If the screen ever stops, the LAST LINE of that file says exactly where. The loading screen also
-- removes itself and opens the panel after 25 seconds no matter what, so it can never lock the screen.
local T0, ready, bootLog = os.clock(), false, {}
local function stage(name, progress)
	table.insert(bootLog, string.format("%5.1fs  %s", os.clock() - T0, name))
	pcall(function()
		if writefile then
			writefile("RebelUI_boot.txt", table.concat(bootLog, "\n"))
		end
	end)
	if Load and not Load.Dead then
		pcall(Load.Status, Load, name)
		if progress then
			pcall(Load.Progress, Load, progress)
		end
	end
	task.wait() -- let the screen draw a frame before the next heavy step
end
task.delay(25, function()
	if not ready then
		warn("[Rebelwar] startup was still running after 25s. Last step: " .. tostring(bootLog[#bootLog]))
		pcall(function()
			if Load then
				Load:Destroy()
			end
			if Win then
				Win:Toggle(true)
			end
		end)
	end
end)
stage("Starting...", 0.05)

-- download both videos FIRST (first run only, they are kept after that), then play the logo video
local logoVid
if VIDEO then
	Load:Status("Downloading the intro...")
	local t0 = os.clock()
	while not vidReady and os.clock() - t0 < 25 do
		task.wait(0.1)
		pcall(Load.Progress, Load, 0.08 + 0.2 * math.min((os.clock() - t0) / 25, 1)) -- the bar keeps moving
	end
	logoVid = vidPath
	if logoVid then
		Load:SetVideo(logoVid) -- plays the video, then boom when the panel opens
	end
end
stage("Loading images...", 0.3)
Load:Preload({ LOGO, BANNER, ICON.ESP, ICON.Settings, ICON.Discord }, 0, 0.6)

-- ============================================================ 2. the window and the top bar
stage("Building the panel...", 0.55)

Win = UI:CreateWindow({
	Title = "Rebelwar",
	Subtitle = "made by prorizz196",
	Icon = LOGO, -- logo in the corner
	Theme = "Red", -- Red, Crimson, Blue, Green, Purple, Orange, Pink, Gold, Cyber, Blood, Ice, Mono
	Open = false, -- stay closed until the loading screen is done
	Opacity = 100, -- 100 = solid panel (10 to 100). Players can change it in Settings
	Setup = SETUP, -- Auto / Mobile / PC. PC gets a wider panel, Mobile a big thumb-sized open button and swipe between tabs
	ToggleStyle = "Switch", -- Switch (normal), Sharp, Check, Radio, Heart, Star, Checkbox
	SliderStyle = "Normal", -- "Sharp" gives diamond knobs and square bars
	Ambient = true, -- two soft glowing circles drift behind the panel
	Search = true, -- the search box next to the page title
	Resizable = true, -- drag the corner grip to resize
	ToggleKey = Enum.KeyCode.RightShift, -- phones use the top bar instead
})

stage("Building the top bar...", 0.6)
Win:CreateWatermark({ Text = "Rebelwar" }) -- small pill in the corner: name, FPS and ping
Win:SetPalette() -- Ctrl+K: search every tab and command
Win:SetBackground({ Image = BANNER, Opacity = 0.18 }) -- a picture behind the panel (Win:SetBackground() removes it)
Win:SetPanicKey(Enum.KeyCode.Delete) -- Delete hides every window and the open button; press again to bring them back
Win:SetOpenBoom("first") -- an explosion the first time the panel opens ("always" = every time, false = off)
Win:SetTabHotkeys() -- Ctrl+1 ... Ctrl+9 jump to the tabs
Win:SetDim(0.35) -- darken the game behind the panel while it is open (0 = off)
local Bar = Win:CreateBar({
	Items = { "FPS", "Logo", "Timer" }, -- the Rebelwar classic. Players can change it in Settings.
	Logo = LOGO,
})

-- ============================================================ 3. tabs
stage("Building tabs...", 0.65)
-- the Elements page builds itself the first time you open it (so the panel starts fast)
local function buildElements(Elements)
	-- ---------------------------------------------------------------- Elements: one of everything
	Elements:Stats({ { Name = "Kills", Value = 0 }, { Name = "Wins", Value = 0 }, { Name = "Streak", Value = 0 } }) -- number tiles: :Set("Kills", 5)
	Elements:Section("New: chips, steps, timeline, list, table")
	Elements:Chips({ "Legit", "Rage", "Closet" }, { Closable = true, Callback = function(name, what) Win:Notify({ Title = what, Text = name }) end })
	local steps = Elements:Steps({ "Pick", "Tune", "Go" }, 1)
	Elements:Button({ Name = "Next step", Callback = function() steps:Next() end })
	-- more animation: a shimmering placeholder while loading, and text that types itself
	Elements:Typewriter({ Text = "Rows rise in, tap squishes, numbers count up..." })
	local skel = Elements:Skeleton({ Lines = 2 })
	task.delay(3, function()
		skel:Remove()
	end)
	-- a live "Summary" feed: finished steps, notes, and a red glowing step while something is still working
	local feed = Elements:Activity({ Title = "Summary" })
	Elements:Button({ Name = "Run the Summary demo", Description = "Red glow = still working", Callback = function()
		feed:Clear()
		task.spawn(function()
			feed:Working("Sleuthing")
			task.wait(1.2)
			feed:Add({ Kind = "search" })
			task.wait(1)
			feed:Add({ Kind = "command", Detail = "cd /workspace && ls" })
			feed:Note("Adding notification history to the window.")
			task.wait(1.2)
			feed:Add({ Kind = "command", Detail = "run all tests" })
			task.wait(1)
			feed:Done()
			feed:Note("All done.")
		end)
	end })
	Elements:Timeline({ { Title = "v1.0.0", Time = "today", Text = "RebelUI released" }, { Title = "Watermark + palette", Time = "today" } })
	Elements:List({ Items = { "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta" }, Multi = true, Search = true, Callback = function(v) print("picked", #v) end })
	Elements:Table({ Columns = { "Player", "Kills", "Deaths" }, Rows = { { "Ava", 12, 3 }, { "Ben", 7, 9 }, { "Cy", 21, 2 }, { "Dee", 4, 4 }, { "Eli", 15, 6 } }, PageSize = 4 })
	Elements:Section("New: images with effects, boom, hold, undo, mini")
	Elements:Image({ Image = LOGO, Height = 96, Circle = true, Effect = "Rainbow", Caption = "Effect = Rainbow (also Pulse, Float, Glow, Spin, Shimmer)", OnClick = function() Win:Boom({}) end })
	Elements:Image({ Image = BANNER, Height = 90, Crop = true, Effect = "Shimmer" })
	Elements:Button({ Name = "Explosion", Description = "The explosion effect (pick the style in Media or Settings)", Callback = function() Win:Boom({}) end })
	Elements:HoldButton({ Name = "Hold to confirm (1 second)", Seconds = 1, Callback = function() Win:Notify({ Title = "Confirmed", Type = "success" }) end })
	Elements:Button({ Name = "Toast with Undo", Callback = function() Win:NotifyUndo({ Title = "Setting changed", Text = "Tap Undo within 5 seconds.", OnUndo = function() Win:Notify({ Title = "Undone", Type = "success" }) end }) end })
	local miniToggle = Elements:Toggle({ Name = "Mini pill target" })
	Elements:Button({ Name = "Show the mini pill", Description = "A small draggable pill with that toggle", Callback = function() Win:CreateMini({ Toggles = { miniToggle } }) end })
	Elements:Section("New: sub-tabs and columns")
	local sub = Elements:SubTabs({ "Aim", "Visuals", "Misc" }) -- pages inside a tab
	sub.Aim:Toggle({ Name = "A toggle in Aim" })
	sub.Visuals:Slider({ Name = "A slider in Visuals", Min = 0, Max = 100, Default = 40 })
	sub.Misc:Button({ Name = "A button in Misc", Callback = function() Win:Notify({ Title = "Misc button" }) end })
	local cols = Elements:Columns(2) -- two columns (one column on a narrow panel)
	cols[1]:Toggle({ Name = "Left" })
	cols[2]:Toggle({ Name = "Right" })
	Elements:Slider({ Name = "Panel picture opacity", Min = 0, Max = 100, Default = 18, Suffix = "%", Callback = function(v) Win:SetBackgroundOpacity(v / 100) end })
	Elements:Section("Danger zone")
	Elements:Button({
		Name = "Big red button",
		Description = "Danger = true: tap twice and the whole screen shakes",
		Danger = true,
		DoubleClick = true,
		Callback = function()
			Win:Notify({ Title = "Boom", Text = "The screen shook. Win:ScreenShake(power, seconds) does that.", Type = "warn" })
		end,
	})
	Elements:Section("1. Toggles")
	Elements:Toggle({ Name = "Plain switch" })
	Elements:Toggle({ Name = "Name + description", Description = "A second line of small text under the name", Default = true })
	Elements:Toggle({ Name = "Toggle with the key icon", Icon = UI.Icons.key })
	-- a toggle that can be locked shows a padlock; unlock it and the padlock opens
	Elements:Stepper({ Name = "Walk speed", Description = "Tap + or - (hold to repeat)", Min = 16, Max = 100, Step = 4, Default = 16, Flag = "walkspeed" })
Elements:Rating({ Name = "Rate this hub", Default = 4, Flag = "rating", Callback = function(n) Win:Notify({ Title = "Thanks!", Text = "You gave " .. n .. " stars" }) end })
Elements:Countdown({ Name = "Cooldown demo", Seconds = 10, Callback = function() Win:Notify({ Title = "Timer", Text = "Time is up!" }) end })
do -- round 2 demos
	local more = Win:CreateTab({ Name = "More", Icon = 78400891408621, Title = "More elements", Description = "Radio, tags, counters, timers and more." })
	more:Profile({})
	more:Badge({ Text = "NEW", Color = "Green" })
	more:Marquee({ Text = "Welcome to RebelUI - the best mobile UI library   |   discord.gg/8s7RR3wZ6b" })
	more:Radio({ Name = "Mode", Options = { "Legit", "Rage", "Off" }, Default = "Legit" })
	more:CheckList({ Name = "Targets", Items = { "Players", "NPCs", "Items" }, Default = { Players = true } })
	more:Swatches({ Name = "Crosshair color", Default = 1 })
	more:TagInput({ Name = "Whitelist", Placeholder = "type a name and press Enter" })
	local kills = more:Counter({ Name = "Kills", Value = 0 })
	more:Button({ Name = "+100 kills", Callback = function() kills:Add(100) end })
	more:Meter({ Name = "Power", Segments = 10, Value = 7 })
	more:Compare({ Name = "Duel", A = { Name = "You", Value = 60 }, B = { Name = "Rival", Value = 40 } })
	more:Stopwatch({ Name = "Stopwatch" })
	more:Clock({ Name = "Time" })
	more:Pagination({ Name = "Page", Pages = 5 })
	more:Spoiler({ Name = "Secret", Text = "RebelUI rocks" })
	more:Copy({ Name = "Discord", Text = DISCORD })
	more:Kbd({ Name = "Command palette", Keys = { "Ctrl", "K" } })
	more:Quote({ Text = "Make it cool, make it work.", By = "prorizz196" })
	more:Tip({ Text = "Tap the top bar to hide the panel.", Type = "success" })
	more:Heading("Looks and tools")
	more:TriState({ Name = "Aim mode" })
	more:ToggleGrid({ Name = "Hitboxes", Items = { "Head", "Torso", "Arms", "Legs" }, Columns = 2, Default = { Head = true } })
	more:Poll({ Question = "Favorite close animation?", Options = { "Black hole", "Shatter", "TV off" } })
	more:Leaderboard({ Name = "Top players", Rows = { { "Ava", 120 }, { "Ben", 95 }, { "Cleo", 80 } }, Max = 3 })
	more:TextArea({ Name = "Notes", Lines = 3, Placeholder = "write something..." })
	more:FAQ({ { "Is it free?", "Yes, RebelUI is MIT licensed." }, { "Does it work on mobile?", "It was made for Delta on mobile." } })
	more:Changelog({ { Version = "1.0.0", Items = { "Close animations", "Explosion styles", "60 new elements and tools" } } })
	more:Socials({ { Name = "Discord", Url = DISCORD, Color = Color3.fromRGB(88, 101, 242) }, { Name = "Source", Url = "https://github.com/RebelUI/Library", Color = Color3.fromRGB(60, 60, 70) } })
	more:ToggleGrid({ Name = "Screen looks", Items = { "Snow", "Matrix", "Aurora", "Vignette", "Scanlines" }, Columns = 3, Callback = function(n, on)
		if n == "Snow" then Win:Snow(on) elseif n == "Matrix" then Win:Matrix(on) elseif n == "Aurora" then Win:Aurora(on)
		elseif n == "Vignette" then Win:Vignette(on) else Win:Scanlines(on) end
	end })
	more:Button({ Name = "Welcome splash", Callback = function() Win:Welcome({ Text = "Welcome back", Sub = "RebelUI v1.0.0" }) end })
	more:Button({ Name = "Countdown 3", Callback = function() Win:CountDown(3, function() Win:Flash() end) end })
	more:Button({ Name = "Ask for a name", Callback = function() Win:Prompt({ Title = "Your name?", Callback = function(t) Win:Notify({ Title = "Hi " .. t }) end }) end })
	more:Button({ Name = "Choose a color", Callback = function() Win:Choose({ Title = "Pick one", Options = { "Red", "Blue", "Green" }, Callback = function(o) Win:Notify({ Title = o }) end }) end })
	more:Heading("Data and info")
	more:Level({ Name = "Your level", Level = 3, XP = 40, Next = 100 })
	more:Status({ Name = "Server", State = "online", Text = "connected" })
	more:KeyValue({ Name = "Session", Rows = { { "Player", game.Players.LocalPlayer.Name }, { "Place id", tostring(game.PlaceId) } } })
	more:BarChart({ Name = "Kills this week", Data = { { "Mon", 3 }, { "Tue", 7 }, { "Wed", 4 }, { "Thu", 9 }, { "Fri", 6 } } })
	more:Stack({ Name = "Win rate", Parts = { { "Wins", 6 }, { "Losses", 3 }, { "Draws", 1 } } })
	more:Tasks({ Name = "Today", Items = { "Join a server", "Test the panel", "Join the Discord" } })
	more:Vector({ Name = "Teleport to", Default = { 0, 50, 0 } })
	more:ColorInput({ Name = "ESP color", Default = "#E94B35" })
	more:Callout({ Title = "Heads up", Text = "Everything here is a demo. Copy what you like into your own script." })
	more:ButtonRow({ { Name = "Fireworks", Callback = function() Win:Fireworks(5) end }, { Name = "Achievement", Callback = function() Win:Achievement({ Title = "Explorer", Text = "You opened the More tab" }) end } })
	more:ButtonRow({ { Name = "Next theme", Callback = function() Win:Notify({ Title = "Theme", Text = Win:CycleTheme() }) end }, { Name = "Self test", Callback = function() local r = UI:SelfTest(); Win:Notify({ Title = "Self test", Text = r.Passed .. " passed, " .. r.Failed .. " failed", Type = r.Failed == 0 and "success" or "error" }) end } })
	more:Tiles({ { Name = "Snow", Callback = function() Win:Snow(true) end }, { Name = "Snow off", Callback = function() Win:Snow(false) end }, { Name = "Shortcuts", Callback = function() Win:ShowShortcuts() end } })
	more:Button({ Name = "Announcement", Callback = function() Win:Announce({ Text = "RebelUI v1.0.0 is here!", Type = "success" }) end })
	more:Button({ Name = "What is new", Callback = function() Win:ShowChangelog({ Version = "1.0.0", Items = { "30 new elements", "Groupbox, Tabbox, Accordion", "8 close animations" } }) end })
	more:Button({ Name = "Quick tour", Callback = function() Win:Tour({ { Title = "Welcome", Text = "This is RebelUI." }, { Title = "Tabs", Text = "Pick a tab on the left." } }) end })
	more:Button({ Name = "Rain", Callback = function() Win:Rain({ Count = 40 }) end })
end
do -- cards inside a tab: Groupbox, Tabbox, Accordion
	local box = Elements:Groupbox("Groupbox")
	box:Toggle({ Name = "Inside a groupbox", Description = "A titled card that holds any element" })
	local tb = Elements:Tabbox({ "Aim", "Visuals" })
	tb.Aim:Slider({ Name = "FOV", Min = 10, Max = 120, Default = 60 })
	tb.Visuals:Toggle({ Name = "Show boxes" })
	local more = Elements:Accordion({ Name = "More options (tap to open)", Open = false })
	more:Button({ Name = "Hidden button", Callback = function() Win:Notify({ Title = "Accordion", Text = "You found it!" }) end })
end
local lockedT = Elements:Toggle({ Name = "Locked feature", Description = "Tap Unlock below", Locked = true })
	Elements:Button({ Name = "Unlock / lock it", Callback = function()
		lockedT:Lock(not lockedT.Locked)
	end })
	Elements:Toggle({ Name = "Check style", Style = "Check" })
	Elements:Toggle({ Name = "Heart style", Style = "Heart" })
	Elements:Toggle({ Name = "With an icon", Description = "A Roblox image on the left", Icon = ICON.ESP })
	Elements:Toggle({ Name = "Checkbox style", Description = "Style = \"Checkbox\"", Style = "Checkbox", Default = true })
	Elements:Toggle({ Name = "Green when on", Description = "Color = Color3.fromRGB(...)", Color = Color3.fromRGB(60, 210, 90), Default = true })
	Elements:Toggle({ Name = "Blue when on", Color = Color3.fromRGB(64, 140, 255), Default = true })
	Elements:Toggle({ Name = "Toggle with a key", Description = "Press Z on a keyboard to flip it", Key = Enum.KeyCode.Z })
	local locked = Elements:Toggle({ Name = "Locked toggle", Description = "Tap it: it tells you it is locked", Locked = true })
	Elements:Button({
		Name = "Unlock / lock the toggle above",
		Callback = function()
			locked:Lock(not locked.Locked)
		end,
	})

	Elements:Section("2. Sliders and choices")
	Elements:Slider({ Name = "Slider with a suffix", Min = 0, Max = 100, Default = 30, Suffix = "%" })
	Elements:Choice({ Name = "Choice bar", Options = { "Easy", "Normal", "Hard" }, Default = "Normal" })
	Elements:Cycle({ Name = "Cycle picker", Description = "Tap the arrows", Options = { "One", "Two", "Three", "Four" } })
	Elements:Dropdown({ Name = "Dropdown", Options = { "Speed", "Jump", "Fly", "Fog" }, Default = "Speed" })
	Elements:Dropdown({ Name = "Dropdown (many)", Options = { "Speed", "Jump", "Fly", "Fog" }, Multi = true, Default = { "Jump" } })

	Elements:Section("3. Typing, keys and colors")
	Elements:Input({
		Name = "Text box",
		Placeholder = "name here",
		Callback = function(text)
			Win:Notify({ Title = "You typed", Text = text })
		end,
	})
	Elements:Keybind({ Name = "Keybind", Default = Enum.KeyCode.F })
	Elements:Color({ Name = "Color picker", Default = Color3.fromRGB(235, 40, 50) })

	Elements:Section("4. Text and images")
	Elements:Image({ Image = BANNER, Height = 100, Caption = "A Roblox asset image", Crop = true })
	Elements:Header({ Title = "Header card", Text = "A banner with its own title, text and icon.", Icon = LOGO })
	Elements:Paragraph({ Title = "Paragraph", Text = "A titled block of text. It grows to fit as long as you like." })
	Elements:Label("A label is plain small text.")
	Elements:Divider()

	Elements:Section("5. Notifications")
	Elements:Button({
		Name = "Show every notification type",
		Callback = function()
			Win:Notify({ Title = "Info", Text = "A normal card." })
			Win:Notify({ Title = "Success", Text = "A green card.", Type = "success" })
			Win:Notify({ Title = "Warning", Text = "A yellow card.", Type = "warn" })
			Win:Notify({ Title = "Error", Text = "A red card.", Type = "error" })
		end,
	})
	Elements:Button({
		Name = "Notification with buttons",
		Description = "Cards can have up to 3 buttons",
		Callback = function()
			Win:Notify({
				Title = "Update ready",
				Icon = LOGO, -- a small picture on the card
				Text = "A new version is out. Reload now?",
				Duration = 8,
				Actions = {
					{ Name = "Reload", Callback = function() Win:Notify({ Title = "Reloading...", Type = "success" }) end },
					{ Name = "Later" },
				},
			})
		end,
	})

	Elements:Section("6. Key gate")
	Elements:Button({
		Name = "Try the key gate",
		Description = "Image, note, Get key link and a boom. Demo key: REBEL-DEMO",
		Callback = function()
			local ok = UI:KeyGate(keyGateOptions(false)) -- the full screen: image, note, colored buttons, boom
			Win:Notify({ Title = ok and "Key accepted" or "Closed", Type = ok and "success" or "warn" })
		end,
	})

	Elements:Section("7. More tools")
	Elements:Keybind({
		Name = "Keybind: toggle mode",
		Default = Enum.KeyCode.G,
		Mode = "Toggle", -- Press (default), Toggle or Hold
		Callback = function(state)
			Win:Notify({ Title = "Toggle key", Text = state and "ON" or "OFF" })
		end,
	})
	Elements:Keybind({
		Name = "Keybind: hold mode",
		Default = Enum.KeyCode.J, -- (not H: H opens the game assistant)
		Mode = "Hold", -- Callback(true) while held, Callback(false) when let go
		Callback = function(held)
			print("held:", held)
		end,
	})
	Elements:Input({
		Name = "Number box",
		Numeric = true, -- only numbers
		Min = 0,
		Max = 500,
		Default = "100",
		Callback = function(n)
			Win:Notify({ Title = "Number", Text = "You set " .. n })
		end,
	})
	Elements:Button({
		Name = "Pop-up question",
		Description = "Win:Dialog with buttons",
		Callback = function()
			Win:Dialog({
				Title = "Are you sure?",
				Text = "A dialog asks something and runs a function for the button you tap.",
				Buttons = {
					{ Name = "Yes", Callback = function() Win:Notify({ Title = "You said yes", Type = "success" }) end },
					{ Name = "No" },
				},
			})
		end,
	})
	Elements:Section({ Name = "8. A collapsible section (tap me)", Collapsible = true })
	Elements:Label("Tap the line above to hide or show these rows.")
	local hideMe = Elements:Toggle({ Name = "Toggle inside the section" })
	Elements:Button({
		Name = "Hide the toggle above",
		Description = "Every element has :SetVisible(false) and :Destroy()",
		Callback = function()
			hideMe:SetVisible(false)
			task.delay(1.5, function()
				hideMe:SetVisible(true)
			end)
		end,
	})

	Elements:Section("9. Even more")
	Elements:Notice({ Type = "warn", Title = "Heads up", Text = "A Notice is a colored box for warnings and tips. Types: warn, error, success." })
	Elements:Button({ Name = "Risky button", Description = "Red, and asks you to tap twice", Risky = true, DoubleClick = true, Callback = function()
		Win:Notify({ Title = "Done", Text = "You confirmed it.", Type = "success" })
	end })
	Elements:Button({ Name = "Disabled button", Disabled = true })
	Elements:Toggle({ Name = "Tooltip toggle", Description = "Hold your finger here (or hover)", Tooltip = "A tooltip is a small help card. Add Tooltip = \"text\" to any element." })
	local master = Elements:Toggle({ Name = "Show the hidden slider" })
	Elements:Slider({ Name = "Hidden slider", Min = 0, Max = 10, Default = 5, Prefix = "x" }):DependsOn(master) -- only shows while the toggle is on
	local many = {}
	for i = 1, 12 do
		many[i] = "Option " .. i
	end
	Elements:Dropdown({ Name = "Searchable dropdown", Options = many, Tooltip = "Lists with more than 7 options get a search box." })
	Elements:Dropdown({ Name = "Players in the server", Options = "Players" })
	Elements:Input({ Name = "Max 5 letters", MaxLength = 5 })
	local kl = Win:CreateKeybindList({ Visible = false }) -- the keys that are set, on screen
	Elements:Toggle({ Name = "Show keybind list", Description = "On-screen list of your keys", Callback = function(on)
		kl:Show(on)
	end })
	Elements:Button({ Name = "Notification you can update", Callback = function()
		local n = Win:Notify({ Title = "Working...", Text = "0%", Duration = 0 }) -- Duration = 0 stays until Close()
		task.spawn(function()
			for i = 1, 10 do
				task.wait(0.3)
				n:SetText(i * 10 .. "%")
				n:Progress(i / 10)
			end
			n:SetTitle("Done!")
			task.wait(1)
			n:Close()
		end)
	end })

	Elements:Section("10. Power tools")
	Elements:RangeSlider({ Name = "Range slider", Min = 0, Max = 100, Default = { 20, 80 }, Suffix = "%", Flag = "demo_range", Callback = function(lo, hi)
		print("range", lo, hi)
	end })
	Elements:Pad({ Name = "2D pad", Flag = "demo_pad", Callback = function(x, y)
		print("pad", x, y)
	end })
	Elements:Slider({ Name = "Slider with arrows + log scale", Min = 1, Max = 1000, Default = 10, Log = true, Arrows = true })
	Elements:Input({ Name = "Math box", Math = true, Default = "16*4", Tooltip = "Type 16*4 or (2+3)^2 and tap done." })
	Elements:Keybind({ Name = "Combo key (Shift + X)", Default = Enum.KeyCode.X, Modifier = Enum.KeyCode.LeftShift, Callback = function()
		Win:Notify({ Title = "Combo", Text = "Shift + X pressed" })
	end })
	Elements:Graph({ Name = "FPS", Source = "FPS" })
	Elements:Graph({ Name = "Ping", Source = "Ping" })
	Elements:Graph({ Name = "Memory", Source = "Memory" })
	local Log = Elements:Console({ Name = "Console", Height = 100 })
	Log:Log("Console ready. Win:Log(text, kind) writes here.")
	Elements:Button({ Name = "Write to the console", Callback = function()
		Win:Log("An info line")
		Win:Log("A warning", "warn")
		Win:Log("An error", "error")
		Win:Log("A success", "success")
	end })
	Elements:CodeBox({ Name = "Code box", Default = 'print("hello from the code box")', Height = 70 })
	local score = UI.State(0) -- a value that updates anything bound to it
	local scoreLabel = Elements:Label("")
	score:Bind(scoreLabel, "Score: %d")
	Elements:Button({ Name = "Add 1 to the score", Callback = function()
		score:Set(score:Get() + 1)
	end })
	Elements:Feed({ Title = "News from GitHub", Url = "https://raw.githubusercontent.com/RebelUI/Library/main/README.md", Text = "Could not load the news.", MaxChars = 300 })
end

-- a folder in the tab list: tap the arrow (right.png turns down) and its tabs slide down. Main:CreateTab({...}) puts tabs inside.
local Main = Win:CreateTabGroup({ Name = "Main", Open = false })
Main:CreateTab({ Name = "Elements", Icon = UI.Icons.elements, Title = "🧩 ALL ELEMENTS", Description = "One of every element and every toggle style.", Build = buildElements })
local Media = Main:CreateTab({ Name = "Media", Icon = UI.Icons.test, Title = "MEDIA", Description = "Songs, crosshairs, image ids, loading screen and effects.", Build = function(t)
	t:MusicPlayer({ Presets = {}, Volume = 0.5 }) -- Presets = { { Name = "My song", Id = 123456 }, { Name = "A link", Url = "https://.../song.mp3" } }
	t:CrosshairPicker({ Shape = "Cross", Color = "Red" }) -- shapes, colors, spin, or your own Roblox image id / link
	t:Section("Check an image id")
	t:AssetPicker({ Name = "Image id or link" })
	t:LoadingPicker({ File = PREFS_FILE, Base = { Title = "Rebelwar", Subtitle = "made by prorizz196", Logo = LOGO, Banner = BANNER, Video = "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/assets/Logo-loading.png.mp4", Theme = "Red" } })
	t:ClosePicker({ Title = "When you press X" })
	t:BoomPicker({ Title = "Explosion style" })
	t:Section("Effects")
	t:Dropdown({ Name = "Page animation", Options = UI.PageAnimations, Default = "Slide up", Callback = function(v)
		Win:SetPageAnimation(v)
	end })
	t:Toggle({ Name = "Sparkle trail", Description = "Sparkles follow your finger", Callback = function(on)
		Win:SetTrail(on, "Rainbow")
	end })
end })
local Discord = Main:CreateTab({ Name = "Discord", Icon = ICON.Discord, Title = "💬 DISCORD", Description = "Updates, support and suggestions." })
Discord:SetBadge("NEW") -- a small bubble on the tab button (nil removes it)
Win:SetAssistant({ -- the full-screen HUD is built only when it is first opened
	Logo = LOGO,
	Title = "ELITE GAME ASSISTANT",
	Color = "Rainbow",
	Key = Enum.KeyCode.H, -- press H on a keyboard to open or close it
	OnSummary = function(hud, done)
		done(hud:GetSummary())
	end,
})
stage("Building the tools tab...", 0.85)
local Tools = Win:CreateToolsTab({ Icon = UI.Icons.wrench, Features = { "More themes", "More crosshairs", "Macro recorder", "Cloud sync", "Sound packs" } })
Win:CreateNotificationsTab({ Icon = UI.Icons.notification }) -- every toast you saw, with an unread number on the tab
Win:CreateFavoritesTab({ Icon = UI.Icons.star }) -- pick toggles and buttons from other tabs and use them in one place
Win:CreateThemeEditor({ Icon = LOGO }) -- a color picker for every theme color, with copy / paste of the theme
stage("Building settings...", 0.92)
local Settings = Win:CreateSettingsTab({
	Icon = ICON.Settings,
	Bar = Bar,
	Credits = { Name = "Rebelwar", Text = "Made by prorizz196. Thank you for playing!", Discord = DISCORD },
}) -- the ready-made Settings tab

-- ---------------------------------------------------------------- Discord
Discord:Image({ Image = BANNER, Height = 110, Crop = true, Effect = "Shimmer" })
Discord:Paragraph({ Title = "🔥 REBELWAR — KEYLESS • SIMPLE • POWERFUL 🔥", Text = "✅ No keys needed. Open it, tap the bar, and go." })
Discord:Paragraph({
	Title = "⚡ THIS PANEL SHOWS",
	Text = "A loading screen\nA search box, a resize grip, panel opacity, dialogs, tooltips, a keybind list and collapsible sections\nNamed profiles in Settings (save Legit, Rage, ...)\nA top bar you can fill with FPS, Timer, Logo and more\nTabs with their own pictures and headers\nEvery kind of toggle, slider, color picker and menu\n14 themes that change live",
})
Discord:Paragraph({
	Title = "📚 REBELUI & RESOURCES",
	Text = "#examples: the tutorial source.lua (copy it and change it)\n#documentation: every document we have\nAsk questions, share your scripts, get help.",
})
Discord:Link({ Url = DISCORD, Name = DISCORD, Description = "Tap the blue link to copy it" })
Discord:Button({
	Name = "Copy the official Discord invite",
	Description = "Tutorials, documentation, updates and help",
	Callback = function()
		local ok = pcall(function()
			setclipboard(DISCORD)
		end)
		Win:Notify({
			Title = ok and "Copied!" or "Your executor can't copy",
			Text = ok and "Paste it in your browser to join." or DISCORD,
			Type = ok and "success" or "warn",
		})
	end,
})

-- ============================================================ 4. finish: close the loading screen, open the panel
stage("Ready!", 1)
ready = true
Load:Finish() -- fades the loading screen out
Win:Toggle(true) -- the panel pops open
Win:Boom({})
Win:Notify({ Title = "Welcome, " .. lp.DisplayName, Text = "Tap the top bar (or press RightShift) to hide or show the panel.", Duration = 5 })
end

-- 2. run it. If anything goes wrong, the loading screen shows the problem and closes (it can never get stuck)
local okMain, errMain = pcall(main)
if not okMain then
	problem("Demo failed: " .. tostring(errMain))
	if Load then
		Load:Fail("Something went wrong. Check the console.")
		task.wait(4)
		Load:Destroy()
	end
	if Win then
		Win:Destroy()
	end
end
