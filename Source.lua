--[[
    RebelUI v1.0.0  ·  made by prorizz196  ·  MIT license
    The panel library behind Rebelwar. Mobile friendly. Made for Roblox executors.
    Same look as the Rebelwar Hub: spinning ring, embers, glowing tabs, shiny buttons,
    pill toggles, a top bar you can fill with FPS / Timer / Logo and more, and a loading screen.

    local UI  = loadstring(game:HttpGet("https://raw.githubusercontent.com/RebelUI/Library/main/source.lua"))()

    local Load = UI:Loading({ Title = "Rebelwar", Logo = 114659273298746 })   -- optional loading screen
    Load:Status("Starting..."); Load:Progress(0.6)
    Load:Finish()

    local Win  = UI:CreateWindow({ Title = "Rebelwar", Subtitle = "my panel", Icon = 114659273298746 })
    local Bar  = Win:CreateBar({ Items = { "FPS", "Logo", "Timer" } })
    local Tab  = Win:CreateTab({ Name = "Main", Icon = 78400891408621, Title = "Main hub", Description = "Hello!" })
    Tab:Toggle({ Name = "Speed", Description = "Run faster", Callback = function(on) print(on) end })
    Win:CreateSettingsTab({ Bar = Bar })

    Elements: Section, Label, Divider, Button, Toggle, Slider, RangeSlider, Pad, Dropdown, Input,
              Keybind, Color, Header, Image, Progress, Paragraph, Notice, Choice, Cycle,
              Console, Graph, CodeBox, Feed
    Window:   CreateTab, CreateBar, CreateSettingsTab, Notify, SetTheme, SetAccent, SetScale,
              SetOpacity, SetSize, SetToggleKey, Toggle, Save, Load, Destroy,
              SaveProfile, LoadProfile, DeleteProfile, ListProfiles, SetAutoLoad, AutoLoad
    Library:  Loading, CreateWindow, KeyGate, AddTheme, SetLanguage, Spring, State
    Also: search box, drag-to-resize, named profiles, key gate, notification buttons and icons,
          dialogs, collapsible sections, keybind modes, number boxes, tab dividers,
          settings export / import, panel opacity (100% by default).
    More Window methods: Dialog, CreateTabDivider, CreateKeybindList, Export, Import
    Game assistant: Window:GameAssistant (full-screen HUD), Window:SetTrigger (Circle / Square / Bar), Loading({ Video = ... })
    Effects: SetOpenAnimation, SetAnimSpeed, SetReduceMotion, SetFx, SetRainbow, Confetti, Shake, ScreenShake, Button { Danger = true }
    Extras: CreateToolsTab (command bar, notes, badges, randomizer, performance, accessibility), AddCommand, RunCommand
    More elements: Notice (warning box). Every element: tooltip, :SetVisible, :Destroy, :DependsOn
    Every element returns an object with :Get() and :Set(value).
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local RebelUI = { Version = "1.0.0" }
local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

-- ============================================================ themes
-- A theme is built from one accent color. "Red" is the exact Rebelwar Hub look.
local rgb = Color3.fromRGB

local function makeTheme(accent, over)
	local h, s = accent:ToHSV()
	local function d(sv, v)
		return Color3.fromHSV(h, math.clamp(s * sv, 0, 1), v)
	end
	local t = {
		Accent = accent,
		Glow = accent:Lerp(Color3.new(1, 1, 1), 0.15),
		Dark = accent:Lerp(Color3.new(0, 0, 0), 0.6),
		BG0 = d(0.9, 0.09),
		BG1 = d(0.85, 0.2),
		S0 = d(0.9, 0.12),
		S1 = d(0.85, 0.24),
		B0 = d(0.9, 0.1),
		B1 = d(0.85, 0.26),
		Item = d(0.8, 0.17),
		ItemOn = d(0.85, 0.24),
		Off = d(0.35, 0.3),
		Inset = d(0.9, 0.07),
	}
	for k, v in pairs(over or {}) do
		t[k] = v
	end
	return t
end

local THEMES = {
	Red = makeTheme(rgb(235, 40, 50), {
		Glow = rgb(255, 60, 70),
		Dark = rgb(110, 12, 20),
		BG0 = rgb(22, 10, 12),
		BG1 = rgb(40, 14, 19),
		S0 = rgb(30, 13, 16),
		S1 = rgb(48, 16, 23),
		B0 = rgb(26, 12, 14),
		B1 = rgb(58, 16, 24),
		Item = rgb(42, 18, 22),
		ItemOn = rgb(58, 20, 27),
		Off = rgb(78, 44, 48),
		Inset = rgb(26, 11, 14),
	}),
	Crimson = makeTheme(rgb(200, 20, 45)),
	Blue = makeTheme(rgb(64, 140, 255)),
	Green = makeTheme(rgb(60, 205, 110)),
	Purple = makeTheme(rgb(160, 90, 255)),
	Orange = makeTheme(rgb(255, 140, 40)),
	Pink = makeTheme(rgb(255, 80, 170)),
	Gold = makeTheme(rgb(245, 190, 40)),
	Cyber = makeTheme(rgb(0, 235, 230)),
	Blood = makeTheme(rgb(150, 10, 20)),
	Ice = makeTheme(rgb(150, 210, 255)),
	Mono = makeTheme(rgb(190, 190, 205)),
	-- made for easy reading: pure black, bright yellow
	Contrast = makeTheme(rgb(255, 230, 0), {
		Glow = rgb(255, 255, 120),
		Dark = rgb(130, 115, 0),
		BG0 = rgb(0, 0, 0),
		BG1 = rgb(12, 12, 12),
		S0 = rgb(0, 0, 0),
		S1 = rgb(20, 20, 20),
		B0 = rgb(0, 0, 0),
		B1 = rgb(28, 28, 28),
		Item = rgb(26, 26, 26),
		ItemOn = rgb(52, 48, 0),
		Off = rgb(120, 120, 120),
		Inset = rgb(0, 0, 0),
	}),
	-- blue and orange are easy to tell apart for most kinds of color blindness
	Colorblind = makeTheme(rgb(0, 114, 178), { Glow = rgb(86, 180, 233), Dark = rgb(0, 50, 80) }),
}
RebelUI.Themes = { "Red", "Crimson", "Blue", "Green", "Purple", "Orange", "Pink", "Gold", "Cyber", "Blood", "Ice", "Mono", "Contrast", "Colorblind" }
RebelUI.SourceUrl = "https://raw.githubusercontent.com/RebelUI/Library/main/source.lua"
RebelUI.Lang = {} -- text translations, see RebelUI:SetLanguage

local C = {
	Text = rgb(240, 235, 235),
	Dim = rgb(150, 125, 128),
	White = Color3.new(1, 1, 1),
	Green = rgb(70, 220, 110),
	Yellow = rgb(255, 200, 70),
	Bad = rgb(235, 70, 70),
}

-- ============================================================ helpers
local function new(class, props, parent)
	local o = Instance.new(class)
	if props and type(props.Text) == "string" and RebelUI.Lang[props.Text] then
		props.Text = RebelUI.Lang[props.Text] -- translations (RebelUI:SetLanguage)
	end
	for k, v in pairs(props or {}) do
		o[k] = v
	end
	if parent then
		o.Parent = parent
	end
	return o
end

local function corner(o, r)
	return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, o)
end

local function tween(o, t, props, style, dir)
	local tw = TweenService:Create(
		o,
		TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	tw:Play()
	return tw
end

-- Developer tools. UI.Debug = true prints what the library is doing. UI.OnError = function(where, err) ... end receives every error
-- that RebelUI catches (a broken callback never breaks the rest of the UI). UI.Errors holds the last 50.
RebelUI.Debug = false
RebelUI.OnError = nil
RebelUI.Errors = {}
function RebelUI.Log(...)
	if RebelUI.Debug then
		print("[RebelUI]", ...)
	end
end
function RebelUI._reportError(where, err)
	local list = RebelUI.Errors
	list[#list + 1] = { Where = where, Error = tostring(err), Time = os.time() }
	if #list > 50 then
		table.remove(list, 1)
	end
	RebelUI.Log("error in", where, tostring(err))
	if type(RebelUI.OnError) == "function" then
		pcall(RebelUI.OnError, where, tostring(err))
	end
end

local function safe(fn, ...)
	if type(fn) ~= "function" then
		return
	end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[RebelUI] callback error: " .. tostring(err))
		RebelUI._reportError("callback", err)
	end
end

local function asset(x)
	-- accepts 123456, "123456" or "rbxassetid://123456"
	if type(x) == "number" then
		return "rbxassetid://" .. tostring(math.floor(x))
	end
	x = tostring(x or "")
	if x:match("^%d+$") then
		return "rbxassetid://" .. x
	end
	return x
end

-- ============================================================ your uploaded icon pack, fancy text
-- RebelUI.Icons.key / .padlock / .notification ... : Roblox image ids (black icons). On a dark panel a black icon would vanish,
-- so every place that shows one puts it on a light tile automatically (RebelUI._iconFix).
RebelUI.Icons = {
	silent = 127543229071551, save = 100853731399741, file = 108892160159150, copy = 78967949653653,
	downloads = 108541383384867, refresh = 97420167649054, link = 92386396427078, info = 133363969110623,
	printer = 82923631400917, share = 92335044119803, notification = 125753537841173, ringing = 126612245577406,
	padlock = 124786828881533, openpadlock = 101866153472892, loading = 117902004624996, calendar = 103661816948286,
	key = 97014133087839, elements = 81398540814546, expand = 117887360495259, minimize = 92738514605920,
	wrench = 139235132677195, test = 118555594943008, newkey = 71431118058119, search = 91325208171746, sidebar = 97218104581792, home = 83313298037903, right = 139553391725025, up = 138186535538448, left = 87498021827607, star = 85275169714542,
}
local blackIcons = {}
for _, id in pairs(RebelUI.Icons) do
	blackIcons[tostring(id)] = true
end
-- Black icons cannot be recolored in Roblox, so they get a soft white GLOW behind them (no hard tile).
-- RebelUI.IconGlow = false turns the glow off. RebelUI.IconTile = true goes back to a solid colored tile (RebelUI.IconTileColor).
-- White / transparent icons (see the "white icons" folder) need neither: they show alone.
-- RebelUI.IconMode: "Black" (default) = the plain black icon with NOTHING behind it, no glow, no tile, no recoloring.
--                   "White" = turn them white (downloaded once, falls back to the glow), "Glow" = black icon with a soft white glow.
RebelUI.IconMode = "Black"
RebelUI.IconTile = false
RebelUI.IconTileColor = Color3.fromRGB(226, 52, 62)
RebelUI.IconGlow = true
RebelUI.IconGlowColor = Color3.fromRGB(255, 240, 240)
local haloOf = setmetatable({}, { __mode = "k" })
RebelUI._curId = setmetatable({}, { __mode = "k" })
function RebelUI._iconFix(img, src, tint)
	local k = tostring(src or ""):match("%d+")
	if img then
		RebelUI._curId[img] = k
		if haloOf[img] then
			for _, f in ipairs(haloOf[img]) do
				pcall(function()
					f:Destroy()
				end)
			end
			haloOf[img] = nil
		end
	end
	if not (img and k and blackIcons[k]) then
		return
	end
	if RebelUI.IconTile then
		img.BackgroundTransparency = 0
		img.BackgroundColor3 = tint or RebelUI.IconTileColor
		img.ScaleType = Enum.ScaleType.Fit
		pcall(function()
			Instance.new("UICorner", img).CornerRadius = UDim.new(0, 3)
		end)
		return
	end
	local tintC = RebelUI._iconColor and RebelUI._iconColor[img] -- a colored icon (the blue link icon): turned white, then tinted
	local mode = tintC and "White" or RebelUI.IconMode
	if mode == "Black" then
		img.BackgroundTransparency = 1
		return -- the plain black icon, nothing behind it
	end
	if tintC then
		img.ImageColor3 = tintC
	end
	local halos = {}
	haloOf[img] = halos
	if mode ~= "Glow" and RebelUI._whitenIcon and RebelUI._whitenIcon(img, k, halos) then
		return -- the white version is already saved: no glow needed
	end
	if not RebelUI.IconGlow then
		return
	end
	pcall(function()
		local par = img.Parent
		if not par or par:FindFirstChildOfClass("UIListLayout") then
			return
		end
		local A = img.AnchorPoint or Vector2.new(0, 0)
		local P = img.Position or UDim2.new()
		local S = img.Size or UDim2.new()
		for _, h in ipairs({ { 14, 0.93 }, { 9, 0.86 }, { 4, 0.72 } }) do
			local f = Instance.new("Frame")
			f.Name = "RebelGlow"
			f.AnchorPoint = Vector2.new(0.5, 0.5)
			f.Position = UDim2.new(P.X.Scale + (0.5 - A.X) * S.X.Scale, P.X.Offset + (0.5 - A.X) * S.X.Offset, P.Y.Scale + (0.5 - A.Y) * S.Y.Scale, P.Y.Offset + (0.5 - A.Y) * S.Y.Offset)
			f.Size = UDim2.new(S.X.Scale, S.X.Offset + h[1], S.Y.Scale, S.Y.Offset + h[1])
			f.BackgroundColor3 = tintC or RebelUI.IconGlowColor
			f.BackgroundTransparency = h[2]
			f.BorderSizePixel = 0
			f.Active = false
			f.ZIndex = math.max((img.ZIndex or 1) - 1, 0)
			Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
			f.Parent = par
			halos[#halos + 1] = f
		end
		img.AncestryChanged:Connect(function(_, p)
			if not p then
				for _, f in ipairs(halos) do
					f:Destroy()
				end
			end
		end)
	end)
end

-- swap the picture of an icon (keeps the glow / white version in step)
function RebelUI._setIcon(img, id)
	img.Image = asset(id)
	RebelUI._iconFix(img, id)
end

-- RebelUI.Fancy("lets go!", "Bold") -> 𝐥𝐞𝐭𝐬 𝐠𝐨!   Styles: Bold, Italic, BoldItalic, BoldScript, BoldFraktur, Mono, Sans, SansBold, SansItalic,
-- SansBoldItalic, Fullwidth, Circled. Works anywhere text is shown (titles, notifications, buttons, boom text).
local FANCY = {
	Bold = { 0x1D400, 0x1D41A, 0x1D7CE }, Italic = { 0x1D434, 0x1D44E }, BoldItalic = { 0x1D468, 0x1D482 },
	BoldScript = { 0x1D4D0, 0x1D4EA }, BoldFraktur = { 0x1D56C, 0x1D586 }, Mono = { 0x1D670, 0x1D68A, 0x1D7F6 },
	Sans = { 0x1D5A0, 0x1D5BA, 0x1D7E2 }, SansBold = { 0x1D5D4, 0x1D5EE, 0x1D7EC }, SansItalic = { 0x1D608, 0x1D622 },
	SansBoldItalic = { 0x1D63C, 0x1D656 }, Fullwidth = { 0xFF21, 0xFF41, 0xFF10 }, Circled = { 0x24B6, 0x24D0 },
}
function RebelUI.Fancy(text, style)
	local def = FANCY[style or "Bold"] or FANCY.Bold
	local out = {}
	for _, cp in utf8.codes(tostring(text or "")) do
		local c
		if cp >= 65 and cp <= 90 then
			c = utf8.char(def[1] + cp - 65)
		elseif cp >= 97 and cp <= 122 then
			c = (style == "Italic" and cp == 104) and utf8.char(0x210E) or utf8.char(def[2] + cp - 97)
		elseif cp >= 48 and cp <= 57 and def[3] then
			c = utf8.char(def[3] + cp - 48)
		else
			c = utf8.char(cp)
		end
		out[#out + 1] = c
	end
	return table.concat(out)
end


-- RebelUI.FancyText = "Bold"  -> EVERY label and button text in RebelUI screens is shown in that style (𝐁𝐨𝐥𝐝 𝐬𝐞𝐫𝐢𝐟 letters).
-- Set it BEFORE Loading / CreateWindow. nil = off. Search still works (typed letters are matched against the plain text).
local PLAIN = {}
for _, def in pairs(FANCY) do
	for i = 0, 25 do
		PLAIN[utf8.char(def[1] + i)] = string.char(65 + i)
		PLAIN[utf8.char(def[2] + i)] = string.char(97 + i)
	end
	if def[3] then
		for i = 0, 9 do
			PLAIN[utf8.char(def[3] + i)] = tostring(i)
		end
	end
end
PLAIN[utf8.char(0x210E)] = "h"
function RebelUI._plain(text)
	text = tostring(text or "")
	if not text:find("[\240-\244]") and not text:find("\226") and not text:find("\239") then
		return text
	end
	local out = {}
	for _, cp in utf8.codes(text) do
		local ch = utf8.char(cp)
		out[#out + 1] = PLAIN[ch] or ch
	end
	return table.concat(out)
end
function RebelUI._fancyGui(gui)
	local style = RebelUI.FancyText
	if not style or not gui then
		return
	end
	local function hook(o)
		if not (o:IsA("TextLabel") or o:IsA("TextButton")) then
			return
		end
		local function fix()
			local t = o.Text
			if t ~= "" then
				local f = RebelUI.Fancy(RebelUI._plain(t), style)
				if f ~= t then
					o.Text = f
				end
			end
		end
		pcall(fix)
		pcall(function()
			o:GetPropertyChangedSignal("Text"):Connect(function()
				pcall(fix)
			end)
		end)
	end
	for _, d in ipairs(gui:GetDescendants()) do
		hook(d)
	end
	gui.DescendantAdded:Connect(hook)
end

local origText = setmetatable({}, { __mode = "k" })
local function label(parent, str, size, color, bold)
	local l = new("TextLabel", {
		BackgroundTransparency = 1,
		Text = RebelUI.Lang[str] or str,
		TextSize = size or 11,
		TextColor3 = color or C.Text,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
	if type(str) == "string" then
		origText[l] = str
	end
	return l
end

-- ============================================================ small tools you can use too
-- Translate the panel. Give a table, or the name of a language you added:
--   UI:AddLanguage("Malay", { ["Settings"] = "Tetapan", ["Save settings"] = "Simpan" })
--   UI:SetLanguage("Malay")      -- text already on screen changes right away. UI:SetLanguage() goes back to English.
RebelUI.Languages = {}
function RebelUI:AddLanguage(name, dict)
	RebelUI.Languages[tostring(name)] = type(dict) == "table" and dict or {}
end
function RebelUI:SetLanguage(dict)
	if type(dict) == "string" then
		dict = RebelUI.Languages[dict] or {}
	end
	RebelUI.Lang = type(dict) == "table" and dict or {}
	for l, orig in pairs(origText) do
		pcall(function()
			if l.Parent then
				l.Text = RebelUI.Lang[orig] or orig
			end
		end)
	end
end
-- UI.T("Settings") -> the translated text (use it for your own labels)
function RebelUI.T(str)
	return RebelUI.Lang[str] or str
end

-- A spring: smooth, bouncy movement. local s = UI.Spring.new(0, 12, 0.6); s.Target = 1; s:Update(dt) each frame.
local Spring = {}
Spring.__index = Spring
function Spring.new(value, speed, damping)
	return setmetatable({ Value = value or 0, Target = value or 0, Velocity = 0, Speed = speed or 10, Damping = damping or 0.7 }, Spring)
end
function Spring:Update(dt)
	dt = math.min(dt or 1 / 60, 0.25)
	local steps = math.max(1, math.ceil(dt * 120))
	local h = dt / steps
	local k, c = self.Speed * self.Speed, 2 * self.Damping * self.Speed
	for _ = 1, steps do
		self.Velocity += (k * (self.Target - self.Value) - c * self.Velocity) * h
		self.Value += self.Velocity * h
	end
	return self.Value
end
RebelUI.Spring = Spring

-- A value that tells everyone who is listening when it changes.
--   local score = UI.State(0); score:Bind(labelObj, "Score: %d"); score:Set(5)
local State = {}
State.__index = State
function RebelUI.State(initial)
	return setmetatable({ Value = initial, _fns = {} }, State)
end
function State:Get()
	return self.Value
end
function State:Set(v)
	if v == self.Value then
		return
	end
	self.Value = v
	for _, fn in ipairs(self._fns) do
		safe(fn, v)
	end
end
function State:OnChange(fn)
	table.insert(self._fns, fn)
	return fn
end
function State:Bind(obj, fmt)
	-- obj is any element with :Set (a Label, Paragraph, Slider, Toggle...). fmt is a string.format pattern.
	local function push(v)
		obj:Set(fmt and string.format(fmt, v) or v)
	end
	push(self.Value)
	return self:OnChange(push)
end

local function fitText(l, maxSize)
	l.TextScaled = true
	new("UITextSizeConstraint", { MaxTextSize = maxSize }, l)
end

local function gradient(obj, c0, c1, rot)
	return new("UIGradient", { Color = ColorSequence.new(c0, c1), Rotation = rot or 0 }, obj)
end

local function ringSeq(t)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, t.Glow),
		ColorSequenceKeypoint.new(0.5, t.Dark),
		ColorSequenceKeypoint.new(1, t.Glow),
	})
end

local RAINBOW = (function()
	local k = {}
	for i = 0, 6 do
		k[#k + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 0.85, 1))
	end
	return ColorSequence.new(k)
end)()

local function pulse(obj)
	local sc = new("UIScale", {}, obj)
	TweenService:Create(
		sc,
		TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Scale = 1.12 }
	):Play()
	return sc
end

local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

-- Mouse or finger drag on a bar. onRel gets a number from 0 to 1.
local function bindBar(win, bar, onRel, onState)
	local dragging = false
	local function fromInput(i)
		local w = bar.AbsoluteSize.X
		if w <= 0 then
			return
		end
		onRel(math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1))
	end
	bar.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			if onState then
				onState(true)
			end
			fromInput(i)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			fromInput(i)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			if onState then
				onState(false)
			end
		end
	end)
end

local function pickParent()
	local ok, h = pcall(function()
		return gethui and gethui()
	end)
	if ok and h then
		return h
	end
	ok, h = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and h then
		return h
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function clearOld(name)
	local lp = Players.LocalPlayer
	local places = { pickParent() }
	local pg = lp and lp:FindFirstChildOfClass("PlayerGui")
	if pg then
		table.insert(places, pg)
	end
	for _, place in ipairs(places) do
		for _, g in ipairs(place:GetChildren()) do
			if g.Name == name then
				g:Destroy()
			end
		end
	end
end

local function toHex(c)
	return string.format(
		"#%02X%02X%02X",
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5)
	)
end

local function fromHex(s)
	s = tostring(s):gsub("#", "")
	if #s ~= 6 then
		return nil
	end
	local r, g, b = tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16)
	if not (r and g and b) then
		return nil
	end
	return Color3.fromRGB(r, g, b)
end

function Window:_onTheme(fn)
	fn(self.Theme)
	table.insert(self._fns, fn)
end

-- a stroke whose gradient spins around the object and follows the theme
function Window:_ring(stroke)
	stroke.Color = Color3.new(1, 1, 1)
	local g = new("UIGradient", { Color = self._rainbow and RAINBOW or ringSeq(self.Theme) }, stroke)
	table.insert(self._spin, g)
	return g
end

-- turns a link, a file name or an asset id into something an ImageLabel / VideoFrame can show (nil if it can't)
local function resolveMedia(src, file)
	src = tostring(src or "")
	if src:match("^%d+$") or src:match("^rbxasset") then
		return asset(src)
	end
	local gca = getcustomasset or get_custom_asset
	if src:match("^https?://") then
		if not file then
			local h = 0
			for i = 1, #src do
				h = (h * 31 + src:byte(i)) % 1000000007
			end
			file = "RebelUI_media_" .. h .. ".mp4"
		end
		if type(isfile) == "function" and isfile(file) and gca then
			local okC, size = pcall(function()
				return #readfile(file)
			end)
			if okC and size > 1000 and size < 30000000 then
				local okA, a = pcall(gca, file)
				if okA then
					return a
				end
			end
		end
		local req = (syn and syn.request) or request or http_request
		local function fetch(u)
			if req then
				local ok, res = pcall(req, { Url = u, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36", Referer = u } })
				if ok and res and type(res.Body) == "string" then
					return res.Body
				end
			end
			local ok, b = pcall(function()
				return game:HttpGet(u)
			end)
			return ok and type(b) == "string" and b or nil
		end
		local function isVideo(b)
			return type(b) == "string" and #b > 20000 and not b:sub(1, 600):lower():find("<html", 1, true)
		end
		local body = fetch(src)
		if body and not isVideo(body) then
			-- it was a web page (a video host's player). Look for the real video file inside it.
			local page = body:gsub("\\/", "/"):gsub("&amp;", "&")
			local found
			for _, pat in ipairs({ '<source[^>]-src=["\']([^"\']+)["\']', '<video[^>]-src=["\']([^"\']+)["\']', '["\']file["\']%s*:%s*["\']([^"\']+)["\']', '["\']src["\']%s*:%s*["\']([^"\']+)["\']', '(https?://[^%s"\'<>\\]+%.mp4[^%s"\'<>\\]*)', '(https?://[^%s"\'<>\\]+%.webm[^%s"\'<>\\]*)' }) do
				for u in page:gmatch(pat) do
					if u:lower():find("%.mp4") or u:lower():find("%.webm") or u:lower():find("/video") or u:lower():find("/download") then
						found = u
						break
					end
				end
				if found then
					break
				end
			end
			if found then
				if found:sub(1, 2) == "//" then
					found = "https:" .. found
				elseif found:sub(1, 1) == "/" then
					found = src:match("^(https?://[^/]+)") .. found
				end
				body = fetch(found)
			else
				body = nil
			end
		end
		if not isVideo(body) or #body > 30000000 then
			if body and #body > 30000000 then
				warn("[RebelUI] that video is over 30 MB, so it was skipped (make it smaller)")
			end
			body = nil
		end
		if body and writefile and gca then
			pcall(writefile, file, body)
			local ok, a = pcall(gca, file)
			if ok then
				return a
			end
		end
		return nil
	end
	if gca and type(isfile) == "function" and isfile(src) then
		local ok, a = pcall(gca, src)
		if ok then
			return a
		end
	end
	return nil
end
RebelUI.ResolveMedia = resolveMedia

-- ============================================================ device, images, developer switch
-- RebelUI.Device() -> "Mobile" (touch, no keyboard) or "PC". Windows, key panels and buttons size themselves from it.
function RebelUI.Device()
	local touch, kb = false, false
	pcall(function()
		touch = UIS.TouchEnabled
		kb = UIS.KeyboardEnabled
	end)
	if touch and not kb then
		return "Mobile"
	end
	return "PC"
end
-- RebelUI.Setup = "Auto" | "Mobile" | "PC": force a setup (Auto = detect). Read it with RebelUI.GetSetup().
RebelUI.Setup = "Auto"
function RebelUI.GetSetup(pref)
	pref = pref or RebelUI.Setup
	if pref == "Mobile" or pref == "PC" then
		return pref
	end
	return RebelUI.Device()
end

-- Roblox can't show a web picture directly. This downloads it once, keeps it in the workspace folder and returns a
-- local asset you can put in any ImageLabel.Image. Numbers and rbxassetid:// strings are returned as they are.
-- Returns nil when it can't (then show a color or text instead).
local imgCache = {}
function RebelUI.ResolveImage(src, file)
	src = tostring(src or "")
	if src == "" then
		return nil
	end
	if not src:match("^https?://") then
		return asset(src)
	end
	if imgCache[src] then
		return imgCache[src]
	end
	local gca = getcustomasset or get_custom_asset
	if not gca or type(writefile) ~= "function" then
		return nil
	end
	if not file then
		local h = 0
		for i = 1, #src do
			h = (h * 31 + src:byte(i)) % 1000000007
		end
		file = "RebelUI_img_" .. h .. ".png"
	end
	local function tryAsset()
		if type(isfile) == "function" and isfile(file) then
			local okS, sz = pcall(function()
				return #readfile(file)
			end)
			if okS and sz > 200 then
				local ok, a = pcall(gca, file)
				if ok and a then
					return a
				end
			end
		end
	end
	local a = tryAsset()
	if a then
		imgCache[src] = a
		return a
	end
	local req = (syn and syn.request) or request or http_request
	local body
	if req then
		local ok, res = pcall(req, { Url = src, Method = "GET" })
		if ok and res and type(res.Body) == "string" and (res.StatusCode == nil or res.StatusCode == 200) then
			body = res.Body
		end
	end
	if not body then
		local ok, b = pcall(function()
			return game:HttpGet(src)
		end)
		body = ok and type(b) == "string" and b or nil
	end
	-- a real picture starts with the PNG or JPEG signature, a web page does not
	if body and #body > 200 and (body:sub(2, 4) == "PNG" or body:sub(1, 2) == "\255\216") then
		pcall(writefile, file, body)
		a = tryAsset()
		if a then
			imgCache[src] = a
			return a
		end
	end
	return nil
end
-- Put a picture in an ImageLabel/ImageButton from anything: asset id, rbxassetid://, or a web link (loads in the background).
function RebelUI.SetImage(obj, src, onLoaded)
	if src == nil or src == "" then
		return
	end
	src = tostring(src)
	if not src:match("^https?://") then
		obj.Image = asset(src)
		if onLoaded then
			onLoaded(true)
		end
		return
	end
	task.spawn(function()
		local a = RebelUI.ResolveImage(src)
		if a then
			pcall(function()
				obj.Image = a
			end)
		end
		if onLoaded then
			onLoaded(a ~= nil)
		end
	end)
end

-- Developer switch. ON: the script works. OFF: it does nothing when someone runs it.
--   local UI = loadstring(game:HttpGet(".../source.lua"))()
--   if not UI:Switch({ On = true, Url = "https://.../switch.txt" }) then return end
-- Url (optional): a text file you edit any time, saying on / off (also true/false/1/0/enabled/disabled), so you can shut
-- the script off for everyone without re-uploading it. If the Url can't be read, FailOpen decides (default true = keep working).
function RebelUI:Switch(o)
	if type(o) == "boolean" then
		o = { On = o }
	end
	o = o or {}
	local on = o.On ~= false
	if on and o.Url then
		local ok, body = pcall(function()
			return game:HttpGet(tostring(o.Url) .. (tostring(o.Url):find("?", 1, true) and "&" or "?") .. "t=" .. tostring(os.time()))
		end)
		if ok and type(body) == "string" then
			local w = body:lower():match("^%s*([%a%d]+)")
			if w == "off" or w == "false" or w == "0" or w == "disabled" or w == "no" or w == "stop" then
				on = false
			elseif w == "on" or w == "true" or w == "1" or w == "enabled" or w == "yes" then
				on = true
			elseif o.FailOpen == false then
				on = false
			end
		elseif o.FailOpen == false then
			on = false
		end
	end
	RebelUI._off = not on
	if not on then
		warn("[" .. tostring(o.Name or "RebelUI") .. "] " .. tostring(o.Message or "This script is switched OFF by the developer."))
		if o.Toast ~= false then
			pcall(function()
				pcall(function()
					game:GetService("StarterGui"):SetCore("SendNotification", { Title = tostring(o.Name or "RebelUI"), Text = tostring(o.Message or "Switched OFF by the developer."), Duration = 5 })
				end)
			end)
		end
	end
	return on
end
-- a quiet stand-in returned by CreateWindow while the switch is OFF, so a script that forgot to return keeps working without a panel
local function quietStub()
	local stub
	stub = setmetatable({ Flags = {}, Open = false }, {
		__index = function(_, k)
			if k == "Flags" then
				return {}
			end
			return function(self2, ...)
				return stub
			end
		end,
	})
	return stub
end

-- ============================================================ loading screen
local function fadeOut(root, dur)
	local info = TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local function tw(obj, props)
		pcall(function()
			TweenService:Create(obj, info, props):Play()
		end)
	end
	tw(root, { BackgroundTransparency = 1 })
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("UIStroke") then
			tw(d, { Transparency = 1 })
		elseif d:IsA("ImageLabel") then
			tw(d, { ImageTransparency = 1, BackgroundTransparency = 1 })
		elseif d:IsA("TextLabel") or d:IsA("TextButton") then
			tw(d, { TextTransparency = 1, TextStrokeTransparency = 1, BackgroundTransparency = 1 })
		elseif d:IsA("Frame") then
			tw(d, { BackgroundTransparency = 1 })
		end
	end
end

function RebelUI:Loading(o)
	-- Title, Subtitle, Logo, Banner, Footer, Theme, Name, Timeout
	-- Returns L with :Progress(0-1) :Status(text) :Badge(text) :Preload({ids}) :Run(steps) :Fail(text) :Finish()
	o = o or {}
	local theme = THEMES[o.Theme or "Red"] or THEMES.Red
	local name = o.Name or "RebelUI_Loading"
	clearOld(name)
	local L = {}
	local sg = new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 10000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	pcall(function()
		sg.ScreenInsets = Enum.ScreenInsets.None
	end)
	sg.Parent = pickParent()
	RebelUI._fancyGui(sg)

	local root = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(8, 3, 5),
		BorderSizePixel = 0,
		Active = true,
		ClipsDescendants = true,
		ZIndex = 1,
	}, sg)

	if o.Banner then
		local banner = new("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = asset(o.Banner),
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 1,
		}, root)
		local bs = new("UIScale", {}, banner)
		TweenService:Create(bs, TweenInfo.new(14, Enum.EasingStyle.Linear), { Scale = 1.12 }):Play()
	end
	-- a loading video (optional). Video = link / file name / asset id. L:SetVideo(x) can add it later.
	local function attachVideo(src)
		if not src or L.Dead then
			return
		end
		pcall(function()
			if L.VideoFrame then
				L.VideoFrame:Destroy()
			end
			local vf = new("VideoFrame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Looped = o.VideoLoop ~= false,
				Volume = o.VideoVolume or 0,
				Video = src,
				ZIndex = 1,
			}, root)
			vf.Playing = true
			pcall(function()
				vf:Play()
			end)
			L.VideoFrame = vf
			-- if the video never loads (some executors can't play them) remove it so the banner stays
			task.delay(8, function()
				pcall(function()
					if vf.Parent and not vf.IsLoaded then
						vf:Destroy()
					end
				end)
			end)
		end)
	end
	function L:SetVideo(v)
		task.spawn(function()
			local okR, src = pcall(resolveMedia, v, o.VideoFile)
			if okR then
				attachVideo(src)
			end
		end)
	end
	if o.Video then
		L:SetVideo(o.Video)
	end
	-- dark shade (heavier at the bottom) and an accent glow at the bottom
	local shade = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 2 }, root)
	new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.75),
			NumberSequenceKeypoint.new(0.45, 0.6),
			NumberSequenceKeypoint.new(1, 0.1),
		}),
	}, shade)
	local tint = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = theme.Accent:Lerp(Color3.new(0, 0, 0), 0.35),
		BorderSizePixel = 0,
		ZIndex = 2,
	}, root)
	new("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.55, 1),
			NumberSequenceKeypoint.new(1, 0.72),
		}),
	}, tint)

	-- rising embers
	local embers = {}
	for i = 1, 24 do
		local s = math.random(2, 5)
		local e = new("Frame", {
			Size = UDim2.fromOffset(s, s),
			BackgroundColor3 = (math.random() < 0.5) and theme.Glow or theme.Accent:Lerp(Color3.new(1, 0.7, 0.2), 0.5),
			BackgroundTransparency = 0.25 + math.random() * 0.5,
			BorderSizePixel = 0,
			ZIndex = 3,
		}, root)
		corner(e, s)
		embers[i] = { f = e, x = math.random(), y = math.random(), sp = 0.04 + math.random() * 0.09, ph = math.random() * 6.28, fr = 0.6 + math.random() }
	end

	-- badge (top center)
	local badge = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.08, 0),
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		Text = "",
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextColor3 = C.Text,
		Visible = false,
		ZIndex = 6,
	}, root)
	corner(badge, 13)
	new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, badge)
	local badgeStroke = new("UIStroke", {
		Color = theme.Glow,
		Thickness = 1,
		Transparency = 0.3,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, badge)

	-- logo with a spinning ring
	local spin = {}
	if o.Logo then
		local logoL = new("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.27, 0),
			Size = UDim2.fromOffset(84, 84),
			BackgroundTransparency = 1,
			Image = asset(o.Logo),
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 5,
		}, root)
		corner(logoL, 18)
		local logoRing = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.new(1, 1, 1), Thickness = 2 }, logoL)
		table.insert(spin, new("UIGradient", { Color = ringSeq(theme) }, logoRing))
		pulse(logoL)
	end

	-- title: accent text with a white shine sweeping across
	local titleL = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.42, 0),
		Size = UDim2.fromOffset(340, 62),
		BackgroundTransparency = 1,
		Text = o.Title or "RebelUI",
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		ZIndex = 5,
	}, root)
	new("UITextSizeConstraint", { MaxTextSize = 50 }, titleL)
	new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 2.5 }, titleL)
	local base = theme.Accent:Lerp(Color3.new(1, 1, 1), 0.05)
	local titleGrad = new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, base),
			ColorSequenceKeypoint.new(0.42, base),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.58, base),
			ColorSequenceKeypoint.new(1, base),
		}),
	}, titleL)
	local titleScale = new("UIScale", { Scale = 0.7 }, titleL)
	if o.Subtitle then
		new("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.42, 46),
			Size = UDim2.fromOffset(320, 16),
			BackgroundTransparency = 1,
			Text = string.upper(o.Subtitle),
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(235, 215, 218),
			TextTransparency = 0.15,
			ZIndex = 5,
		}, root)
	end

	-- loading bar block
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.8, 0),
		Size = UDim2.new(0.6, 0, 0, 44),
		BackgroundTransparency = 1,
		ZIndex = 5,
	}, root)
	new("UISizeConstraint", { MaxSize = Vector2.new(400, 44), MinSize = Vector2.new(220, 44) }, holder)
	local statusL = label(holder, "", 13, C.Text, false)
	statusL.Size = UDim2.new(1, -60, 0, 18)
	statusL.Position = UDim2.fromOffset(2, 0)
	statusL.Font = Enum.Font.GothamMedium
	statusL.ZIndex = 6
	local pctL = label(holder, "0%", 13, C.Text, true)
	pctL.Size = UDim2.fromOffset(56, 18)
	pctL.Position = UDim2.new(1, -56, 0, 0)
	pctL.TextXAlignment = Enum.TextXAlignment.Right
	pctL.ZIndex = 6
	local outer = new("Frame", { Size = UDim2.new(1, 0, 0, 16), Position = UDim2.fromOffset(0, 24), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 6 }, holder)
	corner(outer, 8)
	local redRing = new("Frame", { Size = UDim2.new(1, -2, 1, -2), Position = UDim2.fromOffset(1, 1), BackgroundColor3 = theme.Glow, BorderSizePixel = 0, ZIndex = 6 }, outer)
	corner(redRing, 7)
	local inner = new("Frame", {
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.fromOffset(1, 1),
		BackgroundColor3 = Color3.fromRGB(18, 7, 9),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 7,
	}, redRing)
	corner(inner, 6)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 8 }, inner)
	corner(fill, 6)
	gradient(fill, theme.Accent, theme.Accent:Lerp(Color3.new(1, 0.7, 0.3), 0.55), 0)
	local shimmer = new("Frame", { Size = UDim2.fromScale(0.4, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 9 }, fill)
	new("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.45),
			NumberSequenceKeypoint.new(1, 1),
		}),
	}, shimmer)

	if o.Footer ~= false then
		new("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.94, 0),
			Size = UDim2.fromOffset(320, 16),
			BackgroundTransparency = 1,
			Text = o.Footer or ("RebelUI v" .. RebelUI.Version),
			Font = Enum.Font.Gotham,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(210, 180, 182),
			TextTransparency = 0.25,
			ZIndex = 5,
		}, root)
	end

	local target, displayed, alive = 0, 0, true
	local conn = RunService.RenderStepped:Connect(function(dt)
		local now = os.clock()
		displayed += (target - displayed) * math.min(1, dt * 5)
		fill.Size = UDim2.fromScale(math.clamp(displayed, 0, 1), 1)
		pctL.Text = math.floor(displayed * 100 + 0.5) .. "%"
		shimmer.Position = UDim2.fromScale(((now * 0.9) % 1.6) - 0.5, 0)
		titleGrad.Offset = Vector2.new(((now * 0.55) % 2) - 1, 0)
		local rot = (now * 90) % 360
		for _, g in ipairs(spin) do
			g.Rotation = rot
		end
		for _, e in ipairs(embers) do
			e.y -= e.sp * dt
			if e.y < -0.05 then
				e.y = 1.05
				e.x = math.random()
			end
			e.f.Position = UDim2.new(e.x, math.sin(now * e.fr + e.ph) * 14, e.y, 0)
		end
	end)
	tween(titleScale, 0.7, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	function L:Progress(p)
		target = math.clamp(tonumber(p) or 0, 0, 1)
	end
	function L:Status(text, color)
		statusL.Text = tostring(text or "")
		statusL.TextColor3 = color or C.Text
		statusL.TextTransparency = 1
		statusL.Position = UDim2.fromOffset(2, 6)
		tween(statusL, 0.25, { TextTransparency = 0, Position = UDim2.fromOffset(2, 0) })
	end
	function L:Badge(text, color)
		badge.Text = tostring(text or "")
		badge.TextColor3 = color or C.Text
		badgeStroke.Color = color or theme.Glow
		badge.Visible = true
		badge.BackgroundTransparency = 1
		tween(badge, 0.3, { BackgroundTransparency = 0.35 })
	end
	function L:Fail(text)
		fill.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
		L:Status(text or "Something went wrong", Color3.fromRGB(255, 90, 90))
	end
	-- loads images / sounds ahead of time and moves the bar from `from` to `to` while it works
	function L:Preload(list, from, to)
		list = list or {}
		from, to = from or target, to or 1
		local ids = {}
		for _, x in ipairs(list) do
			table.insert(ids, asset(x))
		end
		if #ids == 0 then
			return
		end
		local done, finished = 0, false
		task.spawn(function()
			pcall(function()
				game:GetService("ContentProvider"):PreloadAsync(ids, function()
					done += 1
					L:Progress(from + (to - from) * math.min(done / #ids, 1))
				end)
			end)
			finished = true
		end)
		local t0 = os.clock()
		while not finished and os.clock() - t0 < 5 do
			task.wait(0.05)
		end
	end
	-- Run({ {"Loading assets", function() ... end}, {"Building panel", fn} }): shows each step and fills the bar
	function L:Run(steps)
		steps = steps or {}
		for i, step in ipairs(steps) do
			L:Status(step[1])
			if type(step[2]) == "function" then
				local ok, err = pcall(step[2])
				if not ok then
					warn("[RebelUI] loading step failed: " .. tostring(err))
				end
			end
			L:Progress(i / #steps)
			task.wait(0.18)
		end
	end
	function L:Finish()
		if not alive then
			return
		end
		alive = false
		target = 1
		local t0 = os.clock()
		while displayed < 0.985 and os.clock() - t0 < 1.2 do
			task.wait()
		end
		task.wait(0.25)
		tween(titleScale, 0.55, { Scale = 1.15 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		fadeOut(root, 0.55)
		task.wait(0.65)
		conn:Disconnect()
		sg:Destroy()
	end
	function L:Destroy()
		L.Dead = true
		alive = false
		conn:Disconnect()
		sg:Destroy()
	end
	L.Gui = sg
	-- tap anywhere to skip (after 2.5 seconds), so a loading screen can never trap you
	if o.Skippable ~= false then
		local born = os.clock()
		local hint = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -14, 1, -10),
			Size = UDim2.fromOffset(120, 16),
			BackgroundTransparency = 1,
			Text = "Tap to skip",
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.35,
			TextXAlignment = Enum.TextXAlignment.Right,
			Visible = false,
			ZIndex = 20,
		}, root)
		task.delay(2.5, function()
			if alive then
				hint.Visible = true
			end
		end)
		root.InputBegan:Connect(function(i)
			if alive and os.clock() - born > 2.5 and isPress(i) then
				L:Destroy()
			end
		end)
	end
	-- safety net: if your script never calls Finish, the screen removes itself so it can never trap the player
	local limit = o.Timeout or 40
	task.delay(limit, function()
		if alive and sg.Parent then
			warn("[RebelUI] the loading screen was still open after " .. limit .. "s and was closed. Call Load:Finish().")
			L:Destroy()
		end
	end)
	return L
end

-- ============================================================ window
function RebelUI:CreateWindow(o)
	o = o or {}
	if RebelUI._off then
		return quietStub()
	end
	local win = setmetatable({
		_conns = {},
		_fns = {},
		_tabs = {},
		_spin = {},
		_frame = {},
		_keybinds = {},
		Flags = {},
		Open = false,
		Sound = o.Sound == true,
		Toasts = o.Toasts ~= false,
		NotifyTime = 4,
		ConfirmClose = o.ConfirmClose == true,
		Scale = 1,
		Inertia = o.Inertia ~= false,
		Scramble = o.Scramble ~= false,
		Opacity = 100,
		ToggleKey = o.ToggleKey or Enum.KeyCode.RightShift,
		AnimSpeed = o.AnimSpeed or 1,
		OpenAnim = o.OpenAnimation or "Pop",
		CloseAnimation = o.CloseAnimation or "BlackHole", -- Normal, BlackHole, Shatter, TVOff, Spin, Implode, Custom (with CloseMedia), None
		CloseMedia = o.CloseMedia,
		BoomStyle = o.BoomStyle, -- Classic, Confetti, Shockwave, Sparks, Diamonds, Custom (with BoomImage), None
		BoomImage = o.BoomImage,
		ReduceMotion = o.ReduceMotion == true,
		ToggleStyle = o.ToggleStyle, -- "Switch", "Sharp", "Checkbox", "Check", "Radio", "Heart", "Star" (a Toggle can still pick its own Style)
		SliderStyle = o.SliderStyle, -- "Sharp" gives diamond knobs and square bars
	}, Window)
	local themeName = THEMES[o.Theme or "Red"] and (o.Theme or "Red") or "Red"
	win.Theme = THEMES[themeName]
	win.ThemeName = themeName
	win.TitleText = o.Title or "RebelUI"
	win._icon = o.Icon
	local lp = Players.LocalPlayer

	local name = o.Name or "RebelUI"
	clearOld(name)

	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 500)
	if vp.X < 200 or vp.Y < 150 then
		vp = Vector2.new(800, 450) -- some executors report 0 right after joining
	end
	-- Setup = "Auto" (detect), "Mobile" or "PC". Mobile: a compact panel and a big thumb-sized open button.
	-- PC: a wider, taller panel. Width/Height you pass always win.
	win.Setup = RebelUI.GetSetup(o.Setup)
	local pc = win.Setup == "PC"
	local width = math.floor(math.min(o.Width or (pc and 560 or 420), math.max(300, vp.X * (pc and 0.7 or 0.9))))
	local height = math.floor(math.min(o.Height or (pc and 380 or 340), math.max(200, vp.Y * (pc and 0.78 or 0.85))))
	win._baseSize = { width, height }

	local gui = new("ScreenGui", {
		Name = name,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 999,
	})
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	gui.Parent = pickParent()
	RebelUI._fancyGui(gui)
	win.Gui = gui

	win._click = new("Sound", { SoundId = "rbxasset://sounds/electronicpingshort.wav", Volume = 0.6 }, gui)

	-- ---------- the panel: spinning ring + thin black outer ring
	local main = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = o.Position or UDim2.new(0.5, 0, 0.5, 22),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Active = true,
		Visible = false,
		ClipsDescendants = false,
	}, gui)
	corner(main, 10)
	local mainG = new("UIGradient", { Rotation = 90 }, main)
	local panelScale = new("UIScale", { Scale = 0.6 }, main)
	local ringStroke = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1 }, main)
	win:_ring(ringStroke)
	local blackRing = new("Frame", {
		Size = UDim2.new(1, 2, 1, 2),
		Position = UDim2.fromOffset(-1, -1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
	}, main)
	corner(blackRing, 11)
	new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }, blackRing)
	win.Main, win._mainG, win._scaleObj = main, mainG, panelScale
	win._ringStroke = ringStroke

	-- embers drifting up behind the content
	local fx = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Active = false }, main)
	corner(fx, 10)
	local embers = {}
	for i = 1, 14 do
		local s = math.random(2, 4)
		local e = new("Frame", {
			Size = UDim2.fromOffset(s, s),
			BackgroundTransparency = 0.45 + math.random() * 0.4,
			BorderSizePixel = 0,
		}, fx)
		corner(e, s)
		embers[i] = { f = e, x = math.random(), y = math.random(), sp = 0.03 + math.random() * 0.06, ph = math.random() * 6.28, fr = 0.5 + math.random(), odd = i % 2 == 0 }
	end

	-- ---------- side column: logo, title, tabs, player card
	local side = new("Frame", {
		Size = UDim2.new(0, 110, 1, -10),
		Position = UDim2.fromOffset(5, 5),
		BackgroundColor3 = Color3.new(1, 1, 1),
	}, main)
	corner(side, 12)
	local sideG = new("UIGradient", { Rotation = 90 }, side)
	local titleX = o.Icon and 29 or 8
	local titleL = label(side, win.TitleText, 11, C.Text, true)
	titleL.Size = UDim2.new(1, -(titleX + 3), 0, 14)
	titleL.Position = UDim2.fromOffset(titleX, 11)
	fitText(titleL, 11)
	if o.Subtitle then
		local sub = label(side, o.Subtitle, 8, C.Dim, false)
		sub.Size = UDim2.new(1, -10, 0, 10)
		sub.Position = UDim2.fromOffset(6, 27)
		fitText(sub, 8)
	end
	if o.Icon then
		local logo = new("ImageLabel", {
			Size = UDim2.fromOffset(20, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(15, 16),
			BackgroundTransparency = 1,
			Image = asset(o.Icon),
			ScaleType = Enum.ScaleType.Fit,
		}, side)
		corner(logo, 10)
		RebelUI._iconFix(logo, o.Icon)
		pulse(logo)
	end
	local showProfile = o.Profile ~= false and lp ~= nil
	local tabList = new("ScrollingFrame", {
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -10, 1, showProfile and -96 or -46),
		Position = UDim2.fromOffset(5, 40),
		BackgroundTransparency = 1,
	}, side)
	new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)
	local profile
	if showProfile then
		profile = new("Frame", { Size = UDim2.new(1, -10, 0, 46), Position = UDim2.new(0, 5, 1, -51) }, side)
		corner(profile, 10)
		local avatar = new("ImageLabel", {
			Size = UDim2.fromOffset(32, 32),
			Position = UDim2.fromOffset(6, 7),
			BackgroundTransparency = 1,
			Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150",
		}, profile)
		corner(avatar, 16)
		local u = label(profile, "@" .. lp.Name, 11, C.Text, true)
		u.Size = UDim2.new(1, -46, 0, 16)
		u.Position = UDim2.fromOffset(42, 9)
		local n = label(profile, lp.DisplayName, 8, C.Dim, false)
		n.Size = UDim2.new(1, -46, 0, 11)
		n.Position = UDim2.fromOffset(42, 26)
	end

	-- ---------- content column: page title, glowing line, - and X
	local content = new("Frame", {
		Size = UDim2.new(1, -126, 1, -10),
		Position = UDim2.fromOffset(121, 5),
		BackgroundTransparency = 1,
	}, main)
	local pageTitle = label(content, "", 12, C.Text, true)
	local hasSearch = o.Search ~= false
	pageTitle.Size = UDim2.new(1, hasSearch and -196 or -84, 0, 22)
	pageTitle.Position = UDim2.fromOffset(4, 4)
	if hasSearch then
		local sb = new("TextBox", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -84, 0, 6), -- stays left of the expand, - and X buttons
			Size = UDim2.fromOffset(104, 18),
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "Search...",
			PlaceholderColor3 = C.Dim,
			TextColor3 = C.Text,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false,
			ZIndex = 8,
		}, content)
		corner(sb, 9)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 6) }, sb)
		win:_bind(sb, "BackgroundColor3", "Inset")
		win._search = sb
		sb:GetPropertyChangedSignal("Text"):Connect(function()
			win:_filter(sb.Text)
		end)
	end
	local underline = new("Frame", {
		Size = UDim2.new(1, -86, 0, 2),
		Position = UDim2.fromOffset(4, 26),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, content)
	corner(underline, 1)
	local ulG = new("UIGradient", {}, underline)
	win._pageTitle, win._content, win._side, win._tabList = pageTitle, content, side, tabList

	local function smallButton(txt, x, size, color)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(1, x, 0, 0),
			BackgroundTransparency = 1,
			Text = txt,
			TextColor3 = color,
			TextSize = size,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
		}, content)
		new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.2 }, b)
		return b
	end
	local miniBtn = smallButton("-", -52, 16, Color3.fromRGB(120, 120, 120))
	local closeBtn = smallButton("X", -26, 12, Color3.fromRGB(235, 40, 50))
	win._closeBtn = closeBtn
	-- expand / restore button, connected to the panel (Win:Maximize)
	local expBtn = new("ImageButton", { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -78, 0, 4), BackgroundTransparency = 1, Image = asset(RebelUI.Icons.expand), ScaleType = Enum.ScaleType.Fit, AutoButtonColor = false, ZIndex = 5 }, content)
	RebelUI._iconFix(expBtn, RebelUI.Icons.expand)
	win._expandBtn = expBtn

	-- ---------- notifications (slide up from the bottom, stack)
	local notes = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -16),
		Size = UDim2.new(0, 260, 1, -40),
		BackgroundTransparency = 1,
		ZIndex = 50,
	}, gui)
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}, notes)
	win._notes = notes

	-- ---------- round button that opens the panel (only shown when there is no top bar)
	local fabSize = pc and 44 or 54
	local fab = new("TextButton", {
		Position = UDim2.new(0, 12, 0.5, -fabSize // 2),
		Size = UDim2.fromOffset(fabSize, fabSize),
		Text = "",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Visible = false,
		AutoButtonColor = false,
		ZIndex = 20,
	}, gui)
	win._fabCorner = corner(fab, fabSize // 2)
	win._fabSize = fabSize
	local fabG = new("UIGradient", { Rotation = 90 }, fab)
	local fabRing = new("UIStroke", { Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, fab)
	win:_ring(fabRing)
	if not o.Icon then
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "R",
			TextSize = pc and 20 or 24,
			Font = Enum.Font.GothamBlack,
			TextColor3 = C.Text,
			ZIndex = 21,
		}, fab)
	end
	if o.Icon then
		-- the picture fills the whole button (cropped, no empty edges) and follows the shape: circle or square
		local fi = new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 21,
		}, fab)
		RebelUI.SetImage(fi, o.Icon)
		win._fabImgCorner = corner(fi, fabSize // 2)
	end
	do
		local down, moved, startPos, startMouse = false, 0, nil, nil
		fab.InputBegan:Connect(function(i)
			if isPress(i) then
				down, moved = true, 0
				startMouse, startPos = i.Position, fab.Position
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if down and isMove(i) then
				local d = i.Position - startMouse
				moved = math.max(moved, d.Magnitude)
				if moved > 6 then
					fab.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				end
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if down and isPress(i) then
				down = false
				if moved <= 6 then
					win:Toggle(true)
				end
			end
		end)
	end
	win._fab = fab

	-- ---------- dragging the panel by the title strips
	local function makeDraggable(handle)
		local dragging, startMouse, startPos = false, nil, nil
		local lx, ly, lt, vx, vy = 0, 0, 0, 0, 0
		handle.InputBegan:Connect(function(i)
			if isPress(i) then
				dragging = true
				startMouse = i.Position
				startPos = main.Position
				win._glide = nil
				lx, ly, lt, vx, vy = i.Position.X, i.Position.Y, os.clock(), 0, 0
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if dragging and isMove(i) then
				local d = i.Position - startMouse
				main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				local now = os.clock()
				local dt = now - lt
				if dt > 0.001 then
					vx = vx * 0.5 + ((i.Position.X - lx) / dt) * 0.5
					vy = vy * 0.5 + ((i.Position.Y - ly) / dt) * 0.5
					lx, ly, lt = i.Position.X, i.Position.Y, now
				end
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if dragging and isPress(i) then
				dragging = false
				-- let go while moving: the panel keeps gliding and slows down (Inertia = false turns it off)
				if win.Inertia and os.clock() - lt < 0.08 and math.abs(vx) + math.abs(vy) > 150 then
					win._glide = { x = math.clamp(vx, -1500, 1500), y = math.clamp(vy, -1500, 1500) }
				end
			end
		end)
	end
	local function strip(p, size, pos)
		local f = new("Frame", { Size = size, Position = pos, BackgroundTransparency = 1, ZIndex = 5 }, p)
		makeDraggable(f)
	end
	strip(content, UDim2.new(1, -54, 0, 26), UDim2.fromOffset(0, 0))
	strip(side, UDim2.new(1, 0, 0, 36), UDim2.fromOffset(0, 0))

	-- ---------- theme painting
	win:_onTheme(function(t)
		mainG.Color = ColorSequence.new(t.BG0, t.BG1)
		sideG.Color = ColorSequence.new(t.S0, t.S1)
		fabG.Color = ColorSequence.new(t.S1, t.B1)
		ulG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, t.Dark),
			ColorSequenceKeypoint.new(0.5, t.Glow),
			ColorSequenceKeypoint.new(1, t.Dark),
		})
		if profile then
			profile.BackgroundColor3 = t.Item
		end
		for _, g in ipairs(win._spin) do
			g.Color = win._rainbow and RAINBOW or ringSeq(t)
		end
		for _, e in ipairs(embers) do
			e.f.BackgroundColor3 = e.odd and t.Glow or t.Accent:Lerp(Color3.new(1, 0.7, 0.3), 0.5)
		end
	end)

	-- ---------- one render loop: spinning rings, moving gradients, embers
	win._conns[#win._conns + 1] = RunService.RenderStepped:Connect(function(dt)
		local now = os.clock()
		local rot = (now * 80) % 360
		win._tick = (win._tick or 0) + 1
		if win._tick % 2 == 0 or win.Open then -- the rings turn at half speed of updates when the panel is closed
			for _, g in ipairs(win._spin) do
				g.Rotation = rot
			end
		end
		if win.Open then
			mainG.Offset = Vector2.new(0, math.sin(now * 0.6) * 0.12)
			ulG.Offset = Vector2.new(((now * 0.5) % 2) - 1, 0)
			for _, e in ipairs(embers) do
				e.y -= e.sp * dt
				if e.y < -0.05 then
					e.y = 1.05
					e.x = math.random()
				end
				e.f.Position = UDim2.new(e.x, math.sin(now * e.fr + e.ph) * 8, e.y, 0)
			end
		end
		local g = win._glide
		if g then
			local P = main.Position
			main.Position = UDim2.new(P.X.Scale, P.X.Offset + g.x * dt, P.Y.Scale, P.Y.Offset + g.y * dt)
			local f = 0.88 ^ (dt * 60)
			g.x *= f
			g.y *= f
			if math.abs(g.x) + math.abs(g.y) < 20 then
				win._glide = nil
			end
		end
		local fns = win._frame
		if fns and #fns > 0 then
			for _, fn in ipairs(table.clone(fns)) do -- a copy, so a function can remove itself safely
				local ok, err = pcall(fn, now, dt)
				if not ok then
					local at = table.find(fns, fn)
					if at then
						table.remove(fns, at) -- a broken per-frame function is dropped instead of erroring every frame
					end
					warn("[RebelUI] a per-frame function failed and was removed: " .. tostring(err))
				end
			end
		end
	end)

	-- ---------- drag the corner to resize the panel
	if o.Resizable ~= false then
		local grip = new("TextButton", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -2, 1, -2),
			Size = UDim2.fromOffset(22, 22),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 12,
		}, main)
		local lines = {}
		for k = 1, 2 do
			local ln = new("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(15 - (k - 1) * 4, 15 - (k - 1) * 4),
				Size = UDim2.fromOffset(k == 1 and 10 or 6, 2),
				Rotation = -45,
				BorderSizePixel = 0,
				BackgroundTransparency = 0.25,
				ZIndex = 13,
			}, grip)
			corner(ln, 1)
			lines[k] = ln
		end
		win:_onTheme(function(t)
			for _, ln in ipairs(lines) do
				ln.BackgroundColor3 = t.Glow
			end
		end)
		local rs, sm, ss = false, nil, nil
		grip.InputBegan:Connect(function(i)
			if isPress(i) then
				rs, sm, ss = true, i.Position, main.AbsoluteSize / math.max(panelScale.Scale, 0.01)
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if rs and isMove(i) then
				local d = (i.Position - sm) / math.max(panelScale.Scale, 0.01)
				win:SetSize(ss.X + d.X, ss.Y + d.Y)
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if rs and isPress(i) then
				rs = false
			end
		end)
	end

	-- ---------- buttons and keys
	local armed = false
	closeBtn.MouseButton1Click:Connect(function()
		if win.ConfirmClose and not armed then
			armed = true
			win:Notify({ Title = "Close the panel?", Text = "Tap X again to confirm", Duration = 2.5 })
			task.delay(2.5, function()
				armed = false
			end)
			return
		end
		win:Close()
	end)
	expBtn.MouseButton1Click:Connect(function()
		win:Maximize()
	end)
	miniBtn.MouseButton1Click:Connect(function()
		win:Toggle(false)
	end)
	win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, processed)
		if not processed and i.KeyCode == win.ToggleKey then
			win:Toggle()
		end
	end)

	win._orderTabs = 0
	win:_initFx()
	win:SetOpacity(o.Opacity or 100)
	if o.AutoSave then
		win:AutoSave(o.AutoSave)
	end
	if o.Open ~= false then
		win:Toggle(true)
	else
		fab.Visible = not win._hasBar
	end
	if o.Trigger then
		win:SetTrigger(o.Trigger)
	end
	win._born = os.clock()
	if win.Setup == "Mobile" and win.EnableSwipe then
		win:EnableSwipe()
	end
	if o.Ambient and win.SetAmbient then
		win:SetAmbient(true)
	end
	return win
end

function Window:_playClick()
	if self.Sound and self._click then
		pcall(function()
			self._click:Play()
		end)
	end
end

function Window:Toggle(state)
	if state == nil then
		state = not self.Open
	end
	self.Open = state
	local main = self.Main
	local sp = self.AnimSpeed or 1
	local style = self.OpenAnim or "Pop"
	local sc = self._scaleObj
	if not self._restPos then
		self._restPos = main.Position
	end
	if state then
		self._token = (self._token or 0) + 1
		main.Visible = true
		if self.ReduceMotion then
			sc.Scale = self.Scale
			main.Rotation = 0
		elseif style == "Slide" then
			sc.Scale = self.Scale
			local base = main.Position
			main.Position = base + UDim2.fromOffset(0, 90)
			tween(main, 0.4 / sp, { Position = base }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		elseif style == "Fade" then
			sc.Scale = self.Scale * 0.94
			tween(sc, 0.3 / sp, { Scale = self.Scale }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		elseif style == "Bounce" then
			sc.Scale = self.Scale * 0.3
			tween(sc, 0.7 / sp, { Scale = self.Scale }, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
		elseif style == "Drop" then
			sc.Scale = self.Scale
			local base = main.Position
			main.Position = base + UDim2.fromOffset(0, -140)
			tween(main, 0.6 / sp, { Position = base }, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
		elseif style == "Spin" then
			sc.Scale = self.Scale * 0.5
			main.Rotation = -14
			tween(sc, 0.45 / sp, { Scale = self.Scale }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			tween(main, 0.45 / sp, { Rotation = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else -- Pop
			tween(sc, 0.35 / sp, { Scale = self.Scale }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	else
		local my = (self._token or 0) + 1
		self._token = my
		local t = tween(sc, (self.ReduceMotion and 0.01 or 0.2 / sp), { Scale = self.Scale * 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		t.Completed:Connect(function()
			if not self.Open and self._token == my then
				main.Visible = false
				main.Rotation = 0
			end
		end)
	end
	if self._scan then
		self._scan.Visible = state and self.Fx and self.Fx.Scan or false
	end
	self._fab.Visible = not state and not self._hasBar
end

function Window:SetTheme(name)
	local t = THEMES[name]
	if not t then
		return
	end
	self.Theme = t
	self.ThemeName = name
	for _, fn in ipairs(self._fns) do
		fn(t)
	end
end

-- rainbow rings around everything (cheap: no per-frame recoloring of the whole panel)
function Window:SetRainbow(on)
	self._rainbow = on == true
	for _, g in ipairs(self._spin) do
		g.Color = self._rainbow and RAINBOW or ringSeq(self.Theme)
	end
end

function Window:SetAccent(color)
	-- any Color3 becomes the accent; the rest of the theme is made from it
	local t = makeTheme(color)
	self.Theme = t
	self.ThemeName = "Custom"
	for _, fn in ipairs(self._fns) do
		fn(t)
	end
end

function RebelUI:AddTheme(name, accent, dark)
	THEMES[name] = makeTheme(accent, dark and { Dark = dark } or nil)
	if not table.find(self.Themes, name) then
		table.insert(self.Themes, name)
	end
end

function Window:SetScale(s)
	-- 0.8 to 1.3: makes the whole panel smaller or bigger
	self.Scale = math.clamp(tonumber(s) or 1, 0.5, 1.6)
	if self.Open then
		tween(self._scaleObj, 0.2, { Scale = self.Scale })
	end
end

function Window:SetTransparency(t)
	-- 0 to 0.9: see-through panel (SetOpacity is the same thing as a percent)
	t = math.clamp(tonumber(t) or 0, 0, 0.9)
	self.Main.BackgroundTransparency = t
	self._side.BackgroundTransparency = t
end

function Window:SetOpacity(pct)
	-- 10 to 100. 100 = solid panel (the default)
	pct = math.clamp(tonumber(pct) or 100, 10, 100)
	self.Opacity = pct
	self:SetTransparency(1 - pct / 100)
end

function Window:SetSize(w, h)
	-- the size of the panel in pixels (before UI size scaling). It stays inside the screen.
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 500)
	if vp.X < 200 or vp.Y < 150 then
		vp = Vector2.new(800, 450)
	end
	local s = math.max(self.Scale, 0.01)
	w = math.clamp(tonumber(w) or self._baseSize[1], 320, math.max(320, vp.X * 0.96 / s))
	h = math.clamp(tonumber(h) or self._baseSize[2], 240, math.max(240, vp.Y * 0.96 / s))
	self.Main.Size = UDim2.fromOffset(math.floor(w), math.floor(h))
end

-- Win:Maximize(true | false | nil): fill the screen (the expand icon in the top corner) or go back. The icon turns into "minimize" while it is big.
function Window:Maximize(on)
	if on == nil then
		on = not self._max
	end
	if (on == true) == (self._max == true) then
		return
	end
	self._max = on == true
	local main = self.Main
	if self._max then
		self._preSize, self._prePos = main.Size, main.Position
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 450)
		if vp.X < 200 or vp.Y < 150 then
			vp = Vector2.new(800, 450)
		end
		local s = math.max(self.Scale or 1, 0.01)
		local w, h = math.max(320, vp.X * 0.96 / s), math.max(240, vp.Y * 0.92 / s)
		tween(main, self.ReduceMotion and 0 or 0.4, { Size = UDim2.fromOffset(math.floor(w), math.floor(h)), Position = UDim2.new(0.5, 0, 0.5, 0) }, Enum.EasingStyle.Quint)
	else
		tween(main, self.ReduceMotion and 0 or 0.4, { Size = self._preSize or main.Size, Position = self._prePos or main.Position }, Enum.EasingStyle.Quint)
	end
	if self._expandBtn then
		RebelUI._setIcon(self._expandBtn, self._max and RebelUI.Icons.minimize or RebelUI.Icons.expand)
	end
	if self.LogAction then
		self:LogAction(self._max and "Expanded the panel" or "Restored the panel size", nil, "read")
	end
end

function Window:SetToggleKey(k)
	if typeof(k) == "EnumItem" then
		self.ToggleKey = k
	end
end

function Window:_scramble(lbl, text)
	-- the title "decodes" into the new name (Scramble = false turns it off)
	self._scrTok = (self._scrTok or 0) + 1
	local mine = self._scrTok
	text = tostring(text)
	if not self.Scramble or #text == 0 then
		lbl.Text = text
		return
	end
	local chars = "01#@$%&*+=?"
	task.spawn(function()
		local steps = 7
		for s = 1, steps do
			if self._scrTok ~= mine or self._dead then
				return
			end
			local out = {}
			for k = 1, #text do
				local ch = text:sub(k, k)
				if ch == " " or k <= (#text * (s - 1) / steps) then
					out[k] = ch
				else
					local r = math.random(1, #chars)
					out[k] = chars:sub(r, r)
				end
			end
			lbl.Text = table.concat(out)
			task.wait(0.035)
		end
		if self._scrTok == mine then
			lbl.Text = text
		end
	end)
end

-- Win:Close(): what the X button does. Plays the close animation (Win.CloseAnimation: Normal, BlackHole, Shatter, TVOff, Spin, Implode, Custom, None), then Destroy().
function Window:Close()
	if self._closing or self._dead then
		return
	end
	local style = self.CloseAnimation or "BlackHole"
	if style == "None" or self.ReduceMotion or not self.Main or not self.Gui or not RebelUI.CloseEffect then
		self:Destroy()
		return
	end
	self._closing = true
	task.spawn(function()
		pcall(RebelUI.CloseEffect, self.Gui, self.Main, style, { Color = self.Theme and self.Theme.Glow, Move = true, Media = self.CloseMedia })
		self:Destroy()
	end)
end

function Window:Destroy()
	self._dead = true
	if self.HUD then
		pcall(function()
			self.HUD:Destroy()
		end)
	end
	for _, c in ipairs(self._conns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	self._conns = {}
	if self.OnDestroy then
		safe(self.OnDestroy)
	end
	if self.Gui then
		self.Gui:Destroy()
	end
end

function Window:Notify(o)
	if type(o) == "string" then
		o = { Text = o }
	end
	o = o or {}
	if self.Toasts == false then
		local nop = function() end
		return { SetTitle = nop, SetText = nop, Progress = nop, Close = nop }
	end
	self._noteN = (self._noteN or 0) + 1
	-- remember it: Window:GetNotifications(), or a Notifications tab with an unread badge (Window:CreateNotificationsTab)
	self._noteLog = self._noteLog or {}
	table.insert(self._noteLog, { Time = os.date("%H:%M:%S"), Title = o.Title, Text = tostring(o.Text or ""), Type = o.Type })
	if #self._noteLog > 60 then
		table.remove(self._noteLog, 1)
	end
	if self._onNote then
		pcall(self._onNote, self._noteLog[#self._noteLog])
	end
	local dur = o.Duration or self.NotifyTime or 4
	local kinds = { success = C.Green, warn = C.Yellow, error = C.Bad }
	self:_playClick()
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = self._noteN,
	}, self._notes)
	local card = new("Frame", {
		Position = UDim2.new(0, -290, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.new(1, 1, 1),
		ZIndex = 30,
	}, wrap)
	corner(card, 10)
	local cg = new("UIGradient", {}, card)
	local st = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1, Transparency = 0.2 }, card)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, card)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	local hparent = card
	if o.Icon then
		hparent = new("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, ZIndex = 31, LayoutOrder = 1 }, card)
		new("ImageLabel", {
			Size = UDim2.fromOffset(13, 13),
			Position = UDim2.fromOffset(0, 2),
			BackgroundTransparency = 1,
			Image = asset(o.Icon),
			ZIndex = 32,
		}, hparent)
	end
	local h = label(hparent, o.Title or "Rebelwar", 11, C.Text, true)
	h.Size = UDim2.new(1, 0, 0, 14)
	h.ZIndex = 31
	h.LayoutOrder = 1
	if o.Icon then
		h.Size = UDim2.new(1, -22, 0, 18)
		h.Position = UDim2.fromOffset(22, 0)
	end
	local b = label(card, o.Text or "", 9, C.Dim, false)
	b.TextWrapped = true
	b.TextTruncate = Enum.TextTruncate.None
	b.Size = UDim2.new(1, 0, 0, 0)
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.ZIndex = 31
	b.LayoutOrder = 2
	b.Visible = o.Text ~= nil
	local dismiss
	local btns = {}
	if type(o.Actions) == "table" and #o.Actions > 0 then
		local arow = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, ZIndex = 31, LayoutOrder = 3 }, card)
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 5),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, arow)
		for n, a in ipairs(o.Actions) do
			if n > 3 then
				break
			end
			local b = new("TextButton", {
				Size = UDim2.new(1 / math.min(#o.Actions, 3), -4, 0, 20),
				BorderSizePixel = 0,
				Text = tostring(a.Name or "OK"),
				TextColor3 = C.Text,
				TextSize = 10,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				ZIndex = 32,
				LayoutOrder = n,
			}, arow)
			corner(b, 6)
			btns[#btns + 1] = b
			b.MouseButton1Click:Connect(function()
				safe(a.Callback)
				if dismiss then
					dismiss()
				end
			end)
		end
	end
	local line = new("Frame", { Size = UDim2.new(1, 0, 0, 2), BorderSizePixel = 0, ZIndex = 31, LayoutOrder = 4 }, card)
	corner(line, 1)
	local function paint(t)
		cg.Color = ColorSequence.new(t.BG0, t.B1)
		local c = kinds[o.Type or ""] or t.Accent
		st.Color = kinds[o.Type or ""] or t.Glow
		line.BackgroundColor3 = c
		for _, b in ipairs(btns) do
			b.BackgroundColor3 = c:Lerp(Color3.new(0, 0, 0), 0.45)
		end
	end
	paint(self.Theme)
	tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local persistent = dur <= 0 or dur == math.huge -- Duration = 0 stays until Close()
	if persistent then
		line.Size = UDim2.new(0, 0, 0, 2)
	else
		tween(line, dur, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
	end
	local closing = false
	dismiss = function()
		if closing or not card.Parent then
			return
		end
		closing = true
		local o2 = tween(card, 0.25, { Position = UDim2.new(0, -290, 0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		o2.Completed:Connect(function()
			wrap:Destroy()
		end)
	end
	if not persistent then
		task.delay(dur, dismiss)
	end
	-- the card can be changed while it is on screen: n:SetTitle, n:SetText, n:Progress(0 to 1), n:Close()
	return {
		SetTitle = function(_, t)
			h.Text = tostring(t)
		end,
		SetText = function(_, t)
			b.Text = tostring(t)
			b.Visible = true
		end,
		Progress = function(_, v)
			line.Size = UDim2.new(math.clamp(tonumber(v) or 0, 0, 1), 0, 0, 2)
		end,
		Close = function()
			dismiss()
		end,
	}
end

-- ============================================================ dialog (a pop-up question with buttons)
function Window:Dialog(o)
	-- Title, Text, Buttons = { { Name = "Yes", Callback = fn }, { Name = "No" } }  (up to 3, tapping one closes it)
	o = o or {}
	if self._dialog and self._dialog.Parent then
		self._dialog:Destroy()
	end
	local t = self.Theme
	local back = new("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		ZIndex = 60,
	}, self.Gui)
	self._dialog = back
	tween(back, 0.2, { BackgroundTransparency = 0.45 })
	local card = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(280, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Active = true,
		ZIndex = 61,
	}, back)
	corner(card, 12)
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(t.BG0, t.BG1) }, card)
	new("UIStroke", { Color = t.Glow, Thickness = 1.5 }, card)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
	}, card)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	local sc = new("UIScale", { Scale = 0.75 }, card)
	tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local h = label(card, o.Title or "Are you sure?", 14, t.Glow, true)
	h.Font = Enum.Font.GothamBlack
	h.Size = UDim2.new(1, 0, 0, 20)
	h.ZIndex = 62
	h.LayoutOrder = 1
	if o.Text then
		local b = label(card, o.Text, 10, C.Dim, false)
		b.TextWrapped = true
		b.TextTruncate = Enum.TextTruncate.None
		b.Size = UDim2.new(1, 0, 0, 0)
		b.AutomaticSize = Enum.AutomaticSize.Y
		b.ZIndex = 62
		b.LayoutOrder = 2
	end
	local row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, ZIndex = 62, LayoutOrder = 3 }, card)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
	}, row)
	local list = o.Buttons
	if type(list) ~= "table" or #list == 0 then
		list = { { Name = "OK" } }
	end
	local n = math.min(#list, 3)
	local function close()
		if back.Parent then
			tween(back, 0.15, { BackgroundTransparency = 1 })
			tween(sc, 0.15, { Scale = 0.8 })
			task.delay(0.16, function()
				back:Destroy()
			end)
		end
	end
	for i = 1, n do
		local a = list[i]
		local first = i == 1
		local btn = new("TextButton", {
			Size = UDim2.new(1 / n, -6 * (n - 1) / n, 0, 30),
			BackgroundColor3 = first and t.Accent or t.Item,
			BorderSizePixel = 0,
			Text = tostring(a.Name or "OK"),
			TextColor3 = C.Text,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
			ZIndex = 63,
			LayoutOrder = i,
		}, row)
		corner(btn, 8)
		if first then
			new("UIStroke", { Color = t.Glow, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, btn)
		end
		btn.MouseButton1Click:Connect(function()
			self:_playClick()
			close()
			safe(a.Callback)
		end)
	end
	return { Close = close }
end

function Window:_bind(obj, prop, key)
	self:_onTheme(function(t)
		obj[prop] = t[key]
	end)
end

-- ============================================================ tooltips
-- Hover (PC) or press and hold (phone) on an element that has Tooltip = "text".
function Window:_tip(row, text)
	local win = self
	local token = 0
	local function hide()
		token += 1
		if win._tipFrame then
			win._tipFrame.Visible = false
		end
	end
	local function show()
		if not win.Gui then
			return
		end
		if not win._tipFrame then
			local f = new("Frame", {
				Size = UDim2.fromOffset(190, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 70,
			}, win.Gui)
			corner(f, 8)
			local st = new("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
			new("UIPadding", {
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}, f)
			local l = label(f, "", 9, C.Text, false)
			l.TextWrapped = true
			l.TextTruncate = Enum.TextTruncate.None
			l.Size = UDim2.new(1, 0, 0, 0)
			l.AutomaticSize = Enum.AutomaticSize.Y
			l.ZIndex = 71
			win:_onTheme(function(t)
				f.BackgroundColor3 = t.S0
				st.Color = t.Glow
			end)
			win._tipFrame, win._tipLabel = f, l
		end
		win._tipLabel.Text = tostring(text)
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 450)
		local pos, size = row.AbsolutePosition, row.AbsoluteSize
		local x = math.clamp(pos.X, 6, math.max(6, vp.X - 200))
		local y = pos.Y - 40
		if y < 6 then
			y = pos.Y + size.Y + 6
		end
		win._tipFrame.Position = UDim2.fromOffset(x, y)
		win._tipFrame.Visible = true
	end
	row.MouseEnter:Connect(function()
		token += 1
		local mine = token
		task.delay(0.4, function()
			if token == mine then
				show()
			end
		end)
	end)
	row.MouseLeave:Connect(hide)
	row.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			token += 1
			local mine = token
			task.delay(0.6, function()
				if token == mine then
					show()
				end
			end)
		end
	end)
	row.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then
			local mine = token
			task.delay(1.6, function()
				if token == mine then
					hide()
				end
			end)
			token += 1
		end
	end)
end

-- ============================================================ keybind list (the keys that are set, on screen)
function Window:CreateKeybindList(o)
	-- Position (UDim2), Title, Visible. Lists every Keybind and every Toggle that has a Key.
	o = o or {}
	local win = self
	local f = new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = o.Position or UDim2.new(1, -12, 0, 56),
		Size = UDim2.fromOffset(150, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Active = true,
		ZIndex = 40,
		Visible = o.Visible ~= false,
	}, win.Gui)
	corner(f, 8)
	local fg = new("UIGradient", { Rotation = 90 }, f)
	local st = new("UIStroke", { Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 7),
		PaddingLeft = UDim.new(0, 9),
		PaddingRight = UDim.new(0, 9),
	}, f)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, f)
	local title = label(f, o.Title or "Keybinds", 10, C.Text, true)
	title.Size = UDim2.new(1, 0, 0, 16)
	title.ZIndex = 41
	title.LayoutOrder = 0
	win:_onTheme(function(t)
		fg.Color = ColorSequence.new(t.BG0, t.B1)
		st.Color = t.Glow
		title.TextColor3 = t.Glow
	end)
	-- drag it by the title
	local dragging, sm, sp
	local grab = new("TextButton", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "", ZIndex = 42, LayoutOrder = 0 }, title)
	grab.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging, sm, sp = true, i.Position, f.Position
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local d = i.Position - sm
			f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if isPress(i) then
			dragging = false
		end
	end)
	local rows, acc = {}, 1
	local obj = {}
	local function refresh()
		for n, kb in ipairs(win._keybinds) do
			local l = rows[kb]
			if not l then
				l = label(f, "", 9, C.Dim, false)
				l.Size = UDim2.new(1, 0, 0, 14)
				l.ZIndex = 41
				rows[kb] = l
			end
			l.LayoutOrder = n
			local on = kb.active and kb.active() or false
			local okk, k = pcall(kb.key)
			l.Text = tostring(kb.name) .. "   [" .. ((okk and k and k.Name) or "?") .. "]" .. (on and "  ON" or "")
			l.TextColor3 = on and win.Theme.Glow or C.Dim
		end
	end
	table.insert(win._frame, function(_, dt)
		acc += dt or 0
		if acc >= 0.25 and f.Visible then
			acc = 0
			refresh()
		end
	end)
	refresh()
	function obj:Show(v)
		f.Visible = v ~= false
	end
	function obj:Destroy()
		f:Destroy()
	end
	win._kbList = obj
	return obj
end

-- ============================================================ search
-- Types in the search box: rows on the current tab whose text matches stay, the rest hide.
function Window:_filter(q)
	q = tostring(q or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	local tab = self.CurrentTab
	if not tab then
		return
	end
	local hidden = tab._hidden or {}
	tab._hidden = hidden
	for _, obj in ipairs(hidden) do
		if obj.Parent then
			obj.Visible = true
		end
	end
	table.clear(hidden)
	for _, s in ipairs(tab._secs or {}) do
		if s.apply and s.collapsed then
			s.apply()
		end
	end
	if q == "" then
		return
	end
	local found = 0
	for _, row in ipairs(tab.Page:GetChildren()) do
		if row:IsA("GuiObject") then
			local match = false
			if row:IsA("Frame") or row:IsA("TextButton") then
				for _, d in ipairs(row:GetDescendants()) do
					if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text ~= "" and RebelUI._plain(d.Text):lower():find(q, 1, true) then
						match = true
						break
					end
				end
			end
			if match then
				found += 1
			else
				row.Visible = false
				table.insert(hidden, row)
			end
		end
	end
	return found
end

-- ============================================================ tabs
function Window:CreateTabDivider(text)
	-- a small caption between tabs in the side list, like "GAMES" or "SETTINGS"
	local l = label(self._tabList, string.upper(tostring(text or "")), 8, C.Dim, true)
	l.Size = UDim2.new(1, 0, 0, 16)
	l.TextXAlignment = Enum.TextXAlignment.Left
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4) }, l)
	l.LayoutOrder = #self._tabs * 10 + 5
	self:_bind(l, "TextColor3", "Glow")
	return l
end

-- Win:CreateTabGroup({ Name = "Main", Open = false, Icon = optional })
-- A folder in the tab list. Its arrow (UI.Icons.right) turns down when you tap it and the tabs inside slide down with a fade.
-- g:CreateTab({ Name, Icon, ... }) puts a tab inside. g:Open() g:Close() g:Toggle() g.IsOpen. If you upload a Down image, set UI.Icons.down = id
-- and it is used for the open arrow instead of turning the right arrow.
function Window:CreateTabGroup(o)
	o = type(o) == "string" and { Name = o } or (o or {})
	local win = self
	local g = { Win = win, Name = o.Name or "Group", IsOpen = false, _n = 0 }
	local order = (#win._tabs + 1) * 10
	local head = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = C.White, BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = order,
	}, win._tabList)
	corner(head, 8)
	local hg = new("UIGradient", {}, head)
	local arrow = new("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(13, 13), BackgroundTransparency = 1,
		Image = asset(RebelUI.Icons.right), ScaleType = Enum.ScaleType.Fit, ZIndex = 4,
	}, head)
	RebelUI._iconFix(arrow, RebelUI.Icons.right)
	local arrowDown
	if RebelUI.Icons.down then
		arrowDown = new("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.fromOffset(13, 13), BackgroundTransparency = 1,
			Image = asset(RebelUI.Icons.down), ScaleType = Enum.ScaleType.Fit, ImageTransparency = 1, ZIndex = 4,
		}, head)
		RebelUI._iconFix(arrowDown, RebelUI.Icons.down)
		arrowDown.BackgroundTransparency = 1
	end
	local tx = 26
	if o.Icon then
		local ic = new("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 26, 0.5, 0), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 1, Image = asset(o.Icon), ScaleType = Enum.ScaleType.Fit, ZIndex = 4 }, head)
		RebelUI._iconFix(ic, o.Icon)
		tx = 42
	end
	local name = label(head, g.Name, 12, C.Text, true)
	name.Position = UDim2.new(0, tx, 0, 0)
	name.Size = UDim2.new(1, -tx - 34, 1, 0)
	name.ZIndex = 4
	local chip = new("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(22, 16), BackgroundTransparency = 0.2, Text = "0", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = C.White, ZIndex = 4 }, head)
	corner(chip, 8)
	local box = new("Frame", { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true, LayoutOrder = order + 1, Visible = false }, win._tabList)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, box)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, box)
	g._box, g._head = box, head
	local function paint()
		local t = win.Theme
		hg.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.4))
		chip.BackgroundColor3 = t.Accent
	end
	paint()
	if win._onTheme then
		win:_onTheme(paint)
	end
	function g:_resize()
		chip.Text = tostring(g._n)
		if g.IsOpen then
			box.Size = UDim2.new(1, 0, 0, g._n * 28)
		end
	end
	local function fadeKids(toOut, step)
		local i = 0
		for _, b in ipairs(box:GetChildren()) do
			if b:IsA("TextButton") then
				i += 1
				local sc = b:FindFirstChild("RebelGrp") or new("UIScale", { Name = "RebelGrp", Scale = 1 }, b)
				if toOut then
					tween(sc, 0.12, { Scale = 0.85 })
				else
					sc.Scale = 0.8
				end
				for _, d in ipairs(b:GetChildren()) do
					local prop = d:IsA("TextLabel") and "TextTransparency" or d:IsA("ImageLabel") and "ImageTransparency" or nil
					if prop then
						if not toOut then
							d[prop] = 1
						end
						task.delay(toOut and 0 or (i - 1) * step, function()
							tween(d, toOut and 0.12 or 0.28, { [prop] = toOut and 1 or 0 })
						end)
					end
				end
				if not toOut then
					task.delay((i - 1) * step, function()
						tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
					end)
				end
			end
		end
	end
	function g:Open()
		if g.IsOpen then
			return
		end
		g.IsOpen = true
		local fast = win.ReduceMotion
		box.Visible = true
		if arrowDown then
			tween(arrow, 0.2, { ImageTransparency = 1 })
			tween(arrowDown, 0.2, { ImageTransparency = 0 })
		else
			tween(arrow, fast and 0 or 0.35, { Rotation = 90 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
		tween(box, fast and 0 or 0.4, { Size = UDim2.new(1, 0, 0, g._n * 28) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		if not fast then
			fadeKids(false, 0.06)
		end
	end
	function g:Close()
		if not g.IsOpen then
			return
		end
		g.IsOpen = false
		if arrowDown then
			tween(arrow, 0.2, { ImageTransparency = 0 })
			tween(arrowDown, 0.2, { ImageTransparency = 1 })
		else
			tween(arrow, win.ReduceMotion and 0 or 0.3, { Rotation = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
		if not win.ReduceMotion then
			fadeKids(true)
		end
		tween(box, win.ReduceMotion and 0 or 0.28, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.delay(win.ReduceMotion and 0 or 0.3, function()
			if not g.IsOpen then
				box.Visible = false
			end
		end)
	end
	function g:Toggle()
		if g.IsOpen then
			g:Close()
		else
			g:Open()
		end
	end
	function g:CreateTab(t, icon)
		local opts = type(t) == "table" and t or { Name = t, Icon = icon }
		local copy = {}
		for k, v in pairs(opts) do
			copy[k] = v
		end
		copy.Group = g
		return win:CreateTab(copy)
	end
	head.MouseEnter:Connect(function()
		tween(head, 0.15, { BackgroundTransparency = 0.7 })
	end)
	head.MouseLeave:Connect(function()
		tween(head, 0.2, { BackgroundTransparency = 1 })
	end)
	head.Activated:Connect(function()
		g:Toggle()
	end)
	if o.Open then
		g:Open()
	end
	return g
end

function Window:CreateTab(name, icon)
	-- CreateTab("Main", 123456)  or  CreateTab({ Name=, Icon=, Title=, Description= })
	local opts = type(name) == "table" and name or { Name = name, Icon = icon }
	local win = self
	local tab = setmetatable({ Win = win, Name = opts.Name or "Tab", Icon = opts.Icon, _n = 0 }, Tab)
	local active = false

	-- ---------- the tab button: icon far left, name next to it, marker when selected
	local btn = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = C.White,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = opts.Group and (opts.Group._n + 1) or (#win._tabs + 1) * 10,
	}, opts.Group and opts.Group._box or win._tabList)
	corner(btn, 8)
	if opts.Group then
		opts.Group._n += 1
		opts.Group:_resize()
	end
	local bg = new("UIGradient", {}, btn)
	local ind = new("Frame", {
		Size = UDim2.fromOffset(3, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 1, 0.5, 0),
		BackgroundColor3 = C.White,
		BorderSizePixel = 0,
		ZIndex = 5,
	}, btn)
	corner(ind, 2)
	local pad = 10
	local img
	if opts.Icon then
		img = new("ImageLabel", {
			Size = UDim2.fromOffset(12, 12),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			BackgroundTransparency = 1,
			Image = asset(opts.Icon),
			ImageColor3 = C.Dim,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 4,
		}, btn)
		RebelUI._iconFix(img, opts.Icon)
		pad = 24
	end
	local txt = label(btn, tab.Name, 11, C.Dim, false)
	txt.Font = Enum.Font.GothamMedium
	txt.Position = UDim2.new(0, pad, 0, 0)
	txt.Size = UDim2.new(1, -pad - 4, 1, 0)
	txt.ZIndex = 4

	btn.MouseEnter:Connect(function()
		if not win.ReduceMotion then
			tween(txt, 0.18, { Position = UDim2.new(0, pad + 4, 0, 0) }, Enum.EasingStyle.Quad)
		end
	end)
	btn.MouseLeave:Connect(function()
		tween(txt, 0.2, { Position = UDim2.new(0, pad, 0, 0) }, Enum.EasingStyle.Quad)
	end)

	-- ---------- the page
	local page = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -32),
		Position = UDim2.fromOffset(0, 32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
	}, win._content)
	new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, page)
	new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8), PaddingRight = UDim.new(0, 6) }, page)
	tab.Page = page
	tab.TabButton = btn

	local function paint()
		local t = win.Theme
		bg.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.4))
		page.ScrollBarImageColor3 = t.Accent
		tween(btn, 0.15, { BackgroundTransparency = active and 0.1 or 1 })
		tween(ind, 0.2, { Size = UDim2.fromOffset(3, active and 14 or 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		txt.TextColor3 = active and C.Text or C.Dim
		if img then
			img.ImageColor3 = active and C.Text or C.Dim
		end
	end
	tab._set = function(a)
		active = a
		paint()
	end
	function tab:Select()
		for _, other in ipairs(win._tabs) do
			if other ~= tab then
				other.Page.Visible = false
				other._set(false)
			end
		end
		if win._search and win._search.Text ~= "" then
			win._search.Text = ""
		end
		if opts.Group and not opts.Group.IsOpen and not tab._auto then
			opts.Group:Open() -- selecting a tab inside a closed group opens the group
		end
		page.Visible = true
		RebelUI._pageIn(win, page)
		if win._stagger then
			win:_stagger(page)
		end
		tab._set(true)
		win:_scramble(win._pageTitle, tab.Name)
		win.CurrentTab = tab
		if not tab._auto and win.LogAction then
			win:LogAction("Opened tab " .. tostring(tab.Name), nil, "read")
		end
		if opts.Build and not tab._built then
			-- Build = function(tab) ... end : the tab fills itself the first time it is opened
			tab._built = true
			-- if building the tab fails, SAY SO (toast + console) and keep what was built, with a Retry button
			win._building = true
			local okB, errB = xpcall(opts.Build, function(e)
				return tostring(e)
			end, tab)
			win._building = false
			if not okB then
				warn("[RebelUI] the tab '" .. tostring(tab.Name) .. "' failed to build: " .. tostring(errB))
				pcall(function()
					win:Notify({ Type = "error", Title = "Tab '" .. tostring(tab.Name) .. "' failed", Text = tostring(errB):sub(1, 160), Duration = 10 })
					tab:Button({ Name = "This tab hit an error. Tap to retry", Callback = function()
						for _, c in ipairs(tab.Page:GetChildren()) do
							if c:IsA("GuiObject") then
								c:Destroy()
							end
						end
						tab._n = 0
						local ok2, e2 = xpcall(opts.Build, function(e)
							return tostring(e)
						end, tab)
						if not ok2 then
							win:Notify({ Type = "error", Title = "Still failing", Text = tostring(e2):sub(1, 160), Duration = 10 })
						end
					end })
				end)
			end
		end
	end
	function tab:SetName(n)
		tab.Name = n
		txt.Text = n
		if win.CurrentTab == tab then
			win._pageTitle.Text = n
		end
	end
	function tab:SetIcon(i)
		if img then
			img.Image = asset(i)
		end
	end
	win:_onTheme(paint)
	btn.MouseButton1Click:Connect(function()
		win:_playClick()
		tab:Select()
	end)
	btn.MouseEnter:Connect(function()
		if not active then
			tween(btn, 0.12, { BackgroundTransparency = 0.8 })
		end
	end)
	btn.MouseLeave:Connect(function()
		if not active then
			tween(btn, 0.12, { BackgroundTransparency = 1 })
		end
	end)

	table.insert(win._tabs, tab)
	-- the tab's own header ("text hub") at the top of its page
	if opts.Title or opts.Description then
		tab.HeaderObj = tab:Header({
			Title = opts.Title or tab.Name,
			Text = opts.Description,
			Icon = opts.HeaderIcon or opts.Icon,
		})
	end
	if #win._tabs == 1 then
		tab._auto = true -- the first page shows itself, but a closed folder stays closed
		tab:Select()
		tab._auto = nil
	end
	return tab
end

-- ============================================================ elements
function Tab:_next()
	self._n += 1
	return self._n
end

function Tab:_row(h)
	local f = new("Frame", {
		Size = UDim2.new(1, 0, 0, h or 36),
		BorderSizePixel = 0,
		LayoutOrder = self:_next(),
	}, self.Page)
	corner(f, 8)
	self.Win:_bind(f, "BackgroundColor3", "Item")
	-- hover lift and press squish on every row (Win:SetFx({ Hover = false }) turns it off)
	local win = self.Win
	local sc
	local function scale()
		if not sc then
			sc = f:FindFirstChild("RebelStag") or new("UIScale", { Name = "RebelStag", Scale = 1 }, f)
		end
		return sc
	end
	f.MouseEnter:Connect(function()
		if win.Fx and win.Fx.Hover and not win.ReduceMotion then
			tween(scale(), 0.14, { Scale = 1.012 }, Enum.EasingStyle.Quad)
		end
	end)
	f.MouseLeave:Connect(function()
		if sc and win.Fx and win.Fx.Hover then
			tween(sc, 0.18, { Scale = 1 }, Enum.EasingStyle.Quad)
		end
	end)
	f.InputBegan:Connect(function(i)
		if win.Fx and win.Fx.Hover and not win.ReduceMotion and isPress(i) then
			tween(scale(), 0.08, { Scale = 0.975 }, Enum.EasingStyle.Quad)
		end
	end)
	f.InputEnded:Connect(function(i)
		if sc and win.Fx and win.Fx.Hover and isPress(i) then
			tween(sc, 0.22, { Scale = 1 }, Enum.EasingStyle.Back)
		end
	end)
	return f
end

local function register(self, o, obj, kind)
	if o.Flag then
		self.Win.Flags[o.Flag] = obj
	end
	obj.Flag = o.Flag
	local row
	for _, c in ipairs(self.Page:GetChildren()) do
		if c:IsA("GuiObject") and c.LayoutOrder == self._n then
			row = c
			break
		end
	end
	obj.Row = row
	-- move an element after it was made: obj:MoveUp() / obj:MoveDown() / obj:MoveTo(position)
	local page = self.Page
	local function siblings()
		local list = {}
		for _, c in ipairs(page:GetChildren()) do
			if c:IsA("GuiObject") then
				list[#list + 1] = c
			end
		end
		table.sort(list, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)
		return list
	end
	function obj:MoveTo(pos)
		if not row or not row.Parent then
			return false
		end
		local list = siblings()
		local orders = {}
		for i, c in ipairs(list) do
			orders[i] = c.LayoutOrder
		end
		local at = table.find(list, row)
		if not at then
			return false
		end
		table.remove(list, at)
		pos = math.clamp(math.floor(tonumber(pos) or at), 1, #list + 1)
		table.insert(list, pos, row)
		for i, c in ipairs(list) do
			c.LayoutOrder = orders[i]
		end
		return true
	end
	function obj:MoveUp()
		local list = siblings()
		return obj:MoveTo((table.find(list, row) or 1) - 1)
	end
	function obj:MoveDown()
		local list = siblings()
		return obj:MoveTo((table.find(list, row) or 1) + 1)
	end
	if kind then
		self._items = self._items or {}
		table.insert(self._items, { kind = kind, o = o, obj = obj })
		local W = self.Win
		W._all = W._all or {}
		table.insert(W._all, { kind = kind, o = o, obj = obj, tab = self })
	end
	if o.Tooltip and row then
		self.Win:_tip(row, o.Tooltip)
	end
	local winRef = self.Win
	function obj:DependsOn(other, value)
		-- shows this element only while `other:Get() == value` (default true). Example: speed:DependsOn(toggle)
		if value == nil then
			value = true
		end
		local acc, last = 0, nil
		local function check(_, dt)
			acc += dt or 0
			if last ~= nil and acc < 0.1 then
				return
			end
			acc = 0
			local ok, v = pcall(function()
				return other:Get()
			end)
			local show = ok and v == value
			if show ~= last then
				last = show
				if row and row.Parent then
					row.Visible = show
				end
			end
		end
		table.insert(winRef._frame, check)
		check(0, 1)
		return self
	end
	if not obj.SetVisible then
		function obj:SetVisible(v)
			if row then
				row.Visible = v ~= false
			end
		end
	end
	if not obj.Destroy then
		local win = self.Win
		function obj:Destroy()
			if row then
				row:Destroy()
			end
			if o.Flag and win.Flags[o.Flag] == self then
				win.Flags[o.Flag] = nil
			end
		end
	end
	return obj
end

function Tab:Section(text)
	-- Section("Name")  or  Section({ Name = "Name", Collapsible = true, Collapsed = false })
	local o = type(text) == "table" and text or { Name = text }
	local name = tostring(o.Name or "Section")
	self._secs = self._secs or {}
	if not o.Collapsible then
		local l = label(self.Page, name, 11, C.Text, true)
		l.Size = UDim2.new(1, 0, 0, 18)
		l.LayoutOrder = self:_next()
		self.Win:_bind(l, "TextColor3", "Glow")
		table.insert(self._secs, { order = l.LayoutOrder })
		local obj = {}
		function obj:Set(v)
			l.Text = tostring(v)
		end
		return register(self, { Name = name }, obj, "Section")
	end
	local tab = self
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = self:_next(),
	}, self.Page)
	local l = label(b, "", 11, C.Text, true)
	l.Size = UDim2.fromScale(1, 1)
	self.Win:_bind(l, "TextColor3", "Glow")
	local sec = { order = b.LayoutOrder, collapsed = o.Collapsed == true }
	table.insert(self._secs, sec)
	local obj = {}
	local function render()
		l.Text = (sec.collapsed and ">  " or "v  ") .. name
	end
	function sec.apply()
		local to = math.huge
		for _, s in ipairs(tab._secs) do
			if s.order > sec.order and s.order < to then
				to = s.order
			end
		end
		for _, c in ipairs(tab.Page:GetChildren()) do
			if c:IsA("GuiObject") and c.LayoutOrder > sec.order and c.LayoutOrder < to then
				c.Visible = not sec.collapsed
			end
		end
	end
	function obj:Set(v)
		name = tostring(v)
		render()
	end
	function obj:Collapse(state)
		if state == nil then
			state = not sec.collapsed
		end
		sec.collapsed = state
		render()
		sec.apply()
	end
	function obj:IsCollapsed()
		return sec.collapsed
	end
	b.MouseButton1Click:Connect(function()
		tab.Win:_playClick()
		obj:Collapse()
	end)
	render()
	task.defer(sec.apply) -- rows you add after the section are hidden too when it starts collapsed
	return register(self, { Name = name }, obj, "Section")
end

function Tab:Divider()
	local d = new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		LayoutOrder = self:_next(),
	}, self.Page)
	self.Win:_bind(d, "BackgroundColor3", "Off")
	return d
end

function Tab:Label(text)
	local l = label(self.Page, text or "", 10, C.Dim, false)
	l.TextWrapped = true
	l.TextTruncate = Enum.TextTruncate.None
	l.Size = UDim2.new(1, 0, 0, 14)
	l.AutomaticSize = Enum.AutomaticSize.Y
	l.LayoutOrder = self:_next()
	local onlyUrl = type(text) == "string" and text:match("^https?://%S+$")
	if onlyUrl then
		RebelUI._linkFx(l, { Url = onlyUrl, OnClick = function(_, ok)
			self.Win:Notify({ Type = ok and "success" or "warn", Title = ok and "Link copied" or "Can't copy", Text = onlyUrl })
		end })
	elseif type(text) == "string" and text:find("https?://") then
		l.RichText = true
		l.Text = RebelUI._richLinks(text)
	end
	local obj = {}
	function obj:Set(v)
		l.Text = tostring(v)
	end
	function obj:Get()
		return l.Text
	end
	return register(self, { Text = text }, obj, "Label")
end

function Tab:Button(o)
	-- Name, Description, Callback: a shiny gradient button with a spinning ring and a click ripple
	-- Risky = true (red), DoubleClick = true (asks "Tap again"), Disabled = true, Tooltip = "text"
	o = o or {}
	if o.Danger then
		o.Risky = true
	end
	local win = self.Win
	local hasDesc = o.Description ~= nil
	local H = o.Height or (hasDesc and 40 or 32)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, H),
		BackgroundColor3 = C.White,
		Text = "",
		AutoButtonColor = false,
		ClipsDescendants = true,
		LayoutOrder = self:_next(),
	}, self.Page)
	corner(b, 8)
	local bg = new("UIGradient", {}, b)
	local st = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1.5 }, b)
	win:_ring(st)
	win:_onTheme(function(t)
		if o.Risky then
			bg.Color = ColorSequence.new(C.Bad, C.Bad:Lerp(Color3.new(0, 0, 0), 0.5))
		else
			bg.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
		end
	end)
	local shine = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0.28, 0, 1.8, 0),
		Position = UDim2.new(-0.3, 0, 0.5, 0),
		Rotation = 20,
		BackgroundColor3 = C.White,
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, b)
	TweenService:Create(
		shine,
		TweenInfo.new(1.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, false, 0.9),
		{ Position = UDim2.new(1.3, 0, 0.5, 0) }
	):Play()
	local lbl = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, hasDesc and 22 or H),
		Position = UDim2.fromOffset(0, hasDesc and 4 or 0),
		Text = o.Name or "Button",
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = C.White,
		ZIndex = 4,
	}, b)
	local dl
	if hasDesc then
		dl = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 12),
			Position = UDim2.fromOffset(0, 22),
			Text = o.Description,
			Font = Enum.Font.Gotham,
			TextSize = 8,
			TextColor3 = Color3.fromRGB(235, 220, 222),
			ZIndex = 4,
		}, b)
	end
	local sc = new("UIScale", {}, b)
	local disabled = o.Disabled == true
	local armed = false
	local nameText = o.Name or "Button"
	local function look()
		b.BackgroundTransparency = disabled and 0.55 or 0
		lbl.TextTransparency = disabled and 0.5 or 0
	end
	look()
	b.MouseButton1Down:Connect(function()
		tween(sc, 0.08, { Scale = 0.95 })
	end)
	b.MouseButton1Up:Connect(function()
		tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
	b.MouseButton1Click:Connect(function()
		if disabled then
			return
		end
		if win.SafeMode and (o.Risky or o.Danger) then
			win:Notify({ Title = "Safe mode is on", Text = "Turn it off in Tools to use this button.", Type = "warn" })
			return
		end
		if o.DoubleClick and not armed then
			armed = true
			lbl.Text = "Tap again to confirm"
			task.delay(2, function()
				if armed then
					armed = false
					lbl.Text = nameText
				end
			end)
			return
		end
		armed = false
		lbl.Text = nameText
		win:_playClick()
		local r = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			BackgroundColor3 = C.White,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			ZIndex = 3,
		}, b)
		new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, r)
		local tw = tween(r, 0.5, { Size = UDim2.fromOffset(340, 340), BackgroundTransparency = 1 })
		tw.Completed:Connect(function()
			r:Destroy()
		end)
		if o.Danger then -- Danger = true: the screen shakes (Power = 0.2 to 4)
			win:ScreenShake(o.Power or 1.6, o.ShakeTime or 0.8)
		end
		safe(o.Callback)
	end)
	local obj = {}
	function obj:Fire()
		safe(o.Callback)
	end
	function obj:SetName(n)
		nameText = n
		lbl.Text = n
	end
	function obj:SetDescription(d)
		if dl then
			dl.Text = d
		end
	end
	function obj:SetDisabled(v)
		disabled = v == true
		look()
	end
	return register(self, o, obj, "Button")
end

function Tab:Toggle(o)
	-- Name, Description, Icon, Default, Style ("Switch"|"Checkbox"), Color, Locked, Key, Flag, Callback
	o = o or {}
	local win = self.Win
	local hasDesc = o.Description ~= nil
	local H = hasDesc and 40 or 32
	local row = self:_row(H)
	local rowStroke = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1, Transparency = 1 }, row)
	local left = 10
	local lockIcon = o.Icon == nil and o.Locked ~= nil -- a toggle that can be locked shows a padlock; it opens when unlocked
	local ico = o.Icon or (o.Locked ~= nil and (o.Locked and RebelUI.Icons.padlock or RebelUI.Icons.openpadlock))
	local icoImg
	if ico then
		icoImg = new("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.fromOffset(13, 13),
			Image = asset(ico),
			ScaleType = Enum.ScaleType.Fit,
		}, row)
		RebelUI._iconFix(icoImg, ico)
		left = 34
	end
	local right = 62 + (o.Key and 36 or 0)
	local name = label(row, o.Name or "Toggle", 11, C.Text, true)
	name.Position = UDim2.new(0, left, 0, hasDesc and 6 or 0)
	name.Size = UDim2.new(1, -(left + right), 0, hasDesc and 14 or H)
	local desc
	if hasDesc then
		desc = label(row, o.Description, 8, C.Dim, false)
		desc.Position = UDim2.new(0, left, 0, 22)
		desc.Size = UDim2.new(1, -(left + right), 0, 11)
	end
	local tag
	if o.Key then
		tag = label(row, "[" .. o.Key.Name .. "]", 9, C.Dim, true)
		tag.TextXAlignment = Enum.TextXAlignment.Right
		tag.AnchorPoint = Vector2.new(1, 0.5)
		tag.Position = UDim2.new(1, -58, 0.5, 0)
		tag.Size = UDim2.fromOffset(34, 16)
	end

	local style = o.Style or win.ToggleStyle or "Switch"
	local sharpT = style == "Sharp"
	local checky, radio, glyphKind = style == "Check", style == "Radio", (style == "Heart" and "heart") or (style == "Star" and "star") or nil
	local checkbox = style == "Checkbox" or checky or radio or glyphKind ~= nil
	local switch, swScale, swGlow, stateLabel, knob, dot, box, tick, markScale, glyph
	local swW = sharpT and 46 or 42
	if checkbox then
		box = new("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -24, 0.5, 0),
			Size = UDim2.fromOffset(20, 20),
			Text = "",
			AutoButtonColor = false,
		}, row)
		corner(box, radio and 10 or 6)
		swGlow = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 2, Transparency = 1 }, box)
		tick = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(0, 0),
			BackgroundColor3 = C.White,
			BorderSizePixel = 0,
		}, box)
		corner(tick, radio and 5 or 3)
		if checky then
			-- a check mark drawn from two bars, it pops in
			tick.Visible = false
			local mark = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1 }, box)
			markScale = new("UIScale", { Scale = 0 }, mark)
			local short = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(4, 9), Size = UDim2.fromOffset(3, 7), Rotation = -45, BackgroundColor3 = C.White, BorderSizePixel = 0 }, mark)
			local long = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(9, 6), Size = UDim2.fromOffset(3, 12), Rotation = 40, BackgroundColor3 = C.White, BorderSizePixel = 0 }, mark)
			corner(short, 1)
			corner(long, 1)
		elseif glyphKind then
			tick.Visible = false
			glyph = new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = glyphKind == "heart" and "♡" or "☆", TextSize = 22, Font = Enum.Font.GothamBold, TextColor3 = C.Dim, ZIndex = 3 }, box)
			markScale = new("UIScale", { Scale = 1 }, glyph)
		end
		switch = box
	else
		switch = new("TextButton", {
			Size = UDim2.fromOffset(swW, 20),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(1, -(swW // 2) - 10, 0.5, 0),
			Text = "",
			AutoButtonColor = false,
		}, row)
		corner(switch, sharpT and 2 or 10)
		swScale = new("UIScale", {}, switch)
		swGlow = new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 2, Transparency = 1 }, switch)
		stateLabel = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(22, 20),
			Position = UDim2.fromOffset(swW - 23, 0),
			Text = "OFF",
			TextSize = 8,
			Font = Enum.Font.GothamBold,
			TextColor3 = C.Dim,
		}, switch)
		knob = new("Frame", {
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromOffset(2, 2),
			BackgroundColor3 = Color3.fromRGB(215, 205, 205),
			BorderSizePixel = 0,
			ZIndex = 3,
		}, switch)
		corner(knob, sharpT and 2 or 8)
		if sharpT then
			-- sharp style: square knob with a bright edge, glowing frame
			new("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, knob)
		end
		dot = new("Frame", {
			Size = UDim2.fromOffset(6, 6),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
		}, knob)
		corner(dot, 3)
	end

	local obj = { Value = o.Default == true, Locked = o.Locked == true, Color = o.Color }
	local fast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local pop = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local function play(inst, info, props)
		TweenService:Create(inst, info, props):Play()
	end
	local function render(pulseIt)
		local on = obj.Value
		local t = win.Theme
		local accent = obj.Color or t.Accent
		local glow = obj.Color and obj.Color:Lerp(C.White, 0.15) or t.Glow
		swGlow.Color = glow
		rowStroke.Color = glow
		local lockT = obj.Locked and 0.5 or 0
		play(row, fast, { BackgroundColor3 = on and t.ItemOn or t.Item })
		play(rowStroke, fast, { Transparency = on and 0.55 or 1 })
		play(swGlow, fast, { Transparency = on and 0.4 or 1 })
		name.TextTransparency = obj.Locked and 0.55 or 0
		if checkbox then
			if glyph then
				glyph.Text = on and (glyphKind == "heart" and "♥" or "★") or (glyphKind == "heart" and "♡" or "☆")
				glyph.TextColor3 = on and (obj.Color or (glyphKind == "heart" and Color3.fromRGB(255, 70, 100) or Color3.fromRGB(255, 200, 50))) or C.Dim
				play(box, fast, { BackgroundTransparency = 1 })
				if pulseIt then
					markScale.Scale = 0.5
					play(markScale, pop, { Scale = 1 })
				end
			else
				play(box, fast, { BackgroundColor3 = on and accent or t.Off, BackgroundTransparency = lockT })
				if markScale then
					play(markScale, pop, { Scale = on and 1 or 0 })
				else
					play(tick, pop, { Size = on and (radio and UDim2.fromOffset(8, 8) or UDim2.fromOffset(10, 10)) or UDim2.fromOffset(0, 0) })
				end
			end
		else
			if pulseIt then
				swScale.Scale = 0.88
				play(swScale, pop, { Scale = 1 })
				knob.Size = UDim2.fromOffset(22, 16)
				if not on then
					knob.Position = UDim2.fromOffset(swW - 22, 2)
				end
			end
			play(knob, pop, {
				Position = on and UDim2.fromOffset(swW - 18, 2) or UDim2.fromOffset(2, 2),
				Size = UDim2.fromOffset(16, 16),
				BackgroundColor3 = on and C.White or Color3.fromRGB(215, 205, 205),
			})
			play(switch, fast, { BackgroundColor3 = on and accent or t.Off, BackgroundTransparency = lockT })
			dot.BackgroundColor3 = accent
			play(dot, fast, { BackgroundTransparency = on and 0 or 1 })
			stateLabel.Text = on and "ON" or "OFF"
			stateLabel.Position = on and UDim2.fromOffset(3, 0) or UDim2.fromOffset(swW - 23, 0)
			stateLabel.TextColor3 = on and C.White or C.Dim
		end
	end
	function obj:Set(v, silent)
		v = v and true or false
		local changed = v ~= self.Value
		self.Value = v
		render(changed)
		if not silent then
			if changed and win.ToggleToasts then
				win:Notify({ Title = o.Name or "Toggle", Text = v and "Enabled" or "Disabled", Duration = 1.6 })
			end
			safe(o.Callback, v)
		end
	end
	function obj:Get()
		return self.Value
	end
	function obj:Toggle()
		if self.Locked then
			win:Notify({ Title = o.Name or "Toggle", Text = "This toggle is locked", Type = "warn", Duration = 1.6 })
			return
		end
		win:_playClick()
		self:Set(not self.Value)
	end
	function obj:Lock(state)
		self.Locked = state ~= false
		if lockIcon and icoImg then
			RebelUI._setIcon(icoImg, self.Locked and RebelUI.Icons.padlock or RebelUI.Icons.openpadlock)
		end
		render(false)
	end
	function obj:SetName(n)
		name.Text = n
	end
	function obj:SetDescription(d)
		if desc then
			desc.Text = d
		end
	end
	function obj:SetColor(c)
		self.Color = c
		render(false)
	end
	switch.MouseButton1Click:Connect(function()
		obj:Toggle()
	end)
	local hit = new("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, -62, 1, 0),
		ZIndex = 2,
	}, row)
	hit.MouseButton1Click:Connect(function()
		obj:Toggle()
	end)
	if o.Key then
		table.insert(win._keybinds, {
			name = o.Name or "Toggle",
			key = function()
				return o.Key
			end,
			active = function()
				return obj.Value
			end,
		})
		win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, processed)
			if not processed and i.KeyCode == o.Key then
				obj:Toggle()
			end
		end)
	end
	win:_onTheme(function()
		render(false)
	end)
	if obj.Value and o.Callback then
		task.defer(safe, o.Callback, true) -- a toggle that starts ON tells your code once
	end
	return register(self, o, obj, "Toggle")
end

function Tab:Slider(o)
	-- Name, Min, Max, Default, Step, Suffix, Prefix, Flag, Callback(value)
	-- Arrows = true (< > buttons), Log = true (fine steps for small numbers, Min must be above 0)
	o = o or {}
	local win = self.Win
	local min, max = o.Min or 0, o.Max or 100
	local step = o.Step or 1
	local suffix = o.Suffix or ""
	local row = self:_row(44)
	local name = label(row, o.Name or "Slider", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 6)
	name.Size = UDim2.new(1, -66, 0, 14)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(1, -58, 0, 6)
	val.Size = UDim2.fromOffset(48, 14)
	local bar = new("Frame", {
		Position = UDim2.fromOffset(12, 31),
		Size = UDim2.new(1, -24, 0, 4),
		BorderSizePixel = 0,
	}, row)
	local sharp = (o.Style or win.SliderStyle or win.ToggleStyle) == "Sharp"
	corner(bar, sharp and 0 or 2)
	if sharp then
		bar.Size = UDim2.new(1, -24, 0, 6)
		bar.Position = UDim2.fromOffset(12, 30)
		new("UIStroke", { Color = Color3.fromRGB(0, 0, 0), Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 0.3 }, bar)
	end
	win:_bind(bar, "BackgroundColor3", "Off")
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, bar)
	corner(fill, sharp and 0 or 2)
	if sharp then
		new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(170, 170, 170)), Rotation = 90 }, fill)
	end
	win:_bind(fill, "BackgroundColor3", "Accent")
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(12, 12),
		BackgroundColor3 = C.Text,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, bar)
	corner(knob, sharp and 0 or 6)
	if sharp then
		-- a diamond with a glowing edge
		knob.Rotation = 45
		knob.Size = UDim2.fromOffset(11, 11)
		local ks = new("UIStroke", { Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, knob)
		win:_bind(ks, "Color", "Glow")
	end
	local hit = new("TextButton", {
		BackgroundTransparency = 1,
		Text = "",
		Position = UDim2.fromOffset(6, 22),
		Size = UDim2.new(1, -12, 0, 22),
		ZIndex = 3,
	}, row)

	local obj = { Value = min }
	-- Log = true: the left part of the bar covers small numbers in fine steps (needs Min above 0)
	local useLog = o.Log == true and min > 0 and max > min
	local function toRel(v)
		if useLog then
			return math.log(math.max(v, min) / min) / math.log(max / min)
		end
		return (v - min) / math.max(max - min, 1e-9)
	end
	local function fromRel(r)
		if useLog then
			return min * (max / min) ^ r
		end
		return min + r * (max - min)
	end
	local function render()
		local rel = toRel(obj.Value)
		fill.Size = UDim2.fromScale(rel, 1)
		knob.Position = UDim2.new(rel, 0, 0.5, 0)
		val.Text = (o.Prefix or "") .. tostring(obj.Value) .. suffix
	end
	local function snap(v)
		v = math.clamp(v, min, max)
		v = min + math.floor((v - min) / step + 0.5) * step
		v = math.clamp(v, min, max)
		return math.floor(v * 10000 + 0.5) / 10000
	end
	function obj:Set(v, silent)
		v = snap(tonumber(v) or min)
		local changed = v ~= self.Value
		self.Value = v
		render()
		if changed and not silent then
			safe(o.Callback, v)
		end
	end
	function obj:Get()
		return self.Value
	end
	local page = self.Page
	-- the touch area is a little bigger than the thin bar
	local dragging = false
	hit.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			page.ScrollingEnabled = false
			local w = bar.AbsoluteSize.X
			if w > 0 then
				obj:Set(fromRel(math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1)))
			end
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			local w = bar.AbsoluteSize.X
			if w > 0 then
				obj:Set(fromRel(math.clamp((i.Position.X - bar.AbsolutePosition.X) / w, 0, 1)))
			end
		end
	end)
	if o.Arrows then
		-- small < > buttons for exact one-step changes
		val.Position = UDim2.new(1, -104, 0, 6)
		local function arrow(txt, x, dir)
			local a = new("TextButton", {
				Position = UDim2.new(1, x, 0, 5),
				Size = UDim2.fromOffset(20, 16),
				BorderSizePixel = 0,
				Text = txt,
				TextSize = 11,
				TextColor3 = C.Text,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				ZIndex = 4,
			}, row)
			corner(a, 5)
			win:_bind(a, "BackgroundColor3", "Inset")
			a.MouseButton1Click:Connect(function()
				obj:Set(obj.Value + dir * step)
			end)
		end
		arrow("<", -50, -1)
		arrow(">", -28, 1)
	end
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
		end
	end)
	obj.Value = snap(o.Default or min)
	render()
	return register(self, o, obj, "Slider")
end

function Tab:Dropdown(o)
	-- Name, Options (a list, or "Players" for everyone in the server), Default, Multi, Flag, Callback(choice) (Multi gives { Speed = true, ... })
	-- Searchable: a search box inside the list (automatic when there are more than 7 options)
	o = o or {}
	local win = self.Win
	local function playerNames()
		local out = {}
		for _, pl in ipairs(Players:GetPlayers()) do
			table.insert(out, pl.Name)
		end
		table.sort(out)
		return out
	end
	local isPlayers = o.Options == "Players"
	local options = isPlayers and playerNames() or o.Options or {}
	local multi = o.Multi == true
	local searchable = o.Searchable == true or (o.Searchable ~= false and #options > 7)
	local HEAD, ITEM = 34, 24
	local SH = searchable and 26 or 0
	local row = self:_row(HEAD)
	row.ClipsDescendants = true
	local name = label(row, o.Name or "Dropdown", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 0)
	name.Size = UDim2.new(0.5, -10, 0, HEAD)
	local cur = label(row, "", 10, C.Dim, true)
	cur.TextXAlignment = Enum.TextXAlignment.Right
	cur.Position = UDim2.new(0.5, 0, 0, 0)
	cur.Size = UDim2.new(0.5, -28, 0, HEAD)
	local arrow = label(row, "v", 10, C.Dim, true)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	arrow.Position = UDim2.new(1, -22, 0, 0)
	arrow.Size = UDim2.fromOffset(14, HEAD)
	local head = new("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.new(1, 0, 0, HEAD) }, row)
	local items = {}
	local sbox
	if searchable then
		sbox = new("TextBox", {
			Position = UDim2.new(0, 6, 0, HEAD),
			Size = UDim2.new(1, -12, 0, 22),
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "Search...",
			PlaceholderColor3 = C.Dim,
			TextColor3 = C.Text,
			TextSize = 10,
			Font = Enum.Font.Gotham,
			ClearTextOnFocus = false,
		}, row)
		corner(sbox, 6)
		win:_bind(sbox, "BackgroundColor3", "Item")
		sbox:GetPropertyChangedSignal("Text"):Connect(function()
			local q = sbox.Text:lower()
			for v, b in pairs(items) do
				b.Visible = q == "" or tostring(v):lower():find(q, 1, true) ~= nil
			end
		end)
	end
	local list = new("ScrollingFrame", {
		Position = UDim2.new(0, 6, 0, HEAD + SH),
		Size = UDim2.new(1, -12, 1, -HEAD - SH - 6),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, row)
	new("UIListLayout", { Padding = UDim.new(0, 2) }, list)

	local obj = { Value = multi and {} or nil, Open = false }
	local function selected(v)
		if multi then
			return obj.Value[v] == true
		end
		return obj.Value == v
	end
	local function text()
		if multi then
			local t = {}
			for _, v in ipairs(options) do
				if obj.Value[v] then
					table.insert(t, tostring(v))
				end
			end
			return #t > 0 and table.concat(t, ", ") or "None"
		end
		return obj.Value ~= nil and tostring(obj.Value) or "Select"
	end
	local function render()
		cur.Text = text()
		for v, b in pairs(items) do
			b.TextColor3 = selected(v) and win.Theme.Glow or C.Text
			b.Font = selected(v) and Enum.Font.GothamBold or Enum.Font.Gotham
		end
	end
	local function build(v)
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, ITEM),
			Text = tostring(v),
			TextSize = 10,
			Font = Enum.Font.Gotham,
			TextColor3 = C.Text,
			AutoButtonColor = false,
		}, list)
		corner(b, 6)
		win:_bind(b, "BackgroundColor3", "Inset")
		items[v] = b
		b.MouseButton1Click:Connect(function()
			win:_playClick()
			if multi then
				obj.Value[v] = not obj.Value[v] or nil
			else
				obj.Value = v
				obj:Close()
			end
			render()
			safe(o.Callback, obj.Value)
		end)
	end
	for _, v in ipairs(options) do
		build(v)
	end
	local function setOpen(open)
		obj.Open = open
		local shown = math.min(#options, 5)
		tween(row, 0.18, { Size = UDim2.new(1, 0, 0, open and (HEAD + SH + shown * (ITEM + 2) + 8) or HEAD) })
		arrow.Text = open and "^" or "v"
		if not open and sbox then
			sbox.Text = ""
		end
	end
	function obj:Close()
		setOpen(false)
	end
	head.MouseButton1Click:Connect(function()
		win:_playClick()
		setOpen(not obj.Open)
	end)
	function obj:Set(v, silent)
		if multi then
			obj.Value = {}
			if type(v) == "table" then
				for k, x in pairs(v) do
					if type(k) == "number" then
						obj.Value[x] = true
					elseif x then
						obj.Value[k] = true
					end
				end
			end
		else
			obj.Value = v
		end
		render()
		if not silent then
			safe(o.Callback, obj.Value)
		end
	end
	function obj:Get()
		return obj.Value
	end
	function obj:Refresh(newOptions)
		for _, b in pairs(items) do
			b:Destroy()
		end
		items, options = {}, newOptions or {}
		for _, v in ipairs(options) do
			build(v)
		end
		render()
	end
	if o.Default ~= nil then
		obj:Set(o.Default, true)
	else
		render()
	end
	win:_onTheme(render)
	if isPlayers then
		-- Options = "Players": the list follows who is in the server
		local function again()
			local keep = obj.Value
			obj:Refresh(playerNames())
			if not multi and keep ~= nil and items[keep] then
				obj.Value = keep
				render()
			end
		end
		win._conns[#win._conns + 1] = Players.PlayerAdded:Connect(again)
		win._conns[#win._conns + 1] = Players.PlayerRemoving:Connect(function()
			task.delay(0.1, again)
		end)
	end
	return register(self, o, obj, "Dropdown")
end

function Tab:Input(o)
	-- Name, Default, Placeholder, Clear, Flag, Callback(text)
	-- Numeric = true: only numbers, Callback(number). Min / Max clamp it. Math = true also solves things like 16 * 4.
	o = o or {}
	if o.Math then
		o.Numeric = true
	end
	local win = self.Win
	local row = self:_row(36)
	local name = label(row, o.Name or "Input", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 0)
	name.Size = UDim2.new(0.42, -10, 1, 0)
	local box = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.58, -16, 0, 24),
		BorderSizePixel = 0,
		Text = o.Default or "",
		PlaceholderText = o.Placeholder or "type here",
		PlaceholderColor3 = C.Dim,
		TextColor3 = C.Text,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		ClearTextOnFocus = false,
	}, row)
	corner(box, 6)
	win:_bind(box, "BackgroundColor3", "Inset")
	local obj = {}
	-- Math = true lets you type 16 * 4 or (2 + 3) ^ 2 and get the answer. Plain recursive parser, no loadstring.
	local function evaluate(src)
		local pos, s = 1, tostring(src):gsub("%s+", "")
		local expr
		local function atom()
			local c = s:sub(pos, pos)
			if c == "(" then
				pos += 1
				local v = expr()
				if s:sub(pos, pos) == ")" then
					pos += 1
				end
				return v
			elseif c == "-" then
				pos += 1
				return -(atom() or 0)
			end
			local num = s:match("^%d*%.?%d+", pos) or s:match("^%d+", pos)
			if not num then
				return nil
			end
			pos += #num
			return tonumber(num)
		end
		local function power()
			local a = atom()
			while a and s:sub(pos, pos) == "^" do
				pos += 1
				local b = atom()
				a = b and a ^ b or nil
			end
			return a
		end
		local function term()
			local a = power()
			while a do
				local c = s:sub(pos, pos)
				if c ~= "*" and c ~= "/" and c ~= "%" then
					break
				end
				pos += 1
				local b = power()
				if not b then
					return nil
				end
				a = c == "*" and a * b or (c == "/" and b ~= 0 and a / b) or (c == "%" and b ~= 0 and a % b) or nil
			end
			return a
		end
		function expr()
			local a = term()
			while a do
				local c = s:sub(pos, pos)
				if c ~= "+" and c ~= "-" then
					break
				end
				pos += 1
				local b = term()
				if not b then
					return nil
				end
				a = c == "+" and a + b or a - b
			end
			return a
		end
		local r = expr()
		if pos <= #s then
			return nil
		end
		return r
	end
	local function value()
		if not o.Numeric then
			return box.Text
		end
		local n = (o.Math and evaluate(box.Text)) or tonumber(box.Text) or tonumber(o.Default) or 0
		return math.clamp(n, o.Min or -math.huge, o.Max or math.huge)
	end
	if o.Numeric or o.MaxLength then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			local clean = box.Text
			if o.Numeric then
				clean = (clean:gsub(o.Math and "[^%d%.%-%+%*/%^%%%(%)%s]" or "[^%d%.%-]", ""))
			end
			if o.MaxLength and #clean > o.MaxLength then
				clean = clean:sub(1, o.MaxLength)
			end
			if clean ~= box.Text then
				box.Text = clean
			end
		end)
	end
	function obj:Set(v, silent)
		box.Text = tostring(v)
		if not silent then
			safe(o.Callback, value())
		end
	end
	function obj:Get()
		return value()
	end
	box.FocusLost:Connect(function()
		if o.Numeric then
			box.Text = tostring(value())
		end
		safe(o.Callback, value())
		if o.Clear then
			box.Text = ""
		end
	end)
	return register(self, o, obj, "Input")
end

function Tab:Keybind(o)
	-- Name, Default (Enum.KeyCode), Flag, Callback() when the key is pressed, Changed(key) when rebound
	-- Modifier = Enum.KeyCode.LeftShift: the key only counts while that key is held (a combo, like Shift + F)
	-- Mode: "Press" (default, Callback()), "Toggle" (Callback(true/false) each press), "Hold" (Callback(true) down, Callback(false) up)
	o = o or {}
	local mode = o.Mode or "Press"
	local win = self.Win
	local row = self:_row(36)
	local name = label(row, o.Name or "Keybind", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 0)
	name.Size = UDim2.new(1, -100, 1, 0)
	local b = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(78, 22),
		BorderSizePixel = 0,
		TextColor3 = C.Text,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, row)
	corner(b, 6)
	win:_bind(b, "BackgroundColor3", "Inset")
	local obj = { Value = o.Default or Enum.KeyCode.F, Listening = false, State = false }
	table.insert(win._keybinds, {
		name = o.Name or "Keybind",
		key = function()
			return obj.Value
		end,
		active = function()
			return obj.State
		end,
	})
	local function render()
		b.Text = obj.Listening and "press a key..." or ((o.Modifier and (o.Modifier.Name:gsub("^Left", "") .. "+") or "") .. obj.Value.Name)
	end
	function obj:Set(k, silent)
		self.Value = k
		self.Listening = false
		render()
		if not silent then
			safe(o.Changed, k)
		end
	end
	function obj:Get()
		return self.Value
	end
	b.MouseButton1Click:Connect(function()
		obj.Listening = true
		render()
	end)
	win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, processed)
		if i.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if obj.Listening then
			obj:Set(i.KeyCode == Enum.KeyCode.Escape and obj.Value or i.KeyCode)
		elseif not processed and i.KeyCode == obj.Value and (not o.Modifier or UIS:IsKeyDown(o.Modifier)) then
			if mode == "Toggle" then
				obj.State = not obj.State
				safe(o.Callback, obj.State)
			elseif mode == "Hold" then
				obj.State = true
				safe(o.Callback, true)
			else
				safe(o.Callback)
			end
		end
	end)
	if mode == "Hold" then
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if obj.State and i.KeyCode == obj.Value then
				obj.State = false
				safe(o.Callback, false)
			end
		end)
	end
	render()
	return register(self, o, obj, "Keybind")
end

local PRESETS = {
	Color3.fromRGB(235, 40, 50),
	Color3.fromRGB(255, 150, 50),
	Color3.fromRGB(250, 210, 60),
	Color3.fromRGB(60, 205, 110),
	Color3.fromRGB(60, 200, 220),
	Color3.fromRGB(64, 140, 255),
	Color3.fromRGB(160, 90, 255),
	Color3.fromRGB(255, 90, 170),
	Color3.fromRGB(240, 240, 245),
}

function Tab:Color(o)
	-- Name, Default (Color3), Flag, Callback(Color3). Tap the swatch: hue / saturation / brightness bars, hex box, presets.
	o = o or {}
	local win = self.Win
	local HEAD, FULL = 40, 168
	local row = self:_row(HEAD)
	row.ClipsDescendants = true
	local name = label(row, o.Name or "Color", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 6)
	name.Size = UDim2.new(1, -130, 0, 14)
	local hint = label(row, "Tap the color to change it", 8, C.Dim, false)
	hint.Position = UDim2.fromOffset(10, 22)
	hint.Size = UDim2.new(1, -130, 0, 11)
	local swatch = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0, HEAD / 2),
		Size = UDim2.fromOffset(34, 18),
		Text = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
	}, row)
	corner(swatch, 9)
	new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = C.Text, Thickness = 1.5, Transparency = 0.4 }, swatch)
	local hex = new("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -52, 0, HEAD / 2),
		Size = UDim2.fromOffset(62, 20),
		BorderSizePixel = 0,
		Text = "",
		TextColor3 = C.Text,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		ClearTextOnFocus = false,
	}, row)
	corner(hex, 6)
	win:_bind(hex, "BackgroundColor3", "Inset")

	local function makeBar(y)
		local bar = new("Frame", {
			Position = UDim2.fromOffset(12, y),
			Size = UDim2.new(1, -24, 0, 12),
			BackgroundColor3 = C.White,
			BorderSizePixel = 0,
		}, row)
		corner(bar, 6)
		local g = new("UIGradient", {}, bar)
		local knob = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(8, 18),
			BackgroundColor3 = C.Text,
			BorderSizePixel = 0,
		}, bar)
		corner(knob, 3)
		return bar, g, knob
	end
	local hueBar, hueG, hueKnob = makeBar(50)
	local satBar, satG, satKnob = makeBar(76)
	local valBar, valG, valKnob = makeBar(102)
	hueG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
		ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
		ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
		ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
	})

	local def = o.Default or Color3.fromRGB(235, 40, 50)
	local h, s, v = def:ToHSV()
	local obj = { Value = def, Open = false }
	local function render()
		obj.Value = Color3.fromHSV(h, s, v)
		swatch.BackgroundColor3 = obj.Value
		hex.Text = toHex(obj.Value)
		hueKnob.Position = UDim2.new(h, 0, 0.5, 0)
		satKnob.Position = UDim2.new(s, 0, 0.5, 0)
		valKnob.Position = UDim2.new(v, 0, 0.5, 0)
		satG.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
		valG.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(h, s, 1))
	end
	local page = self.Page
	local function lock(down)
		page.ScrollingEnabled = not down
	end
	local function changed()
		render()
		safe(o.Callback, obj.Value)
	end
	bindBar(win, hueBar, function(rel)
		h = rel
		changed()
	end, lock)
	bindBar(win, satBar, function(rel)
		s = rel
		changed()
	end, lock)
	bindBar(win, valBar, function(rel)
		v = rel
		changed()
	end, lock)

	local sw = new("Frame", { Position = UDim2.fromOffset(12, 134), Size = UDim2.new(1, -24, 0, 22), BackgroundTransparency = 1 }, row)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, sw)
	for i, c in ipairs(PRESETS) do
		local b = new("TextButton", {
			Size = UDim2.fromOffset(22, 22),
			BackgroundColor3 = c,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = i,
		}, sw)
		corner(b, 11)
		b.MouseButton1Click:Connect(function()
			h, s, v = c:ToHSV()
			changed()
		end)
	end
	hex.FocusLost:Connect(function()
		local c = fromHex(hex.Text)
		if c then
			h, s, v = c:ToHSV()
			changed()
		else
			render()
		end
	end)
	swatch.MouseButton1Click:Connect(function()
		win:_playClick()
		obj.Open = not obj.Open
		hint.Text = obj.Open and "Drag the bars, type a hex, or pick a preset" or "Tap the color to change it"
		tween(row, 0.2, { Size = UDim2.new(1, 0, 0, obj.Open and FULL or HEAD) })
	end)

	function obj:Set(c, silent)
		h, s, v = c:ToHSV()
		render()
		if not silent then
			safe(o.Callback, obj.Value)
		end
	end
	function obj:Get()
		return obj.Value
	end
	function obj:GetHex()
		return toHex(obj.Value)
	end
	function obj:SetHex(str, silent)
		local c = fromHex(str)
		if c then
			obj:Set(c, silent)
		end
	end
	render()
	return register(self, o, obj, "Color")
end

function Tab:Header(o)
	-- Title, Text, Icon: a banner card, the "text hub" of a tab
	o = o or {}
	local win = self.Win
	local hasText = o.Text ~= nil and o.Text ~= ""
	local row = self:_row(hasText and 58 or 40)
	row.ClipsDescendants = true
	local mark = new("Frame", { Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0 }, row)
	win:_bind(mark, "BackgroundColor3", "Accent")
	local left = 14
	if o.Icon then
		local holder = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 12, 0.5, 0),
			Size = UDim2.fromOffset(34, 34),
			BorderSizePixel = 0,
		}, row)
		corner(holder, 9)
		win:_bind(holder, "BackgroundColor3", "Inset")
		local hico = new("ImageLabel", {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(24, 24),
			Image = asset(o.Icon),
			ScaleType = Enum.ScaleType.Fit,
		}, holder)
		RebelUI._iconFix(hico, o.Icon)
		left = 54
	end
	local title = label(row, o.Title or "Header", 13, C.Text, true)
	title.Position = UDim2.new(0, left, 0, hasText and 7 or 0)
	title.Size = UDim2.new(1, -(left + 8), 0, hasText and 18 or 40)
	local body
	if hasText then
		body = label(row, o.Text, 9, C.Dim, false)
		body.TextWrapped = true
		body.TextTruncate = Enum.TextTruncate.None
		body.TextYAlignment = Enum.TextYAlignment.Top
		body.Position = UDim2.new(0, left, 0, 26)
		body.Size = UDim2.new(1, -(left + 8), 0, 28)
	end
	local obj = {}
	function obj:SetTitle(t)
		title.Text = t
	end
	function obj:SetText(t)
		if body then
			body.Text = t
		end
	end
	return register(self, o, obj, "Header")
end

function Tab:Image(o)
	-- Image (123456 or "rbxassetid://123456"), Height, Caption, Crop (true = fill and crop)
	o = o or {}
	local h = o.Height or 110
	local row = self:_row(h + (o.Caption and 22 or 0))
	row.ClipsDescendants = true
	local img = new("ImageLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 0, h - 12),
		Image = asset(o.Image),
		ScaleType = o.Crop and Enum.ScaleType.Crop or Enum.ScaleType.Fit,
	}, row)
	corner(img, o.Circle and 500 or 6)
	if o.Circle then
		img.Size = UDim2.fromOffset(h - 12, h - 12)
		img.Position = UDim2.new(0.5, -(h - 12) / 2, 0, 6)
		img.ScaleType = Enum.ScaleType.Crop
	end
	if RebelUI._imageEffect and o.Effect then
		RebelUI._imageEffect(img, o.Effect, self.Win.Theme)
	end
	if o.OnClick then
		local hitb = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 5 }, img)
		hitb.MouseButton1Click:Connect(function()
			task.spawn(o.OnClick)
		end)
	end
	local cap
	if o.Caption then
		cap = label(row, o.Caption, 9, C.Dim, false)
		cap.TextXAlignment = Enum.TextXAlignment.Center
		cap.Position = UDim2.fromOffset(6, h - 4)
		cap.Size = UDim2.new(1, -12, 0, 16)
	end
	local obj = {}
	function obj:Set(i)
		img.Image = asset(i)
	end
	function obj:Get()
		return img.Image
	end
	function obj:SetCaption(t)
		if cap then
			cap.Text = t
		end
	end
	return register(self, o, obj, "Image")
end

function Tab:Progress(o)
	-- Name, Min, Max, Default, Suffix. A read-only bar: use :Set(value) from your own code.
	o = o or {}
	local win = self.Win
	local min, max = o.Min or 0, o.Max or 100
	local suffix = o.Suffix or "%"
	local row = self:_row(40)
	local name = label(row, o.Name or "Progress", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(1, -66, 0, 14)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(1, -58, 0, 5)
	val.Size = UDim2.fromOffset(48, 14)
	local bar = new("Frame", { Position = UDim2.fromOffset(12, 26), Size = UDim2.new(1, -24, 0, 6), BorderSizePixel = 0 }, row)
	corner(bar, 3)
	win:_bind(bar, "BackgroundColor3", "Off")
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, bar)
	corner(fill, 3)
	local fg = new("UIGradient", {}, fill)
	win:_onTheme(function(t)
		fill.BackgroundColor3 = C.White
		fg.Color = ColorSequence.new(t.Accent, t.Glow:Lerp(Color3.new(1, 0.8, 0.5), 0.4))
	end)
	local obj = { Value = min }
	function obj:Set(v)
		v = math.clamp(tonumber(v) or min, min, max)
		self.Value = v
		local rel = (v - min) / math.max(max - min, 1e-9)
		tween(fill, 0.2, { Size = UDim2.fromScale(rel, 1) })
		val.Text = tostring(math.floor(v * 100 + 0.5) / 100) .. suffix
	end
	function obj:Get()
		return self.Value
	end
	obj:Set(o.Default or min)
	return register(self, o, obj, "Progress")
end

function Tab:Paragraph(o)
	-- Title, Text: a titled block of text
	o = o or {}
	local row = self:_row(30)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.Size = UDim2.new(1, 0, 0, 0)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, row)
	new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	local t = label(row, o.Title or "", 11, C.Text, true)
	t.Size = UDim2.new(1, 0, 0, 14)
	t.LayoutOrder = 1
	local b = label(row, o.Text or "", 9, C.Dim, false)
	if type(o.Text) == "string" and o.Text:find("https?://") then
		b.RichText = true
		b.Text = RebelUI._richLinks(o.Text)
	end
	b.TextWrapped = true
	b.TextTruncate = Enum.TextTruncate.None
	b.Size = UDim2.new(1, 0, 0, 0)
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.LayoutOrder = 2
	local obj = {}
	function obj:Set(title, text)
		t.Text = title or t.Text
		b.Text = text or b.Text
	end
	return register(self, o, obj, "Paragraph")
end

function Tab:Notice(o)
	-- a colored box for warnings and tips. Type = "warn" (yellow), "error" (red), "success" (green) or none. Title, Text
	o = o or {}
	local kinds = { warn = C.Yellow, error = C.Bad, success = C.Green }
	local row = self:_row(30)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.Size = UDim2.new(1, 0, 0, 0)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, row)
	new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	local st = new("UIStroke", { Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, row)
	local t = label(row, o.Title or "Note", 11, C.Text, true)
	t.Size = UDim2.new(1, 0, 0, 14)
	t.LayoutOrder = 1
	local b = label(row, o.Text or "", 9, C.Dim, false)
	b.TextWrapped = true
	b.TextTruncate = Enum.TextTruncate.None
	b.Size = UDim2.new(1, 0, 0, 0)
	b.AutomaticSize = Enum.AutomaticSize.Y
	b.LayoutOrder = 2
	local kind = o.Type
	local function paint()
		local c = kinds[kind or ""] or self.Win.Theme.Glow
		st.Color = c
		t.TextColor3 = c
	end
	self.Win:_onTheme(paint)
	local obj = {}
	function obj:Set(title, text)
		t.Text = title or t.Text
		b.Text = text or b.Text
	end
	function obj:SetType(k)
		kind = k
		paint()
	end
	return register(self, o, obj, "Notice")
end

-- ============================================================ range slider (two knobs)
function Tab:RangeSlider(o)
	-- Name, Min, Max, Default = { Low, High }, Step, Suffix, Flag, Callback(low, high). Get() gives { Low =, High = }
	o = o or {}
	local win = self.Win
	local min, max = o.Min or 0, o.Max or 100
	local step = o.Step or 1
	local suffix = o.Suffix or ""
	local row = self:_row(44)
	local name = label(row, o.Name or "Range", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 6)
	name.Size = UDim2.new(1, -110, 0, 14)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(1, -108, 0, 6)
	val.Size = UDim2.fromOffset(98, 14)
	local bar = new("Frame", { Position = UDim2.fromOffset(12, 31), Size = UDim2.new(1, -24, 0, 4), BorderSizePixel = 0 }, row)
	corner(bar, 2)
	win:_bind(bar, "BackgroundColor3", "Off")
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BorderSizePixel = 0 }, bar)
	corner(fill, 2)
	win:_bind(fill, "BackgroundColor3", "Accent")
	local knobs = {}
	for k = 1, 2 do
		local kn = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = C.Text,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, bar)
		corner(kn, 6)
		knobs[k] = kn
	end
	local hit = new("TextButton", { BackgroundTransparency = 1, Text = "", Position = UDim2.fromOffset(6, 22), Size = UDim2.new(1, -12, 0, 22), ZIndex = 3 }, row)
	local obj = { Low = min, High = max }
	local function snap(v)
		v = math.clamp(v, min, max)
		v = min + math.floor((v - min) / step + 0.5) * step
		return math.floor(math.clamp(v, min, max) * 10000 + 0.5) / 10000
	end
	local function render()
		local a = (obj.Low - min) / math.max(max - min, 1e-9)
		local b = (obj.High - min) / math.max(max - min, 1e-9)
		knobs[1].Position = UDim2.new(a, 0, 0.5, 0)
		knobs[2].Position = UDim2.new(b, 0, 0.5, 0)
		fill.Position = UDim2.fromScale(a, 0)
		fill.Size = UDim2.fromScale(math.max(b - a, 0), 1)
		val.Text = tostring(obj.Low) .. suffix .. " - " .. tostring(obj.High) .. suffix
	end
	function obj:Set(v, silent)
		local lo, hi
		if type(v) == "table" then
			lo, hi = v.Low or v[1], v.High or v[2]
		end
		lo, hi = snap(tonumber(lo) or min), snap(tonumber(hi) or max)
		if lo > hi then
			lo, hi = hi, lo
		end
		local changed = lo ~= self.Low or hi ~= self.High
		self.Low, self.High = lo, hi
		render()
		if changed and not silent then
			safe(o.Callback, lo, hi)
		end
	end
	function obj:Get()
		return { Low = self.Low, High = self.High }
	end
	local page = self.Page
	local dragging, which = false, 1
	local function move(x)
		local w = bar.AbsoluteSize.X
		if w <= 0 then
			return
		end
		local v = min + math.clamp((x - bar.AbsolutePosition.X) / w, 0, 1) * (max - min)
		if which == 1 then
			obj:Set({ Low = math.min(v, obj.High), High = obj.High })
		else
			obj:Set({ Low = obj.Low, High = math.max(v, obj.Low) })
		end
	end
	hit.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			page.ScrollingEnabled = false
			local w = bar.AbsoluteSize.X
			local v = min + math.clamp((i.Position.X - bar.AbsolutePosition.X) / math.max(w, 1), 0, 1) * (max - min)
			which = math.abs(v - obj.Low) <= math.abs(v - obj.High) and 1 or 2
			move(i.Position.X)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			move(i.Position.X)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
		end
	end)
	obj:Set(o.Default or { min, max }, true)
	return register(self, o, obj, "RangeSlider")
end

-- ============================================================ 2D pad (two values with one finger)
function Tab:Pad(o)
	-- Name, Default = { X = 0.5, Y = 0.5 } (0 to 1), Height, Flag, Callback(x, y). Get() gives { X =, Y = }
	o = o or {}
	local win = self.Win
	local H = o.Height or 110
	local row = self:_row(H + 26)
	local name = label(row, o.Name or "Pad", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(0.5, -10, 0, 14)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(0.5, 0, 0, 5)
	val.Size = UDim2.new(0.5, -10, 0, 14)
	local box = new("TextButton", {
		Position = UDim2.fromOffset(10, 24),
		Size = UDim2.new(1, -20, 0, H),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		ClipsDescendants = true,
	}, row)
	corner(box, 8)
	win:_bind(box, "BackgroundColor3", "Inset")
	local vline = new("Frame", { Size = UDim2.new(0, 1, 1, 0), BorderSizePixel = 0, BackgroundTransparency = 0.6 }, box)
	local hline = new("Frame", { Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.6 }, box)
	local dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(14, 14), BorderSizePixel = 0, ZIndex = 3 }, box)
	corner(dot, 7)
	win:_bind(dot, "BackgroundColor3", "Glow")
	win:_bind(vline, "BackgroundColor3", "Glow")
	win:_bind(hline, "BackgroundColor3", "Glow")
	local obj = { X = 0.5, Y = 0.5 }
	local function render()
		dot.Position = UDim2.fromScale(obj.X, obj.Y)
		vline.Position = UDim2.new(obj.X, 0, 0, 0)
		hline.Position = UDim2.new(0, 0, obj.Y, 0)
		val.Text = string.format("%.2f , %.2f", obj.X, obj.Y)
	end
	function obj:Set(v, silent)
		v = type(v) == "table" and v or {}
		self.X = math.clamp(tonumber(v.X or v[1]) or 0.5, 0, 1)
		self.Y = math.clamp(tonumber(v.Y or v[2]) or 0.5, 0, 1)
		render()
		if not silent then
			safe(o.Callback, self.X, self.Y)
		end
	end
	function obj:Get()
		return { X = self.X, Y = self.Y }
	end
	local page = self.Page
	local dragging = false
	local function move(p)
		local s = box.AbsoluteSize
		if s.X > 0 and s.Y > 0 then
			obj:Set({ X = (p.X - box.AbsolutePosition.X) / s.X, Y = (p.Y - box.AbsolutePosition.Y) / s.Y })
		end
	end
	box.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true
			page.ScrollingEnabled = false
			move(i.Position)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if dragging and isMove(i) then
			move(i.Position)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if dragging and isPress(i) then
			dragging = false
			page.ScrollingEnabled = true
		end
	end)
	obj:Set(o.Default or { X = 0.5, Y = 0.5 }, true)
	return register(self, o, obj, "Pad")
end

-- ============================================================ console (a log you can read inside the panel)
local LOG_COLORS = { warn = C.Yellow, error = C.Bad, success = C.Green }
function Tab:Console(o)
	-- Name, Height (120), MaxLines (200). obj:Log(text, "info"|"warn"|"error"|"success"), obj:Clear(), obj:GetText(), obj:Copy()
	o = o or {}
	local win = self.Win
	local H = o.Height or 120
	local row = self:_row(H + 30)
	local name = label(row, o.Name or "Console", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(1, -120, 0, 16)
	local list = new("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 25),
		Size = UDim2.new(1, -16, 0, H),
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, row)
	corner(list, 6)
	win:_bind(list, "BackgroundColor3", "Inset")
	new("UIListLayout", { Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4) }, list)
	local obj = { Lines = {}, _n = 0 }
	local function small(txt, x, fn)
		local b = new("TextButton", {
			Position = UDim2.new(1, x, 0, 5),
			Size = UDim2.fromOffset(48, 16),
			BorderSizePixel = 0,
			Text = txt,
			TextSize = 9,
			TextColor3 = C.Text,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
		}, row)
		corner(b, 5)
		win:_bind(b, "BackgroundColor3", "Inset")
		b.MouseButton1Click:Connect(fn)
	end
	function obj:Log(text, kind)
		self._n += 1
		local stamp = os.date("%H:%M:%S")
		local l = new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = "[" .. stamp .. "] " .. tostring(text),
			TextSize = 9,
			Font = Enum.Font.Code,
			TextColor3 = LOG_COLORS[kind or ""] or C.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			LayoutOrder = self._n,
		}, list)
		table.insert(self.Lines, { l = l, t = l.Text })
		while #self.Lines > (o.MaxLines or 200) do
			local first = table.remove(self.Lines, 1)
			first.l:Destroy()
		end
		list.CanvasPosition = Vector2.new(0, 1e6)
	end
	function obj:Clear()
		for _, e in ipairs(self.Lines) do
			e.l:Destroy()
		end
		self.Lines = {}
	end
	function obj:GetText()
		local out = {}
		for _, e in ipairs(self.Lines) do
			table.insert(out, e.t)
		end
		return table.concat(out, "\n")
	end
	function obj:Copy()
		return type(setclipboard) == "function" and pcall(setclipboard, self:GetText())
	end
	function obj:Get()
		return self:GetText()
	end
	function obj:Set() end
	small("Clear", -56, function()
		obj:Clear()
	end)
	small("Copy", -108, function()
		local ok = obj:Copy()
		win:Notify({ Title = ok and "Copied" or "Can't copy", Type = ok and "success" or "warn" })
	end)
	win._console = win._console or obj
	return register(self, o, obj, "Console")
end

function Window:Log(text, kind)
	-- writes to the first Console you made. Returns false if there is none.
	if self._console then
		self._console:Log(text, kind)
		return true
	end
	return false
end

-- ============================================================ live graph (FPS, Ping, Memory, frame time or your own number)
function Tab:Graph(o)
	-- Name, Source = "FPS" | "Ping" | "Memory" | "Frame" | function() return number end, Height (60), Samples (30), Interval (0.25), Max, Suffix
	o = o or {}
	local win = self.Win
	local H = o.Height or 60
	local N = math.clamp(o.Samples or 30, 8, 60)
	local source = o.Source or "FPS"
	local row = self:_row(H + 30)
	local name = label(row, o.Name or tostring(type(source) == "string" and source or "Graph"), 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(0.6, -10, 0, 16)
	local val = label(row, "", 10, C.Dim, true)
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Position = UDim2.new(0.6, 0, 0, 5)
	val.Size = UDim2.new(0.4, -10, 0, 16)
	local area = new("Frame", { Position = UDim2.fromOffset(10, 26), Size = UDim2.new(1, -20, 0, H), BorderSizePixel = 0, ClipsDescendants = true }, row)
	corner(area, 6)
	win:_bind(area, "BackgroundColor3", "Inset")
	local bars = {}
	for k = 1, N do
		local b = new("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new((k - 1) / N, 1, 1, -1),
			Size = UDim2.new(1 / N, -2, 0, 1),
			BorderSizePixel = 0,
		}, area)
		win:_bind(b, "BackgroundColor3", "Accent")
		bars[k] = b
	end
	local defaults = { FPS = { 120, " fps" }, Ping = { 300, " ms" }, Memory = { 1500, " MB" }, Frame = { 40, " ms" } }
	local top = o.Max or (defaults[source] and defaults[source][1]) or 100
	local suffix = o.Suffix or (defaults[source] and defaults[source][2]) or ""
	local samples = {}
	for k = 1, N do
		samples[k] = 0
	end
	local fpsAvg = 60
	local function read(dt)
		if type(source) == "function" then
			local ok, v = pcall(source)
			return ok and tonumber(v) or 0
		elseif source == "FPS" then
			fpsAvg = fpsAvg * 0.7 + (1 / math.max(dt, 1e-3)) * 0.3
			return math.floor(fpsAvg + 0.5)
		elseif source == "Frame" then
			return math.floor(dt * 10000 + 0.5) / 10
		elseif source == "Ping" then
			local ok, v = pcall(function()
				return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			return ok and math.floor((tonumber(v) or 0) + 0.5) or 0
		elseif source == "Memory" then
			local ok, v = pcall(function()
				return game:GetService("Stats"):GetTotalMemoryUsageMb()
			end)
			return ok and math.floor((tonumber(v) or 0) + 0.5) or 0
		end
		return 0
	end
	local acc, dtSum, cnt = 0, 0, 0
	local function draw()
		local peak = top
		for _, v in ipairs(samples) do
			if v > peak then
				peak = v
			end
		end
		for k = 1, N do
			bars[k].Size = UDim2.new(1 / N, -2, math.clamp(samples[k] / peak, 0.02, 1), 0)
		end
		val.Text = tostring(samples[N]) .. suffix
	end
	local obj = {}
	function obj:Push(v)
		table.remove(samples, 1)
		table.insert(samples, tonumber(v) or 0)
		draw()
	end
	function obj:Get()
		return samples[N]
	end
	function obj:Set() end
	table.insert(win._frame, function(_, dt)
		acc += dt
		dtSum += dt
		cnt += 1
		if acc >= (o.Interval or 0.25) then
			local avg = dtSum / math.max(cnt, 1)
			acc, dtSum, cnt = 0, 0, 0
			if win.Open and self.Page.Visible and row.Visible then
				obj:Push(read(avg))
			end
		end
	end)
	draw()
	return register(self, o, obj, "Graph")
end

-- ============================================================ code box (type or paste a script and run it)
function Tab:CodeBox(o)
	-- Name, Height (110), Default, Placeholder, RunText ("Run"), Callback(code). Without a Callback it runs the code with loadstring.
	o = o or {}
	local win = self.Win
	local H = o.Height or 110
	local row = self:_row(H + 66)
	local name = label(row, o.Name or "Code", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(0.6, -10, 0, 16)
	local count = label(row, "1 line", 9, C.Dim, false)
	count.TextXAlignment = Enum.TextXAlignment.Right
	count.Position = UDim2.new(0.6, 0, 0, 5)
	count.Size = UDim2.new(0.4, -10, 0, 16)
	local box = new("TextBox", {
		Position = UDim2.fromOffset(8, 25),
		Size = UDim2.new(1, -16, 0, H),
		BorderSizePixel = 0,
		Text = o.Default or "",
		PlaceholderText = o.Placeholder or "-- type or paste Lua here",
		PlaceholderColor3 = C.Dim,
		TextColor3 = C.Text,
		TextSize = 10,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = false,
		MultiLine = true,
		ClearTextOnFocus = false,
		ClipsDescendants = true,
	}, row)
	corner(box, 6)
	new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 6) }, box)
	win:_bind(box, "BackgroundColor3", "Inset")
	local function lines()
		local _, n = box.Text:gsub("\n", "")
		count.Text = (n + 1) .. (n == 0 and " line" or " lines")
	end
	box:GetPropertyChangedSignal("Text"):Connect(lines)
	lines()
	local obj = {}
	function obj:Get()
		return box.Text
	end
	function obj:Set(v)
		box.Text = tostring(v)
	end
	function obj:Run()
		local code = box.Text
		if o.Callback then
			safe(o.Callback, code)
			return
		end
		if type(loadstring) ~= "function" then
			win:Notify({ Title = "Can't run", Text = "This executor has no loadstring.", Type = "error" })
			return
		end
		local fn, err = loadstring(code)
		if not fn then
			win:Notify({ Title = "Syntax error", Text = tostring(err), Type = "error" })
			win:Log(tostring(err), "error")
			return
		end
		local ok, e = pcall(fn)
		win:Notify({ Title = ok and "Ran" or "Error", Text = ok and "The code ran without errors." or tostring(e), Type = ok and "success" or "error" })
		win:Log(ok and "ran ok" or tostring(e), ok and "success" or "error")
	end
	local function btn(txt, x, w, accent, fn)
		local b = new("TextButton", {
			Position = UDim2.new(x, accent and 8 or 4, 0, H + 31),
			Size = UDim2.new(w, -12, 0, 26),
			BorderSizePixel = 0,
			Text = txt,
			TextSize = 11,
			TextColor3 = C.Text,
			Font = Enum.Font.GothamBold,
			AutoButtonColor = false,
		}, row)
		corner(b, 7)
		win:_bind(b, "BackgroundColor3", accent and "Accent" or "Inset")
		b.MouseButton1Click:Connect(function()
			win:_playClick()
			fn()
		end)
	end
	btn(o.RunText or "Run", 0, 0.5, true, function()
		obj:Run()
	end)
	btn("Clear", 0.5, 0.5, false, function()
		box.Text = ""
	end)
	return register(self, o, obj, "CodeBox")
end

-- ============================================================ feed (text that is loaded from a web page, like announcements)
function Tab:Feed(o)
	-- Title, Url (a plain text page, like a raw GitHub file), Text (shown while loading or if it fails), MaxChars (800). obj:Refresh()
	o = o or {}
	local obj = self:Paragraph({ Title = o.Title or "News", Text = o.Text or "Loading..." })
	function obj:Refresh()
		if not o.Url then
			return
		end
		task.spawn(function()
			local ok, body = pcall(function()
				return game:HttpGet(o.Url)
			end)
			if ok and type(body) == "string" and body ~= "" then
				body = body:gsub("\r", "")
				if #body > (o.MaxChars or 800) then
					body = body:sub(1, o.MaxChars or 800) .. "..."
				end
				obj:Set(nil, body)
			else
				obj:Set(nil, o.Text or "Could not load the news.")
			end
		end)
	end
	obj:Refresh()
	return obj
end

-- ============================================================ chat (messages, typing text, quick replies, input box)
local function chatRich(s)
	-- a little markdown: **bold**, `code`, "- " bullets, "# " headings. Everything else is escaped.
	s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
	s = s:gsub("%*%*(.-)%*%*", "<b>%1</b>")
	s = s:gsub("`([^`\n]+)`", '<font face="Code" color="#ffb59e">%1</font>')
	s = s:gsub("^%- ", "• "):gsub("\n%- ", "\n• "):gsub("\n%* ", "\n• ")
	s = s:gsub("\n#+ ([^\n]+)", "\n<b>%1</b>"):gsub("^#+ ([^\n]+)", "<b>%1</b>")
	return s
end

local function chatSegments(text)
	local out, pos = {}, 1
	while true do
		local a, b, _, code = text:find("```(%w*)\n?(.-)```", pos)
		if not a then
			break
		end
		if a > pos then
			table.insert(out, { false, text:sub(pos, a - 1) })
		end
		table.insert(out, { true, (code:gsub("\n+$", "")) })
		pos = b + 1
	end
	if pos <= #text then
		table.insert(out, { false, text:sub(pos) })
	end
	local clean = {}
	for _, seg in ipairs(out) do
		local t = seg[2]
		if not seg[1] then
			t = t:gsub("^%s+", ""):gsub("%s+$", "")
		end
		if t ~= "" then
			table.insert(clean, { seg[1], t })
		end
	end
	return clean
end

function Tab:Chat(o)
	-- Name (the bot's name), Height (260), Placeholder, MaxMessages (60), Chips = true,
	-- OnSend(text, chat) when the player sends something, Actions = { { Name = "Speak", Callback = function(text) end } }
	-- chat:Add("user" | "bot" | "system", text, { Instant = true }) -> message, chat:SetStatus(text), chat:SetChips({...}),
	-- chat:SetBusy(bool), chat:Submit(text), chat:Clear(), chat:GetMessages()
	o = o or {}
	local win = self.Win
	local H = o.Height or 260
	local botName = o.Name or "Bot"
	local row = self:_row(H)
	local INPUT, CHIPS, STATUS = 34, 26, 16
	local reserve = 6 + INPUT + 6 + CHIPS + 2 + STATUS + 4
	local list = new("ScrollingFrame", {
		Position = UDim2.fromOffset(6, 6),
		Size = UDim2.new(1, -12, 1, -reserve - 6),
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, row)
	corner(list, 8)
	win:_bind(list, "BackgroundColor3", "Inset")
	win:_bind(list, "ScrollBarImageColor3", "Accent")
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 8) }, list)

	local statusL = label(row, "", 10, C.Dim, true)
	statusL.Position = UDim2.new(0, 10, 1, -(6 + INPUT + 6 + CHIPS + 2 + STATUS))
	statusL.Size = UDim2.new(1, -20, 0, STATUS)
	win:_bind(statusL, "TextColor3", "Glow")

	local chipBox = new("ScrollingFrame", {
		Position = UDim2.new(0, 6, 1, -(6 + INPUT + 6 + CHIPS)),
		Size = UDim2.new(1, -12, 0, CHIPS),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
	}, row)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	}, chipBox)

	local box = new("TextBox", {
		Position = UDim2.new(0, 6, 1, -(6 + INPUT)),
		Size = UDim2.new(1, -78, 0, INPUT),
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = o.Placeholder or "Type a message...",
		PlaceholderColor3 = C.Dim,
		TextColor3 = C.Text,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	}, row)
	corner(box, 9)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 8) }, box)
	win:_bind(box, "BackgroundColor3", "Inset")
	local send = new("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 1, -(6 + INPUT)),
		Size = UDim2.fromOffset(64, INPUT),
		BorderSizePixel = 0,
		Text = "Send",
		TextColor3 = C.White,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
	}, row)
	corner(send, 9)
	local sg = new("UIGradient", {}, send)
	win:_onTheme(function(t)
		sg.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
	end)

	local obj = { Messages = {}, Busy = false }
	local n = 0
	local function toBottom()
		list.CanvasPosition = Vector2.new(0, 1e7)
	end

	-- one message bubble. role: "user" (right), "bot" (left), "system" (centered, small)
	function obj:Add(role, text, opt)
		opt = opt or {}
		text = tostring(text or "")
		n += 1
		local isUser, isSys = role == "user", role == "system"
		local wrap = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = n,
		}, list)
		new("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = isUser and Enum.HorizontalAlignment.Right or (isSys and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left),
		}, wrap)
		if not isSys then
			local who = label(wrap, isUser and (opt.Name or "You") or (opt.Name or botName), 8, C.Dim, true)
			who.Size = UDim2.new(1, 0, 0, 11)
			who.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
			who.LayoutOrder = 1
		end
		local bub = new("Frame", {
			Size = UDim2.new(isSys and 1 or 0.9, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			BackgroundTransparency = isSys and 1 or 0,
			LayoutOrder = 2,
		}, wrap)
		corner(bub, 10)
		if isUser then
			win:_bind(bub, "BackgroundColor3", "Accent")
		else
			win:_bind(bub, "BackgroundColor3", "Item")
		end
		new("UIPadding", {
			PaddingTop = UDim.new(0, isSys and 0 or 6),
			PaddingBottom = UDim.new(0, isSys and 0 or 7),
			PaddingLeft = UDim.new(0, isSys and 0 or 9),
			PaddingRight = UDim.new(0, isSys and 0 or 9),
		}, bub)
		new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, bub)

		local msg = { Role = role, Text = text, Frame = wrap }
		local reveal = {}
		local function build(t)
			for _, c in ipairs(bub:GetChildren()) do
				if c:IsA("GuiObject") then
					c:Destroy()
				end
			end
			table.clear(reveal)
			local k = 0
			for _, seg in ipairs(isUser and { { false, t } } or chatSegments(t)) do
				k += 1
				if seg[1] then
					local cf = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, LayoutOrder = k }, bub)
					corner(cf, 7)
					win:_bind(cf, "BackgroundColor3", "Inset")
					new("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }, cf)
					new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, cf)
					local top = new("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 1 }, cf)
					local tag = label(top, "lua", 8, C.Dim, true)
					tag.Size = UDim2.new(0.5, 0, 1, 0)
					local cp = new("TextButton", {
						AnchorPoint = Vector2.new(1, 0),
						Position = UDim2.new(1, 0, 0, 0),
						Size = UDim2.fromOffset(46, 16),
						BorderSizePixel = 0,
						Text = "Copy",
						TextSize = 9,
						TextColor3 = C.Text,
						Font = Enum.Font.GothamBold,
						AutoButtonColor = false,
					}, top)
					corner(cp, 5)
					win:_bind(cp, "BackgroundColor3", "Item")
					cp.MouseButton1Click:Connect(function()
						local ok = type(setclipboard) == "function" and pcall(setclipboard, seg[2])
						cp.Text = ok and "Copied" or "No clip"
						task.delay(1.4, function()
							if cp.Parent then
								cp.Text = "Copy"
							end
						end)
					end)
					local cl = new("TextLabel", {
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						Text = seg[2],
						TextSize = 9,
						Font = Enum.Font.Code,
						TextColor3 = C.Text,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextWrapped = true,
						LayoutOrder = 2,
					}, cf)
					table.insert(reveal, { obj = cf, code = true, len = #seg[2] })
				else
					local tl = new("TextLabel", {
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						RichText = true,
						Text = isUser and (t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) or chatRich(seg[2]),
						TextSize = isSys and 9 or 11,
						Font = Enum.Font.Gotham,
						TextColor3 = isSys and C.Dim or (isUser and C.White or C.Text),
						TextXAlignment = isSys and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
						TextWrapped = true,
						LayoutOrder = k,
					}, bub)
					table.insert(reveal, { obj = tl, code = false, len = #(seg[2]:gsub("[%*`#]", "")) })
				end
			end
		end
		build(text)
		function msg:Set(t)
			self.Text = tostring(t)
			build(self.Text)
			toBottom()
		end
		-- the typing effect: the text appears quickly, a few seconds at most
		function msg:Type(speed)
			local total = 0
			for _, r in ipairs(reveal) do
				total += r.len
			end
			if total == 0 then
				return
			end
			local cps = math.max(speed or 70, total / 2.4)
			local shown, done = 0, false
			local labels = {}
			for _, r in ipairs(reveal) do
				if r.code then
					r.obj.Visible = false
				else
					r.obj.MaxVisibleGraphemes = 0
				end
				table.insert(labels, r)
			end
			local fn
			fn = function(_, dt)
				shown += cps * dt
				local left = shown
				for _, r in ipairs(labels) do
					if r.code then
						r.obj.Visible = left > 0
						left -= r.len
					else
						local take = math.clamp(left, 0, r.len)
						r.obj.MaxVisibleGraphemes = take >= r.len and -1 or math.floor(take)
						left -= r.len
					end
				end
				toBottom()
				if shown >= total or not wrap.Parent then
					for _, r in ipairs(labels) do
						if r.code then
							r.obj.Visible = true
						else
							r.obj.MaxVisibleGraphemes = -1
						end
					end
					local at = table.find(win._frame, fn)
					if at then
						table.remove(win._frame, at)
					end
				end
			end
			table.insert(win._frame, fn)
		end
		-- small buttons under a bot message: Copy + your own (Speak ...)
		if role == "bot" and opt.Actions ~= false then
			local acts = new("Frame", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, LayoutOrder = 3 }, wrap)
			new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, acts)
			local function mini(txt, order, fn)
				local b = new("TextButton", {
					Size = UDim2.fromOffset(#txt * 5.4 + 16, 16),
					BorderSizePixel = 0,
					Text = txt,
					TextSize = 8,
					TextColor3 = C.Dim,
					Font = Enum.Font.GothamBold,
					AutoButtonColor = false,
					LayoutOrder = order,
				}, acts)
				corner(b, 8)
				win:_bind(b, "BackgroundColor3", "Item")
				b.MouseButton1Click:Connect(function()
					fn(b)
				end)
			end
			mini("Copy", 1, function(b)
				local ok = type(setclipboard) == "function" and pcall(setclipboard, msg.Text)
				b.Text = ok and "Copied" or "No clip"
				task.delay(1.4, function()
					if b.Parent then
						b.Text = "Copy"
					end
				end)
			end)
			for i, a in ipairs(o.Actions or {}) do
				mini(tostring(a.Name), 1 + i, function()
					safe(a.Callback, msg.Text, msg)
				end)
			end
		end
		table.insert(obj.Messages, msg)
		while #obj.Messages > (o.MaxMessages or 60) do
			local old = table.remove(obj.Messages, 1)
			old.Frame:Destroy()
		end
		toBottom()
		if role == "bot" and not opt.Instant and opt.Type ~= false then
			msg:Type(opt.Speed)
		end
		return msg
	end

	-- the line above the chips: "Thinking..." with moving dots (SetStatus(nil) hides it)
	local statusText, statusT0 = nil, 0
	function obj:SetStatus(text)
		statusText = text
		statusT0 = os.clock()
		statusL.Text = text and tostring(text) or ""
	end
	table.insert(win._frame, function(now)
		if statusText then
			local dots = string.rep(".", math.floor((now - statusT0) * 3) % 4)
			statusL.Text = statusText .. dots
			statusL.TextTransparency = 0.15 + 0.25 * (0.5 + 0.5 * math.sin(now * 5))
		elseif statusL.TextTransparency ~= 0 then
			statusL.TextTransparency = 0
		end
	end)

	function obj:SetChips(chips)
		for _, c in ipairs(chipBox:GetChildren()) do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		for i, text in ipairs(chips or {}) do
			if i > 8 then
				break
			end
			local b = new("TextButton", {
				Size = UDim2.fromOffset(0, 22),
				AutomaticSize = Enum.AutomaticSize.X,
				BorderSizePixel = 0,
				Text = tostring(text),
				TextSize = 10,
				Font = Enum.Font.GothamMedium,
				AutoButtonColor = false,
				LayoutOrder = i,
			}, chipBox)
			corner(b, 11)
			new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, b)
			win:_bind(b, "BackgroundColor3", "Item")
			win:_bind(b, "TextColor3", "Glow")
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				obj:Submit(tostring(text))
			end)
		end
		chipBox.CanvasPosition = Vector2.new(0, 0)
	end

	function obj:SetBusy(v)
		self.Busy = v == true
		send.Text = self.Busy and "..." or "Send"
		send.BackgroundTransparency = self.Busy and 0.5 or 0
	end

	function obj:Submit(text)
		text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if text == "" then
			return false
		end
		if self.Busy and not o.AllowWhileBusy then
			win:Notify({ Title = botName, Text = "One moment, I'm still on your last message.", Type = "warn", Duration = 2 })
			return false
		end
		self:Add("user", text)
		safe(o.OnSend, text, self)
		return true
	end

	function obj:Clear()
		for _, m in ipairs(self.Messages) do
			m.Frame:Destroy()
		end
		self.Messages = {}
	end
	function obj:GetMessages()
		return self.Messages
	end
	function obj:Get()
		return #self.Messages
	end
	function obj:Set() end
	function obj:Focus()
		box:CaptureFocus()
	end

	local function fromBox()
		local t = box.Text
		if t:gsub("%s", "") ~= "" and obj:Submit(t) then
			box.Text = ""
		end
	end
	send.MouseButton1Click:Connect(function()
		win:_playClick()
		fromBox()
	end)
	box.FocusLost:Connect(function(enter)
		if enter then
			fromBox()
		end
	end)
	return register(self, o, obj, "Chat")
end


function Tab:Choice(o)
	-- Name, Options, Default (false = none chosen), Flag, Callback(choice): a bar of buttons where one is chosen
	o = o or {}
	local win = self.Win
	local options = o.Options or {}
	local n = math.max(#options, 1)
	local row = self:_row(58)
	local name = label(row, o.Name or "Choice", 11, C.Text, true)
	name.Position = UDim2.fromOffset(10, 5)
	name.Size = UDim2.new(1, -20, 0, 14)
	local bar = new("Frame", {
		Position = UDim2.fromOffset(10, 24),
		Size = UDim2.new(1, -20, 0, 26),
		BorderSizePixel = 0,
	}, row)
	corner(bar, 8)
	win:_bind(bar, "BackgroundColor3", "Inset")
	local obj = { Value = nil }
	local buttons = {}
	local function render()
		local t = win.Theme
		for choice, b in pairs(buttons) do
			local on = choice == obj.Value
			b.BackgroundColor3 = t.Accent
			tween(b, 0.15, {
				BackgroundTransparency = on and 0 or 1,
				TextColor3 = on and C.White or C.Dim,
			})
		end
	end
	for i, choice in ipairs(options) do
		local b = new("TextButton", {
			Position = UDim2.new((i - 1) / n, 2, 0, 2),
			Size = UDim2.new(1 / n, -4, 1, -4),
			BackgroundTransparency = 1,
			Text = tostring(choice),
			TextSize = 10,
			Font = Enum.Font.GothamBold,
			TextColor3 = C.Dim,
			AutoButtonColor = false,
		}, bar)
		corner(b, 6)
		buttons[choice] = b
		b.MouseButton1Click:Connect(function()
			win:_playClick()
			obj:Set(choice)
		end)
	end
	function obj:Set(choice, silent)
		if buttons[choice] == nil then
			return
		end
		local changed = self.Value ~= choice
		self.Value = choice
		render()
		if changed and not silent then
			safe(o.Callback, choice)
		end
	end
	function obj:Get()
		return self.Value
	end
	if o.Default == false then
		obj.Value = nil -- nothing chosen yet
	else
		obj.Value = o.Default ~= nil and buttons[o.Default] and o.Default or options[1]
	end
	win:_onTheme(render)
	return register(self, o, obj, "Choice")
end

function Tab:Stepper(o)
	-- Name, Description, Min, Max, Step, Default, Flag, Suffix, Callback(value): a number with - and + buttons (hold to repeat)
	o = o or {}
	local win = self.Win
	local mn, mx, step = o.Min or 0, o.Max or 100, o.Step or 1
	local hasDesc = o.Description ~= nil
	local row = self:_row(hasDesc and 40 or 34)
	local name = label(row, o.Name or "Stepper", 11, C.Text, true)
	name.Position = UDim2.new(0, 10, 0, hasDesc and 6 or 0)
	name.Size = UDim2.new(1, -160, 0, hasDesc and 14 or 34)
	if hasDesc then
		local d = label(row, o.Description, 8, C.Dim, false)
		d.Position = UDim2.fromOffset(10, 22)
		d.Size = UDim2.new(1, -160, 0, 11)
	end
	local valueL = new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(60, 20), Position = UDim2.new(1, -98, 0.5, -10), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.Text }, row)
	local obj = { Value = math.clamp(o.Default or mn, mn, mx) }
	local function render()
		valueL.Text = tostring(obj.Value) .. (o.Suffix or "")
	end
	function obj:Set(v, silent)
		v = tonumber(v)
		if not v then
			return
		end
		v = math.clamp(math.floor((v - mn) / step + 0.5) * step + mn, mn, mx)
		v = math.floor(v * 1000 + 0.5) / 1000
		local changed = v ~= obj.Value
		obj.Value = v
		render()
		if changed and not silent then
			win:_playClick()
			safe(o.Callback, v)
		end
	end
	function obj:Get()
		return obj.Value
	end
	local function btn(txt, x, dir)
		local b = new("TextButton", { Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, x, 0.5, -12), BackgroundColor3 = C.White, Text = "", AutoButtonColor = false }, row)
		corner(b, 7)
		local g = new("UIGradient", { Rotation = 90 }, b)
		new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = txt, TextColor3 = C.White, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 2 }, b)
		win:_onTheme(function(t)
			g.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
		end)
		local held = 0
		b.MouseButton1Down:Connect(function()
			held += 1
			local me = held
			obj:Set(obj.Value + dir * step)
			task.delay(0.4, function()
				while held == me and b.Parent do
					obj:Set(obj.Value + dir * step)
					task.wait(0.07)
				end
			end)
		end)
		local function release()
			held += 1
		end
		b.MouseButton1Up:Connect(release)
		b.MouseLeave:Connect(release)
	end
	btn("-", -126, -1)
	btn("+", -34, 1)
	render()
	return register(self, o, obj, "Stepper")
end

function Tab:Rating(o)
	-- Name, Max (default 5), Default, Flag, Callback(stars): tap a star to rate (tap the same star again to clear)
	o = o or {}
	local win = self.Win
	local max = o.Max or 5
	local row = self:_row(40)
	local name = label(row, o.Name or "Rating", 11, C.Text, true)
	name.Position = UDim2.new(0, 10, 0, 0)
	name.Size = UDim2.new(1, -20 - max * 26, 1, 0)
	local obj = { Value = math.clamp(o.Default or 0, 0, max) }
	local stars = {}
	local function render()
		for i, s in ipairs(stars) do
			tween(s, 0.15, { ImageTransparency = i <= obj.Value and 0 or 0.8, Size = i <= obj.Value and UDim2.fromOffset(22, 22) or UDim2.fromOffset(18, 18) })
		end
	end
	function obj:Set(v, silent)
		obj.Value = math.clamp(math.floor(tonumber(v) or 0), 0, max)
		render()
		if not silent then
			win:_playClick()
			safe(o.Callback, obj.Value)
		end
	end
	function obj:Get()
		return obj.Value
	end
	for i = 1, max do
		local s = new("ImageButton", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -(max - i) * 26 - 22, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1, Image = asset(RebelUI.Icons.star), ScaleType = Enum.ScaleType.Fit, AutoButtonColor = false, ImageTransparency = 0.8 }, row)
		RebelUI._iconFix(s, RebelUI.Icons.star)
		stars[i] = s
		s.MouseButton1Click:Connect(function()
			obj:Set(obj.Value == i and 0 or i)
		end)
	end
	render()
	return register(self, o, obj, "Rating")
end

function Tab:Countdown(o)
	-- Name, Seconds, AutoStart, Loop, Flag, Callback(): a live timer with a bar. obj:Start() / Pause() / Reset(seconds) / Get() = seconds left
	o = o or {}
	local win = self.Win
	local total = o.Seconds or 30
	local row = self:_row(44)
	local name = label(row, o.Name or "Timer", 11, C.Text, true)
	name.Position = UDim2.new(0, 10, 0, 4)
	name.Size = UDim2.new(1, -140, 0, 16)
	local barBg = new("Frame", { Position = UDim2.new(0, 10, 1, -14), Size = UDim2.new(1, -140, 0, 6), BackgroundColor3 = Color3.fromRGB(40, 24, 28), BorderSizePixel = 0 }, row)
	corner(barBg, 3)
	local bar = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.White, BorderSizePixel = 0 }, barBg)
	corner(bar, 3)
	win:_onTheme(function(t)
		bar.BackgroundColor3 = t.Accent
	end)
	local timeL = new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(60, 20), Position = UDim2.new(1, -128, 0.5, -10), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.Text }, row)
	local btn = new("TextButton", { Size = UDim2.fromOffset(52, 24), Position = UDim2.new(1, -62, 0.5, -12), BackgroundColor3 = C.White, Text = "Start", TextColor3 = C.White, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false }, row)
	corner(btn, 7)
	local g = new("UIGradient", { Rotation = 90 }, btn)
	win:_onTheme(function(t)
		g.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
	end)
	local obj = { Left = total, Running = false }
	local gen = 0
	local function render()
		local m, sec = math.floor(obj.Left / 60), math.ceil(obj.Left % 60)
		if sec == 60 then
			m, sec = m + 1, 0
		end
		timeL.Text = string.format("%d:%02d", m, sec)
		bar.Size = UDim2.fromScale(math.clamp(total > 0 and obj.Left / total or 0, 0, 1), 1)
		btn.Text = obj.Running and "Pause" or (obj.Left <= 0 and "Again" or "Start")
	end
	function obj:Start()
		if obj.Running then
			return
		end
		if obj.Left <= 0 then
			obj.Left = total
		end
		obj.Running = true
		gen += 1
		local me = gen
		render()
		task.spawn(function()
			local last = os.clock()
			while obj.Running and gen == me and row.Parent do
				task.wait(0.1)
				if not obj.Running or gen ~= me then
					break
				end
				local now = os.clock()
				obj.Left = math.max(0, obj.Left - (now - last))
				last = now
				render()
				if obj.Left <= 0 then
					obj.Running = false
					render()
					safe(o.Callback)
					if o.Loop then
						obj.Left = total
						obj:Start()
					end
				end
			end
		end)
	end
	function obj:Pause()
		obj.Running = false
		gen += 1
		render()
	end
	function obj:Reset(sec)
		total = sec or total
		obj.Running = false
		gen += 1
		obj.Left = total
		render()
	end
	function obj:Get()
		return obj.Left
	end
	btn.MouseButton1Click:Connect(function()
		win:_playClick()
		if obj.Running then
			obj:Pause()
		else
			obj:Start()
		end
	end)
	render()
	if o.AutoStart then
		obj:Start()
	end
	return register(self, o, obj, "Countdown")
end

function Tab:Cycle(o)
	-- Name, Description, Options, Default (name or number), Flag, Callback(choice, index): the "<  option  >" picker
	o = o or {}
	local win = self.Win
	local options = o.Options or { "-" }
	local hasDesc = o.Description ~= nil
	local row = self:_row(hasDesc and 40 or 34)
	local name = label(row, o.Name or "Cycle", 11, C.Text, true)
	name.Position = UDim2.new(0, 10, 0, hasDesc and 6 or 0)
	name.Size = UDim2.new(1, -150, 0, hasDesc and 14 or 34)
	if hasDesc then
		local d = label(row, o.Description, 8, C.Dim, false)
		d.Position = UDim2.fromOffset(10, 22)
		d.Size = UDim2.new(1, -150, 0, 11)
	end
	local valueL = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(64, 20),
		Position = UDim2.new(1, -102, 0.5, -10),
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = C.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	local obj = { Index = 1 }
	local function render()
		valueL.Text = tostring(options[obj.Index])
	end
	function obj:Set(v, silent)
		local idx = type(v) == "number" and v or table.find(options, v)
		if not idx then
			return
		end
		obj.Index = ((idx - 1) % #options) + 1
		render()
		if not silent then
			win:_playClick()
			safe(o.Callback, options[obj.Index], obj.Index)
		end
	end
	function obj:Get()
		return options[obj.Index]
	end
	local function arrow(txt, x, dir)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.new(1, x, 0.5, -12),
			BackgroundColor3 = C.White,
			Text = "",
			AutoButtonColor = false,
		}, row)
		corner(b, 7)
		local g = new("UIGradient", { Rotation = 90 }, b)
		new("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = txt,
			TextColor3 = C.White,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			ZIndex = 2,
		}, b)
		win:_onTheme(function(t)
			g.Color = ColorSequence.new(t.Accent, t.Dark:Lerp(t.Accent, 0.35))
		end)
		b.MouseButton1Click:Connect(function()
			obj:Set(obj.Index + dir)
		end)
	end
	arrow("<", -134, -1)
	arrow(">", -34, 1)
	if o.Default ~= nil then
		local idx = type(o.Default) == "number" and o.Default or table.find(options, o.Default)
		obj.Index = idx or 1
	end
	render()
	return register(self, o, obj, "Cycle")
end

-- ============================================================ top bar (FPS, logo, timer and more)
local BAR_ORDER = { "FPS", "Ping", "Logo", "Title", "Timer", "Clock", "Players", "Memory", "Executor", "Game" }
local BAR_PRESETS = {
	Classic = { "FPS", "Logo", "Timer" },
	Minimal = { "Logo" },
	Gamer = { "FPS", "Ping", "Clock" },
	Info = { "Logo", "Title", "Players", "Executor" },
	Full = { "FPS", "Ping", "Logo", "Title", "Timer", "Clock", "Players", "Memory", "Executor", "Game" },
}
RebelUI.BarItems = BAR_ORDER
RebelUI.BarPresets = { "Classic", "Minimal", "Gamer", "Info", "Full" }

local function readPing()
	local ok, v = pcall(function()
		return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	return ok and tonumber(v) and math.floor(v + 0.5) or 0
end

local function readMemory()
	local ok, v = pcall(function()
		return game:GetService("Stats"):GetTotalMemoryUsageMb()
	end)
	return ok and tonumber(v) and math.floor(v + 0.5) or 0
end

local function readExecutor()
	local ok, v = pcall(function()
		return identifyexecutor()
	end)
	return ok and tostring(v) or "Unknown"
end

function Window:CreateBar(o)
	-- Items = { "FPS", "Logo", "Timer" } (any of RebelUI.BarItems), Preset = "Classic", Logo = asset id,
	-- Visible, Position (UDim2). Tap the bar to open or close the panel; drag it to move it.
	o = o or {}
	local win = self
	local bar = { Visible = o.Visible ~= false }
	local items = {}
	local logo = o.Logo or o.Icon
	local started = os.clock()
	local fps, frames, acc = 60, 0, 0
	local gameName = tostring(game.Name or "Game")
	local defaultPos = o.Position or UDim2.new(0.5, 0, 0, 12)

	task.spawn(function()
		local ok, info = pcall(function()
			return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
		end)
		if ok and info and info.Name then
			gameName = info.Name
		end
	end)

	-- thin black ring around the bar, then the bar with its own spinning ring
	local outer = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = defaultPos,
		Size = UDim2.new(0, 0, 0, 36),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = bar.Visible,
		ZIndex = 9,
	}, win.Gui)
	corner(outer, 19)
	new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1 }, outer)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 1),
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 1),
		PaddingRight = UDim.new(0, 1),
	}, outer)
	local frame = new("Frame", {
		Size = UDim2.new(0, 0, 0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 10,
	}, outer)
	corner(frame, 17)
	local barG = new("UIGradient", {}, frame)
	local ring = new("UIStroke", { Thickness = 1 }, frame)
	win:_ring(ring)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, frame)
	new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, frame)
	local intro = new("UIScale", { Scale = 0.7 }, outer)
	tween(intro, 0.5, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	win._hasBar = true
	win._fab.Visible = false
	win._bar = bar
	win._barOpts = o

	local texts = {} -- item name -> TextLabel whose text is refreshed
	local seps = {}
	local function accentHex()
		return toHex(win.Theme.Glow)
	end
	local function line(name, value)
		return string.format('<font color="#A58C90">%s</font> <font color="%s">%s</font>', name, accentHex(), tostring(value))
	end
	local function timer()
		local s = math.floor(os.clock() - started)
		return string.format("%02d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
	end
	local function players()
		local ok, v = pcall(function()
			return #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		end)
		return ok and v or "1/1"
	end
	local function valueOf(name)
		if name == "FPS" then
			return line("FPS", math.floor(fps + 0.5))
		elseif name == "Ping" then
			return line("Ping", readPing() .. "ms")
		elseif name == "Timer" then
			return line("Time", timer())
		elseif name == "Clock" then
			return line("Clock", os.date("%H:%M"))
		elseif name == "Players" then
			return line("Players", players())
		elseif name == "Memory" then
			return line("Mem", readMemory() .. "MB")
		elseif name == "Executor" then
			return line("Exec", readExecutor())
		elseif name == "Game" then
			local g = gameName
			if #g > 18 then
				g = g:sub(1, 17) .. "..."
			end
			return string.format('<font color="%s">%s</font>', accentHex(), g)
		elseif name == "Title" then
			return string.format('<font color="#F0EBEB"><b>%s</b></font>', tostring(o.Title or win.TitleText or "Rebelwar"))
		end
		return ""
	end
	local function refresh()
		for name, l in pairs(texts) do
			l.Text = valueOf(name)
		end
		for _, s in ipairs(seps) do
			s.BackgroundColor3 = win.Theme.Glow
		end
	end

	local function rebuild()
		for _, c in ipairs(frame:GetChildren()) do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		texts, seps = {}, {}
		local order = 0
		for _, name in ipairs(BAR_ORDER) do
			if items[name] then
				order += 1
				if order > 1 then
					table.insert(seps, new("Frame", {
						Size = UDim2.fromOffset(2, 16),
						BackgroundTransparency = 0.35,
						BorderSizePixel = 0,
						LayoutOrder = order * 2 - 1,
					}, frame))
				end
				if name == "Logo" then
					if logo then
						local img = new("ImageLabel", {
							Size = UDim2.fromOffset(26, 26),
							BackgroundTransparency = 1,
							ScaleType = Enum.ScaleType.Crop,
							LayoutOrder = order * 2,
						}, frame)
						RebelUI.SetImage(img, logo)
						corner(img, o.LogoShape == "Square" and 6 or 13)
						local ls = new("UIStroke", { Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, img)
						win:_bind(ls, "Color", "Glow")
						pulse(img)
					else
						local r = label(frame, "R", 17, C.Text, true)
						r.TextXAlignment = Enum.TextXAlignment.Center
						r.Size = UDim2.fromOffset(16, 22)
						r.LayoutOrder = order * 2
						win:_bind(r, "TextColor3", "Glow")
					end
				else
					local l = new("TextLabel", {
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.fromOffset(0, 22),
						RichText = true,
						Text = "",
						TextSize = 13,
						Font = Enum.Font.GothamBold,
						TextColor3 = C.Text,
						LayoutOrder = order * 2,
					}, frame)
					texts[name] = l
				end
			end
		end
		refresh()
	end

	function bar:SetItems(list)
		items = {}
		for _, n in ipairs(list or {}) do
			items[n] = true
		end
		rebuild()
		if bar.OnChange then
			safe(bar.OnChange, bar:GetItems())
		end
	end
	function bar:GetItems()
		local out = {}
		for _, n in ipairs(BAR_ORDER) do
			if items[n] then
				table.insert(out, n)
			end
		end
		return out
	end
	function bar:SetPreset(name)
		if BAR_PRESETS[name] then
			bar:SetItems(BAR_PRESETS[name])
		end
	end
	function bar:Add(name)
		items[name] = true
		rebuild()
	end
	function bar:Remove(name)
		items[name] = nil
		rebuild()
	end
	function bar:SetLogo(l)
		logo = l
		rebuild()
	end
	function bar:Show(v)
		bar.Visible = v and true or false
		outer.Visible = bar.Visible
	end
	function bar:ResetPosition()
		outer.Position = defaultPos
	end
	function bar:Destroy()
		outer:Destroy()
		win._hasBar = false
		win._bar = nil
		if not win.Open then
			win._fab.Visible = true
		end
	end
	bar.Frame = outer

	-- drag, and a tap opens or closes the panel
	do
		local down, moved, startPos, startMouse = false, 0, nil, nil
		frame.InputBegan:Connect(function(i)
			if isPress(i) then
				down, moved = true, 0
				startMouse, startPos = i.Position, outer.Position
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
			if down and isMove(i) then
				local d = i.Position - startMouse
				moved = math.max(moved, d.Magnitude)
				if moved > 6 then
					outer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
				end
			end
		end)
		win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
			if down and isPress(i) then
				down = false
				if moved <= 6 then
					win:_playClick()
					win:Toggle()
				end
			end
		end)
	end

	-- live numbers: FPS from Heartbeat, text refreshed twice a second, gradient drifting
	local since = 0
	win._conns[#win._conns + 1] = RunService.Heartbeat:Connect(function(dt)
		frames += 1
		acc += dt
		since += dt
		if acc >= 0.5 then
			fps = frames / acc
			frames, acc = 0, 0
		end
		if since >= 0.5 then
			since = 0
			refresh()
		end
		barG.Offset = Vector2.new(math.sin(os.clock() * 0.8) * 0.25, 0)
	end)

	win:_onTheme(function(t)
		barG.Color = ColorSequence.new(t.B0, t.B1)
		refresh()
	end)

	if o.Items then
		bar:SetItems(o.Items)
	else
		bar:SetPreset(o.Preset or "Classic")
	end
	return bar
end

function Tab:BarSettings(bar, o)
	-- one call adds the controls that let a player choose what the bar shows
	o = o or {}
	self:Section(o.Section or "Top bar")
	self:Toggle({
		Name = "Show top bar",
		Description = "Tap the bar to open or close the panel",
		Default = bar.Visible,
		Callback = function(on)
			bar:Show(on)
		end,
	})
	if o.Preset then
		bar:SetPreset(o.Preset)
	end
	-- show the preset that matches what the bar shows now (none if it is a custom mix)
	local nowItems = table.concat(bar:GetItems(), ",")
	local current = false
	for _, name in ipairs(RebelUI.BarPresets) do
		local want = {}
		for _, n in ipairs(BAR_ORDER) do
			for _, p in ipairs(BAR_PRESETS[name]) do
				if p == n then
					table.insert(want, n)
				end
			end
		end
		if table.concat(want, ",") == nowItems then
			current = name
			break
		end
	end
	local dd
	self:Choice({
		Name = "Bar style",
		Options = RebelUI.BarPresets,
		Default = current,
		Callback = function(name)
			bar:SetPreset(name)
			if dd then
				dd:Set(bar:GetItems(), true)
			end
		end,
	})
	dd = self:Dropdown({
		Name = "Bar items",
		Options = BAR_ORDER,
		Multi = true,
		Default = bar:GetItems(),
		Callback = function(set)
			local list = {}
			for name in pairs(set) do
				table.insert(list, name)
			end
			bar:SetItems(list)
		end,
	})
	return dd
end

-- ============================================================ saving
local function encode(v)
	local t = typeof(v)
	if t == "Color3" then
		return { _t = "c", v = toHex(v) }
	elseif t == "EnumItem" then
		return { _t = "k", v = v.Name }
	elseif t == "table" then
		if v.Low ~= nil and v.High ~= nil then
			return { _t = "r", lo = v.Low, hi = v.High }
		elseif v.X ~= nil and v.Y ~= nil then
			return { _t = "p", x = v.X, y = v.Y }
		end
		local list = {}
		for k, x in pairs(v) do
			if x then
				table.insert(list, k)
			end
		end
		table.sort(list, function(a, b)
			return tostring(a) < tostring(b)
		end)
		return { _t = "m", v = list }
	end
	return v
end

local function decode(v)
	if type(v) == "table" then
		if v._t == "c" then
			return fromHex(v.v)
		elseif v._t == "k" then
			return Enum.KeyCode[v.v]
		elseif v._t == "m" then
			return v.v
		elseif v._t == "r" then
			return { Low = v.lo, High = v.hi }
		elseif v._t == "p" then
			return { X = v.x, Y = v.y }
		end
	end
	return v
end

function Window:_file(file)
	if file then
		return file
	end
	local clean = tostring(self.TitleText):gsub("[^%w]", "")
	return (clean == "" and "RebelUI" or clean) .. "_settings.json"
end

function Window:_collect()
	local data = {}
	for flag, obj in pairs(self.Flags) do
		local ok, v = pcall(function()
			return obj:Get()
		end)
		if ok and v ~= nil then
			data[flag] = encode(v)
		end
	end
	data["__theme"] = self.ThemeName
	return data
end

function Window:Save(file)
	-- saves every element that has a Flag. Needs an executor with writefile. Returns true on success.
	if type(writefile) ~= "function" then
		return false
	end
	local data = self:_collect()
	local ok = pcall(function()
		writefile(self:_file(file), game:GetService("HttpService"):JSONEncode(data))
	end)
	return ok
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64encode(s)
	local out = {}
	for i = 1, #s, 3 do
		local a, b, c = s:byte(i, i + 2)
		local n = a * 65536 + (b or 0) * 256 + (c or 0)
		local c1, c2, c3, c4 = math.floor(n / 262144) % 64, math.floor(n / 4096) % 64, math.floor(n / 64) % 64, n % 64
		out[#out + 1] = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1) .. (b and B64:sub(c3 + 1, c3 + 1) or "=") .. (c and B64:sub(c4 + 1, c4 + 1) or "=")
	end
	return table.concat(out)
end
local function b64decode(s)
	s = s:gsub("[^%w%+/=]", "")
	local out = {}
	for i = 1, #s, 4 do
		local n, pad = 0, 0
		for k = 0, 3 do
			local ch = s:sub(i + k, i + k)
			if ch == "=" or ch == "" then
				n = n * 64
				pad += 1
			else
				local at = B64:find(ch, 1, true)
				if not at then
					return nil
				end
				n = n * 64 + (at - 1)
			end
		end
		local b1, b2, b3 = math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256
		out[#out + 1] = string.char(b1) .. (pad < 2 and string.char(b2) or "") .. (pad < 1 and string.char(b3) or "")
	end
	return table.concat(out)
end

function Window:Export()
	-- every Flag as one short line of text you can share ("RBL1:..."). Window:Import(text) puts it back.
	return "RBL1:" .. b64encode(game:GetService("HttpService"):JSONEncode(self:_collect()))
end

function Window:ExportTheme()
	-- just the look: "RBLT:#RRGGBB"
	return "RBLT:" .. toHex(self.Theme.Accent)
end

function Window:Import(text)
	text = tostring(text):gsub("^%s+", ""):gsub("%s+$", "")
	if text:sub(1, 5) == "RBLT:" then
		local c = fromHex(text:sub(6))
		if c then
			self:SetAccent(c)
			return true
		end
		return false
	end
	if text:sub(1, 5) == "RBL1:" then
		text = b64decode(text:sub(6)) or ""
	end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(text)
	end)
	if not ok or type(data) ~= "table" then
		return false
	end
	self:_apply(data)
	return true
end

function Window:Load(file)
	-- loads what Save wrote and applies it (your Callbacks run). Returns true if a file was found.
	if type(readfile) ~= "function" or type(isfile) ~= "function" then
		return false
	end
	local path = self:_file(file)
	local okExists, exists = pcall(isfile, path)
	if not (okExists and exists) then
		return false
	end
	local ok, data = pcall(function()
		return game:GetService("HttpService"):JSONDecode(readfile(path))
	end)
	if not ok or type(data) ~= "table" then
		return false
	end
	self:_apply(data)
	return true
end

function Window:_apply(data)
	if data["__theme"] and THEMES[data["__theme"]] then
		self:SetTheme(data["__theme"])
	end
	for flag, v in pairs(data) do
		local obj = self.Flags[flag]
		if obj then
			local val = decode(v)
			if val ~= nil then
				pcall(function()
					obj:Set(val)
				end)
			end
		end
	end
	return true
end

-- ============================================================ auto-save, avatar colors, update check, code export
function Window:AutoSave(seconds)
	-- keeps a backup file of all your settings every N seconds. AutoSave(nil) or AutoSave(0) stops it.
	self._autoTok = (self._autoTok or 0) + 1
	local mine = self._autoTok
	seconds = tonumber(seconds)
	self._autoOn = seconds ~= nil and seconds > 0
	if not self._autoOn then
		return
	end
	task.spawn(function()
		while not self._dead and self._autoTok == mine do
			task.wait(math.max(seconds, 5))
			if self._dead or self._autoTok ~= mine then
				return
			end
			self:Save(self:_base() .. "_autosave.json")
		end
	end)
end

function Window:RestoreSnapshot()
	-- brings back the last auto-saved settings
	return self:Load(self:_base() .. "_autosave.json")
end

function Window:ThemeFromAvatar()
	-- makes the accent color from the colors of your avatar. Returns the color, or nil if it can't tell.
	local lp = Players.LocalPlayer
	local ch = lp and lp.Character
	local bc = ch and ch:FindFirstChildOfClass("BodyColors")
	if not bc then
		return nil
	end
	local best, bestS = nil, -1
	for _, prop in ipairs({ "TorsoColor3", "HeadColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3" }) do
		local c = bc[prop]
		if typeof(c) == "Color3" then
			local _, s = c:ToHSV()
			if s > bestS then
				best, bestS = c, s
			end
		end
	end
	if not best then
		return nil
	end
	local h, s, v = best:ToHSV()
	best = Color3.fromHSV(h, math.max(s, 0.45), math.max(v, 0.75))
	self:SetAccent(best)
	return best
end

local function newer(remote, current)
	local function parts(v)
		local t = {}
		for n in tostring(v):gmatch("%d+") do
			table.insert(t, tonumber(n))
		end
		return t
	end
	local a, b = parts(remote), parts(current)
	for i = 1, math.max(#a, #b) do
		local x, y = a[i] or 0, b[i] or 0
		if x ~= y then
			return x > y
		end
	end
	return false
end

function Window:CheckUpdate(o)
	-- Url (a raw page with  Version = "1.2.3"  in it), Current (your version), Silent = true to skip the notification.
	-- Returns isNewer, remoteVersion (or nil, nil if it could not check).
	o = o or {}
	local ok, body = pcall(function()
		return game:HttpGet(o.Url or RebelUI.SourceUrl)
	end)
	if not ok or type(body) ~= "string" then
		if not o.Silent then
			self:Notify({ Title = "Update check", Text = "Could not reach the server.", Type = "warn" })
		end
		return nil, nil
	end
	local remote = body:match('Version%s*=%s*"([%d%.]+)"')
	if not remote then
		return nil, nil
	end
	local isNew = newer(remote, o.Current or RebelUI.Version)
	if not o.Silent then
		self:Notify({
			Title = isNew and "Update available" or "Up to date",
			Text = isNew and ("Version " .. remote .. " is out.") or ("You have the newest version (" .. remote .. ")."),
			Type = isNew and "warn" or "success",
		})
	end
	return isNew, remote
end

local function lit(v)
	local t = typeof(v)
	if t == "string" then
		return string.format("%q", v)
	elseif t == "number" or t == "boolean" then
		return tostring(v)
	elseif t == "Color3" then
		return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(v.R * 255 + 0.5), math.floor(v.G * 255 + 0.5), math.floor(v.B * 255 + 0.5))
	elseif t == "EnumItem" then
		local s = tostring(v)
		return s:find("^Enum%.") and s or ("Enum.KeyCode." .. tostring(v.Name))
	elseif t == "table" then
		local parts = {}
		for _, x in ipairs(v) do
			local s = lit(x)
			if not s then
				return nil
			end
			table.insert(parts, s)
		end
		if #parts == 0 then
			return nil
		end
		return "{ " .. table.concat(parts, ", ") .. " }"
	end
	return nil
end

local STATEFUL = { Toggle = true, Slider = true, Dropdown = true, Input = true, Keybind = true, Color = true, Choice = true, Cycle = true, Stepper = true, Rating = true }

function Window:GenerateCode()
	-- writes the Lua that builds this panel as it is now (names, options, current values). Callbacks are left empty.
	local lines = {
		'local UI = loadstring(game:HttpGet("' .. RebelUI.SourceUrl .. '"))()',
		"",
		"local Win = UI:CreateWindow({",
		"\tTitle = " .. lit(self.TitleText) .. ",",
	}
	if THEMES[self.ThemeName] then
		table.insert(lines, "\tTheme = " .. lit(self.ThemeName) .. ",")
	end
	table.insert(lines, "})")
	local skip = { Callback = true, Changed = true, Flag = false }
	for ti, tab in ipairs(self._tabs) do
		table.insert(lines, "")
		table.insert(lines, "local Tab" .. ti .. " = Win:CreateTab({ Name = " .. lit(tab.Name) .. " })")
		for _, it in ipairs(tab._items or {}) do
			local o, kind = it.o, it.kind
			if kind == "Section" and not o.Collapsible then
				table.insert(lines, "Tab" .. ti .. ":Section(" .. lit(o.Name or "Section") .. ")")
			elseif kind == "Label" then
				table.insert(lines, "Tab" .. ti .. ":Label(" .. lit(o.Text or "") .. ")")
			else
				local keys = {}
				for k, v in pairs(o) do
					if not skip[k] and type(v) ~= "function" and lit(v) and not (k == "Default" and STATEFUL[kind]) then
						table.insert(keys, k)
					end
				end
				if STATEFUL[kind] and it.obj.Get then
					local okg, cur = pcall(function()
						return it.obj:Get()
					end)
					if okg and cur ~= nil then
						if typeof(cur) == "table" and next(cur) ~= nil and type(next(cur)) ~= "number" then
							local pick = {}
							for k, on in pairs(cur) do
								if on == true then
									table.insert(pick, k)
								end
							end
							table.sort(pick)
							cur = pick
						end
						if lit(cur) then
							o = setmetatable({ Default = cur }, { __index = o })
							table.insert(keys, "Default")
						end
					end
				end
				table.sort(keys)
				local parts = {}
				for _, k in ipairs(keys) do
					table.insert(parts, k .. " = " .. lit(o[k]))
				end
				if type(it.o.Callback) == "function" then
					table.insert(parts, "Callback = function() end")
				end
				table.insert(lines, "Tab" .. ti .. ":" .. kind .. "({ " .. table.concat(parts, ", ") .. " })")
			end
		end
	end
	return table.concat(lines, "\n")
end

-- ============================================================ named profiles
-- Several saved setups per script ("Legit", "Rage", ...). Plain files, no folders needed.
local function cleanName(s)
	s = tostring(s or ""):gsub("[^%w _%-]", ""):gsub("^%s+", ""):gsub("%s+$", "")
	return s
end

function Window:_base()
	local clean = tostring(self.TitleText):gsub("[^%w]", "")
	return "RebelUI_" .. (clean == "" and "Script" or clean)
end

function Window:_readIndex()
	local idx = { names = {} }
	if type(readfile) == "function" and type(isfile) == "function" then
		local path = self:_base() .. "_profiles.json"
		local ok, data = pcall(function()
			if isfile(path) then
				return game:GetService("HttpService"):JSONDecode(readfile(path))
			end
		end)
		if ok and type(data) == "table" then
			idx.auto = type(data.auto) == "string" and data.auto or nil
			if type(data.names) == "table" then
				for _, n in ipairs(data.names) do
					if type(n) == "string" then
						table.insert(idx.names, n)
					end
				end
			end
		end
	end
	return idx
end

function Window:_writeIndex(idx)
	if type(writefile) ~= "function" then
		return false
	end
	return (pcall(function()
		writefile(self:_base() .. "_profiles.json", game:GetService("HttpService"):JSONEncode(idx))
	end))
end

function Window:_pfile(name)
	return self:_base() .. "_profile_" .. name .. ".json"
end

function Window:ListProfiles()
	local names = self:_readIndex().names
	table.sort(names, function(a, b)
		return a:lower() < b:lower()
	end)
	return names
end

function Window:SaveProfile(name)
	name = cleanName(name)
	if name == "" then
		return false, "Type a name first."
	end
	if not self:Save(self:_pfile(name)) then
		return false, "This executor can't write files."
	end
	local idx = self:_readIndex()
	if not table.find(idx.names, name) then
		table.insert(idx.names, name)
	end
	self:_writeIndex(idx)
	return true
end

function Window:LoadProfile(name)
	name = cleanName(name)
	if name == "" then
		return false, "Pick a profile first."
	end
	if not self:Load(self:_pfile(name)) then
		return false, "That profile was not found."
	end
	return true
end

function Window:DeleteProfile(name)
	name = cleanName(name)
	local idx = self:_readIndex()
	local at = table.find(idx.names, name)
	if not at then
		return false, "That profile was not found."
	end
	table.remove(idx.names, at)
	if idx.auto == name then
		idx.auto = nil
	end
	pcall(function()
		if type(delfile) == "function" then
			delfile(self:_pfile(name))
		end
	end)
	self:_writeIndex(idx)
	return true
end

function Window:SetAutoLoad(name)
	-- the profile that AutoLoad() applies. nil turns it off.
	local idx = self:_readIndex()
	idx.auto = name and cleanName(name) or nil
	if idx.auto == "" then
		idx.auto = nil
	end
	self:_writeIndex(idx)
	return idx.auto
end

function Window:AutoLoad()
	-- call once after your tabs exist. Applies the auto-load profile (or the plain saved file) if there is one.
	local idx = self:_readIndex()
	if idx.auto and self:Load(self:_pfile(idx.auto)) then
		return idx.auto
	end
	return nil
end

-- ============================================================ ready-made Settings tab
function Window:CreateSettingsTab(o)
	-- Bar = the bar from CreateBar, Icon, Name, File. One call: themes, accent color, size, see-through,
	-- top bar choices, notifications, sound, save / load, reset position and unload.
	o = o or {}
	local win = self
	local tab = win:CreateTab({
		Name = o.Name or "Settings",
		Icon = o.Icon,
		Title = o.Title or "Settings",
		Description = o.Description or "Themes, top bar, notifications and the panel itself.",
	})
	local startPos = win.Main.Position
	tab:Section("Appearance")
	tab:Cycle({
		Name = "Theme",
		Description = #RebelUI.Themes .. " themes - tap the arrows",
		Options = RebelUI.Themes,
		Default = win.ThemeName,
		Callback = function(n)
			win:SetTheme(n)
		end,
	})
	tab:Color({
		Name = "Accent color",
		Default = win.Theme.Accent,
		Callback = function(c)
			win:SetAccent(c)
		end,
	})
	tab:Button({
		Name = "Match my avatar colors",
		Description = "Makes the accent from your character",
		Callback = function()
			local c = win:ThemeFromAvatar()
			win:Notify({
				Title = c and "Theme changed" or "Can't tell",
				Text = c and "The panel now matches your avatar." or "Your character has no body colors yet.",
				Type = c and "success" or "warn",
			})
		end,
	})
	tab:Toggle({
		Name = "Rainbow rings",
		Description = "Every glowing edge turns rainbow",
		Default = win._rainbow == true,
		Flag = "__rainbow",
		Callback = function(on)
			win:SetRainbow(on)
		end,
	})
	tab:Slider({
		Name = "Panel size",
		Min = 70,
		Max = 130,
		Default = 100,
		Suffix = "%",
		Callback = function(v)
			win:SetScale(v / 100)
		end,
	})
	tab:Slider({
		Name = "Opacity",
		Description = "100% = solid panel",
		Min = 30,
		Max = 100,
		Default = win.Opacity,
		Suffix = "%",
		Flag = "__opacity",
		Callback = function(v)
			win:SetOpacity(v)
		end,
	})
	if o.Bar then
		tab:BarSettings(o.Bar)
	end
	tab:Section("Open button and game assistant")
	tab:Cycle({
		Name = "Open button",
		Description = "Round logo, square logo or the top bar",
		Options = { "Circle", "Square", "Bar" },
		Default = win.TriggerStyle or (win._hasBar and "Bar" or "Circle"),
		Flag = "__trigger",
		Callback = function(v)
			win:SetTrigger(v)
		end,
	})
	local function hud()
		return (o.Assistant and (win.HUD or win:GameAssistant(o.Assistant))) or win:_hud()
	end
	tab:Button({
		Name = "Open full game assistance",
		Description = "Full-screen HUD: players, health, stats, crosshair, your profile",
		Callback = function()
			local h = hud()
			win:Toggle(false)
			h:Open()
		end,
	})
	tab:Cycle({
		Name = "HUD colors",
		Description = "Rainbow glow, your theme or one color",
		Options = RebelUI.HudColors,
		Default = "Rainbow",
		Flag = "__hudcolor",
		Callback = function(v)
			hud():SetColor(v)
		end,
	})
	tab:Cycle({
		Name = "Crosshair",
		Options = RebelUI.Crosshairs,
		Default = "Cross",
		Flag = "__hudcross",
		Callback = function(v)
			hud():SetCrosshair(v)
		end,
	})
	tab:Toggle({
		Name = "Crosshair on screen",
		Description = "Keep the crosshair in the middle of your game view",
		Flag = "__hudingame",
		Callback = function(on)
			hud():CrosshairInGame(on)
		end,
	})
	tab:Section("Animations and effects")
	tab:Cycle({
		Name = "Open animation",
		Description = "How the panel appears",
		Options = RebelUI.OpenAnimations,
		Default = win.OpenAnim,
		Flag = "__openanim",
		Callback = function(v)
			win:SetOpenAnimation(v)
			win:Toggle(false)
			task.delay(0.35, function()
				win:Toggle(true)
			end)
		end,
	})
	tab:ClosePicker({ Section = false })
	tab:BoomPicker({ Section = false })
	tab:Slider({
		Name = "Animation speed",
		Min = 0.5,
		Max = 2.5,
		Default = win.AnimSpeed,
		Step = 0.1,
		Suffix = "x",
		Flag = "__animspeed",
		Callback = function(v)
			win:SetAnimSpeed(v)
		end,
	})
	tab:Toggle({ Name = "Click ripples", Description = "A glow ring where you tap", Default = true, Flag = "__fxripple", Callback = function(on)
		win:SetFx({ Ripple = on })
	end })
	tab:Toggle({ Name = "Rows pop in", Description = "Each row rises in when you open a tab", Default = true, Flag = "__fxstagger", Callback = function(on)
		win:SetFx({ Stagger = on })
	end })
	tab:Toggle({ Name = "Hover lift and press squish", Description = "Rows grow a little under your finger and squish when tapped", Default = true, Flag = "__fxhover", Callback = function(on)
		win:SetFx({ Hover = on })
	end })
	tab:Toggle({ Name = "Finger glow", Description = "A soft light follows your finger or mouse", Default = false, Flag = "__fxglow", Callback = function(on)
		win:SetFx({ Glow = on })
	end })
	tab:Toggle({ Name = "Scan lines", Description = "A slow sweep over the panel", Default = false, Flag = "__fxscan", Callback = function(on)
		win:SetFx({ Scan = on })
	end })
	tab:Toggle({ Name = "Breathing border", Description = "The edge glows in and out", Default = true, Flag = "__fxbreathe", Callback = function(on)
		win:SetFx({ Breathe = on })
	end })
	tab:Toggle({ Name = "Reduce motion", Description = "Turns the extra animations off (easier on weak phones)", Default = win.ReduceMotion, Flag = "__reduce", Callback = function(on)
		win:SetReduceMotion(on)
	end })
	tab:Button({ Name = "Test confetti", Callback = function()
		win:Confetti(40)
	end })
	tab:Section("Notifications and sound")
	tab:Toggle({
		Name = "Notifications",
		Description = "Pop-up cards at the bottom",
		Default = win.Toasts,
		Callback = function(on)
			win.Toasts = on
		end,
	})
	tab:Toggle({
		Name = "Toggle pop-ups",
		Description = "A card each time a toggle flips",
		Default = win.ToggleToasts == true,
		Callback = function(on)
			win.ToggleToasts = on
		end,
	})
	tab:Toggle({
		Name = "Sound effects",
		Description = "A soft click on buttons and tabs",
		Default = win.Sound,
		Callback = function(on)
			win.Sound = on
		end,
	})
	tab:Slider({
		Name = "Notification time",
		Min = 1,
		Max = 8,
		Default = win.NotifyTime,
		Suffix = "s",
		Callback = function(v)
			win.NotifyTime = v
		end,
	})
	tab:Section("Panel")
	tab:Keybind({
		Name = "Open / close key",
		Default = win.ToggleKey,
		Flag = "__togglekey",
		Changed = function(k)
			win:SetToggleKey(k)
			win:Notify({ Title = "Key set", Text = "Press " .. k.Name .. " to open or close the panel." })
		end,
	})
	tab:Toggle({
		Name = "Confirm on close",
		Description = "Tap X twice to close",
		Default = win.ConfirmClose,
		Callback = function(on)
			win.ConfirmClose = on
		end,
	})
	tab:Button({
		Name = "Reset position",
		Callback = function()
			win.Main.Position = startPos
			if win._bar then
				win._bar:ResetPosition()
			end
			win:Notify({ Title = "Position", Text = "The panel is back in the middle." })
		end,
	})
	tab:Section("Profiles")
	local nameBox, picker
	nameBox = tab:Input({
		Name = "Profile name",
		Placeholder = "e.g. Legit",
	})
	picker = tab:Dropdown({
		Name = "Saved profiles",
		Options = win:ListProfiles(),
		Callback = function(n)
			if type(n) == "string" then
				nameBox:Set(n, true)
			end
		end,
	})
	local function result(ok, why, okText, okTitle)
		win:Notify({
			Title = ok and okTitle or "Profile",
			Text = ok and okText or why,
			Type = ok and "success" or "warn",
		})
		picker:Refresh(win:ListProfiles())
	end
	tab:Button({
		Name = "Save profile",
		Description = "Saves everything under that name",
		Callback = function()
			local ok, why = win:SaveProfile(nameBox:Get())
			result(ok, why, "Saved as " .. cleanName(nameBox:Get()) .. ".", "Saved")
		end,
	})
	tab:Button({
		Name = "Load profile",
		Callback = function()
			local ok, why = win:LoadProfile(nameBox:Get())
			result(ok, why, "Profile " .. cleanName(nameBox:Get()) .. " is on.", "Loaded")
		end,
	})
	tab:Button({
		Name = "Delete profile",
		Callback = function()
			local ok, why = win:DeleteProfile(nameBox:Get())
			result(ok, why, "Profile deleted.", "Deleted")
		end,
	})
	tab:Button({
		Name = "Load this profile on start",
		Description = "Your script can call Win:AutoLoad()",
		Callback = function()
			local n = cleanName(nameBox:Get())
			if n == "" or not table.find(win:ListProfiles(), n) then
				win:Notify({ Title = "Profile", Text = "Save the profile first.", Type = "warn" })
				return
			end
			win:SetAutoLoad(n)
			win:Notify({ Title = "Auto-load", Text = n .. " will load next time.", Type = "success" })
		end,
	})
	tab:Section("Share settings")
	tab:Button({
		Name = "Copy settings code",
		Description = "One line of text with all your settings",
		Callback = function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, win:Export())
			win:Notify({
				Title = ok and "Copied" or "Can't copy",
				Text = ok and "Send it to a friend. They paste it below." or "This executor can't copy text.",
				Type = ok and "success" or "warn",
			})
		end,
	})
	tab:Button({
		Name = "Copy theme code",
		Description = "Just the colors (a short RBLT code)",
		Callback = function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, win:ExportTheme())
			win:Notify({ Title = ok and "Copied" or "Can't copy", Text = ok and "Paste it in the box below on another device." or "This executor can't copy text.", Type = ok and "success" or "warn" })
		end,
	})
	tab:Button({
		Name = "Copy this panel as code",
		Description = "Lua that builds the panel as it is now",
		Callback = function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, win:GenerateCode())
			win:Notify({ Title = ok and "Copied" or "Can't copy", Text = ok and "The Lua code is on your clipboard." or "This executor can't copy text.", Type = ok and "success" or "warn" })
		end,
	})
	tab:Input({
		Name = "Paste settings code",
		Placeholder = "paste, then tap done",
		Clear = true,
		Callback = function(text)
			if tostring(text) ~= "" then
				local ok = win:Import(text)
				win:Notify({
					Title = ok and "Imported" or "Not a settings code",
					Text = ok and "The settings were applied." or "Copy the whole code and try again.",
					Type = ok and "success" or "warn",
				})
			end
		end,
	})
	if o.Utilities ~= false then
		tab:Section("Utilities")
		local lp = Players.LocalPlayer
		tab:Toggle({
			Name = "Anti-AFK",
			Description = "Stops the 20 minute idle kick",
			Flag = "__antiafk",
			Callback = function(on)
				if win._afk then
					win._afk:Disconnect()
					win._afk = nil
				end
				if on and lp then
					local ok, vu = pcall(function()
						return game:GetService("VirtualUser")
					end)
					if ok and vu then
						local okc, c = pcall(function()
							return lp.Idled:Connect(function()
								pcall(function()
									vu:CaptureController()
									vu:ClickButton2(Vector2.new())
								end)
							end)
						end)
						if okc and c then
							win._afk = c
							win._conns[#win._conns + 1] = c
						end
					end
				end
			end,
		})
		if type(setfpscap) == "function" then
			tab:Slider({
				Name = "FPS cap",
				Min = 30,
				Max = 240,
				Step = 10,
				Default = 60,
				Flag = "__fpscap",
				Callback = function(v)
					pcall(setfpscap, v)
				end,
			})
		end
		tab:Button({
			Name = "Rejoin this server",
			Callback = function()
				win:Dialog({
					Title = "Rejoin?",
					Text = "You will leave this server and come back to the same game.",
					Buttons = {
						{
							Name = "Rejoin",
							Callback = function()
								pcall(function()
									game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
								end)
							end,
						},
						{ Name = "Cancel" },
					},
				})
			end,
		})
		tab:Toggle({
			Name = "Auto-save",
			Description = "A backup of your settings every minute",
			Default = win._autoOn == true,
			Flag = "__autosave",
			Callback = function(on)
				win:AutoSave(on and 60 or nil)
			end,
		})
		tab:Button({
			Name = "Restore auto-save",
			Callback = function()
				local ok = win:RestoreSnapshot()
				win:Notify({ Title = ok and "Restored" or "Nothing to restore", Text = ok and "Your last backup is back." or "Turn on Auto-save first.", Type = ok and "success" or "warn" })
			end,
		})
		tab:Button({
			Name = "Check for updates",
			Callback = function()
				win:CheckUpdate()
			end,
		})
		tab:Button({
			Name = "Copy game ID",
			Description = "The place id of this game",
			Callback = function()
				local ok = type(setclipboard) == "function" and pcall(setclipboard, tostring(game.PlaceId))
				win:Notify({ Title = ok and "Copied" or "Can't copy", Text = tostring(game.PlaceId), Type = ok and "success" or "warn" })
			end,
		})
	end
	tab:Section("Files")
	tab:Button({
		Name = "Save settings",
		Description = "Keeps every element that has a Flag",
		Callback = function()
			local ok = win:Save(o.File)
			win:Notify({
				Title = ok and "Saved" or "Could not save",
				Text = ok and "Your settings are saved." or "This executor can't write files.",
				Type = ok and "success" or "error",
			})
		end,
	})
	tab:Button({
		Name = "Load settings",
		Callback = function()
			local ok = win:Load(o.File)
			win:Notify({
				Title = ok and "Loaded" or "Nothing to load",
				Text = ok and "Your saved settings are back." or "No saved file was found.",
				Type = ok and "success" or "warn",
			})
		end,
	})
	tab:Section("About")
	local cr = o.Credits or {}
	tab:Paragraph({
		Title = (cr.Name or win.TitleText) .. "  |  RebelUI v" .. RebelUI.Version,
		Text = (cr.Text or "Made by prorizz196. Thank you for using it!") .. (cr.Discord and ("\n" .. cr.Discord) or ""),
	})
	if cr.Discord then
		tab:Link({ Url = cr.Discord, Name = cr.Discord })
		tab:Button({ Name = "Copy Discord invite", Callback = function()
			local ok = type(setclipboard) == "function" and pcall(setclipboard, cr.Discord)
			win:Notify({ Title = ok and "Copied!" or "Can't copy", Text = ok and "Paste it in your browser." or cr.Discord, Type = ok and "success" or "warn" })
		end })
	end
	tab:Button({ Name = "Check for updates", Callback = function()
		win:CheckUpdate()
	end })
	tab:Button({
		Name = "Unload panel",
		Callback = function()
			win:Dialog({
				Title = "Unload the panel?",
				Text = "Everything you turned on stays as it is. The panel closes for good.",
				Buttons = { { Name = "Unload", Callback = function() win:Destroy() end }, { Name = "Cancel" } },
			})
		end,
	})
	return tab
end

-- ============================================================ key gate
-- Asks for a key before your script goes on. It waits (yields) until the key is right or the window is closed.
--   local ok = UI:KeyGate({ Title = "My Script", Keys = { "ABC-123" }, Link = "https://discord.gg/..." })
--   if not ok then return end
-- Use Check = function(key) return true/false end to ask your own server (for example an HttpGet).
-- The four get-key buttons (pictures live in the repo Assets folder). Use them as Providers = { {"Linkvertise", url}, ... }
local ASSET_BASE = "https://raw.githubusercontent.com/rizqadeeb38-dev/Rebelwar_UI/main/Assets/"
RebelUI.Providers = {
	linkvertise = { Label = "Linkvertise", Color = Color3.fromRGB(255, 106, 0), Image = "https://i.imgur.com/muikU7L.png" },
	platoboost = { Label = "Platoboost", Color = Color3.fromRGB(104, 78, 235), Image = ASSET_BASE .. "Platoboast_Getkey.png" },
	rekonise = { Label = "Rekonise", Color = Color3.fromRGB(28, 186, 166), Image = ASSET_BASE .. "Rekonise_Getkey.png" },
	lootlabs = { Label = "LootLabs", Color = Color3.fromRGB(245, 166, 35), Image = "https://i.imgur.com/CCNfGa7.png" },
	workink = { Label = "Work.ink", Color = Color3.fromRGB(47, 128, 237), Image = ASSET_BASE .. "Work.ink_Getkey.png" },
}
local function providerInfo(name)
	local k = tostring(name or ""):lower():gsub("[^%w]", "")
	if k == "platoboast" then
		k = "platoboost"
	end
	return RebelUI.Providers[k]
end

-- RebelUI.Blur(size, seconds): blurs the game behind the panels (0 removes it)
function RebelUI.Blur(size, t)
	pcall(function()
		local Lighting = game:GetService("Lighting")
		local b = Lighting:FindFirstChild("RebelUI_Blur")
		if not b then
			if (size or 0) <= 0 then
				return
			end
			b = Instance.new("BlurEffect")
			b.Name, b.Size = "RebelUI_Blur", 0
			b.Parent = Lighting
		end
		local tw = game:GetService("TweenService"):Create(b, TweenInfo.new(t or 0.4), { Size = size or 0 })
		tw:Play()
		if (size or 0) <= 0 then
			task.delay((t or 0.4) + 0.05, function()
				if b.Parent and b.Size <= 0.5 then
					b:Destroy()
				end
			end)
		end
	end)
end

-- RebelUI.KeyTimeLeft() -> seconds left on the key that was just accepted (nil = no limit / no key).
function RebelUI.KeyTimeLeft()
	if not RebelUI.KeyExpires then
		return nil
	end
	return math.max(0, RebelUI.KeyExpires - os.time())
end
-- RebelUI.WatchKey(function() ... end) -> calls your function once when the key runs out (do your cleanup / show the panel again there).
-- Returns a function that stops the watch.
function RebelUI.WatchKey(onExpire)
	local alive = true
	task.spawn(function()
		while alive do
			local left = RebelUI.KeyTimeLeft()
			if left == nil then
				return
			end
			if left <= 0 then
				pcall(onExpire)
				return
			end
			task.wait(math.min(left, 5))
		end
	end)
	return function()
		alive = false
	end
end

-- UI.GetHWID() -> an id for this player's device (nil if the executor hides it). Used by KeyGate({ HwidBind = true }).
function RebelUI.GetHWID()
	local ok, id = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	if ok and type(id) == "string" and id ~= "" then
		return id
	end
	return nil
end

function RebelUI:KeyGate(o)
	-- A WIDE card made for phones held sideways: left = logo, name, note, steps, extra buttons. right = get-key buttons, key box, Verify.
	-- (In portrait it becomes one tall column.) Options: Name, Title, Subtitle, Logo, Emoji, Note, NoteIcon, NoteColor, Providers, Buttons, Tagline,
	-- HwidBind (a saved key only works on the device that made it; Check(key, hwid) also gets the device id), Keys, Check(key) (may also return a 2nd value: seconds the key lasts), RememberFor (seconds a saved key stays valid), Save, File, Boom, BoomText, Theme, Setup, Video, Background, BackgroundOpacity, Blur (default true), MaxTries, Timeout, ReduceMotion
	o = o or {}
	if RebelUI._off then
		return false
	end
	local setup = RebelUI.GetSetup(o.Setup)
	local pcSetup = setup == "PC"
	local theme = THEMES[o.Theme or "Red"] or THEMES.Red
	local clean = tostring(o.Name or o.Title or "RebelUI"):gsub("[^%w]", "")
	local file = o.File or ("RebelUI_" .. (clean == "" and "Script" or clean) .. "_key.txt")
	local function trim(s)
		s = tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")
		return s
	end
	local function valid(k)
		-- returns ok, seconds the key lasts (nil = no limit). Check(key) may return true, seconds.
		k = trim(k)
		if k == "" then
			return false
		end
		if type(o.Check) == "function" then
			local ok, r, ttl = pcall(o.Check, k, RebelUI.GetHWID())
			if ok and r == true then
				return true, tonumber(ttl)
			end
			return false
		end
		for _, good in ipairs(o.Keys or {}) do
			if k == tostring(good) then
				return true
			end
		end
		return false
	end
	local function fmtTime(sec)
		sec = math.max(0, math.floor(sec))
		if sec >= 86400 then
			return string.format("%dd %dh", sec // 86400, (sec % 86400) // 3600)
		elseif sec >= 3600 then
			return string.format("%dh %dm", sec // 3600, (sec % 3600) // 60)
		elseif sec >= 60 then
			return string.format("%dm %ds", sec // 60, sec % 60)
		end
		return sec .. "s"
	end
	RebelUI.FormatTime = fmtTime
	if o.Save ~= false and type(readfile) == "function" and type(isfile) == "function" then
		local okf, raw = pcall(function()
			if isfile(file) then
				return readfile(file)
			end
		end)
		if okf and raw then
			local k, exp, hw = tostring(raw):match("^([^\n]*)\n(%d*)\n?([^\n]*)")
			if not k then
				k, exp = tostring(raw), nil
			end
			exp = tonumber(exp)
			local fresh = true
			if o.HwidBind then
				local mine = RebelUI.GetHWID()
				if not mine or hw ~= mine then
					fresh = false -- saved on another device (or no id available): ask again
				end
			end
			if exp then
				fresh = fresh and os.time() < exp
			elseif o.RememberFor then
				fresh = false -- an old save with no time stamp, and you now want keys to expire
			end
			if fresh then
				local good, ttl = valid(k)
				if good then
					if ttl then
						exp = math.min(exp or math.huge, os.time() + ttl)
					end
					RebelUI.KeyExpires = exp
					return true, trim(k), exp
				end
			end
		end
	end
	local NOTE = {
		Green = Color3.fromRGB(60, 200, 110), Blue = Color3.fromRGB(70, 140, 255), Red = Color3.fromRGB(235, 60, 70), Gold = Color3.fromRGB(255, 190, 50),
		Purple = Color3.fromRGB(160, 90, 255), Pink = Color3.fromRGB(255, 90, 180), Orange = Color3.fromRGB(255, 140, 40), Cyan = Color3.fromRGB(50, 220, 240),
		Gray = Color3.fromRGB(150, 150, 160), Discord = Color3.fromRGB(88, 101, 242),
	}
	local function pick(c, d)
		if typeof(c) == "Color3" then
			return c
		end
		return NOTE[c] or d
	end

	local name = (o.Name or "RebelUI") .. "_KeyGate"
	clearOld(name)
	local gui = new("ScreenGui", { Name = name, ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1001 })
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	gui.Parent = pickParent()
	RebelUI._fancyGui(gui)
	local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 450)
	local wide = vp.X >= vp.Y * 1.1
	if o.Layout == "Tall" then
		wide = false
	elseif o.Layout == "Wide" then
		wide = true
	end
	if o.Blur ~= false then
		RebelUI.Blur(o.BlurSize or 14, 0.5)
	end
	local back = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 2, 4), BackgroundTransparency = 0.3, Text = "", AutoButtonColor = false, BorderSizePixel = 0 }, gui)
	if o.Background or o.Image then
		new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = asset(o.Background or o.Image), ImageTransparency = 1 - (o.BackgroundOpacity or 0.2), ScaleType = Enum.ScaleType.Crop }, back)
	end
	if o.Video then
		task.spawn(function()
			local okV, src = pcall(RebelUI.ResolveMedia, o.Video, o.VideoFile)
			if okV and src and gui.Parent then
				pcall(function()
					local vf = new("VideoFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Looped = true, Volume = 0, Video = src, ZIndex = 1 }, back)
					vf.Playing = true
					new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 2 }, back)
				end)
			end
		end)
	end
	-- floating glow dots behind the card
	if o.Particles ~= false and not o.ReduceMotion then
		for i = 1, 14 do
			local d = new("Frame", { Position = UDim2.fromScale(math.random(), math.random()), Size = UDim2.fromOffset(math.random(3, 7), math.random(3, 7)), BackgroundColor3 = theme.Glow, BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 3 }, back)
			corner(d, 4)
			task.spawn(function()
				while gui.Parent do
					local t = math.random(40, 90) / 10
					tween(d, t, { Position = UDim2.fromScale(math.random(), math.random()), BackgroundTransparency = math.random(5, 9) / 10 }, Enum.EasingStyle.Sine)
					task.wait(t)
				end
			end)
		end
	end

	-- ====================================================================================================================
	-- CARD layout (the default): a compact panel. Title + subtitle, key box, status line, a big Check Key button and a row of
	-- small buttons (Get Key, Discord ...). Animated: the card slides up, every row pops in one after another, a light sweeps
	-- over the top bar and the Check Key button, the key box glows when you type, a wrong key shakes the card, a right key
	-- fills the bar green and booms. Layout = "Wide" or "Tall" brings the older big panels back.
	-- ====================================================================================================================
	if o.Layout == nil or o.Layout == "Card" then
		local accent = pick(o.Accent, theme.Accent)
		local CWd = math.min(vp.X * 0.92, o.FormWidth or (pcSetup and 440 or 400))
		local P, SG = 22, 12 -- side padding, gap between rows
		local IW = CWd - P * 2
		local DARK, DARK2 = Color3.fromRGB(34, 34, 46), Color3.fromRGB(22, 22, 30)
		local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 40), Size = UDim2.fromOffset(CWd, 320), BackgroundColor3 = Color3.fromRGB(7, 7, 11), BorderSizePixel = 0, Active = true, ClipsDescendants = true, ZIndex = 5 }, back)
		corner(card, 20)
		local cstroke = new("UIStroke", { Color = accent, Thickness = 1.5, Transparency = 0.55, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, card)
		local scl = new("UIScale", { Scale = 0.86 }, card)
		-- top bar with a light that sweeps across it
		local bar = new("Frame", { Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = accent, BorderSizePixel = 0, ZIndex = 8 }, card)
		local sweep = new("Frame", { Size = UDim2.new(0.3, 0, 1, 0), Position = UDim2.fromScale(-0.4, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 9 }, bar)
		local result, savedKey = nil, nil
		local closedByX = false
		local busy, tries, remember = false, 0, o.Save ~= false
		local sections, boxF, statusL, checkB, checkT, drawerOpen = {}, nil, nil, nil, nil, false
		local box, kst, triesL
		local drawerH, drawerTarget = 0, 0
		local H = 320

		local function addSection(h, build)
			local f = new("Frame", { Size = UDim2.fromOffset(IW, h), BackgroundTransparency = 1, Visible = false, ZIndex = 6 }, card)
			local s = { f = f, h = h }
			sections[#sections + 1] = s
			build(f, s)
			return s
		end
		local function layout(animate)
			local y = 22
			for _, s in ipairs(sections) do
				if s.h > 0 or s.keep then
					s.y = y
					if s.shown then
						if animate then
							tween(s.f, 0.25, { Position = UDim2.fromOffset(P, y) }, Enum.EasingStyle.Quad)
						else
							s.f.Position = UDim2.fromOffset(P, y)
						end
					end
					y = y + s.h + (s.h > 0 and SG or 0)
				end
			end
			H = y - SG + 22
			if animate then
				tween(card, 0.25, { Size = UDim2.fromOffset(CWd, H) }, Enum.EasingStyle.Quad)
			else
				card.Size = UDim2.fromOffset(CWd, H)
			end
			local fit = math.min(1, (vp.Y * 0.94) / H, (vp.X * 0.97) / CWd)
			if scl.Scale ~= fit and not busy then
				tween(scl, 0.25, { Scale = fit })
			end
		end
		local function setStatus(text, color)
			if not statusL then
				return
			end
			statusL.Text = text
			statusL.TextColor3 = color or C.Dim
			if not o.ReduceMotion then
				statusL.Position = UDim2.fromOffset(2, 7)
				statusL.TextTransparency = 1
				tween(statusL, 0.25, { Position = UDim2.fromOffset(2, 0), TextTransparency = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			else
				statusL.TextTransparency = 0
			end
		end
		local function press(btn)
			local sc = btn:FindFirstChildOfClass("UIScale") or new("UIScale", { Scale = 1 }, btn)
			tween(sc, 0.07, { Scale = 0.95 })
			task.delay(0.07, function()
				tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end)
		end
		local function hover(btn, base, over)
			btn.MouseEnter:Connect(function()
				tween(btn, 0.15, { BackgroundColor3 = over })
			end)
			btn.MouseLeave:Connect(function()
				tween(btn, 0.2, { BackgroundColor3 = base })
			end)
		end

		-- ---- header: logo, title, subtitle, close button
		addSection(54, function(f)
			local tx = 0
			if o.Logo or o.Emoji then
				tx = 58
				local ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(25, 27), Size = UDim2.fromOffset(52, 52), BackgroundColor3 = accent, BackgroundTransparency = 0.8, BorderSizePixel = 0 }, f)
				corner(ring, 14)
				if not o.ReduceMotion then
					task.spawn(function()
						while gui.Parent and result == nil do
							tween(ring, 1.1, { BackgroundTransparency = 0.93, Size = UDim2.fromOffset(60, 60) }, Enum.EasingStyle.Sine)
							task.wait(1.1)
							tween(ring, 1.1, { BackgroundTransparency = 0.78, Size = UDim2.fromOffset(52, 52) }, Enum.EasingStyle.Sine)
							task.wait(1.1)
						end
					end)
				end
				if o.Logo then
					local lg = new("ImageLabel", { Position = UDim2.fromOffset(1, 3), Size = UDim2.fromOffset(48, 48), BackgroundTransparency = 1, Image = asset(o.Logo), ScaleType = Enum.ScaleType.Fit, ZIndex = 7 }, f)
					corner(lg, 10)
					RebelUI.SetImage(lg, o.Logo)
				else
					local em = label(f, o.Emoji, 26, C.Text, true)
					em.Position, em.Size = UDim2.fromOffset(1, 3), UDim2.fromOffset(48, 48)
					em.TextXAlignment = Enum.TextXAlignment.Center
					em.ZIndex = 7
				end
			end
			local tl = label(f, tostring(o.Title or "KEY SYSTEM"), 24, C.White, true)
			tl.Font = Enum.Font.GothamBlack
			tl.Position = UDim2.fromOffset(tx, 2)
			tl.Size = UDim2.new(1, -(tx + 46), 0, 30)
			local sl = label(f, tostring(o.Subtitle or "Key System  -  enter your key to continue"), 11, Color3.fromRGB(135, 135, 152), false)
			sl.Position = UDim2.fromOffset(tx, 32)
			sl.Size = UDim2.new(1, -(tx + 46), 0, 18)
		end)
		local closeB = new("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 22), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = DARK, Text = "X", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.White, AutoButtonColor = false, ZIndex = 12 }, card)
		corner(closeB, 10)
		closeB.MouseEnter:Connect(function()
			tween(closeB, 0.15, { BackgroundColor3 = Color3.fromRGB(190, 45, 55) })
		end)
		closeB.MouseLeave:Connect(function()
			tween(closeB, 0.15, { BackgroundColor3 = DARK })
		end)
		closeB.Activated:Connect(function()
			closedByX = true
			result = false
		end)

		-- ---- optional note
		if o.Note then
			local nc = pick(o.NoteColor, Color3.fromRGB(255, 190, 50))
			local text = (o.NoteIcon and (o.NoteIcon .. "  ") or "") .. tostring(o.Note)
			local perLine = math.max(14, math.floor(IW / 6.4))
			local lines = math.ceil(#text / perLine) + select(2, text:gsub("\n", ""))
			addSection(10 + lines * 13, function(f)
				f.BackgroundTransparency = 0.88
				f.BackgroundColor3 = nc
				corner(f, 10)
				local nb = new("Frame", { Size = UDim2.new(0, 3, 1, -10), Position = UDim2.fromOffset(6, 5), BackgroundColor3 = nc, BorderSizePixel = 0 }, f)
				corner(nb, 2)
				local nt = label(f, text, 10, C.Text, false)
				nt.Position = UDim2.fromOffset(16, 0)
				nt.Size = UDim2.new(1, -22, 1, 0)
				nt.TextWrapped = true
				nt.TextTruncate = Enum.TextTruncate.None
			end)
		end

		-- ---- key box
		addSection(52, function(f)
			f.BackgroundTransparency = 0
			f.BackgroundColor3 = DARK2
			corner(f, 12)
			kst = new("UIStroke", { Color = Color3.fromRGB(52, 52, 70), Thickness = 1.5 }, f)
			local canPaste = type(getclipboard) == "function"
			box = new("TextBox", { Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, canPaste and -92 or -32, 1, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = "Paste your key here...", PlaceholderColor3 = Color3.fromRGB(105, 105, 124), TextColor3 = C.White, TextSize = 14, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8 }, f)
			if canPaste then
				local pb = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0), Size = UDim2.fromOffset(60, 32), BackgroundColor3 = DARK, Text = "Paste", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.White, AutoButtonColor = false, ZIndex = 9 }, f)
				corner(pb, 9)
				hover(pb, DARK, Color3.fromRGB(52, 52, 70))
				pb.Activated:Connect(function()
					press(pb)
					local okp, txt = pcall(getclipboard)
					if okp and type(txt) == "string" and txt ~= "" then
						box.Text = trim(txt)
					end
				end)
			end
			box.Focused:Connect(function()
				tween(kst, 0.2, { Color = accent, Thickness = 2 })
			end)
			box.FocusLost:Connect(function(enter)
				tween(kst, 0.2, { Color = Color3.fromRGB(52, 52, 70), Thickness = 1.5 })
				if enter and RebelUI._cardSubmit then
					RebelUI._cardSubmit()
				end
			end)
			boxF = f
		end)

		-- ---- status line (red = wrong, green = copied / ok, grey = info)
		addSection(20, function(f)
			statusL = label(f, "", 12, C.Dim, true)
			statusL.Position = UDim2.fromOffset(2, 0)
			statusL.Size = UDim2.new(1, -4, 1, 0)
			statusL.TextTruncate = Enum.TextTruncate.AtEnd
		end)

		-- ---- Check Key
		addSection(50, function(f)
			checkB = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = accent, BackgroundTransparency = 0.3, Text = o.ButtonText or "Check Key", TextColor3 = C.White, Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false, ClipsDescendants = true, ZIndex = 7 }, f)
			corner(checkB, 12)
			checkT = checkB
			local shine = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(-0.3, 0.5), Size = UDim2.new(0, 36, 1.8, 0), Rotation = 20, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = 8 }, checkB)
			if not o.ReduceMotion then
				task.spawn(function()
					task.wait(1.2)
					while gui.Parent and result == nil do
						shine.Position = UDim2.fromScale(-0.2, 0.5)
						tween(shine, 0.9, { Position = UDim2.fromScale(1.2, 0.5) }, Enum.EasingStyle.Quad)
						task.wait(2.6)
					end
				end)
			end
		end)

		-- ---- row of small buttons: Get Key first, then the ones you listed in Buttons
		local provs = o.Providers or {}
		local small = {}
		if #provs > 0 then
			small[#small + 1] = { Name = o.GetKeyText or "Get Key", Color = DARK, Provs = true }
		end
		for _, bd in ipairs(o.Buttons or {}) do
			local c = pick(bd.Color, accent)
			small[#small + 1] = { Name = bd.Name or "Button", Color = c:Lerp(Color3.new(0, 0, 0), 0.18), Link = bd.Link, Callback = bd.Callback, Copied = bd.CopiedText or (tostring(bd.Name) == "Discord" and "Discord invite copied!" or (tostring(bd.Name) .. " link copied!")) }
		end
		local drawerSec
		local function closeDrawer()
			if not drawerOpen then
				return
			end
			drawerOpen = false
			drawerSec.h = 0
			tween(drawerSec.f, 0.25, { Size = UDim2.fromOffset(IW, 0) }, Enum.EasingStyle.Quad)
			layout(true)
		end
		local perRow = 3
		for r0 = 1, #small, perRow do
			local n = math.min(perRow, #small - r0 + 1)
			addSection(48, function(f)
				local bw = (IW - SG * (n - 1)) / n
				for i = 0, n - 1 do
					local d = small[r0 + i]
					local b = new("TextButton", { Position = UDim2.fromOffset(i * (bw + SG), 0), Size = UDim2.fromOffset(bw, 48), BackgroundColor3 = d.Color, Text = d.Name, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = C.White, AutoButtonColor = false, ZIndex = 7 }, f)
					corner(b, 12)
					hover(b, d.Color, d.Color:Lerp(Color3.new(1, 1, 1), 0.12))
					b.Activated:Connect(function()
						press(b)
						if d.Provs then
							if #provs == 1 then
								local pr = provs[1]
								local link = type(pr) == "table" and (pr.Link or pr[2]) or nil
								local okc = link and type(setclipboard) == "function" and pcall(setclipboard, link)
								setStatus(okc and "Key link copied to clipboard!" or "No link set for the key.", okc and C.Green or C.Bad)
							else
								drawerOpen = not drawerOpen
								drawerSec.h = drawerOpen and drawerTarget or 0
								tween(drawerSec.f, 0.25, { Size = UDim2.fromOffset(IW, drawerSec.h) }, Enum.EasingStyle.Quad)
								layout(true)
							end
							return
						end
						local okc = d.Link and type(setclipboard) == "function" and pcall(setclipboard, d.Link)
						if d.Callback then
							safe(d.Callback)
						end
						setStatus(okc and d.Copied or (d.Link and "Could not copy." or "..."), okc and C.Green or C.Bad)
					end)
				end
			end)
		end

		-- ---- provider drawer (only when there is more than one get-key link)
		drawerSec = addSection(0, function(f, s)
			f.ClipsDescendants = true
			s.keep = true
			if #provs > 1 then
				local y = 0
				for i, pr in ipairs(provs) do
					local pname = type(pr) == "table" and (pr.Name or pr[1]) or tostring(pr)
					local link = type(pr) == "table" and (pr.Link or pr[2]) or nil
					local info = providerInfo(pname) or {}
					local img = (type(pr) == "table" and pr.Image) or info.Image
					local pb = new("TextButton", { Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = DARK2, Text = "", AutoButtonColor = false, ZIndex = 7 }, f)
					corner(pb, 12)
					local pst = new("UIStroke", { Color = (type(pr) == "table" and pr.Color) or info.Color or accent, Thickness = 1.2, Transparency = 0.5 }, pb)
					local fb = label(pb, tostring(pname), 13, C.White, true)
					fb.Size = UDim2.fromScale(1, 1)
					fb.TextXAlignment = Enum.TextXAlignment.Center
					fb.ZIndex = 8
					if img then
						local im = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -16, 1, -12), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, ImageTransparency = 1, ZIndex = 9 }, pb)
						corner(im, 8)
						RebelUI.SetImage(im, img, function(okI)
							if okI and im.Parent then
								tween(im, 0.3, { ImageTransparency = 0 })
								fb.Visible = false
							end
						end)
					end
					hover(pb, DARK2, Color3.fromRGB(30, 30, 42))
					pb.Activated:Connect(function()
						press(pb)
						local okc = link and type(setclipboard) == "function" and pcall(setclipboard, link)
						setStatus(okc and (tostring(pname) .. " link copied to clipboard!") or ("No link set for " .. tostring(pname)), okc and C.Green or C.Bad)
						if okc then
							task.delay(0.5, closeDrawer)
						end
					end)
					y = y + 46 + 8
				end
				drawerTarget = y - 8
			end
		end)
		drawerSec.f.Size = UDim2.fromOffset(IW, 0)

		-- ---- footer: remember tick, tries, tagline
		addSection(o.Tagline and 40 or 22, function(f)
			local rm = new("TextButton", { Size = UDim2.fromOffset(150, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 7 }, f)
			local rbox = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = remember and accent or DARK, BorderSizePixel = 0 }, rm)
			corner(rbox, 5)
			local rtick = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(remember and 8 or 0, remember and 8 or 0), BackgroundColor3 = C.White, BorderSizePixel = 0 }, rbox)
			corner(rtick, 3)
			local rl = label(rm, "Remember my key", 11, Color3.fromRGB(135, 135, 152), false)
			rl.Position = UDim2.fromOffset(26, 0)
			rl.Size = UDim2.new(1, -26, 1, 0)
			rm.Activated:Connect(function()
				remember = not remember
				tween(rbox, 0.15, { BackgroundColor3 = remember and accent or DARK })
				tween(rtick, 0.2, { Size = remember and UDim2.fromOffset(8, 8) or UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end)
			triesL = label(f, o.MaxTries and ("Tries 0/" .. o.MaxTries) or "", 11, Color3.fromRGB(135, 135, 152), false)
			triesL.AnchorPoint = Vector2.new(1, 0)
			triesL.Position = UDim2.new(1, 0, 0, 0)
			triesL.Size = UDim2.fromOffset(110, 22)
			triesL.TextXAlignment = Enum.TextXAlignment.Right
			if o.Tagline then
				local tg = label(f, tostring(o.Tagline), 10, Color3.fromRGB(95, 95, 112), false)
				tg.Position = UDim2.fromOffset(0, 24)
				tg.Size = UDim2.new(1, 0, 0, 14)
				tg.TextXAlignment = Enum.TextXAlignment.Center
			end
		end)

		-- ---- open: the card slides up, the rows pop in one after another
		layout(false)
		card.Size = UDim2.fromOffset(CWd, H)
		local fit0 = math.min(1, (vp.Y * 0.94) / H, (vp.X * 0.97) / CWd)
		tween(scl, 0.5, { Scale = fit0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		tween(card, 0.5, { Position = UDim2.fromScale(0.5, 0.5) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		for i, s in ipairs(sections) do
			task.delay(o.ReduceMotion and 0 or (0.12 + i * 0.07), function()
				if not s.f.Parent then
					return
				end
				s.shown = true
				if o.ReduceMotion then
					s.f.Position = UDim2.fromOffset(P, s.y)
					s.f.Visible = true
				else
					s.f.Position = UDim2.fromOffset(P, s.y + 16)
					s.f.Visible = true
					tween(s.f, 0.4, { Position = UDim2.fromOffset(P, s.y) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end
			end)
		end
		if not o.ReduceMotion then
			task.spawn(function()
				task.wait(0.6)
				while gui.Parent and result == nil do
					sweep.Position = UDim2.fromScale(-0.4, 0)
					tween(sweep, 1.4, { Position = UDim2.fromScale(1.1, 0) }, Enum.EasingStyle.Quad)
					task.wait(3.4)
				end
			end)
			task.spawn(function()
				task.wait(0.9)
				while gui.Parent and result == nil do
					tween(cstroke, 1, { Transparency = 0.15 }, Enum.EasingStyle.Sine)
					task.wait(1)
					tween(cstroke, 1, { Transparency = 0.6 }, Enum.EasingStyle.Sine)
					task.wait(1)
				end
			end)
		end
		if o.OpenBoom ~= false then
			task.delay(0.35, function()
				pcall(RebelUI.Boom, gui, { Color = accent, Count = 18, Style = o.BoomStyle, Image = o.BoomImage })
			end)
		end
		-- the Check Key button is dimmer while the box is empty
		box:GetPropertyChangedSignal("Text"):Connect(function()
			if busy or result ~= nil then
				return
			end
			tween(checkB, 0.2, { BackgroundTransparency = trim(box.Text) == "" and 0.3 or 0 })
			if statusL.TextColor3 == C.Bad then
				statusL.Text = ""
			end
		end)
		hover(checkB, accent, accent:Lerp(Color3.new(1, 1, 1), 0.12))

		-- ---- check the key
		local dots
		local function submit()
			if busy or result ~= nil then
				return
			end
			local k = trim(box.Text)
			if k == "" then
				setStatus("Paste your key first.", C.Bad)
				if not o.ReduceMotion then
					task.spawn(function()
						for _, dx in ipairs({ -6, 6, -4, 4, 0 }) do
							boxF.Position = UDim2.fromOffset(P + dx, boxF.Position.Y.Offset)
							task.wait(0.035)
						end
					end)
				end
				return
			end
			busy = true
			press(checkB)
			setStatus("Checking...", C.Dim)
			local dotsOn = true
			task.spawn(function()
				local n = 0
				while dotsOn and gui.Parent do
					checkT.Text = "Checking" .. string.rep(".", n % 4)
					n += 1
					task.wait(0.25)
				end
			end)
			task.spawn(function()
				local good, ttl = valid(k)
				dotsOn = false
				if good then
					ttl = ttl or o.RememberFor
					RebelUI.KeyExpires = ttl and (os.time() + ttl) or nil
					busy = false
					task.wait(0.3)
					checkT.Text = "Unlocked"
					setStatus((o.SuccessText or "Key accepted. Welcome!") .. (ttl and ("  Key valid for " .. fmtTime(ttl)) or ""), C.Green)
					tween(checkB, 0.3, { BackgroundColor3 = C.Green, BackgroundTransparency = 0 })
					tween(bar, 0.5, { BackgroundColor3 = C.Green })
					tween(cstroke, 0.3, { Color = C.Green, Transparency = 0.2 })
					tween(kst, 0.3, { Color = C.Green })
					if remember and type(writefile) == "function" then
						pcall(writefile, file, k .. "\n" .. (RebelUI.KeyExpires or "") .. (o.HwidBind and ("\n" .. (RebelUI.GetHWID() or "")) or ""))
					end
					savedKey = k
					busy = true
					if not o.ReduceMotion then
						tween(scl, 0.15, { Scale = scl.Scale * 1.04 }, Enum.EasingStyle.Quad)
					end
					if o.Boom ~= false then
						pcall(RebelUI.Boom, gui, { Color = theme.Glow, Count = 28, Text = o.BoomText, Style = o.BoomStyle, Image = o.BoomImage })
						task.wait(0.9)
					else
						task.wait(0.5)
					end
					result = true
				else
					tries += 1
					busy = false
					task.wait(0.3)
					checkT.Text = o.ButtonText or "Check Key"
					setStatus(o.MaxTries and ("That key is not right. (" .. tries .. "/" .. o.MaxTries .. ")") or "Invalid key. Try again.", C.Bad)
					tween(kst, 0.1, { Color = C.Bad })
					task.delay(0.8, function()
						if kst.Parent then
							tween(kst, 0.3, { Color = Color3.fromRGB(52, 52, 70) })
						end
					end)
					if o.MaxTries then
						triesL.Text = "Tries " .. tries .. "/" .. o.MaxTries
					end
					if not o.ReduceMotion then
						for _, dx in ipairs({ -9, 9, -6, 6, 0 }) do
							card.Position = UDim2.new(0.5, dx, 0.5, 0)
							task.wait(0.04)
						end
					end
					if o.MaxTries and tries >= o.MaxTries then
						task.wait(0.8)
						result = false
					elseif (o.Cooldown or 0) > 0 then
						busy = true
						for s = math.ceil(o.Cooldown), 1, -1 do
							checkT.Text = "Wait " .. s .. "s"
							task.wait(1)
						end
						checkT.Text = o.ButtonText or "Check Key"
						busy = false
					end
				end
			end)
		end
		RebelUI._cardSubmit = submit
		checkB.Activated:Connect(submit)
		local waited = 0
		while result == nil do
			task.wait(0.1)
			waited += 0.1
			if o.Timeout and waited >= o.Timeout then
				result = false
			end
		end
		RebelUI._cardSubmit = nil
		if o.Blur ~= false then
			RebelUI.Blur(0, 0.6)
		end
		if closedByX and o.CloseAnimation and o.CloseAnimation ~= "None" and not o.ReduceMotion then
			RebelUI.CloseEffect(gui, card, o.CloseAnimation == true and "BlackHole" or o.CloseAnimation, { Color = accent, Move = true, Media = o.CloseMedia })
		end
		tween(scl, 0.2, { Scale = 0.7 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tween(back, 0.2, { BackgroundTransparency = 1 })
		task.wait(0.2)
		gui:Destroy()
		if result then
			return true, savedKey, RebelUI.KeyExpires
		end
		return false
	end

	local PAD, GAP = 14, 8
	local CW
	if wide then
		CW = math.min(vp.X * 0.94, o.WideWidth or (pcSetup and 820 or 720))
	else
		CW = math.min(vp.X * 0.96, o.FormWidth or (pcSetup and 440 or 350))
	end
	local LW = wide and math.floor(CW * 0.4) or CW
	local RW = wide and (CW - LW) or CW
	local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(CW, 400), BackgroundColor3 = Color3.fromRGB(20, 11, 14), BorderSizePixel = 0, Active = true, ClipsDescendants = true, ZIndex = 5 }, back)
	corner(card, 18)
	local cstroke = new("UIStroke", { Color = theme.Glow, Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, card)
	-- a bright streak that slowly travels around the panel rim
	if not o.ReduceMotion and o.Rim ~= false then
		local rim = new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, theme.Glow), ColorSequenceKeypoint.new(0.35, Color3.fromRGB(70, 20, 28)), ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(0.65, Color3.fromRGB(70, 20, 28)), ColorSequenceKeypoint.new(1, theme.Glow) }) }, cstroke)
		task.spawn(function()
			local r = 0
			while card.Parent do
				r = (r + 3) % 360
				rim.Rotation = r
				task.wait(0.03)
			end
		end)
	end
	new("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(36, 15, 19), Color3.fromRGB(15, 7, 9)) }, card)
	local scl = new("UIScale", { Scale = 0.8 }, card)
	local Lf = new("Frame", { Size = UDim2.new(0, LW, 1, 0), BackgroundTransparency = 1 }, card)
	local Rf = new("Frame", { Position = wide and UDim2.fromOffset(LW, 0) or UDim2.fromOffset(0, 0), Size = UDim2.new(0, RW, 1, 0), BackgroundTransparency = 1 }, card)
	if wide then
		local dv = new("Frame", { Position = UDim2.fromOffset(LW, PAD), Size = UDim2.new(0, 1, 1, -PAD * 2), BackgroundColor3 = theme.Glow, BackgroundTransparency = 0.7, BorderSizePixel = 0 }, card)
	end
	local result, savedKey = nil, nil
	local setStep, box, go, status, kst, lockI, gl, triesL
	local remember = o.Save ~= false

	-- ================= block: header (logo with a glow, title, subtitle)
	local function blockHeader(p, y, W)
		-- the glow behind the logo: soft pulsing rings in the theme color
		local lx, ly, ls = PAD + 4, y + 2, 54
		local rings = {}
		for i, g in ipairs({ { 22, 0.88 }, { 14, 0.8 }, { 7, 0.68 } }) do
			local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(lx + ls / 2, ly + ls / 2), Size = UDim2.fromOffset(ls + g[1], ls + g[1]), BackgroundColor3 = theme.Glow, BackgroundTransparency = g[2], BorderSizePixel = 0 }, p)
			corner(f, 20 + g[1] / 2)
			rings[i] = f
		end
		if not o.ReduceMotion then
			task.spawn(function()
				local out = true
				while gui.Parent and result == nil do
					for i, f in ipairs(rings) do
						tween(f, 1.1, { BackgroundTransparency = out and math.min(0.97, f.BackgroundTransparency + 0.08) or math.max(0.55, f.BackgroundTransparency - 0.08) }, Enum.EasingStyle.Sine)
					end
					out = not out
					task.wait(1.1)
				end
			end)
		end
		if o.Logo then
			local lg = new("ImageLabel", { Position = UDim2.fromOffset(lx, ly), Size = UDim2.fromOffset(ls, ls), BackgroundTransparency = 1, Image = asset(o.Logo), ScaleType = Enum.ScaleType.Fit, ZIndex = 3 }, p)
			RebelUI.SetImage(lg, o.Logo)
			pcall(RebelUI._imageEffect, lg, o.LogoEffect or "Float", theme)
		else
			local em = label(p, o.Emoji or "🔑", 30, C.Text, true)
			em.Position, em.Size = UDim2.fromOffset(lx, ly), UDim2.fromOffset(ls, ls)
			em.ZIndex = 3
		end
		local tx = lx + ls + 14
		local tl = label(p, tostring(o.Title or "KEY SYSTEM"), pcSetup and 20 or 18, C.Text, true)
		tl.Font = Enum.Font.GothamBlack
		tl.Position = UDim2.fromOffset(tx, y + 4)
		tl.Size = UDim2.new(1, -(tx + PAD + (wide and 0 or 30)), 0, 26)
		tl.TextXAlignment = Enum.TextXAlignment.Left
		local sl = label(p, tostring(o.Subtitle or "Get your key, then paste it below."), 10, C.Dim, false)
		sl.Position = UDim2.fromOffset(tx, y + 32)
		sl.Size = UDim2.new(1, -(tx + PAD), 0, 26)
		sl.TextXAlignment = Enum.TextXAlignment.Left
		sl.TextWrapped = true
		sl.TextYAlignment = Enum.TextYAlignment.Top
		return y + 62 + GAP
	end

	-- ================= block: note (colored box)
	local function blockNote(p, y, W)
		if not o.Note then
			return y
		end
		local text = (o.NoteIcon and (o.NoteIcon .. "  ") or "") .. "Note: " .. tostring(o.Note)
		local perLine = math.max(10, math.floor((W - PAD * 2 - 30) / 7.4))
		local lines = math.ceil(#text / perLine) + select(2, text:gsub("\n", ""))
		local h = 14 + lines * 13
		local nc = pick(o.NoteColor, Color3.fromRGB(255, 190, 50))
		local nb = new("Frame", { Position = UDim2.fromOffset(PAD, y), Size = UDim2.new(1, -PAD * 2, 0, h), BackgroundColor3 = nc, BackgroundTransparency = 0.86, BorderSizePixel = 0 }, p)
		corner(nb, 10)
		new("UIStroke", { Color = nc, Thickness = 1, Transparency = 0.5 }, nb)
		local bar = new("Frame", { Size = UDim2.new(0, 3, 1, -10), Position = UDim2.fromOffset(6, 5), BackgroundColor3 = nc, BorderSizePixel = 0 }, nb)
		corner(bar, 2)
		local nt = label(nb, text, 10, C.Text, false)
		nt.Position = UDim2.fromOffset(18, 0)
		nt.Size = UDim2.new(1, -26, 1, 0)
		nt.TextWrapped = true
		nt.TextXAlignment = Enum.TextXAlignment.Left
		return y + h + GAP
	end

	-- ================= block: three steps
	local function blockSteps(p, y, W)
		local frames = {}
		local names = { "1  Get key", "2  Paste", "3  Verify" }
		local sw = (W - PAD * 2 - GAP * 2) / 3
		for i = 1, 3 do
			local f = new("Frame", { Position = UDim2.fromOffset(PAD + (i - 1) * (sw + GAP), y), Size = UDim2.fromOffset(sw, 24), BackgroundColor3 = Color3.fromRGB(40, 24, 28), BorderSizePixel = 0 }, p)
			corner(f, 12)
			local tx = label(f, names[i], 10, C.Dim, true)
			tx.Size = UDim2.fromScale(1, 1)
			tx.TextXAlignment = Enum.TextXAlignment.Center
			frames[i] = { f, tx }
		end
		setStep = function(n, ok)
			for i, s in ipairs(frames) do
				local on = i <= n
				tween(s[1], 0.25, { BackgroundColor3 = on and (ok and Color3.fromRGB(40, 150, 80) or theme.Accent) or Color3.fromRGB(40, 24, 28) })
				s[2].TextColor3 = on and C.White or C.Dim
			end
		end
		setStep(1)
		return y + 24 + GAP
	end

	-- ================= block: get-key buttons, two per row
	local provs = o.Providers or {}
	local function blockProviders(p, y, W)
		if #provs == 0 then
			return y
		end
		local cap = label(p, o.ProvidersText or "GET YOUR KEY  (tap a button: the link is copied)", 9, theme.Glow, true)
		cap.Position = UDim2.fromOffset(PAD, y)
		cap.Size = UDim2.new(1, -PAD * 2, 0, 14)
		cap.TextXAlignment = Enum.TextXAlignment.Left
		y = y + 17
		local cw = (W - PAD * 2 - GAP) / 2
		for i, pr in ipairs(provs) do
			local pname = type(pr) == "table" and (pr.Name or pr[1]) or tostring(pr)
			local link = type(pr) == "table" and (pr.Link or pr[2]) or nil
			local info = providerInfo(pname) or {}
			local col = (type(pr) == "table" and pr.Color) or info.Color or theme.Accent
			local img = (type(pr) == "table" and pr.Image) or info.Image
			local r, cI = math.floor((i - 1) / 2), (i - 1) % 2
			local b = new("TextButton", { Position = UDim2.fromOffset(PAD + cI * (cw + GAP), y + r * 60), Size = UDim2.fromOffset(cw, 54), BackgroundColor3 = Color3.fromRGB(20, 12, 16), Text = "", AutoButtonColor = false, ClipsDescendants = true }, p)
			corner(b, 14)
			local bs = new("UIStroke", { Color = col, Thickness = 1.5, Transparency = 0.45 }, b)
			local fb = label(b, tostring(pname), 13, C.White, true)
			fb.Size = UDim2.fromScale(1, 1)
			fb.TextXAlignment = Enum.TextXAlignment.Center
			local im
			if img then
				im = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -14, 1, -12), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, ImageTransparency = 1, ZIndex = 3 }, b)
				corner(im, 10)
				RebelUI.SetImage(im, img, function(okI)
					if okI and im.Parent then
						tween(im, 0.3, { ImageTransparency = 0 })
						fb.Visible = false
					end
				end)
			end
			-- "copied" feedback: a small pill pops in at the corner, the border turns green, the logo stays visible
			local pill = new("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -6, 1, 40), Size = UDim2.fromOffset(86, 20), BackgroundColor3 = Color3.fromRGB(30, 160, 80), BorderSizePixel = 0, Visible = false, ZIndex = 8 }, b)
			corner(pill, 10)
			local ct = label(pill, "Link copied", 9, C.White, true)
			ct.Size = UDim2.fromScale(1, 1)
			ct.TextXAlignment = Enum.TextXAlignment.Center
			ct.ZIndex = 9
			local sc = new("UIScale", { Scale = o.ReduceMotion and 1 or 0 }, b)
			if not o.ReduceMotion then
				task.delay(0.25 + i * 0.07, function()
					tween(sc, 0.4, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end)
			end
			b.MouseEnter:Connect(function()
				tween(b, 0.15, { BackgroundColor3 = Color3.fromRGB(34, 20, 26) })
				tween(bs, 0.15, { Transparency = 0, Color = theme.Glow })
			end)
			b.MouseLeave:Connect(function()
				tween(b, 0.2, { BackgroundColor3 = Color3.fromRGB(20, 12, 16) })
				tween(bs, 0.2, { Transparency = 0.45, Color = col })
			end)
			local token = 0
			b.Activated:Connect(function()
				local ok = link and type(setclipboard) == "function" and pcall(setclipboard, link)
				token += 1
				local me = token
				tween(sc, 0.08, { Scale = 0.95 })
				task.delay(0.08, function()
					tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end)
				ct.Text = ok and "Link copied" or "No link set"
				pill.BackgroundColor3 = ok and Color3.fromRGB(30, 160, 80) or Color3.fromRGB(180, 50, 50)
				local good = ok and Color3.fromRGB(60, 220, 120) or Color3.fromRGB(235, 70, 70)
				tween(bs, 0.15, { Color = good, Transparency = 0, Thickness = 2.5 })
				pill.Position = UDim2.new(1, -6, 1, 40)
				pill.Visible = true
				tween(pill, 0.3, { Position = UDim2.new(1, -6, 1, -6) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				if im then
					tween(im, 0.15, { ImageTransparency = 0.25 })
				end
				if ok and setStep then
					setStep(2)
				end
				task.delay(1.4, function()
					if me ~= token or not b.Parent then
						return
					end
					tween(pill, 0.25, { Position = UDim2.new(1, -6, 1, 40) })
					task.delay(0.3, function()
						if me == token and pill.Parent then
							pill.Visible = false
						end
					end)
					tween(bs, 0.3, { Color = col, Transparency = 0.45, Thickness = 1.5 })
					if im then
						tween(im, 0.3, { ImageTransparency = 0 })
					end
				end)
			end)
		end
		return y + math.ceil(#provs / 2) * 60 + GAP - 6
	end

	-- ================= block: key box, verify, status, remember, tries
	local function blockKey(p, y, W)
		local kb = new("Frame", { Position = UDim2.fromOffset(PAD, y), Size = UDim2.new(1, -PAD * 2, 0, 42), BackgroundColor3 = Color3.fromRGB(244, 238, 238), BorderSizePixel = 0 }, p) -- light box so the black key icon shows
		corner(kb, 12)
		kst = new("UIStroke", { Color = Color3.fromRGB(150, 70, 80), Thickness = 1.5 }, kb)
		local kico = new("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Image = asset(RebelUI.Icons.newkey), ScaleType = Enum.ScaleType.Fit }, kb)
		RebelUI._iconFix(kico, RebelUI.Icons.newkey)
		box = new("TextBox", { Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -80, 1, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = "Paste your key here", PlaceholderColor3 = Color3.fromRGB(125, 100, 106), TextColor3 = Color3.fromRGB(25, 14, 18), TextSize = 12, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left }, kb)
		local clr = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Color3.fromRGB(226, 212, 214), Text = "X", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.fromRGB(90, 60, 66), AutoButtonColor = false }, kb)
		corner(clr, 12)
		clr.Activated:Connect(function()
			box.Text = ""
			if setStep then
				setStep(1)
			end
		end)
		box.Focused:Connect(function()
			tween(kst, 0.2, { Color = theme.Glow })
		end)
		box:GetPropertyChangedSignal("Text"):Connect(function()
			if result == nil and trim(box.Text) ~= "" and setStep then
				setStep(2)
			end
		end)
		y = y + 42 + GAP
		go = new("TextButton", { Position = UDim2.fromOffset(PAD, y), Size = UDim2.new(1, -PAD * 2, 0, 42), BackgroundColor3 = theme.Glow, Text = "", AutoButtonColor = false, ClipsDescendants = true }, p)
		corner(go, 12)
		lockI = new("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, Image = asset(RebelUI.Icons.padlock), ScaleType = Enum.ScaleType.Fit, ZIndex = 3 }, go)
		RebelUI._iconFix(lockI, RebelUI.Icons.padlock)
		gl = label(go, o.ButtonText or "VERIFY KEY", 14, C.White, true)
		gl.Font = Enum.Font.GothamBlack
		gl.Position = UDim2.fromOffset(46, 0) -- the text lives between the padlock (left) and an equal margin (right)
		gl.Size = UDim2.new(1, -92, 1, 0)
		gl.TextXAlignment = Enum.TextXAlignment.Center
		gl.TextTruncate = Enum.TextTruncate.AtEnd
		gl.ZIndex = 4
		if not o.ReduceMotion then
			local breathe = new("UIScale", { Scale = 1 }, go)
			pcall(function()
				TweenService:Create(breathe, TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Scale = 1.025 }):Play()
			end)
		end
		local shine = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(-0.3, 0.5), Size = UDim2.new(0, 30, 1.6, 0), Rotation = 20, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.78, BorderSizePixel = 0, ZIndex = 4 }, go)
		task.spawn(function()
			task.wait(0.9)
			while gui.Parent and result == nil do
				shine.Position = UDim2.fromScale(-0.2, 0.5)
				tween(shine, 0.8, { Position = UDim2.fromScale(1.2, 0.5) }, Enum.EasingStyle.Quad)
				task.wait(1.8)
			end
		end)
		y = y + 42 + GAP
		status = label(p, "Waiting for your key", 10, C.Dim, true)
		status.Position = UDim2.fromOffset(PAD, y)
		status.Size = UDim2.new(1, -PAD * 2, 0, 18)
		y = y + 18 + GAP - 2
		local rm = new("TextButton", { Position = UDim2.fromOffset(PAD, y), Size = UDim2.fromOffset(150, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, p)
		local rbox = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundColor3 = remember and theme.Accent or Color3.fromRGB(40, 24, 28), BorderSizePixel = 0 }, rm)
		corner(rbox, 4)
		local rtick = label(rbox, "✔", 12, C.White, true)
		rtick.Size = UDim2.fromScale(1, 1)
		rtick.Visible = remember
		local rl = label(rm, "Remember my key", 10, C.Dim, false)
		rl.Position = UDim2.fromOffset(26, 0)
		rl.Size = UDim2.new(1, -26, 1, 0)
		rl.TextXAlignment = Enum.TextXAlignment.Left
		rm.Activated:Connect(function()
			remember = not remember
			rtick.Visible = remember
			tween(rbox, 0.15, { BackgroundColor3 = remember and theme.Accent or Color3.fromRGB(40, 24, 28) })
		end)
		triesL = label(p, o.MaxTries and ("Tries 0/" .. o.MaxTries) or "", 10, C.Dim, false)
		triesL.AnchorPoint = Vector2.new(1, 0)
		triesL.Position = UDim2.new(1, -PAD, 0, y)
		triesL.Size = UDim2.fromOffset(110, 22)
		triesL.TextXAlignment = Enum.TextXAlignment.Right
		return y + 22 + GAP
	end

	-- ================= block: extra buttons + tagline
	local function blockFooter(p, y, W)
		if o.Buttons and #o.Buttons > 0 then
			local n = #o.Buttons
			local bw = (W - PAD * 2 - GAP * (n - 1)) / n
			for i, bd in ipairs(o.Buttons) do
				local col = pick(bd.Color, theme.Accent)
				local eb = new("TextButton", { Position = UDim2.fromOffset(PAD + (i - 1) * (bw + GAP), y), Size = UDim2.fromOffset(bw, 30), BackgroundColor3 = col, BackgroundTransparency = 0.25, Text = bd.Name or "Button", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.White, AutoButtonColor = false }, p)
				corner(eb, 9)
				eb.MouseEnter:Connect(function()
					tween(eb, 0.15, { BackgroundTransparency = 0 })
				end)
				eb.MouseLeave:Connect(function()
					tween(eb, 0.2, { BackgroundTransparency = 0.25 })
				end)
				eb.Activated:Connect(function()
					local was = eb.Text
					local ok = bd.Link and type(setclipboard) == "function" and pcall(setclipboard, bd.Link)
					eb.Text = ok and "Copied!" or (bd.Link or "...")
					if bd.Callback then
						pcall(bd.Callback)
					end
					task.delay(1.2, function()
						if eb.Parent then
							eb.Text = was
						end
					end)
				end)
			end
			y = y + 30 + GAP
		end
		if o.Tagline then
			local tg = label(p, tostring(o.Tagline), 9, C.Dim, false)
			tg.Position = UDim2.fromOffset(PAD, y)
			tg.Size = UDim2.new(1, -PAD * 2, 0, 14)
			y = y + 16
		end
		return y
	end

	-- the close button (top right of the card)
	local closeB = new("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 10), Size = UDim2.fromOffset(28, 28), BackgroundColor3 = Color3.fromRGB(60, 22, 28), Text = "X", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.Text, AutoButtonColor = false, ZIndex = 9 }, card)
	corner(closeB, 14)
	closeB.MouseEnter:Connect(function()
		tween(closeB, 0.15, { BackgroundColor3 = Color3.fromRGB(200, 40, 50) })
	end)
	closeB.MouseLeave:Connect(function()
		tween(closeB, 0.15, { BackgroundColor3 = Color3.fromRGB(60, 22, 28) })
	end)

	local H
	if wide then
		local yL = PAD
		yL = blockHeader(Lf, yL, LW)
		yL = blockNote(Lf, yL, LW)
		yL = blockSteps(Lf, yL, LW)
		yL = blockFooter(Lf, yL, LW)
		local yR = PAD + 22 -- room for the close button
		yR = blockProviders(Rf, yR, RW)
		yR = blockKey(Rf, yR, RW)
		H = math.max(yL, yR) + PAD - GAP
	else
		local y = PAD
		y = blockHeader(Lf, y, CW)
		y = blockNote(Lf, y, CW)
		y = blockSteps(Lf, y, CW)
		y = blockProviders(Lf, y, CW)
		y = blockKey(Lf, y, CW)
		y = blockFooter(Lf, y, CW)
		H = y + PAD - GAP
		Rf.Visible = false
	end
	card.Size = UDim2.fromOffset(CW, H)
	local fit = math.min(1, (vp.Y * 0.94) / H, (vp.X * 0.97) / CW)
	tween(scl, 0.45, { Scale = fit }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	if not o.ReduceMotion then
		task.spawn(function()
			task.wait(0.9)
			while gui.Parent and result == nil do
				tween(cstroke, 0.9, { Transparency = 0.55 }, Enum.EasingStyle.Sine)
				task.wait(0.9)
				tween(cstroke, 0.9, { Transparency = 0 }, Enum.EasingStyle.Sine)
				task.wait(0.9)
			end
		end)
	end
	if o.OpenBoom ~= false then
		task.delay(0.3, function()
			pcall(RebelUI.Boom, gui, { Color = theme.Glow, Count = 18, Style = o.BoomStyle, Image = o.BoomImage })
		end)
	end

	local busy, tries = false, 0
	local closedByX = false
	local spinConn
	local function submit()
		if busy or result ~= nil then
			return
		end
		busy = true
		setStep(3)
		status.TextColor3 = C.Dim
		status.Text = "Checking..."
		pcall(function()
			RebelUI._setIcon(lockI, RebelUI.Icons.loading)
			spinConn = game:GetService("RunService").RenderStepped:Connect(function(dt)
				lockI.Rotation = (lockI.Rotation + dt * 360) % 360
			end)
		end)
		task.spawn(function()
			local k = trim(box.Text)
			local good, ttl = valid(k)
			if spinConn then
				spinConn:Disconnect()
				spinConn = nil
			end
			lockI.Rotation = 0
			if good then
				status.TextColor3 = C.Green
				ttl = ttl or o.RememberFor
				RebelUI.KeyExpires = ttl and (os.time() + ttl) or nil
				status.Text = (o.SuccessText or "Correct. Welcome!") .. (ttl and ("  Key valid for " .. fmtTime(ttl)) or "")
				pcall(function()
					RebelUI._setIcon(lockI, RebelUI.Icons.openpadlock)
				end)
				gl.Text = "UNLOCKED"
				setStep(3, true)
				tween(cstroke, 0.2, { Color = C.Green })
				if remember and type(writefile) == "function" then
					pcall(writefile, file, k .. "\n" .. (RebelUI.KeyExpires or "") .. (o.HwidBind and ("\n" .. (RebelUI.GetHWID() or "")) or ""))
				end
				savedKey = k
				if o.Boom ~= false then
					pcall(RebelUI.Boom, gui, { Color = theme.Glow, Count = 28, Text = o.BoomText, Style = o.BoomStyle, Image = o.BoomImage })
					task.wait(0.9)
				else
					task.wait(0.5)
				end
				result = true
			else
				tries += 1
				pcall(function()
					RebelUI._setIcon(lockI, RebelUI.Icons.padlock)
				end)
				setStep(2)
				status.TextColor3 = C.Bad
				status.Text = k == "" and "Type your key first." or "That key is not right. Try again."
				tween(kst, 0.1, { Color = C.Bad })
				if o.MaxTries then
					triesL.Text = "Tries " .. tries .. "/" .. o.MaxTries
				end
				if not o.ReduceMotion then
					for _, dx in ipairs({ -9, 9, -6, 6, 0 }) do
						card.Position = UDim2.new(0.5, dx, 0.5, 0)
						task.wait(0.04)
					end
				end
				if o.MaxTries and tries >= o.MaxTries then
					task.wait(0.8)
					result = false
				end
			end
			busy = false
		end)
	end
	go.Activated:Connect(submit)
	box.FocusLost:Connect(function(enter)
		if enter then
			submit()
		end
	end)
	closeB.Activated:Connect(function()
		closedByX = true
		result = false
	end)
	local waited = 0
	while result == nil do
		task.wait(0.1)
		waited += 0.1
		if o.Timeout and waited >= o.Timeout then
			result = false
		end
	end
	if spinConn then
		spinConn:Disconnect()
	end
	if o.Blur ~= false then
		RebelUI.Blur(0, 0.6)
	end
	if closedByX and o.CloseAnimation and o.CloseAnimation ~= "None" and not o.ReduceMotion then
		RebelUI.CloseEffect(gui, card, o.CloseAnimation == true and "BlackHole" or o.CloseAnimation, { Color = theme.Glow, Move = true, Media = o.CloseMedia })
	end
	tween(scl, 0.2, { Scale = 0.7 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	tween(back, 0.2, { BackgroundTransparency = 1 })
	task.wait(0.2)
	gui:Destroy()
	if result then
		return true, savedKey, RebelUI.KeyExpires
	end
	return false
end

-- how the panel is opened: a round logo button, a square logo button, or the top bar
function Window:SetTrigger(style, barOpts)
	style = tostring(style or "Circle")
	if style ~= "Circle" and style ~= "Square" and style ~= "Bar" then
		style = "Circle"
	end
	self.TriggerStyle = style
	if style == "Bar" then
		if not self._bar then
			self:CreateBar(barOpts or self._barOpts or { Items = { "FPS", "Logo", "Timer" }, Logo = self._icon })
		end
		self._bar:Show(true)
		self._hasBar = true
		self._fab.Visible = false
	else
		if self._bar then
			self._bar:Show(false)
		end
		self._hasBar = false
		local rad = style == "Circle" and math.floor((self._fabSize or 44) / 2) or 8
		if self._fabCorner then
			self._fabCorner.CornerRadius = UDim.new(0, rad)
		end
		if self._fabImgCorner then
			self._fabImgCorner.CornerRadius = UDim.new(0, rad)
		end
		self._fab.Visible = not self.Open
	end
	return style
end

-- ============================================================ game assistant (full-screen HUD)
-- win:GameAssistant({ Logo, Title, Color = "Rainbow", Crosshair = "Cross", Key, OnSummary = function(hud, done) end })
-- hud:Open() :Close() :Toggle() :SetColor(name) :SetCrosshair(name) :CrosshairInGame(bool) :Show(panel, bool)
-- hud:Target(name | "nearest" | nil) :Spectate(name | nil) :Command("crosshair dot") :GetSummary() :ShowBrief(text) :Destroy()
local HUD_COLORS = {
	Rainbow = "rainbow",
	Theme = "theme",
	Red = Color3.fromRGB(255, 48, 56),
	Cyan = Color3.fromRGB(40, 220, 255),
	Lime = Color3.fromRGB(120, 255, 90),
	Gold = Color3.fromRGB(255, 200, 60),
	Pink = Color3.fromRGB(255, 80, 200),
	Violet = Color3.fromRGB(160, 100, 255),
}
RebelUI.HudColors = { "Rainbow", "Theme", "Red", "Cyan", "Lime", "Gold", "Pink", "Violet" }
RebelUI.Crosshairs = { "Cross", "Dot", "Circle", "Chevron", "Diamond", "X", "Plus", "Square", "Sniper" }
RebelUI.CrossSizes = { Small = 50, Medium = 90, Large = 140, XL = 200 }
RebelUI.HudPresets = { "Low", "Medium", "High", "Extreme" }

local function hudBattery()
	local tries = { { "Stats", "BatteryLevel" }, { "UserInputService", "BatteryLevel" }, { "GuiService", "BatteryLevel" }, { "PlatformService", "BatteryLevel" } }
	for _, t in ipairs(tries) do
		local ok, v = pcall(function()
			return game:GetService(t[1])[t[2]]
		end)
		if ok and type(v) == "number" and v >= 0 then
			return v <= 1 and v * 100 or v
		end
	end
	for _, name in ipairs({ "getbatterylevel", "get_battery_level" }) do
		local f = getgenv and getgenv()[name]
		if type(f) == "function" then
			local ok, v = pcall(f)
			if ok and type(v) == "number" then
				return v <= 1 and v * 100 or v
			end
		end
	end
	return nil
end

-- draws one crosshair style inside `parent`. paint(inst, prop) registers things that follow the HUD color.
local function drawCross(parent, style, s, paint, th, alpha)
	th = th or 2
	alpha = alpha or 0
	for _, c in ipairs(parent:GetChildren()) do
		c:Destroy()
	end
	local function bar(x, y, w, h, rot)
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, x, 0.5, y),
			Size = UDim2.fromOffset(w, h),
			BorderSizePixel = 0,
			Rotation = rot or 0,
			BackgroundTransparency = alpha,
			BackgroundColor3 = Color3.new(1, 1, 1),
		}, parent)
		paint(f, "BackgroundColor3")
		return f
	end
	local function ring(d, t2)
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(d, d),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, parent)
		corner(f, d)
		local st = new("UIStroke", { Thickness = t2 or th, Transparency = alpha, Color = Color3.new(1, 1, 1) }, f)
		paint(st, "Color")
		return f
	end
	local dotS = math.max(3, th * 1.6)
	local g, L = math.floor(s * 0.1), math.floor(s * 0.28)
	if style == "Dot" then
		bar(0, 0, dotS * 1.6, dotS * 1.6)
		ring(s * 0.5)
	elseif style == "Circle" then
		ring(s * 0.6)
		bar(0, 0, dotS, dotS)
	elseif style == "Chevron" then
		bar(-s * 0.08, 0, L, th, 35)
		bar(s * 0.08, 0, L, th, -35)
		bar(0, s * 0.16, dotS, dotS)
	elseif style == "Diamond" then
		local d = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(s * 0.34, s * 0.34),
			Rotation = 45,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, parent)
		paint(new("UIStroke", { Thickness = th, Transparency = alpha, Color = Color3.new(1, 1, 1) }, d), "Color")
		bar(0, 0, dotS, dotS)
	elseif style == "Square" then
		local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(s * 0.4, s * 0.4), BackgroundTransparency = 1, BorderSizePixel = 0 }, parent)
		paint(new("UIStroke", { Thickness = th, Transparency = alpha, Color = Color3.new(1, 1, 1) }, d), "Color")
		bar(0, 0, dotS, dotS)
	elseif style == "X" then
		local o2 = g + L * 0.35
		for _, p in ipairs({ { -o2, -o2, 45 }, { o2, -o2, -45 }, { -o2, o2, -45 }, { o2, o2, 45 } }) do
			bar(p[1], p[2], L * 0.8, th, p[3])
		end
	elseif style == "Plus" then
		bar(0, -(g + L / 2), th, L)
		bar(0, g + L / 2, th, L)
		bar(-(g + L / 2), 0, L, th)
		bar(g + L / 2, 0, L, th)
	elseif style == "Sniper" then
		bar(0, 0, s, math.max(1, th * 0.5))
		bar(0, 0, math.max(1, th * 0.5), s)
		ring(s * 0.28, math.max(1, th * 0.6))
		bar(0, 0, dotS, dotS)
	else -- Cross
		bar(0, -(g + L / 2), th, L)
		bar(0, g + L / 2, th, L)
		bar(-(g + L / 2), 0, L, th)
		bar(g + L / 2, 0, L, th)
		bar(0, 0, dotS, dotS)
	end
end

-- Win:SetAssistant({ ... same options as GameAssistant ... }): remember the options and build the HUD only when it is first needed.
function Window:SetAssistant(o)
	self._hudOpts = o or {}
	if o and o.Key and not self._hudKey then
		self._hudKey = UIS.InputBegan:Connect(function(i, gp)
			if not gp and i.KeyCode == o.Key then
				self:_hud():Toggle()
			end
		end)
		self._conns[#self._conns + 1] = self._hudKey
		self._hudOpts = setmetatable({ Key = false }, { __index = o })
	end
end
function Window:_hud()
	return self.HUD or self:GameAssistant(self._hudOpts or { Logo = self._icon })
end

function Window:GameAssistant(o)
	o = o or self._hudOpts or {}
	local win = self
	if win.HUD and not win.HUD._dead then
		return win.HUD
	end
	local lp = Players.LocalPlayer
	local hud = { IsOpen = false, ColorName = HUD_COLORS[o.Color or "Rainbow"] and (o.Color or "Rainbow") or "Rainbow", CrossName = o.Crosshair or "Cross", CrossSize = o.CrosshairSize or 90, CrossThick = 2, CrossAlpha = 0, Preset = "Medium", Interval = 0.35, Fancy = true, Boost = 1, _panels = {}, _glows = {}, _dead = false }
	win.HUD = hud
	local name = o.Name or "RebelUI_HUD"
	clearOld(name)
	local gui = new("ScreenGui", { Name = name, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 998, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = false })
	pcall(function()
		gui.ScreenInsets = Enum.ScreenInsets.None
	end)
	gui.Parent = pickParent()
	RebelUI._fancyGui(gui)
	hud.Gui = gui

	local root = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0 }, gui)
	new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(4, 2, 4), BackgroundTransparency = 0.62, BorderSizePixel = 0, ZIndex = 1 }, root)
	for i = 0, 1 do -- dark bands top and bottom
		local b = new("Frame", { Size = UDim2.new(1, 0, 0.22, 0), Position = UDim2.fromScale(0, i == 0 and 0 or 0.78), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 1 }, root)
		new("UIGradient", { Rotation = i == 0 and 90 or -90, Transparency = NumberSequence.new(0.2, 1) }, b)
	end
	local ui = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, root)
	local sc = new("UIScale", {}, ui)
	local function relayout()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(800, 450)
		local s = math.clamp(vp.Y / 560, 0.62, 1.35) * (hud.Boost or 1)
		sc.Scale = s
		ui.Size = UDim2.fromScale(1 / s, 1 / s)
	end
	relayout()
	hud._relayout = relayout
	pcall(function()
		win._conns[#win._conns + 1] = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(relayout)
	end)

	-- ---------- colors: everything registered here follows the HUD color (rainbow / theme / fixed)
	local paints, grads = {}, {}
	local function paint(inst, prop)
		table.insert(paints, { inst, prop })
		return inst
	end
	local function curColor(now)
		local c = HUD_COLORS[hud.ColorName]
		if c == "rainbow" then
			return Color3.fromHSV((now * 0.12) % 1, 0.82, 1)
		elseif c == "theme" then
			return win.Theme.Glow
		end
		return c
	end
	local function gradSeq()
		local c = HUD_COLORS[hud.ColorName]
		if c == "rainbow" then
			local k = {}
			for i = 0, 6 do
				k[#k + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 0.85, 1))
			end
			return ColorSequence.new(k)
		end
		c = c == "theme" and win.Theme.Glow or c
		return ColorSequence.new({
			ColorSequenceKeypoint.new(0, c),
			ColorSequenceKeypoint.new(0.35, c:Lerp(Color3.new(0, 0, 0), 0.7)),
			ColorSequenceKeypoint.new(0.5, c:Lerp(Color3.new(1, 1, 1), 0.5)),
			ColorSequenceKeypoint.new(0.65, c:Lerp(Color3.new(0, 0, 0), 0.7)),
			ColorSequenceKeypoint.new(1, c),
		})
	end
	local function neon(stroke) -- a stroke whose gradient races around the edge
		stroke.Color = Color3.new(1, 1, 1)
		local g = new("UIGradient", { Color = gradSeq() }, stroke)
		table.insert(grads, g)
		return stroke
	end
	local function applyColors(now)
		local c = curColor(now or os.clock())
		for i = #paints, 1, -1 do
			local pi = paints[i]
			if pi[1].Parent == nil then
				table.remove(paints, i) -- the thing was destroyed (a redrawn crosshair)
			else
				pi[1][pi[2]] = c
			end
		end
	end
	local function applyGrads()
		local seq = gradSeq()
		for _, g in ipairs(grads) do
			g.Color = seq
		end
	end

	local DARK = Color3.fromRGB(10, 6, 9)
	local function text(parent, str, size, bold, pos, sz, align, accent, z)
		local l = new("TextLabel", {
			BackgroundTransparency = 1,
			Text = str,
			TextSize = size,
			Font = bold and Enum.Font.GothamBlack or Enum.Font.GothamMedium,
			TextColor3 = accent and Color3.new(1, 1, 1) or Color3.fromRGB(235, 230, 232),
			TextXAlignment = align or Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = pos,
			Size = sz or UDim2.new(1, 0, 0, size + 2),
			ZIndex = z or 6,
			RichText = false,
		}, parent)
		if accent then
			paint(l, "TextColor3")
		end
		return l
	end

	-- a sharp panel: dark glass, racing neon edge, glow, corner brackets, slanted header
	local function panel(key, pos, size, title, anchor)
		local f = new("Frame", { Position = pos, Size = size, AnchorPoint = anchor or Vector2.new(0, 0), BackgroundColor3 = DARK, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 3 }, ui)
		neon(new("UIStroke", { Thickness = 1.8, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f))
		local glow = new("Frame", { Position = UDim2.fromOffset(-4, -4), Size = UDim2.new(1, 8, 1, 8), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 2 }, f)
		local gs = neon(new("UIStroke", { Thickness = 5, Transparency = 0.78, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, glow))
		gs.Transparency = 0.78
		table.insert(hud._glows, glow)
		for _, c in ipairs({ { 0, 0, 1, 1 }, { 1, 0, -1, 1 }, { 0, 1, 1, -1 }, { 1, 1, -1, -1 } }) do
			local ax, ay = c[1], c[2]
			local h = new("Frame", { AnchorPoint = Vector2.new(ax, ay), Position = UDim2.fromScale(ax, ay), Size = UDim2.fromOffset(16, 3), BorderSizePixel = 0, ZIndex = 7, BackgroundColor3 = Color3.new(1, 1, 1) }, f)
			local v = new("Frame", { AnchorPoint = Vector2.new(ax, ay), Position = UDim2.fromScale(ax, ay), Size = UDim2.fromOffset(3, 16), BorderSizePixel = 0, ZIndex = 7, BackgroundColor3 = Color3.new(1, 1, 1) }, f)
			paint(h, "BackgroundColor3")
			paint(v, "BackgroundColor3")
		end
		if title then
			local hd = new("Frame", { Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 4 }, f)
			paint(hd, "BackgroundColor3")
			new("UIGradient", { Transparency = NumberSequence.new(0, 1) }, hd)
			text(f, title, 13, true, UDim2.fromOffset(26, 6), UDim2.new(1, -60, 0, 16), nil, true)
			for i = 0, 2 do -- slanted slashes
				local sl = new("Frame", { Position = UDim2.fromOffset(8 + i * 5, 8), Size = UDim2.fromOffset(2, 13), Rotation = 25, BorderSizePixel = 0, ZIndex = 7, BackgroundColor3 = Color3.new(1, 1, 1) }, f)
				paint(sl, "BackgroundColor3")
			end
			local ln = new("Frame", { Position = UDim2.fromOffset(0, 28), Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 5, BackgroundColor3 = Color3.new(1, 1, 1) }, f)
			paint(ln, "BackgroundColor3")
			new("UIGradient", { Transparency = NumberSequence.new(0.1, 1) }, ln)
		end
		hud._panels[key] = f
		return f
	end

	local function bar(parent, pos, size, z)
		local back = new("Frame", { Position = pos, Size = size, BackgroundColor3 = Color3.fromRGB(34, 28, 32), BorderSizePixel = 0, ZIndex = z or 6 }, parent)
		local fill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = (z or 6) + 1 }, back)
		return back, fill
	end

	-- ---------- top: logo, banner, close, AI brief
	local logo = new("Frame", { Position = UDim2.fromOffset(14, 10), Size = UDim2.fromOffset(150, 40), BackgroundTransparency = 1, ZIndex = 5 }, ui)
	if o.Logo then
		new("ImageLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 36), Image = asset(o.Logo), ZIndex = 6 }, logo)
	end
	text(logo, "REBELUI", 20, true, UDim2.fromOffset(o.Logo and 44 or 0, 4), UDim2.new(1, -44, 0, 30), nil, true)

	local banner = panel("banner", UDim2.new(0.5, 0, 0, 8), UDim2.fromOffset(330, 46), nil, Vector2.new(0.5, 0))
	hud._title = text(banner, o.Title or "ELITE GAME ASSISTANT", 15, true, UDim2.fromOffset(0, 6), UDim2.new(1, 0, 0, 18), Enum.TextXAlignment.Center, true)
	hud._sub = text(banner, "", 10, false, UDim2.fromOffset(0, 26), UDim2.new(1, 0, 0, 14), Enum.TextXAlignment.Center)
	hud._sub.TextColor3 = Color3.fromRGB(180, 170, 175)

	local function chipButton(parent, label, pos, size, cb)
		local b = new("TextButton", { Position = pos, Size = size, BackgroundColor3 = DARK, BackgroundTransparency = 0.15, BorderSizePixel = 0, Text = label, TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, ZIndex = 8 }, parent)
		neon(new("UIStroke", { Thickness = 1.3, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b))
		b.MouseButton1Click:Connect(function()
			win:_playClick()
			cb(b)
		end)
		return b
	end
	chipButton(ui, "X", UDim2.new(1, -52, 0, 10), UDim2.fromOffset(40, 34), function()
		hud:Close()
	end)
	chipButton(ui, "PANEL", UDim2.new(1, -112, 0, 10), UDim2.fromOffset(54, 34), function()
		win:Toggle(true)
	end)
	local brief = chipButton(ui, "BRIEF", UDim2.new(1, -184, 0, 10), UDim2.fromOffset(66, 34), function(b)
		hud:Brief()
	end)

	-- color chips (top left) and crosshair chips (top center)
	local function chipRow(pos, width, items, current, cb)
		local sf = new("ScrollingFrame", { Position = pos, Size = UDim2.fromOffset(width, 26), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, ZIndex = 6 }, ui)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, sf)
		local btns = {}
		for i, it in ipairs(items) do
			local b = new("TextButton", { Size = UDim2.fromOffset(#it * 7 + 18, 24), LayoutOrder = i, BackgroundColor3 = DARK, BackgroundTransparency = 0.2, BorderSizePixel = 0, Text = it, TextSize = 10, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(200, 195, 198), AutoButtonColor = false, ZIndex = 7 }, sf)
			local st = new("UIStroke", { Thickness = 1, Color = Color3.fromRGB(70, 60, 66), ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b)
			btns[it] = { b, st }
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				cb(it)
			end)
		end
		return function(sel)
			for k, v in pairs(btns) do
				local on = k == sel
				v[1].TextColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(200, 195, 198)
				v[1].BackgroundTransparency = on and 0.0 or 0.2
				v[2].Color = on and Color3.new(1, 1, 1) or Color3.fromRGB(70, 60, 66)
			end
		end
	end
	local markColor = chipRow(UDim2.fromOffset(14, 58), 250, RebelUI.HudColors, hud.ColorName, function(n)
		hud:SetColor(n)
	end)
	local sizeNames = { "Small", "Medium", "Large", "XL" }
	local markSize = chipRow(UDim2.fromOffset(14, 88), 250, sizeNames, "Medium", function(n)
		hud:SetCrosshairSize(n)
	end)
	local markPreset = chipRow(UDim2.fromOffset(14, 118), 280, RebelUI.HudPresets, "Medium", function(n)
		hud:SetPreset(n)
	end)
	local markCross = chipRow(UDim2.new(0.5, -150, 0, 62), 300, RebelUI.Crosshairs, hud.CrossName, function(n)
		hud:SetCrosshair(n)
	end)

	-- ---------- left middle: your stats
	local stats = panel("stats", UDim2.new(0, 14, 0.5, -112), UDim2.fromOffset(216, 232), "YOUR STATS")
	local srow = {}
	local function statRow(i, label)
		local y = 36 + (i - 1) * 32
		local lb = text(stats, label, 10, true, UDim2.fromOffset(14, y), UDim2.new(0.5, 0, 0, 12))
		lb.TextColor3 = Color3.fromRGB(170, 160, 165)
		local v = text(stats, "-", 14, true, UDim2.fromOffset(14, y + 11), UDim2.new(0.55, 0, 0, 16), nil, true)
		local back, fill = bar(stats, UDim2.new(0.5, 6, 0, y + 14), UDim2.new(0.5, -20, 0, 6))
		paint(fill, "BackgroundColor3")
		srow[label] = { v = v, fill = fill }
	end
	for i, l in ipairs({ "PING", "FPS", "BATTERY", "MEMORY", "SPEED" }) do
		statRow(i, l)
	end
	hud._session = text(stats, "SESSION 00:00", 10, true, UDim2.fromOffset(14, 202), UDim2.new(1, -28, 0, 12))
	hud._session.TextColor3 = Color3.fromRGB(170, 160, 165)

	-- ---------- bottom left: your health
	local health = panel("health", UDim2.new(0, 14, 1, -96), UDim2.fromOffset(310, 84), "HEALTH")
	local hpText = text(health, "100 / 100", 22, true, UDim2.fromOffset(14, 34), UDim2.new(0.6, 0, 0, 26), nil, false)
	local hpName = text(health, "", 10, true, UDim2.new(1, -150, 0, 40), UDim2.fromOffset(136, 14), Enum.TextXAlignment.Right)
	hpName.TextColor3 = Color3.fromRGB(170, 160, 165)
	local hpBack, hpFill = bar(health, UDim2.fromOffset(14, 62), UDim2.new(1, -28, 0, 12))
	for i = 1, 9 do -- segment lines
		new("Frame", { Position = UDim2.new(i / 10, 0, 0, 0), Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Color3.fromRGB(10, 6, 9), BorderSizePixel = 0, ZIndex = 9 }, hpBack)
	end

	-- ---------- right: players
	local plist = panel("players", UDim2.new(1, -234, 0, 96), UDim2.new(0, 220, 1, -300), "PLAYERS")
	local pcount = text(plist, "", 12, true, UDim2.new(1, -90, 0, 7), UDim2.fromOffset(78, 14), Enum.TextXAlignment.Right, true)
	local scroll = new("ScrollingFrame", { Position = UDim2.fromOffset(6, 34), Size = UDim2.new(1, -12, 1, -40), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 5 }, plist)
	paint(scroll, "ScrollBarImageColor3")
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
	local rows = {}

	-- ---------- right bottom: your profile
	local prof = panel("profile", UDim2.new(1, -234, 1, -192), UDim2.fromOffset(220, 180), "YOU")
	local avatar = new("ImageLabel", { Position = UDim2.fromOffset(12, 38), Size = UDim2.fromOffset(84, 84), BackgroundColor3 = Color3.fromRGB(26, 20, 24), BorderSizePixel = 0, ZIndex = 6, Image = "" }, prof)
	paint(new("UIStroke", { Thickness = 1.5 }, avatar), "Color")
	pcall(function()
		avatar.Image = "rbxthumb://type=AvatarBust&id=" .. lp.UserId .. "&w=150&h=150"
	end)
	text(prof, lp.DisplayName, 16, true, UDim2.fromOffset(106, 40), UDim2.new(1, -116, 0, 20), nil, true)
	local un = text(prof, "@" .. lp.Name, 11, false, UDim2.fromOffset(106, 62), UDim2.new(1, -116, 0, 14))
	un.TextColor3 = Color3.fromRGB(180, 170, 175)
	local pid = text(prof, "ID " .. tostring(lp.UserId), 10, false, UDim2.fromOffset(106, 80), UDim2.new(1, -116, 0, 12))
	pid.TextColor3 = Color3.fromRGB(140, 130, 135)
	local age = text(prof, "ACCOUNT " .. tostring(lp.AccountAge) .. " DAYS", 10, true, UDim2.fromOffset(12, 130), UDim2.new(1, -24, 0, 12))
	age.TextColor3 = Color3.fromRGB(170, 160, 165)
	hud._where = text(prof, "", 10, true, UDim2.fromOffset(12, 148), UDim2.new(1, -24, 0, 24), nil, true)
	hud._where.TextWrapped = true
	hud._where.TextTruncate = Enum.TextTruncate.None

	-- ---------- center: radar crosshair
	local center = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(260, 260), BackgroundTransparency = 1, ZIndex = 4 }, ui)
	hud._panels.crosshair = center
	local function ringF(d, th, tr)
		local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(d, d), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 4 }, center)
		corner(f, d)
		local st = new("UIStroke", { Thickness = th, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
		return f, st
	end
	local _, st1 = ringF(252, 2)
	neon(st1)
	local _, st2 = ringF(256, 7, 0.82)
	neon(st2)
	local _, st3 = ringF(170, 1.2, 0.2)
	neon(st3)
	local _, st4 = ringF(80, 1, 0.5)
	paint(st4, "Color")
	local ticks = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(236, 236), BackgroundTransparency = 1, ZIndex = 4 }, center)
	for i = 0, 59 do
		local a = math.rad(i * 6)
		local long = i % 5 == 0
		local t = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, math.sin(a) * 114, 0.5, -math.cos(a) * 114), Size = UDim2.fromOffset(long and 3 or 1.5, long and 11 or 6), Rotation = i * 6, BorderSizePixel = 0, ZIndex = 4, BackgroundColor3 = Color3.new(1, 1, 1) }, ticks)
		paint(t, "BackgroundColor3")
	end
	local arcs = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(190, 190), BackgroundTransparency = 1, ZIndex = 4 }, center)
	for i = 0, 35 do
		if i % 12 < 4 then
			local a = math.rad(i * 10)
			local t = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, math.sin(a) * 90, 0.5, -math.cos(a) * 90), Size = UDim2.fromOffset(5, 13), Rotation = i * 10, BorderSizePixel = 0, ZIndex = 4, BackgroundColor3 = Color3.new(1, 1, 1) }, arcs)
			paint(t, "BackgroundColor3")
		end
	end
	local sweep = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(170, 2), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 4 }, center)
	paint(sweep, "BackgroundColor3")
	new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0) }) }, sweep)
	local dots = {} -- other players on the radar
	local cross = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(90, 90), BackgroundTransparency = 1, ZIndex = 8 }, center)
	local function redrawCross()
		cross.Size = UDim2.fromOffset(hud.CrossSize, hud.CrossSize)
		drawCross(cross, hud.CrossName, hud.CrossSize, paint, hud.CrossThick, hud.CrossAlpha)
		applyColors()
	end
	hud._target = text(ui, "", 12, true, UDim2.new(0.5, -130, 0.5, -170), UDim2.fromOffset(260, 16), Enum.TextXAlignment.Center, true)

	-- ---------- in-game crosshair (stays on screen after the HUD closes)
	local cgui = new("ScreenGui", { Name = name .. "_Cross", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 997, Enabled = false }, nil)
	clearOld(name .. "_Cross")
	cgui.Parent = pickParent()
	local cbox = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(60, 60), BackgroundTransparency = 1 }, cgui)
	local function redrawGameCross()
		cbox.Size = UDim2.fromOffset(hud.CrossSize, hud.CrossSize)
		drawCross(cbox, hud.CrossName, hud.CrossSize, paint, hud.CrossThick, hud.CrossAlpha)
		applyColors()
	end

	-- ---------- brief card (AI summary)
	local card = panel("brief", UDim2.new(0.5, 0, 1, -150), UDim2.fromOffset(420, 120), "BRIEF", Vector2.new(0.5, 0))
	card.Visible = false
	hud._briefText = text(card, "", 12, false, UDim2.fromOffset(14, 36), UDim2.new(1, -28, 1, -44))
	hud._briefText.TextWrapped = true
	hud._briefText.TextYAlignment = Enum.TextYAlignment.Top
	hud._briefText.TextTruncate = Enum.TextTruncate.None
	hud._briefText.RichText = false
	hud._briefText.TextSize = 12
	local briefToken = 0
	function hud:ShowBrief(str, hold)
		briefToken += 1
		local my = briefToken
		hud._briefText.Text = tostring(str or "")
		card.Visible = true
		hud._panels.brief = nil
		task.delay(hold or 14, function()
			if briefToken == my then
				card.Visible = false
			end
		end)
	end
	function hud:Brief()
		if type(o.OnSummary) == "function" then
			hud:ShowBrief("Reading the room...", 30)
			local ok, err = pcall(o.OnSummary, hud, function(result)
				hud:ShowBrief(result, 18)
			end)
			if not ok then
				hud:ShowBrief("The summary failed: " .. tostring(err), 6)
			end
		else
			hud:ShowBrief(hud:GetSummary(), 18)
		end
	end

	-- ---------- extras: damage flash, status tags, compare card, hotbar
	local vig = {}
	for i, e in ipairs({ { UDim2.new(1, 0, 0.2, 0), UDim2.fromScale(0, 0), 90 }, { UDim2.new(1, 0, 0.2, 0), UDim2.fromScale(0, 0.8), -90 }, { UDim2.new(0.12, 0, 1, 0), UDim2.fromScale(0, 0), 0 }, { UDim2.new(0.12, 0, 1, 0), UDim2.fromScale(0.88, 0), 180 } }) do
		local v = new("Frame", { Size = e[1], Position = e[2], BackgroundColor3 = Color3.fromRGB(255, 20, 30), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1, Active = false }, root)
		new("UIGradient", { Rotation = e[3], Transparency = NumberSequence.new(0, 1) }, v)
		vig[i] = v
	end
	function hud:_damage(n)
		for _, v in ipairs(vig) do
			v.BackgroundTransparency = math.clamp(0.75 - n / 80, 0.15, 0.7)
			tween(v, 0.7, { BackgroundTransparency = 1 })
		end
		local t = text(ui, "-" .. math.floor(n), 24, true, UDim2.new(0.5, math.random(-40, 40), 0.5, 40), UDim2.fromOffset(80, 28), Enum.TextXAlignment.Center, false, 12)
		t.AnchorPoint = Vector2.new(0.5, 0.5)
		t.TextColor3 = Color3.fromRGB(255, 70, 70)
		tween(t, 0.9, { Position = t.Position - UDim2.fromOffset(0, 60), TextTransparency = 1 })
		task.delay(1, function()
			t:Destroy()
		end)
	end
	hud._status = text(ui, "", 11, true, UDim2.new(0, 16, 1, -118), UDim2.fromOffset(320, 16), nil, true)
	local cmp = panel("compare", UDim2.new(0.5, 0, 0, 96), UDim2.fromOffset(300, 62), nil, Vector2.new(0.5, 0))
	cmp.Visible = false
	local cmpL = text(cmp, "", 11, true, UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 48))
	cmpL.TextWrapped = true
	cmpL.TextYAlignment = Enum.TextYAlignment.Top
	cmpL.TextTruncate = Enum.TextTruncate.None
	local hot = panel("hotbar", UDim2.new(0.5, 0, 1, -64), UDim2.fromOffset(200, 52), nil, Vector2.new(0.5, 0))
	hot.Visible = false
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder }, hot)
	local lastHp
	local sh

	-- ---------- data
	local Stats = game:GetService("Stats")
	local fps, frames, acc, started = 60, 0, 0, os.clock()
	local function hum(p)
		local ch = p and p.Character
		return ch and ch:FindFirstChildOfClass("Humanoid"), ch and ch:FindFirstChild("HumanoidRootPart")
	end
	local function distTo(p)
		local _, mine = hum(lp)
		local _, theirs = hum(p)
		if mine and theirs then
			return (mine.Position - theirs.Position).Magnitude
		end
		return nil
	end
	local targetPlayer = nil
	local hl
	local function setTarget(p)
		targetPlayer = p
		if hl then
			hl:Destroy()
			hl = nil
		end
		if p and p.Character then
			pcall(function()
				hl = new("Highlight", { FillTransparency = 0.75, OutlineTransparency = 0, FillColor = Color3.fromRGB(255, 60, 60), OutlineColor = Color3.new(1, 1, 1), Name = "RebelHUDTarget" }, p.Character)
			end)
		end
	end
	local function findPlayer(q)
		q = tostring(q or ""):lower()
		if q == "" then
			return nil
		end
		local best
		for _, p in ipairs(Players:GetPlayers()) do
			local a, b = p.Name:lower(), p.DisplayName:lower()
			if a == q or b == q then
				return p
			elseif (a:find(q, 1, true) or b:find(q, 1, true)) and not best then
				best = p
			end
		end
		return best
	end
	local function nearest()
		local best, bd = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local d = distTo(p)
				if d and d < bd then
					best, bd = p, d
				end
			end
		end
		return best, bd
	end

	local function makeRow(p)
		local r = new("TextButton", { Size = UDim2.new(1, -2, 0, 40), BackgroundColor3 = Color3.fromRGB(26, 18, 22), BackgroundTransparency = 0.25, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 6 }, scroll)
		local img = new("ImageLabel", { Position = UDim2.fromOffset(4, 4), Size = UDim2.fromOffset(32, 32), BackgroundColor3 = Color3.fromRGB(40, 30, 35), BorderSizePixel = 0, ZIndex = 7, Image = "" }, r)
		pcall(function()
			img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. p.UserId .. "&w=100&h=100"
		end)
		local nm = text(r, p.DisplayName, 12, true, UDim2.fromOffset(42, 3), UDim2.new(1, -92, 0, 14), nil, false, 7)
		local un2 = text(r, "@" .. p.Name, 9, false, UDim2.fromOffset(42, 17), UDim2.new(1, -92, 0, 11), nil, false, 7)
		un2.TextColor3 = Color3.fromRGB(150, 140, 145)
		local dl = text(r, "", 11, true, UDim2.new(1, -52, 0, 4), UDim2.fromOffset(48, 13), Enum.TextXAlignment.Right, true, 7)
		local hb, hf = bar(r, UDim2.fromOffset(42, 32), UDim2.new(1, -50, 0, 4), 7)
		local st = new("UIStroke", { Thickness = 1.3, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, r)
		paint(st, "Color")
		r.MouseButton1Click:Connect(function()
			win:_playClick()
			if targetPlayer == p then
				setTarget(nil)
			else
				setTarget(p)
			end
		end)
		rows[p] = { f = r, d = dl, hf = hf, st = st, nm = nm }
	end
	local function dropRow(p)
		if rows[p] then
			rows[p].f:Destroy()
			rows[p] = nil
		end
		if targetPlayer == p then
			setTarget(nil)
		end
	end
	win._conns[#win._conns + 1] = Players.PlayerAdded:Connect(function(p)
		if hud.IsOpen then
			makeRow(p)
		end
	end)
	win._conns[#win._conns + 1] = Players.PlayerRemoving:Connect(dropRow)

	local function colorHP(f)
		return Color3.fromRGB(255, 60, 60):Lerp(Color3.fromRGB(70, 235, 110), math.clamp(f, 0, 1))
	end

	local function refreshData(now)
		-- you
		local h, root0 = hum(lp)
		local hp, mx = h and h.Health or 0, h and math.max(h.MaxHealth, 1) or 100
		hpText.Text = string.format("%d / %d", math.floor(hp), math.floor(mx))
		hpFill.Size = UDim2.fromScale(math.clamp(hp / mx, 0, 1), 1)
		hpFill.BackgroundColor3 = colorHP(hp / mx)
		hpText.TextColor3 = colorHP(hp / mx)
		hpName.Text = lp.DisplayName:upper()
		local ping = 0
		pcall(function()
			ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		end)
		local bat = hudBattery()
		local mem = 0
		pcall(function()
			mem = Stats:GetTotalMemoryUsageMb()
		end)
		local spd = h and root0 and root0.AssemblyLinearVelocity and Vector3.new(root0.AssemblyLinearVelocity.X, 0, root0.AssemblyLinearVelocity.Z).Magnitude or 0
		local function set(k, v, f)
			srow[k].v.Text = v
			srow[k].fill.Size = UDim2.fromScale(math.clamp(f, 0.02, 1), 1)
		end
		set("PING", string.format("%d ms", ping), 1 - math.clamp(ping / 300, 0, 1))
		set("FPS", tostring(math.floor(fps)), math.clamp(fps / 60, 0, 1))
		set("BATTERY", bat and string.format("%d%%", bat) or "N/A", bat and bat / 100 or 0)
		set("MEMORY", string.format("%d MB", mem), 1 - math.clamp(mem / 3000, 0, 1))
		set("SPEED", string.format("%.0f", spd), math.clamp(spd / 80, 0, 1))
		local t = math.floor(now - started)
		hud._session.Text = string.format("SESSION %02d:%02d", t // 60, t % 60)
		hud._sub.Text = string.format("%s  |  %d / %d PLAYERS", (game.Name or "Game"):upper(), #Players:GetPlayers(), Players.MaxPlayers or 0)
		if root0 then
			local p = root0.Position
			hud._where.Text = string.format("POS %d, %d, %d", p.X, p.Y, p.Z)
		end
		-- players
		pcount.Text = string.format("%d / %d", #Players:GetPlayers(), Players.MaxPlayers or 0)
		local list = Players:GetPlayers()
		for _, p in ipairs(list) do
			if not rows[p] then
				makeRow(p)
			end
		end
		local used = {}
		for i, p in ipairs(list) do
			local r = rows[p]
			local d = distTo(p)
			local ph = hum(p)
			r.d.Text = d and (p == lp and "YOU" or string.format("%dm", d)) or "--"
			local f = ph and math.clamp(ph.Health / math.max(ph.MaxHealth, 1), 0, 1) or 0
			r.hf.Size = UDim2.fromScale(math.max(f, 0.02), 1)
			r.hf.BackgroundColor3 = colorHP(f)
			r.f.LayoutOrder = p == lp and -1 or math.floor(d or 99999)
			r.st.Transparency = (p == targetPlayer) and 0 or 1
			r.f.BackgroundTransparency = (p == targetPlayer) and 0.05 or 0.25
			used[p] = true
		end
		for p in pairs(rows) do
			if not used[p] then
				dropRow(p)
			end
		end
		-- radar dots
		local n = 0
		for _, p in ipairs(list) do
			if p ~= lp then
				local _, tr = hum(p)
				local d = distTo(p)
				if tr and root0 and d and d < 150 then
					n += 1
					local dot = dots[n]
					if not dot then
						dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BorderSizePixel = 0, ZIndex = 5, BackgroundColor3 = Color3.new(1, 1, 1) }, center)
						corner(dot, 6)
						dots[n] = dot
					end
					local rel = tr.Position - root0.Position
					local cam = workspace.CurrentCamera
					local look = cam and cam.CFrame.LookVector or Vector3.new(0, 0, -1)
					local ang = math.atan2(rel.X, -rel.Z) - math.atan2(look.X, -look.Z)
					local rr = math.clamp(d / 150, 0, 1) * 78
					dot.Position = UDim2.new(0.5, math.sin(ang) * rr, 0.5, -math.cos(ang) * rr)
					dot.BackgroundColor3 = p == targetPlayer and Color3.fromRGB(255, 60, 60) or Color3.new(1, 1, 1)
					dot.Visible = true
				end
			end
		end
		for i = n + 1, #dots do
			dots[i].Visible = false
		end
		-- target readout
		if targetPlayer and targetPlayer.Parent then
			local d = distTo(targetPlayer)
			local th = hum(targetPlayer)
			hud._target.Text = string.format("TARGET  %s  %s  %s", targetPlayer.DisplayName:upper(), d and (math.floor(d) .. "m") or "--", th and (math.floor(th.Health) .. " HP") or "")
		else
			hud._target.Text = ""
		end
		-- status tags and the compare card
		local tags = {}
		if h then
			local okS, stn = pcall(function()
				return h:GetState().Name
			end)
			if okS and stn then
				table.insert(tags, stn:upper())
			end
			if hp / mx < 0.3 and hp > 0 then
				table.insert(tags, "LOW HP")
			end
		end
		if ping > 220 then
			table.insert(tags, "HIGH PING")
		end
		if fps < 30 then
			table.insert(tags, "LOW FPS")
		end
		hud._status.Text = table.concat(tags, "  |  ")
		if targetPlayer and targetPlayer.Parent and hud._panels.compare then
			local th = hum(targetPlayer)
			local _, tr = hum(targetPlayer)
			local tsp = tr and tr.AssemblyLinearVelocity and Vector3.new(tr.AssemblyLinearVelocity.X, 0, tr.AssemblyLinearVelocity.Z).Magnitude or 0
			cmpL.Text = string.format("YOU vs %s\nHP  %d  |  %d      SPEED  %d  |  %d      DIST  %s", targetPlayer.DisplayName:upper(), hp, th and th.Health or 0, spd, tsp, distTo(targetPlayer) and (math.floor(distTo(targetPlayer)) .. "m") or "--")
			cmp.Visible = hud._cmpOn ~= false
		else
			cmp.Visible = false
		end
	end

	-- ---------- one loop: racing edges, spinning rings, colors, data
	local dataAcc = 0
	win._conns[#win._conns + 1] = RunService.RenderStepped:Connect(function(dt)
		frames += 1
		acc += dt
		if acc >= 0.5 then
			fps = frames / acc
			frames, acc = 0, 0
		end
		if not (hud.IsOpen or hud._gameCross) then
			return
		end
		local now = os.clock()
		applyColors(now)
		if not hud.IsOpen then
			return
		end
		local rot = (now * 90) % 360
		for _, g in ipairs(grads) do
			g.Rotation = rot
		end
		if hud.Fancy then
			ticks.Rotation = (now * 6) % 360
			arcs.Rotation = -(now * 22) % 360
			sweep.Rotation = (now * 140) % 360
		end
		local hh = hum(lp)
		if hh then
			if lastHp and hh.Health < lastHp - 0.5 then
				hud:_damage(lastHp - hh.Health)
			end
			lastHp = hh.Health
		end
		if sh then
			local k = 1 - (now - sh.t0) / sh.dur
			if k <= 0 then
				sh = nil
				ui.Position = UDim2.new()
			else
				local m = 8 * sh.p * k
				ui.Position = UDim2.fromOffset((math.random() - 0.5) * 2 * m, (math.random() - 0.5) * 2 * m)
			end
		end
		dataAcc += dt
		if dataAcc >= (hud.Interval or 0.35) then
			dataAcc = 0
			local okR, eR = pcall(refreshData, now)
			if not okR and not hud._warned then
				hud._warned = true
				warn("[RebelUI] HUD refresh: " .. tostring(eR))
			end
		end
	end)

	-- ---------- public methods
	function hud:SetColor(n)
		if not HUD_COLORS[n] then
			return false
		end
		hud.ColorName = n
		applyGrads()
		applyColors()
		markColor(n)
		return true
	end
	function hud:SetCrosshair(n)
		if not table.find(RebelUI.Crosshairs, n) then
			return false
		end
		hud.CrossName = n
		redrawCross()
		redrawGameCross()
		markCross(n)
		return true
	end
	function hud:CrosshairInGame(on)
		hud._gameCross = on == true
		cgui.Enabled = hud._gameCross
		if hud._gameCross then
			redrawGameCross()
		end
	end
	function hud:_shake(power, dur)
		sh = { t0 = os.clock(), dur = dur, p = power }
	end
	function hud:SetCrosshairSize(n)
		local px = RebelUI.CrossSizes[n] or tonumber(n)
		if not px then
			return false
		end
		hud.CrossSize = math.clamp(math.floor(px), 20, 240)
		redrawCross()
		redrawGameCross()
		for name2, v in pairs(RebelUI.CrossSizes) do
			if v == hud.CrossSize then
				markSize(name2)
				return true
			end
		end
		markSize(nil)
		return true
	end
	function hud:SetCrosshairThickness(n)
		hud.CrossThick = math.clamp(tonumber(n) or 2, 1, 8)
		redrawCross()
		redrawGameCross()
	end
	function hud:SetCrosshairOpacity(pct)
		hud.CrossAlpha = 1 - math.clamp((tonumber(pct) or 100) / 100, 0.1, 1)
		redrawCross()
		redrawGameCross()
	end
	function hud:SetPreset(n)
		local P = {
			Low = { 0.8, false, 0.9, false },
			Medium = { 0.35, true, 1, true },
			High = { 0.25, true, 1.08, true },
			Extreme = { 0.2, true, 1.15, true },
		}
		local c = P[n]
		if not c then
			return false
		end
		hud.Preset, hud.Interval, hud.Fancy, hud.Boost = n, c[1], c[2], c[3]
		for _, g in ipairs(hud._glows) do
			g.Visible = c[4]
		end
		ticks.Visible, arcs.Visible, sweep.Visible = c[2], c[2], c[2]
		if n == "Extreme" then
			hud:SetColor("Rainbow")
		end
		hud._relayout()
		markPreset(n)
		return true
	end
	-- the game's name decides a starting setup (a template)
	local TEMPLATES = {
		{ "Shooter", { "shoot", "gun", "war", "arsenal", "phantom", "strike", "combat", "battle", "fps", "rivals", "business", "criminality", "sniper", "zombie", "blox" }, { cross = "Cross", size = 70, preset = "High", show = { players = true, crosshair = true } } },
		{ "Murder mystery", { "murder", "mm2", "sheriff", "mystery", "among", "impostor" }, { cross = "Dot", size = 60, preset = "Medium", show = { players = true, crosshair = true } } },
		{ "Obby / parkour", { "obby", "tower", "parkour", "difficulty", "escape", "climb", "jump" }, { cross = "Dot", size = 40, preset = "Low", show = { players = false, crosshair = false } } },
		{ "Simulator / tycoon", { "tycoon", "simulator", "farm", "grow", "idle", "clicker", "pet", "garden", "fisch", "bee" }, { cross = "Plus", size = 50, preset = "Low", show = { players = true, crosshair = false } } },
		{ "Racing", { "race", "racing", "drive", "driving", "car", "speed", "drift" }, { cross = "Chevron", size = 60, preset = "Medium", show = { players = true, crosshair = false } } },
		{ "Roleplay / social", { "roleplay", "rp", "hangout", "life", "town", "city", "school" }, { cross = "Dot", size = 40, preset = "Low", show = { players = true, crosshair = false } } },
	}
	function hud:Detect(apply)
		local nm = (game.Name or ""):lower()
		pcall(function()
			nm = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:lower()
		end)
		local found, cfg = "General", { cross = "Cross", size = 90, preset = "Medium", show = { players = true, crosshair = true } }
		for _, t in ipairs(TEMPLATES) do
			for _, w in ipairs(t[2]) do
				if nm:find(w, 1, true) then
					found, cfg = t[1], t[3]
					break
				end
			end
			if found ~= "General" then
				break
			end
		end
		hud.Template = found
		if apply ~= false then
			hud:SetCrosshair(cfg.cross)
			hud:SetCrosshairSize(cfg.size)
			hud:SetPreset(cfg.preset)
			for k, v in pairs(cfg.show) do
				hud:Show(k, v)
			end
		end
		return found
	end
	-- profiles: one file per game (and a share code)
	local function profileData()
		local hidden = {}
		for k, f in pairs(hud._panels) do
			if k ~= "brief" and k ~= "compare" and k ~= "hotbar" and f.Visible == false then
				hidden[#hidden + 1] = k
			end
		end
		return { color = hud.ColorName, cross = hud.CrossName, size = hud.CrossSize, thick = hud.CrossThick, alpha = hud.CrossAlpha, preset = hud.Preset, hidden = hidden, game = hud._gameCross == true }
	end
	local function applyProfile(d)
		if type(d) ~= "table" then
			return false
		end
		hud:SetColor(d.color or "Rainbow")
		hud:SetCrosshair(d.cross or "Cross")
		hud.CrossThick, hud.CrossAlpha = d.thick or 2, d.alpha or 0
		hud:SetCrosshairSize(d.size or 90)
		hud:SetPreset(d.preset or "Medium")
		hud:Show("all", true)
		for _, k in ipairs(d.hidden or {}) do
			hud:Show(k, false)
		end
		hud:CrosshairInGame(d.game == true)
		return true
	end
	local function pfile()
		return "RebelUI_HUD_" .. tostring(game.PlaceId) .. ".json"
	end
	function hud:SaveProfile()
		local ok = pcall(function()
			writefile(pfile(), game:GetService("HttpService"):JSONEncode(profileData()))
		end)
		return ok
	end
	function hud:LoadProfile()
		local ok, d = pcall(function()
			if isfile and isfile(pfile()) then
				return game:GetService("HttpService"):JSONDecode(readfile(pfile()))
			end
		end)
		if ok and d then
			return applyProfile(d)
		end
		return false
	end
	function hud:Export()
		local code = "RBH1:" .. b64encode(game:GetService("HttpService"):JSONEncode(profileData()))
		pcall(function()
			setclipboard(code)
		end)
		return code
	end
	function hud:Import(code)
		code = tostring(code or "")
		if code:sub(1, 5) ~= "RBH1:" then
			return false
		end
		local ok, d = pcall(function()
			return game:GetService("HttpService"):JSONDecode(b64decode(code:sub(6)))
		end)
		return ok and applyProfile(d)
	end
	function hud:SetHotbar(list)
		for _, c in ipairs(hot:GetChildren()) do
			if c:IsA("TextButton") then
				c:Destroy()
			end
		end
		list = list or {}
		hot.Size = UDim2.fromOffset(math.max(120, #list * 84 + 16), 52)
		for i, it in ipairs(list) do
			local b = new("TextButton", { Size = UDim2.fromOffset(78, 34), LayoutOrder = i, BackgroundColor3 = DARK, BackgroundTransparency = 0.1, BorderSizePixel = 0, Text = tostring(it.Name or ("Slot " .. i)), TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), AutoButtonColor = false, ZIndex = 8 }, hot)
			neon(new("UIStroke", { Thickness = 1.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, b))
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				safe(it.Callback)
			end)
		end
		hot.Visible = #list > 0
		return hot.Visible
	end
	-- a quick demo of the effects (test mode)
	function hud:Demo()
		hud:_damage(25)
		hud:_shake(1.2, 0.5)
		win:Confetti(30)
		hud:ShowBrief("Test mode: damage flash, shake and confetti. Nothing in the game changed.", 5)
	end
	function hud:Show(key, v)
		local p = hud._panels[key]
		if key == "all" then
			for k, f in pairs(hud._panels) do
				if k ~= "brief" and k ~= "compare" and k ~= "hotbar" then
					f.Visible = v ~= false
				end
			end
			return true
		end
		if p then
			p.Visible = v ~= false
			return true
		end
		return false
	end
	function hud:Open()
		if not hud._init then
			hud._init = true
			if not hud:LoadProfile() and o.AutoDetect ~= false then
				pcall(hud.Detect, hud, true)
			end
		end
		hud.IsOpen = true
		gui.Enabled = true
		root.Visible = true
		pcall(refreshData, os.clock())
		if cgui.Enabled then
			cgui.Enabled = false
		end
		local intro = new("UIScale", { Scale = 1.08 }, ui)
		tween(intro, 0.4, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		task.delay(0.5, function()
			intro:Destroy()
		end)
	end
	function hud:Close()
		hud.IsOpen = false
		gui.Enabled = false
		cgui.Enabled = hud._gameCross == true
		if o.OnClose then
			safe(o.OnClose)
		end
	end
	function hud:Toggle()
		if hud.IsOpen then
			hud:Close()
		else
			hud:Open()
		end
	end
	function hud:Target(q)
		if q == nil or q == "none" or q == "off" then
			setTarget(nil)
			return true, "Target cleared."
		end
		local p = q == "nearest" and (nearest()) or findPlayer(q)
		if not p or p == lp then
			return false, "I can't find that player."
		end
		setTarget(p)
		return true, "Targeting " .. p.DisplayName .. "."
	end
	function hud:Spectate(q)
		local cam = workspace.CurrentCamera
		if not cam then
			return false, "No camera."
		end
		if q == nil or q == "off" or q == "none" then
			local h = hum(lp)
			if h then
				cam.CameraSubject = h
			end
			return true, "Back to your own view."
		end
		local p = q == "nearest" and (nearest()) or findPlayer(q)
		local h = p and hum(p)
		if not h then
			return false, "I can't find that player."
		end
		cam.CameraSubject = h
		return true, "Watching " .. p.DisplayName .. "."
	end
	function hud:GetSummary()
		local h = hum(lp)
		local lines = {}
		table.insert(lines, string.format("You: %s (@%s), health %d/%d, ping %d ms, %d fps.", lp.DisplayName, lp.Name, h and h.Health or 0, h and h.MaxHealth or 100, (function()
			local v = 0
			pcall(function()
				v = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			return v
		end)(), fps))
		table.insert(lines, string.format("Server: %d of %d players.", #Players:GetPlayers(), Players.MaxPlayers or 0))
		local near = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp then
				local d = distTo(p)
				local ph = hum(p)
				table.insert(near, { p, d or 99999, ph and ph.Health or 0 })
			end
		end
		table.sort(near, function(a, b)
			return a[2] < b[2]
		end)
		for i = 1, math.min(6, #near) do
			local e = near[i]
			table.insert(lines, string.format("Near %d: %s (@%s) %s, %d HP.", i, e[1].DisplayName, e[1].Name, e[2] < 99999 and (math.floor(e[2]) .. " studs") or "unknown distance", e[3]))
		end
		if targetPlayer then
			table.insert(lines, "Target: " .. targetPlayer.DisplayName)
		end
		return table.concat(lines, "\n")
	end
	-- text commands (the AI uses these): "open", "close", "color gold", "crosshair dot", "crosshair game on",
	-- "show players", "hide stats", "target nearest", "target name", "spectate name", "spectate off", "brief"
	function hud:Command(str)
		local w = {}
		for x in tostring(str or ""):lower():gmatch("%S+") do
			table.insert(w, x)
		end
		local cmd, a, b = w[1], w[2], w[3]
		local function cap(s)
			return s and (s:sub(1, 1):upper() .. s:sub(2)) or s
		end
		if cmd == "open" then
			hud:Open()
			win:Toggle(false)
			return true, "HUD open."
		elseif cmd == "close" then
			hud:Close()
			return true, "HUD closed."
		elseif cmd == "toggle" then
			hud:Toggle()
			return true, "Toggled."
		elseif cmd == "color" or cmd == "style" then
			if cap(a) == "Random" then
				a = RebelUI.HudColors[math.random(#RebelUI.HudColors)]:lower()
			end
			return hud:SetColor(cap(a)), "Color: " .. tostring(cap(a))
		elseif cmd == "crosshair" then
			if a == "size" then
				local ok = hud:SetCrosshairSize(RebelUI.CrossSizes[cap(b)] and cap(b) or (b == "xl" and "XL" or tonumber(b)))
				return ok, ok and ("Crosshair size " .. tostring(hud.CrossSize)) or "Use small, medium, large, xl or a number."
			elseif a == "thick" or a == "thickness" then
				hud:SetCrosshairThickness(tonumber(b))
				return true, "Thickness " .. hud.CrossThick
			elseif a == "opacity" or a == "alpha" then
				hud:SetCrosshairOpacity(tonumber(b))
				return true, "Crosshair opacity changed."
			elseif a == "game" then
				hud:CrosshairInGame(b ~= "off")
				return true, "In-game crosshair " .. (b == "off" and "off" or "on") .. "."
			elseif a == "on" or a == "off" then
				hud:CrosshairInGame(a == "on")
				return true, "In-game crosshair " .. a .. "."
			end
			local ok = hud:SetCrosshair(a == "random" and RebelUI.Crosshairs[math.random(#RebelUI.Crosshairs)] or (a == "x" and "X" or cap(a)))
			return ok, ok and "Crosshair changed." or "Unknown crosshair."
		elseif cmd == "show" or cmd == "hide" then
			local ok = hud:Show(a, cmd == "show")
			return ok, ok and (cmd .. " " .. tostring(a)) or "Unknown panel (players, stats, health, profile, crosshair, banner, all)."
		elseif cmd == "target" then
			return hud:Target(table.concat(w, " ", 2))
		elseif cmd == "spectate" or cmd == "watch" then
			return hud:Spectate(table.concat(w, " ", 2))
		elseif cmd == "preset" or cmd == "quality" then
			local ok = hud:SetPreset(cap(a))
			return ok, ok and ("Preset " .. cap(a)) or "Use low, medium, high or extreme."
		elseif cmd == "template" or cmd == "detect" then
			return true, "Template: " .. hud:Detect(true)
		elseif cmd == "save" then
			return hud:SaveProfile(), "Saved the HUD setup for this game."
		elseif cmd == "load" then
			local ok = hud:LoadProfile()
			return ok, ok and "Loaded." or "No saved setup for this game yet."
		elseif cmd == "export" or cmd == "share" then
			return true, "Copied a share code: " .. hud:Export():sub(1, 24) .. "..."
		elseif cmd == "demo" or cmd == "test" then
			hud:Demo()
			return true, "Test mode."
		elseif cmd == "shake" then
			win:ScreenShake(tonumber(a) or 1.5, 0.7)
			return true, "Shake."
		elseif cmd == "compare" then
			hud._cmpOn = a ~= "off"
			return true, "Compare " .. (hud._cmpOn and "on" or "off")
		elseif cmd == "brief" or cmd == "summary" then
			hud:Brief()
			return true, "Brief."
		end
		return false, "Unknown HUD command."
	end
	function hud:Destroy()
		hud._dead = true
		hud.IsOpen = false
		setTarget(nil)
		gui:Destroy()
		cgui:Destroy()
		if win.HUD == hud then
			win.HUD = nil
		end
	end
	if o.Key then
		win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i, gp)
			if not gp and i.KeyCode == o.Key then
				hud:Toggle()
			end
		end)
	end
	win:_onTheme(function()
		applyGrads()
		applyColors()
	end)
	hud:SetColor(hud.ColorName)
	hud:SetCrosshair(table.find(RebelUI.Crosshairs, hud.CrossName) and hud.CrossName or "Cross")
	if o.InGameCrosshair then
		hud:CrosshairInGame(true)
	end
	if o.Open then
		hud:Open()
	end
	return hud
end



-- ============================================================ effects: animations, ripples, glow, confetti, shake
-- Win:SetOpenAnimation("Pop"|"Slide"|"Fade"|"Bounce"|"Drop"|"Spin")  Win:SetAnimSpeed(0.5 - 2.5)  Win:SetReduceMotion(bool)
-- Win:SetFx({ Ripple = true, Glow = false, Scan = false, Breathe = true })
-- Win:Confetti(count)  Win:Shake(power, seconds) shakes the panel  Win:ScreenShake(power, seconds) shakes the panel AND the game camera
RebelUI.OpenAnimations = { "Pop", "Slide", "Fade", "Bounce", "Drop", "Spin" }

function Window:SetOpenAnimation(style)
	if table.find(RebelUI.OpenAnimations, style) then
		self.OpenAnim = style
	end
	return self.OpenAnim
end

function Window:SetAnimSpeed(x)
	self.AnimSpeed = math.clamp(tonumber(x) or 1, 0.4, 2.5)
end

function Window:SetReduceMotion(on)
	self.ReduceMotion = on == true
	if self.ReduceMotion then
		self.Fx.Glow, self.Fx.Scan = false, false
		if self._glowDot then
			self._glowDot.Visible = false
		end
		if self._scan then
			self._scan.Visible = false
		end
	end
end

function Window:SetFx(t)
	for k, v in pairs(t or {}) do
		self.Fx[k] = v == true
	end
	if self._scan then
		self._scan.Visible = self.Fx.Scan and self.Open
	end
	if self._glowDot and not self.Fx.Glow then
		self._glowDot.Visible = false
	end
end

function Window:Confetti(n)
	n = math.clamp(math.floor(n or 36), 1, 80)
	if self.ReduceMotion or not self.Gui then
		return
	end
	local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 450)
	local cols = { Color3.fromRGB(255, 70, 90), Color3.fromRGB(255, 200, 60), Color3.fromRGB(80, 220, 130), Color3.fromRGB(70, 160, 255), Color3.fromRGB(190, 110, 255), Color3.fromRGB(255, 255, 255) }
	for i = 1, n do
		local s = math.random(5, 10)
		local f = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, math.random(-60, 60), 0.3, 0),
			Size = UDim2.fromOffset(s, s * (math.random() < 0.5 and 1 or 2)),
			BackgroundColor3 = cols[math.random(#cols)],
			BorderSizePixel = 0,
			Rotation = math.random(0, 360),
			ZIndex = 200,
		}, self.Gui)
		local t = (0.9 + math.random() * 1.0) / (self.AnimSpeed or 1)
		tween(f, t, {
			Position = UDim2.new(0.5, math.random(-vp.X * 0.45, vp.X * 0.45), 0.3, math.random(vp.Y * 0.3, vp.Y * 0.75)),
			Rotation = f.Rotation + math.random(-540, 540),
			BackgroundTransparency = 1,
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		task.delay(t + 0.1, function()
			f:Destroy()
		end)
	end
end

function Window:Shake(power, dur)
	if self.ReduceMotion then
		return
	end
	power = math.clamp(tonumber(power) or 1, 0.2, 4)
	dur = math.clamp(tonumber(dur) or 0.5, 0.1, 3)
	local main = self.Main
	if not main then
		return
	end
	if not self._shakeBase then
		self._shakeBase = main.Position
	end
	self._shake = { t0 = os.clock(), dur = dur, p = power }
end

local function cameraShake(power, dur)
	local ok = pcall(function()
		local cam = workspace.CurrentCamera
		local t0 = os.clock()
		local name = "RebelUIShake"
		pcall(function()
			RunService:UnbindFromRenderStep(name)
		end)
		RunService:BindToRenderStep(name, Enum.RenderPriority.Camera.Value + 1, function()
			local k = 1 - (os.clock() - t0) / dur
			if k <= 0 then
				RunService:UnbindFromRenderStep(name)
				return
			end
			local a = power * 0.012 * k
			cam.CFrame = cam.CFrame * CFrame.new((math.random() - 0.5) * power * 0.5 * k, (math.random() - 0.5) * power * 0.5 * k, 0) * CFrame.Angles((math.random() - 0.5) * a, (math.random() - 0.5) * a, (math.random() - 0.5) * a)
		end)
	end)
	return ok
end

function Window:ScreenShake(power, dur)
	power = math.clamp(tonumber(power) or 1, 0.2, 4)
	dur = math.clamp(tonumber(dur) or 0.7, 0.1, 3)
	self:Shake(power * 1.4, dur)
	if self.HUD and self.HUD.IsOpen and self.HUD._shake then
		self.HUD:_shake(power, dur)
	end
	if not self.ReduceMotion then
		cameraShake(power, dur)
	end
end

-- called once from CreateWindow
function Window:_initFx()
	local win = self
	win.Fx = { Ripple = true, Glow = false, Scan = false, Breathe = true, Stagger = true, Hover = true }
	local main = win.Main
	-- overlay that holds ripples (clipped to the panel)
	local layer = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Active = false, ZIndex = 40 }, main)
	corner(layer, 10)
	local dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(110, 110), BackgroundTransparency = 0.88, BorderSizePixel = 0, Visible = false, Active = false, ZIndex = 39 }, layer)
	corner(dot, 110)
	win._glowDot = dot
	win:_onTheme(function(t)
		dot.BackgroundColor3 = t.Glow
	end)
	local scan = new("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.9, BorderSizePixel = 0, Visible = false, Active = false, ZIndex = 38 }, layer)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }) }, scan)
	win._scan = scan
	local function local_(p)
		local s = win._scaleObj and win._scaleObj.Scale or 1
		return Vector2.new((p.X - main.AbsolutePosition.X) / s, (p.Y - main.AbsolutePosition.Y) / s)
	end
	local function inside(p)
		local a, s = main.AbsolutePosition, main.AbsoluteSize
		return p.X >= a.X and p.Y >= a.Y and p.X <= a.X + s.X and p.Y <= a.Y + s.Y
	end
	win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i)
		if win.Open and win.Fx.Ripple and not win.ReduceMotion and isPress(i) and i.Position and inside(i.Position) then
			local p = local_(i.Position)
			local r = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(p.X, p.Y), Size = UDim2.fromOffset(6, 6), BackgroundColor3 = win.Theme.Glow, BackgroundTransparency = 0.55, BorderSizePixel = 0, Active = false, ZIndex = 41 }, layer)
			corner(r, 200)
			local t = 0.55 / (win.AnimSpeed or 1)
			tween(r, t, { Size = UDim2.fromOffset(120, 120), BackgroundTransparency = 1 })
			task.delay(t + 0.05, function()
				r:Destroy()
			end)
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputChanged:Connect(function(i)
		if win.Open and win.Fx.Glow and not win.ReduceMotion and isMove(i) and i.Position then
			if inside(i.Position) then
				local p = local_(i.Position)
				dot.Position = UDim2.fromOffset(p.X, p.Y)
				dot.Visible = true
			else
				dot.Visible = false
			end
		end
	end)
	-- one hook in the shared frame loop: breathing border, scan line, panel shake
	table.insert(win._frame, function(now)
		local rs = win._ringStroke
		if rs and win.Open then
			rs.Thickness = (win.Fx.Breathe and not win.ReduceMotion) and (1.2 + 0.7 * math.sin(now * 2.2)) or 1
		end
		if win.Fx.Scan and win.Open and not win.ReduceMotion then
			scan.Visible = true
			scan.Position = UDim2.new(0, 0, ((now * 0.22) % 1.2) - 0.1, 0)
		elseif scan.Visible then
			scan.Visible = false
		end
		local sh = win._shake
		if sh then
			local k = 1 - (now - sh.t0) / sh.dur
			if k <= 0 then
				win._shake = nil
				main.Position = win._shakeBase
				win._shakeBase = nil
			else
				local m = 7 * sh.p * k
				main.Position = win._shakeBase + UDim2.fromOffset((math.random() - 0.5) * 2 * m, (math.random() - 0.5) * 2 * m)
			end
		end
	end)
end

-- ============================================================ tools tab: command bar, notes, usage + badges, randomizer, performance, accessibility, votes
-- Win:AddCommand("name", function(args) end, "what it does")  Win:RunCommand("name args")  Win:CreateToolsTab({ Icon, Features = { "Fly", "ESP" }, Tips = { ... } })
function Window:AddCommand(name, fn, desc)
	self._commands = self._commands or {}
	self._commands[tostring(name):lower()] = { fn = fn, desc = desc or "" }
end

function Window:RunCommand(text)
	text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local cmds = self._commands or {}
	local word, rest = text:match("^(%S+)%s*(.*)$")
	if not word then
		return false, "Type a command."
	end
	word = word:lower()
	local hit = cmds[word]
	if not hit then
		local names = {}
		for n in pairs(cmds) do
			names[#names + 1] = n
		end
		table.sort(names)
		for _, n in ipairs(names) do
			if n:sub(1, #word) == word then
				hit = cmds[n]
				break
			end
		end
		if not hit then
			for _, n in ipairs(names) do
				if n:find(word, 1, true) then
					hit = cmds[n]
					break
				end
			end
		end
	end
	if not hit then
		return false, "No command like '" .. word .. "'."
	end
	local ok, res = pcall(hit.fn, rest)
	return ok, ok and (res ~= nil and tostring(res) or "Done.") or tostring(res)
end

function Window:CreateToolsTab(o)
	o = o or {}
	local win = self
	local HttpService = game:GetService("HttpService")
	local buildUI -- the page fills itself the first time it is opened (keeps the start fast)
	local tab = win:CreateTab({
		Name = o.Name or "Tools",
		Icon = o.Icon,
		Title = o.Title or "🧰 TOOLS",
		Description = o.Description or "Command bar, notes, stats, randomizer, performance and accessibility.",
		Build = function()
			if buildUI then
				buildUI()
			end
		end,
	})

	-- built-in commands
	win:AddCommand("confetti", function()
		win:Confetti(50)
	end, "party")
	win:AddCommand("shake", function(a)
		win:ScreenShake(tonumber(a) or 1.5, 0.7)
	end, "shake the screen")
	win:AddCommand("theme", function(a)
		for _, n in ipairs(RebelUI.Themes) do
			if n:lower() == a:lower() then
				win:SetTheme(n)
				return "Theme " .. n
			end
		end
		return "Themes: " .. table.concat(RebelUI.Themes, ", ")
	end, "theme <name>")
	win:AddCommand("anim", function(a)
		for _, n in ipairs(RebelUI.OpenAnimations) do
			if n:lower() == a:lower() then
				win:SetOpenAnimation(n)
				return "Animation " .. n
			end
		end
		return "Animations: " .. table.concat(RebelUI.OpenAnimations, ", ")
	end, "anim <name>")
	win:AddCommand("hud", function(a)
		local h = win:_hud()
		if a == "" then
			a = "open"
		end
		local ok, m = h:Command(a)
		return m
	end, "hud open / color gold / crosshair dot ...")
	win:AddCommand("close", function()
		win:Toggle(false)
	end, "hide the panel")

	buildUI = function()
		-- ---------- command bar
		tab:Section("Quick command bar")
		local out = tab:Label("Type a command (try: confetti, shake, theme blue, hud open) and press enter.")
		tab:Input({
			Name = "Command",
			Placeholder = "confetti, shake 2, theme blue, hud color gold ...",
			Clear = true,
			Callback = function(text)
				local ok, m = win:RunCommand(text)
				out:Set((ok and "OK: " or "Oops: ") .. tostring(m))
			end,
		})
		tab:Button({ Name = "List commands", Callback = function()
			local names = {}
			for n, c in pairs(win._commands or {}) do
				names[#names + 1] = n .. (c.desc ~= "" and (" - " .. c.desc) or "")
			end
			table.sort(names)
			out:Set(table.concat(names, "\n"))
		end })

		-- ---------- quick notes (saved to a file)
		tab:Section("Quick notes")
		local NOTES = "RebelUI_notes.txt"
		local saved = ""
		pcall(function()
			if isfile and isfile(NOTES) then
				saved = readfile(NOTES)
			end
		end)
		tab:CodeBox({
			Name = "Notes",
			Height = 80,
			Default = saved,
			Placeholder = "Write anything. Tap Save.",
			RunText = "Save",
			Callback = function(text)
				local ok = pcall(function()
					writefile(NOTES, text)
				end)
				win:Notify({ Title = ok and "Saved" or "Can't save", Text = ok and "Notes saved on this device." or "This executor can't write files.", Type = ok and "success" or "warn" })
			end,
		})

		-- ---------- usage tracker and badges
		tab:Section("Your stats and badges")
		local FILE = "RebelUI_usage.json"
		local use = { seconds = 0, opens = 0, badges = {} }
		pcall(function()
			if isfile and isfile(FILE) then
				local d = HttpService:JSONDecode(readfile(FILE))
				if type(d) == "table" then
					use.seconds, use.opens, use.badges = d.seconds or 0, d.opens or 0, d.badges or {}
				end
			end
		end)
		use.opens += 1
		local BADGES = {
			{ "First steps", function() return use.opens >= 1 end },
			{ "Regular", function() return use.opens >= 10 end },
			{ "Veteran", function() return use.opens >= 50 end },
			{ "10 minutes", function() return use.seconds >= 600 end },
			{ "1 hour", function() return use.seconds >= 3600 end },
			{ "10 hours", function() return use.seconds >= 36000 end },
		}
		local shown = tab:Label("")
		local function fmt(s)
			return string.format("%dh %02dm", s // 3600, (s % 3600) // 60)
		end
		local function refresh(announce)
			local lines = { "Time used: " .. fmt(use.seconds) .. "    Sessions: " .. use.opens }
			local have = {}
			for _, b in ipairs(BADGES) do
				if b[2]() then
					have[#have + 1] = b[1]
					if not use.badges[b[1]] then
						use.badges[b[1]] = true
						if announce then
							win:Notify({ Title = "Badge unlocked!", Text = b[1], Type = "success" })
							win:Confetti(40)
						end
					end
				end
			end
			lines[#lines + 1] = "Badges: " .. (#have > 0 and table.concat(have, ", ") or "none yet")
			shown:Set(table.concat(lines, "\n"))
		end
		refresh(false)
		task.spawn(function()
			local n = 0
			while not win._dead do
				task.wait(5)
				use.seconds += 5
				n += 1
				refresh(true)
				if n % 6 == 0 then
					pcall(function()
						writefile(FILE, HttpService:JSONEncode(use))
					end)
				end
			end
		end)

		-- ---------- randomizer
		tab:Section("Randomizer")
		local rr = tab:Label("Tap one.")
		local function say(t)
			rr:Set(t)
			win:Notify({ Title = "Randomizer", Text = t, Duration = 2.5 })
		end
		tab:Button({ Name = "Flip a coin", Callback = function()
			say(math.random() < 0.5 and "Heads" or "Tails")
		end })
		tab:Button({ Name = "Roll a dice (1-6)", Callback = function()
			say("You rolled " .. math.random(6))
		end })
		tab:Button({ Name = "Roll a d20", Callback = function()
			say("You rolled " .. math.random(20))
		end })
		local picks = "pizza, burger, sushi"
		tab:Input({ Name = "Pick one of (comma separated)", Default = picks, Callback = function(t)
			picks = t
		end })
		tab:Button({ Name = "Pick for me", Callback = function()
			local list = {}
			for x in picks:gmatch("[^,]+") do
				x = x:gsub("^%s+", ""):gsub("%s+$", "")
				if x ~= "" then
					list[#list + 1] = x
				end
			end
			say(#list > 0 and ("Go with: " .. list[math.random(#list)]) or "Type some choices first.")
		end })
		tab:Button({ Name = "Random username idea", Callback = function()
			local a = { "Shadow", "Turbo", "Neon", "Pixel", "Ghost", "Rebel", "Cosmic", "Wild" }
			local b = { "Fox", "Blade", "Storm", "Panda", "Rider", "Ninja", "Bolt", "Wolf" }
			say(a[math.random(#a)] .. b[math.random(#b)] .. math.random(10, 99))
		end })

		-- ---------- performance
		tab:Section("Performance monitor")
		tab:Graph({ Name = "FPS", Source = "FPS", Max = 70 })
		tab:Graph({ Name = "Ping", Source = "Ping", Suffix = " ms" })
		tab:Graph({ Name = "Memory", Source = "Memory", Suffix = " MB" })

		-- ---------- accessibility
		tab:Section("Accessibility")
		tab:Toggle({ Name = "High contrast", Description = "Strong colors, easier to read", Flag = "__a11y_contrast", Callback = function(on)
			win:SetTheme(on and "Contrast" or "Red")
		end })
		tab:Toggle({ Name = "Colorblind friendly colors", Flag = "__a11y_cb", Callback = function(on)
			win:SetTheme(on and "Colorblind" or "Red")
		end })
		tab:Toggle({ Name = "Large panel", Description = "Bigger buttons and text", Flag = "__a11y_big", Callback = function(on)
			win:SetScale(on and 1.25 or 1)
		end })
		tab:Toggle({ Name = "Reduce motion", Description = "Fewer animations", Flag = "__a11y_motion", Default = win.ReduceMotion, Callback = function(on)
			win:SetReduceMotion(on)
		end })

		-- ---------- keyboard cheat sheet
		tab:Section("Keyboard cheat sheet")
		tab:Paragraph({
			Title = "Keys",
			Text = (win.ToggleKey and (win.ToggleKey.Name .. "  open / close the panel\n") or "") .. "H  open / close the game assistant (if set)\nEnter  send a chat message or run a command\nPhones: tap the top bar or the round button",
		})

		-- ---------- feature voting (saved on this device) and tips
		tab:Section("Vote for the next feature")
		local VOTES = "RebelUI_votes.json"
		local votes = {}
		pcall(function()
			if isfile and isfile(VOTES) then
				votes = HttpService:JSONDecode(readfile(VOTES)) or {}
			end
		end)
		local features = o.Features or { "More themes", "More crosshairs", "Macro recorder", "Cloud sync", "Sound packs" }
		local vtxt = tab:Label("")
		local function showVotes()
			local l = {}
			for _, f in ipairs(features) do
				l[#l + 1] = f .. ": " .. (votes[f] or 0)
			end
			vtxt:Set(table.concat(l, "\n"))
		end
		showVotes()
		for _, f in ipairs(features) do
			tab:Button({ Name = "Vote: " .. f, Callback = function()
				votes[f] = (votes[f] or 0) + 1
				pcall(function()
					writefile(VOTES, HttpService:JSONEncode(votes))
				end)
				showVotes()
			end })
		end
		local tips = o.Tips or { "Tap the top bar to hide the panel.", "Drag the corner grip to resize.", "Settings has 14 themes and a rainbow HUD.", "Say 'make the crosshair bigger' to the AI.", "Use the command bar for fast actions." }
		local seen = 0
		local tl = tab:Label("Tips seen: 0")
		tab:Button({ Name = "Show a tip", Callback = function()
			seen += 1
			local t = tips[math.random(#tips)]
			tl:Set("Tips seen: " .. seen)
			win:Notify({ Title = "Tip", Text = t, Duration = 4 })
		end })

		-- ---------- safe mode, sandbox, screenshot
		tab:Section("Safety and capture")
		tab:Toggle({ Name = "Safe mode lock", Description = "Blocks dangerous buttons until you turn it off", Flag = "__safemode", Callback = function(on)
			win.SafeMode = on
		end })
		tab:Section("Danger zone")
		tab:Button({
			Name = "DO NOT PRESS",
			Description = "Shakes the whole screen. Tap twice.",
			Danger = true,
			DoubleClick = true,
			Callback = function()
				win:Notify({ Title = "You pressed it", Text = "Everything is fine. Probably.", Type = "warn" })
			end,
		})
		tab:Button({ Name = "Take a screenshot", Description = "Saves to your Roblox captures (if the game allows it)", Callback = function()
			win:Toggle(false)
			task.wait(0.5)
			local ok = pcall(function()
				game:GetService("CaptureService"):CaptureScreenshot(function() end)
			end)
			task.wait(0.6)
			win:Toggle(true)
			win:Notify({ Title = ok and "Screenshot" or "Can't capture", Text = ok and "Taken." or "Your executor or this game blocks it.", Type = ok and "success" or "warn" })
		end })
	end
	if win.CurrentTab == tab and buildUI then -- the Tools tab was the first tab and is already open: fill it now
		buildUI()
	end
	return tab
end

-- ============================================================ polish: watermark, command palette, stat tiles
-- Win:CreateWatermark({ Text = "Rebelwar" })      a small pill in the corner: name + FPS + ping. :SetText(t) :Show(bool) :Destroy()
-- Win:SetPalette({ Key = Enum.KeyCode.K })        Ctrl+K (or Win:OpenPalette()) opens a search that jumps to any tab or runs any command
-- Tab:Stats({ { Name = "Kills", Value = 0 }, ... })   a row of number tiles. obj:Set(index or name, value)
function Window:CreateWatermark(o)
	o = o or {}
	local win = self
	local gui = win.Gui
	local pill = new("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = o.Position or UDim2.new(1, -10, 0, 10),
		Size = UDim2.fromOffset(40, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(14, 14, 18),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 50,
	}, gui)
	corner(pill, 12)
	local st = new("UIStroke", { Thickness = 1.2, Transparency = 0.2 }, pill)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, pill)
	local txt = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(10, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = C.Text,
		Text = "",
		ZIndex = 51,
	}, pill)
	win:_onTheme(function(t)
		st.Color = t.Accent
	end)
	local obj, base, frames, acc = { Frame = pill }, tostring(o.Text or "RebelUI"), 0, 0
	local function ping()
		local ok, v = pcall(function()
			return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
		end)
		return ok and v or nil
	end
	local conn = RunService.Heartbeat:Connect(function(dt)
		frames += 1
		acc += dt
		if acc >= 0.5 then
			local p = ping()
			txt.Text = string.format("%s  |  %d fps%s", base, math.floor(frames / acc + 0.5), p and ("  |  " .. p .. " ms") or "")
			frames, acc = 0, 0
		end
	end)
	function obj:SetText(t)
		base = tostring(t)
	end
	function obj:Show(on)
		pill.Visible = on ~= false
	end
	function obj:Destroy()
		conn:Disconnect()
		pill:Destroy()
	end
	table.insert(win._cleanup or {}, function()
		conn:Disconnect()
	end)
	return obj
end

function Window:OpenPalette()
	local win = self
	if win._palette and win._palette.Parent then
		win._palette:Destroy()
		win._palette = nil
		return
	end
	local shade = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		ZIndex = 200,
	}, win.Gui)
	win._palette = shade
	local box = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0.12, 0),
		Size = UDim2.new(0, 340, 0, 300),
		BackgroundColor3 = Color3.fromRGB(16, 16, 22),
		BorderSizePixel = 0,
		ZIndex = 201,
	}, shade)
	corner(box, 12)
	local st = new("UIStroke", { Thickness = 1.5 }, box)
	win:_onTheme(function(t)
		if st.Parent then
			st.Color = t.Accent
		end
	end)
	local input = new("TextBox", {
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(1, -20, 0, 34),
		BackgroundColor3 = Color3.fromRGB(28, 28, 36),
		BorderSizePixel = 0,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = C.Text,
		PlaceholderText = "Search tabs and commands...",
		PlaceholderColor3 = C.Dim,
		Text = "",
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 202,
	}, box)
	corner(input, 8)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10) }, input)
	local list = new("ScrollingFrame", {
		Position = UDim2.fromOffset(10, 52),
		Size = UDim2.new(1, -20, 1, -62),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 202,
	}, box)
	new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, list)
	local function close()
		if shade.Parent then
			shade:Destroy()
		end
		win._palette = nil
	end
	local function fill()
		for _, c in ipairs(list:GetChildren()) do
			if c:IsA("GuiObject") then
				c:Destroy()
			end
		end
		local q, n = input.Text:lower(), 0
		local function add(title, sub, fn)
			if q ~= "" and not (title:lower():find(q, 1, true) or sub:lower():find(q, 1, true)) then
				return
			end
			n += 1
			if n > 40 then
				return
			end
			local b = new("TextButton", {
				Text = "",
				AutoButtonColor = false,
				Size = UDim2.new(1, -4, 0, 34),
				BackgroundColor3 = Color3.fromRGB(26, 26, 34),
				BorderSizePixel = 0,
				LayoutOrder = n,
				ZIndex = 203,
			}, list)
			corner(b, 8)
			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(10, 0),
				Size = UDim2.new(0.6, -10, 1, 0),
				Text = title,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				TextColor3 = C.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 204,
			}, b)
			new("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0.6, 0, 0, 0),
				Size = UDim2.new(0.4, -10, 1, 0),
				Text = sub,
				Font = Enum.Font.Gotham,
				TextSize = 10,
				TextColor3 = C.Dim,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 204,
			}, b)
			b.MouseButton1Click:Connect(function()
				close()
				pcall(fn)
			end)
		end
		for _, tb in ipairs(win._tabs or {}) do
			if tb.Select then
				add("Go to " .. tostring(tb.Name or "tab"), "tab", function()
					win:Toggle(true)
					tb:Select()
				end)
			end
		end
		local names = {}
		for k in pairs(win._commands or {}) do
			names[#names + 1] = k
		end
		table.sort(names)
		for _, k in ipairs(names) do
			add("Run: " .. k, win._commands[k].desc, function()
				win:RunCommand(k)
			end)
		end
		if n == 0 then
			new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Text = "Nothing found.", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.Dim, ZIndex = 203 }, list)
		end
	end
	input:GetPropertyChangedSignal("Text"):Connect(fill)
	shade.MouseButton1Click:Connect(close)
	fill()
	pcall(function()
		input:CaptureFocus()
	end)
end

function Window:SetPalette(o)
	o = o or {}
	local win = self
	if win._paletteConn then
		win._paletteConn:Disconnect()
	end
	local key = o.Key or Enum.KeyCode.K
	win._paletteConn = UIS.InputBegan:Connect(function(i, gp)
		if i.KeyCode == key and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
			win:OpenPalette()
		end
	end)
	return win
end

function Tab:Stats(items)
	local win = self.Win
	items = items or {}
	local row = self:_row(52)
	local n = math.max(#items, 1)
	local vals, byName = {}, {}
	for i, it in ipairs(items) do
		local tile = new("Frame", {
			Position = UDim2.new((i - 1) / n, i == 1 and 6 or 3, 0, 4),
			Size = UDim2.new(1 / n, (i == 1 or i == n) and -9 or -6, 1, -8),
			BackgroundColor3 = Color3.fromRGB(26, 26, 34),
			BorderSizePixel = 0,
		}, row)
		corner(tile, 8)
		local v = label(tile, tostring(it.Value or 0), 15, C.Text, true)
		v.Position = UDim2.fromOffset(8, 4)
		v.Size = UDim2.new(1, -16, 0, 22)
		local nm = label(tile, tostring(it.Name or ""), 9, C.Dim, false)
		nm.Position = UDim2.fromOffset(8, 26)
		nm.Size = UDim2.new(1, -16, 0, 12)
		vals[i] = v
		byName[tostring(it.Name)] = v
		win:_onTheme(function(t)
			v.TextColor3 = t.Accent:Lerp(C.White, 0.35)
		end)
	end
	local obj = {}
	function obj:Set(k, value)
		local l = vals[k] or byName[tostring(k)]
		if l then
			local from, to = tonumber(l.Text), tonumber(value)
			if from and to and from ~= to and not win.ReduceMotion then
				-- numbers count up (or down) instead of jumping
				local token = {}
				l._tok = token
				task.spawn(function()
					local steps = 14
					for s = 1, steps do
						if l._tok ~= token then
							return
						end
						local e = 1 - (1 - s / steps) ^ 3
						local v = from + (to - from) * e
						l.Text = tostring(to % 1 == 0 and math.floor(v + 0.5) or math.floor(v * 100 + 0.5) / 100)
						task.wait(0.03)
					end
					l.Text = tostring(value)
				end)
			else
				l.Text = tostring(value)
			end
		end
	end
	return register(self, {}, obj, "Stats")
end

-- ============================================================ more: tab badges, background dim, tab hotkeys, chips, steps, timeline, list, table
-- tab:SetBadge(5) / tab:SetBadge("NEW") / tab:SetBadge(nil)    a small bubble on the tab button
-- Win:SetDim(0.5)                                              darkens the game behind the panel while it is open (0 = off)
-- Win:SetTabHotkeys()                                          Ctrl+1 ... Ctrl+9 jump to the tabs
-- Tab:Chips({ "Legit", "Rage" }, { Closable = true, Callback = fn })   Tab:Steps({ "Pick", "Tune", "Go" }, 1)   Tab:Timeline({ { Title, Time, Text } })
-- Tab:List({ Items = {...}, Multi = true, Search = true, Callback = fn })   Tab:Table({ Columns = {...}, Rows = {{...}}, PageSize = 8 })
function Tab:SetBadge(v)
	local btn = self.TabButton
	if not btn then
		return
	end
	local b = self._badge
	if v == nil or v == false or v == 0 then
		if b then
			b:Destroy()
			self._badge = nil
		end
		return
	end
	if not b then
		b = new("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(18, 16),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Color3.fromRGB(235, 50, 60),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamBold,
			TextSize = 9,
			TextColor3 = C.White,
			ZIndex = 8,
		}, btn)
		corner(b, 8)
		new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }, b)
		self._badge = b
	end
	local n = tonumber(v)
	b.Text = n and (n > 99 and "99+" or tostring(math.floor(n))) or tostring(v)
end

function Window:SetDim(amount)
	amount = math.clamp(tonumber(amount) or 0, 0, 1)
	local win = self
	if not win._dim then
		win._dim = new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Active = false,
			ZIndex = 0,
			Visible = false,
		}, win.Gui)
		local function sync()
			if win._dim and win._dim.Parent then
				win._dim.Visible = win.Main.Visible and win._dimAmount > 0
			end
		end
		win.Main:GetPropertyChangedSignal("Visible"):Connect(sync)
		win._dimSync = sync
	end
	win._dimAmount = amount
	tween(win._dim, 0.25, { BackgroundTransparency = 1 - amount * 0.8 })
	win._dimSync()
	return win
end

function Window:SetTabHotkeys()
	local win = self
	if win._hotkeyConn then
		win._hotkeyConn:Disconnect()
	end
	local keys = { Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine }
	win._hotkeyConn = UIS.InputBegan:Connect(function(i, gp)
		if gp or not (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
			return
		end
		for n, k in ipairs(keys) do
			if i.KeyCode == k and win._tabs[n] and win._tabs[n].Select then
				win._tabs[n]:Select()
				return
			end
		end
	end)
	return win
end

function Tab:Chips(items, o)
	o = o or {}
	local win = self.Win
	local row = self:_row(30)
	row.AutomaticSize = Enum.AutomaticSize.Y
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }, row)
	new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingRight = UDim.new(0, 8) }, row)
	local obj, chips = {}, {}
	local function make(text)
		local c = new("TextButton", {
			Size = UDim2.fromOffset(20, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			AutoButtonColor = false,
			Text = tostring(text) .. (o.Closable and "  ✕" or ""),
			Font = Enum.Font.GothamMedium,
			TextSize = 10,
			TextColor3 = C.Text,
			BorderSizePixel = 0,
			LayoutOrder = #chips + 1,
		}, row)
		corner(c, 10)
		new("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) }, c)
		win:_onTheme(function(t)
			if c.Parent then
				c.BackgroundColor3 = t.Accent:Lerp(Color3.new(0, 0, 0), 0.55)
			end
		end)
		c.MouseButton1Click:Connect(function()
			if o.Closable then
				c:Destroy()
				for i, v in ipairs(chips) do
					if v == c then
						table.remove(chips, i)
						break
					end
				end
			end
			if o.Callback then
				task.spawn(o.Callback, text, o.Closable and "closed" or "tapped")
			end
		end)
		chips[#chips + 1] = c
	end
	for _, t in ipairs(items or {}) do
		make(t)
	end
	function obj:Add(text)
		make(text)
	end
	function obj:Count()
		return #chips
	end
	return register(self, o, obj, "Chips")
end

function Tab:Steps(names, current)
	local win = self.Win
	names = names or {}
	local row = self:_row(46)
	local n = math.max(#names, 1)
	local dots, labs = {}, {}
	local obj = { Current = 1 }
	for i, nm in ipairs(names) do
		local cx = (i - 0.5) / n
		if i < n then
			local line = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(cx, 10, 0, 16), Size = UDim2.new(1 / n, -20, 0, 2), BackgroundColor3 = Color3.fromRGB(50, 50, 60), BorderSizePixel = 0 }, row)
			dots[i] = { line = line }
		else
			dots[i] = {}
		end
		local d = new("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(cx, 0, 0, 16), Size = UDim2.fromOffset(20, 20), BackgroundColor3 = Color3.fromRGB(50, 50, 60), BorderSizePixel = 0, Text = tostring(i), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = C.Text, ZIndex = 3 }, row)
		corner(d, 10)
		dots[i].dot = d
		local l = new("TextLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(cx, 0, 0, 29), Size = UDim2.new(1 / n, -4, 0, 12), BackgroundTransparency = 1, Text = tostring(nm), Font = Enum.Font.Gotham, TextSize = 9, TextColor3 = C.Dim, TextTruncate = Enum.TextTruncate.AtEnd }, row)
		labs[i] = l
	end
	function obj:Set(k)
		k = math.clamp(math.floor(tonumber(k) or 1), 1, n)
		self.Current = k
		local t = win.Theme
		for i, v in ipairs(dots) do
			local done, cur = i < k, i == k
			v.dot.BackgroundColor3 = (done or cur) and t.Accent or Color3.fromRGB(50, 50, 60)
			v.dot.Text = done and "✓" or tostring(i)
			if v.line then
				v.line.BackgroundColor3 = done and t.Accent or Color3.fromRGB(50, 50, 60)
			end
			labs[i].TextColor3 = cur and C.Text or C.Dim
		end
	end
	function obj:Next()
		self:Set(self.Current + 1)
	end
	function obj:Back()
		self:Set(self.Current - 1)
	end
	function obj:Get()
		return self.Current
	end
	win:_onTheme(function()
		obj:Set(obj.Current)
	end)
	obj:Set(current or 1)
	return register(self, {}, obj, "Steps")
end

function Tab:Timeline(events)
	local win = self.Win
	events = events or {}
	local row = self:_row(10)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.Size = UDim2.new(1, 0, 0, 10)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10) }, row)
	local obj, count = {}, 0
	function obj:Add(ev)
		count += 1
		local e = new("Frame", { Size = UDim2.new(1, 0, 0, 14), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = ev.Newest and -count or count }, row)
		local dot = new("Frame", { Position = UDim2.fromOffset(0, 3), Size = UDim2.fromOffset(8, 8), BackgroundColor3 = ev.Color or win.Theme.Accent, BorderSizePixel = 0 }, e)
		corner(dot, 4)
		local t = label(e, tostring(ev.Title or ""), 11, C.Text, true)
		t.Position = UDim2.fromOffset(16, 0)
		t.Size = UDim2.new(1, -90, 0, 14)
		local tm = label(e, tostring(ev.Time or ""), 9, C.Dim, false)
		tm.TextXAlignment = Enum.TextXAlignment.Right
		tm.Position = UDim2.new(1, -70, 0, 1)
		tm.Size = UDim2.fromOffset(70, 12)
		if ev.Text then
			local d = new("TextLabel", { Position = UDim2.fromOffset(16, 15), Size = UDim2.new(1, -16, 0, 12), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = tostring(ev.Text), Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = C.Dim, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }, e)
			e.Size = UDim2.new(1, 0, 0, 30)
		end
	end
	for _, ev in ipairs(events) do
		obj:Add(ev)
	end
	return register(self, {}, obj, "Timeline")
end

-- A "Summary" feed like an AI app shows while it works: finished steps ("Ran a command" + the command), notes,
-- and one live step with a pulsing red glow dot and shimmering text while something is still running.
--   local act = tab:Activity({ Title = "Summary" })
--   act:Working("Sleuthing")                         -- red glow = still working
--   act:Add({ Kind = "command", Detail = "cd /tmp && ls" })   -- Kind: command, search, read, note (or any word)
--   act:Note("Adding a log of notifications.")
--   act:Done()                                       -- the glow stops
function Tab:Activity(o)
	o = o or {}
	local win = self.Win
	local row = self:_row(10)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.Size = UDim2.new(1, 0, 0, 10)
	new("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10) }, row)
	local head = label(row, "", 11, C.Dim, true)
	head.Size = UDim2.new(1, 0, 0, 22)
	head.LayoutOrder = 0
	local TITLES = { command = "Ran a command", search = "Searched the web", read = "Read a page" }
	local NOTE = { success = { "OK", Color3.fromRGB(70, 200, 110) }, warn = { "!", Color3.fromRGB(240, 190, 60) }, error = { "X", Color3.fromRGB(235, 70, 60) }, info = { "i", Color3.fromRGB(90, 160, 240) } }
	local counts = { command = 0, search = 0, read = 0, success = 0, warn = 0, error = 0, info = 0 }
	local obj, n, live = {}, 0, nil
	local function summary()
		local parts = {}
		if counts.search > 0 then
			parts[#parts + 1] = "Searched the web" .. (counts.search > 1 and (" " .. counts.search .. " times") or "")
		end
		if counts.read > 0 then
			parts[#parts + 1] = "read " .. counts.read .. (counts.read > 1 and " pages" or " page")
		end
		if counts.command > 0 then
			parts[#parts + 1] = "ran " .. counts.command .. (counts.command > 1 and " commands" or " command")
		end
		local alerts = counts.success + counts.warn + counts.error + counts.info
		if alerts > 0 then
			parts[#parts + 1] = alerts .. (alerts > 1 and " alerts" or " alert")
			if counts.error > 0 then
				parts[#parts + 1] = counts.error .. (counts.error > 1 and " errors" or " error")
			end
			if counts.warn > 0 then
				parts[#parts + 1] = counts.warn .. (counts.warn > 1 and " warnings" or " warning")
			end
		end
		local s = #parts > 0 and table.concat(parts, ", ") or ""
		if s ~= "" then
			s = s:sub(1, 1):upper() .. s:sub(2)
		end
		head.Text = (o.Title or "Summary") .. (s ~= "" and ("  ·  " .. s) or "")
	end
	summary()
	local function entry(kind, title, detail, order)
		local e = new("Frame", { Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order }, row)
		new("UIPadding", { PaddingBottom = UDim.new(0, 8) }, e)
		local rail = new("Frame", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(0, 1, 1, 8), BackgroundColor3 = win.Theme.Dark, BorderSizePixel = 0 }, e)
		local mark
		if NOTE[kind] then
			local col = NOTE[kind][2]
			mark = new("TextLabel", { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(22, 22), BackgroundColor3 = col:Lerp(Color3.new(0, 0, 0), 0.7), BorderSizePixel = 0, Text = NOTE[kind][1], Font = Enum.Font.GothamBlack, TextSize = 10, TextColor3 = col, ZIndex = 2 }, e)
			corner(mark, 6)
			new("UIStroke", { Color = col, Thickness = 1, Transparency = 0.3 }, mark)
		elseif kind == "command" or kind == "search" or kind == "read" then
			mark = new("TextLabel", { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(22, 22), BackgroundColor3 = win.Theme.Inset, BorderSizePixel = 0, Text = kind == "command" and ">_" or (kind == "search" and "?" or "="), Font = Enum.Font.Code, TextSize = 10, TextColor3 = C.Text, ZIndex = 2 }, e)
			corner(mark, 6)
			new("UIStroke", { Color = win.Theme.Dark, Thickness = 1 }, mark)
		else
			mark = new("Frame", { Position = UDim2.fromOffset(6, 7), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = Color3.fromRGB(80, 80, 88), BorderSizePixel = 0, ZIndex = 2 }, e)
			corner(mark, 5)
		end
		local t = new("TextLabel", { Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -32, 0, 22), BackgroundTransparency = 1, Text = title, Font = (kind == "note" or kind == "live") and Enum.Font.Gotham or Enum.Font.GothamBold, TextSize = 12, TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y }, e)
		if detail and detail ~= "" then
			new("TextLabel", { Position = UDim2.fromOffset(32, 22), Size = UDim2.new(1, -32, 0, 12), BackgroundTransparency = 1, Text = detail, Font = Enum.Font.Code, TextSize = 10, TextColor3 = C.Dim, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y }, e)
			e.Size = UDim2.new(1, 0, 0, 42)
		end
		return e, mark, t, rail
	end
	local function stopLive()
		if live then
			live.on = false
			pcall(function()
				live.mark.BackgroundColor3 = Color3.fromRGB(80, 80, 88)
				live.glow.Visible = false
				live.text.TextTransparency = 0
			end)
			live = nil
		end
	end
	function obj:Add(a, b)
		if type(a) == "string" then
			a = { Kind = "command", Title = a, Detail = b }
		end
		a = a or {}
		local kind = tostring(a.Kind or "command"):lower()
		local was = live and live.text.Text
		local wasObj = live
		if wasObj then
			wasObj.e:Destroy()
			live = nil
		end
		n += 1
		if counts[kind] ~= nil then
			counts[kind] += 1
		end
		entry(kind, a.Title or TITLES[kind] or kind, a.Detail, n)
		summary()
		if wasObj then
			obj:Working(was)
		end
	end
	function obj:Note(text)
		obj:Add({ Kind = "note", Title = tostring(text or "") })
	end
	function obj:Working(text)
		stopLive()
		local e, mark, t = entry("live", tostring(text or "Working"), nil, 1000000)
		mark.BackgroundColor3 = Color3.fromRGB(235, 70, 55)
		local glow = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(mark.Position.X.Offset + 4, mark.Position.Y.Offset + 4), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = Color3.fromRGB(235, 70, 55), BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 1 }, e)
		corner(glow, 14)
		live = { on = true, e = e, mark = mark, glow = glow, text = t }
		local me = live
		task.spawn(function()
			while me.on and e.Parent do
				tween(glow, 0.7, { Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1 }, Enum.EasingStyle.Sine)
				tween(t, 0.7, { TextTransparency = 0.55 }, Enum.EasingStyle.Sine)
				task.wait(0.7)
				glow.Size = UDim2.fromOffset(9, 9)
				glow.BackgroundTransparency = 0.5
				tween(t, 0.7, { TextTransparency = 0 }, Enum.EasingStyle.Sine)
				task.wait(0.7)
			end
		end)
	end
	function obj:Done()
		stopLive()
	end
	function obj:IsWorking()
		return live ~= nil
	end
	function obj:Clear()
		stopLive()
		for _, c in ipairs(row:GetChildren()) do
			if c:IsA("Frame") then
				c:Destroy()
			end
		end
		counts = { command = 0, search = 0, read = 0, success = 0, warn = 0, error = 0, info = 0 }
		n = 0
		summary()
	end
	return register(self, {}, obj, "Activity")
end

function Tab:List(o)
	o = o or {}
	local win = self.Win
	local items = o.Items or {}
	local multi = o.Multi
	local selected = {}
	local rowH = 24
	local shown = math.min(o.Height and math.floor(o.Height / rowH) or 6, math.max(#items, 1))
	local row = self:_row(10 + (o.Search and 30 or 0) + shown * rowH + 20)
	local y = 6
	local box
	if o.Search then
		box = new("TextBox", { Position = UDim2.fromOffset(8, 6), Size = UDim2.new(1, -16, 0, 24), BackgroundColor3 = Color3.fromRGB(28, 28, 36), BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.Text, PlaceholderText = "Search...", PlaceholderColor3 = C.Dim, Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left }, row)
		corner(box, 6)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, box)
		y = 36
	end
	local scroll = new("ScrollingFrame", { Position = UDim2.fromOffset(8, y), Size = UDim2.new(1, -16, 0, shown * rowH), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y }, row)
	new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
	local info = label(row, "", 9, C.Dim, false)
	info.Position = UDim2.new(0, 10, 1, -16)
	info.Size = UDim2.new(1, -20, 0, 12)
	local obj, buttons = {}, {}
	local function count()
		local n = 0
		for _ in pairs(selected) do
			n += 1
		end
		return n
	end
	local function paint()
		local t = win.Theme
		for name, b in pairs(buttons) do
			b.BackgroundColor3 = selected[name] and t.Accent:Lerp(Color3.new(0, 0, 0), 0.45) or Color3.fromRGB(26, 26, 34)
		end
		info.Text = (multi and (count() .. " selected  ·  ") or "") .. #items .. " items"
	end
	for i, name in ipairs(items) do
		name = tostring(name)
		local b = new("TextButton", { Size = UDim2.new(1, -4, 0, rowH - 2), AutoButtonColor = false, BorderSizePixel = 0, Text = name, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = i }, scroll)
		corner(b, 6)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8) }, b)
		buttons[name] = b
		b.MouseButton1Click:Connect(function()
			if multi then
				selected[name] = not selected[name] or nil
			else
				selected = { [name] = true }
			end
			paint()
			if o.Callback then
				local list = {}
				for k in pairs(selected) do
					list[#list + 1] = k
				end
				table.sort(list)
				task.spawn(o.Callback, multi and list or list[1])
			end
		end)
	end
	if box then
		box:GetPropertyChangedSignal("Text"):Connect(function()
			local q = box.Text:lower()
			for name, b in pairs(buttons) do
				b.Visible = q == "" or name:lower():find(q, 1, true) ~= nil
			end
		end)
	end
	function obj:Get()
		local list = {}
		for k in pairs(selected) do
			list[#list + 1] = k
		end
		table.sort(list)
		return multi and list or list[1]
	end
	function obj:Clear()
		selected = {}
		paint()
	end
	win:_onTheme(paint)
	return register(self, o, obj, "List")
end

function Tab:Table(o)
	o = o or {}
	local win = self.Win
	local cols = o.Columns or {}
	local rows = o.Rows or {}
	local pageSize, page, sortCol, sortDesc = o.PageSize or 8, 1, nil, false
	local nc = math.max(#cols, 1)
	local rh = 22
	local row = self:_row(30 + pageSize * rh + 28)
	local head = new("Frame", { Position = UDim2.fromOffset(6, 4), Size = UDim2.new(1, -12, 0, 22), BackgroundTransparency = 1 }, row)
	local body = new("Frame", { Position = UDim2.fromOffset(6, 28), Size = UDim2.new(1, -12, 0, pageSize * rh), BackgroundTransparency = 1, ClipsDescendants = true }, row)
	local nav = new("Frame", { Position = UDim2.new(0, 6, 1, -24), Size = UDim2.new(1, -12, 0, 20), BackgroundTransparency = 1 }, row)
	local info = label(nav, "", 9, C.Dim, false)
	info.Size = UDim2.new(0.5, 0, 1, 0)
	local function navBtn(txt, xs)
		local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(xs, 0, 0.5, 0), Size = UDim2.fromOffset(26, 18), BackgroundColor3 = Color3.fromRGB(34, 34, 44), BorderSizePixel = 0, Text = txt, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.Text, AutoButtonColor = false }, nav)
		corner(b, 5)
		return b
	end
	local nextB, prevB = navBtn(">", 1), navBtn("<", 1)
	prevB.Position = UDim2.new(1, -30, 0.5, 0)
	local obj = {}
	local function render()
		for _, c in ipairs(body:GetChildren()) do
			c:Destroy()
		end
		local list = table.clone(rows)
		if sortCol then
			table.sort(list, function(a, b)
				local x, y = a[sortCol], b[sortCol]
				if type(x) == "number" and type(y) == "number" then
					if sortDesc then return x > y end
					return x < y
				end
				x, y = tostring(x):lower(), tostring(y):lower()
				if sortDesc then return x > y end
				return x < y
			end)
		end
		local pages = math.max(1, math.ceil(#list / pageSize))
		page = math.clamp(page, 1, pages)
		for r = 1, pageSize do
			local data = list[(page - 1) * pageSize + r]
			if not data then
				break
			end
			local line = new("Frame", { Position = UDim2.fromOffset(0, (r - 1) * rh), Size = UDim2.new(1, 0, 0, rh - 1), BackgroundColor3 = r % 2 == 0 and Color3.fromRGB(24, 24, 32) or Color3.fromRGB(20, 20, 27), BorderSizePixel = 0 }, body)
			corner(line, 4)
			for ci = 1, nc do
				local c = label(line, tostring(data[ci] == nil and "" or data[ci]), 10, C.Text, false)
				c.Position = UDim2.new((ci - 1) / nc, 6, 0, 0)
				c.Size = UDim2.new(1 / nc, -8, 1, 0)
			end
		end
		info.Text = string.format("Showing %d-%d of %d  ·  page %d/%d", #list == 0 and 0 or (page - 1) * pageSize + 1, math.min(page * pageSize, #list), #list, page, pages)
	end
	for ci, name in ipairs(cols) do
		local h = new("TextButton", { Position = UDim2.new((ci - 1) / nc, 0, 0, 0), Size = UDim2.new(1 / nc, -2, 1, 0), BackgroundColor3 = Color3.fromRGB(34, 34, 44), BorderSizePixel = 0, Text = tostring(name), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = C.Text, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd }, head)
		corner(h, 5)
		h.MouseButton1Click:Connect(function()
			if sortCol == ci then
				sortDesc = not sortDesc
			else
				sortCol, sortDesc = ci, false
			end
			for i2, b in ipairs(head:GetChildren()) do
				if b:IsA("TextButton") then
					b.Text = tostring(cols[b.LayoutOrder] or "") .. ((b.LayoutOrder == sortCol) and (sortDesc and " ▼" or " ▲") or "")
				end
			end
			render()
		end)
		h.LayoutOrder = ci
	end
	nextB.MouseButton1Click:Connect(function()
		page += 1
		render()
	end)
	prevB.MouseButton1Click:Connect(function()
		page -= 1
		render()
	end)
	function obj:SetRows(r)
		rows = r or {}
		render()
	end
	function obj:AddRow(r)
		rows[#rows + 1] = r
		render()
	end
	win:_onTheme(function(t)
		for _, b in ipairs(head:GetChildren()) do
			if b:IsA("TextButton") then
				b.TextColor3 = t.Accent:Lerp(C.White, 0.5)
			end
		end
	end)
	render()
	return register(self, {}, obj, "Table")
end

-- ============================================================ BOOM, image effects, open boom, panic key, hold button, undo toast, mini pill
-- RebelUI.Boom(parent, { Color, Count, Text, Origin })   a flash, rings and sparks. Win:Boom()  Win:SetOpenBoom("first" | "always" | false)
-- Tab:Image({ Image, Height, Crop, Effect = "Pulse"|"Float"|"Shimmer"|"Glow"|"Spin"|"Rainbow"|"None", Circle = true, OnClick = fn })
-- Win:SetPanicKey(Enum.KeyCode.Delete)   hides every RebelUI window and stops its effects; press again to bring them back
-- Tab:HoldButton({ Name, Seconds = 1, Callback })   Win:NotifyUndo({ Text, OnUndo })   Win:CreateMini({ Toggles = { toggleObj, ... } })
function RebelUI._imageEffect(img, effect, theme)
	effect = tostring(effect or "None")
	if effect == "None" or not img or not img.Parent then
		return
	end
	local TweenService = game:GetService("TweenService")
	local function loop(inst, props, t, style)
		local ok, tw = pcall(function()
			return TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), props)
		end)
		if ok and tw then
			tw:Play()
		end
	end
	local accent = (theme and theme.Glow) or Color3.fromRGB(255, 80, 90)
	if effect == "Pulse" then
		local sc = new("UIScale", { Scale = 1 }, img)
		loop(sc, { Scale = 1.06 }, 0.9)
	elseif effect == "Float" then
		local p = img.Position
		loop(img, { Position = p + UDim2.fromOffset(0, -4) }, 1.2)
	elseif effect == "Glow" then
		local st = new("UIStroke", { Color = accent, Thickness = 2, Transparency = 0.2 }, img)
		loop(st, { Thickness = 4, Transparency = 0.7 }, 0.9)
	elseif effect == "Rainbow" then
		local st = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2 }, img)
		local g = new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 220, 60)), ColorSequenceKeypoint.new(0.66, Color3.fromRGB(60, 200, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 60, 60)) }) }, st)
		loop(g, { Rotation = 360 }, 3, Enum.EasingStyle.Linear)
	elseif effect == "Spin" then
		loop(img, { Rotation = 360 }, 6, Enum.EasingStyle.Linear)
	elseif effect == "Shimmer" then
		local sh = new("Frame", { Size = UDim2.new(0.25, 0, 1.4, 0), Position = UDim2.new(-0.4, 0, -0.2, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.82, BorderSizePixel = 0, Rotation = 18, ZIndex = (img.ZIndex or 1) + 1 }, img)
		loop(sh, { Position = UDim2.new(1.2, 0, -0.2, 0) }, 1.8, Enum.EasingStyle.Quad)
	end
end

function RebelUI._classicBoom(parent, o)
	o = o or {}
	if not parent then
		return
	end
	local color = o.Color or Color3.fromRGB(255, 200, 80)
	local count = math.clamp(math.floor(o.Count or 24), 4, 60)
	local origin = o.Origin or UDim2.fromScale(0.5, 0.5)
	local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 450)
	local R = math.min(vp.X, vp.Y) * 0.55
	local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 300, Active = false }, parent)
	local flash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.6), BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 300 }, holder)
	tween(flash, 0.35, { BackgroundTransparency = 1 })
	for i = 1, 3 do
		local r = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = origin, Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, ZIndex = 301 }, holder)
		corner(r, 500)
		local st = new("UIStroke", { Color = i == 2 and Color3.new(1, 1, 1) or color, Thickness = 5 - i, Transparency = 0.05 }, r)
		task.delay((i - 1) * 0.09, function()
			if r.Parent then
				tween(r, 0.6, { Size = UDim2.fromOffset(R * (0.6 + i * 0.3), R * (0.6 + i * 0.3)) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				tween(st, 0.6, { Transparency = 1, Thickness = 1 })
			end
		end)
	end
	for i = 1, count do
		local ang = (i / count) * math.pi * 2 + math.random() * 0.3
		local dist = R * (0.35 + math.random() * 0.65)
		local sp = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = origin,
			Size = UDim2.fromOffset(4, math.random(10, 22)),
			BackgroundColor3 = (i % 3 == 0) and Color3.new(1, 1, 1) or color,
			BorderSizePixel = 0,
			Rotation = math.deg(ang) + 90,
			ZIndex = 302,
		}, holder)
		corner(sp, 2)
		tween(sp, 0.55 + math.random() * 0.35, {
			Position = UDim2.new(origin.X.Scale, origin.X.Offset + math.cos(ang) * dist, origin.Y.Scale, origin.Y.Offset + math.sin(ang) * dist),
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(2, 4),
		}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end
	if o.Text then
		local t = new("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = origin, Size = UDim2.fromOffset(300, 60), BackgroundTransparency = 1, Text = tostring(o.Text), Font = Enum.Font.GothamBlack, TextSize = 44, TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0.2, TextStrokeColor3 = color, ZIndex = 303 }, holder)
		local sc = new("UIScale", { Scale = 0.2 }, t)
		tween(sc, 0.35, { Scale = 1.15 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		task.delay(0.7, function()
			if t.Parent then
				tween(t, 0.4, { TextTransparency = 1, TextStrokeTransparency = 1 })
			end
		end)
	end
	task.delay(1.4, function()
		holder:Destroy()
	end)
end

function Window:Boom(o)
	o = o or {}
	if self.ReduceMotion or not self.Gui then
		return
	end
	local origin
	pcall(function()
		local m = self.Main
		origin = UDim2.fromOffset(m.AbsolutePosition.X + m.AbsoluteSize.X / 2, m.AbsolutePosition.Y + m.AbsoluteSize.Y / 2)
	end)
	RebelUI.Boom(self.Gui, { Color = o.Color or self.Theme.Glow, Count = o.Count or 30, Text = o.Text, Origin = origin, Style = o.Style or self.BoomStyle, Image = o.Image or self.BoomImage })
	if o.Shake ~= false then
		self:Shake(1.6, 0.35)
	end
end

function Window:SetOpenBoom(mode)
	self.OpenBoom = mode
	self._boomed = false
	if not Window._boomWrapped then
		Window._boomWrapped = true
		local base = Window.Toggle
		function Window:Toggle(state)
			local was = self.Open
			base(self, state)
			if self.Open and not was and self.OpenBoom and (self.OpenBoom == "always" or not self._boomed) then
				self._boomed = true
				task.defer(function()
					pcall(self.Boom, self, { Text = self.BoomText })
				end)
			end
		end
	end
	return self
end

function Window:SetPanicKey(key)
	local win = self
	if win._panicConn then
		win._panicConn:Disconnect()
	end
	key = key or Enum.KeyCode.Delete
	win._panicConn = UIS.InputBegan:Connect(function(i, gp)
		if gp or i.KeyCode ~= key then
			return
		end
		win._panic = not win._panic
		if win._panic then
			win._panicWas = win.Open
			win:Toggle(false)
			if win._fab then
				win._fabWas = win._fab.Visible
				win._fab.Visible = false
			end
			if win._bar then
				pcall(win._bar.Show, win._bar, false)
			end
		else
			if win._fab then
				win._fab.Visible = win._fabWas ~= false and not win.Open
			end
			if win._bar and win._hasBar then
				pcall(win._bar.Show, win._bar, true)
			end
			if win._panicWas then
				win:Toggle(true)
			end
		end
	end)
	return win
end

function Tab:HoldButton(o)
	o = o or {}
	local win = self.Win
	local secs = math.max(0.3, o.Seconds or 1)
	local row = self:_row(36)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 2 }, row)
	corner(fill, 8)
	local nm = label(row, o.Name or "Hold to confirm", 12, C.Text, true)
	nm.Position = UDim2.fromOffset(12, 0)
	nm.Size = UDim2.new(1, -24, 1, 0)
	nm.ZIndex = 3
	win:_onTheme(function(t)
		fill.BackgroundColor3 = o.Danger and Color3.fromRGB(215, 50, 60) or t.Accent
	end)
	local hit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 4 }, row)
	local token = 0
	local function release()
		token += 1
		tween(fill, 0.15, { Size = UDim2.fromScale(0, 1) })
	end
	hit.MouseButton1Down:Connect(function()
		token += 1
		local mine = token
		fill.Size = UDim2.fromScale(0, 1)
		tween(fill, secs, { Size = UDim2.fromScale(1, 1) }, Enum.EasingStyle.Linear)
		task.delay(secs, function()
			if token == mine then
				token += 1
				tween(fill, 0.25, { Size = UDim2.fromScale(0, 1) })
				if o.Callback then
					task.spawn(o.Callback)
				end
			end
		end)
	end)
	hit.MouseButton1Up:Connect(release)
	hit.MouseLeave:Connect(release)
	return register(self, o, {}, "HoldButton")
end

function Window:NotifyUndo(o)
	o = o or {}
	local done = false
	return self:Notify({
		Title = o.Title or "Done",
		Text = o.Text or "Changed.",
		Duration = o.Duration or 5,
		Actions = { { Name = o.UndoName or "Undo", Callback = function()
			if not done then
				done = true
				if o.OnUndo then
					task.spawn(o.OnUndo)
				end
			end
		end } },
	})
end

function Window:CreateMini(o)
	o = o or {}
	local win = self
	local items = o.Toggles or {}
	local pill = new("Frame", {
		Position = o.Position or UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(120, 18 + #items * 28),
		BackgroundColor3 = Color3.fromRGB(14, 14, 18),
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		ZIndex = 60,
		Active = true,
	}, win.Gui)
	corner(pill, 12)
	local st = new("UIStroke", { Thickness = 1.3 }, pill)
	win:_onTheme(function(t)
		st.Color = t.Accent
	end)
	local grip = new("TextButton", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Text = "· · ·", TextColor3 = C.Dim, TextSize = 12, Font = Enum.Font.GothamBold, ZIndex = 61 }, pill)
	local dragging, off
	grip.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			off = Vector2.new(i.Position.X, i.Position.Y) - pill.AbsolutePosition
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			pill.Position = UDim2.fromOffset(i.Position.X - off.X, i.Position.Y - off.Y)
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	for n, tg in ipairs(items) do
		local b = new("TextButton", { Position = UDim2.fromOffset(6, 16 + (n - 1) * 28), Size = UDim2.new(1, -12, 0, 24), AutoButtonColor = false, BorderSizePixel = 0, Text = tostring(tg.Name or ("Toggle " .. n)), TextSize = 10, Font = Enum.Font.GothamBold, TextColor3 = C.Text, ZIndex = 61 }, pill)
		corner(b, 8)
		local function paint()
			local on = false
			pcall(function()
				on = tg:Get() == true
			end)
			b.BackgroundColor3 = on and win.Theme.Accent or Color3.fromRGB(34, 34, 44)
		end
		b.MouseButton1Click:Connect(function()
			pcall(function()
				tg:Set(not tg:Get())
			end)
			paint()
		end)
		win:_onTheme(paint)
		paint()
	end
	local obj = { Frame = pill }
	function obj:Show(on)
		pill.Visible = on ~= false
	end
	function obj:Destroy()
		pill:Destroy()
	end
	return obj
end

-- ============================================================ sub-tabs, columns, containers, favorites, theme editor
-- local sub = Tab:SubTabs({ "Aim", "Visuals", "Misc" })   sub.Aim:Toggle({...})  sub[2]:Slider({...})  sub:Select("Misc")
-- local cols = Tab:Columns(2)                              cols[1]:Toggle({...})  cols[2]:Button({...})   (stacks into one column on a narrow panel)
-- local box = Tab:Container()                              a frame that takes every element method; box:Clear() removes what is inside
-- Win:CreateFavoritesTab({ Name = "Favorites" })           players pick toggles and buttons from other tabs and use them in one place
-- Win:CreateThemeEditor({ Name = "Theme" })                a color picker for every theme color, with copy / paste of the whole theme
local function makeContainer(parentTab, parentFrame)
	local frame = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0 }, parentFrame)
	local lay = new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, frame)
	local c = setmetatable({ Win = parentTab.Win, Name = parentTab.Name, Page = frame, _n = 0, Parent = parentTab }, Tab)
	function c:Clear()
		for _, ch in ipairs(frame:GetChildren()) do
			if ch:IsA("GuiObject") then
				ch:Destroy()
			end
		end
		c._n, c._items, c._secs = 0, nil, nil
	end
	function c:SetVisible(v)
		frame.Visible = v ~= false
	end
	return c, frame
end

function Tab:Container()
	local wrap = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self:_next(), BorderSizePixel = 0 }, self.Page)
	local c = makeContainer(self, wrap)
	return c
end

function Tab:SubTabs(names, o)
	o = o or {}
	local win = self.Win
	local wrap = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self:_next(), BorderSizePixel = 0 }, self.Page)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)
	local strip = new("ScrollingFrame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollingDirection = Enum.ScrollingDirection.X, LayoutOrder = 0 }, wrap)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }, strip)
	new("UIPadding", { PaddingLeft = UDim.new(0, 2), PaddingTop = UDim.new(0, 2) }, strip)
	local obj, btns, boxes, current = { Names = names }, {}, {}, nil
	local function paint()
		for nm, b in pairs(btns) do
			local on = nm == current
			b.BackgroundColor3 = on and win.Theme.Accent or Color3.fromRGB(34, 34, 44)
			b.TextColor3 = on and C.White or C.Dim
		end
	end
	for i, nm in ipairs(names or {}) do
		nm = tostring(nm)
		local b = new("TextButton", { Size = UDim2.fromOffset(20, 26), AutomaticSize = Enum.AutomaticSize.X, AutoButtonColor = false, BorderSizePixel = 0, Text = nm, Font = Enum.Font.GothamBold, TextSize = 11, LayoutOrder = i }, strip)
		corner(b, 13)
		new("UIPadding", { PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, b)
		btns[nm] = b
		local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i, Visible = false, BorderSizePixel = 0 }, wrap)
		local c = makeContainer(self, holder)
		c.Name = nm
		boxes[nm] = holder
		obj[nm] = c
		obj[i] = c
		b.MouseButton1Click:Connect(function()
			obj:Select(nm)
		end)
	end
	function obj:Select(nm)
		nm = tostring(nm)
		if not boxes[nm] then
			return
		end
		current = nm
		for k, h in pairs(boxes) do
			h.Visible = k == nm
		end
		paint()
	end
	win:_onTheme(paint)
	if names and names[1] then
		obj:Select(o.Default or names[1])
	end
	return obj
end

function Tab:Columns(n, o)
	o = o or {}
	n = math.clamp(math.floor(tonumber(n) or 2), 2, 3)
	local win = self.Win
	local gap = 6
	local wrap = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = self:_next(), BorderSizePixel = 0 }, self.Page)
	local lay = new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, gap), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Top }, wrap)
	local obj, frames = {}, {}
	for i = 1, n do
		local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1 / n, -gap * (n - 1) / n, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = i, BorderSizePixel = 0 }, wrap)
		local c = makeContainer(self, holder)
		obj[i] = c
		frames[i] = holder
	end
	local function relayout()
		local w = 0
		pcall(function()
			w = win.Main.AbsoluteSize.X
		end)
		local narrow = w > 0 and w < (o.MinWidth or 480)
		lay.FillDirection = narrow and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		for _, f in ipairs(frames) do
			f.Size = narrow and UDim2.new(1, 0, 0, 0) or UDim2.new(1 / n, -gap * (n - 1) / n, 0, 0)
		end
	end
	pcall(function()
		win.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
	end)
	relayout()
	return obj
end

function Window:CreateFavoritesTab(o)
	o = o or {}
	local win = self
	local FILE = o.File or "RebelUI_favorites.txt"
	local chosen = {}
	pcall(function()
		if type(isfile) == "function" and isfile(FILE) then
			for line in tostring(readfile(FILE)):gmatch("[^\n]+") do
				chosen[line] = true
			end
		end
	end)
	local function saveFile()
		pcall(function()
			if type(writefile) == "function" then
				local out = {}
				for k in pairs(chosen) do
					out[#out + 1] = k
				end
				table.sort(out)
				writefile(FILE, table.concat(out, "\n"))
			end
		end)
	end
	local tab
	local body
	body = function()
		local picker = tab:Container()
		local shown = tab:Container()
		local gen = 0
		local function key(e)
			return tostring(e.tab.Name) .. ": " .. tostring(e.o.Name)
		end
		local function build()
			gen += 1
			local mine = gen
			shown:Clear()
			shown:Section("Your favorites")
			local any = false
			for _, e in ipairs(win._all or {}) do
				if (e.kind == "Toggle" or e.kind == "Button") and e.o.Name and e.tab ~= tab and chosen[key(e)] then
					any = true
					if e.kind == "Toggle" then
						local m = shown:Toggle({ Name = tostring(e.o.Name), Default = (function() local ok, v = pcall(e.obj.Get, e.obj) return ok and v == true end)(), Callback = function(v)
							pcall(function()
								if e.obj:Get() ~= v then
									e.obj:Set(v)
								end
							end)
						end })
						local acc = 0
						table.insert(win._frame, function(_, dt)
							if mine ~= gen then
								return
							end
							acc += dt or 0
							if acc < 0.2 then
								return
							end
							acc = 0
							pcall(function()
								local v = e.obj:Get()
								if m:Get() ~= v then
									m:Set(v)
								end
							end)
						end)
					else
						shown:Button({ Name = tostring(e.o.Name), Description = e.o.Description, Callback = function()
							if e.o.Callback then
								task.spawn(e.o.Callback)
							end
						end })
					end
				end
			end
			if not any then
				shown:Label("Nothing yet. Choose some above, then tap Show.")
			end
		end
		local function pickerUI()
			picker:Clear()
			picker:Section("Choose favorites")
			local items, lookup = {}, {}
			for _, e in ipairs(win._all or {}) do
				if (e.kind == "Toggle" or e.kind == "Button") and e.o.Name and e.tab ~= tab then
					local k = key(e)
					if not lookup[k] then
						lookup[k] = true
						items[#items + 1] = k
					end
				end
			end
			table.sort(items)
			if #items == 0 then
				picker:Label("Open your other tabs once so their toggles and buttons appear here, then tap Refresh.")
			else
				local list = picker:List({ Items = items, Multi = true, Search = true, Height = 150 })
				picker:Button({ Name = "Show these as favorites", Callback = function()
					chosen = {}
					for _, k in ipairs(list:Get() or {}) do
						chosen[k] = true
					end
					saveFile()
					build()
					win:Notify({ Title = "Favorites updated", Type = "success" })
				end })
			end
			picker:Button({ Name = "Refresh the list", Callback = function()
				pickerUI()
				build()
			end })
		end

		pickerUI()
		build()
	end
	tab = win:CreateTab({ Name = o.Name or "Favorites", Icon = o.Icon, Title = o.Title or "⭐ FAVORITES", Description = o.Description or "Pick toggles and buttons from your other tabs. They show up here so you can reach them fast." , Build = function(t)
		tab = t
		body()
	end })
	return tab
end

function Window:CreateThemeEditor(o)
	o = o or {}
	local win = self
	local tab
	local body
	local startName = win.ThemeName
	body = function()
		local FIELDS = { { "Accent", "Accent" }, { "Glow", "Glow (bright edge)" }, { "Dark", "Dark (shadows)" }, { "BG0", "Background top" }, { "BG1", "Background bottom" }, { "Item", "Row color" }, { "ItemOn", "Row color (on)" }, { "Inset", "Input boxes" } }
		local function setField(k, c)
			local t = {}
			for kk, vv in pairs(win.Theme) do
				t[kk] = vv
			end
			t[k] = c
			win.Theme = t
			win.ThemeName = "Custom"
			for _, fn in ipairs(win._fns) do
				pcall(fn, t)
			end
		end
		local function hex(c)
			return string.format("%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
		end
		local function unhex(s)
			s = tostring(s):gsub("#", "")
			if #s ~= 6 or s:find("[^%x]") then
				return nil
			end
			return Color3.fromRGB(tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16))
		end
		tab:Section("Colors")
		for _, f in ipairs(FIELDS) do
			local k = f[1]
			tab:Color({ Name = f[2], Default = win.Theme[k] or win.Theme.Accent, Callback = function(c)
				setField(k, c)
			end })
		end
		tab:Section("Share")
		tab:Button({ Name = "Copy theme code", Description = "Send it to a friend", Callback = function()
			local parts = {}
			for _, f in ipairs(FIELDS) do
				parts[#parts + 1] = hex(win.Theme[f[1]] or win.Theme.Accent)
			end
			local code = "RBLF:" .. table.concat(parts, ",")
			local ok = type(setclipboard) == "function" and pcall(setclipboard, code)
			win:Notify({ Title = ok and "Copied" or "Your executor can't copy", Text = ok and "Paste it anywhere." or code, Type = ok and "success" or "warn" })
		end })
		tab:Input({ Name = "Paste a theme code", Placeholder = "RBLF:...", Callback = function(text)
			text = tostring(text or ""):gsub("%s", "")
			if text:sub(1, 5) ~= "RBLF:" then
				if win:Import(text) then
					win:Notify({ Title = "Theme applied", Type = "success" })
				else
					win:Notify({ Title = "That is not a theme code", Type = "warn" })
				end
				return
			end
			local i, okAll = 0, true
			for h in text:sub(6):gmatch("[^,]+") do
				i += 1
				local f, c = FIELDS[i], unhex(h)
				if f and c then
					setField(f[1], c)
				else
					okAll = false
				end
			end
			win:Notify({ Title = okAll and "Theme applied" or "Part of the code was wrong", Type = okAll and "success" or "warn" })
		end })
		tab:Button({ Name = "Reset to the starting theme", Callback = function()
			if startName and startName ~= "Custom" then
				win:SetTheme(startName)
				win:Notify({ Title = "Theme reset", Type = "success" })
			end
		end })

	end
	tab = win:CreateTab({ Name = o.Name or "Theme", Icon = o.Icon, Title = o.Title or "🎨 THEME EDITOR", Description = o.Description or "Change every color live. Copy the code to share your theme." , Build = function(t)
		tab = t
		body()
	end })
	return tab
end

-- Win:SetBackground({ Image = 125144167121839, Opacity = 0.22, Effect = "None" })   a picture behind the whole panel. Opacity 0 to 1. SetBackground() removes it.
function Window:SetBackground(o)
	o = type(o) == "table" and o or {}
	if self._bgImg then
		self._bgImg:Destroy()
		self._bgImg = nil
	end
	if not o.Image or not self.Main then
		return self
	end
	local img = new("ImageLabel", {
		Name = "RebelBackground",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Image = asset(o.Image),
		ScaleType = o.Fit and Enum.ScaleType.Fit or Enum.ScaleType.Crop,
		ImageTransparency = 1 - math.clamp(tonumber(o.Opacity) or 0.2, 0, 1),
		ZIndex = 0,
	}, self.Main)
	corner(img, 14)
	if o.Effect then
		RebelUI._imageEffect(img, o.Effect, self.Theme)
	end
	self._bgImg = img
	self._bgOpts = o
	return self
end

function Window:SetBackgroundOpacity(v)
	if self._bgImg then
		self._bgImg.ImageTransparency = 1 - math.clamp(tonumber(v) or 0.2, 0, 1)
	end
	return self
end

-- ============================================================ notification history, swipe tabs, ambient glow
function Window:GetNotifications()
	return self._noteLog or {}
end
function Window:ClearNotifications()
	self._noteLog = {}
end
-- A tab that lists every toast you have seen, with a number badge for the unread ones. Opening it clears the badge.
function Window:CreateNotificationsTab(o)
	o = o or {}
	local win = self
	local unread = 0
	local act, stats
	local total, errs, warns, did = 0, 0, 0, 0
	local tab
	local filter = ""
	local importantOnly = false
	local function passes(...)
		if filter == "" then
			return true
		end
		for _, s in ipairs({ ... }) do
			if tostring(s or ""):lower():find(filter, 1, true) then
				return true
			end
		end
		return false
	end
	local function showAction(a)
		if not act or importantOnly or not passes(a.Title, a.Detail) then
			return
		end
		act:Add({ Kind = a.Kind or "command", Title = a.Title, Detail = a.Time .. (a.Detail ~= "" and ("  " .. a.Detail) or "") })
		did += 1
		if stats then
			stats:Set("Actions", did)
		end
	end
	local function show(n)
		if not act or not passes(n.Title, n.Text, n.Type) then
			return
		end
		if importantOnly and n.Type ~= "error" and n.Type ~= "warn" then
			return
		end
		local kind = (n.Type == "success" or n.Type == "warn" or n.Type == "error") and n.Type or "info"
		act:Add({ Kind = kind, Title = tostring(n.Title or (kind == "error" and "Error" or kind == "warn" and "Warning" or kind == "success" and "Done" or "Notice")), Detail = n.Time .. "  " .. n.Text })
		total += 1
		errs += kind == "error" and 1 or 0
		warns += kind == "warn" and 1 or 0
		if stats then
			stats:Set("Alerts", total)
			stats:Set("Errors", errs)
			stats:Set("Warnings", warns)
		end
	end
	tab = win:CreateTab({
		Name = o.Name or "Alerts",
		Icon = o.Icon,
		Title = "SUMMARY",
		Description = "Everything you did and everything the panel told you, newest at the bottom. The red glow means it is listening.",
		Build = function(t)
			stats = t:Stats({ { Name = "Actions", Value = 0 }, { Name = "Alerts", Value = 0 }, { Name = "Errors", Value = 0 }, { Name = "Warnings", Value = 0 } })
			act = t:Activity({ Title = "Summary" })
			act:Working("Listening for alerts")
			for _, n in ipairs(win._noteLog or {}) do
				show(n)
			end
			for _, a in ipairs(win._actions or {}) do
				showAction(a)
			end
			local function reload()
				act:Clear()
				act:Working("Listening for alerts and your actions")
				total, errs, warns, did = 0, 0, 0, 0
				for _, n in ipairs(win._noteLog or {}) do
					show(n)
				end
				for _, a in ipairs(win._actions or {}) do
					showAction(a)
				end
			end
			local function sessionInfo()
				local ex = "unknown"
				pcall(function()
					ex = tostring(identifyexecutor())
				end)
				local gname = "this game"
				pcall(function()
					gname = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
				end)
				local secs = math.floor(os.clock() - (win._born or os.clock()))
				return table.concat({
					"Script: " .. tostring(win.TitleText or o.Name or "RebelUI") .. "   (RebelUI v" .. tostring(RebelUI.Version) .. ")",
					"Game: " .. gname,
					"Executor: " .. ex,
					"Device: " .. tostring(RebelUI.Device and RebelUI.Device() or "?") .. "   Setup: " .. tostring(win.Setup),
					string.format("Open for: %dm %ds", secs // 60, secs % 60),
					"Actions logged: " .. #(win._actions or {}) .. "   Alerts: " .. #(win._noteLog or {}),
				}, "\n")
			end
			local function exportJson()
				local HttpService = game:GetService("HttpService")
				return HttpService:JSONEncode({ actions = win._actions or {}, alerts = win._noteLog or {}, made = os.date("%Y-%m-%d %H:%M:%S") })
			end
			t:Input({ Name = "Search the summary", Placeholder = "type a word, then press Enter", NoLog = true, Callback = function(txt)
				filter = tostring(txt or ""):lower()
				reload()
			end })
			t:IconButtons({
				{ Icon = RebelUI.Icons.info, Name = "Info", Callback = function()
					win:Dialog({ Title = "About this session", Text = sessionInfo(), Buttons = { { Name = "Copy", Callback = function()
						if type(setclipboard) == "function" then
							pcall(setclipboard, sessionInfo())
						end
					end }, { Name = "Close" } } })
				end },
				{ Icon = RebelUI.Icons.search, Name = "Search", Callback = function()
					reload()
					win:Notify({ Type = "info", Title = filter == "" and "Showing everything" or ("Showing: " .. filter), Text = "Type a word in the box above to filter." })
				end },
				{ Icon = RebelUI.Icons.refresh, Name = "Refresh", Async = true, Working = "Refreshing", Done = "Refreshed", Callback = function(done)
					task.wait(0.2)
					reload()
					done()
				end },
				{ Icon = RebelUI.Icons.copy, Name = "Copy", Done = "Copied", Callback = function()
					local ok = type(setclipboard) == "function" and pcall(setclipboard, win:GetSummaryText())
					win:Notify({ Type = ok and "success" or "warn", Title = ok and "Summary copied" or "Can't copy", Text = ok and "Paste it anywhere." or "Your executor has no clipboard." })
				end },
			})
			local function savedFiles()
				local lines = {}
				for _, f in ipairs({ "RebelUI_summary.txt", "RebelUI_summary.json" }) do
					local has = type(isfile) == "function" and isfile(f)
					lines[#lines + 1] = f .. (has and "   (saved)" or "   (not saved yet)")
				end
				return table.concat(lines, "\n")
			end
			t:IconButtons({
				{ Icon = RebelUI.Icons.save, Name = "Save", Async = true, Working = "Saving", Done = "Saved", Callback = function(done)
					local ok = type(writefile) == "function" and pcall(writefile, "RebelUI_summary.txt", win:GetSummaryText())
					task.wait(0.2)
					win:Notify({ Type = ok and "success" or "warn", Title = ok and "Saved" or "Can't save", Text = ok and "RebelUI_summary.txt in your workspace folder." or "Your executor can't write files." })
					done(ok)
				end },
				{ Icon = RebelUI.Icons.share, Name = "Share", Done = "Copied", Callback = function()
					local txt = win:GetSummaryText()
					if #txt > 1900 then
						txt = txt:sub(1, 1900) .. "\n..."
					end
					local ok = type(setclipboard) == "function" and pcall(setclipboard, "```\n" .. txt .. "\n```")
					win:Notify({ Type = ok and "success" or "warn", Title = ok and "Ready for Discord" or "Can't copy", Text = ok and "Pasted as a code block it fits one message." or "Your executor has no clipboard." })
				end },
				{ Icon = RebelUI.Icons.downloads, Name = "Export", Async = true, Working = "Exporting", Done = "Exported", Callback = function(done)
					local ok = type(writefile) == "function" and pcall(function()
						writefile("RebelUI_summary.json", exportJson())
					end)
					task.wait(0.2)
					win:Notify({ Type = ok and "success" or "warn", Title = ok and "Exported" or "Can't export", Text = ok and "RebelUI_summary.json in your workspace folder." or "Your executor can't write files." })
					done(ok)
				end },
				{ Icon = RebelUI.Icons.file, Name = "Files", Callback = function()
					win:Dialog({ Title = "Saved files", Text = savedFiles() .. "\n\nThey are in your executor's workspace folder.", Buttons = { { Name = "Close" } } })
				end },
			})
			t:IconButtons({
				{ Icon = RebelUI.Icons.calendar, Name = "Session", Callback = function()
					local secs = math.floor(os.clock() - (win._born or os.clock()))
					local first = (win._actions or {})[1]
					local last = (win._actions or {})[#(win._actions or {})]
					win:Dialog({ Title = "This session", Text = table.concat({
						"Today: " .. os.date("%Y-%m-%d"),
						"Now: " .. os.date("%H:%M:%S"),
						string.format("Open for: %dm %ds", secs // 60, secs % 60),
						"First action: " .. (first and (first.Time .. "  " .. tostring(first.Title)) or "none yet"),
						"Latest action: " .. (last and (last.Time .. "  " .. tostring(last.Title)) or "none yet"),
					}, "\n"), Buttons = { { Name = "Close" } } })
				end },
				{ Icon = RebelUI.Icons.star, Name = "Important", Callback = function()
					importantOnly = not importantOnly
					reload()
					win:Notify({ Type = "info", Title = importantOnly and "Showing only warnings and errors" or "Showing everything", Text = "Tap Important again to switch." })
				end },
				{ Icon = RebelUI.Icons.link, Name = "Discord", Done = "Copied", Callback = function()
					local link = win.DiscordLink or (RebelUI.Credits and RebelUI.Credits.Discord) or "https://discord.gg/8s7RR3wZ6b"
					local ok = type(setclipboard) == "function" and pcall(setclipboard, link)
					win:Notify({ Type = ok and "success" or "warn", Title = ok and "Link copied" or "Can't copy", Text = ok and link or "Your executor has no clipboard." })
				end },
			})
			t:Button({ Name = "Clear the summary", Callback = function()
				win:ClearNotifications()
				act:Clear()
				act:Working("Listening for alerts")
				win._actions = {}
				total, errs, warns, did = 0, 0, 0, 0
				stats:Set("Actions", 0)
				stats:Set("Alerts", 0)
				stats:Set("Errors", 0)
				stats:Set("Warnings", 0)
			end })
			t:Button({ Name = "Send a test alert", Callback = function()
				win:Notify({ Title = "Test", Text = "This alert shows up in the summary.", Type = ({ "success", "warn", "error", "info" })[math.random(4)] })
			end })
		end,
	})
	local prevA = win._onAction
	win._onAction = function(a)
		if prevA then
			pcall(prevA, a)
		end
		showAction(a)
	end
	local prev = win._onNote
	win._onNote = function(n)
		if prev then
			pcall(prev, n)
		end
		show(n)
		if win.CurrentTab ~= tab then
			unread += 1
			tab:SetBadge(unread)
		end
	end
	local sel = tab.Select
	tab.Select = function(self2, ...)
		unread = 0
		tab:SetBadge(nil)
		return sel(self2, ...)
	end
	return tab
end

-- Swipe left or right on the panel to change tab (on by default for the Mobile setup).
function Window:EnableSwipe()
	if self._swipe then
		return
	end
	self._swipe = true
	local win = self
	local startPos
	win._conns[#win._conns + 1] = UIS.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch and win.Open then
			startPos = i.Position
		end
	end)
	win._conns[#win._conns + 1] = UIS.InputEnded:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.Touch or not startPos then
			return
		end
		local d = i.Position - startPos
		startPos = nil
		local c = win._content
		if not c or not win.Open or math.abs(d.X) < 110 or math.abs(d.X) < math.abs(d.Y) * 2 then
			return
		end
		local ok, inside = pcall(function()
			local p, s = c.AbsolutePosition, c.AbsoluteSize
			return i.Position.X >= p.X and i.Position.X <= p.X + s.X and i.Position.Y >= p.Y and i.Position.Y <= p.Y + s.Y
		end)
		if ok and inside == false then
			return
		end
		local idx
		for n, t in ipairs(win._tabs) do
			if t == win.CurrentTab then
				idx = n
			end
		end
		if idx then
			local nxt = win._tabs[idx + (d.X < 0 and 1 or -1)]
			if nxt and nxt.Select then
				nxt:Select()
			end
		end
	end)
end

-- Two soft glowing circles drift slowly behind everything (CreateWindow({ Ambient = true }) or Win:SetAmbient(true)).
function Window:SetAmbient(on)
	if self._orbHolder then
		self._orbHolder.Visible = on and true or false
		return
	end
	if not on or self.ReduceMotion or not self.Main then
		return
	end
	local win = self
	local holder = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 1, Active = false }, win.Main)
	corner(holder, 10)
	win._orbHolder = holder
	for k = 1, 2 do
		local orb = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(k == 1 and 0.2 or 0.8, k == 1 and 0.25 or 0.8), Size = UDim2.fromOffset(150, 150), BackgroundColor3 = win.Theme.Glow, BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 1, Active = false }, holder)
		corner(orb, 75)
		win:_bind(orb, "BackgroundColor3", "Glow")
		task.spawn(function()
			while orb.Parent and holder.Parent do
				tween(orb, 5, { Position = UDim2.fromScale(0.15 + math.random() * 0.7, 0.15 + math.random() * 0.7), BackgroundTransparency = 0.82 + math.random() * 0.1 }, Enum.EasingStyle.Sine)
				task.wait(5)
			end
		end)
	end
end

-- ============================================================ more animation: rows rise in, skeleton loader, typewriter
-- Rows rise in one after another when a tab opens (Win:SetFx({ Stagger = false }) to turn off).
function Window:_stagger(page)
	if not (self.Fx and self.Fx.Stagger) or self.ReduceMotion then
		return
	end
	local rows = {}
	for _, c in ipairs(page:GetChildren()) do
		local ok, lo = pcall(function()
			return c:IsA("GuiObject") and c.Visible and c.LayoutOrder
		end)
		if ok and lo then
			rows[#rows + 1] = c
		end
	end
	table.sort(rows, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
	for i = 1, math.min(#rows, 9) do
		local c = rows[i]
		local sc = c:FindFirstChild("RebelStag") or new("UIScale", { Name = "RebelStag", Scale = 1 }, c)
		sc.Scale = 0.9
		task.delay((i - 1) * 0.035, function()
			tween(sc, 0.32, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end)
	end
end

-- Tab:Skeleton({ Lines = 3 }): grey bars with a shimmer while you wait for data. obj:Remove() when it is ready.
function Tab:Skeleton(o)
	o = o or {}
	local lines = math.clamp(o.Lines or 3, 1, 8)
	local row = self:_row(14 + lines * 20)
	local alive = true
	local bars = {}
	for i = 1, lines do
		local w = i == lines and 0.55 or (0.9 - (i % 2) * 0.15)
		local b = new("Frame", { Position = UDim2.fromOffset(10, 10 + (i - 1) * 20), Size = UDim2.new(w, -10, 0, 12), BackgroundColor3 = Color3.fromRGB(44, 44, 54), BorderSizePixel = 0, ClipsDescendants = true }, row)
		corner(b, 6)
		local sh = new("Frame", { Position = UDim2.fromScale(-0.4, 0), Size = UDim2.fromScale(0.4, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.85, BorderSizePixel = 0 }, b)
		bars[i] = sh
	end
	task.spawn(function()
		while alive and row.Parent do
			for _, sh in ipairs(bars) do
				sh.Position = UDim2.fromScale(-0.4, 0)
				tween(sh, 0.9, { Position = UDim2.fromScale(1, 0) }, Enum.EasingStyle.Sine)
			end
			task.wait(1.2)
		end
	end)
	local obj = {}
	function obj:Remove()
		alive = false
		row:Destroy()
	end
	return register(self, {}, obj, "Skeleton")
end

-- Tab:Typewriter({ Text = "...", Speed = 40 }): a text row that types itself out. obj:Say("new text") types again.
function Tab:Typewriter(o)
	o = o or {}
	local row = self:_row(30)
	row.AutomaticSize = Enum.AutomaticSize.Y
	local l = new("TextLabel", { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = "", Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.Text, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left }, row)
	local tok
	local obj = {}
	function obj:Say(text)
		text = tostring(text or "")
		local mine = {}
		tok = mine
		task.spawn(function()
			local spd = o.Speed or 40
			for i = 1, #text do
				if tok ~= mine then
					return
				end
				l.Text = text:sub(1, i) .. (i < #text and "_" or "")
				task.wait(1 / spd)
			end
			l.Text = text
		end)
	end
	obj:Say(o.Text or "")
	return register(self, {}, obj, "Typewriter")
end

-- RebelUI:Activate({ Mode = "Cover" | "Logo", Video, Logo, Title, Text, Button, Theme, Timeout, BoomText })
-- A big glowing Activate button. "Cover" fills the screen (video behind it if you give one), "Logo" is just your logo + button.
-- Tap = padlock opens, boom, then the call returns true. Returns false if the switch is off or Timeout runs out.
function RebelUI:Activate(o)
	o = o or {}
	if RebelUI._off then
		return false
	end
	local theme = THEMES[o.Theme or "Red"] or THEMES.Red
	local F = RebelUI.Fancy
	local cover = (o.Mode or "Cover") ~= "Logo"
	local name = o.Name or "RebelUI_Activate"
	clearOld(name)
	local sg = new("ScreenGui", { Name = name, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 9990, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
	pcall(function()
		sg.ScreenInsets = Enum.ScreenInsets.None
	end)
	sg.Parent = pickParent()
	RebelUI._fancyGui(sg)
	local root = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 3, 5), BackgroundTransparency = cover and 0 or 0.35, BorderSizePixel = 0, Active = true, ZIndex = 1 }, sg)
	if cover and o.Video then
		pcall(function()
			local src = o.Video
			if not tostring(src):find("^rbxasset") and not tostring(src):find("^rbxassetid") then
				src = RebelUI.ResolveMedia(o.Video, o.VideoFile)
			end
			if src then
				local vf = new("VideoFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Looped = true, Volume = 0, Video = src, ZIndex = 2 }, root)
				vf.Playing = true
				new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 3 }, root)
			end
		end)
	end
	local box = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(300, 300), BackgroundTransparency = 1, ZIndex = 5 }, root)
	local y = 0
	if o.Logo then
		local lg = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.fromOffset(96, 96), BackgroundTransparency = 1, Image = asset(o.Logo), ScaleType = Enum.ScaleType.Fit, ZIndex = 6 }, box)
		corner(lg, 20)
		RebelUI._iconFix(lg, o.Logo)
		pcall(RebelUI._imageEffect, lg, "Float", theme)
		y = 108
	end
	local title = new("TextLabel", { Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = (o.Title or "Rebelwar"), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 30, ZIndex = 6 }, box)
	new("TextLabel", { Position = UDim2.fromOffset(0, y + 42), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = o.Text or "Tap to activate", TextColor3 = Color3.fromRGB(210, 210, 220), Font = Enum.Font.GothamMedium, TextSize = 14, ZIndex = 6 }, box)
	local btn = new("TextButton", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, y + 84), Size = UDim2.fromOffset(240, 58), BackgroundColor3 = theme.Glow, AutoButtonColor = false, Text = "", ZIndex = 6 }, box)
	corner(btn, 14)
	local stroke = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Transparency = 0.4 }, btn)
	local lock = new("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(30, 30), BackgroundTransparency = 1, Image = asset(RebelUI.Icons.padlock), ZIndex = 7 }, btn)
	corner(lock, 8)
	RebelUI._iconFix(lock, RebelUI.Icons.padlock)
	local lbl = new("TextLabel", { Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Text = o.Button or "ACTIVATE", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 20, ZIndex = 7 }, btn)
	local sc = new("UIScale", { Scale = 1 }, btn)
	pcall(function()
		TweenService:Create(sc, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Scale = 1.05 }):Play()
		TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.9 }):Play()
	end)
	local done, result = false, nil
	local function finish(val)
		if done then
			return
		end
		done, result = true, val
	end
	btn.Activated:Connect(function()
		if done then
			return
		end
		pcall(function()
			lock.Image = asset(RebelUI.Icons.openpadlock)
		end)
		lbl.Text = "ACTIVATED"
		pcall(RebelUI.Boom, sg, { Color = theme.Glow, Count = 40, Text = o.BoomText, Style = o.BoomStyle, Image = o.BoomImage })
		task.delay(0.9, function()
			finish(true)
		end)
	end)
	if o.Timeout then
		task.delay(o.Timeout, function()
			finish(false)
		end)
	end
	while not done do
		task.wait(0.1)
	end
	pcall(function()
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("TextLabel") then
				tween(d, 0.4, { TextTransparency = 1 })
			end
		end
		tween(root, 0.45, { BackgroundTransparency = 1 })
	end)
	task.wait(0.5)
	sg:Destroy()
	return result == true
end

-- ============================================================ saved choices, music, custom crosshair, asset preview, loading picker, trail
-- RebelUI.LoadPrefs(file, defaults) -> table     RebelUI.SavePrefs(file, table)   (a small json file in your executor's workspace folder)
function RebelUI.LoadPrefs(file, defaults)
	local out = {}
	for k, v in pairs(defaults or {}) do
		out[k] = v
	end
	pcall(function()
		if isfile and isfile(file) then
			local t = game:GetService("HttpService"):JSONDecode(readfile(file))
			if type(t) == "table" then
				for k, v in pairs(t) do
					out[k] = v
				end
			end
		end
	end)
	return out
end
function RebelUI.SavePrefs(file, t)
	pcall(function()
		if writefile then
			writefile(file, game:GetService("HttpService"):JSONEncode(t))
		end
	end)
end

-- RebelUI.LoadingStyles = the choices. RebelUI.StartupOptions(baseLoadingOptions, prefs) -> Loading options for the chosen style
RebelUI.LoadingStyles = { "Full cover", "Video", "Logo only", "Minimal", "Custom" }
local function isVideoLink(s)
	s = tostring(s or ""):lower()
	return s:find("%.mp4") ~= nil or s:find("%.webm") ~= nil or s:find("%.mov") ~= nil
end
function RebelUI.StartupOptions(base, p)
	local o = {}
	for k, v in pairs(base or {}) do
		o[k] = v
	end
	local s = (p and p.Style) or "Full cover"
	if s == "Full cover" then
		o.Video = nil
	elseif s == "Video" then
		-- keeps base.Video
	elseif s == "Logo only" then
		o.Video, o.Banner = nil, nil
	elseif s == "Minimal" then
		o.Video, o.Banner, o.Logo, o.Subtitle = nil, nil, nil, nil
	elseif s == "Custom" then
		local c = tostring((p and p.Custom) or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if c ~= "" then
			if isVideoLink(c) then
				o.Video = c
			else
				o.Video = nil
				o.Banner = c
				if c:match("^https?://") then
					local okR, a = pcall(RebelUI.ResolveImage, c)
					o.Banner = okR and a or base.Banner
				end
			end
		end
	end
	return o
end

-- ---------------------------------------------------------------- audio
local function resolveAudio(src)
	src = tostring(src or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if src == "" then
		return nil, "type a song id or link first"
	end
	local id = src:match("^rbxassetid://(%d+)$") or src:match("^(%d+)$") or src:match("roblox%.com/.-/(%d+)")
	if id and not src:match("^https?://[^r]") then
		return "rbxassetid://" .. id
	end
	if src:match("^rbxasset") then
		return src
	end
	if not src:match("^https?://") then
		return nil, "that is not an id or a link"
	end
	if not (writefile and getcustomasset and isfile) then
		return nil, "your executor can't play song links (no getcustomasset). Use a Roblox audio id"
	end
	local sum = 0
	for i = 1, #src do
		sum = (sum * 31 + src:byte(i)) % 4294967291
	end
	local ext = src:lower():match("%.(mp3)") or src:lower():match("%.(ogg)") or src:lower():match("%.(wav)") or "mp3"
	pcall(function()
		if makefolder and not isfolder("RebelUI_audio") then
			makefolder("RebelUI_audio")
		end
	end)
	local path = "RebelUI_audio/" .. tostring(sum) .. "." .. ext
	if not isfile(path) then
		local okG, body = pcall(function()
			return game:HttpGet(src)
		end)
		if not okG or type(body) ~= "string" or #body < 2000 or body:sub(1, 1) == "<" then
			return nil, "could not download that link (it must be a direct .mp3 / .ogg file)"
		end
		if #body > 30000000 then
			return nil, "that file is too big (30 MB max)"
		end
		pcall(writefile, path, body)
	end
	local okA, a = pcall(getcustomasset, path)
	if not okA or not a then
		return nil, "your executor could not load the file"
	end
	return a
end
RebelUI.ResolveAudio = resolveAudio

-- Tab:MusicPlayer({ Presets = { { Name = "My song", Id = 123 }, { Name = "Link", Url = "https://...mp3" } }, Volume = 0.5, Loop = false })
-- Song id (Roblox audio), or a direct .mp3 / .ogg link (downloaded once, then kept). Returns p with :Play(src) :Pause() :Stop() :SetVolume(0-1) .Sound
function Tab:MusicPlayer(o)
	o = o or {}
	local win = self.Win
	local snd = Instance.new("Sound")
	snd.Name, snd.Volume, snd.Looped = "RebelUI_Music", o.Volume or 0.5, o.Loop == true
	snd.Parent = game:GetService("SoundService")
	local p = { Sound = snd }
	local cur = ""
	self:Section(o.Title or "Music")
	local status = self:Label("Nothing playing. Paste a song id or a .mp3 link, then tap Play.")
	local function say(t)
		pcall(function()
			status:Set(t)
		end)
	end
	function p:Play(src)
		src = src or cur
		task.spawn(function()
			say("Loading...")
			local a, why = resolveAudio(src)
			if not a then
				say(why or "could not load")
				pcall(function()
					win:Notify({ Type = "warn", Title = "Music", Text = why or "could not load" })
				end)
				return
			end
			snd:Stop()
			snd.SoundId = a
			local t0 = os.clock()
			while not snd.IsLoaded and os.clock() - t0 < 12 do
				task.wait(0.1)
			end
			if not snd.IsLoaded then
				say("That song would not load (wrong id, or it is private).")
				return
			end
			snd:Play()
			say("Playing: " .. tostring(src):sub(1, 48))
		end)
	end
	function p:Pause()
		if snd.IsPlaying then
			snd:Pause()
			say("Paused")
		else
			snd:Resume()
			say("Playing")
		end
	end
	function p:Stop()
		snd:Stop()
		say("Stopped")
	end
	function p:SetVolume(v)
		snd.Volume = math.clamp(v, 0, 1)
	end
	if o.Presets and #o.Presets > 0 then
		local names, by = {}, {}
		for _, s in ipairs(o.Presets) do
			names[#names + 1] = s.Name
			by[s.Name] = s.Url or s.Id
		end
		self:Dropdown({ Name = "Songs", Options = names, Callback = function(n)
			cur = tostring(by[n] or "")
			p:Play(cur)
		end })
	end
	self:Input({ Name = "Song id or link", Placeholder = "123456 or https://...mp3", Callback = function(t)
		cur = tostring(t or "")
	end })
	self:Button({ Name = "Play", Callback = function()
		p:Play(cur)
	end })
	self:Button({ Name = "Pause / Resume", Callback = function()
		p:Pause()
	end })
	self:Button({ Name = "Stop", Callback = function()
		p:Stop()
	end })
	self:Slider({ Name = "Volume", Min = 0, Max = 100, Default = math.floor((o.Volume or 0.5) * 100), Suffix = "%", Callback = function(v)
		p:SetVolume(v / 100)
	end })
	self:Toggle({ Name = "Loop", Default = o.Loop == true, Callback = function(on)
		snd.Looped = on
	end })
	return p
end

-- ---------------------------------------------------------------- crosshair
RebelUI.CrosshairShapes = { "Cross", "Plus", "Dot", "Circle", "Square", "Diamond", "X", "Custom image" }
RebelUI.CrosshairColors = { Red = Color3.fromRGB(255, 50, 60), White = Color3.fromRGB(255, 255, 255), Green = Color3.fromRGB(70, 255, 110), Cyan = Color3.fromRGB(60, 230, 255), Yellow = Color3.fromRGB(255, 225, 60), Pink = Color3.fromRGB(255, 90, 200), Orange = Color3.fromRGB(255, 150, 40), Rainbow = false }
-- Tab:CrosshairPicker({ Shape, Color, Size, Thickness, Gap, Opacity, Image }) : shapes, colors, size, a spinner, and YOUR OWN image
-- (a Roblox asset id, or a link to a png). Returns c with :Set({ ... }) :Enable(bool) :Destroy()
function Tab:CrosshairPicker(o)
	o = o or {}
	local win = self.Win
	local RunService = game:GetService("RunService")
	local st = { On = o.Enabled ~= false and o.Enabled ~= nil and o.Enabled or false, Shape = o.Shape or "Cross", Color = o.Color or "Red", Size = o.Size or 24, Thick = o.Thickness or 2, Gap = o.Gap or 4, Alpha = o.Opacity or 100, Image = o.Image or "", Spin = false }
	local gui = new("ScreenGui", { Name = "RebelUI_Cross", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 996, Enabled = false })
	gui.Parent = pickParent()
	local hold = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(300, 300), BackgroundTransparency = 1, Active = false }, gui)
	local paints = {}
	local c = {}
	local function bar(x, y, w, h, rot)
		local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, x, 0.5, y), Size = UDim2.fromOffset(w, h), BorderSizePixel = 0, Rotation = rot or 0 }, hold)
		paints[#paints + 1] = { f, "BackgroundColor3", "BackgroundTransparency" }
		return f
	end
	local function draw()
		for _, ch in ipairs(hold:GetChildren()) do
			ch:Destroy()
		end
		paints = {}
		local s, t, g = st.Size, st.Thick, st.Gap
		local shape = st.Shape
		if shape == "Cross" or shape == "Plus" then
			local len = s
			if shape == "Plus" then
				bar(0, 0, len * 2 + g * 2, t)
				bar(0, 0, t, len * 2 + g * 2)
			else
				bar(-(g + len / 2), 0, len, t)
				bar(g + len / 2, 0, len, t)
				bar(0, -(g + len / 2), t, len)
				bar(0, g + len / 2, t, len)
			end
		elseif shape == "Dot" then
			local d = bar(0, 0, math.max(t * 2, 4), math.max(t * 2, 4))
			new("UICorner", { CornerRadius = UDim.new(1, 0) }, d)
		elseif shape == "Circle" or shape == "Square" or shape == "Diamond" then
			local f = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(s * 2, s * 2), BackgroundTransparency = 1, Rotation = shape == "Diamond" and 45 or 0 }, hold)
			if shape == "Circle" then
				new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
			end
			local sk = new("UIStroke", { Thickness = t, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, f)
			paints[#paints + 1] = { sk, "Color", "Transparency" }
		elseif shape == "X" then
			bar(0, 0, s * 2, t, 45)
			bar(0, 0, s * 2, t, -45)
		elseif shape == "Custom image" then
			local img = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(s * 2, s * 2), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit }, hold)
			paints[#paints + 1] = { img, "ImageColor3", "ImageTransparency", true }
			if tostring(st.Image) ~= "" then
				RebelUI.SetImage(img, st.Image)
			end
		end
	end
	local conn
	local hue = 0
	local function paint(dt)
		local col = RebelUI.CrosshairColors[st.Color]
		if col == false or col == nil then
			hue = (hue + (dt or 0) * 0.4) % 1
			col = Color3.fromHSV(hue, 0.9, 1)
		end
		local tr = 1 - st.Alpha / 100
		for _, pnt in ipairs(paints) do
			local inst, prop, tprop, isImg = pnt[1], pnt[2], pnt[3], pnt[4]
			if inst.Parent then
				if isImg and st.Color == "White" then
					inst[prop] = Color3.new(1, 1, 1)
				else
					inst[prop] = col
				end
				inst[tprop] = tr
			end
		end
		if st.Spin then
			hold.Rotation = (hold.Rotation + (dt or 0) * 180) % 360
		else
			hold.Rotation = 0
		end
	end
	local function refresh()
		gui.Enabled = st.On
		if st.On and not conn then
			conn = RunService.RenderStepped:Connect(paint)
		elseif not st.On and conn then
			conn:Disconnect()
			conn = nil
		end
		draw()
		paint(0)
	end
	function c:Set(t)
		for k, v in pairs(t or {}) do
			st[k] = v
		end
		refresh()
	end
	function c:Enable(on)
		st.On = on == true
		refresh()
	end
	function c:Destroy()
		if conn then
			conn:Disconnect()
		end
		gui:Destroy()
	end
	self:Section(o.Title or "Crosshair")
	self:Toggle({ Name = "Crosshair on screen", Default = st.On, Callback = function(on)
		c:Enable(on)
	end })
	self:Dropdown({ Name = "Shape", Options = RebelUI.CrosshairShapes, Default = st.Shape, Callback = function(v)
		c:Set({ Shape = v })
	end })
	local colorNames = { "Red", "White", "Green", "Cyan", "Yellow", "Pink", "Orange", "Rainbow" }
	self:Dropdown({ Name = "Color", Options = colorNames, Default = st.Color, Callback = function(v)
		c:Set({ Color = v })
	end })
	self:Slider({ Name = "Size", Min = 3, Max = 80, Default = st.Size, Callback = function(v)
		c:Set({ Size = v })
	end })
	self:Slider({ Name = "Thickness", Min = 1, Max = 10, Default = st.Thick, Callback = function(v)
		c:Set({ Thick = v })
	end })
	self:Slider({ Name = "Gap", Min = 0, Max = 30, Default = st.Gap, Callback = function(v)
		c:Set({ Gap = v })
	end })
	self:Slider({ Name = "Opacity", Min = 10, Max = 100, Default = st.Alpha, Suffix = "%", Callback = function(v)
		c:Set({ Alpha = v })
	end })
	self:Toggle({ Name = "Spin", Default = false, Callback = function(on)
		c:Set({ Spin = on })
	end })
	self:Input({ Name = "Your image (id or link)", Placeholder = "Roblox image id or https://...png", Default = tostring(st.Image), Callback = function(t)
		c:Set({ Image = t, Shape = (tostring(t) ~= "" and "Custom image" or st.Shape) })
	end })
	draw()
	refresh()
	return c
end

-- Tab:AssetPicker({ Name, Default, Callback(src) }) : type a Roblox image id or a link and SEE it before you use it
function Tab:AssetPicker(o)
	o = o or {}
	local win = self.Win
	local row = self:_row(86)
	local nm = label(row, o.Name or "Image id or link", 11, C.Text, true)
	nm.Position = UDim2.fromOffset(10, 4)
	nm.Size = UDim2.new(1, -20, 0, 16)
	local prev = new("ImageLabel", { Position = UDim2.fromOffset(10, 24), Size = UDim2.fromOffset(54, 54), BackgroundTransparency = 0.6, BackgroundColor3 = Color3.fromRGB(30, 20, 22), ScaleType = Enum.ScaleType.Fit }, row)
	corner(prev, 8)
	local box = new("TextBox", { Position = UDim2.new(0, 74, 0, 30), Size = UDim2.new(1, -84, 0, 26), BackgroundColor3 = Color3.fromRGB(26, 18, 20), BorderSizePixel = 0, Text = tostring(o.Default or ""), PlaceholderText = "123456 or https://...png", PlaceholderColor3 = C.Dim, TextColor3 = C.Text, TextSize = 10, Font = Enum.Font.Gotham, ClearTextOnFocus = false }, row)
	corner(box, 6)
	local msg = label(row, "", 9, C.Dim, false)
	msg.Position = UDim2.new(0, 74, 0, 60)
	msg.Size = UDim2.new(1, -84, 0, 16)
	local obj = {}
	local function load(t)
		t = tostring(t or "")
		prev.Image = ""
		if t == "" then
			msg.Text = ""
			return
		end
		msg.Text = "Loading..."
		RebelUI.SetImage(prev, t, function(ok)
			msg.Text = ok and "Looks good. White box = the image has white in it." or "Could not load that image."
		end)
		if o.Callback then
			task.spawn(o.Callback, t)
		end
	end
	box.FocusLost:Connect(function()
		load(box.Text)
	end)
	if box.Text ~= "" then
		load(box.Text)
	end
	function obj:Get()
		return box.Text
	end
	function obj:Set(v)
		box.Text = tostring(v)
		load(v)
	end
	return register(self, { Text = o.Name }, obj, "AssetPicker")
end

-- Tab:LoadingPicker({ File = "MyHub_prefs.json", Base = { Title, Subtitle, Logo, Banner, Video, Theme }, Notify = true })
-- Choose the loading screen: Full cover, Video, Logo only, Minimal, or Custom (your own image id / link, or a .mp4 link). Saved for next time.
function Tab:LoadingPicker(o)
	o = o or {}
	local win = self.Win
	local file = o.File or "RebelUI_prefs.json"
	local prefs = RebelUI.LoadPrefs(file, { Style = "Full cover", Custom = "" })
	self:Section(o.Title or "Loading screen")
	self:Dropdown({ Name = "Style", Options = RebelUI.LoadingStyles, Default = prefs.Style, Callback = function(v)
		prefs.Style = v
		RebelUI.SavePrefs(file, prefs)
		pcall(function()
			win:Notify({ Type = "success", Title = "Saved", Text = "Loading style: " .. v .. " (next time you run the script)" })
		end)
	end })
	self:Input({ Name = "Custom (image id, image link or .mp4 link)", Placeholder = "used when Style = Custom", Default = prefs.Custom or "", Callback = function(t)
		prefs.Custom = tostring(t or "")
		RebelUI.SavePrefs(file, prefs)
	end })
	self:Button({ Name = "Preview the loading screen", Description = "Shows it for 4 seconds", Callback = function()
		task.spawn(function()
			local opts = RebelUI.StartupOptions(o.Base or {}, prefs)
			opts.Name = "RebelUI_LoadingPreview"
			local L = RebelUI:Loading(opts)
			L:Progress(0.2)
			task.wait(1.5)
			L:Progress(0.7)
			task.wait(1.5)
			L:Finish()
		end)
	end })
	return prefs
end

-- ---------------------------------------------------------------- page transitions and cursor trail
RebelUI.PageAnimations = { "Slide up", "Rise", "From left", "From right", "Zoom", "None" }
function RebelUI._pageIn(win, page)
	local a = win.PageAnim or "Slide up"
	local base = UDim2.fromOffset(0, 32)
	if win.ReduceMotion or a == "None" then
		page.Position = base
		return
	end
	if a == "Zoom" then
		page.Position = base
		local sc = page:FindFirstChild("RebelZoom") or new("UIScale", { Name = "RebelZoom", Scale = 1 }, page)
		sc.Scale = 0.93
		tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		return
	end
	local from = a == "Rise" and UDim2.fromOffset(0, 90) or a == "From left" and UDim2.fromOffset(-50, 32) or a == "From right" and UDim2.fromOffset(50, 32) or UDim2.fromOffset(0, 40)
	page.Position = from
	tween(page, a == "Rise" and 0.4 or 0.24, { Position = base }, a == "Rise" and Enum.EasingStyle.Quint or Enum.EasingStyle.Quad)
end
function Window:SetPageAnimation(name)
	if table.find(RebelUI.PageAnimations, name) then
		self.PageAnim = name
	end
end

-- Win:SetTrail(true, Color3?) : sparkles follow your finger / mouse
function Window:SetTrail(on, color)
	if self._trailConn then
		self._trailConn:Disconnect()
		self._trailConn = nil
	end
	if self._trailGui then
		self._trailGui:Destroy()
		self._trailGui = nil
	end
	if not on then
		return
	end
	local UIS = game:GetService("UserInputService")
	local gui = new("ScreenGui", { Name = "RebelUI_Trail", ResetOnSpawn = false, IgnoreGuiInset = false, DisplayOrder = 9999 })
	gui.Parent = pickParent()
	self._trailGui = gui
	local last, hue = 0, 0
	self._trailConn = UIS.InputChanged:Connect(function(i)
		if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if self.ReduceMotion or os.clock() - last < 0.02 then
			return
		end
		last = os.clock()
		hue = (hue + 0.02) % 1
		local col = color or (self.Theme and self.Theme.Glow) or Color3.fromRGB(255, 70, 80)
		if color == "Rainbow" then
			col = Color3.fromHSV(hue, 0.8, 1)
		end
		local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(i.Position.X, i.Position.Y), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = col, BorderSizePixel = 0, Active = false }, gui)
		new("UICorner", { CornerRadius = UDim.new(1, 0) }, d)
		tween(d, 0.5, { Size = UDim2.fromOffset(2, 2), BackgroundTransparency = 1 })
		task.delay(0.55, function()
			d:Destroy()
		end)
	end)
end

-- ============================================================ everything the player does is written to the Summary
-- Win:LogAction(title, detail, kind)  kind = "command" (default) / "read" / "search". Toggles, sliders, dropdowns, buttons, inputs,
-- keybinds and tab changes call it by themselves. Pass NoLog = true in an element's options to keep it out.
-- Win:GetActions() -> list    Win:GetSummaryText() -> one text with every alert and action    (copy / print buttons use it)
function Window:LogAction(title, detail, kind)
	if self._building or os.clock() - (self._born or 0) < 3 then
		return
	end
	local e = { Time = os.date("%H:%M:%S"), Title = tostring(title), Detail = detail and tostring(detail) or "", Kind = kind or "command" }
	self._actions = self._actions or {}
	table.insert(self._actions, e)
	if #self._actions > 300 then
		table.remove(self._actions, 1)
	end
	if self._onAction then
		pcall(self._onAction, e)
	end
end
function Window:GetActions()
	return self._actions or {}
end
function Window:GetSummaryText()
	local out = { "RebelUI summary  |  " .. tostring(self.Title or "") .. "  |  " .. os.date("%Y-%m-%d %H:%M:%S"), "", "-- What you did --" }
	for _, a in ipairs(self._actions or {}) do
		out[#out + 1] = a.Time .. "  " .. a.Title .. (a.Detail ~= "" and ("  (" .. a.Detail .. ")") or "")
	end
	out[#out + 1] = ""
	out[#out + 1] = "-- Alerts --"
	for _, n in ipairs(self._noteLog or {}) do
		out[#out + 1] = tostring(n.Time) .. "  [" .. tostring(n.Type or "info") .. "] " .. tostring(n.Title) .. ": " .. tostring(n.Text)
	end
	return table.concat(out, "\n")
end

local function hideSecret(name, v)
	local n = tostring(name):lower()
	if n:find("key") or n:find("pass") or n:find("token") or n:find("secret") then
		return "(hidden)"
	end
	return tostring(v):sub(1, 40)
end
local function wrapAction(method, describe, debounce)
	local orig = Tab[method]
	if not orig then
		return
	end
	Tab[method] = function(self, o, ...)
		if type(o) == "table" and not o.NoLog and not o._wrapped then
			o._wrapped = true
			local cb = o.Callback
			local nm = tostring(o.Name or method)
			local win = self.Win
			local stamp = 0
			o.Callback = function(...)
				local args = table.pack(...)
				local function log()
					local t, d = describe(nm, table.unpack(args, 1, args.n))
					if t then
						win:LogAction(t, d)
					end
				end
				if debounce then
					stamp += 1
					local mine = stamp
					task.delay(debounce, function()
						if mine == stamp then
							log()
						end
					end)
				else
					log()
				end
				if cb then
					return cb(...)
				end
			end
		end
		return orig(self, o, ...)
	end
end
wrapAction("Toggle", function(n, on)
	return "Turned " .. n .. (on and " ON" or " OFF")
end)
wrapAction("Slider", function(n, v)
	return "Set " .. n .. " to " .. tostring(v)
end, 0.8)
wrapAction("RangeSlider", function(n, v)
	return "Changed " .. n
end, 0.8)
wrapAction("Dropdown", function(n, v)
	local s = v
	if type(v) == "table" then
		local t = {}
		for k, on in pairs(v) do
			if on then
				t[#t + 1] = tostring(k)
			end
		end
		s = table.concat(t, ", ")
	end
	return "Chose in " .. n, tostring(s):sub(1, 50)
end)
wrapAction("Button", function(n)
	return "Pressed " .. n
end)
wrapAction("HoldButton", function(n)
	return "Held " .. n
end)
wrapAction("Input", function(n, v)
	return "Typed in " .. n, hideSecret(n, v)
end)
wrapAction("Keybind", function(n, v)
	return "Set key for " .. n, tostring(v)
end)
wrapAction("Color", function(n)
	return "Changed color " .. n
end, 0.8)
wrapAction("Choice", function(n, v)
	return "Picked in " .. n, tostring(v)
end)
wrapAction("Cycle", function(n, v)
	return "Picked in " .. n, tostring(v)
end)
wrapAction("Stepper", function(n, v)
	return "Set " .. n, tostring(v)
end, 0.6)
wrapAction("Rating", function(n, v)
	return "Rated " .. n, tostring(v)
end)

-- Tab:IconButtons({ { Icon = UI.Icons.refresh, Name = "Refresh", Async = true, Callback = function(done) ...; done() end }, ... })
-- A row of icon buttons. An Async button swaps its icon for the loading icon while it works: the icon spins slowly, speeds up for
-- about 5 seconds, slows down and pauses, then does it again, until the callback calls done(). Min = seconds to keep spinning (default 1.5).
function Tab:IconButtons(list)
	local win = self.Win
	local row = self:_row(52)
	local n = #list
	local obj = {}
	for i, b in ipairs(list) do
		local btn = new("TextButton", { Position = UDim2.new((i - 1) / n, 4, 0, 4), Size = UDim2.new(1 / n, -8, 1, -8), BackgroundColor3 = Color3.fromRGB(44, 22, 28), Text = "", AutoButtonColor = false, ClipsDescendants = false }, row)
		corner(btn, 10)
		local st = new("UIStroke", { Color = Color3.fromRGB(120, 40, 50), Thickness = 1.2 }, btn)
		local ic = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 5), Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1, Image = asset(b.Icon), ScaleType = Enum.ScaleType.Fit, ZIndex = 3 }, btn)
		RebelUI._iconFix(ic, b.Icon)
		local nm = label(btn, tostring(b.Name or ""), 9, C.Text, true)
		nm.Position = UDim2.new(0, 0, 0, 27)
		nm.Size = UDim2.new(1, 0, 0, 12)
		nm.ZIndex = 3
		local sc = new("UIScale", { Scale = 1 }, btn)
		local busy = false
		btn.MouseEnter:Connect(function()
			tween(btn, 0.15, { BackgroundColor3 = Color3.fromRGB(80, 28, 36) })
			tween(st, 0.15, { Color = win.Theme and win.Theme.Glow or Color3.fromRGB(255, 70, 80) })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, 0.2, { BackgroundColor3 = Color3.fromRGB(44, 22, 28) })
			tween(st, 0.2, { Color = Color3.fromRGB(120, 40, 50) })
		end)
		local function flash(text)
			local old = b.Name or ""
			nm.Text = text
			task.delay(1.1, function()
				if nm.Parent then
					nm.Text = old
				end
			end)
		end
		btn.Activated:Connect(function()
			if busy then
				return
			end
			tween(sc, 0.07, { Scale = 0.9 })
			task.delay(0.07, function()
				tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			end)
			if not b.Async then
				flash(b.Done or "Done")
				if b.Callback then
					task.spawn(b.Callback)
				end
				return
			end
			-- ---- async: loading icon with a slow > fast > slow > stop spin, repeated until done()
			busy = true
			local finished, finishedAt = false, nil
			local started = os.clock()
			RebelUI._setIcon(ic, RebelUI.Icons.loading)
			nm.Text = b.Working or "Working..."
			local PHASES = { { 1.6, 60, 220 }, { 5, 720, 720 }, { 1.6, 220, 40 }, { 0.5, 0, 0 } } -- seconds, deg/s start, deg/s end
			local ph, pt, rot = 1, 0, 0
			local conn
			conn = game:GetService("RunService").RenderStepped:Connect(function(dt)
				if not btn.Parent then -- the window was closed while it was spinning
					conn:Disconnect()
					return
				end
				if win.ReduceMotion then
					return
				end
				local P = PHASES[ph]
				pt += dt
				local k = math.min(pt / P[1], 1)
				local speed = P[2] + (P[3] - P[2]) * k
				if finished then
					speed = speed * math.max(0, 1 - (os.clock() - finishedAt) / 0.35)
				end
				rot = (rot + speed * dt) % 360
				ic.Rotation = rot
				if pt >= P[1] then
					pt = 0
					ph = ph % #PHASES + 1
				end
			end)
			local function done(ok)
				if finished then
					return
				end
				finished = true
				finishedAt = os.clock()
				task.spawn(function()
					local minT = b.Min or 1.5
					local left = minT - (os.clock() - started)
					if left > 0 then
						task.wait(left)
						finishedAt = os.clock()
					end
					task.wait(0.4)
					conn:Disconnect()
					ic.Rotation = 0
					RebelUI._setIcon(ic, b.Icon)
					busy = false
					flash(ok == false and (b.Failed or "Failed") or (b.Done or "Done"))
				end)
			end
			local okC, err = pcall(function()
				if b.Callback then
					task.spawn(function()
						local ok2, e2 = pcall(b.Callback, done)
						if not ok2 then
							warn("[RebelUI] icon button error: " .. tostring(e2))
							done(false)
						end
					end)
				else
					done()
				end
			end)
			if not okC then
				done(false)
			end
		end)
	end
	return register(self, {}, obj, "IconButtons")
end


-- ============================================================ turn black icons white (so they need no background at all)
-- RebelUI._png.whiten(pngBytes) -> new png bytes (white, same shape) or nil. Pure Luau: inflate + png unfilter + stored-deflate encode.
-- Your executor downloads the icon from Roblox, this makes it white, saves it in RebelUI_icons/ and shows that instead.
-- RebelUI.AutoWhite = false turns it off (the soft glow is used instead).
RebelUI.AutoWhite = true
local PNG = {}
RebelUI._png = PNG
local band, rshift, lshift, bxor = bit32.band, bit32.rshift, bit32.lshift, bit32.bxor

local LBASE = { 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258 }
local LEXT = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0 }
local DBASE = { 1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577 }
local DEXT = { 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13 }
local CLORD = { 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15 }

local function buildHuff(lengths, n)
	local count, offs, syms = {}, {}, {}
	for i = 0, 15 do
		count[i] = 0
	end
	for i = 0, n - 1 do
		count[lengths[i] or 0] += 1
	end
	count[0] = 0
	offs[1] = 0
	for i = 1, 14 do
		offs[i + 1] = offs[i] + count[i]
	end
	for i = 0, n - 1 do
		local l = lengths[i] or 0
		if l ~= 0 then
			syms[offs[l]] = i
			offs[l] += 1
		end
	end
	return { count = count, syms = syms }
end

-- zlib inflate. `data` is a string, returns a table of bytes (or nil)
function PNG.inflate(data, start)
	local pos, bitbuf, bitcnt = start or 3, 0, 0 -- skip the 2-byte zlib header
	local len = #data
	local function bits(n)
		while bitcnt < n do
			if pos > len then
				error("eof")
			end
			bitbuf = bitbuf + lshift(data:byte(pos), bitcnt)
			pos += 1
			bitcnt += 8
		end
		local v = band(bitbuf, lshift(1, n) - 1)
		bitbuf = rshift(bitbuf, n)
		bitcnt -= n
		return v
	end
	local function decode(h)
		local code, first, index = 0, 0, 0
		for l = 1, 15 do
			code = code + bits(1)
			local c = h.count[l]
			if code - c < first then
				return h.syms[index + (code - first)]
			end
			index += c
			first = (first + c) * 2
			code = code * 2
		end
		error("bad code")
	end
	local out, n = {}, 0
	local fixedL, fixedD
	repeat
		local final = bits(1)
		local typ = bits(2)
		if typ == 0 then
			bitbuf, bitcnt = 0, 0
			local l = data:byte(pos) + data:byte(pos + 1) * 256
			pos += 4
			for i = 0, l - 1 do
				n += 1
				out[n] = data:byte(pos + i)
			end
			pos += l
		else
			local hl, hd
			if typ == 1 then
				if not fixedL then
					local l = {}
					for i = 0, 143 do l[i] = 8 end
					for i = 144, 255 do l[i] = 9 end
					for i = 256, 279 do l[i] = 7 end
					for i = 280, 287 do l[i] = 8 end
					fixedL = buildHuff(l, 288)
					local d = {}
					for i = 0, 29 do d[i] = 5 end
					fixedD = buildHuff(d, 30)
				end
				hl, hd = fixedL, fixedD
			elseif typ == 2 then
				local nlen, ndist, ncode = bits(5) + 257, bits(5) + 1, bits(4) + 4
				local cl = {}
				for i = 0, 18 do cl[i] = 0 end
				for i = 1, ncode do cl[CLORD[i]] = bits(3) end
				local ch = buildHuff(cl, 19)
				local lens, idx = {}, 0
				while idx < nlen + ndist do
					local sym = decode(ch)
					if sym < 16 then
						lens[idx] = sym
						idx += 1
					else
						local prev, rep = 0, 0
						if sym == 16 then
							prev = lens[idx - 1]
							rep = 3 + bits(2)
						elseif sym == 17 then
							rep = 3 + bits(3)
						else
							rep = 11 + bits(7)
						end
						for _ = 1, rep do
							lens[idx] = prev
							idx += 1
						end
					end
				end
				local ll, dl = {}, {}
				for i = 0, nlen - 1 do ll[i] = lens[i] end
				for i = 0, ndist - 1 do dl[i] = lens[nlen + i] end
				hl, hd = buildHuff(ll, nlen), buildHuff(dl, ndist)
			else
				error("bad block")
			end
			while true do
				local sym = decode(hl)
				if sym < 256 then
					n += 1
					out[n] = sym
				elseif sym == 256 then
					break
				else
					sym -= 257
					local l = LBASE[sym + 1] + bits(LEXT[sym + 1])
					local ds = decode(hd)
					local dist = DBASE[ds + 1] + bits(DEXT[ds + 1])
					for _ = 1, l do
						n += 1
						out[n] = out[n - dist]
					end
				end
				if n % 60000 == 0 then
					task.wait() -- keep the game running while a big icon is processed
				end
			end
		end
	until final == 1
	return out, n
end

local crcT
local function crc32(s)
	if not crcT then
		crcT = {}
		for i = 0, 255 do
			local c = i
			for _ = 1, 8 do
				if band(c, 1) == 1 then
					c = bxor(0xEDB88320, rshift(c, 1))
				else
					c = rshift(c, 1)
				end
			end
			crcT[i] = c
		end
	end
	local c = 0xFFFFFFFF
	for i = 1, #s do
		c = bxor(crcT[band(bxor(c, s:byte(i)), 255)], rshift(c, 8))
	end
	return bxor(c, 0xFFFFFFFF)
end
local function be32(n)
	return string.char(band(rshift(n, 24), 255), band(rshift(n, 16), 255), band(rshift(n, 8), 255), band(n, 255))
end
local function chunk(name, body)
	return be32(#body) .. name .. body .. be32(crc32(name .. body))
end

-- decode a png into { w, h, rgba = function(x, y) } -> returns w, h, getpixel table of alpha/luma info
function PNG.decode(bytes)
	if bytes:sub(1, 8) ~= "\137PNG\r\n\26\n" then
		return nil, "not a png"
	end
	local pos, w, h, depth, ctype, interlace = 9, 0, 0, 0, 0, 0
	local idat, plte, trns = {}, nil, nil
	while pos <= #bytes do
		local l = (bytes:byte(pos) * 16777216) + bytes:byte(pos + 1) * 65536 + bytes:byte(pos + 2) * 256 + bytes:byte(pos + 3)
		local name = bytes:sub(pos + 4, pos + 7)
		local body = bytes:sub(pos + 8, pos + 7 + l)
		if name == "IHDR" then
			w = body:byte(1) * 16777216 + body:byte(2) * 65536 + body:byte(3) * 256 + body:byte(4)
			h = body:byte(5) * 16777216 + body:byte(6) * 65536 + body:byte(7) * 256 + body:byte(8)
			depth, ctype, interlace = body:byte(9), body:byte(10), body:byte(13)
		elseif name == "PLTE" then
			plte = body
		elseif name == "tRNS" then
			trns = body
		elseif name == "IDAT" then
			idat[#idat + 1] = body
		elseif name == "IEND" then
			break
		end
		pos += 12 + l
	end
	if interlace ~= 0 or depth ~= 8 or w < 1 or h < 1 or w * h > 4200000 then
		return nil, "unsupported png"
	end
	local chans = ({ [0] = 1, [2] = 3, [3] = 1, [4] = 2, [6] = 4 })[ctype]
	if not chans then
		return nil, "unsupported color type"
	end
	local raw, n = PNG.inflate(table.concat(idat))
	local stride = w * chans
	if n < (stride + 1) * h then
		return nil, "short data"
	end
	-- unfilter in place
	local prev, cur = {}, {}
	for i = 1, stride do
		prev[i] = 0
	end
	local px = {} -- px[y] = row table
	local p = 1
	for y = 1, h do
		local f = raw[p]
		p += 1
		cur = {}
		for i = 1, stride do
			local x = raw[p + i - 1]
			local a = i > chans and cur[i - chans] or 0
			local b = prev[i]
			local c = i > chans and prev[i - chans] or 0
			local v
			if f == 0 then
				v = x
			elseif f == 1 then
				v = x + a
			elseif f == 2 then
				v = x + b
			elseif f == 3 then
				v = x + math.floor((a + b) / 2)
			else
				local pa, pb, pc = math.abs(b - c), math.abs(a - c), math.abs(a + b - 2 * c)
				local pr = (pa <= pb and pa <= pc) and a or (pb <= pc and b or c)
				v = x + pr
			end
			cur[i] = v % 256
		end
		p += stride
		px[y] = cur
		prev = cur
		if y % 16 == 0 then
			task.wait()
		end
	end
	return { w = w, h = h, ctype = ctype, rows = px, plte = plte, trns = trns }
end

-- returns white png bytes: same alpha, white color. If the picture has no alpha, dark pixels become the white shape.
function PNG.whiten(bytes)
	local img, why = PNG.decode(bytes)
	if not img then
		return nil, why
	end
	local w, h, ct = img.w, img.h, img.ctype
	-- build an alpha value per pixel
	local alphaRows, darkSum, darkN, darkPix = {}, 0, 0, 0
	local hasAlpha = ct == 4 or ct == 6 or (ct == 3 and img.trns ~= nil)
	for y = 1, h do
		local r = img.rows[y]
		local a = {}
		for x = 1, w do
			local av, lum
			if ct == 6 then
				av, lum = r[x * 4], (r[x * 4 - 3] * 3 + r[x * 4 - 2] * 6 + r[x * 4 - 1]) / 10
			elseif ct == 4 then
				av, lum = r[x * 2], r[x * 2 - 1]
			elseif ct == 2 then
				av, lum = 255, (r[x * 3 - 2] * 3 + r[x * 3 - 1] * 6 + r[x * 3]) / 10
			elseif ct == 0 then
				av, lum = 255, r[x]
			else
				local idx = r[x]
				local pl = img.plte
				av = img.trns and (img.trns:byte(idx + 1) or 255) or 255
				lum = pl and ((pl:byte(idx * 3 + 1) * 3 + pl:byte(idx * 3 + 2) * 6 + pl:byte(idx * 3 + 3)) / 10) or 0
			end
			if av > 20 then
				darkSum += lum
				darkN += 1
			end
			if lum < 100 then
				darkPix += 1
			end
			a[x] = { av, lum }
		end
		alphaRows[y] = a
	end
	if darkN == 0 or (hasAlpha and darkSum / darkN > 110) or (not hasAlpha and darkPix < w * h * 0.02) then
		return nil, "icon is not dark" -- already light: leave it alone
	end
	local pxs = {}
	for a = 0, 255 do
		pxs[a] = "\255\255\255" .. string.char(a)
	end
	local rows = {}
	for y = 1, h do
		local parts = { "\0" }
		for x = 1, w do
			local av, lum = alphaRows[y][x][1], alphaRows[y][x][2]
			local a
			if hasAlpha then
				a = av
			else
				a = math.clamp(math.floor(255 - lum + 0.5), 0, 255) -- dark = shape
			end
			parts[#parts + 1] = pxs[a]
		end
		rows[y] = table.concat(parts)
		if y % 32 == 0 then
			task.wait()
		end
	end
	local rawStr = table.concat(rows)
	-- zlib with stored blocks
	local z = { "\120\1" }
	local i, total = 1, #rawStr
	local s1, s2 = 1, 0
	for k = 1, total do
		s1 = (s1 + rawStr:byte(k)) % 65521
		s2 = (s2 + s1) % 65521
		if k % 200000 == 0 then
			task.wait()
		end
	end
	while i <= total do
		local blk = rawStr:sub(i, i + 65534)
		local fin = (i + #blk > total) and 1 or 0
		z[#z + 1] = string.char(fin, band(#blk, 255), rshift(#blk, 8), band(bxor(#blk, 65535), 255), rshift(bxor(#blk, 65535), 8))
		z[#z + 1] = blk
		i += #blk
	end
	z[#z + 1] = be32(s2 * 65536 + s1)
	local ihdr = be32(w) .. be32(h) .. "\8\6\0\0\0"
	return "\137PNG\r\n\26\n" .. chunk("IHDR", ihdr) .. chunk("IDAT", table.concat(z)) .. chunk("IEND", "")
end

-- ---- download + cache + swap
local whiteCache, queue, working = {}, {}, false
local watchers = {} -- id -> list of { img, halos }
RebelUI._iconWatch = watchers
local function canWhite()
	return RebelUI.AutoWhite and type(writefile) == "function" and type(getcustomasset) == "function" and type(isfile) == "function"
end
local function fetchPng(id)
	for _ = 1, 3 do
		local okG, body = pcall(function()
			return game:HttpGet("https://assetdelivery.roblox.com/v1/asset/?id=" .. tostring(id))
		end)
		if not okG or type(body) ~= "string" or #body < 50 then
			return nil
		end
		if body:sub(2, 4) == "PNG" then
			return body
		end
		local nid = body:match("[?&]id=(%d+)") or body:match("rbxassetid://(%d+)")
		if not nid or nid == tostring(id) then
			return nil
		end
		id = nid
	end
	return nil
end
local function applyWhite(id, path)
	local okA, a = pcall(getcustomasset, path)
	if not okA or not a then
		return false
	end
	whiteCache[id] = a
	for _, w in ipairs(watchers[id] or {}) do
		pcall(function()
			if w.img and w.img.Parent and RebelUI._curId[w.img] == id then
				w.img.Image = a
				for _, f in ipairs(w.halos or {}) do
					f:Destroy()
				end
			end
		end)
	end
	watchers[id] = nil
	return true
end
local function pump()
	if working then
		return
	end
	working = true
	task.spawn(function()
		while #queue > 0 do
			local id = table.remove(queue, 1)
			pcall(function()
				local path = "RebelUI_icons/" .. id .. "_w.png"
				if isfile(path) then
					applyWhite(id, path)
					return
				end
				local bytes = fetchPng(id)
				if not bytes then
					return
				end
				local out = PNG.whiten(bytes)
				if not out then
					return
				end
				pcall(function()
					if makefolder and not isfolder("RebelUI_icons") then
						makefolder("RebelUI_icons")
					end
				end)
				writefile(path, out)
				applyWhite(id, path)
			end)
			task.wait(0.05)
		end
		working = false
	end)
end
-- called by _iconFix: shows the white version as soon as it exists
function RebelUI._whitenIcon(img, id, halos)
	if not canWhite() then
		return false
	end
	id = tostring(id)
	if whiteCache[id] then
		img.Image = whiteCache[id]
		return true
	end
	watchers[id] = watchers[id] or {}
	table.insert(watchers[id], { img = img, halos = halos })
	if not watchers[id].queued then
		watchers[id].queued = true
		queue[#queue + 1] = id
		pump()
	end
	return false
end

-- ============================================================ cover media, explosion styles, close animations, links
-- RebelUI.PlayCover(gui, src, { Time, Type = "image" | "video", Volume, OnCovered }) -> true if the picture / video was shown.
-- A picture or video that covers the whole screen for a moment (used by the "Custom" close animation and "Custom" explosion).
function RebelUI.PlayCover(gui, src, o)
	o = o or {}
	if not gui or src == nil or tostring(src) == "" then
		return false
	end
	local s = tostring(src):lower()
	local isVideo = o.Type == "video" or s:find("%.mp4") ~= nil or s:find("%.webm") ~= nil or s:find("%.mov") ~= nil
	local cover = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Active = true, ZIndex = 400 }, gui)
	tween(cover, 0.25, { BackgroundTransparency = 0 })
	task.wait(0.27)
	if o.OnCovered then
		pcall(o.OnCovered)
	end
	local shown = false
	local maxT = o.Time or (isVideo and 6 or 2)
	local t0 = os.clock()
	if isVideo then
		local ok, resolved = pcall(RebelUI.ResolveMedia, src, o.File)
		if ok and resolved then
			local okV = pcall(function()
				local vf = new("VideoFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Looped = false, Volume = o.Volume or 0.6, Video = resolved, ZIndex = 401 }, cover)
				vf.Playing = true
				shown = true
				local ended = false
				vf.Ended:Connect(function()
					ended = true
				end)
				while not ended and os.clock() - t0 < maxT and cover.Parent do
					task.wait(0.1)
				end
			end)
			shown = shown and okV
		end
	else
		local im = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop, ImageTransparency = 1, ZIndex = 401 }, cover)
		RebelUI.SetImage(im, src, function(okI)
			if okI and im.Parent then
				shown = true
				tween(im, 0.3, { ImageTransparency = 0 })
			end
		end)
		task.wait(0.5)
		while os.clock() - t0 < maxT and cover.Parent do
			task.wait(0.1)
		end
	end
	tween(cover, 0.3, { BackgroundTransparency = 1 })
	for _, d in ipairs(cover:GetChildren()) do
		pcall(function()
			if d:IsA("ImageLabel") then
				tween(d, 0.3, { ImageTransparency = 1 })
			end
		end)
	end
	task.wait(0.32)
	cover:Destroy()
	return shown
end

-- ---------- explosion styles: UI.Boom(parent, { Style = "Classic" | "Confetti" | "Shockwave" | "Sparks" | "Diamonds" | "Custom" | "None", Image, Media, Color, Count })
RebelUI.BoomStyles = { "Classic", "Confetti", "Shockwave", "Sparks", "Diamonds", "Custom", "None" }
RebelUI.BoomStyle = "Classic"
RebelUI.BoomImage = nil -- the picture used by the "Custom" style (asset id or link)
local BOOMS = {}
local function boomHolder(parent, o)
	local color = o.Color or Color3.fromRGB(255, 200, 80)
	local origin = o.Origin or UDim2.fromScale(0.5, 0.5)
	local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 450)
	local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 300, Active = false }, parent)
	local flash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = color:Lerp(Color3.new(1, 1, 1), 0.6), BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 300 }, holder)
	tween(flash, 0.3, { BackgroundTransparency = 1 })
	return holder, color, origin, math.min(vp.X, vp.Y) * 0.55
end
local function around(origin, ang, dist)
	return UDim2.new(origin.X.Scale, origin.X.Offset + math.cos(ang) * dist, origin.Y.Scale, origin.Y.Offset + math.sin(ang) * dist)
end
BOOMS.Confetti = function(parent, o)
	local holder, color, origin, R = boomHolder(parent, o)
	local palette = { color, Color3.new(1, 1, 1), Color3.fromRGB(255, 205, 70), Color3.fromRGB(255, 90, 170), Color3.fromRGB(70, 210, 255), Color3.fromRGB(110, 255, 150) }
	local n = math.clamp(math.floor((o.Count or 24) * 1.6), 12, 70)
	for i = 1, n do
		local ang = -math.pi / 2 + (math.random() - 0.5) * 2.6
		local dist = R * (0.4 + math.random() * 0.8)
		local p = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = origin, Size = UDim2.fromOffset(math.random(6, 10), math.random(10, 16)), BackgroundColor3 = palette[(i % #palette) + 1], BorderSizePixel = 0, Rotation = math.random(0, 360), ZIndex = 302 }, holder)
		tween(p, 0.45, { Position = around(origin, ang, dist), Rotation = p.Rotation + math.random(-200, 200) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		task.delay(0.45, function()
			if p.Parent then
				local pos = p.Position
				tween(p, 0.95, { Position = UDim2.new(pos.X.Scale, pos.X.Offset + math.random(-40, 40), pos.Y.Scale, pos.Y.Offset + R * 0.9), BackgroundTransparency = 1, Rotation = p.Rotation + math.random(-300, 300) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			end
		end)
	end
	task.delay(1.7, function()
		holder:Destroy()
	end)
end
BOOMS.Shockwave = function(parent, o)
	local holder, color, origin, R = boomHolder(parent, o)
	for i = 1, 5 do
		local r = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = origin, Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, ZIndex = 301 }, holder)
		corner(r, 500)
		local st = new("UIStroke", { Color = i % 2 == 0 and Color3.new(1, 1, 1) or color, Thickness = 7 - i, Transparency = 0.05 }, r)
		task.delay((i - 1) * 0.1, function()
			if r.Parent then
				tween(r, 0.8, { Size = UDim2.fromOffset(R * (0.7 + i * 0.35), R * (0.7 + i * 0.35)) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				tween(st, 0.8, { Transparency = 1, Thickness = 1 })
			end
		end)
	end
	task.delay(1.5, function()
		holder:Destroy()
	end)
end
BOOMS.Sparks = function(parent, o)
	local holder, color, origin, R = boomHolder(parent, o)
	local n = math.clamp(math.floor((o.Count or 24) * 2), 16, 80)
	for i = 1, n do
		local ang = math.random() * math.pi * 2
		local dist = R * (0.5 + math.random() * 1.1)
		local sp = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = origin, Size = UDim2.fromOffset(2, math.random(14, 34)), BackgroundColor3 = (i % 4 == 0) and Color3.new(1, 1, 1) or color, BorderSizePixel = 0, Rotation = math.deg(ang) + 90, ZIndex = 302 }, holder)
		tween(sp, 0.35 + math.random() * 0.3, { Position = around(origin, ang, dist), BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 4) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end
	task.delay(1.2, function()
		holder:Destroy()
	end)
end
BOOMS.Diamonds = function(parent, o)
	local holder, color, origin, R = boomHolder(parent, o)
	local n = math.clamp(math.floor(o.Count or 24), 8, 50)
	for i = 1, n do
		local ang = (i / n) * math.pi * 2 + math.random() * 0.4
		local dist = R * (0.3 + math.random() * 0.8)
		local sz = math.random(8, 20)
		local d = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = origin, Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = (i % 2 == 0) and color or Color3.new(1, 1, 1), BorderSizePixel = 0, Rotation = 45, ZIndex = 302 }, holder)
		tween(d, 0.8 + math.random() * 0.3, { Position = around(origin, ang, dist), Rotation = 45 + math.random(-180, 180), BackgroundTransparency = 1, Size = UDim2.fromOffset(sz * 0.3, sz * 0.3) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end
	task.delay(1.4, function()
		holder:Destroy()
	end)
end
BOOMS.Custom = function(parent, o)
	local img = o.Image or RebelUI.BoomImage
	if img == nil or tostring(img) == "" then
		return RebelUI._classicBoom(parent, o)
	end
	local holder, color, origin, R = boomHolder(parent, o)
	local n = math.clamp(math.floor((o.Count or 24) * 0.7), 8, 30)
	for i = 1, n do
		local ang = (i / n) * math.pi * 2 + math.random() * 0.4
		local dist = R * (0.35 + math.random() * 0.75)
		local sz = math.random(26, 54)
		local im = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = origin, Size = UDim2.fromOffset(sz, sz), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, ZIndex = 302 }, holder)
		RebelUI.SetImage(im, img)
		tween(im, 0.9 + math.random() * 0.3, { Position = around(origin, ang, dist), Rotation = math.random(-360, 360), ImageTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	end
	task.delay(1.5, function()
		holder:Destroy()
	end)
end
function RebelUI.Boom(parent, o)
	o = o or {}
	if not parent then
		return
	end
	local style = o.Style or RebelUI.BoomStyle or "Classic"
	if style == "None" then
		return
	end
	local fn = BOOMS[style]
	if not fn then
		return RebelUI._classicBoom(parent, o)
	end
	local ok, err = pcall(fn, parent, o)
	if not ok then
		RebelUI._reportError("boom " .. tostring(style), err)
		pcall(RebelUI._classicBoom, parent, o)
	end
end

-- ---------- close animations: what happens when the panel is closed
RebelUI.CloseAnimations = { "Normal", "BlackHole", "Shatter", "TVOff", "Spin", "Implode", "Custom", "None" }
local CLOSERS = {}
local function centerOf(gui, target)
	local ok, cx, cy, w, h = pcall(function()
		local ap, as, gp = target.AbsolutePosition, target.AbsoluteSize, gui.AbsolutePosition
		if as.X <= 0 or as.Y <= 0 then
			error("no size")
		end
		return ap.X + as.X / 2 - gp.X, ap.Y + as.Y / 2 - gp.Y, as.X, as.Y
	end)
	if ok then
		return UDim2.fromOffset(cx, cy), w, h, cx, cy
	end
	return UDim2.fromScale(0.5, 0.5), 320, 220, nil, nil
end
local function scaleOf(target)
	return target:FindFirstChildOfClass("UIScale") or new("UIScale", { Scale = 1 }, target)
end
local function veil(target, color)
	local v = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = color or Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 999 }, target)
	corner(v, 16)
	return v
end
local function centered(target)
	return target.AnchorPoint == Vector2.new(0.5, 0.5)
end

CLOSERS.Normal = function(gui, target, o)
	local sc = scaleOf(target)
	local v = veil(target)
	tween(v, 0.3, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quad)
	tween(sc, 0.3, { Scale = sc.Scale * 0.82 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.wait(0.32)
end
CLOSERS.Spin = function(gui, target, o)
	local sc = scaleOf(target)
	tween(target, 0.65, { Rotation = 540 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	tween(sc, 0.65, { Scale = 0.01 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	task.wait(0.7)
end
CLOSERS.TVOff = function(gui, target, o)
	local _, w, h = centerOf(gui, target)
	local v = veil(target, Color3.new(1, 1, 1))
	tween(v, 0.22, { BackgroundTransparency = 0.5 })
	if centered(target) then
		tween(target, 0.22, { Size = UDim2.fromOffset(w, 5) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.24)
		tween(v, 0.1, { BackgroundTransparency = 0 })
		tween(target, 0.2, { Size = UDim2.fromOffset(0, 3) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.22)
	else
		task.wait(0.3)
	end
end
CLOSERS.Implode = function(gui, target, o)
	local sc = scaleOf(target)
	local base = sc.Scale
	local pos = centerOf(gui, target)
	tween(sc, 0.14, { Scale = base * 1.08 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	task.wait(0.14)
	tween(sc, 0.32, { Scale = 0.01 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	task.wait(0.3)
	pcall(function()
		target.Visible = false
	end)
	local ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, ZIndex = 260 }, gui)
	new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, ring)
	local st = new("UIStroke", { Color = o.Color or Color3.fromRGB(255, 70, 80), Thickness = 6 }, ring)
	tween(ring, 0.5, { Size = UDim2.fromOffset(420, 420) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(st, 0.5, { Transparency = 1, Thickness = 1 })
	pcall(RebelUI.Boom, gui, { Color = o.Color, Count = 26, Origin = pos })
	task.wait(0.5)
	ring:Destroy()
end
CLOSERS.Shatter = function(gui, target, o)
	local _, w, h, cx, cy = centerOf(gui, target)
	local COLS, ROWS = 8, 5
	local color = o.Color or Color3.fromRGB(255, 70, 80)
	local layer = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Active = false, ZIndex = 260 }, gui)
	local x0, y0 = (cx or 0) - w / 2, (cy or 0) - h / 2
	if not cx then
		x0, y0 = 0, 0
	end
	local tw, th = w / COLS, h / ROWS
	for r = 0, ROWS - 1 do
		for c = 0, COLS - 1 do
			local t = new("Frame", { Position = UDim2.fromOffset(x0 + c * tw, y0 + r * th), Size = UDim2.fromOffset(tw + 1, th + 1), BackgroundColor3 = Color3.fromRGB(16, 12, 16):Lerp(color, math.random() * 0.25), BorderSizePixel = 0, ZIndex = 261 }, layer)
			new("UIStroke", { Color = color, Thickness = 1, Transparency = 0.6 }, t)
			local ox, oy = (c + 0.5 - COLS / 2) / COLS, (r + 0.5 - ROWS / 2) / ROWS
			task.delay(math.random() * 0.2, function()
				if t.Parent then
					local p = t.Position
					tween(t, 0.8, { Position = UDim2.fromOffset(p.X.Offset + ox * 380 + math.random(-30, 30), p.Y.Offset + oy * 240 + 260 + math.random(0, 120)), Rotation = math.random(-260, 260), BackgroundTransparency = 1, Size = UDim2.fromOffset(tw * 0.4, th * 0.4) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				end
			end)
		end
	end
	pcall(function()
		target.Visible = false
	end)
	task.wait(1.05)
	layer:Destroy()
end
CLOSERS.Custom = function(gui, target, o)
	local src = o.Media
	if src == nil or tostring(src) == "" then
		return CLOSERS.Normal(gui, target, o)
	end
	local shown = RebelUI.PlayCover(gui, src, {
		Time = o.MediaTime,
		OnCovered = function()
			pcall(function()
				target.Visible = false
			end)
		end,
	})
	if not shown then
		pcall(function()
			target.Visible = true
		end)
		CLOSERS.Normal(gui, target, o)
	end
end
-- the black hole: the world dims, an accretion disk (three counter-spinning rings) and an event horizon open over the panel,
-- sparks spiral in along three orbits, the panel is stretched thin ("spaghettified"), spun and swallowed, then the hole
-- collapses in a shockwave, flash and explosion.
CLOSERS.BlackHole = function(gui, target, o)
	local color = o.Color or Color3.fromRGB(255, 70, 80)
	local hot = color:Lerp(Color3.fromRGB(255, 220, 160), 0.55)
	local pos, w, h = centerOf(gui, target)
	local sc = scaleOf(target)
	local layer = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Active = false, ZIndex = 200 }, gui)
	local alive = true
	-- 1) the world dims
	local dim = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 200 }, layer)
	tween(dim, 0.6, { BackgroundTransparency = 0.45 })
	-- 2) soft aura
	local aura = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = UDim2.fromOffset(0, 0), BackgroundColor3 = color, BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 201 }, layer)
	new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, aura)
	tween(aura, 0.7, { Size = UDim2.fromOffset(230, 230) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	-- 3) accretion disk: three rings spinning at different speeds
	local rings = {}
	for i, d in ipairs({ { 170, 7, color, 14 }, { 128, 5, hot, -22 }, { 92, 3, Color3.new(1, 1, 1), 34 } }) do
		local r = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, ZIndex = 202 }, layer)
		new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, r)
		local st = new("UIStroke", { Color = d[3], Thickness = d[2] }, r)
		local g = new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, d[3]), ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, d[3]) }) }, st)
		rings[i] = { g = g, speed = d[4] }
		task.delay(0.08 * i, function()
			tween(r, 0.45, { Size = UDim2.fromOffset(d[1], d[1]) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end)
	end
	task.spawn(function()
		local a = 0
		while alive and layer.Parent do
			a += 1
			for _, r in ipairs(rings) do
				r.g.Rotation = (a * r.speed * 0.35) % 360
			end
			task.wait(0.03)
		end
	end)
	-- 4) the event horizon
	local hole = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = UDim2.fromOffset(0, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 203 }, layer)
	new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, hole)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.5, Transparency = 0.35 }, hole)
	tween(hole, 0.5, { Size = UDim2.fromOffset(78, 78) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	-- 5) sparks spiral in along three orbits that spin in opposite directions
	local size = 1000
	pcall(function()
		local s = gui.AbsoluteSize
		if s.X > 0 then
			size = math.max(s.X, s.Y) * 1.3
		end
	end)
	local spins = {}
	for k = 1, 3 do
		local spin = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1, ZIndex = 202 }, layer)
		spins[k] = spin
		for i = 1, 14 do
			local dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5 + (math.random() - 0.5) * (0.5 + k * 0.28), 0.5 + (math.random() - 0.5) * (0.5 + k * 0.28)), Size = UDim2.fromOffset(math.random(3, 8), math.random(3, 8)), BackgroundColor3 = (i % 3 == 0) and Color3.new(1, 1, 1) or ((i % 3 == 1) and color or hot), BorderSizePixel = 0, ZIndex = 202 }, spin)
			new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, dot)
			task.delay(0.25 + i * 0.02 + k * 0.05, function()
				if dot.Parent then
					tween(dot, 0.6 + math.random() * 0.45, { Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(1, 1), BackgroundTransparency = 0.7 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				end
			end)
		end
		tween(spin, 1.3, { Rotation = (k % 2 == 0 and 1 or -1) * (300 + k * 120) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	end
	task.wait(0.35)
	-- 6) the panel is stretched thin, spun and pulled in
	local darken = veil(target)
	tween(darken, 0.8, { BackgroundTransparency = 0.35 })
	pcall(function()
		tween(target, 0.85, { Rotation = 260 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		if centered(target) then
			tween(target, 0.85, { Position = pos, Size = UDim2.fromOffset(w * 0.14, h * 1.18) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		end
	end)
	tween(sc, 0.85, { Scale = 0.02 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	task.wait(0.85)
	pcall(function()
		target.Visible = false
	end)
	-- 7) the hole swells, then collapses in a shockwave
	tween(hole, 0.12, { Size = UDim2.fromOffset(130, 130) }, Enum.EasingStyle.Quad)
	task.wait(0.12)
	tween(hole, 0.2, { Size = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	tween(aura, 0.25, { Size = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	for _, rr in ipairs(layer:GetChildren()) do
		pcall(function()
			if rr.ZIndex == 202 and rr:FindFirstChildOfClass("UIStroke") then
				tween(rr, 0.2, { Size = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			end
		end)
	end
	local wave = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = pos, Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, ZIndex = 205 }, layer)
	new("UICorner", { CornerRadius = UDim.new(0.5, 0) }, wave)
	local wst = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 8 }, wave)
	tween(wave, 0.6, { Size = UDim2.fromOffset(size * 0.7, size * 0.7) }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	tween(wst, 0.6, { Transparency = 1, Thickness = 1 })
	local flash = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.3, BorderSizePixel = 0, ZIndex = 210 }, layer)
	tween(flash, 0.4, { BackgroundTransparency = 1 })
	tween(dim, 0.5, { BackgroundTransparency = 1 })
	pcall(RebelUI.Boom, layer, { Color = color, Count = 36, Origin = pos })
	task.wait(0.55)
	alive = false
	layer:Destroy()
end
-- UI.CloseEffect(gui, target, style, { Color, Media, MediaTime, Move }): plays one of RebelUI.CloseAnimations on `target`. Yields until it is over.
function RebelUI.CloseEffect(gui, target, style, o)
	o = o or {}
	style = style or "Normal"
	if style == "None" or o.ReduceMotion or not (gui and target and target.Parent) then
		return
	end
	local fn = CLOSERS[style] or CLOSERS.Normal
	local ok, err = pcall(fn, gui, target, o)
	if not ok then
		RebelUI._reportError("close animation " .. tostring(style), err)
	end
	pcall(function()
		target.Visible = false
	end)
end
-- old name, still works
function RebelUI.BlackHole(gui, target, o)
	return RebelUI.CloseEffect(gui, target, "BlackHole", o)
end

function Window:SetCloseAnimation(style, media)
	if style ~= nil and not table.find(RebelUI.CloseAnimations, style) then
		return self
	end
	if style ~= nil then
		self.CloseAnimation = style
	end
	if media ~= nil then
		self.CloseMedia = tostring(media) ~= "" and media or nil
	end
	RebelUI.Log("close animation:", self.CloseAnimation, self.CloseMedia)
	return self
end
function Window:SetBoomStyle(style, image)
	if style ~= nil and not table.find(RebelUI.BoomStyles, style) then
		return self
	end
	if style ~= nil then
		self.BoomStyle = style
	end
	if image ~= nil then
		self.BoomImage = tostring(image) ~= "" and image or nil
	end
	return self
end
-- UI.PreviewClose(win, style, media): plays a close animation on a small test card so you can see it (the real panel stays)
function RebelUI.PreviewClose(win, style, media)
	if not win or not win.Gui or win._previewing then
		return
	end
	win._previewing = true
	task.spawn(function()
		local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(240, 150), BackgroundColor3 = Color3.fromRGB(20, 12, 16), BorderSizePixel = 0, ZIndex = 120 }, win.Gui)
		corner(card, 16)
		new("UIStroke", { Color = win.Theme and win.Theme.Glow or Color3.fromRGB(255, 70, 80), Thickness = 2 }, card)
		local t = label(card, "Preview", 18, Color3.new(1, 1, 1), true)
		t.Size = UDim2.fromScale(1, 1)
		t.TextXAlignment = Enum.TextXAlignment.Center
		task.wait(0.5)
		RebelUI.CloseEffect(win.Gui, card, style or win.CloseAnimation or "BlackHole", { Color = win.Theme and win.Theme.Glow, Media = media or win.CloseMedia, MediaTime = 2, Move = true })
		card:Destroy()
		win._previewing = false
	end)
end

-- pickers you can drop into any tab (they are also in the Settings tab)
function Tab:ClosePicker(o)
	o = o or {}
	local win = self.Win
	if o.Section ~= false then
		self:Section(o.Title or "Close animation")
	end
	self:Cycle({ Name = "When I press X", Description = "How the panel disappears", Options = RebelUI.CloseAnimations, Default = win.CloseAnimation or "BlackHole", Flag = "__closeanim", Callback = function(v)
		win:SetCloseAnimation(v)
		if v == "Custom" and not win.CloseMedia then
			win:Notify({ Type = "info", Title = "Custom close", Text = "Paste a picture or video link in the box below." })
		end
	end })
	self:Input({ Name = "Custom picture or video", Description = "Covers the whole screen. A link, a file name or an asset id (.mp4 / .webm = video)", Placeholder = "https://...", Flag = "__closemedia", NoLog = true, Callback = function(v)
		win:SetCloseAnimation(nil, v)
		if tostring(v or "") ~= "" then
			win:SetCloseAnimation("Custom")
		end
	end })
	self:Button({ Name = "Preview the close animation", Description = "Plays it on a small test card", NoLog = true, Callback = function()
		RebelUI.PreviewClose(win)
	end })
end
function Tab:BoomPicker(o)
	o = o or {}
	local win = self.Win
	if o.Section ~= false then
		self:Section(o.Title or "Explosion")
	end
	self:Cycle({ Name = "Explosion style", Description = "The effect when something booms", Options = RebelUI.BoomStyles, Default = win.BoomStyle or RebelUI.BoomStyle, Flag = "__boomstyle", Callback = function(v)
		win:SetBoomStyle(v)
	end })
	self:Input({ Name = "Custom explosion picture", Description = "Used by the Custom style. A link, a file name or an asset id", Placeholder = "https://...", Flag = "__boomimage", NoLog = true, Callback = function(v)
		win:SetBoomStyle(nil, v)
		if tostring(v or "") ~= "" then
			win:SetBoomStyle("Custom")
		end
	end })
	self:Button({ Name = "Preview the explosion", NoLog = true, Callback = function()
		win:Boom({ Shake = false })
	end })
end

-- ---------- links: blue text, a line under it, a dark scan that sweeps across it, and a blue link icon on the left
RebelUI.LinkColor = Color3.fromRGB(88, 166, 255)
RebelUI._iconColor = RebelUI._iconColor or setmetatable({}, { __mode = "k" })
-- RebelUI._linkFx(label, { Url }): makes a TextLabel look like a link (blue, underlined, with the scan). Click copies the url.
function RebelUI._linkFx(lbl, o)
	o = o or {}
	lbl.TextColor3 = RebelUI.LinkColor
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	task.spawn(function()
		task.wait(0.1)
		if not lbl.Parent then
			return
		end
		local w = 0
		pcall(function()
			w = math.min(lbl.TextBounds.X, lbl.AbsoluteSize.X)
		end)
		if not w or w <= 0 then
			w = math.max(20, #tostring(lbl.Text) * (lbl.TextSize * 0.55))
		end
		local th = lbl.TextSize + 3
		local line = new("Frame", { Name = "LinkLine", Position = UDim2.fromOffset(0, th), Size = UDim2.fromOffset(w, 1), BackgroundColor3 = RebelUI.LinkColor, BorderSizePixel = 0, ZIndex = (lbl.ZIndex or 1) + 1 }, lbl)
		local host = new("Frame", { Name = "LinkScan", Position = UDim2.fromOffset(0, -1), Size = UDim2.fromOffset(w, th + 2), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = (lbl.ZIndex or 1) + 2 }, lbl)
		local function bar(width, transp)
			local b = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0, -20, 0, 0), Size = UDim2.new(0, width, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = transp, BorderSizePixel = 0, ZIndex = (lbl.ZIndex or 1) + 2 }, host)
			return b
		end
		local glowOuter, glowInner, core = bar(26, 0.9), bar(13, 0.78), bar(2, 0.1)
		if not o.NoScan then
			task.spawn(function()
				local dur = math.max(0.9, w / 110)
				while lbl.Parent and host.Parent do
					for _, b in ipairs({ glowOuter, glowInner, core }) do
						b.Position = UDim2.new(0, -20, 0, 0)
						tween(b, dur, { Position = UDim2.new(0, w + 20, 0, 0) }, Enum.EasingStyle.Sine)
					end
					task.wait(dur + 1.6)
				end
			end)
		end
		lbl.Active = true
	end)
	local hit = new("TextButton", { Name = "LinkHit", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = (lbl.ZIndex or 1) + 5 }, lbl)
	hit.Activated:Connect(function()
		local url = o.Url or lbl.Text
		local ok = type(setclipboard) == "function" and pcall(setclipboard, url)
		if o.OnClick then
			safe(o.OnClick, url, ok)
		end
	end)
	hit.MouseEnter:Connect(function()
		tween(lbl, 0.12, { TextColor3 = RebelUI.LinkColor:Lerp(Color3.new(1, 1, 1), 0.3) })
	end)
	hit.MouseLeave:Connect(function()
		tween(lbl, 0.15, { TextColor3 = RebelUI.LinkColor })
	end)
	return hit
end
-- turns every http(s) link inside a text into blue underlined rich text
function RebelUI._richLinks(text)
	text = tostring(text or "")
	if not text:find("https?://") then
		return text, false
	end
	local hex = string.format("#%02X%02X%02X", math.floor(RebelUI.LinkColor.R * 255 + 0.5), math.floor(RebelUI.LinkColor.G * 255 + 0.5), math.floor(RebelUI.LinkColor.B * 255 + 0.5))
	local out = text:gsub("(https?://[%w%-%._~:/%?#%[%]@!$&'%(%)%*%+,;=%%]+)", function(u)
		return '<font color="' .. hex .. '"><u>' .. u .. "</u></font>"
	end)
	return out, true
end

function Tab:Link(o)
	-- Url, Name (the text shown, default = the url), Description, Callback(url): a blue link row. Tap = copy.
	if type(o) == "string" then
		o = { Url = o }
	end
	o = o or {}
	local win = self.Win
	local hasDesc = o.Description ~= nil
	local row = self:_row(hasDesc and 44 or 36)
	local ico = new("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, Image = asset(RebelUI.Icons.link), ScaleType = Enum.ScaleType.Fit, ImageColor3 = RebelUI.LinkColor }, row)
	RebelUI._iconColor[ico] = RebelUI.LinkColor
	RebelUI._iconFix(ico, RebelUI.Icons.link)
	local txt = label(row, tostring(o.Name or o.Url or "link"), 12, RebelUI.LinkColor, true)
	txt.Position = UDim2.fromOffset(38, hasDesc and 6 or 9)
	txt.Size = UDim2.new(1, -52, 0, 16)
	local shown = txt.Text
	if hasDesc then
		local d = label(row, o.Description, 8, C.Dim, false)
		d.Position = UDim2.fromOffset(38, 28)
		d.Size = UDim2.new(1, -52, 0, 11)
	end
	local obj = { Url = o.Url }
	RebelUI._linkFx(txt, { Url = o.Url, OnClick = function(url, ok)
		txt.Text = ok and "Link copied" or "Can't copy"
		task.delay(1.1, function()
			if txt.Parent then
				txt.Text = shown
			end
		end)
		if o.Callback then
			safe(o.Callback, url)
		end
	end })
	function obj:Get()
		return obj.Url
	end
	function obj:Set(url)
		obj.Url = url
	end
	return register(self, o, obj, "Link")
end

-- ============================================================ groupbox, tabbox, accordion
-- local g = Tab:Groupbox("Combat")                 a titled card; g takes every element method (g:Toggle, g:Slider ...). g:SetTitle("x")
-- local tb = Tab:Tabbox({ "Aim", "Visuals" })      a card with tabs inside it; tb.Aim:Toggle({...})  tb[2]:Slider({...})  tb:Select("Visuals")
-- local a = Tab:Accordion({ Name = "More", Open = false })   a card that opens and closes; a:Open() a:Close() a:Flip() a:IsOpen()
local function makeCard(tab, title)
	local win = tab.Win
	local card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, LayoutOrder = tab:_next() }, tab.Page)
	corner(card, 10)
	win:_bind(card, "BackgroundColor3", "Item")
	local st = new("UIStroke", { Thickness = 1, Transparency = 0.5 }, card)
	win:_bind(st, "Color", "B1")
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, card)
	return card, st
end

function Tab:Groupbox(o)
	o = type(o) == "table" and o or { Name = o }
	local card = makeCard(self)
	local head = label(card, tostring(o.Name or "Group"), 12, C.Text, true)
	head.Size = UDim2.new(1, 0, 0, 18)
	head.LayoutOrder = 0
	self.Win:_bind(head, "TextColor3", "Glow")
	local body = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, BorderSizePixel = 0 }, card)
	local c = makeContainer(self, body)
	function c:SetTitle(t)
		head.Text = tostring(t)
	end
	function c:SetVisible(v)
		card.Visible = v ~= false
	end
	c.Card = card
	return c
end

function Tab:Tabbox(names, o)
	o = o or {}
	local win = self.Win
	local card = makeCard(self)
	local strip = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), LayoutOrder = 0, BorderSizePixel = 0 }, card)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, strip)
	local obj, btns, boxes, current = { Card = card }, {}, {}, nil
	local n = math.max(#(names or {}), 1)
	local function paint()
		for nm, b in pairs(btns) do
			local on = nm == current
			b.BackgroundColor3 = on and win.Theme.Accent or win.Theme.Inset
			b.TextColor3 = on and C.White or C.Dim
		end
	end
	for i, nm in ipairs(names or {}) do
		nm = tostring(nm)
		local b = new("TextButton", { Size = UDim2.new(1 / n, -4 * (n - 1) / n, 1, 0), AutoButtonColor = false, BorderSizePixel = 0, Text = nm, Font = Enum.Font.GothamBold, TextSize = 11, LayoutOrder = i }, strip)
		corner(b, 7)
		btns[nm] = b
		local holder = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Visible = false, BorderSizePixel = 0 }, card)
		local c = makeContainer(self, holder)
		c.Name = nm
		boxes[nm] = holder
		obj[nm] = c
		obj[i] = c
		b.MouseButton1Click:Connect(function()
			obj:Select(nm)
		end)
	end
	function obj:Select(nm)
		nm = tostring(nm)
		if not boxes[nm] then
			return
		end
		current = nm
		for k, h in pairs(boxes) do
			h.Visible = k == nm
		end
		paint()
	end
	function obj:SetVisible(v)
		card.Visible = v ~= false
	end
	win:_onTheme(paint)
	if names and names[1] then
		obj:Select(o.Default or names[1])
	end
	return obj
end

function Tab:Accordion(o)
	o = type(o) == "table" and o or { Name = o }
	local win = self.Win
	local card = makeCard(self)
	local head = new("TextButton", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = 0 }, card)
	local l = label(head, "", 12, C.Text, true)
	l.Size = UDim2.fromScale(1, 1)
	win:_bind(l, "TextColor3", "Glow")
	local body = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, BorderSizePixel = 0 }, card)
	local c = makeContainer(self, body)
	local open = o.Open ~= false
	local name = tostring(o.Name or "More")
	local function render()
		l.Text = (open and "v  " or ">  ") .. name
		body.Visible = open
	end
	function c:Open()
		open = true
		render()
	end
	function c:Close()
		open = false
		render()
	end
	function c:Flip()
		open = not open
		render()
	end
	function c:IsOpen()
		return open
	end
	function c:SetTitle(t)
		name = tostring(t)
		render()
	end
	function c:SetVisible(v)
		card.Visible = v ~= false
	end
	head.MouseButton1Click:Connect(function()
		c:Flip()
	end)
	c.Card = card
	render()
	return c
end

-- ============================================================ round 2: 30 more things
-- Tab elements:  Radio, CheckList, Swatches, Badge, Profile, Spacer, Quote, Counter, Meter, Compare, Banner, Marquee, Stopwatch, Clock,
--                Spoiler, TagInput, Pagination, Copy, Kbd, Tip
-- Window:        Announce, ShowChangelog, Tour, AskRating, Lock, SetAutoHide, GetFlag, SetFlag, Highlight, Rain
do
	local function T(self)
		return self.Win.Theme
	end
	local function rowOf(self, h, name)
		local row = self:_row(h)
		local l = label(row, name or "", 11, C.Text, true)
		l.Position = UDim2.new(0, 10, 0, 0)
		l.Size = UDim2.new(1, -20, 0, h > 40 and 22 or h)
		return row, l
	end

	function Tab:Radio(o)
		-- Name, Options = { "A", "B" }, Default, Flag, Callback(option): one choice out of a list, one per line
		o = o or {}
		local win, opts = self.Win, o.Options or {}
		local row, head = rowOf(self, 28 + #opts * 26, o.Name or "Choose")
		head.Size = UDim2.new(1, -20, 0, 24)
		local obj, dots, cur = {}, {}, nil
		local function paint()
			for nm, d in pairs(dots) do
				d.BackgroundColor3 = nm == cur and win.Theme.Accent or win.Theme.Inset
				d.Size = nm == cur and UDim2.fromOffset(14, 14) or UDim2.fromOffset(12, 12)
			end
		end
		function obj:Set(v, silent)
			if dots[tostring(v)] == nil then
				return
			end
			cur = tostring(v)
			paint()
			if not silent then
				win:_playClick()
				safe(o.Callback, cur)
			end
		end
		function obj:Get()
			return cur
		end
		for i, v in ipairs(opts) do
			local nm = tostring(v)
			local b = new("TextButton", { Position = UDim2.new(0, 10, 0, 24 + (i - 1) * 26), Size = UDim2.new(1, -20, 0, 24), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, row)
			local d = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(12, 12), BorderSizePixel = 0 }, b)
			corner(d, 7)
			dots[nm] = d
			local l = label(b, nm, 11, C.Dim, false)
			l.Position = UDim2.new(0, 22, 0, 0)
			l.Size = UDim2.new(1, -22, 1, 0)
			b.MouseButton1Click:Connect(function()
				obj:Set(nm)
			end)
		end
		win:_onTheme(paint)
		cur = o.Default ~= nil and tostring(o.Default) or nil
		paint()
		if cur then
			safe(o.Callback, cur)
		end
		return register(self, o, obj, "Radio")
	end

	function Tab:CheckList(o)
		-- Name, Items = { "A", "B" }, Default = { A = true }, Flag, Callback(set): several checkboxes in one card. obj:Get() = { A = true, B = false }
		o = o or {}
		local win, items = self.Win, o.Items or {}
		local row, head = rowOf(self, 28 + #items * 26, o.Name or "Pick")
		head.Size = UDim2.new(1, -20, 0, 24)
		local obj, boxes, state = {}, {}, {}
		local function paint()
			for nm, b in pairs(boxes) do
				b.BackgroundColor3 = state[nm] and win.Theme.Accent or win.Theme.Inset
				b.Text = state[nm] and "x" or ""
			end
		end
		function obj:Set(nm, v, silent)
			nm = tostring(nm)
			if boxes[nm] == nil then
				return
			end
			state[nm] = v and true or false
			paint()
			if not silent then
				win:_playClick()
				safe(o.Callback, obj:Get())
			end
		end
		function obj:Get()
			local t = {}
			for k, v in pairs(state) do
				t[k] = v
			end
			return t
		end
		for i, v in ipairs(items) do
			local nm = tostring(v)
			state[nm] = o.Default and o.Default[nm] == true or false
			local btn = new("TextButton", { Position = UDim2.new(0, 10, 0, 24 + (i - 1) * 26), Size = UDim2.new(1, -20, 0, 24), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, row)
			local b = new("TextLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(16, 16), BorderSizePixel = 0, Font = Enum.Font.GothamBlack, TextSize = 11, TextColor3 = C.White }, btn)
			corner(b, 4)
			boxes[nm] = b
			local l = label(btn, nm, 11, C.Dim, false)
			l.Position = UDim2.new(0, 24, 0, 0)
			l.Size = UDim2.new(1, -24, 1, 0)
			btn.MouseButton1Click:Connect(function()
				obj:Set(nm, not state[nm])
			end)
		end
		win:_onTheme(paint)
		paint()
		return register(self, o, obj, "CheckList")
	end

	function Tab:Swatches(o)
		-- Name, Colors = { Color3, ... }, Default (index), Flag, Callback(color, index): tap a color circle
		o = o or {}
		local win, cols = self.Win, o.Colors or { Color3.fromRGB(255, 70, 80), Color3.fromRGB(80, 160, 255), Color3.fromRGB(80, 220, 120), Color3.fromRGB(255, 200, 70), Color3.fromRGB(180, 100, 255) }
		local row, head = rowOf(self, 62, o.Name or "Color")
		head.Size = UDim2.new(1, -20, 0, 22)
		local obj, ring, idx = {}, {}, nil
		function obj:Set(i, silent)
			if not cols[i] then
				return
			end
			idx = i
			for k, s in pairs(ring) do
				s.Thickness = k == i and 2.5 or 0
			end
			if not silent then
				win:_playClick()
				safe(o.Callback, cols[i], i)
			end
		end
		function obj:Get()
			return cols[idx], idx
		end
		for i, c in ipairs(cols) do
			local b = new("TextButton", { Position = UDim2.new(0, 10 + (i - 1) * 32, 0, 28), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = c, Text = "", AutoButtonColor = false, BorderSizePixel = 0 }, row)
			corner(b, 13)
			ring[i] = new("UIStroke", { Color = C.White, Thickness = 0 }, b)
			b.MouseButton1Click:Connect(function()
				obj:Set(i)
			end)
		end
		if o.Default then
			obj:Set(o.Default, o.Default == nil)
		end
		return register(self, o, obj, "Swatches")
	end

	function Tab:Badge(o)
		-- Text, Color (Color3 or "Green"/"Yellow"/"Bad"), obj:Set("text"): a small colored pill
		o = type(o) == "table" and o or { Text = o }
		local win = self.Win
		local col = o.Color
		if type(col) == "string" then
			col = C[col] or C.Green
		end
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		local pill = new("TextLabel", { Size = UDim2.fromOffset(20, 22), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = col or win.Theme.Accent, BorderSizePixel = 0, Text = tostring(o.Text or "NEW"), TextColor3 = C.White, Font = Enum.Font.GothamBlack, TextSize = 10 }, row)
		corner(pill, 11)
		new("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, pill)
		local obj = {}
		function obj:Set(t)
			pill.Text = tostring(t)
		end
		function obj:SetColor(c)
			pill.BackgroundColor3 = c
		end
		return register(self, o, obj, "Badge")
	end

	function Tab:Profile(o)
		-- Name, Subtitle, UserId: a card with the player's headshot (defaults to you)
		o = o or {}
		local win = self.Win
		local lp = game:GetService("Players").LocalPlayer
		local row = self:_row(60)
		local img = new("ImageLabel", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(42, 42), BackgroundColor3 = win.Theme.Inset, BorderSizePixel = 0, Image = "" }, row)
		corner(img, 21)
		local n = label(row, o.Name or (lp and lp.DisplayName) or "Player", 13, C.Text, true)
		n.Position, n.Size = UDim2.new(0, 62, 0, 10), UDim2.new(1, -72, 0, 20)
		local s = label(row, o.Subtitle or (lp and ("@" .. lp.Name)) or "", 10, C.Dim, false)
		s.Position, s.Size = UDim2.new(0, 62, 0, 31), UDim2.new(1, -72, 0, 16)
		task.spawn(function()
			pcall(function()
				local id = o.UserId or (lp and lp.UserId)
				if id then
					img.Image = game:GetService("Players"):GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end
			end)
		end)
		local obj = {}
		function obj:SetName(t)
			n.Text = tostring(t)
		end
		function obj:SetSubtitle(t)
			s.Text = tostring(t)
		end
		return register(self, o, obj, "Profile")
	end

	function Tab:Spacer(h)
		local f = new("Frame", { Size = UDim2.new(1, 0, 0, tonumber(h) or 10), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		return register(self, {}, { Frame = f }, "Spacer")
	end

	function Tab:Quote(o)
		-- Text, By: an italic-style quote with an accent bar
		o = type(o) == "table" and o or { Text = o }
		local win = self.Win
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		local bar = new("Frame", { Size = UDim2.new(0, 3, 1, 0), BorderSizePixel = 0 }, row)
		corner(bar, 2)
		win:_bind(bar, "BackgroundColor3", "Accent")
		local t = label(row, tostring(o.Text or ""), 11, C.Text, false)
		t.Position, t.Size = UDim2.new(0, 12, 0, 0), UDim2.new(1, -12, 0, 0)
		t.AutomaticSize, t.TextWrapped, t.TextTruncate = Enum.AutomaticSize.Y, true, Enum.TextTruncate.None
		if o.By then
			t.Text = t.Text .. "\n- " .. tostring(o.By)
		end
		local obj = {}
		function obj:Set(x)
			t.Text = tostring(x)
		end
		return register(self, o, obj, "Quote")
	end

	function Tab:Counter(o)
		-- Name, Value, Prefix, Suffix, Decimals: a big number that counts up smoothly. obj:Set(n) obj:Add(n) obj:Get()
		o = o or {}
		local win = self.Win
		local row = self:_row(44)
		local nm = label(row, o.Name or "Counter", 11, C.Dim, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.5, 0, 1, 0)
		local val = label(row, "", 18, C.Text, true)
		val.Font, val.TextXAlignment = Enum.Font.GothamBlack, Enum.TextXAlignment.Right
		val.Position, val.Size = UDim2.new(0.4, 0, 0, 0), UDim2.new(0.6, -10, 1, 0)
		win:_bind(val, "TextColor3", "Glow")
		local obj, shown, target, gen = {}, tonumber(o.Value) or 0, tonumber(o.Value) or 0, 0
		local dec = o.Decimals or 0
		local function fmt(v)
			local s = string.format("%." .. dec .. "f", v)
			local int, rest = s:match("^(-?%d+)(.*)$")
			int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""):gsub("^%-,", "-")
			return (o.Prefix or "") .. int .. rest .. (o.Suffix or "")
		end
		val.Text = fmt(shown)
		function obj:Set(v)
			target = tonumber(v) or 0
			gen += 1
			local my, from, t0 = gen, shown, os.clock()
			if win.ReduceMotion then
				shown = target
				val.Text = fmt(shown)
				return
			end
			task.spawn(function()
				while gen == my do
					local a = math.clamp((os.clock() - t0) / 0.6, 0, 1)
					shown = from + (target - from) * (1 - (1 - a) ^ 3)
					val.Text = fmt(shown)
					if a >= 1 then
						shown = target
						break
					end
					task.wait()
				end
			end)
		end
		function obj:Add(v)
			obj:Set(target + (tonumber(v) or 1))
		end
		function obj:Get()
			return target
		end
		return register(self, o, obj, "Counter")
	end

	function Tab:Meter(o)
		-- Name, Segments (default 10), Value (0 to Segments), Colors = low, high: a segmented bar like a battery. obj:Set(n) obj:Get()
		o = o or {}
		local win = self.Win
		local n = math.clamp(o.Segments or 10, 2, 30)
		local row = self:_row(48)
		local nm = label(row, o.Name or "Meter", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 2), UDim2.new(1, -20, 0, 20)
		local segs = {}
		local holder = new("Frame", { Position = UDim2.new(0, 10, 0, 26), Size = UDim2.new(1, -20, 0, 14), BackgroundTransparency = 1 }, row)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2) }, holder)
		for i = 1, n do
			local s = new("Frame", { Size = UDim2.new(1 / n, -2, 1, 0), BorderSizePixel = 0 }, holder)
			corner(s, 3)
			segs[i] = s
		end
		local lo, hi = (o.Colors and o.Colors[1]) or C.Bad, (o.Colors and o.Colors[2]) or C.Green
		local obj = { Value = 0 }
		function obj:Set(v)
			obj.Value = math.clamp(tonumber(v) or 0, 0, n)
			for i, s in ipairs(segs) do
				tween(s, 0.2, { BackgroundColor3 = i <= obj.Value and lo:Lerp(hi, (i - 1) / math.max(n - 1, 1)) or win.Theme.Inset })
			end
		end
		function obj:Get()
			return obj.Value
		end
		obj:Set(o.Value or 0)
		return register(self, o, obj, "Meter")
	end

	function Tab:Compare(o)
		-- Name, A = { Name = "You", Value = 30 }, B = { Name = "Enemy", Value = 70 }: a tug-of-war bar. obj:Set(a, b)
		o = o or {}
		local win = self.Win
		local row = self:_row(50)
		local nm = label(row, o.Name or "Compare", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 2), UDim2.new(1, -20, 0, 18)
		local bg = new("Frame", { Position = UDim2.new(0, 10, 0, 24), Size = UDim2.new(1, -20, 0, 12), BackgroundColor3 = C.Bad, BorderSizePixel = 0 }, row)
		corner(bg, 6)
		local fill = new("Frame", { Size = UDim2.new(0.5, 0, 1, 0), BorderSizePixel = 0 }, bg)
		corner(fill, 6)
		win:_bind(fill, "BackgroundColor3", "Accent")
		local la = label(row, "", 9, C.Dim, false)
		la.Position, la.Size = UDim2.new(0, 10, 0, 37), UDim2.new(0.5, 0, 0, 12)
		local lb = label(row, "", 9, C.Dim, false)
		lb.TextXAlignment = Enum.TextXAlignment.Right
		lb.Position, lb.Size = UDim2.new(0.5, 0, 0, 37), UDim2.new(0.5, -10, 0, 12)
		local obj = {}
		function obj:Set(a, b)
			a, b = math.max(tonumber(a) or 0, 0), math.max(tonumber(b) or 0, 0)
			tween(fill, 0.25, { Size = UDim2.new(a + b > 0 and a / (a + b) or 0.5, 0, 1, 0) })
			la.Text = ((o.A and o.A.Name) or "A") .. ": " .. tostring(a)
			lb.Text = ((o.B and o.B.Name) or "B") .. ": " .. tostring(b)
		end
		obj:Set(o.A and o.A.Value or 1, o.B and o.B.Value or 1)
		return register(self, o, obj, "Compare")
	end

	function Tab:Banner(o)
		-- Title, Text, Image, Color: a wide colored card for news
		o = o or {}
		local win = self.Win
		local row = self:_row(70)
		row.BackgroundColor3 = o.Color or win.Theme.Dark
		pcall(function()
			win:_bind(row, "BackgroundColor3", o.Color and "Item" or "Dark")
			if o.Color then
				row.BackgroundColor3 = o.Color
			end
		end)
		local pad = 12
		if o.Image then
			local im = new("ImageLabel", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(46, 46), BackgroundTransparency = 1, Image = asset(o.Image), ScaleType = Enum.ScaleType.Fit }, row)
			corner(im, 8)
			pad = 66
		end
		local t = label(row, o.Title or "News", 14, C.White, true)
		t.Font, t.Position, t.Size = Enum.Font.GothamBlack, UDim2.new(0, pad, 0, 8), UDim2.new(1, -pad - 10, 0, 22)
		local d = label(row, o.Text or "", 10, C.Text, false)
		d.TextWrapped, d.TextTruncate = true, Enum.TextTruncate.None
		d.TextYAlignment = Enum.TextYAlignment.Top
		d.Position, d.Size = UDim2.new(0, pad, 0, 32), UDim2.new(1, -pad - 10, 1, -36)
		local obj = {}
		function obj:Set(title, text)
			t.Text = tostring(title or t.Text)
			d.Text = tostring(text or d.Text)
		end
		return register(self, o, obj, "Banner")
	end

	function Tab:Marquee(o)
		-- Text, Speed (pixels per second): scrolling text like a news ticker
		o = type(o) == "table" and o or { Text = o }
		local win = self.Win
		local row = self:_row(26)
		row.ClipsDescendants = true
		local t = new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(10, 26), AutomaticSize = Enum.AutomaticSize.X, Text = tostring(o.Text or ""), TextSize = 11, Font = Enum.Font.GothamBold, TextColor3 = C.Text }, row)
		win:_bind(t, "TextColor3", "Glow")
		local obj, alive = {}, true
		function obj:Set(x)
			t.Text = tostring(x)
		end
		function obj:Destroy()
			alive = false
		end
		task.spawn(function()
			local x = row.AbsoluteSize.X
			while alive and t.Parent do
				if not win.ReduceMotion then
					x -= (o.Speed or 40) / 30
					if x < -t.AbsoluteSize.X then
						x = math.max(row.AbsoluteSize.X, 100)
					end
				else
					x = 10
				end
				t.Position = UDim2.fromOffset(x, 0)
				task.wait(1 / 30)
			end
		end)
		return register(self, o, obj, "Marquee")
	end

	function Tab:Stopwatch(o)
		-- Name: Start / Stop / Reset, with laps. obj:Get() = seconds
		o = o or {}
		local win = self.Win
		local row = self:_row(44)
		local nm = label(row, o.Name or "Stopwatch", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.35, 0, 1, 0)
		local tx = label(row, "00:00.0", 15, C.Text, true)
		tx.Font, tx.Position, tx.Size = Enum.Font.GothamBlack, UDim2.new(0.33, 0, 0, 0), UDim2.new(0.3, 0, 1, 0)
		win:_bind(tx, "TextColor3", "Glow")
		local b1 = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(58, 26), BorderSizePixel = 0, Text = "Start", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.White, AutoButtonColor = false }, row)
		corner(b1, 8)
		win:_bind(b1, "BackgroundColor3", "Accent")
		local obj, running, acc, t0 = {}, false, 0, 0
		local function show(v)
			tx.Text = string.format("%02d:%04.1f", math.floor(v / 60), v % 60)
		end
		function obj:Get()
			return running and acc + (os.clock() - t0) or acc
		end
		function obj:Start()
			if not running then
				running, t0 = true, os.clock()
				b1.Text = "Stop"
				task.spawn(function()
					while running and tx.Parent do
						show(obj:Get())
						task.wait(0.1)
					end
				end)
			end
		end
		function obj:Stop()
			if running then
				acc = acc + (os.clock() - t0)
				running = false
				b1.Text = "Reset"
				show(acc)
			end
		end
		function obj:Reset()
			running, acc = false, 0
			b1.Text = "Start"
			show(0)
		end
		b1.MouseButton1Click:Connect(function()
			if running then
				obj:Stop()
			elseif acc > 0 then
				obj:Reset()
			else
				obj:Start()
			end
		end)
		return register(self, o, obj, "Stopwatch")
	end

	function Tab:Clock(o)
		-- Name, Format = "%H:%M:%S" (os.date format): a live clock
		o = o or {}
		local win = self.Win
		local row = self:_row(40)
		local nm = label(row, o.Name or "Time", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.4, 0, 1, 0)
		local tx = label(row, "", 15, C.Text, true)
		tx.Font, tx.TextXAlignment = Enum.Font.GothamBlack, Enum.TextXAlignment.Right
		tx.Position, tx.Size = UDim2.new(0.4, 0, 0, 0), UDim2.new(0.6, -10, 1, 0)
		win:_bind(tx, "TextColor3", "Glow")
		local fmt = o.Format or "%H:%M:%S"
		task.spawn(function()
			while tx.Parent do
				tx.Text = os.date(fmt)
				task.wait(1)
			end
		end)
		local obj = {}
		function obj:SetFormat(f)
			fmt = f
		end
		return register(self, o, obj, "Clock")
	end

	function Tab:Spoiler(o)
		-- Name, Text: the text is hidden until you tap it
		o = o or {}
		local win = self.Win
		local row = self:_row(38)
		local nm = label(row, o.Name or "Secret", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.4, 0, 1, 0)
		local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0.55, 0, 0, 26), BorderSizePixel = 0, Text = "tap to reveal", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = C.Dim, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd }, row)
		corner(b, 8)
		win:_bind(b, "BackgroundColor3", "Inset")
		local shown = false
		local obj = {}
		function obj:Reveal(v)
			shown = v ~= false
			b.Text = shown and tostring(o.Text or "") or "tap to reveal"
			b.TextColor3 = shown and C.Text or C.Dim
		end
		function obj:SetText(t)
			o.Text = t
			obj:Reveal(shown)
		end
		b.MouseButton1Click:Connect(function()
			obj:Reveal(not shown)
		end)
		return register(self, o, obj, "Spoiler")
	end

	function Tab:TagInput(o)
		-- Name, Placeholder, Max, Callback(list): type a word, press Enter, it becomes a tag. Tap a tag to remove it
		o = o or {}
		local win = self.Win
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		corner(row, 8)
		win:_bind(row, "BackgroundColor3", "Item")
		new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, row)
		new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, row)
		local nm = label(row, o.Name or "Tags", 11, C.Text, true)
		nm.Size, nm.LayoutOrder = UDim2.new(1, 0, 0, 16), 0
		local box = new("TextBox", { Size = UDim2.new(1, 0, 0, 28), BorderSizePixel = 0, Text = "", PlaceholderText = o.Placeholder or "type and press Enter", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.Text, PlaceholderColor3 = C.Dim, ClearTextOnFocus = false, LayoutOrder = 1 }, row)
		corner(box, 7)
		win:_bind(box, "BackgroundColor3", "Inset")
		local wrap = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 2 }, row)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Wraps = true, Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)
		local obj, list = {}, {}
		local function rebuild()
			for _, c in ipairs(wrap:GetChildren()) do
				if c:IsA("GuiObject") then
					c:Destroy()
				end
			end
			for i, t in ipairs(list) do
				local b = new("TextButton", { Size = UDim2.fromOffset(20, 22), AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, Text = t .. "  x", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = C.White, AutoButtonColor = false, LayoutOrder = i }, wrap)
				corner(b, 11)
				win:_bind(b, "BackgroundColor3", "Accent")
				new("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9) }, b)
				b.MouseButton1Click:Connect(function()
					obj:Remove(t)
				end)
			end
		end
		function obj:Add(t)
			t = tostring(t or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if t == "" or table.find(list, t) or #list >= (o.Max or 20) then
				return false
			end
			table.insert(list, t)
			rebuild()
			safe(o.Callback, obj:Get())
			return true
		end
		function obj:Remove(t)
			local i = table.find(list, t)
			if i then
				table.remove(list, i)
				rebuild()
				safe(o.Callback, obj:Get())
			end
		end
		function obj:Get()
			return table.clone(list)
		end
		function obj:Clear()
			list = {}
			rebuild()
			safe(o.Callback, {})
		end
		box.FocusLost:Connect(function(enter)
			if enter and obj:Add(box.Text) then
				box.Text = ""
			end
		end)
		return register(self, o, obj, "TagInput")
	end

	function Tab:Pagination(o)
		-- Name, Pages, Default, Callback(page): < 1 / 5 > buttons
		o = o or {}
		local win = self.Win
		local row = self:_row(38)
		local nm = label(row, o.Name or "Page", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.4, 0, 1, 0)
		local pages = math.max(o.Pages or 1, 1)
		local obj = { Page = math.clamp(o.Default or 1, 1, pages) }
		local mid = label(row, "", 12, C.Text, true)
		mid.TextXAlignment = Enum.TextXAlignment.Center
		mid.AnchorPoint, mid.Position, mid.Size = Vector2.new(1, 0), UDim2.new(1, -44, 0, 0), UDim2.new(0, 60, 1, 0)
		local function btn(txt, x)
			local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(28, 26), BorderSizePixel = 0, Text = txt, Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = C.White, AutoButtonColor = false }, row)
			corner(b, 7)
			win:_bind(b, "BackgroundColor3", "Accent")
			return b
		end
		local prev, nxt = btn("<", -108), btn(">", -10)
		local function render()
			mid.Text = obj.Page .. " / " .. pages
		end
		function obj:Set(p, silent)
			obj.Page = math.clamp(math.floor(tonumber(p) or 1), 1, pages)
			render()
			if not silent then
				win:_playClick()
				safe(o.Callback, obj.Page)
			end
		end
		function obj:Get()
			return obj.Page
		end
		prev.MouseButton1Click:Connect(function()
			obj:Set(obj.Page - 1)
		end)
		nxt.MouseButton1Click:Connect(function()
			obj:Set(obj.Page + 1)
		end)
		render()
		return register(self, o, obj, "Pagination")
	end

	function Tab:Copy(o)
		-- Name, Text: a row that copies the text when tapped (a link, a code, an id)
		o = o or {}
		local win = self.Win
		local row = self:_row(40)
		local nm = label(row, o.Name or "Copy", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.35, 0, 1, 0)
		local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0.6, -10, 0, 26), BorderSizePixel = 0, Text = tostring(o.Text or ""), Font = Enum.Font.Code, TextSize = 10, TextColor3 = C.Text, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd }, row)
		corner(b, 7)
		win:_bind(b, "BackgroundColor3", "Inset")
		local obj = {}
		function obj:Copy()
			local ok = false
			if type(setclipboard) == "function" then
				ok = pcall(setclipboard, tostring(o.Text or ""))
			end
			b.Text = ok and "copied!" or "no clipboard"
			task.delay(1.2, function()
				if b.Parent then
					b.Text = tostring(o.Text or "")
				end
			end)
			if o.Notify ~= false then
				win:Notify({ Title = "Copied", Text = tostring(o.Name or "Text"), Type = ok and "success" or "warn", Duration = 2 })
			end
			return ok
		end
		function obj:SetText(t)
			o.Text = t
			b.Text = tostring(t)
		end
		b.MouseButton1Click:Connect(function()
			obj:Copy()
		end)
		return register(self, o, obj, "Copy")
	end

	function Tab:Kbd(o)
		-- Name, Keys = { "Ctrl", "K" }: shows key caps like a shortcut hint
		o = o or {}
		local win = self.Win
		local row = self:_row(36)
		local nm = label(row, o.Name or "Shortcut", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.5, 0, 1, 0)
		local holder = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1 }, row)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center }, holder)
		for i, k in ipairs(o.Keys or {}) do
			local c = new("TextLabel", { Size = UDim2.fromOffset(22, 22), AutomaticSize = Enum.AutomaticSize.X, BorderSizePixel = 0, Text = tostring(k), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = C.Text, LayoutOrder = i }, holder)
			corner(c, 5)
			win:_bind(c, "BackgroundColor3", "Inset")
			new("UIStroke", { Color = C.Dim, Thickness = 1, Transparency = 0.6 }, c)
			new("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7) }, c)
		end
		return register(self, o, {}, "Kbd")
	end

	function Tab:Tip(o)
		-- Text, Type = "info" | "success" | "warn": a small hint line with a colored dot
		o = type(o) == "table" and o or { Text = o }
		local win = self.Win
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		local col = o.Type == "success" and C.Green or o.Type == "warn" and C.Yellow or nil
		local dot = new("Frame", { Position = UDim2.new(0, 2, 0, 5), Size = UDim2.fromOffset(7, 7), BorderSizePixel = 0, BackgroundColor3 = col or win.Theme.Accent }, row)
		corner(dot, 4)
		if not col then
			win:_bind(dot, "BackgroundColor3", "Accent")
		end
		local t = label(row, tostring(o.Text or ""), 10, C.Dim, false)
		t.Position, t.Size = UDim2.new(0, 16, 0, 0), UDim2.new(1, -16, 0, 0)
		t.AutomaticSize, t.TextWrapped, t.TextTruncate = Enum.AutomaticSize.Y, true, Enum.TextTruncate.None
		local obj = {}
		function obj:Set(x)
			t.Text = tostring(x)
		end
		return register(self, o, obj, "Tip")
	end

	-- ---------------------------------------------------------------- window-level
	function Window:GetFlag(name)
		local f = self.Flags[name]
		if f and f.Get then
			return f:Get()
		end
	end

	function Window:SetFlag(name, ...)
		local f = self.Flags[name]
		if f and f.Set then
			f:Set(...)
			return true
		end
		return false
	end

	function Window:Announce(o)
		-- Text, Type = "info" | "success" | "warn" | "error", Duration (seconds, default 6): a banner that slides down from the top. Tap to close
		if type(o) == "string" then
			o = { Text = o }
		end
		o = o or {}
		local col = o.Type == "success" and C.Green or o.Type == "warn" and C.Yellow or o.Type == "error" and C.Bad or self.Theme.Accent
		if self._announce and self._announce.Parent then
			self._announce:Destroy()
		end
		local b = new("TextButton", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -60), Size = UDim2.new(0.8, 0, 0, 36), BackgroundColor3 = col, Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 80 }, self.Gui)
		corner(b, 10)
		b.Size = UDim2.new(0, 360, 0, 36)
		local l = label(b, tostring(o.Text or ""), 12, C.White, true)
		l.TextXAlignment, l.Size, l.Position, l.ZIndex = Enum.TextXAlignment.Center, UDim2.new(1, -16, 1, 0), UDim2.fromOffset(8, 0), 81
		self._announce = b
		tween(b, 0.4, { Position = UDim2.new(0.5, 0, 0, 12) }, Enum.EasingStyle.Back)
		local gone = false
		local function close()
			if gone then
				return
			end
			gone = true
			tween(b, 0.3, { Position = UDim2.new(0.5, 0, 0, -60) })
			task.delay(0.35, function()
				b:Destroy()
			end)
		end
		b.MouseButton1Click:Connect(close)
		task.delay(o.Duration or 6, close)
		return { Close = close }
	end

	function Window:ShowChangelog(o)
		-- Version, Items = { "Added X", "Fixed Y" }, Title: a pop-up of what is new. Add Once = true to show it only the first time for this Version
		o = o or {}
		local file = "RebelUI_seen_" .. tostring(self.Title or "win"):gsub("%W", "") .. ".txt"
		if o.Once and o.Version then
			local ok, seen = pcall(function()
				return type(isfile) == "function" and isfile(file) and readfile(file)
			end)
			if ok and seen == tostring(o.Version) then
				return false
			end
			pcall(function()
				if type(writefile) == "function" then
					writefile(file, tostring(o.Version))
				end
			end)
		end
		local lines = {}
		for _, it in ipairs(o.Items or {}) do
			lines[#lines + 1] = "- " .. tostring(it)
		end
		self:Dialog({ Title = o.Title or ("What is new" .. (o.Version and (" in " .. o.Version) or "")), Text = table.concat(lines, "\n"), Buttons = { { Name = "Nice" } } })
		return true
	end

	function Window:Tour(steps, o)
		-- steps = { { Title = "Welcome", Text = "..." }, ... }: a guided intro, one pop-up after another (Next / Skip)
		o = o or {}
		local win, i = self, 0
		local function nextStep()
			i += 1
			local s = steps[i]
			if not s then
				safe(o.Done)
				return
			end
			local last = i == #steps
			win:Dialog({
				Title = (s.Title or "Tip") .. "  (" .. i .. "/" .. #steps .. ")",
				Text = s.Text,
				Buttons = {
					{ Name = last and "Done" or "Next", Callback = function()
						if s.Highlight then
							pcall(function() win:Highlight(s.Highlight) end)
						end
						task.delay(0.35, nextStep)
					end },
					not last and { Name = "Skip", Callback = function()
						i = #steps
						safe(o.Done)
					end } or nil,
				},
			})
		end
		nextStep()
	end

	function Window:AskRating(o)
		-- Title, Text, Callback(1 to 3): "Love it / It is ok / Needs work"
		o = o or {}
		self:Dialog({
			Title = o.Title or "How is it?",
			Text = o.Text or "Tell us what you think.",
			Buttons = {
				{ Name = "Love it", Callback = function() safe(o.Callback, 3) end },
				{ Name = "It is ok", Callback = function() safe(o.Callback, 2) end },
				{ Name = "Needs work", Callback = function() safe(o.Callback, 1) end },
			},
		})
	end

	function Window:Lock(o)
		-- Pin = "1234", Title, OnUnlock(): a lock screen over the panel. Type the pin to open it. obj:Unlock() opens it from code
		o = o or {}
		local pin = tostring(o.Pin or "0000")
		local t = self.Theme
		local back = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 90, Active = true }, self.Gui)
		local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(240, 120), BackgroundColor3 = t.BG0, BorderSizePixel = 0, ZIndex = 91 }, back)
		corner(card, 12)
		new("UIStroke", { Color = t.Glow, Thickness = 1.5 }, card)
		local h = label(card, o.Title or "Locked", 14, t.Glow, true)
		h.Font, h.Position, h.Size, h.ZIndex = Enum.Font.GothamBlack, UDim2.fromOffset(14, 10), UDim2.new(1, -28, 0, 20), 92
		local box = new("TextBox", { Position = UDim2.fromOffset(14, 40), Size = UDim2.new(1, -28, 0, 30), BackgroundColor3 = t.Inset, BorderSizePixel = 0, Text = "", PlaceholderText = "enter pin", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.Text, PlaceholderColor3 = C.Dim, ClearTextOnFocus = true, ZIndex = 92 }, card)
		corner(box, 8)
		local msg = label(card, "", 10, C.Bad, false)
		msg.Position, msg.Size, msg.ZIndex = UDim2.fromOffset(14, 78), UDim2.new(1, -28, 0, 16), 92
		local obj, done = {}, false
		function obj:Unlock()
			if done then
				return
			end
			done = true
			tween(back, 0.3, { BackgroundTransparency = 1 })
			task.delay(0.35, function()
				back:Destroy()
			end)
			safe(o.OnUnlock)
		end
		box.FocusLost:Connect(function()
			if box.Text == pin then
				obj:Unlock()
			else
				msg.Text = "wrong pin"
				box.Text = ""
			end
		end)
		return obj
	end

	function Window:SetAutoHide(seconds)
		-- hides the panel after this many seconds without touching it (nil or 0 turns it off). The open key or button brings it back
		self._autoHideGen = (self._autoHideGen or 0) + 1
		local my, win = self._autoHideGen, self
		if not seconds or seconds <= 0 then
			return
		end
		local last = os.clock()
		local uis = game:GetService("UserInputService")
		pcall(function()
			uis.InputBegan:Connect(function()
				last = os.clock()
			end)
			uis.InputChanged:Connect(function()
				last = os.clock()
			end)
		end)
		task.spawn(function()
			while win._autoHideGen == my and win.Gui and win.Gui.Parent do
				if win.Open ~= false and os.clock() - last >= seconds then
					pcall(function() win:Toggle(false) end)
					last = os.clock()
				end
				task.wait(1)
			end
		end)
	end

	function Window:Highlight(target, seconds)
		-- flashes an outline around an element (pass the element you got from Tab:Toggle etc.)
		local row = type(target) == "table" and target.Row or target
		if not row or not row.Parent then
			return false
		end
		local st = new("UIStroke", { Color = self.Theme.Glow, Thickness = 3, Transparency = 0 }, row)
		local n = math.max(math.floor((seconds or 2) / 0.3), 2)
		task.spawn(function()
			for i = 1, n do
				tween(st, 0.15, { Transparency = i % 2 == 0 and 0 or 0.8 })
				task.wait(0.3)
			end
			st:Destroy()
		end)
		return true
	end

	function Window:Rain(o)
		-- Image (asset id; default a star), Count (default 30), Time (seconds): things fall from the top of the screen
		o = o or {}
		if self.ReduceMotion then
			return
		end
		local gui = self.Gui
		local n = math.clamp(o.Count or 30, 1, 80)
		local img = o.Image or RebelUI.Icons.star
		for i = 1, n do
			task.delay(math.random() * (o.Time or 2), function()
				if not gui.Parent then
					return
				end
				local s = math.random(14, 30)
				local p = new("ImageLabel", { Position = UDim2.new(math.random(), 0, 0, -40), Size = UDim2.fromOffset(s, s), BackgroundTransparency = 1, Image = asset(img), ImageColor3 = o.Color or self.Theme.Glow, ZIndex = 85, Rotation = math.random(0, 360) }, gui)
				local tw = tween(p, 2.2 + math.random(), { Position = UDim2.new(p.Position.X.Scale, 0, 1, 40), Rotation = p.Rotation + math.random(-180, 180), ImageTransparency = 0.6 }, Enum.EasingStyle.Linear)
				task.delay(3.4, function()
					p:Destroy()
				end)
			end)
		end
	end
end

-- ============================================================ round 3: 30 more things (looks and tools)
-- Tab elements:  TriState, ToggleGrid, Socials, Until, Poll, Leaderboard, TextArea, Heading, Gallery, FAQ, Changelog, Avatars
-- Window looks:  Snow, Matrix, Aurora, Vignette, Scanlines, Flash, Pulse, Shine, Wiggle, Welcome, CountDown
-- Window tools:  Prompt, Choose, Confirm, Loading, Hotkey, Once, PlaySound
do
	local function rowOf(self, h, name)
		local row = self:_row(h)
		local l = label(row, name or "", 11, C.Text, true)
		l.Position = UDim2.new(0, 10, 0, 0)
		l.Size = UDim2.new(1, -20, 0, h > 44 and 24 or h)
		return row, l
	end
	local function copyText(win, text, what)
		local ok = false
		if type(setclipboard) == "function" then
			ok = pcall(setclipboard, tostring(text))
		end
		win:Notify({ Title = ok and "Copied" or "No clipboard", Text = tostring(what or text), Type = ok and "success" or "warn", Duration = 2 })
		return ok
	end

	function Tab:TriState(o)
		-- Name, Default = "off" | "on" | "auto", Callback(state): a button that cycles off, on, auto
		o = o or {}
		local win = self.Win
		local row = self:_row(38)
		local nm = label(row, o.Name or "Mode", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.5, 0, 1, 0)
		local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(72, 26), BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.White, AutoButtonColor = false }, row)
		corner(b, 8)
		local order, obj, cur = { "off", "on", "auto" }, {}, o.Default or "off"
		local function paint()
			b.Text = string.upper(cur)
			b.BackgroundColor3 = cur == "on" and C.Green or cur == "auto" and C.Yellow or win.Theme.Off
			b.TextColor3 = cur == "auto" and Color3.new(0, 0, 0) or C.White
		end
		function obj:Set(v, silent)
			if not table.find(order, v) then
				return
			end
			cur = v
			paint()
			if not silent then
				win:_playClick()
				safe(o.Callback, cur)
			end
		end
		function obj:Get()
			return cur
		end
		b.MouseButton1Click:Connect(function()
			obj:Set(order[(table.find(order, cur) % 3) + 1])
		end)
		win:_onTheme(paint)
		paint()
		return register(self, o, obj, "TriState")
	end

	function Tab:ToggleGrid(o)
		-- Name, Items = { "A", "B" }, Columns (default 3), Default = { A = true }, Callback(name, on): small toggle chips in a grid. obj:Get() = { A = true }
		o = o or {}
		local win, items = self.Win, o.Items or {}
		local cols = math.clamp(o.Columns or 3, 1, 4)
		local rows = math.ceil(#items / cols)
		local row, head = rowOf(self, 30 + rows * 32, o.Name or "Options")
		head.Size = UDim2.new(1, -20, 0, 26)
		local obj, btns, state = {}, {}, {}
		local function paint()
			for nm, b in pairs(btns) do
				b.BackgroundColor3 = state[nm] and win.Theme.Accent or win.Theme.Inset
				b.TextColor3 = state[nm] and C.White or C.Dim
			end
		end
		function obj:Set(nm, v, silent)
			nm = tostring(nm)
			if btns[nm] == nil then
				return
			end
			state[nm] = v and true or false
			paint()
			if not silent then
				win:_playClick()
				safe(o.Callback, nm, state[nm])
			end
		end
		function obj:Get()
			return table.clone(state)
		end
		for i, v in ipairs(items) do
			local nm = tostring(v)
			state[nm] = o.Default and o.Default[nm] == true or false
			local c, r = (i - 1) % cols, math.floor((i - 1) / cols)
			local b = new("TextButton", { Position = UDim2.new(c / cols, c == 0 and 10 or 3, 0, 28 + r * 32), Size = UDim2.new(1 / cols, c == 0 and -13 or (c == cols - 1 and -13 or -6), 0, 26), BorderSizePixel = 0, Text = nm, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, TextTruncate = Enum.TextTruncate.AtEnd }, row)
			corner(b, 7)
			btns[nm] = b
			b.MouseButton1Click:Connect(function()
				obj:Set(nm, not state[nm])
			end)
		end
		win:_onTheme(paint)
		paint()
		return register(self, o, obj, "ToggleGrid")
	end

	function Tab:Socials(list)
		-- { { Name = "Discord", Url = "https://...", Color = Color3 }, ... }: a row of buttons that copy a link
		list = list or {}
		local win = self.Win
		local row = self:_row(44)
		local lay = new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Center }, row)
		for i, s in ipairs(list) do
			local b = new("TextButton", { Size = UDim2.new(1 / math.max(#list, 1), -8, 0, 30), BackgroundColor3 = s.Color or win.Theme.Accent, BorderSizePixel = 0, Text = tostring(s.Name or "Link"), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.White, AutoButtonColor = false, LayoutOrder = i }, row)
			corner(b, 8)
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				copyText(win, s.Url, s.Name)
			end)
		end
		return register(self, {}, {}, "Socials")
	end

	function Tab:Until(o)
		-- Name, Time (os.time() number to count down to), Callback(): shows 1d 02:03:04 until then
		o = o or {}
		local win = self.Win
		local row = self:_row(40)
		local nm = label(row, o.Name or "Event starts in", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.45, 0, 1, 0)
		local tx = label(row, "", 14, C.Text, true)
		tx.Font, tx.TextXAlignment = Enum.Font.GothamBlack, Enum.TextXAlignment.Right
		tx.Position, tx.Size = UDim2.new(0.4, 0, 0, 0), UDim2.new(0.6, -10, 1, 0)
		win:_bind(tx, "TextColor3", "Glow")
		local obj, target, fired = {}, tonumber(o.Time) or os.time(), false
		local function fmt(s)
			s = math.max(math.floor(s), 0)
			local d, h, m, sec = math.floor(s / 86400), math.floor(s / 3600) % 24, math.floor(s / 60) % 60, s % 60
			return (d > 0 and (d .. "d ") or "") .. string.format("%02d:%02d:%02d", h, m, sec)
		end
		function obj:SetTime(t)
			target, fired = tonumber(t) or target, false
		end
		function obj:Get()
			return math.max(target - os.time(), 0)
		end
		task.spawn(function()
			while tx.Parent do
				local left = target - os.time()
				tx.Text = left > 0 and fmt(left) or (o.DoneText or "now")
				if left <= 0 and not fired then
					fired = true
					safe(o.Callback)
				end
				task.wait(1)
			end
		end)
		return register(self, o, obj, "Until")
	end

	function Tab:Poll(o)
		-- Question, Options = { "A", "B" }, Callback(option): tap to vote, bars show the share. obj:Vote(opt) obj:SetVotes({ A = 3, B = 1 }) obj:Get()
		o = o or {}
		local win, opts = self.Win, o.Options or {}
		local row, head = rowOf(self, 30 + #opts * 30, o.Question or "Poll")
		head.Size = UDim2.new(1, -20, 0, 26)
		local votes, bars, labs, voted = {}, {}, {}, nil
		local obj = {}
		local function render()
			local total = 0
			for _, n in pairs(votes) do
				total += n
			end
			for nm, f in pairs(bars) do
				local share = total > 0 and votes[nm] / total or 0
				tween(f, 0.3, { Size = UDim2.new(share, 0, 1, 0) })
				labs[nm].Text = nm .. "  " .. math.floor(share * 100 + 0.5) .. "%"
			end
		end
		function obj:SetVotes(t)
			for nm in pairs(votes) do
				votes[nm] = tonumber(t[nm]) or 0
			end
			render()
		end
		function obj:Vote(nm)
			nm = tostring(nm)
			if votes[nm] == nil or voted then
				return false
			end
			voted = nm
			votes[nm] += 1
			render()
			win:_playClick()
			safe(o.Callback, nm)
			return true
		end
		function obj:Get()
			return table.clone(votes), voted
		end
		for i, v in ipairs(opts) do
			local nm = tostring(v)
			votes[nm] = 0
			local b = new("TextButton", { Position = UDim2.new(0, 10, 0, 28 + (i - 1) * 30), Size = UDim2.new(1, -20, 0, 26), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ClipsDescendants = true }, row)
			corner(b, 7)
			win:_bind(b, "BackgroundColor3", "Inset")
			local f = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, BackgroundTransparency = 0.45 }, b)
			win:_bind(f, "BackgroundColor3", "Accent")
			bars[nm] = f
			local l = label(b, nm, 10, C.Text, true)
			l.Position, l.Size = UDim2.new(0, 8, 0, 0), UDim2.new(1, -16, 1, 0)
			labs[nm] = l
			b.MouseButton1Click:Connect(function()
				obj:Vote(nm)
			end)
		end
		render()
		return register(self, o, obj, "Poll")
	end

	function Tab:Leaderboard(o)
		-- Name, Rows = { { "Ava", 12 }, { "Ben", 7 } }, Max (default 5): ranked list with gold / silver / bronze. obj:SetRows(rows)
		o = o or {}
		local win = self.Win
		local max = o.Max or 5
		local row, head = rowOf(self, 30 + max * 24, o.Name or "Leaderboard")
		head.Size = UDim2.new(1, -20, 0, 26)
		local medals = { Color3.fromRGB(255, 200, 60), Color3.fromRGB(200, 205, 215), Color3.fromRGB(205, 130, 70) }
		local lines = {}
		for i = 1, max do
			local r = new("Frame", { Position = UDim2.new(0, 10, 0, 28 + (i - 1) * 24), Size = UDim2.new(1, -20, 0, 22), BackgroundTransparency = 1 }, row)
			local rank = label(r, tostring(i), 11, medals[i] or C.Dim, true)
			rank.Font, rank.Size = Enum.Font.GothamBlack, UDim2.new(0, 22, 1, 0)
			local nm = label(r, "", 11, C.Text, false)
			nm.Position, nm.Size = UDim2.new(0, 26, 0, 0), UDim2.new(0.6, 0, 1, 0)
			local sc = label(r, "", 11, medals[i] or C.Dim, true)
			sc.TextXAlignment, sc.Position, sc.Size = Enum.TextXAlignment.Right, UDim2.new(0.6, 0, 0, 0), UDim2.new(0.4, 0, 1, 0)
			lines[i] = { nm, sc }
		end
		local obj = {}
		function obj:SetRows(rows)
			rows = rows or {}
			for i = 1, max do
				local r = rows[i]
				lines[i][1].Text = r and tostring(r[1]) or ""
				lines[i][2].Text = r and tostring(r[2]) or ""
			end
		end
		obj:SetRows(o.Rows)
		return register(self, o, obj, "Leaderboard")
	end

	function Tab:TextArea(o)
		-- Name, Lines (default 4), Default, Placeholder, Flag, Callback(text): a big multi-line text box
		o = o or {}
		local win = self.Win
		local lines = math.clamp(o.Lines or 4, 2, 12)
		local row, head = rowOf(self, 30 + lines * 15, o.Name or "Notes")
		head.Size = UDim2.new(1, -20, 0, 26)
		local box = new("TextBox", { Position = UDim2.new(0, 10, 0, 28), Size = UDim2.new(1, -20, 1, -36), BorderSizePixel = 0, Text = tostring(o.Default or ""), PlaceholderText = o.Placeholder or "type here...", MultiLine = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.Text, PlaceholderColor3 = C.Dim }, row)
		corner(box, 7)
		win:_bind(box, "BackgroundColor3", "Inset")
		new("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingTop = UDim.new(0, 4), PaddingRight = UDim.new(0, 6) }, box)
		local obj = {}
		function obj:Get()
			return box.Text
		end
		function obj:Set(t, silent)
			box.Text = tostring(t or "")
			if not silent then
				safe(o.Callback, box.Text)
			end
		end
		box.FocusLost:Connect(function()
			safe(o.Callback, box.Text)
		end)
		return register(self, o, obj, "TextArea")
	end

	function Tab:Heading(o)
		-- Text, Size (default 18): a big title with an accent line under it
		o = type(o) == "table" and o or { Text = o }
		local win = self.Win
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, (o.Size or 18) + 12), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		local t = label(row, tostring(o.Text or "Heading"), o.Size or 18, C.White, true)
		t.Font, t.Size = Enum.Font.GothamBlack, UDim2.new(1, 0, 1, -5)
		local ln = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(0.3, 0, 0, 3), BorderSizePixel = 0 }, row)
		corner(ln, 2)
		win:_bind(ln, "BackgroundColor3", "Accent")
		local obj = {}
		function obj:Set(x)
			t.Text = tostring(x)
		end
		return register(self, o, obj, "Heading")
	end

	function Tab:Gallery(o)
		-- Images = { 123, 456 }, Height (default 120), Auto (seconds between slides, 0 = off), Callback(index): a picture slider with < > and dots
		o = o or {}
		local win, imgs = self.Win, o.Images or {}
		local h = o.Height or 120
		local row = self:_row(h + 26)
		local im = new("ImageLabel", { Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(1, -16, 0, h), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, Image = "" }, row)
		corner(im, 8)
		local dots = new("Frame", { Position = UDim2.new(0, 0, 0, h + 12), Size = UDim2.new(1, 0, 0, 8), BackgroundTransparency = 1 }, row)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center }, dots)
		local obj, idx, dd = { Index = 1 }, 1, {}
		for i = 1, #imgs do
			local d = new("Frame", { Size = UDim2.fromOffset(7, 7), BorderSizePixel = 0, LayoutOrder = i }, dots)
			corner(d, 4)
			dd[i] = d
		end
		local function show()
			if #imgs == 0 then
				return
			end
			im.Image = asset(imgs[idx])
			obj.Index = idx
			for i, d in ipairs(dd) do
				d.BackgroundColor3 = i == idx and win.Theme.Accent or win.Theme.Off
			end
		end
		function obj:Set(i)
			if #imgs == 0 then
				return
			end
			idx = ((math.floor(tonumber(i) or 1) - 1) % #imgs) + 1
			show()
			safe(o.Callback, idx)
		end
		function obj:Next()
			obj:Set(idx + 1)
		end
		function obj:Prev()
			obj:Set(idx - 1)
		end
		local function arrow(txt, x, ax, fn)
			local b = new("TextButton", { AnchorPoint = Vector2.new(ax, 0.5), Position = UDim2.new(x, ax == 0 and 12 or -12, 0, 8 + h / 2), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, BorderSizePixel = 0, Text = txt, Font = Enum.Font.GothamBlack, TextSize = 13, TextColor3 = C.White, AutoButtonColor = false, ZIndex = 3 }, row)
			corner(b, 13)
			b.MouseButton1Click:Connect(fn)
		end
		arrow("<", 0, 0, function() obj:Prev() end)
		arrow(">", 1, 1, function() obj:Next() end)
		show()
		if (o.Auto or 0) > 0 then
			task.spawn(function()
				while row.Parent do
					task.wait(o.Auto)
					if row.Parent and not win.ReduceMotion then
						obj:Next()
					end
				end
			end)
		end
		return register(self, o, obj, "Gallery")
	end

	function Tab:FAQ(list)
		-- { { "Question?", "Answer." }, ... }: tap a question to open the answer
		list = list or {}
		local win = self.Win
		local wrap = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)
		local items = {}
		for i, qa in ipairs(list) do
			local card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, LayoutOrder = i }, wrap)
			corner(card, 8)
			win:_bind(card, "BackgroundColor3", "Item")
			new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, card)
			local q = new("TextButton", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, LayoutOrder = 0 }, card)
			local ql = label(q, "", 11, C.Text, true)
			ql.Position, ql.Size = UDim2.new(0, 10, 0, 0), UDim2.new(1, -20, 1, 0)
			local a = label(card, tostring(qa[2] or ""), 10, C.Dim, false)
			a.Size, a.AutomaticSize, a.TextWrapped, a.TextTruncate, a.LayoutOrder, a.Visible = UDim2.new(1, -20, 0, 0), Enum.AutomaticSize.Y, true, Enum.TextTruncate.None, 1, false
			new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingBottom = UDim.new(0, 8) }, a)
			local open = false
			local function render()
				ql.Text = (open and "v  " or ">  ") .. tostring(qa[1])
				a.Visible = open
			end
			items[i] = function(v)
				open = v
				render()
			end
			q.MouseButton1Click:Connect(function()
				open = not open
				render()
			end)
			render()
		end
		local obj = {}
		function obj:Open(i)
			if items[i] then
				items[i](true)
			end
		end
		function obj:CloseAll()
			for _, f in ipairs(items) do
				f(false)
			end
		end
		return register(self, {}, obj, "FAQ")
	end

	function Tab:Changelog(list)
		-- { { Version = "1.0.0", Items = { "Added X", "Fixed Y" } }, ... }: a version history card
		list = list or {}
		local win = self.Win
		local card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		corner(card, 8)
		win:_bind(card, "BackgroundColor3", "Item")
		new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, card)
		new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, card)
		local n = 0
		for _, v in ipairs(list) do
			n += 1
			local h = label(card, "v" .. tostring(v.Version or "?"), 12, C.White, true)
			h.Size, h.LayoutOrder = UDim2.new(1, 0, 0, 18), n
			win:_bind(h, "TextColor3", "Glow")
			for _, it in ipairs(v.Items or {}) do
				n += 1
				local l = label(card, "-  " .. tostring(it), 10, C.Dim, false)
				l.Size, l.AutomaticSize, l.TextWrapped, l.TextTruncate, l.LayoutOrder = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, true, Enum.TextTruncate.None, n
			end
		end
		return register(self, {}, {}, "Changelog")
	end

	function Tab:Avatars(o)
		-- UserIds = { 1, 2, 3 } (or Names), Size (default 38): a row of player headshots
		o = o or {}
		local win = self.Win
		local size = o.Size or 38
		local row = self:_row(size + 14)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = Enum.HorizontalAlignment.Center }, row)
		for i, id in ipairs(o.UserIds or {}) do
			local im = new("ImageLabel", { Size = UDim2.fromOffset(size, size), BackgroundColor3 = win.Theme.Inset, BorderSizePixel = 0, Image = "", LayoutOrder = i }, row)
			corner(im, size / 2)
			task.spawn(function()
				pcall(function()
					im.Image = game:GetService("Players"):GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
			end)
		end
		return register(self, o, {}, "Avatars")
	end

	-- ---------------------------------------------------------------- window looks
	local function particles(win, key, make, every)
		win._looks = win._looks or {}
		local my = (win._looks[key] or 0) + 1
		win._looks[key] = my
		task.spawn(function()
			while win._looks[key] == my and win.Gui and win.Gui.Parent do
				if not win.ReduceMotion then
					pcall(make)
				end
				task.wait(every)
			end
		end)
		return function()
			if win._looks[key] == my then
				win._looks[key] = my + 1
			end
		end
	end
	local function stopLook(win, key)
		if win._looks then
			win._looks[key] = (win._looks[key] or 0) + 1
		end
	end

	function Window:Snow(on, o)
		-- Win:Snow(true) / Win:Snow(false). o = { Color, Image, Speed }: snow (or any picture) falls across the screen
		stopLook(self, "snow")
		if on == false then
			return
		end
		o = o or {}
		local gui, win = self.Gui, self
		particles(self, "snow", function()
			local s = math.random(4, 9)
			local x = math.random()
			local p
			if o.Image then
				p = new("ImageLabel", { BackgroundTransparency = 1, Image = asset(o.Image), ImageColor3 = o.Color or Color3.new(1, 1, 1), Size = UDim2.fromOffset(s * 2, s * 2), Position = UDim2.new(x, 0, 0, -20), ZIndex = 84 }, gui)
			else
				p = new("Frame", { BackgroundColor3 = o.Color or Color3.new(1, 1, 1), BorderSizePixel = 0, BackgroundTransparency = 0.2, Size = UDim2.fromOffset(s, s), Position = UDim2.new(x, 0, 0, -20), ZIndex = 84 }, gui)
				corner(p, s)
			end
			local t = (o.Speed and 8 / o.Speed) or (6 + math.random() * 4)
			tween(p, t, { Position = UDim2.new(x + (math.random() - 0.5) * 0.15, 0, 1, 20) }, Enum.EasingStyle.Linear)
			task.delay(t + 0.2, function()
				p:Destroy()
			end)
		end, 0.18)
	end

	function Window:Matrix(on, o)
		-- Win:Matrix(true): falling code characters (letters and numbers only). o = { Color }
		stopLook(self, "matrix")
		if on == false then
			return
		end
		o = o or {}
		local gui = self.Gui
		local chars = "01ABCDEFXYZ"
		particles(self, "matrix", function()
			local x = math.random()
			local k = math.random(1, #chars)
			local ch = chars:sub(k, k)
			local p = new("TextLabel", { BackgroundTransparency = 1, Text = ch, Font = Enum.Font.Code, TextSize = math.random(12, 18), TextColor3 = o.Color or C.Green, TextTransparency = 0.3, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(x, 0, 0, -20), ZIndex = 84 }, gui)
			local t = 2.5 + math.random() * 2
			tween(p, t, { Position = UDim2.new(x, 0, 1, 20), TextTransparency = 0.9 }, Enum.EasingStyle.Linear)
			task.delay(t + 0.2, function()
				p:Destroy()
			end)
		end, 0.06)
	end

	function Window:Aurora(on, o)
		-- Win:Aurora(true): a soft moving color glow behind the panel. o = { Colors = { Color3, Color3, Color3 }, Transparency (0.85) }
		stopLook(self, "aurora")
		if self._aurora then
			self._aurora:Destroy()
			self._aurora = nil
		end
		if on == false then
			return
		end
		o = o or {}
		local t = self.Theme
		local cols = o.Colors or { t.Accent, Color3.fromRGB(80, 120, 255), t.Glow }
		local f = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = o.Transparency or 0.85, BorderSizePixel = 0, ZIndex = 0, Active = false }, self.Gui)
		local g = new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, cols[1]), ColorSequenceKeypoint.new(0.5, cols[2] or cols[1]), ColorSequenceKeypoint.new(1, cols[3] or cols[1]) }) }, f)
		self._aurora = f
		local win = self
		particles(self, "aurora", function()
			g.Rotation = (g.Rotation + 2) % 360
		end, 0.05)
	end

	function Window:Vignette(on, o)
		-- Win:Vignette(true, { Strength = 0.5 }): dark edges around the screen
		if self._vig then
			self._vig:Destroy()
			self._vig = nil
		end
		if on == false then
			return
		end
		local s = (o and o.Strength) or 0.5
		local holder = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 83, Active = false }, self.Gui)
		local function edge(pos, size, anchor, rot)
			local f = new("Frame", { Position = pos, Size = size, AnchorPoint = anchor, BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 83, Active = false }, holder)
			new("UIGradient", { Rotation = rot, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1 - s), NumberSequenceKeypoint.new(1, 1) }) }, f)
		end
		edge(UDim2.fromScale(0, 0), UDim2.new(1, 0, 0.25, 0), Vector2.new(0, 0), 90)
		edge(UDim2.fromScale(0, 1), UDim2.new(1, 0, 0.25, 0), Vector2.new(0, 1), 270)
		edge(UDim2.fromScale(0, 0), UDim2.new(0.18, 0, 1, 0), Vector2.new(0, 0), 0)
		edge(UDim2.fromScale(1, 0), UDim2.new(0.18, 0, 1, 0), Vector2.new(1, 0), 180)
		self._vig = holder
	end

	function Window:Scanlines(on, o)
		-- Win:Scanlines(true): a thin light line sweeps down the screen again and again (retro screen look)
		stopLook(self, "scan")
		if self._scanF then
			self._scanF:Destroy()
			self._scanF = nil
		end
		if on == false then
			return
		end
		local f = new("Frame", { Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 0, -6), BackgroundColor3 = (o and o.Color) or self.Theme.Glow, BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = 84, Active = false }, self.Gui)
		self._scanF = f
		local win = self
		particles(self, "scan", function()
			f.Position = UDim2.new(0, 0, 0, -6)
			tween(f, 2.4, { Position = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)
		end, 3)
	end

	function Window:Flash(color, t)
		-- a quick full-screen flash of color
		if self.ReduceMotion then
			return
		end
		local f = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = color or Color3.new(1, 1, 1), BackgroundTransparency = 0.55, BorderSizePixel = 0, ZIndex = 95, Active = false }, self.Gui)
		tween(f, t or 0.45, { BackgroundTransparency = 1 })
		task.delay((t or 0.45) + 0.1, function()
			f:Destroy()
		end)
	end

	function Window:Pulse(target, color)
		-- the outline of an element breathes 3 times (Win:Pulse(element))
		local row = type(target) == "table" and target.Row or target
		if not row or not row.Parent then
			return false
		end
		local st = new("UIStroke", { Color = color or self.Theme.Glow, Thickness = 2, Transparency = 1 }, row)
		task.spawn(function()
			for _ = 1, 3 do
				tween(st, 0.4, { Transparency = 0.1, Thickness = 3 })
				task.wait(0.45)
				tween(st, 0.4, { Transparency = 1, Thickness = 1 })
				task.wait(0.45)
			end
			st:Destroy()
		end)
		return true
	end

	function Window:Shine(target)
		-- a light sweeps across an element (Win:Shine(element))
		local row = type(target) == "table" and target.Row or target
		if not row or not row.Parent or self.ReduceMotion then
			return false
		end
		local old = row.ClipsDescendants
		row.ClipsDescendants = true
		local s = new("Frame", { Size = UDim2.new(0.25, 0, 1.6, 0), Position = UDim2.new(-0.3, 0, -0.3, 0), Rotation = 20, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = (row.ZIndex or 1) + 5 }, row)
		tween(s, 0.7, { Position = UDim2.new(1.1, 0, -0.3, 0) }, Enum.EasingStyle.Quad)
		task.delay(0.8, function()
			s:Destroy()
			row.ClipsDescendants = old
		end)
		return true
	end

	function Window:Wiggle(target)
		-- shakes an element left and right (Win:Wiggle(element)), good for "wrong"
		local row = type(target) == "table" and target.Row or target
		if not row or not row.Parent then
			return false
		end
		local p = row.Position or UDim2.new()
		task.spawn(function()
			for i = 1, 6 do
				row.Position = p + UDim2.fromOffset(i % 2 == 0 and 5 or -5, 0)
				task.wait(0.04)
			end
			row.Position = p
		end)
		return true
	end

	function Window:Welcome(o)
		-- Text, Sub, Time (seconds): a big greeting that types itself in the middle of the screen, then fades. Win:Welcome({ Text = "Welcome back" })
		if type(o) == "string" then
			o = { Text = o }
		end
		o = o or {}
		local text = tostring(o.Text or "Welcome")
		local t = self.Theme
		local box = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.4), Size = UDim2.fromOffset(420, 70), BackgroundTransparency = 1, ZIndex = 88 }, self.Gui)
		local big = label(box, "", 28, C.White, true)
		big.Font, big.TextXAlignment, big.Size, big.ZIndex = Enum.Font.GothamBlack, Enum.TextXAlignment.Center, UDim2.new(1, 0, 0, 38), 89
		local st = new("UIStroke", { Color = t.Glow, Thickness = 2 }, big)
		local sub = label(box, tostring(o.Sub or ""), 12, t.Glow, true)
		sub.TextXAlignment, sub.Position, sub.Size, sub.ZIndex, sub.TextTransparency = Enum.TextXAlignment.Center, UDim2.fromOffset(0, 42), UDim2.new(1, 0, 0, 20), 89, 1
		task.spawn(function()
			for i = 1, #text do
				big.Text = text:sub(1, i)
				task.wait(self.ReduceMotion and 0 or 0.05)
			end
			tween(sub, 0.4, { TextTransparency = 0 })
			task.wait(o.Time or 1.8)
			tween(big, 0.5, { TextTransparency = 1 })
			tween(st, 0.5, { Transparency = 1 })
			tween(sub, 0.5, { TextTransparency = 1 })
			task.wait(0.6)
			box:Destroy()
		end)
	end

	function Window:CountDown(n, cb, o)
		-- Win:CountDown(3, function() ... end): big numbers 3, 2, 1 pop up on screen, then your function runs
		n = math.clamp(math.floor(tonumber(n) or 3), 1, 10)
		local t = self.Theme
		local l = label(self.Gui, "", 90, (o and o.Color) or t.Glow, true)
		l.Font, l.TextXAlignment, l.AnchorPoint, l.Position, l.Size, l.ZIndex = Enum.Font.GothamBlack, Enum.TextXAlignment.Center, Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.45), UDim2.fromOffset(200, 120), 92
		local sc = new("UIScale", { Scale = 1 }, l)
		task.spawn(function()
			for i = n, 1, -1 do
				l.Text = tostring(i)
				sc.Scale = 0.4
				l.TextTransparency = 0
				tween(sc, 0.35, { Scale = 1 }, Enum.EasingStyle.Back)
				task.wait(0.7)
				tween(l, 0.25, { TextTransparency = 1 })
				task.wait(0.3)
			end
			l:Destroy()
			safe(cb)
		end)
	end

	-- ---------------------------------------------------------------- window tools
	local function modal(win, w)
		local t = win.Theme
		local back = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, BorderSizePixel = 0, ZIndex = 70 }, win.Gui)
		tween(back, 0.2, { BackgroundTransparency = 0.45 })
		local card = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(w or 280, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.new(1, 1, 1), Active = true, ZIndex = 71 }, back)
		corner(card, 12)
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(t.BG0, t.BG1) }, card)
		new("UIStroke", { Color = t.Glow, Thickness = 1.5 }, card)
		new("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, card)
		new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, card)
		local sc = new("UIScale", { Scale = 0.8 }, card)
		tween(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back)
		local function close()
			if back.Parent then
				tween(back, 0.2, { BackgroundTransparency = 1 })
				tween(sc, 0.2, { Scale = 0.8 })
				task.delay(0.22, function()
					back:Destroy()
				end)
			end
		end
		return card, close, back
	end
	local function mbutton(win, parent, text, order, fn, accent)
		local b = new("TextButton", { Size = UDim2.new(1, 0, 0, 30), BorderSizePixel = 0, Text = text, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.White, AutoButtonColor = false, LayoutOrder = order, ZIndex = 72 }, parent)
		corner(b, 8)
		if accent then
			b.BackgroundColor3 = win.Theme.Accent
		else
			b.BackgroundColor3 = win.Theme.Inset
		end
		b.MouseButton1Click:Connect(fn)
		return b
	end

	function Window:Prompt(o)
		-- Title, Text, Placeholder, Default, Button = "OK", Callback(text): a pop-up with a text box
		o = o or {}
		local card, close = modal(self)
		local h = label(card, o.Title or "Type something", 14, self.Theme.Glow, true)
		h.Font, h.Size, h.LayoutOrder, h.ZIndex = Enum.Font.GothamBlack, UDim2.new(1, 0, 0, 20), 1, 72
		if o.Text then
			local b = label(card, o.Text, 10, C.Dim, false)
			b.TextWrapped, b.TextTruncate, b.Size, b.AutomaticSize, b.LayoutOrder, b.ZIndex = true, Enum.TextTruncate.None, UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, 2, 72
		end
		local box = new("TextBox", { Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = self.Theme.Inset, BorderSizePixel = 0, Text = tostring(o.Default or ""), PlaceholderText = o.Placeholder or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.Text, PlaceholderColor3 = C.Dim, ClearTextOnFocus = false, LayoutOrder = 3, ZIndex = 72 }, card)
		corner(box, 8)
		mbutton(self, card, o.Button or "OK", 4, function()
			local txt = box.Text
			close()
			safe(o.Callback, txt)
		end, true)
		mbutton(self, card, "Cancel", 5, close)
		return { Close = close, Box = box }
	end

	function Window:Choose(o)
		-- Title, Options = { "A", "B" }, Callback(option): a pop-up with one button per option
		o = o or {}
		local card, close = modal(self)
		local h = label(card, o.Title or "Choose one", 14, self.Theme.Glow, true)
		h.Font, h.Size, h.LayoutOrder, h.ZIndex = Enum.Font.GothamBlack, UDim2.new(1, 0, 0, 20), 1, 72
		for i, opt in ipairs(o.Options or {}) do
			mbutton(self, card, tostring(opt), 1 + i, function()
				close()
				safe(o.Callback, opt)
			end, i == 1)
		end
		return { Close = close }
	end

	function Window:Confirm(text, yes, no)
		-- Win:Confirm("Delete everything?", function() ... end, function() ... end)
		self:Dialog({ Title = "Are you sure?", Text = text, Buttons = { { Name = "Yes", Callback = yes }, { Name = "No", Callback = no } } })
	end

	function Window:Loading(text)
		-- local ld = Win:Loading("Please wait"); ld:SetText("Almost"); ld:Close(): a full-screen dim with a pulsing message
		local card, close = modal(self, 220)
		local l = label(card, tostring(text or "Loading"), 13, C.White, true)
		l.TextXAlignment, l.Size, l.LayoutOrder, l.ZIndex = Enum.TextXAlignment.Center, UDim2.new(1, 0, 0, 24), 1, 72
		local bar = new("Frame", { Size = UDim2.new(1, 0, 0, 4), BackgroundColor3 = self.Theme.Inset, BorderSizePixel = 0, LayoutOrder = 2, ClipsDescendants = true, ZIndex = 72 }, card)
		corner(bar, 2)
		local run = new("Frame", { Size = UDim2.new(0.35, 0, 1, 0), Position = UDim2.new(-0.4, 0, 0, 0), BackgroundColor3 = self.Theme.Glow, BorderSizePixel = 0, ZIndex = 73 }, bar)
		corner(run, 2)
		local alive = true
		task.spawn(function()
			while alive and run.Parent do
				run.Position = UDim2.new(-0.4, 0, 0, 0)
				tween(run, 0.9, { Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quad)
				task.wait(1)
			end
		end)
		local obj = {}
		function obj:SetText(t)
			l.Text = tostring(t)
		end
		function obj:Close()
			alive = false
			close()
		end
		return obj
	end

	function Window:Hotkey(key, fn)
		-- Win:Hotkey(Enum.KeyCode.F, function() ... end): runs when the key is pressed (not while typing). Returns a function that removes it
		local uis = game:GetService("UserInputService")
		local c = uis.InputBegan:Connect(function(input, typing)
			if not typing and input.KeyCode == key then
				safe(fn)
			end
		end)
		return function()
			c:Disconnect()
		end
	end

	function Window:Once(key, fn)
		-- Win:Once("tour", function() ... end): runs the function only the first time ever on this device. Returns true if it ran
		local file = "RebelUI_once_" .. tostring(key):gsub("%W", "") .. ".txt"
		local seen = false
		pcall(function()
			seen = type(isfile) == "function" and isfile(file)
		end)
		if seen then
			return false
		end
		pcall(function()
			if type(writefile) == "function" then
				writefile(file, "1")
			end
		end)
		safe(fn)
		return true
	end

	function Window:PlaySound(id, volume)
		-- Win:PlaySound(123456, 0.5): plays a Roblox sound once
		local ok = pcall(function()
			local s = Instance.new("Sound")
			s.SoundId = asset(id)
			s.Volume = volume or 0.5
			s.Parent = self.Gui
			s:Play()
			task.delay(6, function()
				s:Destroy()
			end)
		end)
		return ok
	end
end

-- ============================================================ round 4: 30+ more things (data, polish, developer tools)
-- Tab elements:  Vector, Level, BarChart, Stack, ButtonRow, Tiles, Status, KeyValue, Callout, Tasks, ColorInput
-- Window:        GoTo, ListTabs, OnOpen, OnClose, Every, CycleTheme, RandomTheme, Fireworks, Sparkle, RippleAt, Achievement,
--                ShowShortcuts, CopyReport, SetFont, SetTextScale, Konami, IdleDim
-- Library:       UI:SelfTest(), UI.Debounce, UI.Throttle, UI.FormatNumber, UI:Info()
do
	local function rowOf(self, h, name)
		local row = self:_row(h)
		local l = label(row, name or "", 11, C.Text, true)
		l.Position = UDim2.new(0, 10, 0, 0)
		l.Size = UDim2.new(1, -20, 0, h > 44 and 24 or h)
		return row, l
	end

	function Tab:Vector(o)
		-- Name, Default = { 0, 0, 0 }, Labels = { "X", "Y", "Z" }, Callback(Vector3): three number boxes. obj:Get() = Vector3
		o = o or {}
		local win = self.Win
		local row, head = rowOf(self, 58, o.Name or "Vector")
		head.Size = UDim2.new(1, -20, 0, 24)
		local d, labs = o.Default or { 0, 0, 0 }, o.Labels or { "X", "Y", "Z" }
		local boxes, vals = {}, { tonumber(d[1]) or 0, tonumber(d[2]) or 0, tonumber(d[3]) or 0 }
		local obj = {}
		function obj:Get()
			return Vector3.new(vals[1], vals[2], vals[3])
		end
		function obj:Set(v, silent)
			vals = { v.X, v.Y, v.Z }
			for i, b in ipairs(boxes) do
				b.Text = tostring(math.floor(vals[i] * 100 + 0.5) / 100)
			end
			if not silent then
				safe(o.Callback, obj:Get())
			end
		end
		for i = 1, 3 do
			local b = new("TextBox", { Position = UDim2.new((i - 1) / 3, i == 1 and 10 or 3, 0, 28), Size = UDim2.new(1 / 3, i == 2 and -6 or -13, 0, 24), BorderSizePixel = 0, Text = tostring(vals[i]), PlaceholderText = labs[i], Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.Text, PlaceholderColor3 = C.Dim, ClearTextOnFocus = false }, row)
			corner(b, 7)
			win:_bind(b, "BackgroundColor3", "Inset")
			boxes[i] = b
			b.FocusLost:Connect(function()
				vals[i] = tonumber(b.Text) or vals[i]
				b.Text = tostring(vals[i])
				safe(o.Callback, obj:Get())
			end)
		end
		return register(self, o, obj, "Vector")
	end

	function Tab:Level(o)
		-- Name, Level, XP, Next (xp needed): a level badge with an xp bar. obj:SetXP(xp, next) obj:AddXP(n) obj:SetLevel(n)
		o = o or {}
		local win = self.Win
		local row = self:_row(52)
		local badge = new("TextLabel", { Position = UDim2.new(0, 10, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Size = UDim2.fromOffset(34, 34), BorderSizePixel = 0, Font = Enum.Font.GothamBlack, TextSize = 14, TextColor3 = C.White }, row)
		corner(badge, 17)
		win:_bind(badge, "BackgroundColor3", "Accent")
		local nm = label(row, o.Name or "Level", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 54, 0, 6), UDim2.new(1, -64, 0, 16)
		local bg = new("Frame", { Position = UDim2.new(0, 54, 0, 26), Size = UDim2.new(1, -64, 0, 8), BorderSizePixel = 0 }, row)
		corner(bg, 4)
		win:_bind(bg, "BackgroundColor3", "Inset")
		local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 }, bg)
		corner(fill, 4)
		win:_bind(fill, "BackgroundColor3", "Glow")
		local xl = label(row, "", 9, C.Dim, false)
		xl.Position, xl.Size = UDim2.new(0, 54, 0, 36), UDim2.new(1, -64, 0, 12)
		local obj = { Level = o.Level or 1, XP = o.XP or 0, Next = o.Next or 100 }
		local function render()
			badge.Text = tostring(obj.Level)
			tween(fill, 0.35, { Size = UDim2.new(math.clamp(obj.XP / math.max(obj.Next, 1), 0, 1), 0, 1, 0) })
			xl.Text = obj.XP .. " / " .. obj.Next .. " xp"
		end
		function obj:SetXP(xp, nxt)
			obj.XP, obj.Next = xp or obj.XP, nxt or obj.Next
			render()
		end
		function obj:AddXP(n)
			obj.XP += n or 0
			while obj.XP >= obj.Next do
				obj.XP -= obj.Next
				obj.Level += 1
				safe(o.OnLevelUp, obj.Level)
			end
			render()
		end
		function obj:SetLevel(n)
			obj.Level = n
			render()
		end
		render()
		return register(self, o, obj, "Level")
	end

	function Tab:BarChart(o)
		-- Name, Data = { { "Mon", 3 }, { "Tue", 5 } }, Height (default 90): vertical bars. obj:SetData(data)
		o = o or {}
		local win = self.Win
		local h = o.Height or 90
		local row, head = rowOf(self, h + 56, o.Name or "Chart")
		head.Size = UDim2.new(1, -20, 0, 24)
		local area = new("Frame", { Position = UDim2.new(0, 10, 0, 28), Size = UDim2.new(1, -20, 0, h), BackgroundTransparency = 1 }, row)
		local names = new("Frame", { Position = UDim2.new(0, 10, 0, 32 + h), Size = UDim2.new(1, -20, 0, 14), BackgroundTransparency = 1 }, row)
		local obj = {}
		function obj:SetData(data)
			area:ClearAllChildren()
			names:ClearAllChildren()
			data = data or {}
			local max = 1
			for _, d in ipairs(data) do
				max = math.max(max, tonumber(d[2]) or 0)
			end
			local n = math.max(#data, 1)
			for i, d in ipairs(data) do
				local f = (tonumber(d[2]) or 0) / max
				local bar = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new((i - 1) / n, 3, 1, 0), Size = UDim2.new(1 / n, -6, 0, 0), BorderSizePixel = 0 }, area)
				corner(bar, 4)
				win:_bind(bar, "BackgroundColor3", "Accent")
				tween(bar, 0.4, { Size = UDim2.new(1 / n, -6, f, 0) })
				local v = label(bar, tostring(d[2]), 9, C.White, true)
				v.TextXAlignment, v.Size, v.Position = Enum.TextXAlignment.Center, UDim2.new(1, 0, 0, 12), UDim2.fromOffset(0, -13)
				local l = label(names, tostring(d[1]), 9, C.Dim, false)
				l.TextXAlignment, l.Position, l.Size = Enum.TextXAlignment.Center, UDim2.new((i - 1) / n, 0, 0, 0), UDim2.new(1 / n, 0, 1, 0)
			end
		end
		obj:SetData(o.Data)
		return register(self, o, obj, "BarChart")
	end

	function Tab:Stack(o)
		-- Name, Parts = { { "Wins", 6, Color3 }, { "Losses", 4, Color3 } }: one bar split into colored parts with a legend. obj:SetParts(parts)
		o = o or {}
		local win = self.Win
		local row, head = rowOf(self, 62, o.Name or "Split")
		head.Size = UDim2.new(1, -20, 0, 22)
		local bar = new("Frame", { Position = UDim2.new(0, 10, 0, 26), Size = UDim2.new(1, -20, 0, 12), BackgroundTransparency = 1, ClipsDescendants = true }, row)
		corner(bar, 6)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal }, bar)
		local leg = label(row, "", 9, C.Dim, false)
		leg.Position, leg.Size = UDim2.new(0, 10, 0, 42), UDim2.new(1, -20, 0, 14)
		local obj = {}
		local pal = { C.Green, Color3.fromRGB(80, 160, 255), C.Yellow, C.Bad, Color3.fromRGB(180, 100, 255) }
		function obj:SetParts(parts)
			bar:ClearAllChildren()
			new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal }, bar)
			local total, txt = 0, {}
			for _, p in ipairs(parts or {}) do
				total += tonumber(p[2]) or 0
			end
			for i, p in ipairs(parts or {}) do
				local share = total > 0 and (tonumber(p[2]) or 0) / total or 0
				new("Frame", { Size = UDim2.new(share, 0, 1, 0), BackgroundColor3 = p[3] or pal[(i - 1) % #pal + 1], BorderSizePixel = 0, LayoutOrder = i }, bar)
				txt[#txt + 1] = tostring(p[1]) .. " " .. math.floor(share * 100 + 0.5) .. "%"
			end
			leg.Text = table.concat(txt, "   ")
		end
		obj:SetParts(o.Parts)
		return register(self, o, obj, "Stack")
	end

	function Tab:ButtonRow(list)
		-- { { Name = "A", Callback = fn, Color = Color3 }, { Name = "B" } }: several buttons side by side
		list = list or {}
		local win = self.Win
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, row)
		local n = math.max(#list, 1)
		for i, b in ipairs(list) do
			local btn = new("TextButton", { Size = UDim2.new(1 / n, -6 * (n - 1) / n, 1, 0), BorderSizePixel = 0, BackgroundColor3 = b.Color or win.Theme.Item, Text = tostring(b.Name or "Button"), Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.Text, AutoButtonColor = false, LayoutOrder = i }, row)
			corner(btn, 8)
			if not b.Color then
				win:_bind(btn, "BackgroundColor3", "Item")
			end
			btn.MouseButton1Click:Connect(function()
				win:_playClick()
				safe(b.Callback)
			end)
		end
		return register(self, {}, {}, "ButtonRow")
	end

	function Tab:Tiles(list, o)
		-- { { Name = "Teleport", Icon = 123, Callback = fn }, ... }, o = { Columns = 3 }: a grid of big tap tiles like an app screen
		list, o = list or {}, o or {}
		local win = self.Win
		local cols = math.clamp(o.Columns or 3, 2, 4)
		local grid = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		new("UIGridLayout", { CellSize = UDim2.new(1 / cols, -6, 0, 64), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder }, grid)
		for i, t in ipairs(list) do
			local b = new("TextButton", { BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = i }, grid)
			corner(b, 10)
			win:_bind(b, "BackgroundColor3", "Item")
			if t.Icon then
				local im = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1, Image = asset(t.Icon), ScaleType = Enum.ScaleType.Fit }, b)
				pcall(function() RebelUI._iconFix(im, t.Icon) end)
			end
			local l = label(b, tostring(t.Name or "Tile"), 10, C.Text, true)
			l.TextXAlignment, l.Position, l.Size = Enum.TextXAlignment.Center, UDim2.new(0, 2, 1, -22), UDim2.new(1, -4, 0, 18)
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				safe(t.Callback)
			end)
		end
		return register(self, {}, {}, "Tiles")
	end

	function Tab:Status(o)
		-- Name, State = "online" | "busy" | "warn" | "offline", Text: a colored dot (online pulses). obj:Set("busy", "text")
		o = o or {}
		local win = self.Win
		local row = self:_row(36)
		local dot = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0), Size = UDim2.fromOffset(10, 10), BorderSizePixel = 0 }, row)
		corner(dot, 5)
		local nm = label(row, o.Name or "Status", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 30, 0, 0), UDim2.new(0.5, -30, 1, 0)
		local tx = label(row, "", 11, C.Dim, false)
		tx.TextXAlignment, tx.Position, tx.Size = Enum.TextXAlignment.Right, UDim2.new(0.5, 0, 0, 0), UDim2.new(0.5, -10, 1, 0)
		local cols = { online = C.Green, busy = C.Bad, warn = C.Yellow, offline = Color3.fromRGB(110, 110, 120) }
		local obj, state = {}, "online"
		function obj:Set(s, text)
			state = cols[s] and s or "online"
			dot.BackgroundColor3 = cols[state]
			tx.Text = tostring(text or state)
		end
		task.spawn(function()
			while dot.Parent do
				if state == "online" and not win.ReduceMotion then
					tween(dot, 0.7, { BackgroundTransparency = 0.6 })
					task.wait(0.8)
					tween(dot, 0.7, { BackgroundTransparency = 0 })
				else
					dot.BackgroundTransparency = 0
				end
				task.wait(0.8)
			end
		end)
		obj:Set(o.State or "online", o.Text)
		return register(self, o, obj, "Status")
	end

	function Tab:KeyValue(o)
		-- Name, Rows = { { "Ping", "40 ms" }, { "Server", "US-1" } }: an info card. obj:Set("Ping", "55 ms") obj:Get("Ping")
		o = o or {}
		local win = self.Win
		local rows = o.Rows or {}
		local row, head = rowOf(self, 28 + #rows * 22, o.Name or "Info")
		head.Size = UDim2.new(1, -20, 0, 24)
		local vals, obj = {}, {}
		for i, r in ipairs(rows) do
			local k = label(row, tostring(r[1]), 10, C.Dim, false)
			k.Position, k.Size = UDim2.new(0, 10, 0, 26 + (i - 1) * 22), UDim2.new(0.5, -10, 0, 20)
			local v = label(row, tostring(r[2]), 10, C.Text, true)
			v.TextXAlignment, v.Position, v.Size = Enum.TextXAlignment.Right, UDim2.new(0.5, 0, 0, 26 + (i - 1) * 22), UDim2.new(0.5, -10, 0, 20)
			vals[tostring(r[1])] = v
		end
		function obj:Set(k, v)
			if vals[tostring(k)] then
				vals[tostring(k)].Text = tostring(v)
			end
		end
		function obj:Get(k)
			return vals[tostring(k)] and vals[tostring(k)].Text
		end
		return register(self, o, obj, "KeyValue")
	end

	function Tab:Callout(o)
		-- Title, Text, Color: a colored note card with a bar on the left
		o = o or {}
		local win = self.Win
		local col = o.Color or win.Theme.Accent
		local card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = col, BackgroundTransparency = 0.85, BorderSizePixel = 0, LayoutOrder = self:_next() }, self.Page)
		corner(card, 8)
		local bar = new("Frame", { Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = col, BorderSizePixel = 0 }, card)
		corner(bar, 2)
		local inner = new("Frame", { Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -24, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, card)
		new("UIListLayout", { Padding = UDim.new(0, 2) }, inner)
		new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }, inner)
		local t = label(inner, tostring(o.Title or "Note"), 12, col, true)
		t.Size, t.LayoutOrder = UDim2.new(1, 0, 0, 16), 1
		local d = label(inner, tostring(o.Text or ""), 10, C.Text, false)
		d.Size, d.AutomaticSize, d.TextWrapped, d.TextTruncate, d.LayoutOrder = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y, true, Enum.TextTruncate.None, 2
		local obj = {}
		function obj:Set(title, text)
			t.Text, d.Text = tostring(title or t.Text), tostring(text or d.Text)
		end
		return register(self, o, obj, "Callout")
	end

	function Tab:Tasks(o)
		-- Name, Items = { "Do A", "Do B" }, Callback(done, total): a to-do list with a progress bar. obj:Get() = done count
		o = o or {}
		local win, items = self.Win, o.Items or {}
		local row, head = rowOf(self, 40 + #items * 26, o.Name or "Tasks")
		head.Size = UDim2.new(1, -20, 0, 24)
		local bg = new("Frame", { Position = UDim2.new(0, 10, 0, 26), Size = UDim2.new(1, -20, 0, 5), BorderSizePixel = 0 }, row)
		corner(bg, 3)
		win:_bind(bg, "BackgroundColor3", "Inset")
		local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0 }, bg)
		corner(fill, 3)
		win:_bind(fill, "BackgroundColor3", "Accent")
		local obj, done, ls = {}, {}, {}
		local function render()
			local n = 0
			for i, l in ipairs(ls) do
				l.TextColor3 = done[i] and C.Dim or C.Text
				l.Text = (done[i] and "[x]  " or "[  ]  ") .. tostring(items[i])
				n += done[i] and 1 or 0
			end
			tween(fill, 0.25, { Size = UDim2.new(#items > 0 and n / #items or 0, 0, 1, 0) })
			return n
		end
		function obj:Set(i, v)
			if ls[i] then
				done[i] = v and true or false
				safe(o.Callback, render(), #items)
			end
		end
		function obj:Get()
			local n = 0
			for i = 1, #items do
				n += done[i] and 1 or 0
			end
			return n
		end
		for i = 1, #items do
			local b = new("TextButton", { Position = UDim2.new(0, 10, 0, 36 + (i - 1) * 26), Size = UDim2.new(1, -20, 0, 24), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, row)
			local l = label(b, "", 11, C.Text, false)
			l.Size = UDim2.fromScale(1, 1)
			ls[i] = l
			b.MouseButton1Click:Connect(function()
				win:_playClick()
				obj:Set(i, not done[i])
			end)
		end
		render()
		return register(self, o, obj, "Tasks")
	end

	function Tab:ColorInput(o)
		-- Name, Default = "#E94B35", Callback(Color3): type a hex color and see it. obj:Get() = Color3
		o = o or {}
		local win = self.Win
		local row = self:_row(40)
		local nm = label(row, o.Name or "Hex color", 11, C.Text, true)
		nm.Position, nm.Size = UDim2.new(0, 10, 0, 0), UDim2.new(0.4, 0, 1, 0)
		local sw = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(26, 26), BorderSizePixel = 0 }, row)
		corner(sw, 7)
		local box = new("TextBox", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -44, 0.5, 0), Size = UDim2.fromOffset(86, 26), BorderSizePixel = 0, Font = Enum.Font.Code, TextSize = 11, TextColor3 = C.Text, ClearTextOnFocus = false, Text = "" }, row)
		corner(box, 7)
		win:_bind(box, "BackgroundColor3", "Inset")
		local obj, cur = {}, Color3.new(1, 1, 1)
		local function parse(s)
			s = tostring(s or ""):gsub("#", "")
			if #s == 3 then
				s = s:gsub(".", "%0%0")
			end
			if #s ~= 6 or s:find("%X") then
				return nil
			end
			return Color3.fromRGB(tonumber(s:sub(1, 2), 16), tonumber(s:sub(3, 4), 16), tonumber(s:sub(5, 6), 16))
		end
		function obj:Set(s, silent)
			local c = typeof(s) == "Color3" and s or parse(s)
			if not c then
				return false
			end
			cur = c
			sw.BackgroundColor3 = c
			box.Text = string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
			if not silent then
				safe(o.Callback, c)
			end
			return true
		end
		function obj:Get()
			return cur
		end
		box.FocusLost:Connect(function()
			if not obj:Set(box.Text) then
				obj:Set(cur, true)
			end
		end)
		obj:Set(o.Default or "#E94B35", true)
		return register(self, o, obj, "ColorInput")
	end

	-- ---------------------------------------------------------------- window
	function Window:ListTabs()
		local out = {}
		for _, t in ipairs(self._tabs) do
			out[#out + 1] = t.Name
		end
		return out
	end

	function Window:GoTo(nameOrIndex)
		-- Win:GoTo("Settings") or Win:GoTo(2): opens that tab
		local t = type(nameOrIndex) == "number" and self._tabs[nameOrIndex]
		if not t then
			for _, x in ipairs(self._tabs) do
				if x.Name == nameOrIndex then
					t = x
					break
				end
			end
		end
		if t and t.Select then
			t:Select()
			return true
		end
		return false
	end

	do -- OnOpen / OnClose: events fired by Win:Toggle
		local oldToggle = Window.Toggle
		function Window:Toggle(state)
			oldToggle(self, state)
			for _, fn in ipairs(self.Open and (self._onOpen or {}) or (self._onClose or {})) do
				safe(fn, self.Open)
			end
		end
		function Window:OnOpen(fn)
			self._onOpen = self._onOpen or {}
			table.insert(self._onOpen, fn)
		end
		function Window:OnClose(fn)
			self._onClose = self._onClose or {}
			table.insert(self._onClose, fn)
		end
	end

	function Window:Every(seconds, fn)
		-- Win:Every(1, function() ... end): runs again and again until the panel is destroyed. Returns a function that stops it
		local on = true
		local win = self
		task.spawn(function()
			while on and not win._dead and win.Gui and win.Gui.Parent do
				safe(fn)
				task.wait(math.max(tonumber(seconds) or 1, 0.05))
			end
		end)
		return function()
			on = false
		end
	end

	function Window:CycleTheme()
		local list = RebelUI.Themes
		local at = table.find(list, self.ThemeName or "Red") or 0
		local nxt = list[(at % #list) + 1]
		self:SetTheme(nxt)
		return nxt
	end

	function Window:RandomTheme()
		local list = RebelUI.Themes
		local pick = list[math.random(1, #list)]
		self:SetTheme(pick)
		return pick
	end

	local function burst(win, x, y, color, count, dist, size)
		for i = 1, count do
			local ang = (i / count) * math.pi * 2 + math.random() * 0.3
			local d = dist * (0.6 + math.random() * 0.5)
			local p = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(size, size), BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 96, Active = false }, win.Gui)
			corner(p, size)
			tween(p, 0.8 + math.random() * 0.3, { Position = UDim2.fromOffset(x + math.cos(ang) * d, y + math.sin(ang) * d + 20), BackgroundTransparency = 1, Size = UDim2.fromOffset(1, 1) })
			task.delay(1.3, function()
				p:Destroy()
			end)
		end
	end
	local function screenSize(win)
		local s = Vector2.new(800, 450)
		pcall(function()
			s = win.Gui.AbsoluteSize
		end)
		if s.X < 50 then
			s = Vector2.new(800, 450)
		end
		return s
	end

	function Window:Fireworks(count)
		-- Win:Fireworks(5): colored bursts at random places on the screen
		if self.ReduceMotion then
			return
		end
		local s = screenSize(self)
		local cols = { Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 200, 60), Color3.fromRGB(80, 200, 255), Color3.fromRGB(120, 255, 140), Color3.fromRGB(220, 120, 255) }
		for i = 1, math.clamp(count or 4, 1, 12) do
			task.delay((i - 1) * 0.3, function()
				if self.Gui and self.Gui.Parent then
					burst(self, s.X * (0.15 + math.random() * 0.7), s.Y * (0.15 + math.random() * 0.5), cols[math.random(1, #cols)], 16, 90, 5)
				end
			end)
		end
	end

	function Window:Sparkle(target)
		-- little sparkles pop around an element (Win:Sparkle(element))
		local row = type(target) == "table" and target.Row or target
		if not row or not row.Parent or self.ReduceMotion then
			return false
		end
		local p, s = row.AbsolutePosition, row.AbsoluteSize
		local cx, cy = p.X + s.X / 2, p.Y + s.Y / 2
		burst(self, cx, cy, self.Theme.Glow, 12, math.max(s.X, 60) * 0.35, 4)
		return true
	end

	function Window:RippleAt(x, y, color)
		-- a ring grows from a screen point
		if self.ReduceMotion then
			return
		end
		local r = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(8, 8), BackgroundTransparency = 1, ZIndex = 96, Active = false }, self.Gui)
		corner(r, 200)
		local st = new("UIStroke", { Color = color or self.Theme.Glow, Thickness = 3 }, r)
		tween(r, 0.7, { Size = UDim2.fromOffset(160, 160) })
		tween(st, 0.7, { Transparency = 1 })
		task.delay(0.8, function()
			r:Destroy()
		end)
	end

	function Window:Achievement(o)
		-- Title, Text, Icon, Duration: a gold card slides in from the right like a game achievement
		if type(o) == "string" then
			o = { Title = o }
		end
		o = o or {}
		local gold = Color3.fromRGB(255, 200, 60)
		local card = new("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 300, 1, -20), Size = UDim2.fromOffset(250, 56), BackgroundColor3 = Color3.fromRGB(24, 22, 16), BorderSizePixel = 0, ZIndex = 97 }, self.Gui)
		corner(card, 10)
		new("UIStroke", { Color = gold, Thickness = 1.5 }, card)
		local x = 12
		if o.Icon then
			new("ImageLabel", { Position = UDim2.fromOffset(8, 8), Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 1, Image = asset(o.Icon), ZIndex = 98 }, card)
			x = 56
		end
		local t = label(card, tostring(o.Title or "Achievement unlocked"), 12, gold, true)
		t.Position, t.Size, t.ZIndex = UDim2.fromOffset(x, 8), UDim2.new(1, -x - 8, 0, 18), 98
		local d = label(card, tostring(o.Text or ""), 10, C.Text, false)
		d.Position, d.Size, d.ZIndex = UDim2.fromOffset(x, 28), UDim2.new(1, -x - 8, 0, 18), 98
		tween(card, 0.5, { Position = UDim2.new(1, -16, 1, -20) }, Enum.EasingStyle.Back)
		task.delay(o.Duration or 4, function()
			tween(card, 0.4, { Position = UDim2.new(1, 300, 1, -20) })
			task.wait(0.45)
			card:Destroy()
		end)
		return card
	end

	function Window:ShowShortcuts(list)
		-- Win:ShowShortcuts({ { "Ctrl+K", "Command palette" }, { "RightShift", "Hide the panel" } })
		local lines = {}
		for _, r in ipairs(list or { { "RightShift", "Hide or show the panel" }, { "Ctrl+K", "Command palette" } }) do
			lines[#lines + 1] = tostring(r[1]) .. "   -   " .. tostring(r[2])
		end
		self:Dialog({ Title = "Shortcuts", Text = table.concat(lines, "\n"), Buttons = { { Name = "Close" } } })
	end

	function Window:CopyReport()
		-- copies a support report (library version, executor, tabs, last errors) so players can paste it to you
		local ex = "unknown"
		pcall(function()
			if type(identifyexecutor) == "function" then
				ex = tostring((identifyexecutor()))
			end
		end)
		local lines = { "RebelUI " .. tostring(RebelUI.Version), "Executor: " .. ex, "Theme: " .. tostring(self.ThemeName), "Tabs: " .. table.concat(self:ListTabs(), ", "), "Errors: " .. #RebelUI.Errors }
		for i = math.max(#RebelUI.Errors - 4, 1), #RebelUI.Errors do
			local e = RebelUI.Errors[i]
			lines[#lines + 1] = "  " .. tostring(type(e) == "table" and (e.Where or "") .. " " .. tostring(e.Error or e.Err or "") or e)
		end
		local text = table.concat(lines, "\n")
		if type(setclipboard) == "function" then
			pcall(setclipboard, text)
		end
		return text
	end

	do -- fonts and text size for the whole panel
		local FAM = {
			Gotham = { Enum.Font.Gotham, Enum.Font.GothamBold, Enum.Font.GothamBlack },
			Ubuntu = { Enum.Font.Ubuntu, Enum.Font.Ubuntu, Enum.Font.Ubuntu },
			SourceSans = { Enum.Font.SourceSans, Enum.Font.SourceSansBold, Enum.Font.SourceSansBold },
			Arial = { Enum.Font.Arial, Enum.Font.ArialBold, Enum.Font.ArialBold },
		}
		local function texts(win)
			local out = {}
			for _, d in ipairs(win.Gui:GetDescendants()) do
				if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
					out[#out + 1] = d
				end
			end
			return out
		end
		function Window:SetFont(family)
			-- "Gotham" (default) | "Ubuntu" | "SourceSans" | "Arial": changes the font of everything that is on screen now
			local f = FAM[family]
			if not f then
				return false
			end
			for _, d in ipairs(texts(self)) do
				local nm = tostring(d.Font)
				if not nm:find("Code") then
					d.Font = (nm:find("Black") and f[3]) or (nm:find("Bold") and f[2]) or f[1]
				end
			end
			return true
		end
		function Window:SetTextScale(scale)
			-- 0.8 to 1.6: makes all text smaller or bigger (good for small phones or tired eyes). 1 = normal
			scale = math.clamp(tonumber(scale) or 1, 0.8, 1.6)
			self._baseText = self._baseText or setmetatable({}, { __mode = "k" })
			for _, d in ipairs(texts(self)) do
				local base = self._baseText[d]
				if not base then
					base = tonumber(d.TextSize) or 14
					self._baseText[d] = base
				end
				d.TextSize = math.max(math.floor(base * scale + 0.5), 6)
			end
			self.TextScale = scale
			return scale
		end
	end

	function Window:Konami(fn)
		-- up up down down left right left right B A anywhere: runs your function (a secret!). Returns a function that removes it
		local seq = { Enum.KeyCode.Up, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.B, Enum.KeyCode.A }
		local at = 1
		local c = game:GetService("UserInputService").InputBegan:Connect(function(input)
			if input.KeyCode == seq[at] then
				at += 1
				if at > #seq then
					at = 1
					safe(fn)
				end
			else
				at = input.KeyCode == seq[1] and 2 or 1
			end
		end)
		return function()
			c:Disconnect()
		end
	end

	function Window:IdleDim(seconds, pct)
		-- Win:IdleDim(10, 40): after 10 seconds without touching, the panel becomes 40% solid; touching it brings it back. Win:IdleDim(nil) turns it off
		self._idleGen = (self._idleGen or 0) + 1
		local my, win = self._idleGen, self
		if not seconds then
			win:SetOpacity(win.Opacity or 100)
			return
		end
		local base = win.Opacity or 100
		local last, dimmed = os.clock(), false
		local uis = game:GetService("UserInputService")
		local function touch()
			last = os.clock()
			if dimmed then
				dimmed = false
				win:SetOpacity(base)
			end
		end
		local a = uis.InputBegan:Connect(touch)
		local b = uis.InputChanged:Connect(touch)
		task.spawn(function()
			while win._idleGen == my and win.Gui and win.Gui.Parent do
				if not dimmed and os.clock() - last >= seconds then
					dimmed = true
					base = win.Opacity or 100
					win:SetOpacity(pct or 40)
				end
				task.wait(1)
			end
			a:Disconnect()
			b:Disconnect()
		end)
	end
end

-- ================================================================ library helpers
function RebelUI.Debounce(fn, wait)
	-- UI.Debounce(fn, 0.5): fn runs only after 0.5 seconds with no new calls
	local gen = 0
	return function(...)
		gen += 1
		local my, args = gen, table.pack(...)
		task.delay(wait or 0.3, function()
			if gen == my then
				safe(fn, table.unpack(args, 1, args.n))
			end
		end)
	end
end

function RebelUI.Throttle(fn, interval)
	-- UI.Throttle(fn, 1): fn runs at most once per second
	local last = -math.huge
	return function(...)
		if os.clock() - last >= (interval or 0.3) then
			last = os.clock()
			return fn(...)
		end
	end
end

function RebelUI.FormatNumber(n, decimals)
	-- UI.FormatNumber(1234567) = "1,234,567"   (UI.FormatNumber(1234.5, 1) = "1,234.5")
	n = tonumber(n) or 0
	local s = string.format("%." .. (type(decimals) == "number" and decimals or 0) .. "f", n)
	local int, rest = s:match("^(-?%d+)(.*)$")
	int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""):gsub("^%-,", "-")
	return int .. rest
end

function RebelUI.Short(n)
	-- UI.Short(1500000) = "1.5M", UI.Short(12000) = "12K"
	n = tonumber(n) or 0
	local a = math.abs(n)
	local function f(v, suf)
		local s = string.format("%.1f", v):gsub("%.0$", "")
		return s .. suf
	end
	if a >= 1e9 then
		return f(n / 1e9, "B")
	elseif a >= 1e6 then
		return f(n / 1e6, "M")
	elseif a >= 1e3 then
		return f(n / 1e3, "K")
	end
	return tostring(math.floor(n))
end

function RebelUI:Info()
	-- UI:Info(): how many things this version has (elements, window tools)
	local e, w = {}, {}
	for k, v in pairs(Tab) do
		if type(v) == "function" and k:sub(1, 1) ~= "_" then
			e[#e + 1] = k
		end
	end
	for k, v in pairs(Window) do
		if type(v) == "function" and k:sub(1, 1) ~= "_" then
			w[#w + 1] = k
		end
	end
	table.sort(e)
	table.sort(w)
	return { Version = RebelUI.Version, Elements = #e, WindowTools = #w, ElementNames = e, WindowNames = w }
end

function RebelUI:SelfTest()
	-- UI:SelfTest(): builds a hidden test panel with the main elements and tells you what works on THIS executor. Returns { Passed, Failed, Report }
	local win
	local report, passed, failed = {}, 0, 0
	local function step(name, fn)
		local ok, err = pcall(fn)
		if ok then
			passed += 1
			report[#report + 1] = "ok    " .. name
		else
			failed += 1
			report[#report + 1] = "FAIL  " .. name .. " : " .. tostring(err)
		end
	end
	local tab
	step("CreateWindow", function()
		win = RebelUI:CreateWindow({ Title = "RebelUI self test", Name = "RebelSelfTest" })
		win.Gui.Enabled = false
	end)
	if win then
		step("CreateTab", function() tab = win:CreateTab({ Name = "Test" }) end)
		if tab then
			local list = {
				{ "Toggle", { Name = "t" } }, { "Slider", { Name = "s", Min = 0, Max = 10, Default = 1 } }, { "Button", { Name = "b" } },
				{ "Dropdown", { Name = "d", Options = { "a", "b" } } }, { "Input", { Name = "i" } }, { "Keybind", { Name = "k" } },
				{ "Label", "label" }, { "Paragraph", { Text = "p" } }, { "Divider" }, { "Stepper", { Name = "st", Min = 0, Max = 5 } },
				{ "Rating", { Name = "r" } }, { "Progress", { Name = "pr" } }, { "Notice", { Text = "n" } }, { "Radio", { Name = "r", Options = { "a" } } },
				{ "Counter", { Name = "c" } }, { "Poll", { Question = "q", Options = { "a", "b" } } }, { "Table", { Columns = { "a" }, Rows = { { 1 } } } },
			}
			for _, it in ipairs(list) do
				step("Tab:" .. it[1], function()
					tab[it[1]](tab, it[2])
				end)
			end
		end
		step("Notify", function() win:Notify({ Title = "test", Duration = 0.5 }) end)
		step("SetTheme", function() win:SetTheme("Blue"); win:SetTheme("Red") end)
		step("Save / Load flags", function() win:GetActions() end)
		step("Destroy", function() win:Destroy() end)
	end
	local out = { Passed = passed, Failed = failed, Report = table.concat(report, "\n") }
	print("[RebelUI self test] passed " .. passed .. ", failed " .. failed)
	if failed > 0 then
		print(out.Report)
	end
	return out
end

return RebelUI
