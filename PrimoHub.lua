--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 

 ██████╗ ██████╗ ██╗███╗   ███╗ ██████╗     ██╗  ██╗██╗   ██╗██████╗ 
 ██╔══██╗██╔══██╗██║████╗ ████║██╔═══██╗    ██║  ██║██║   ██║██╔══██╗
 ██████╔╝██████╔╝██║██╔████╔██║██║   ██║    ███████║██║   ██║██████╔╝
 ██╔═══╝ ██╔══██╗██║██║╚██╔╝██║██║   ██║    ██╔══██║██║   ██║██╔══██╗
 ██║     ██║  ██║██║██║ ╚═╝ ██║╚██████╔╝    ██║  ██║╚██████╔╝██████╔╝
 ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝ ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 

  Full UI Library | Draggable | Loading Screen | Tabs | Components
]=]

-- ============================================================
--  SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local RunService      = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
--  THEME  (matches your original colour palette exactly)
-- ============================================================
local Theme = {
    Background    = Color3.fromRGB(70,  70,  70),
    Sidebar       = Color3.fromRGB(42,  42,  42),
    TitleBar      = Color3.fromRGB(57,  57,  57),
    Tab           = Color3.fromRGB(63,  63,  63),
    TabHover      = Color3.fromRGB(75,  75,  75),
    TabActive     = Color3.fromRGB(80,  80,  80),
    Button        = Color3.fromRGB(95,  95,  95),
    ButtonHover   = Color3.fromRGB(112, 112, 112),
    ButtonActive  = Color3.fromRGB(143, 229, 255),
    Accent        = Color3.fromRGB(143, 229, 255),
    White         = Color3.fromRGB(255, 255, 255),
    Divider       = Color3.fromRGB(255, 255, 255),
    ToggleOn      = Color3.fromRGB(143, 229, 255),
    ToggleOff     = Color3.fromRGB(80,  80,  80),
    SliderTrack   = Color3.fromRGB(50,  50,  50),
    SliderFill    = Color3.fromRGB(143, 229, 255),
    TextBoxBG     = Color3.fromRGB(55,  55,  55),
    LoadingBG     = Color3.fromRGB(30,  30,  30),
    CloseBtn      = Color3.fromRGB(220, 80,  80),
    MinBtn        = Color3.fromRGB(200, 170, 40),
}

local FontMain = Font.new("rbxasset://fonts/families/SourceSansPro.json",  Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
local FontBold = Font.new("rbxasset://fonts/families/BuilderSans.json",    Enum.FontWeight.Bold,     Enum.FontStyle.Normal)

-- ============================================================
--  HELPERS
-- ============================================================
local function Corner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 6)
    return c
end

local function Stroke(parent, col, thick)
    local s = Instance.new("UIStroke", parent)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color     = col   or Theme.White
    s.Thickness = thick or 1
    return s
end

local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

