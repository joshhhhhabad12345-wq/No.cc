--[[
╔══════════════════════════════════════════════════════════════════╗
║                         ✦  AuraUI  ✦                            ║
║          A Gorgeous Mobile-First Roblox UI Library              ║
║                                                                  ║
║  Components:  Window · Section · Button · Slider                 ║
║               Toggle · Label · Paragraph · Divider               ║
║               Badge · Input · Notification                       ║
╚══════════════════════════════════════════════════════════════════╝

   USAGE EXAMPLE (at bottom of file)
--]]

local AuraUI = {}
AuraUI.__index = AuraUI

-- ─────────────────────────────────────────────
--  ✦  THEME  ✦
-- ─────────────────────────────────────────────
local Theme = {
	-- Surfaces
	BG           = Color3.fromRGB(8,   8,  16),   -- deep navy-black
	Surface      = Color3.fromRGB(14,  15,  28),  -- card surface
	SurfaceAlt   = Color3.fromRGB(20,  22,  40),  -- elevated card
	Border       = Color3.fromRGB(40,  44,  80),  -- subtle border
	BorderBright = Color3.fromRGB(70,  80, 160),  -- hover border

	-- Accents
	Accent       = Color3.fromRGB(120,  80, 255),  -- vivid violet
	AccentSoft   = Color3.fromRGB( 80,  50, 180),  -- muted violet
	AccentGlow   = Color3.fromRGB(160, 110, 255),  -- bright glow
	AccentPink   = Color3.fromRGB(220,  80, 160),  -- hot pink accent
	AccentTeal   = Color3.fromRGB( 40, 200, 180),  -- teal accent
	AccentAmber  = Color3.fromRGB(255, 180,  40),  -- amber

	-- Text
	TextPrimary  = Color3.fromRGB(240, 240, 255),
	TextSecond   = Color3.fromRGB(150, 150, 200),
	TextMuted    = Color3.fromRGB( 80,  85, 130),

	-- State
	Success      = Color3.fromRGB( 60, 220, 120),
	Warning      = Color3.fromRGB(255, 190,  40),
	Danger       = Color3.fromRGB(255,  70,  90),
	Info         = Color3.fromRGB( 60, 180, 255),

	-- Tweens
	Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Medium = TweenInfo.new(0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Slow   = TweenInfo.new(0.50, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	Spring = TweenInfo.new(0.45, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

-- ─────────────────────────────────────────────
--  ✦  INTERNAL HELPERS  ✦
-- ─────────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function lerp(a, b, t) return a + (b - a) * t end

local function roundCorner(obj, radius)
	local uic = Instance.new("UICorner")
	uic.CornerRadius = UDim.new(0, radius)
	uic.Parent = obj
	return uic
end

local function addStroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Border
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end

local function addPadding(obj, top, right, bottom, left)
	local p = Instance.new("UIPadding")
	p.PaddingTop    = UDim.new(0, top    or 0)
	p.PaddingRight  = UDim.new(0, right  or 0)
	p.PaddingBottom = UDim.new(0, bottom or 0)
	p.PaddingLeft   = UDim.new(0, left   or 0)
	p.Parent = obj
	return p
end

local function makeList(obj, padding, fillDir)
	local ul = Instance.new("UIListLayout")
	ul.Padding = UDim.new(0, padding or 8)
	ul.FillDirection = fillDir or Enum.FillDirection.Vertical
	ul.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ul.SortOrder = Enum.SortOrder.LayoutOrder
	ul.Parent = obj
	return ul
end

local function frame(props)
	local f = Instance.new("Frame")
	for k, v in pairs(props) do
		if k ~= "Parent" then f[k] = v end
	end
	f.BorderSizePixel = 0
	if props.Parent then f.Parent = props.Parent end
	return f
end

local function label(props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.BorderSizePixel = 0
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.RichText = true
	for k, v in pairs(props) do
		if k ~= "Parent" then l[k] = v end
	end
	if props.Parent then l.Parent = props.Parent end
	return l
end

local function button(props)
	local b = Instance.new("TextButton")
	b.BackgroundTransparency = 1
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	for k, v in pairs(props) do
		if k ~= "Parent" then b[k] = v end
	end
	if props.Parent then b.Parent = props.Parent end
	return b
end

-- Glow UIGradient inside a frame
local function applyGradient(obj, c0, c1, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, c0),
		ColorSequenceKeypoint.new(1, c1),
	})
	g.Rotation = rotation or 90
	g.Parent = obj
	return g
end

-- Auto-resize list container
local function autoresize(obj, ul, padding)
	ul:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		obj.Size = UDim2.new(1, 0, 0, ul.AbsoluteContentSize.Y + (padding or 0))
	end)
end

-- ─────────────────────────────────────────────
--  ✦  NOTIFICATION SYSTEM  ✦
-- ─────────────────────────────────────────────
local NotifHolder

local function ensureNotifHolder(screenGui)
	if NotifHolder and NotifHolder.Parent then return NotifHolder end
	NotifHolder = frame{
		Name = "AuraNotifHolder",
		Size = UDim2.new(0, 320, 1, 0),
		Position = UDim2.new(1, -330, 0, 0),
		BackgroundTransparency = 1,
		Parent = screenGui,
	}
	local ul = makeList(NotifHolder, 10)
	ul.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ul.HorizontalAlignment = Enum.HorizontalAlignment.Right
	addPadding(NotifHolder, 10, 10, 10, 0)
	return NotifHolder
end

function AuraUI:Notify(opts)
	opts = opts or {}
	local title   = opts.Title   or "Notification"
	local desc    = opts.Desc    or ""
	local accent  = opts.Color   or Theme.Accent
	local dur     = opts.Duration or 4

	local holder = ensureNotifHolder(self._gui)

	local card = frame{
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundColor3 = Theme.SurfaceAlt,
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		Parent = holder,
	}
	roundCorner(card, 14)
	addStroke(card, accent, 1, 0.4)

	-- Colored left bar
	local bar = frame{
		Size = UDim2.new(0, 4, 1, 0),
		BackgroundColor3 = accent,
		Parent = card,
	}
	roundCorner(bar, 2)

	-- Glow overlay
	local glow = frame{
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.88,
		Parent = card,
	}

	local tl = label{
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 14, 0, 12),
		Text = title,
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Parent = card,
	}
	local dl = label{
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 14, 0, 34),
		Text = desc,
		TextColor3 = Theme.TextSecond,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		Parent = card,
	}

	-- Progress bar at bottom
	local prog = frame{
		Size = UDim2.new(1, 0, 0, 3),
		Position = UDim2.new(0, 0, 1, -3),
		BackgroundColor3 = accent,
		Parent = card,
	}
	roundCorner(prog, 2)

	-- Slide in
	card.Position = UDim2.new(1, 10, 0, 0)
	tween(card, Theme.Spring, {Position = UDim2.new(0, 0, 0, 0)})

	-- Drain progress
	tween(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})

	task.delay(dur, function()
		tween(card, Theme.Medium, {Position = UDim2.new(1, 10, 0, 0)})
		task.wait(0.35)
		card:Destroy()
	end)
