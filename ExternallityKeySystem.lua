--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║          EXTERNALLITY KEY VALIDATION SYSTEM               ║
    ║          Powered by Panda Development                     ║
    ║          Version 2.0 | Blue Edition                       ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- ══════════════════════════════════════
--          CONFIGURATION
-- ══════════════════════════════════════
local CONFIG = {
    ServiceIdentifier = "externalliltyserviceidentifier",
    APIToken          = "3f739883-8408-403e-bcfe-fbe8c8241b8d",
    GetKeyLink        = "https://new.pandadevelopment.net/getkey/externalliltyserviceidentifier?hwid=",
    ValidateEndpoint  = "https://new.pandadevelopment.net/v2_validation",
    SaveFileName      = "Externallity_Key.txt",
    HubTitle          = "Externallity",
    HubSubtitle       = "Key Validation System",
}

-- ══════════════════════════════════════
--          COLOR PALETTE
-- ══════════════════════════════════════
local COLORS = {
    Background      = Color3.fromRGB(5, 10, 25),
    SidePanel       = Color3.fromRGB(8, 16, 40),
    CardBG          = Color3.fromRGB(10, 22, 55),
    Accent          = Color3.fromRGB(30, 100, 255),
    AccentGlow      = Color3.fromRGB(50, 130, 255),
    AccentDark      = Color3.fromRGB(15, 55, 160),
    InputBG         = Color3.fromRGB(12, 25, 65),
    InputBorder     = Color3.fromRGB(30, 80, 200),
    TextPrimary     = Color3.fromRGB(220, 235, 255),
    TextSecondary   = Color3.fromRGB(120, 155, 210),
    TextDim         = Color3.fromRGB(60, 90, 150),
    Success         = Color3.fromRGB(40, 200, 120),
    Error           = Color3.fromRGB(220, 60, 80),
    Warning         = Color3.fromRGB(255, 175, 40),
    ButtonHover     = Color3.fromRGB(50, 120, 255),
    Divider         = Color3.fromRGB(20, 50, 120),
    White           = Color3.fromRGB(255, 255, 255),
}

-- ══════════════════════════════════════
--          SERVICES
-- ══════════════════════════════════════
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ══════════════════════════════════════
--          UTILITIES
-- ══════════════════════════════════════
local function GetHWID()
    -- Attempt to get a unique hardware identifier
    local success, hwid = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    if success and hwid and hwid ~= "" then return hwid end

    -- Fallback: use UserId + machine fingerprint
    local userId = tostring(LocalPlayer.UserId)
    local extra = tostring(math.random(100000, 999999))
    -- Try writefile/readfile for persistent HWID
    if writefile and readfile then
        local ok, stored = pcall(readfile, "externallity_hwid.txt")
        if ok and stored and stored ~= "" then return stored end
        local newId = userId .. "_" .. extra
        pcall(writefile, "externallity_hwid.txt", newId)
        return newId
    end
    return userId .. "_" .. extra
end

local function LoadSavedKey()
    if readfile then
        local ok, data = pcall(readfile, CONFIG.SaveFileName)
        if ok and data and data ~= "" then return data end
    end
    return nil
end

local function SaveKey(key)
    if writefile then
        pcall(writefile, CONFIG.SaveFileName, key)
    end
end

local function ValidateKey(key, hwid)
    local url = CONFIG.ValidateEndpoint
        .. "?service=" .. CONFIG.ServiceIdentifier
        .. "&hwid="    .. hwid
        .. "&key="     .. key
        .. "&token="   .. CONFIG.APIToken

    local ok, response = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not response then return false, "Connection failed" end

    local parseOk, data = pcall(HttpService.JSONDecode, HttpService, response)
    if not parseOk then
        -- Some endpoints return plain text "true"/"false"
        local lower = response:lower():gsub("%s+", "")
        if lower == "true" or lower == "valid" then return true, "Authenticated" end
        return false, "Invalid response"
    end

    -- Standard Panda V2 response
    local auth = data["V2_Authentication"] or data["authentication"] or data["valid"] or data["success"]
    if auth == true or auth == "true" then
        return true, "Authenticated"
    elseif auth == false or auth == "false" then
        return false, "Invalid key"
    end

    -- Fallback check
    if data["error"] then return false, tostring(data["error"]) end
    return false, "Unknown response"
end