-- ============================================================
--  LOADING SCREEN
-- ============================================================
local function CreateLoadingScreen(onFinish)
    local LGui = Instance.new("ScreenGui", PlayerGui)
    LGui.Name = "PrimoHub_Loading"
    LGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LGui.DisplayOrder  = 999
    LGui.ResetOnSpawn  = false

    -- Full-screen dim
    local Dim = Instance.new("Frame", LGui)
    Dim.Size = UDim2.new(1,0,1,0)
    Dim.BackgroundColor3 = Theme.LoadingBG
    Dim.BorderSizePixel  = 0
    Dim.BackgroundTransparency = 0

    -- Card
    local Card = Instance.new("Frame", Dim)
    Card.Size = UDim2.new(0, 300, 0, 130)
    Card.Position = UDim2.new(0.5,-150, 0.5,-65)
    Card.BackgroundColor3 = Theme.TitleBar
    Card.BackgroundTransparency = 0.2
    Card.BorderSizePixel = 0
    Corner(Card, 10)
    Stroke(Card, Theme.Accent)

    -- Logo icon
    local Logo = Instance.new("ImageLabel", Card)
    Logo.Size = UDim2.new(0,36,0,28)
    Logo.Position = UDim2.new(0.5,-18, 0,10)
    Logo.BackgroundTransparency = 1
    Logo.Image = "rbxassetid://91306356501736"
    Logo.BorderSizePixel = 0

    -- "Primo" text
    local T1 = Instance.new("TextLabel", Card)
    T1.Size = UDim2.new(0,56,0,22)
    T1.Position = UDim2.new(0.5,-56, 0,42)
    T1.BackgroundTransparency = 1
    T1.BorderSizePixel = 0
    T1.Text = "Primo"
    T1.TextColor3 = Theme.White
    T1.FontFace = FontMain
    T1.TextSize = 20
    T1.TextXAlignment = Enum.TextXAlignment.Right

    -- "Hub" accent text
    local T2 = Instance.new("TextLabel", Card)
    T2.Size = UDim2.new(0,46,0,22)
    T2.Position = UDim2.new(0.5,-2, 0,42)
    T2.BackgroundTransparency = 1
    T2.BorderSizePixel = 0
    T2.Text = "Hub"
    T2.TextColor3 = Theme.Accent
    T2.FontFace = FontMain
    T2.TextSize = 20
    T2.TextXAlignment = Enum.TextXAlignment.Left

    -- Status label
    local Status = Instance.new("TextLabel", Card)
    Status.Size = UDim2.new(1,0,0,18)
    Status.Position = UDim2.new(0,0, 0,68)
    Status.BackgroundTransparency = 1
    Status.BorderSizePixel = 0
    Status.Text = "Initializing..."
    Status.TextColor3 = Theme.Accent
    Status.FontFace = FontMain
    Status.TextSize = 13

    -- Progress bar track
    local BarBG = Instance.new("Frame", Card)
    BarBG.Size = UDim2.new(0,260,0,6)
    BarBG.Position = UDim2.new(0.5,-130, 0,90)
    BarBG.BackgroundColor3 = Theme.SliderTrack
    BarBG.BorderSizePixel = 0
    Corner(BarBG, 3)

    local Bar = Instance.new("Frame", BarBG)
    Bar.Size = UDim2.new(0,0,1,0)
    Bar.BackgroundColor3 = Theme.Accent
    Bar.BorderSizePixel = 0
    Corner(Bar, 3)

    -- Shimmer effect on bar
    local Shimmer = Instance.new("Frame", Bar)
    Shimmer.Size = UDim2.new(0,30,1,0)
    Shimmer.BackgroundColor3 = Theme.White
    Shimmer.BackgroundTransparency = 0.6
    Shimmer.BorderSizePixel = 0
    Corner(Shimmer, 3)

    local steps = {
        {text="Initializing Primo Hub...", pct=0.15},
        {text="Fetching Player Profile...", pct=0.45},
        {text="Building Interface...",      pct=0.75},
        {text="Applying Theme...",          pct=0.92},
        {text="Ready!",                    pct=1.0},
    }

    local idx = 0
    local function nextStep()
        idx = idx + 1
        if idx > #steps then
            -- fade out
            Tween(Dim, {BackgroundTransparency=1}, 0.45)
            Tween(Card, {BackgroundTransparency=1}, 0.35)
            task.delay(0.5, function()
                LGui:Destroy()
                if onFinish then onFinish() end
            end)
            return
        end
        local s = steps[idx]
        Status.Text = s.text
        Tween(Bar,    {Size=UDim2.new(s.pct,0,1,0)},    0.4)
        Tween(Shimmer,{Position=UDim2.new(s.pct,-15,0,0)},0.4)
        task.delay(0.55, nextStep)
    end
    nextStep()
end

-- ============================================================
--  MAIN UI BUILDER
-- ============================================================
local SIDEBAR_W  = 116
local SIDEBAR_H  = 278
local TITLE_H    = 24
local CONTENT_W  = 360
local CONTENT_H  = 254