end

-- ─────────────────────────────────────────────
--  ✦  WINDOW  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateWindow(opts)
	opts = opts or {}
	local title    = opts.Title   or "AuraUI"
	local subtitle = opts.Subtitle or "Interface"
	local width    = opts.Width    or 360
	local accentC  = opts.Accent   or Theme.Accent

	-- ScreenGui
	local sg = Instance.new("ScreenGui")
	sg.Name = "AuraUI_" .. title
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.DisplayOrder = 999
	sg.IgnoreGuiInset = true
	sg.Parent = game:GetService("CoreGui")
	self._gui = sg

	-- Backdrop blur vignette
	local vignette = frame{
		Size = UDim2.new(1,0,1,0),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		BackgroundTransparency = 0.55,
		Parent = sg,
	}

	-- Main container (centered, scrollable)
	local container = frame{
		Name = "Container",
		Size = UDim2.new(0, width, 1, 0),
		Position = UDim2.new(0.5, -width/2, 0, 0),
		BackgroundColor3 = Theme.BG,
		ClipsDescendants = true,
		Parent = sg,
	}

	-- Subtle background gradient
	applyGradient(container, Theme.BG, Color3.fromRGB(10, 8, 22), 170)

	-- Top decorative glow strip
	local topGlow = frame{
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = accentC,
		BackgroundTransparency = 0,
		Parent = container,
	}
	applyGradient(topGlow,
		Color3.fromRGB(accentC.R*255, accentC.G*255, accentC.B*255),
		Theme.AccentPink,
		0)

	-- Header
	local header = frame{
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 90),
		Position = UDim2.new(0, 0, 0, 2),
		BackgroundColor3 = Theme.Surface,
		Parent = container,
	}
	applyGradient(header, Theme.Surface, Color3.fromRGB(16, 14, 36), 160)

	-- Header bottom separator
	local sep = frame{
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Theme.Border,
		Parent = header,
	}

	-- Decorative orb behind title
	local orb = frame{
		Size = UDim2.new(0, 120, 0, 120),
		Position = UDim2.new(0, -30, 0, -30),
		BackgroundColor3 = accentC,
		BackgroundTransparency = 0.82,
		Parent = header,
	}
	roundCorner(orb, 60)

	-- Title
	local titleLabel = label{
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 18, 0, 22),
		Text = title,
		TextColor3 = Theme.TextPrimary,
		TextSize = 22,
		Font = Enum.Font.GothamBlack,
		Parent = header,
	}

	-- Subtitle
	local subLabel = label{
		Size = UDim2.new(1, -20, 0, 18),
		Position = UDim2.new(0, 18, 0, 54),
		Text = subtitle,
		TextColor3 = Theme.TextMuted,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		Parent = header,
	}

	-- Accent badge top-right
	local badgeFrame = frame{
		Size = UDim2.new(0, 52, 0, 22),
		Position = UDim2.new(1, -62, 0, 20),
		BackgroundColor3 = accentC,
		BackgroundTransparency = 0.75,
		Parent = header,
	}
	roundCorner(badgeFrame, 11)
	addStroke(badgeFrame, accentC, 1, 0.3)
	label{
		Size = UDim2.new(1,0,1,0),
		Text = "AURA",
		TextColor3 = Theme.AccentGlow,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = badgeFrame,
	}

	-- ScrollingFrame
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.Size = UDim2.new(1, 0, 1, -93)
	scroll.Position = UDim2.new(0, 0, 0, 93)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = accentC
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = container

	local contentList = Instance.new("UIListLayout")
	contentList.Padding = UDim.new(0, 0)
	contentList.FillDirection = Enum.FillDirection.Vertical
	contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	contentList.SortOrder = Enum.SortOrder.LayoutOrder
	contentList.Parent = scroll

	addPadding(scroll, 10, 14, 20, 14)

	-- Entrance animation
	container.Position = UDim2.new(0.5, -width/2, 0, -30)
	container.BackgroundTransparency = 1
	tween(container, Theme.Spring, {
		Position = UDim2.new(0.5, -width/2, 0, 0),
		BackgroundTransparency = 0,
	})

	-- Window object
	local win = setmetatable({
		_scroll   = scroll,
		_list     = contentList,
		_gui      = sg,
		_accent   = accentC,
		_order    = 0,
	}, AuraUI)

	return win
end