-- ══════════════════════════════════════
--          TWEEN HELPERS
-- ══════════════════════════════════════
local function Tween(obj, props, duration, style, dir)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function FadeIn(obj, duration)
    obj.BackgroundTransparency = 1
    Tween(obj, {BackgroundTransparency = 0}, duration or 0.4)
end

-- ══════════════════════════════════════
--          UI BUILDER HELPERS
-- ══════════════════════════════════════
local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function UICorner(radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 8)})
end

local function UIStroke(color, thickness, trans)
    return Create("UIStroke", {
        Color = color or COLORS.Accent,
        Thickness = thickness or 1.5,
        Transparency = trans or 0,
    })
end

local function GradientLabel(parent, c0, c1, rotation)
    local g = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c0),
            ColorSequenceKeypoint.new(1, c1),
        }),
        Rotation = rotation or 0,
    })
    g.Parent = parent
    return g
end

local function Label(props)
    return Create("TextLabel", {
        BackgroundTransparency = 1,
        TextColor3 = COLORS.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Text = "",
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        unpack(props or {}),
    })
end

-- ══════════════════════════════════════
--          MAIN UI CONSTRUCTION
-- ══════════════════════════════════════
local function BuildUI(hwid, onValidate)

    -- Remove old GUI if exists
    local old = PlayerGui:FindFirstChild("ExternallityKeySystem")
    if old then old:Destroy() end

    -- ── ScreenGui ─────────────────────────────────────────────
    local ScreenGui = Create("ScreenGui", {
        Name              = "ExternallityKeySystem",
        ResetOnSpawn      = false,
        ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset    = true,
        DisplayOrder      = 999,
        Parent            = PlayerGui,
    })

    -- ── Blur Overlay ──────────────────────────────────────────
    local BlurFrame = Create("Frame", {
        Size              = UDim2.fromScale(1, 1),
        BackgroundColor3  = Color3.fromRGB(0, 5, 20),
        BackgroundTransparency = 0.3,
        BorderSizePixel   = 0,
        Parent            = ScreenGui,
    })

    -- ── Main Container ────────────────────────────────────────
    local MainFrame = Create("Frame", {
        Size              = UDim2.new(0, 540, 0, 380),
        Position          = UDim2.new(0.5, -270, 0.5, -190),
        BackgroundColor3  = COLORS.Background,
        BorderSizePixel   = 0,
        ClipDescendants   = true,
        Parent            = ScreenGui,
    })
    UICorner(16).Parent = MainFrame

    -- Outer glow border
    local outerStroke = Create("UIStroke", {
        Color             = COLORS.Accent,
        Thickness         = 1.5,
        Transparency      = 0.3,
        Parent            = MainFrame,
    })

    -- Animated glow background
    local GlowBG = Create("Frame", {
        Size              = UDim2.new(1.5, 0, 1.5, 0),
        Position          = UDim2.new(-0.25, 0, -0.25, 0),
        BackgroundColor3  = COLORS.Accent,
        BackgroundTransparency = 0.92,
        BorderSizePixel   = 0,
        ZIndex            = 0,
        Parent            = MainFrame,
    })
    UICorner(200).Parent = GlowBG

    -- Top gradient bar
    local TopBar = Create("Frame", {
        Size              = UDim2.new(1, 0, 0, 4),
        Position          = UDim2.new(0, 0, 0, 0),
        BackgroundColor3  = COLORS.Accent,
        BorderSizePixel   = 0,
        ZIndex            = 5,
        Parent            = MainFrame,
    })
    GradientLabel(TopBar, Color3.fromRGB(0, 60, 220), Color3.fromRGB(80, 180, 255), 90)

    -- ── Left Panel ────────────────────────────────────────────
    local LeftPanel = Create("Frame", {
        Size              = UDim2.new(0, 175, 1, 0),
        Position          = UDim2.new(0, 0, 0, 0),
        BackgroundColor3  = COLORS.SidePanel,
        BorderSizePixel   = 0,
        ZIndex            = 2,
        Parent            = MainFrame,
    })

    -- Panda logo circle
    local LogoCircle = Create("Frame", {
        Size              = UDim2.new(0, 80, 0, 80),
        Position          = UDim2.new(0.5, -40, 0, 35),
        BackgroundColor3  = COLORS.AccentDark,
        BorderSizePixel   = 0,
        ZIndex            = 3,
        Parent            = LeftPanel,
    })
    UICorner(40).Parent = LogoCircle
    Create("UIStroke", {Color = COLORS.AccentGlow, Thickness = 2, Parent = LogoCircle})

    -- Logo gradient inner
    local LogoInner = Create("Frame", {
        Size              = UDim2.new(0, 64, 0, 64),
        Position          = UDim2.new(0.5, -32, 0.5, -32),
        BackgroundColor3  = COLORS.Accent,
        BorderSizePixel   = 0,
        ZIndex            = 4,
        Parent            = LogoCircle,
    })
    UICorner(32).Parent = LogoInner
    GradientLabel(LogoInner, Color3.fromRGB(20, 80, 255), Color3.fromRGB(80, 160, 255), 135)

    -- Logo icon text
    Create("TextLabel", {
        Size              = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text              = "🔑",
        TextScaled        = true,
        ZIndex            = 5,
        Parent            = LogoInner,
    })

    -- Hub name
    Create("TextLabel", {
        Size              = UDim2.new(1, -10, 0, 28),
        Position          = UDim2.new(0, 5, 0, 125),
        BackgroundTransparency = 1,
        Text              = CONFIG.HubTitle:upper(),
        TextColor3        = COLORS.TextPrimary,
        Font              = Enum.Font.GothamBold,
        TextSize          = 18,
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 3,
        Parent            = LeftPanel,
    })

    -- Subtitle
    Create("TextLabel", {
        Size              = UDim2.new(1, -10, 0, 18),
        Position          = UDim2.new(0, 5, 0, 152),
        BackgroundTransparency = 1,
        Text              = CONFIG.HubSubtitle,
        TextColor3        = COLORS.TextSecondary,
        Font              = Enum.Font.Gotham,
        TextSize          = 11,
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 3,
        Parent            = LeftPanel,
    })

    -- Divider line
    Create("Frame", {
        Size              = UDim2.new(0, 130, 0, 1),
        Position          = UDim2.new(0.5, -65, 0, 178),
        BackgroundColor3  = COLORS.Divider,
        BorderSizePixel   = 0,
        ZIndex            = 3,
        Parent            = LeftPanel,
    })

    -- HWID display
    Create("TextLabel", {
        Size              = UDim2.new(1, -16, 0, 16),
        Position          = UDim2.new(0, 8, 0, 192),
        BackgroundTransparency = 1,
        Text              = "HWID",
        TextColor3        = COLORS.TextDim,
        Font              = Enum.Font.GothamBold,
        TextSize          = 10,
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 3,
        Parent            = LeftPanel,
    })

    local HwidLabel = Create("TextLabel", {
        Size              = UDim2.new(1, -16, 0, 28),
        Position          = UDim2.new(0, 8, 0, 207),
        BackgroundColor3  = COLORS.InputBG,
        BackgroundTransparency = 0,
        Text              = hwid:sub(1, 14) .. "...",
        TextColor3        = COLORS.TextSecondary,
        Font              = Enum.Font.Code,
        TextSize          = 9,
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 3,
        Parent            = LeftPanel,
    })
    UICorner(6).Parent = HwidLabel

    -- Powered by label
    Create("TextLabel", {
        Size              = UDim2.new(1, -10, 0, 18),
        Position          = UDim2.new(0, 5, 1, -30),
        BackgroundTransparency = 1,
        Text              = "Powered by Panda Dev",
        TextColor3        = COLORS.TextDim,
        Font              = Enum.Font.Gotham,
        TextSize          = 9,
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 3,
        Parent            = LeftPanel,
    })

    -- Vertical divider
    Create("Frame", {
        Size              = UDim2.new(0, 1, 1, 0),
        Position          = UDim2.new(0, 175, 0, 0),
        BackgroundColor3  = COLORS.Divider,
        BorderSizePixel   = 0,
        ZIndex            = 3,
        Parent            = MainFrame,
    })

    -- ── Right Panel ───────────────────────────────────────────
    local RightPanel = Create("Frame", {
        Size              = UDim2.new(1, -175, 1, 0),
        Position          = UDim2.new(0, 175, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel   = 0,
        ZIndex            = 2,
        Parent            = MainFrame,
    })

    -- Title
    Create("TextLabel", {
        Size              = UDim2.new(1, -30, 0, 30),
        Position          = UDim2.new(0, 20, 0, 25),
        BackgroundTransparency = 1,
        Text              = "Key Authentication",
        TextColor3        = COLORS.TextPrimary,
        Font              = Enum.Font.GothamBold,
        TextSize          = 20,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 3,
        Parent            = RightPanel,
    })

    Create("TextLabel", {
        Size              = UDim2.new(1, -30, 0, 18),
        Position          = UDim2.new(0, 20, 0, 54),
        BackgroundTransparency = 1,
        Text              = "Enter your key below to access the hub",
        TextColor3        = COLORS.TextSecondary,
        Font              = Enum.Font.Gotham,
        TextSize          = 12,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 3,
        Parent            = RightPanel,
    })

    -- Divider
    Create("Frame", {
        Size              = UDim2.new(1, -40, 0, 1),
        Position          = UDim2.new(0, 20, 0, 80),
        BackgroundColor3  = COLORS.Divider,
        BorderSizePixel   = 0,
        ZIndex            = 3,
        Parent            = RightPanel,
    })

    -- Key input label
    Create("TextLabel", {
        Size              = UDim2.new(1, -40, 0, 16),
        Position          = UDim2.new(0, 20, 0, 95),
        BackgroundTransparency = 1,
        Text              = "LICENSE KEY",
        TextColor3        = COLORS.TextDim,
        Font              = Enum.Font.GothamBold,
        TextSize          = 10,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 3,
        Parent            = RightPanel,
    })

    -- Key input box container
    local InputContainer = Create("Frame", {
        Size              = UDim2.new(1, -40, 0, 44),
        Position          = UDim2.new(0, 20, 0, 113),
        BackgroundColor3  = COLORS.InputBG,
        BorderSizePixel   = 0,
        ZIndex            = 3,
        Parent            = RightPanel,
    })
    UICorner(10).Parent = InputContainer
    local inputStroke = UIStroke(COLORS.InputBorder, 1.5, 0.5)
    inputStroke.Parent = InputContainer

    -- Key icon
    Create("TextLabel", {
        Size              = UDim2.new(0, 36, 1, 0),
        Position          = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text              = "🔑",
        TextSize          = 16,
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 4,
        Parent            = InputContainer,
    })

    -- Actual TextBox
    local KeyInput = Create("TextBox", {
        Size              = UDim2.new(1, -46, 1, -2),
        Position          = UDim2.new(0, 38, 0, 1),
        BackgroundTransparency = 1,
        PlaceholderText   = "Enter your key here...",
        PlaceholderColor3 = COLORS.TextDim,
        Text              = "",
        TextColor3        = COLORS.TextPrimary,
        Font              = Enum.Font.Code,
        TextSize          = 13,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ClearTextOnFocus  = false,
        ZIndex            = 4,
        Parent            = InputContainer,
    })

    -- Focus/blur glow animation
    KeyInput.Focused:Connect(function()
        Tween(inputStroke, {Transparency = 0}, 0.25)
        Tween(inputStroke, {Color = COLORS.AccentGlow}, 0.25)
    end)
    KeyInput.FocusLost:Connect(function()
        Tween(inputStroke, {Transparency = 0.5}, 0.25)
        Tween(inputStroke, {Color = COLORS.InputBorder}, 0.25)
    end)

    -- Status display
    local StatusFrame = Create("Frame", {
        Size              = UDim2.new(1, -40, 0, 32),
        Position          = UDim2.new(0, 20, 0, 165),
        BackgroundColor3  = COLORS.CardBG,
        BackgroundTransparency = 1,
        BorderSizePixel   = 0,
        ZIndex            = 3,
        Parent            = RightPanel,
    })
    UICorner(8).Parent = StatusFrame

    local StatusIcon = Create("TextLabel", {
        Size              = UDim2.new(0, 24, 1, 0),
        Position          = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text              = "ℹ️",
        TextSize          = 14,
        TextXAlignment    = Enum.TextXAlignment.Center,
        ZIndex            = 4,
        Parent            = StatusFrame,
    })

    local StatusLabel = Create("TextLabel", {
        Size              = UDim2.new(1, -40, 1, 0),
        Position          = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text              = "Awaiting key input...",
        TextColor3        = COLORS.TextSecondary,
        Font              = Enum.Font.Gotham,
        TextSize          = 12,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 4,
        Parent            = StatusFrame,
    })

    -- ── Buttons ───────────────────────────────────────────────
    local BtnRow = Create("Frame", {
        Size              = UDim2.new(1, -40, 0, 42),
        Position          = UDim2.new(0, 20, 0, 210),
        BackgroundTransparency = 1,
        BorderSizePixel   = 0,
        ZIndex            = 3,
        Parent            = RightPanel,
    })

    local function MakeButton(text, xPos, width, colorA, colorB, icon)
        local btn = Create("TextButton", {
            Size              = UDim2.new(0, width, 1, 0),
            Position          = UDim2.new(0, xPos, 0, 0),
            BackgroundColor3  = colorA,
            Text              = "",
            AutoButtonColor   = false,
            ZIndex            = 4,
            Parent            = BtnRow,
        })
        UICorner(10).Parent = btn
        GradientLabel(btn, colorA, colorB, 135)

        Create("TextLabel", {
            Size              = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text              = (icon and icon .. "  " or "") .. text,
            TextColor3        = COLORS.White,
            Font              = Enum.Font.GothamBold,
            TextSize          = 13,
            ZIndex            = 5,
            Parent            = btn,
        })

        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = colorB}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = colorA}, 0.2)
        end)

        return btn
    end

    local ValidateBtn = MakeButton("Validate Key", 0, 155,
        Color3.fromRGB(25, 85, 230), Color3.fromRGB(60, 140, 255), "✅")

    local GetKeyBtn = MakeButton("Get Key", 163, 100,
        Color3.fromRGB(15, 55, 160), Color3.fromRGB(30, 90, 220), "🔗")

    local ClearBtn = MakeButton("Clear", 271, 70,
        Color3.fromRGB(40, 20, 80), Color3.fromRGB(80, 40, 140), "✖")

    -- ── Get Key via clipboard link ────────────────────────────
    GetKeyBtn.MouseButton1Click:Connect(function()
        local link = CONFIG.GetKeyLink .. hwid
        if setclipboard then
            setclipboard(link)
            StatusLabel.Text       = "Get-Key link copied to clipboard!"
            StatusLabel.TextColor3 = COLORS.Warning
            StatusIcon.Text        = "📋"
            StatusFrame.BackgroundTransparency = 0
            StatusFrame.BackgroundColor3 = Color3.fromRGB(60, 45, 10)
        else
            StatusLabel.Text       = "Open: " .. link
            StatusLabel.TextColor3 = COLORS.Warning
        end
        task.delay(3, function()
            StatusLabel.Text       = "Awaiting key input..."
            StatusLabel.TextColor3 = COLORS.TextSecondary
            StatusIcon.Text        = "ℹ️"
            Tween(StatusFrame, {BackgroundTransparency = 1}, 0.3)
        end)
    end)

    -- ── Clear ─────────────────────────────────────────────────
    ClearBtn.MouseButton1Click:Connect(function()
        KeyInput.Text          = ""
        StatusLabel.Text       = "Awaiting key input..."
        StatusLabel.TextColor3 = COLORS.TextSecondary
        StatusIcon.Text        = "ℹ️"
        Tween(inputStroke, {Color = COLORS.InputBorder}, 0.2)
        Tween(StatusFrame, {BackgroundTransparency = 1}, 0.3)
    end)

    -- ── Validate ──────────────────────────────────────────────
    local isValidating = false

    local function SetStatus(icon, msg, color, bgColor)
        StatusIcon.Text = icon
        StatusLabel.Text = msg
        StatusLabel.TextColor3 = color
        StatusFrame.BackgroundColor3 = bgColor
        StatusFrame.BackgroundTransparency = 0
    end

    local function DoValidation()
        if isValidating then return end
        local key = KeyInput.Text:match("^%s*(.-)%s*$") -- trim whitespace

        if key == "" then
            SetStatus("⚠️", "Please enter a key first!", COLORS.Warning, Color3.fromRGB(50, 40, 10))
            return
        end

        isValidating = true

        -- Loading animation
        SetStatus("⏳", "Contacting Panda Development servers...", COLORS.TextSecondary, COLORS.CardBG)
        Tween(inputStroke, {Color = COLORS.AccentGlow}, 0.3)

        -- Spinning dots animation
        local dots = {"⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"}
        local dotIdx = 1
        local animConn
        animConn = RunService.Heartbeat:Connect(function()
            StatusIcon.Text = dots[dotIdx]
            dotIdx = (dotIdx % #dots) + 1
        end)

        task.spawn(function()
            local success, msg = ValidateKey(key, hwid)
            animConn:Disconnect()

            if success then
                SetStatus("✅", "Key authenticated successfully!", COLORS.Success, Color3.fromRGB(10, 50, 25))
                Tween(inputStroke, {Color = COLORS.Success}, 0.3)
                SaveKey(key)

                -- Pulse success
                for i = 1, 3 do
                    Tween(outerStroke, {Color = COLORS.Success, Transparency = 0}, 0.2)
                    task.wait(0.25)
                    Tween(outerStroke, {Transparency = 0.6}, 0.2)
                    task.wait(0.25)
                end
                Tween(outerStroke, {Color = COLORS.Success, Transparency = 0.1}, 0.3)

                task.wait(1.5)
                -- Fade out and destroy
                Tween(MainFrame, {BackgroundTransparency = 1}, 0.5)
                Tween(BlurFrame, {BackgroundTransparency = 1}, 0.5)
                task.wait(0.5)
                ScreenGui:Destroy()
                if onValidate then onValidate(key) end
            else
                SetStatus("❌", "Invalid key: " .. (msg or "Authentication failed"), COLORS.Error, Color3.fromRGB(50, 10, 15))
                Tween(inputStroke, {Color = COLORS.Error}, 0.3)

                -- Shake animation
                local originalPos = MainFrame.Position
                for i = 1, 4 do
                    Tween(MainFrame, {Position = originalPos + UDim2.new(0, 8, 0, 0)}, 0.05)
                    task.wait(0.05)
                    Tween(MainFrame, {Position = originalPos - UDim2.new(0, 8, 0, 0)}, 0.05)
                    task.wait(0.05)
                end
                Tween(MainFrame, {Position = originalPos}, 0.1)

                task.delay(3, function()
                    Tween(inputStroke, {Color = COLORS.InputBorder}, 0.3)
                    Tween(StatusFrame, {BackgroundTransparency = 1}, 0.3)
                    StatusLabel.Text       = "Awaiting key input..."
                    StatusLabel.TextColor3 = COLORS.TextSecondary
                    StatusIcon.Text        = "ℹ️"
                end)
            end

            isValidating = false
        end)
    end

    ValidateBtn.MouseButton1Click:Connect(DoValidation)
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then DoValidation() end
    end)

    -- ── Bottom info row ───────────────────────────────────────
    Create("TextLabel", {
        Size              = UDim2.new(1, -40, 0, 16),
        Position          = UDim2.new(0, 20, 1, -28),
        BackgroundTransparency = 1,
        Text              = "💡  Key not working? Click Get Key to obtain a fresh one.",
        TextColor3        = COLORS.TextDim,
        Font              = Enum.Font.Gotham,
        TextSize          = 10,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ZIndex            = 3,
        Parent            = RightPanel,
    })

    -- ── Dragging ──────────────────────────────────────────────
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Entry animation ───────────────────────────────────────
    MainFrame.Position = UDim2.new(0.5, -270, 0.5, -250)
    MainFrame.BackgroundTransparency = 1
    BlurFrame.BackgroundTransparency = 1
    Tween(BlurFrame, {BackgroundTransparency = 0.3}, 0.4)
    Tween(MainFrame, {
        Position = UDim2.new(0.5, -270, 0.5, -190),
        BackgroundTransparency = 0,
    }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- ── Ambient glow pulse ────────────────────────────────────
    task.spawn(function()
        while ScreenGui.Parent do
            Tween(GlowBG, {BackgroundTransparency = 0.88}, 2.5, Enum.EasingStyle.Sine)
            task.wait(2.5)
            Tween(GlowBG, {BackgroundTransparency = 0.94}, 2.5, Enum.EasingStyle.Sine)
            task.wait(2.5)
        end
    end)

    -- ── Auto-fill saved key ───────────────────────────────────
    local saved = LoadSavedKey()
    if saved then
        KeyInput.Text          = saved
        SetStatus("💾", "Saved key loaded. Press Validate or Enter.", COLORS.TextSecondary, COLORS.CardBG)
    end

    return ScreenGui
end

-- ══════════════════════════════════════
--          ENTRY POINT
-- ══════════════════════════════════════
local HWID = GetHWID()

BuildUI(HWID, function(validatedKey)
    -- ✅ Key validated successfully — put your main script below
    print("[Externallity] ✅ Key validated: " .. validatedKey)
    print("[Externallity] 🚀 Loading hub...")

    -- ════════════════════════════
    --   YOUR MAIN SCRIPT HERE
    -- ════════════════════════════
end)