local function BuildUI()
    -- Root ScreenGui
    local SG = Instance.new("ScreenGui", PlayerGui)
    SG.Name = "PrimoHub"
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    SG.ResetOnSpawn   = false
    SG.DisplayOrder   = 10

    -- ── MainContent ──────────────────────────────────────────
    local MC = Instance.new("Frame", SG)
    MC.Name = "MainContent"
    MC.BorderSizePixel = 0
    MC.BackgroundColor3 = Theme.Background
    MC.Size = UDim2.new(0, CONTENT_W, 0, CONTENT_H)
    MC.Position = UDim2.new(0, 268, 0, 68)   -- offset to account for title bar above

    -- ── SideBar ──────────────────────────────────────────────
    local SB = Instance.new("Frame", MC)
    SB.Name = "SideBar"
    SB.BorderSizePixel = 0
    SB.BackgroundColor3 = Theme.Sidebar
    SB.BackgroundTransparency = 0.3
    SB.Size = UDim2.new(0, SIDEBAR_W, 0, SIDEBAR_H)
    SB.Position = UDim2.new(0, -SIDEBAR_W, 0, -TITLE_H)

    -- ── TitleBar ─────────────────────────────────────────────
    local TB = Instance.new("Frame", MC)
    TB.Name = "TitleBar"
    TB.BorderSizePixel = 0
    TB.BackgroundColor3 = Theme.TitleBar
    TB.BackgroundTransparency = 0.3
    TB.Size = UDim2.new(0, CONTENT_W, 0, TITLE_H)
    TB.Position = UDim2.new(0, 0, 0, -TITLE_H)

    -- Title Icon
    local TIcon = Instance.new("ImageLabel", MC)
    TIcon.Name = "TitleIcon"
    TIcon.BorderSizePixel = 0
    TIcon.BackgroundTransparency = 1
    TIcon.Image = "rbxassetid://91306356501736"
    TIcon.Size = UDim2.new(0, 28, 0, 22)
    TIcon.Position = UDim2.new(0, 2, 0, -22)

    -- "Primo" label
    local Txt1 = Instance.new("TextLabel", MC)
    Txt1.Name = "Txt1"
    Txt1.BorderSizePixel = 0
    Txt1.BackgroundTransparency = 1
    Txt1.TextSize = 24
    Txt1.FontFace = FontMain
    Txt1.TextColor3 = Theme.White
    Txt1.Size = UDim2.new(0, 72, 0, 24)
    Txt1.Text = "Primo"
    Txt1.Position = UDim2.new(0, 28, 0, -24)
    Txt1.TextXAlignment = Enum.TextXAlignment.Left

    -- "Hub" accent label
    local Txt2 = Instance.new("TextLabel", MC)
    Txt2.Name = "Txt2"
    Txt2.BorderSizePixel = 0
    Txt2.BackgroundTransparency = 1
    Txt2.TextSize = 24
    Txt2.FontFace = FontMain
    Txt2.TextColor3 = Theme.Accent
    Txt2.Size = UDim2.new(0, 54, 0, 24)
    Txt2.Text = "Hub"
    Txt2.Position = UDim2.new(0, 76, 0, -24)
    Txt2.TextXAlignment = Enum.TextXAlignment.Left

    -- ── Close (X) Button ─────────────────────────────────────
    local XBtn = Instance.new("TextButton", MC)
    XBtn.Name = "X-button"
    XBtn.BorderSizePixel = 0
    XBtn.BackgroundTransparency = 0.3
    XBtn.BackgroundColor3 = Theme.CloseBtn
    XBtn.TextColor3 = Theme.White
    XBtn.FontFace = FontBold
    XBtn.TextSize = 13
    XBtn.Text = "✕"
    XBtn.Size = UDim2.new(0, 20, 0, 16)
    XBtn.Position = UDim2.new(0, 336, 0, -20)
    Corner(XBtn, 4)

    -- ── Minimize Button ───────────────────────────────────────
    local MinBtn = Instance.new("TextButton", MC)
    MinBtn.Name = "MinButton"
    MinBtn.BorderSizePixel = 0
    MinBtn.BackgroundTransparency = 0.3
    MinBtn.BackgroundColor3 = Theme.MinBtn
    MinBtn.TextColor3 = Theme.White
    MinBtn.FontFace = FontBold
    MinBtn.TextSize = 11
    MinBtn.Text = "─"
    MinBtn.Size = UDim2.new(0, 20, 0, 16)
    MinBtn.Position = UDim2.new(0, 312, 0, -20)
    Corner(MinBtn, 4)

    -- ── Player Profile (large avatar in sidebar) ──────────────
    local PP = Instance.new("ImageLabel", MC)
    PP.Name = "Player Profile"
    PP.BorderSizePixel = 0
    PP.BackgroundTransparency = 0.5
    PP.BackgroundColor3 = Theme.Tab
    PP.Size = UDim2.new(0, 72, 0, 76)
    PP.Position = UDim2.new(0, -96, 0, -16)
    PP.Image = ""
    Corner(PP, 8)
    Stroke(PP, Theme.Accent, 1)

    -- ── Dear / Greetings ─────────────────────────────────────
    local DearTxt = Instance.new("TextLabel", MC)
    DearTxt.Name = "DearTxt"
    DearTxt.BorderSizePixel = 0
    DearTxt.BackgroundTransparency = 1
    DearTxt.TextWrapped = true
    DearTxt.TextScaled = true
    DearTxt.FontFace = FontMain
    DearTxt.TextColor3 = Theme.White
    DearTxt.Size = UDim2.new(0, 104, 0, 22)
    DearTxt.Text = "Dear, " .. LocalPlayer.Name
    DearTxt.Position = UDim2.new(0, -108, 0, 64)
    DearTxt.TextXAlignment = Enum.TextXAlignment.Left

    local GreetTxt = Instance.new("TextLabel", MC)
    GreetTxt.Name = "Greetings"
    GreetTxt.BorderSizePixel = 0
    GreetTxt.BackgroundTransparency = 1
    GreetTxt.TextWrapped = true
    GreetTxt.TextScaled = true
    GreetTxt.FontFace = FontMain
    GreetTxt.TextColor3 = Theme.Accent
    GreetTxt.Size = UDim2.new(0, 108, 0, 46)
    GreetTxt.Text = "Welcome to\nPrimo Hub"
    GreetTxt.Position = UDim2.new(0, -112, 0, 84)
    GreetTxt.TextXAlignment = Enum.TextXAlignment.Left

    -- ── Mini Player Profile (sidebar bottom) ──────────────────
    local MiniPP = Instance.new("ImageLabel", MC)
    MiniPP.Name = "MiniPlayer Profile"
    MiniPP.BorderSizePixel = 0
    MiniPP.BackgroundTransparency = 0.5
    MiniPP.BackgroundColor3 = Theme.Tab
    MiniPP.Size = UDim2.new(0, 28, 0, 32)
    MiniPP.Position = UDim2.new(0, -114, 0, 220)
    MiniPP.Image = ""
    Corner(MiniPP, 4)
    Stroke(MiniPP, Theme.Accent, 1)

    -- ── Username ──────────────────────────────────────────────
    local UserLbl = Instance.new("TextLabel", MC)
    UserLbl.Name = "Username"
    UserLbl.BorderSizePixel = 0
    UserLbl.BackgroundTransparency = 1
    UserLbl.TextWrapped = true
    UserLbl.TextScaled = true
    UserLbl.FontFace = FontMain
    UserLbl.TextColor3 = Theme.White
    UserLbl.Size = UDim2.new(0, 80, 0, 32)
    UserLbl.Text = "@" .. LocalPlayer.Name
    UserLbl.Position = UDim2.new(0, -84, 0, 220)
    UserLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- ── Sidebar Divider ───────────────────────────────────────
    local SBDiv = Instance.new("Frame", MC)
    SBDiv.Name = "Divider"
    SBDiv.BorderSizePixel = 0
    SBDiv.BackgroundColor3 = Theme.Divider
    SBDiv.BackgroundTransparency = 0.6
    SBDiv.Size = UDim2.new(0, 100, 0, 1)
    SBDiv.Position = UDim2.new(0, -110, 0, 216)

    -- ── Main Divider (below tab bar) ──────────────────────────
    local MDiv = Instance.new("Frame", MC)
    MDiv.Name = "Main Divider"
    MDiv.BorderSizePixel = 0
    MDiv.BackgroundColor3 = Theme.Divider
    MDiv.BackgroundTransparency = 0.6
    MDiv.Size = UDim2.new(0, CONTENT_W, 0, 1)
    MDiv.Position = UDim2.new(0, 0, 0, 38)

    -- ── Tab Bar ───────────────────────────────────────────────
    local TabBar = Instance.new("Frame", MC)
    TabBar.Name = "TabBar"
    TabBar.BorderSizePixel = 0
    TabBar.BackgroundTransparency = 1
    TabBar.Size = UDim2.new(1, 0, 0, 36)
    TabBar.Position = UDim2.new(0, 0, 0, 2)

    local TabLayout = Instance.new("UIListLayout", TabBar)
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local TabPad = Instance.new("UIPadding", TabBar)
    TabPad.PaddingLeft = UDim.new(0, 6)

    -- ── Load Avatar Thumbnail ─────────────────────────────────
    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.AvatarBust,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if ok and img then
            PP.Image    = img
            MiniPP.Image = img
        end
    end)

    -- ============================================================
    --  TOGGLE BUTTON  (visible when GUI is closed)
    -- ============================================================
    local ToggleHolder = Instance.new("Frame", SG)
    ToggleHolder.Name = "ToggleHolder"
    ToggleHolder.Size = UDim2.new(0, 150, 0, 30)
    ToggleHolder.Position = UDim2.new(0, 10, 0, 10)
    ToggleHolder.BackgroundColor3 = Theme.TitleBar
    ToggleHolder.BackgroundTransparency = 0.3
    ToggleHolder.BorderSizePixel = 0
    ToggleHolder.Visible = false
    Corner(ToggleHolder, 6)
    Stroke(ToggleHolder, Theme.White)

    local TogIcon = Instance.new("ImageLabel", ToggleHolder)
    TogIcon.Size = UDim2.new(0, 22, 0, 17)
    TogIcon.Position = UDim2.new(0, 6, 0.5, -8)
    TogIcon.BackgroundTransparency = 1
    TogIcon.Image = "rbxassetid://91306356501736"
    TogIcon.BorderSizePixel = 0

    local Tog1 = Instance.new("TextLabel", ToggleHolder)
    Tog1.Size = UDim2.new(0, 48, 1, 0)
    Tog1.Position = UDim2.new(0, 32, 0, 0)
    Tog1.BackgroundTransparency = 1
    Tog1.BorderSizePixel = 0
    Tog1.Text = "Primo"
    Tog1.TextColor3 = Theme.White
    Tog1.FontFace = FontMain
    Tog1.TextSize = 15
    Tog1.TextXAlignment = Enum.TextXAlignment.Left

    local Tog2 = Instance.new("TextLabel", ToggleHolder)
    Tog2.Size = UDim2.new(0, 40, 1, 0)
    Tog2.Position = UDim2.new(0, 82, 0, 0)
    Tog2.BackgroundTransparency = 1
    Tog2.BorderSizePixel = 0
    Tog2.Text = "Hub"
    Tog2.TextColor3 = Theme.Accent
    Tog2.FontFace = FontMain
    Tog2.TextSize = 15
    Tog2.TextXAlignment = Enum.TextXAlignment.Left

    -- Invisible click layer over toggle holder
    local TClick = Instance.new("TextButton", ToggleHolder)
    TClick.Size = UDim2.new(1,0,1,0)
    TClick.BackgroundTransparency = 1
    TClick.BorderSizePixel = 0
    TClick.Text = ""

    -- ============================================================
    --  DRAGGING
    -- ============================================================
    local dragging, dragStart, dragOrigin = false, nil, nil

    local function StartDrag(input)
        dragging   = true
        dragStart  = input.Position
        dragOrigin = MC.Position
    end

    TB.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            StartDrag(i)
        end
    end)

    SB.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            StartDrag(i)
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType == Enum.UserInputType.MouseMovement
         or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            MC.Position = UDim2.new(
                dragOrigin.X.Scale, dragOrigin.X.Offset + d.X,
                dragOrigin.Y.Scale, dragOrigin.Y.Offset + d.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ============================================================
    --  CLOSE / MINIMIZE / TOGGLE LOGIC
    -- ============================================================
    local minimized = false

    -- Close
    XBtn.MouseButton1Click:Connect(function()
        Tween(MC, {Size = UDim2.new(0, CONTENT_W, 0, 0)}, 0.2)
        task.delay(0.2, function()
            MC.Visible = false
            MC.Size = UDim2.new(0, CONTENT_W, 0, CONTENT_H)
            ToggleHolder.Visible = true
        end)
    end)

    XBtn.MouseEnter:Connect(function() Tween(XBtn, {BackgroundTransparency=0}, 0.12) end)
    XBtn.MouseLeave:Connect(function() Tween(XBtn, {BackgroundTransparency=0.3}, 0.12) end)

    -- Minimize
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            for _, ch in pairs(MC:GetChildren()) do
                if ch.Name ~= "TitleBar" and ch ~= TB
                and ch.Name ~= "Txt1" and ch.Name ~= "Txt2"
                and ch.Name ~= "TitleIcon" and ch ~= XBtn and ch ~= MinBtn then
                    ch.Visible = false
                end
            end
            Tween(MC, {Size = UDim2.new(0, CONTENT_W, 0, 2)}, 0.22)
            MinBtn.Text = "□"
        else
            Tween(MC, {Size = UDim2.new(0, CONTENT_W, 0, CONTENT_H)}, 0.22)
            task.delay(0.22, function()
                for _, ch in pairs(MC:GetChildren()) do
                    ch.Visible = true
                end
            end)
            MinBtn.Text = "─"
        end
    end)

    MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundTransparency=0}, 0.12) end)
    MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundTransparency=0.3}, 0.12) end)

    -- Toggle (reopen)
    TClick.MouseButton1Click:Connect(function()
        ToggleHolder.Visible = false
        MC.Visible = true
        MC.Size = UDim2.new(0, CONTENT_W, 0, 0)
        Tween(MC, {Size = UDim2.new(0, CONTENT_W, 0, CONTENT_H)}, 0.22)
    end)

    -- ============================================================
    --  LIBRARY API
    -- ============================================================
    local Library = {}
    local AllTabs  = {}
    local activeTab = nil

    -- ── AddTab ───────────────────────────────────────────────
    function Library:AddTab(name)
        local tData = {Name=name, order=#AllTabs+1, itemOrder=0}

        -- Tab button
        local BtnW = math.clamp(#name * 9 + 20, 60, 110)
        local Btn = Instance.new("TextButton", TabBar)
        Btn.Name = name .. "_TabBtn"
        Btn.BorderSizePixel = 0
        Btn.TextScaled = true
        Btn.TextWrapped = true
        Btn.TextColor3 = Theme.White
        Btn.BackgroundColor3 = Theme.Tab
        Btn.FontFace = FontBold
        Btn.Size = UDim2.new(0, BtnW, 0, 22)
        Btn.Text = name
        Btn.LayoutOrder = tData.order
        Corner(Btn, 6)
        local bStroke = Stroke(Btn, Theme.White)

        -- Content host (holds the scroll frame)
        local Host = Instance.new("Frame", MC)
        Host.Name = name .. "_Content"
        Host.BorderSizePixel = 0
        Host.BackgroundTransparency = 1
        Host.Size = UDim2.new(0, CONTENT_W-10, 0, CONTENT_H-44)
        Host.Position = UDim2.new(0, 5, 0, 42)
        Host.Visible = false
        Host.ClipsDescendants = true

        local Scroll = Instance.new("ScrollingFrame", Host)
        Scroll.Name = "Scroll"
        Scroll.BorderSizePixel = 0
        Scroll.BackgroundTransparency = 1
        Scroll.Size = UDim2.new(1,0,1,0)
        Scroll.ScrollBarThickness = 3
        Scroll.ScrollBarImageColor3 = Theme.Accent
        Scroll.CanvasSize = UDim2.new(0,0,0,0)
        Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local SLayout = Instance.new("UIListLayout", Scroll)
        SLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SLayout.Padding = UDim.new(0, 5)
        SLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local SPad = Instance.new("UIPadding", Scroll)
        SPad.PaddingTop    = UDim.new(0, 4)
        SPad.PaddingBottom = UDim.new(0, 6)

        tData.Btn    = Btn
        tData.Stroke = bStroke
        tData.Host   = Host
        tData.Scroll = Scroll

        table.insert(AllTabs, tData)

        local function SelectThis()
            for _, t in ipairs(AllTabs) do
                t.Host.Visible = false
                Tween(t.Btn, {BackgroundColor3 = Theme.Tab}, 0.15)
                t.Stroke.Color = Theme.White
            end
            Host.Visible = true
            Tween(Btn, {BackgroundColor3 = Theme.TabActive}, 0.15)
            bStroke.Color = Theme.Accent
            activeTab = tData
        end

        Btn.MouseButton1Click:Connect(SelectThis)
        Btn.MouseEnter:Connect(function()
            if activeTab ~= tData then
                Tween(Btn, {BackgroundColor3 = Theme.TabHover}, 0.12)
            end
        end)
        Btn.MouseLeave:Connect(function()
            if activeTab ~= tData then
                Tween(Btn, {BackgroundColor3 = Theme.Tab}, 0.12)
            end
        end)

        if #AllTabs == 1 then SelectThis() end

        -- ===========================================================
        --  COMPONENT BUILDERS
        -- ===========================================================
        local function NextOrder()
            tData.itemOrder = tData.itemOrder + 1
            return tData.itemOrder
        end

        local ITEM_W = CONTENT_W - 30   -- standard component width

        -- ── Section Label ─────────────────────────────────────
        function tData:AddSection(text)
            local F = Instance.new("Frame", Scroll)
            F.Name = "Section_"..text
            F.BorderSizePixel = 0
            F.BackgroundTransparency = 1
            F.Size = UDim2.new(0, ITEM_W, 0, 26)
            F.LayoutOrder = NextOrder()

            local L = Instance.new("TextLabel", F)
            L.BorderSizePixel = 0
            L.BackgroundTransparency = 1
            L.Size = UDim2.new(1,-4,1,0)
            L.Position = UDim2.new(0,4,0,0)
            L.Text = text
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.TextColor3 = Theme.White
            L.FontFace = FontMain
            L.TextScaled = false
            L.TextSize = 13

            local Line = Instance.new("Frame", F)
            Line.BorderSizePixel = 0
            Line.BackgroundColor3 = Theme.Divider
            Line.BackgroundTransparency = 0.65
            Line.Size = UDim2.new(1,0,0,1)
            Line.Position = UDim2.new(0,0,1,-1)
        end

        -- ── Paragraph ─────────────────────────────────────────
        function tData:AddParagraph(title, body)
            local F = Instance.new("Frame", Scroll)
            F.Name = "Para_"..title
            F.BorderSizePixel = 0
            F.BackgroundColor3 = Theme.Button
            F.Size = UDim2.new(0, ITEM_W, 0, 0)
            F.AutomaticSize = Enum.AutomaticSize.Y
            F.LayoutOrder = NextOrder()
            Corner(F, 6)

            local Pad = Instance.new("UIPadding", F)
            Pad.PaddingTop    = UDim.new(0,6)
            Pad.PaddingBottom = UDim.new(0,6)
            Pad.PaddingLeft   = UDim.new(0,8)
            Pad.PaddingRight  = UDim.new(0,8)

            local IL = Instance.new("UIListLayout", F)
            IL.SortOrder = Enum.SortOrder.LayoutOrder
            IL.Padding   = UDim.new(0,2)

            local TL = Instance.new("TextLabel", F)
            TL.BorderSizePixel = 0
            TL.BackgroundTransparency = 1
            TL.Text = title
            TL.TextColor3 = Theme.Accent
            TL.FontFace = FontBold
            TL.TextSize = 13
            TL.TextXAlignment = Enum.TextXAlignment.Left
            TL.Size = UDim2.new(1,0,0,18)
            TL.LayoutOrder = 1

            local BL = Instance.new("TextLabel", F)
            BL.BorderSizePixel = 0
            BL.BackgroundTransparency = 1
            BL.TextWrapped = true
            BL.Text = body
            BL.TextColor3 = Color3.fromRGB(220,220,220)
            BL.FontFace = FontMain
            BL.TextSize = 12
            BL.TextXAlignment = Enum.TextXAlignment.Left
            BL.Size = UDim2.new(1,0,0,0)
            BL.AutomaticSize = Enum.AutomaticSize.Y
            BL.LayoutOrder = 2
        end

        -- ── Button ────────────────────────────────────────────
        function tData:AddButton(text, callback)
            local Btn2 = Instance.new("TextButton", Scroll)
            Btn2.Name = "Btn_"..text
            Btn2.BorderSizePixel = 0
            Btn2.TextScaled = true
            Btn2.TextWrapped = true
            Btn2.TextColor3 = Theme.White
            Btn2.BackgroundColor3 = Theme.Button
            Btn2.FontFace = FontBold
            Btn2.Size = UDim2.new(0, ITEM_W, 0, 40)
            Btn2.Text = text
            Btn2.LayoutOrder = NextOrder()
            Corner(Btn2, 6)

            Btn2.MouseEnter:Connect(function()
                Tween(Btn2, {BackgroundColor3 = Theme.ButtonHover}, 0.12)
            end)
            Btn2.MouseLeave:Connect(function()
                Tween(Btn2, {BackgroundColor3 = Theme.Button}, 0.12)
            end)
            Btn2.MouseButton1Click:Connect(function()
                Tween(Btn2, {BackgroundColor3 = Theme.Accent}, 0.08)
                task.delay(0.14, function()
                    Tween(Btn2, {BackgroundColor3 = Theme.Button}, 0.12)
                end)
                if callback then task.spawn(pcall, callback) end
            end)

            return Btn2
        end

        -- ── Toggle ────────────────────────────────────────────
        function tData:AddToggle(text, default, callback)
            local state = default == true

            local F = Instance.new("Frame", Scroll)
            F.Name = "Toggle_"..text
            F.BorderSizePixel = 0
            F.BackgroundColor3 = Theme.Button
            F.Size = UDim2.new(0, ITEM_W, 0, 40)
            F.LayoutOrder = NextOrder()
            Corner(F, 6)

            local Lbl = Instance.new("TextLabel", F)
            Lbl.BorderSizePixel = 0
            Lbl.BackgroundTransparency = 1
            Lbl.Size = UDim2.new(1,-58,1,0)
            Lbl.Position = UDim2.new(0,10,0,0)
            Lbl.Text = text
            Lbl.TextColor3 = Theme.White
            Lbl.FontFace = FontMain
            Lbl.TextScaled = true
            Lbl.TextWrapped = true
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local SW = Instance.new("Frame", F)
            SW.Size = UDim2.new(0,40,0,20)
            SW.Position = UDim2.new(1,-50,0.5,-10)
            SW.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
            SW.BorderSizePixel = 0
            Corner(SW, 10)

            local Knob = Instance.new("Frame", SW)
            Knob.Size = UDim2.new(0,16,0,16)
            Knob.Position = state
                and UDim2.new(1,-18,0.5,-8)
                or  UDim2.new(0,2, 0.5,-8)
            Knob.BackgroundColor3 = Theme.White
            Knob.BorderSizePixel  = 0
            Corner(Knob, 8)

            local CL = Instance.new("TextButton", F)
            CL.Size = UDim2.new(1,0,1,0)
            CL.BackgroundTransparency = 1
            CL.BorderSizePixel = 0
            CL.Text = ""

            local function SetState(v)
                state = v
                Tween(SW,   {BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff}, 0.18)
                Tween(Knob, {Position = state
                    and UDim2.new(1,-18,0.5,-8)
                    or  UDim2.new(0,2, 0.5,-8)}, 0.18)
            end

            CL.MouseButton1Click:Connect(function()
                SetState(not state)
                if callback then task.spawn(pcall, callback, state) end
            end)

            local obj = {}
            function obj:Set(v) SetState(v) end
            function obj:Get()  return state end
            return obj
        end

        -- ── Slider ────────────────────────────────────────────
        function tData:AddSlider(text, min, max, default, callback)
            min, max = min or 0, max or 100
            local val = math.clamp(default or min, min, max)

            local F = Instance.new("Frame", Scroll)
            F.Name = "Slider_"..text
            F.BorderSizePixel = 0
            F.BackgroundColor3 = Theme.Button
            F.Size = UDim2.new(0, ITEM_W, 0, 54)
            F.LayoutOrder = NextOrder()
            Corner(F, 6)

            local TxtL = Instance.new("TextLabel", F)
            TxtL.BorderSizePixel = 0
            TxtL.BackgroundTransparency = 1
            TxtL.Size = UDim2.new(0.65,0,0,22)
            TxtL.Position = UDim2.new(0,10,0,4)
            TxtL.Text = text
            TxtL.TextColor3 = Theme.White
            TxtL.FontFace = FontMain
            TxtL.TextSize = 13
            TxtL.TextXAlignment = Enum.TextXAlignment.Left

            local ValL = Instance.new("TextLabel", F)
            ValL.BorderSizePixel = 0
            ValL.BackgroundTransparency = 1
            ValL.Size = UDim2.new(0.35,-10,0,22)
            ValL.Position = UDim2.new(0.65,0,0,4)
            ValL.Text = tostring(val)
            ValL.TextColor3 = Theme.Accent
            ValL.FontFace = FontBold
            ValL.TextSize = 13
            ValL.TextXAlignment = Enum.TextXAlignment.Right

            local Track = Instance.new("Frame", F)
            Track.Size = UDim2.new(1,-20,0,8)
            Track.Position = UDim2.new(0,10,0,34)
            Track.BackgroundColor3 = Theme.SliderTrack
            Track.BorderSizePixel = 0
            Corner(Track, 4)

            local Fill = Instance.new("Frame", Track)
            local pct0 = (val-min)/(max-min)
            Fill.Size = UDim2.new(pct0,0,1,0)
            Fill.BackgroundColor3 = Theme.SliderFill
            Fill.BorderSizePixel = 0
            Corner(Fill, 4)

            local DotKnob = Instance.new("Frame", Track)
            DotKnob.Size = UDim2.new(0,14,0,14)
            DotKnob.Position = UDim2.new(pct0,-7,0.5,-7)
            DotKnob.BackgroundColor3 = Theme.White
            DotKnob.BorderSizePixel = 0
            Corner(DotKnob, 7)
            Stroke(DotKnob, Theme.Accent, 1)

            local slid = false

            local function Update(input)
                local ap = Track.AbsolutePosition
                local as = Track.AbsoluteSize
                local rx = math.clamp((input.Position.X - ap.X) / as.X, 0, 1)
                val = math.round(min + rx*(max-min))
                local p = (val-min)/(max-min)
                Fill.Size = UDim2.new(p,0,1,0)
                DotKnob.Position = UDim2.new(p,-7,0.5,-7)
                ValL.Text = tostring(val)
                if callback then task.spawn(pcall, callback, val) end
            end

            Track.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    slid = true ; Update(i)
                end
            end)
            DotKnob.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    slid = true
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if slid and (i.UserInputType == Enum.UserInputType.MouseMovement
                          or i.UserInputType == Enum.UserInputType.Touch) then
                    Update(i)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    slid = false
                end
            end)

            local obj = {}
            function obj:Set(v)
                val = math.clamp(v, min, max)
                local p = (val-min)/(max-min)
                Fill.Size = UDim2.new(p,0,1,0)
                DotKnob.Position = UDim2.new(p,-7,0.5,-7)
                ValL.Text = tostring(val)
            end
            function obj:Get() return val end
            return obj
        end

        -- ── TextBox ───────────────────────────────────────────
        function tData:AddTextBox(placeholder, default, callback)
            local F = Instance.new("Frame", Scroll)
            F.Name = "TextBox_"..placeholder
            F.BorderSizePixel = 0
            F.BackgroundColor3 = Theme.Button
            F.Size = UDim2.new(0, ITEM_W, 0, 42)
            F.LayoutOrder = NextOrder()
            Corner(F, 6)

            local TitleL = Instance.new("TextLabel", F)
            TitleL.BorderSizePixel = 0
            TitleL.BackgroundTransparency = 1
            TitleL.Size = UDim2.new(1,-10,0,16)
            TitleL.Position = UDim2.new(0,8,0,2)
            TitleL.Text = placeholder
            TitleL.TextColor3 = Theme.Accent
            TitleL.FontFace = FontMain
            TitleL.TextSize = 11
            TitleL.TextXAlignment = Enum.TextXAlignment.Left

            local TB2 = Instance.new("TextBox", F)
            TB2.Size = UDim2.new(1,-16,0,20)
            TB2.Position = UDim2.new(0,8,0,18)
            TB2.BackgroundColor3 = Theme.TextBoxBG
            TB2.BorderSizePixel = 0
            TB2.TextColor3 = Theme.White
            TB2.PlaceholderColor3 = Color3.fromRGB(140,140,140)
            TB2.PlaceholderText = "Type here..."
            TB2.Text = default or ""
            TB2.TextSize = 12
            TB2.FontFace = FontMain
            TB2.TextXAlignment = Enum.TextXAlignment.Left
            TB2.ClearTextOnFocus = false
            Corner(TB2, 4)

            local TBPad2 = Instance.new("UIPadding", TB2)
            TBPad2.PaddingLeft = UDim.new(0,6)

            local TBStr = Stroke(TB2, Color3.fromRGB(90,90,90), 1)

            TB2.Focused:Connect(function()
                Tween(TBStr, {Color = Theme.Accent}, 0.14)
            end)
            TB2.FocusLost:Connect(function(enter)
                Tween(TBStr, {Color = Color3.fromRGB(90,90,90)}, 0.14)
                if callback then task.spawn(pcall, callback, TB2.Text, enter) end
            end)

            local obj = {}
            function obj:Get()  return TB2.Text end
            function obj:Set(v) TB2.Text = v    end
            return obj
        end

        return tData
    end

    return Library