-- ─────────────────────────────────────────────
--  ✦  SECTION  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateSection(opts)
	opts = opts or {}
	local title   = opts.Title  or "Section"
	local icon    = opts.Icon   or "✦"
	local accent  = opts.Accent or self._accent or Theme.Accent

	self._order += 1

	-- Section header row
	local headerRow = frame{
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		Parent = self._scroll,
	}

	-- Icon pip
	local pip = frame{
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(0, 0, 0.5, -14),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.78,
		Parent = headerRow,
	}
	roundCorner(pip, 8)
	addStroke(pip, accent, 1, 0.4)
	label{
		Size = UDim2.new(1,0,1,0),
		Text = icon,
		TextColor3 = accent,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = pip,
	}

	label{
		Size = UDim2.new(1, -38, 1, 0),
		Position = UDim2.new(0, 36, 0, 0),
		Text = string.upper(title),
		TextColor3 = accent,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = headerRow,
	}

	-- Section card container
	self._order += 1
	local card = frame{
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Theme.Surface,
		LayoutOrder = self._order,
		ClipsDescendants = false,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self._scroll,
	}
	roundCorner(card, 16)
	addStroke(card, Theme.Border, 1, 0)

	-- Inner list
	local inner = frame{
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	}
	local innerList = makeList(inner, 0)
	addPadding(inner, 6, 0, 6, 0)

	-- Spacer after card
	self._order += 1
	local spacer = frame{
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		Parent = self._scroll,
	}

	local sec = setmetatable({
		_card   = card,
		_inner  = inner,
		_list   = innerList,
		_accent = accent,
		_order  = 0,
		-- inherit window methods
		_scroll = self._scroll,
	}, AuraUI)
	sec._winorder = self
	return sec
end

-- ─────────────────────────────────────────────
--  ✦  ROW BASE  ✦
-- ─────────────────────────────────────────────
local function makeRow(parent, extraHeight)
	local row = frame{
		Size = UDim2.new(1, 0, 0, 52 + (extraHeight or 0)),
		BackgroundTransparency = 1,
		Parent = parent,
	}

	-- Hover effect
	local hover = frame{
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 1,
		ZIndex = 0,
		Parent = row,
	}
	roundCorner(hover, 12)

	row.MouseEnter:Connect(function()
		tween(hover, Theme.Fast, {BackgroundTransparency = 0.96})
	end)
	row.MouseLeave:Connect(function()
		tween(hover, Theme.Fast, {BackgroundTransparency = 1})
	end)

	-- Divider at bottom
	local div = frame{
		Size = UDim2.new(1, -16, 0, 1),
		Position = UDim2.new(0, 8, 1, -1),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.4,
		Parent = row,
	}

	return row, div
end

-- ─────────────────────────────────────────────
--  ✦  LABEL  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateLabel(opts)
	opts = opts or {}
	local text   = opts.Text   or "Label"
	local size   = opts.Size   or 14
	local color  = opts.Color  or Theme.TextPrimary
	local accent = opts.Accent or self._accent or Theme.Accent

	self._order = (self._order or 0) + 1
	local row, div = makeRow(self._inner, 0)
	row.LayoutOrder = self._order

	-- Left icon strip
	local strip = frame{
		Size = UDim2.new(0, 3, 0, 24),
		Position = UDim2.new(0, 12, 0.5, -12),
		BackgroundColor3 = accent,
		Parent = row,
	}
	roundCorner(strip, 2)

	label{
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 24, 0, 0),
		Text = text,
		TextColor3 = color,
		TextSize = size,
		Font = Enum.Font.GothamMedium,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
		Parent = row,
	}
end

-- ─────────────────────────────────────────────
--  ✦  PARAGRAPH  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateParagraph(opts)
	opts = opts or {}
	local heading = opts.Title or "Title"
	local body    = opts.Body  or "Body text goes here."
	local accent  = opts.Accent or self._accent or Theme.Accent

	self._order = (self._order or 0) + 1
	local row = frame{
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self._order,
		Parent = self._inner,
	}
	addPadding(row, 14, 14, 14, 14)

	local innerList = makeList(row, 6)

	local hdr = label{
		Size = UDim2.new(1, 0, 0, 18),
		Text = heading,
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Parent = row,
	}

	local bodyL = label{
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = body,
		TextColor3 = Theme.TextSecond,
		TextSize = 13,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		LineHeight = 1.45,
		Parent = row,
	}

	-- Divider
	local div = frame{
		Size = UDim2.new(1, -28, 0, 1),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.4,
		Parent = self._inner,
		LayoutOrder = self._order + 0.5,
	}
	roundCorner(div, 1)
end

-- ─────────────────────────────────────────────
--  ✦  DIVIDER  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateDivider(opts)
	opts = opts or {}
	local text   = opts.Text
	local accent = opts.Accent or self._accent or Theme.Accent

	self._order = (self._order or 0) + 1

	local row = frame{
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		Parent = self._inner,
	}

	if text then
		local mid = label{
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Position = UDim2.new(0.5, 0, 0, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			Text = "  " .. text .. "  ",
			TextColor3 = Theme.TextMuted,
			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Parent = row,
		}
		local lineL = frame{
			Size = UDim2.new(0.4, -20, 0, 1),
			Position = UDim2.new(0, 12, 0.5, 0),
			BackgroundColor3 = Theme.Border,
			Parent = row,
		}
		local lineR = frame{
			Size = UDim2.new(0.4, -20, 0, 1),
			Position = UDim2.new(0.6, 8, 0.5, 0),
			BackgroundColor3 = Theme.Border,
			Parent = row,
		}
	else
		local line = frame{
			Size = UDim2.new(1, -28, 0, 1),
			Position = UDim2.new(0, 14, 0.5, 0),
			BackgroundColor3 = Theme.Border,
			Parent = row,
		}
		applyGradient(line, Color3.fromRGB(0,0,0), accent, 0)
	end
end

-- ─────────────────────────────────────────────
--  ✦  BADGE  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateBadge(opts)
	opts = opts or {}
	local text   = opts.Text   or "NEW"
	local color  = opts.Color  or self._accent or Theme.Accent
	local ltext  = opts.Label  or ""

	self._order = (self._order or 0) + 1
	local row, div = makeRow(self._inner, 0)
	row.LayoutOrder = self._order

	label{
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		Text = ltext,
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = row,
	}

	local badge = frame{
		Size = UDim2.new(0, 0, 0, 24),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(1, -14, 0.5, -12),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.72,
		Parent = row,
	}
	roundCorner(badge, 12)
	addStroke(badge, color, 1, 0.2)

	local bl = label{
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = text,
		TextColor3 = color,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = badge,
	}
	addPadding(bl, 0, 10, 0, 10)
end

-- ─────────────────────────────────────────────
--  ✦  BUTTON  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateButton(opts)
	opts = opts or {}
	local text     = opts.Text     or "Button"
	local desc     = opts.Desc     or ""
	local accent   = opts.Accent   or self._accent or Theme.Accent
	local callback = opts.Callback or function() end
	local style    = opts.Style    or "default" -- "default" | "primary" | "danger"

	self._order = (self._order or 0) + 1

	local isPrimary = (style == "primary")
	local isDanger  = (style == "danger")
	local btnColor  = isDanger and Theme.Danger or accent

	local row = frame{
		Size = UDim2.new(1, 0, 0, 58),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		Parent = self._inner,
	}
	addPadding(row, 6, 12, 6, 12)

	local btn = button{
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = isPrimary and btnColor or Theme.SurfaceAlt,
		BackgroundTransparency = isPrimary and 0 or 0,
		Text = "",
		Parent = row,
	}
	roundCorner(btn, 12)
	addStroke(btn, btnColor, 1, isPrimary and 1 or 0.5)

	if isPrimary then
		applyGradient(btn, btnColor, 
			Color3.fromRGB(
				math.clamp(btnColor.R*255 - 40, 0, 255),
				math.clamp(btnColor.G*255 - 30, 0, 255),
				math.clamp(btnColor.B*255 + 20, 0, 255)
			), 135)
	end

	-- Left text block
	label{
		Size = UDim2.new(1, -50, 0, 18),
		Position = UDim2.new(0, 14, 0, isPrimary and 12 or (desc ~= "" and 10 or 18)),
		Text = text,
		TextColor3 = isPrimary and Color3.fromRGB(255,255,255) or Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = btn,
	}
	if desc ~= "" and not isPrimary then
		label{
			Size = UDim2.new(1, -50, 0, 14),
			Position = UDim2.new(0, 14, 0, 28),
			Text = desc,
			TextColor3 = Theme.TextMuted,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			Parent = btn,
		}
	end

	-- Arrow/icon right
	local arrow = label{
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(1, -36, 0, 0),
		Text = "›",
		TextColor3 = isPrimary and Color3.fromRGB(255,255,255) or btnColor,
		TextSize = 22,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = btn,
	}

	-- Interactions
	btn.MouseButton1Down:Connect(function()
		tween(btn, Theme.Fast, {BackgroundTransparency = isPrimary and 0.2 or 0.85})
		tween(arrow, Theme.Fast, {Position = UDim2.new(1, -30, 0, 0)})
	end)
	btn.MouseButton1Up:Connect(function()
		tween(btn, Theme.Medium, {BackgroundTransparency = isPrimary and 0 or 0})
		tween(arrow, Theme.Spring, {Position = UDim2.new(1, -36, 0, 0)})
		task.spawn(callback)
	end)
	btn.MouseEnter:Connect(function()
		tween(btn, Theme.Fast, {BackgroundTransparency = isPrimary and 0.1 or 0.92})
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, Theme.Fast, {BackgroundTransparency = isPrimary and 0 or 0})
	end)

	-- Divider
	local div = frame{
		Size = UDim2.new(1, -28, 0, 1),
		Position = UDim2.new(0, 14, 1, -1),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.4,
		Parent = row,
	}
end

-- ─────────────────────────────────────────────
--  ✦  TOGGLE  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateToggle(opts)
	opts = opts or {}
	local text     = opts.Text     or "Toggle"
	local desc     = opts.Desc     or ""
	local default  = opts.Default  ~= false
	local accent   = opts.Accent   or self._accent or Theme.Accent
	local callback = opts.Callback or function(_) end

	self._order = (self._order or 0) + 1
	local row, div = makeRow(self._inner, desc ~= "" and 14 or 0)
	row.LayoutOrder = self._order

	local state = default

	label{
		Size = UDim2.new(1, -70, 0, 18),
		Position = UDim2.new(0, 14, 0, desc ~= "" and 10 or 17),
		Text = text,
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Parent = row,
	}
	if desc ~= "" then
		label{
			Size = UDim2.new(1, -70, 0, 14),
			Position = UDim2.new(0, 14, 0, 28),
			Text = desc,
			TextColor3 = Theme.TextMuted,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			Parent = row,
		}
	end

	-- Track
	local track = frame{
		Size = UDim2.new(0, 48, 0, 26),
		Position = UDim2.new(1, -58, 0.5, -13),
		BackgroundColor3 = state and accent or Theme.Border,
		Parent = row,
	}
	roundCorner(track, 13)

	-- Thumb
	local thumb = frame{
		Size = UDim2.new(0, 20, 0, 20),
		Position = state
			and UDim2.new(0, 25, 0.5, -10)
			or  UDim2.new(0,  3, 0.5, -10),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		Parent = track,
	}
	roundCorner(thumb, 10)

	-- Shadow on thumb
	local ts = Instance.new("UIStroke")
	ts.Color = Color3.fromRGB(0,0,0)
	ts.Thickness = 0
	ts.Transparency = 0.6
	ts.Parent = thumb

	local function setToggle(val)
		state = val
		if state then
			tween(track, Theme.Medium, {BackgroundColor3 = accent})
			tween(thumb, Theme.Spring, {Position = UDim2.new(0, 25, 0.5, -10)})
		else
			tween(track, Theme.Medium, {BackgroundColor3 = Theme.Border})
			tween(thumb, Theme.Spring, {Position = UDim2.new(0, 3, 0.5, -10)})
		end
		callback(state)
	end

	local clickBtn = button{
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		Parent = row,
	}
	clickBtn.MouseButton1Click:Connect(function()
		setToggle(not state)
	end)

	return {
		Set = function(_, val) setToggle(val) end,
		Get = function(_) return state end,
	}