end

-- ============================================================
--  EXECUTE
-- ============================================================
CreateLoadingScreen(function()
    local Lib = BuildUI()

    -- ── Example Tabs & Components ────────────────────────────
    local Main     = Lib:AddTab("Main")
    local Player   = Lib:AddTab("Player")
    local Settings = Lib:AddTab("Settings")
    local Info     = Lib:AddTab("Info")

    -- Main Tab
    Main:AddSection("General")
    Main:AddButton("Example Button", function()
        print("[PrimoHub] Button clicked!")
    end)
    Main:AddToggle("Example Toggle", false, function(v)
        print("[PrimoHub] Toggle:", v)
    end)
    Main:AddSlider("Walk Speed", 0, 100, 16, function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end)
    Main:AddSlider("Jump Power", 0, 200, 50, function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = v
        end
    end)
    Main:AddTextBox("Custom Text", "", function(text)
        print("[PrimoHub] TextBox:", text)
    end)

    -- Player Tab
    Player:AddSection("Profile")
    Player:AddParagraph("Username", game.Players.LocalPlayer.Name)
    Player:AddParagraph("Display Name", game.Players.LocalPlayer.DisplayName)
    Player:AddParagraph("User ID", tostring(game.Players.LocalPlayer.UserId))
    Player:AddSection("Character")
    Player:AddToggle("Infinite Jump", false, function(v)
        -- Infinite jump logic
        if v then
            _G.InfJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if _G.InfJumpConn then
                _G.InfJumpConn:Disconnect()
                _G.InfJumpConn = nil
            end
        end
    end)
    Player:AddToggle("Noclip", false, function(v)
        _G.NoclipEnabled = v
        if v then
            _G.NoclipConn = game:GetService("RunService").Stepped:Connect(function()
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if _G.NoclipConn then
                _G.NoclipConn:Disconnect()
                _G.NoclipConn = nil
            end
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end)

    -- Settings Tab
    Settings:AddSection("Display")
    Settings:AddToggle("Notifications", true, function(v)
        print("[PrimoHub] Notifications:", v)
    end)
    Settings:AddSlider("UI Opacity", 0, 100, 70, function(v)
        print("[PrimoHub] Opacity:", v)
    end)
    Settings:AddTextBox("Custom Tab Name", "", function(text)
        print("[PrimoHub] Tab name:", text)
    end)

    -- Info Tab
    Info:AddSection("About")
    Info:AddParagraph("Primo Hub", "A feature-rich, fully functional UI library for Roblox.\n\nDraggable · Tabbed · Minimizable · Closeable")
    Info:AddParagraph("Version", "1.0.0  —  Built with style matching your original design.")
    Info:AddSection("Components Available")
    Info:AddParagraph("Buttons · Toggles · Sliders · TextBoxes · Sections · Paragraphs",
        "All components share the same colour palette, fonts, and corner style as your original code. Sliders, toggles and text boxes all return objects with :Get() and :Set() methods.")
end)