end

-- ─────────────────────────────────────────────
--  ✦  SLIDER  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateSlider(opts)
	opts = opts or {}
	local text     = opts.Text     or "Slider"
	local min      = opts.Min      or 0
	local max      = opts.Max      or 100
	local default  = opts.Default  or 50
	local suffix   = opts.Suffix   or ""
	local accent   = opts.Accent   or self._accent or Theme.Accent
	local callback = opts.Callback or function(_) end
	local decimals = opts.Decimals or 0

	self._order = (self._order or 0) + 1
	local row = frame{
		Size = UDim2.new(1, 0, 0, 72),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		Parent = self._inner,
	}

	label{
		Size = UDim2.new(1, -80, 0, 18),
		Position = UDim2.new(0, 14, 0, 10),
		Text = text,
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Parent = row,
	}

	local valLabel = label{
		Size = UDim2.new(0, 64, 0, 18),
		Position = UDim2.new(1, -78, 0, 10),
		Text = tostring(default) .. suffix,
		TextColor3 = accent,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	}

	-- Track container
	local trackContainer = frame{
		Size = UDim2.new(1, -28, 0, 18),
		Position = UDim2.new(0, 14, 0, 40),
		BackgroundTransparency = 1,
		Parent = row,
	}

	-- Track background
	local trackBG = frame{
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0.5, -3),
		BackgroundColor3 = Theme.Border,
		Parent = trackContainer,
	}
	roundCorner(trackBG, 3)

	-- Track fill
	local fillPct = (default - min) / (max - min)
	local trackFill = frame{
		Size = UDim2.new(fillPct, 0, 0, 6),
		Position = UDim2.new(0, 0, 0.5, -3),
		BackgroundColor3 = accent,
		Parent = trackContainer,
	}
	roundCorner(trackFill, 3)
	applyGradient(trackFill, accent, Theme.AccentGlow, 0)

	-- Thumb
	local thumb = frame{
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(fillPct, -9, 0.5, -9),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		Parent = trackContainer,
		ZIndex = 2,
	}
	roundCorner(thumb, 9)
	addStroke(thumb, accent, 2, 0)

	-- Inner dot on thumb
	local dot = frame{
		Size = UDim2.new(0, 6, 0, 6),
		Position = UDim2.new(0.5, -3, 0.5, -3),
		BackgroundColor3 = accent,
		Parent = thumb,
	}
	roundCorner(dot, 3)

	-- Value
	local currentVal = default

	local function fmt(v)
		if decimals > 0 then
			return string.format("%." .. decimals .. "f", v) .. suffix
		end
		return tostring(math.round(v)) .. suffix
	end

	local function updateVal(absX)
		local trackPos = trackContainer.AbsolutePosition.X
		local trackW   = trackContainer.AbsoluteSize.X
		local pct = math.clamp((absX - trackPos) / trackW, 0, 1)
		local raw = min + (max - min) * pct
		local snapped = decimals > 0 and raw or math.round(raw)
		snapped = math.clamp(snapped, min, max)

		if snapped ~= currentVal then
			currentVal = snapped
			valLabel.Text = fmt(snapped)
			tween(trackFill, Theme.Fast, {Size = UDim2.new(pct, 0, 0, 6)})
			tween(thumb, Theme.Fast, {Position = UDim2.new(pct, -9, 0.5, -9)})
			callback(snapped)
		end
	end

	local dragging = false
	local clickArea = button{
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		ZIndex = 3,
		Parent = trackContainer,
	}

	clickArea.MouseButton1Down:Connect(function()
		dragging = true
		tween(thumb, Theme.Fast, {Size = UDim2.new(0, 22, 0, 22), Position = UDim2.new(fillPct, -11, 0.5, -11)})
		updateVal(UserInputService:GetMouseLocation().X)
	end)

	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or
		   inp.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				local pct2 = (currentVal - min) / (max - min)
				tween(thumb, Theme.Spring, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(pct2, -9, 0.5, -9)})
			end
		end
	end)

	UserInputService.InputChanged:Connect(function(inp)
		if dragging then
			if inp.UserInputType == Enum.UserInputType.MouseMovement or
			   inp.UserInputType == Enum.UserInputType.Touch then
				local x = inp.UserInputType == Enum.UserInputType.Touch
					and inp.Position.X
					or UserInputService:GetMouseLocation().X
				updateVal(x)
			end
		end
	end)

	-- Divider
	local div = frame{
		Size = UDim2.new(1, -28, 0, 1),
		Position = UDim2.new(0, 14, 1, -1),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.4,
		Parent = row,
	}

	return {
		Set = function(_, v)
			v = math.clamp(v, min, max)
			currentVal = v
			local pct = (v - min) / (max - min)
			valLabel.Text = fmt(v)
			tween(trackFill, Theme.Fast, {Size = UDim2.new(pct, 0, 0, 6)})
			tween(thumb, Theme.Fast, {Position = UDim2.new(pct, -9, 0.5, -9)})
		end,
		Get = function(_) return currentVal end,
	}
end

-- ─────────────────────────────────────────────
--  ✦  DROPDOWN  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateDropdown(opts)
	opts = opts or {}
	local text     = opts.Text     or "Dropdown"
	local items    = opts.Items    or {"Option 1", "Option 2"}
	local default  = opts.Default  or items[1]
	local accent   = opts.Accent   or self._accent or Theme.Accent
	local callback = opts.Callback or function(_) end

	self._order = (self._order or 0) + 1

	local selected = default
	local open = false

	local wrapper = frame{
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = false,
		Parent = self._inner,
	}

	local headerRow = frame{
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = wrapper,
	}

	label{
		Size = UDim2.new(1, -160, 0, 18),
		Position = UDim2.new(0, 14, 0, 17),
		Text = text,
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		Parent = headerRow,
	}

	-- Selected pill
	local pill = frame{
		Size = UDim2.new(0, 0, 0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		Position = UDim2.new(1, -14, 0.5, -14),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = accent,
		BackgroundTransparency = 0.8,
		Parent = headerRow,
	}
	roundCorner(pill, 14)
	addStroke(pill, accent, 1, 0.4)

	local selLabel = label{
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = selected .. " ▾",
		TextColor3 = accent,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = pill,
	}
	addPadding(selLabel, 0, 12, 0, 12)

	-- Dropdown list (hidden initially)
	local dropFrame = frame{
		Size = UDim2.new(1, -28, 0, 0),
		Position = UDim2.new(0, 14, 0, 52),
		BackgroundColor3 = Theme.SurfaceAlt,
		ClipsDescendants = true,
		Parent = wrapper,
	}
	roundCorner(dropFrame, 12)
	addStroke(dropFrame, accent, 1, 0.5)

	local dropList = makeList(dropFrame, 2)
	addPadding(dropFrame, 4, 0, 4, 0)

	local totalH = 0
	for _, item in ipairs(items) do
		local itemH = 36
		totalH += itemH + 2
		local itemBtn = button{
			Size = UDim2.new(1, 0, 0, itemH),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BackgroundTransparency = 1,
			Text = "",
			Parent = dropFrame,
		}
		roundCorner(itemBtn, 8)

		label{
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Text = item,
			TextColor3 = item == selected and accent or Theme.TextPrimary,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextYAlignment = Enum.TextYAlignment.Center,
			Parent = itemBtn,
		}

		itemBtn.MouseEnter:Connect(function()
			tween(itemBtn, Theme.Fast, {BackgroundTransparency = 0.9})
		end)
		itemBtn.MouseLeave:Connect(function()
			tween(itemBtn, Theme.Fast, {BackgroundTransparency = 1})
		end)
		itemBtn.MouseButton1Click:Connect(function()
			selected = item
			selLabel.Text = selected .. " ▾"
			callback(selected)
			-- Close
			open = false
			tween(dropFrame, Theme.Medium, {Size = UDim2.new(1, -28, 0, 0)})
			tween(selLabel, Theme.Fast, {TextColor3 = accent})
		end)
	end
	totalH += 8

	local headerClick = button{
		Size = UDim2.new(1, 0, 0, 52),
		Text = "",
		Parent = headerRow,
	}
	headerClick.MouseButton1Click:Connect(function()
		open = not open
		if open then
			tween(dropFrame, Theme.Medium, {Size = UDim2.new(1, -28, 0, totalH)})
			tween(selLabel, Theme.Fast, {TextColor3 = Theme.AccentGlow})
		else
			tween(dropFrame, Theme.Medium, {Size = UDim2.new(1, -28, 0, 0)})
			tween(selLabel, Theme.Fast, {TextColor3 = accent})
		end
	end)

	-- Divider
	local div = frame{
		Size = UDim2.new(1, -28, 0, 1),
		Position = UDim2.new(0, 14, 0, 51),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.4,
		Parent = wrapper,
	}
end

-- ─────────────────────────────────────────────
--  ✦  INPUT (Text Box)  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateInput(opts)
	opts = opts or {}
	local text       = opts.Text        or "Input"
	local placeholder= opts.Placeholder or "Type here..."
	local accent     = opts.Accent      or self._accent or Theme.Accent
	local callback   = opts.Callback    or function(_) end

	self._order = (self._order or 0) + 1
	local row = frame{
		Size = UDim2.new(1, 0, 0, 80),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		Parent = self._inner,
	}

	label{
		Size = UDim2.new(1, -20, 0, 18),
		Position = UDim2.new(0, 14, 0, 10),
		Text = text,
		TextColor3 = Theme.TextPrimary,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		Parent = row,
	}

	local box = frame{
		Size = UDim2.new(1, -28, 0, 36),
		Position = UDim2.new(0, 14, 0, 34),
		BackgroundColor3 = Theme.SurfaceAlt,
		Parent = row,
	}
	roundCorner(box, 10)
	local stroke = addStroke(box, Theme.Border, 1, 0)

	local tb = Instance.new("TextBox")
	tb.Size = UDim2.new(1, 0, 1, 0)
	tb.BackgroundTransparency = 1
	tb.BorderSizePixel = 0
	tb.Text = ""
	tb.PlaceholderText = placeholder
	tb.PlaceholderColor3 = Theme.TextMuted
	tb.TextColor3 = Theme.TextPrimary
	tb.TextSize = 13
	tb.Font = Enum.Font.Gotham
	tb.TextXAlignment = Enum.TextXAlignment.Left
	tb.ClearTextOnFocus = false
	tb.Parent = box
	addPadding(tb, 0, 10, 0, 12)

	tb.Focused:Connect(function()
		tween(stroke, Theme.Fast, {Color = accent, Transparency = 0})
	end)
	tb.FocusLost:Connect(function(enter)
		tween(stroke, Theme.Fast, {Color = Theme.Border, Transparency = 0})
		if enter then callback(tb.Text) end
	end)
	tb:GetPropertyChangedSignal("Text"):Connect(function()
		callback(tb.Text)
	end)

	local div = frame{
		Size = UDim2.new(1, -28, 0, 1),
		Position = UDim2.new(0, 14, 1, -1),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.4,
		Parent = row,
	}
end

-- ─────────────────────────────────────────────
--  ✦  KEYBIND  ✦
-- ─────────────────────────────────────────────
function AuraUI:CreateKeybind(opts)
	opts = opts or {}
	local text     = opts.Text     or "Keybind"
	local default  = opts.Default  or Enum.KeyCode.F
	local accent   = opts.Accent   or self._accent or Theme.Accent
	local callback = opts.Callback or function(_) end

	self._order = (self._order or 0) + 1
	local row, div = makeRow(self._inner, 0)
	row.LayoutOrder = self._order

	local currentKey = default
	local listening  = false

	label{
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		Text = text,
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = row,
	}

	local keyPill = frame{
		Size = UDim2.new(0, 58, 0, 28),
		Position = UDim2.new(1, -68, 0.5, -14),
		BackgroundColor3 = Theme.SurfaceAlt,
		Parent = row,
	}
	roundCorner(keyPill, 8)
	addStroke(keyPill, accent, 1, 0.5)

	local keyLabel = label{
		Size = UDim2.new(1, 0, 1, 0),
		Text = currentKey.Name,
		TextColor3 = accent,
		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = keyPill,
	}

	local clickBtn = button{
		Size = UDim2.new(1,0,1,0),
		Text = "",
		Parent = keyPill,
	}

	clickBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		keyLabel.Text = "..."
		tween(keyPill, Theme.Fast, {BackgroundColor3 = accent})
		tween(keyLabel, Theme.Fast, {TextColor3 = Color3.fromRGB(255,255,255)})

		local conn
		conn = UserInputService.InputBegan:Connect(function(inp, gpe)
			if inp.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				currentKey = inp.KeyCode
				keyLabel.Text = currentKey.Name
				tween(keyPill, Theme.Fast, {BackgroundColor3 = Theme.SurfaceAlt})
				tween(keyLabel, Theme.Fast, {TextColor3 = accent})
				callback(currentKey)
				conn:Disconnect()
			end
		end)
	end)

	UserInputService.InputBegan:Connect(function(inp, gpe)
		if not gpe and inp.KeyCode == currentKey and not listening then
			callback(currentKey)
		end
	end)
end

-- ─────────────────────────────────────────────
--  ✦  COLOR PICKER  ✦  (HSV wheel-less, RGB sliders)
-- ─────────────────────────────────────────────
function AuraUI:CreateColorPicker(opts)
	opts = opts or {}
	local text     = opts.Text     or "Color"
	local default  = opts.Default  or Color3.fromRGB(120, 80, 255)
	local accent   = opts.Accent   or self._accent or Theme.Accent
	local callback = opts.Callback or function(_) end

	self._order = (self._order or 0) + 1

	local r, g, b = math.round(default.R*255), math.round(default.G*255), math.round(default.B*255)
	local open = false

	local wrapper = frame{
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		LayoutOrder = self._order,
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = false,
		Parent = self._inner,
	}

	local header = frame{
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = wrapper,
	}

	label{
		Size = UDim2.new(1, -80, 1, 0),
		Position = UDim2.new(0, 14, 0, 0),
		Text = text,
		TextColor3 = Theme.TextPrimary,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = header,
	}

	-- Color preview swatch
	local swatch = frame{
		Size = UDim2.new(0, 36, 0, 26),
		Position = UDim2.new(1, -50, 0.5, -13),
		BackgroundColor3 = default,
		Parent = header,
	}
	roundCorner(swatch, 8)
	addStroke(swatch, Theme.Border, 1, 0)

	-- Expand panel
	local panel = frame{
		Size = UDim2.new(1, -28, 0, 0),
		Position = UDim2.new(0, 14, 0, 52),
		BackgroundColor3 = Theme.SurfaceAlt,
		ClipsDescendants = true,
		Parent = wrapper,
	}
	roundCorner(panel, 12)
	addStroke(panel, Theme.Border, 1, 0)

	local function rebuild()
		for _, c in ipairs(panel:GetChildren()) do
			if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
		end

		local function makeRGBSlider(label_text, chan_color, getVal, setVal)
			local sRow = frame{
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundTransparency = 1,
				Parent = panel,
			}
			local lbl = label{
				Size = UDim2.new(0, 20, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				Text = label_text,
				TextColor3 = chan_color,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Parent = sRow,
			}
			local tBG = frame{
				Size = UDim2.new(1, -60, 0, 6),
				Position = UDim2.new(0, 34, 0.5, -3),
				BackgroundColor3 = Theme.Border,
				Parent = sRow,
			}
			roundCorner(tBG, 3)
			local tFill = frame{
				Size = UDim2.new(getVal()/255, 0, 1, 0),
				BackgroundColor3 = chan_color,
				Parent = tBG,
			}
			roundCorner(tFill, 3)
			local valLbl = label{
				Size = UDim2.new(0, 28, 1, 0),
				Position = UDim2.new(1, -30, 0, 0),
				Text = tostring(getVal()),
				TextColor3 = Theme.TextSecond,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Center,
				Parent = sRow,
			}

			local dragging = false
			local clickArea = button{Size=UDim2.new(1,0,1,0),Text="",ZIndex=3,Parent=tBG}
			clickArea.MouseButton1Down:Connect(function()
				dragging=true
			end)
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
			end)
			UserInputService.InputChanged:Connect(function(i)
				if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
					local px=tBG.AbsolutePosition.X
					local pw=tBG.AbsoluteSize.X
					local pct=math.clamp((UserInputService:GetMouseLocation().X-px)/pw,0,1)
					local v=math.round(pct*255)
					setVal(v)
					tFill.Size=UDim2.new(pct,0,1,0)
					valLbl.Text=tostring(v)
					swatch.BackgroundColor3=Color3.fromRGB(r,g,b)
					callback(Color3.fromRGB(r,g,b))
				end
			end)
		end

		makeRGBSlider("R", Color3.fromRGB(255,80,80), function() return r end, function(v) r=v end)
		makeRGBSlider("G", Color3.fromRGB(80,220,120),function() return g end, function(v) g=v end)
		makeRGBSlider("B", Color3.fromRGB(80,160,255),function() return b end, function(v) b=v end)
	end

	local headerClick = button{
		Size = UDim2.new(1, 0, 0, 52),
		Text = "",
		Parent = header,
	}
	headerClick.MouseButton1Click:Connect(function()
		open = not open
		if open then
			rebuild()
			tween(panel, Theme.Medium, {Size = UDim2.new(1, -28, 0, 110)})
		else
			tween(panel, Theme.Medium, {Size = UDim2.new(1, -28, 0, 0)})
		end
	end)

	-- Divider
	frame{
		Size = UDim2.new(1,-28,0,1),
		Position = UDim2.new(0,14,0,51),
		BackgroundColor3 = Theme.Border,
		BackgroundTransparency = 0.4,
		Parent = wrapper,
	}
end

-- ─────────────────────────────────────────────
--  ✦  NEW: Initialize  ✦
-- ─────────────────────────────────────────────
function AuraUI.new()
	return setmetatable({_order = 0}, AuraUI)
end

-- ═══════════════════════════════════════════════
--          ✦  DEMO / EXAMPLE USAGE  ✦
-- ═══════════════════════════════════════════════
--[[

local UI = AuraUI.new()

local Window = UI:CreateWindow({
	Title    = "✦ AuraUI",
	Subtitle = "Next-Gen Roblox Interface",
	Accent   = Color3.fromRGB(130, 80, 255),
})

-- ── Section: Visuals ──
local Visuals = Window:CreateSection({
	Title  = "Visuals",
	Icon   = "◈",
	Accent = Color3.fromRGB(130, 80, 255),
})

Visuals:CreateToggle({
	Text     = "Full Bright",
	Desc     = "Illuminates the entire map",
	Default  = false,
	Callback = function(val)
		print("FullBright:", val)
	end,
})

Visuals:CreateSlider({
	Text     = "Field of View",
	Min      = 70,
	Max      = 120,
	Default  = 90,
	Suffix   = "°",
	Callback = function(val)
		game.Workspace.CurrentCamera.FieldOfView = val
	end,
})

Visuals:CreateSlider({
	Text     = "Brightness",
	Min      = 0,
	Max      = 10,
	Default  = 2,
	Decimals = 1,
	Callback = function(val)
		game.Lighting.Brightness = val
	end,
})

Visuals:CreateDropdown({
	Text     = "Sky Theme",
	Items    = {"Midnight", "Sunset", "Dawn", "Storm"},
	Default  = "Midnight",
	Callback = function(val)
		print("Sky:", val)
	end,
})

Visuals:CreateColorPicker({
	Text     = "Ambient Color",
	Default  = Color3.fromRGB(120, 80, 255),
	Callback = function(c)
		game.Lighting.Ambient = c
	end,
})

-- ── Section: Movement ──
local Movement = Window:CreateSection({
	Title  = "Movement",
	Icon   = "⟶",
	Accent = Color3.fromRGB(40, 200, 180),
})

Movement:CreateSlider({
	Text     = "Walk Speed",
	Min      = 16,
	Max      = 250,
	Default  = 16,
	Suffix   = " ws",
	Accent   = Color3.fromRGB(40, 200, 180),
	Callback = function(val)
		if game.Players.LocalPlayer.Character then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
		end
	end,
})

Movement:CreateToggle({
	Text     = "Infinite Jump",
	Default  = false,
	Accent   = Color3.fromRGB(40, 200, 180),
	Callback = function(val)
		print("InfJump:", val)
	end,
})

Movement:CreateKeybind({
	Text     = "Fly Toggle",
	Default  = Enum.KeyCode.G,
	Accent   = Color3.fromRGB(40, 200, 180),
	Callback = function(key)
		print("Fly key pressed:", key)
	end,
})

-- ── Section: Info ──
local Info = Window:CreateSection({
	Title  = "About",
	Icon   = "ℹ",
	Accent = Color3.fromRGB(255, 180, 40),
})

Info:CreateLabel({ Text = "AuraUI v1.0 — Built for beauty & speed", Accent = Color3.fromRGB(255,180,40) })
Info:CreateDivider({ Text = "DETAILS" })
Info:CreateParagraph({
	Title = "What is AuraUI?",
	Body  = "AuraUI is a premium Roblox Luau UI library built for mobile and desktop. It features glassmorphic design, smooth spring animations, and a fully modular component system.",
})
Info:CreateBadge({ Label = "Library Version", Text = "v1.0", Color = Color3.fromRGB(255,180,40) })

-- ── Section: Actions ──
local Actions = Window:CreateSection({
	Title = "Actions",
	Icon  = "✦",
})

Actions:CreateButton({
	Text     = "Rejoin Server",
	Desc     = "Reconnects to a fresh instance",
	Callback = function()
		game:GetService("TeleportService"):Teleport(game.PlaceId)
	end,
})

Actions:CreateButton({
	Text     = "Send Alert ✦",
	Style    = "primary",
	Callback = function()
		Window:Notify({
			Title    = "✦ Hello from AuraUI!",
			Desc     = "Notifications are live and beautiful.",
			Color    = Color3.fromRGB(130, 80, 255),
			Duration = 5,
		})
	end,
})

Actions:CreateButton({
	Text     = "Danger Zone",
	Style    = "danger",
	Callback = function()
		Window:Notify({
			Title = "⚠ Warning",
			Desc  = "This action is irreversible!",
			Color = Color3.fromRGB(255, 70, 90),
		})
	end,
})

Actions:CreateInput({
	Text        = "Player Name",
	Placeholder = "Enter username...",
	Callback    = function(val)
		print("Input:", val)
	end,
})

--]]

return AuraUI
