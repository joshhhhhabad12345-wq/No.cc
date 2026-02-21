-- ============================================================
-- BaldisUILib | Reusable UI Library v1.0
-- Classic 3D Bevel Style | Luau LocalScript for Roblox
-- Usage: local UI = require(path.to.BaldisUILib)
--        local win = UI:CreateWindow("My Menu v1.0")
--        win:Toggle("Label", false, function(state) end)
--        win:Button("Click Me", function() end)
--        win:Keybind("Speed Boost", Enum.KeyCode.X, function(key) end)
--        win:Label("Section Header")
--        win:Divider()
-- ============================================================

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")

local player           = Players.LocalPlayer

-- ============================================================
-- CONSTANTS & THEME
-- ============================================================
local THEME = {
    WindowBg        = Color3.fromRGB(30, 30, 30),
    ContentBg       = Color3.fromRGB(18, 18, 18),
    TitleBarBg      = Color3.fromRGB(160, 20, 20),
    TitleBarHL      = Color3.fromRGB(220, 80, 80),
    TitleBarShadow  = Color3.fromRGB(80, 5, 5),
    CloseBtnBg      = Color3.fromRGB(200, 30, 30),
    CloseBtnOuter   = Color3.fromRGB(80, 5, 5),
    RowEven         = Color3.fromRGB(22, 22, 22),
    RowOdd          = Color3.fromRGB(28, 28, 28),
    RowHover        = Color3.fromRGB(40, 40, 40),
    RowSep          = Color3.fromRGB(40, 40, 40),
    TextMain        = Color3.fromRGB(220, 220, 220),
    TextLabel       = Color3.fromRGB(200, 200, 80),
    TextDim         = Color3.fromRGB(90, 90, 90),
    TextTrue        = Color3.fromRGB(100, 255, 100),
    TextFalse       = Color3.fromRGB(255, 100, 100),
    ToggleOnBg      = Color3.fromRGB(15, 55, 15),
    ToggleOffBg     = Color3.fromRGB(55, 15, 15),
    ToggleOnFlash   = Color3.fromRGB(10, 35, 10),
    ToggleOffFlash  = Color3.fromRGB(35, 10, 10),
    BtnBg           = Color3.fromRGB(40, 40, 80),
    BtnHoverBg      = Color3.fromRGB(60, 60, 110),
    BtnHL           = Color3.fromRGB(80, 80, 80),
    KeybindBg       = Color3.fromRGB(40, 40, 40),
    KeybindActive   = Color3.fromRGB(60, 80, 40),
    DividerColor    = Color3.fromRGB(10, 10, 10),
    DividerHL       = Color3.fromRGB(50, 50, 50),
    BevelLight      = 1.5,    -- factor for top-left bevel
    BevelDark       = 0.35,   -- factor for bottom-right bevel
    BevelInset      = 3,      -- pixel inset per bevel layer
    RowH            = 24,
    TitleH          = 26,
    MenuW           = 340,
    Font            = Enum.Font.Code,
    TextSize        = 11,
}

-- ============================================================
-- INTERNAL HELPERS
-- ============================================================

-- Clamp a Color3 channel (0–1 range)
local function clamp01(v) return math.clamp(v, 0, 1) end

-- Build a 3D bevel frame (no drop shadow)
-- Returns (face, outerDark) — face is where you parent children
local function make3DFrame(parent, size, pos, baseColor, zBase, name)
    name = name or "Frame"
    local bi = THEME.BevelInset

    -- Dark border (bottom-right bevel)
    local darkBorder = Instance.new("Frame")
    darkBorder.Name = name .. "_Dark"
    darkBorder.Size = size
    darkBorder.Position = pos
    darkBorder.BackgroundColor3 = Color3.new(
        clamp01(baseColor.R * THEME.BevelDark),
        clamp01(baseColor.G * THEME.BevelDark),
        clamp01(baseColor.B * THEME.BevelDark)
    )
    darkBorder.BorderSizePixel = 0
    darkBorder.ZIndex = zBase
    darkBorder.Parent = parent

    -- Light border (top-left bevel)
    local lightBorder = Instance.new("Frame")
    lightBorder.Name = name .. "_Light"
    lightBorder.Size = UDim2.new(1, -bi, 1, -bi)
    lightBorder.Position = UDim2.new(0, 0, 0, 0)
    lightBorder.BackgroundColor3 = Color3.new(
        clamp01(baseColor.R * THEME.BevelLight),
        clamp01(baseColor.G * THEME.BevelLight),
        clamp01(baseColor.B * THEME.BevelLight)
    )
    lightBorder.BorderSizePixel = 0
    lightBorder.ZIndex = zBase + 1
    lightBorder.Parent = darkBorder

    -- Main face
    local face = Instance.new("Frame")
    face.Name = name .. "_Face"
    face.Size = UDim2.new(1, -4, 1, -4)
    face.Position = UDim2.new(0, 2, 0, 2)
    face.BackgroundColor3 = baseColor
    face.BorderSizePixel = 0
    face.ZIndex = zBase + 2
    face.Parent = lightBorder

    return face, darkBorder
end

-- Shared row builder (alternating background, separator, name label)
local function makeRow(parent, text, yOffset, zBase, textColor)
    local even = (math.floor(yOffset / THEME.RowH)) % 2 == 0
    local rowBg = Instance.new("Frame")
    rowBg.Size = UDim2.new(1, 0, 0, THEME.RowH)
    rowBg.Position = UDim2.new(0, 0, 0, yOffset)
    rowBg.BackgroundColor3 = even and THEME.RowEven or THEME.RowOdd
    rowBg.BorderSizePixel = 0
    rowBg.ZIndex = zBase
    rowBg.Parent = parent

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 1, -1)
    sep.BackgroundColor3 = THEME.RowSep
    sep.BorderSizePixel = 0
    sep.ZIndex = zBase + 1
    sep.Parent = rowBg

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textColor or THEME.TextMain
    lbl.TextSize = THEME.TextSize
    lbl.Font = THEME.Font
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextStrokeTransparency = 0.6
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.ZIndex = zBase + 1
    lbl.Parent = rowBg

    return rowBg, lbl
end

-- Row hover animation helpers
local function onEnter(rowBg)
    TweenService:Create(rowBg, TweenInfo.new(0.1), { BackgroundColor3 = THEME.RowHover }):Play()
end
local function onLeave(rowBg, yOffset)
    local even = (math.floor(yOffset / THEME.RowH)) % 2 == 0
    TweenService:Create(rowBg, TweenInfo.new(0.1), {
        BackgroundColor3 = even and THEME.RowEven or THEME.RowOdd
    }):Play()
end

-- Flash a row on click then restore
local function flashRow(rowBg, flashColor, yOffset)
    TweenService:Create(rowBg, TweenInfo.new(0.05), { BackgroundColor3 = flashColor }):Play()
    task.delay(0.15, function()
        local even = (math.floor(yOffset / THEME.RowH)) % 2 == 0
        TweenService:Create(rowBg, TweenInfo.new(0.1), {
            BackgroundColor3 = even and THEME.RowEven or THEME.RowOdd
        }):Play()
    end)
end

-- ============================================================
-- LIBRARY TABLE
-- ============================================================
local BaldisUILib = {}
BaldisUILib.__index = BaldisUILib

-- ============================================================
-- CreateWindow(title, options?)
--   options.x, options.y  — initial screen position (pixels)
--   options.width         — menu width (default 340)
--   options.toggleKey     — KeyCode to show/hide (default RightShift)
-- ============================================================
function BaldisUILib:CreateWindow(title, options)
    options = options or {}

    local W        = options.width      or THEME.MenuW
    local startX   = options.x          or 60
    local startY   = options.y          or 60
    local toggleKey = options.toggleKey or Enum.KeyCode.RightShift

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BaldisUI_" .. title:gsub("%s", "")
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = player.PlayerGui

    -- Container (draggable root, no visual background)
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, W + 8, 0, 100) -- height grows dynamically
    container.Position = UDim2.new(0, startX, 0, startY)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = 8
    container.Parent = screenGui

    -- Bevel panel (actual visual window)
    local panelFace, panelDark = make3DFrame(
        container,
        UDim2.new(0, W, 0, 100),
        UDim2.new(0, 0, 0, 0),
        THEME.WindowBg,
        9,
        "Panel"
    )

    -- ---- TITLE BAR ----
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, THEME.TitleH)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = THEME.TitleBarBg
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 15
    titleBar.Parent = panelFace

    -- Title bevel lines
    local function makeTitleLine(yPos, h, color)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, h)
        f.Position = UDim2.new(0, 0, yPos, yPos == 0 and 0 or -h)
        f.BackgroundColor3 = color
        f.BorderSizePixel = 0
        f.ZIndex = 16
        f.Parent = titleBar
    end
    makeTitleLine(0, 2, THEME.TitleBarHL)
    makeTitleLine(1, 2, THEME.TitleBarShadow)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -32, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = THEME.TextSize
    titleLabel.Font = THEME.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextStrokeTransparency = 0.5
    titleLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    titleLabel.ZIndex = 17
    titleLabel.Parent = titleBar

    -- ---- CLOSE BUTTON ----
    local closeBtnOuter = Instance.new("Frame")
    closeBtnOuter.Size = UDim2.new(0, 20, 0, 18)
    closeBtnOuter.Position = UDim2.new(1, -22, 0, 4)
    closeBtnOuter.BackgroundColor3 = THEME.CloseBtnOuter
    closeBtnOuter.BorderSizePixel = 0
    closeBtnOuter.ZIndex = 16
    closeBtnOuter.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(1, -2, 1, -2)
    closeBtn.Position = UDim2.new(0, 0, 0, 0)
    closeBtn.BackgroundColor3 = THEME.CloseBtnBg
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = THEME.TextSize
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 17
    closeBtn.Parent = closeBtnOuter

    -- ---- CONTENT FRAME ----
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -4, 1, -THEME.TitleH - 2)
    contentFrame.Position = UDim2.new(0, 2, 0, THEME.TitleH + 2)
    contentFrame.BackgroundColor3 = THEME.ContentBg
    contentFrame.BorderSizePixel = 0
    contentFrame.ZIndex = 14
    contentFrame.Parent = panelFace

    local contentHL = Instance.new("Frame")
    contentHL.Size = UDim2.new(1, 0, 0, 1)
    contentHL.Position = UDim2.new(0, 0, 0, 0)
    contentHL.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    contentHL.BorderSizePixel = 0
    contentHL.ZIndex = 15
    contentHL.Parent = contentFrame

    -- Window state
    local win = setmetatable({}, BaldisUILib)
    win._screenGui    = screenGui
    win._container    = container
    win._panelFace    = panelFace
    win._panelDark    = panelDark
    win._titleBar     = titleBar
    win._closeBtn     = closeBtn
    win._contentFrame = contentFrame
    win._yOffset      = 2   -- running y cursor inside contentFrame
    win._menuW        = W
    win._visible      = true
    win._toggleKey    = toggleKey
    win._keybindRegs  = {}  -- registered keybind callbacks

    -- ---- DRAGGING: PC (Mouse) + Mobile (Touch) ----
    local dragging = false
    local dragStartInput, startContainerPos

    local function onDragStart(input)
        dragging = true
        dragStartInput = input.Position
        startContainerPos = container.Position
    end

    local function onDragEnd()
        dragging = false
    end

    local function onDragMove(input)
        if not dragging then return end
        local delta = input.Position - dragStartInput
        container.Position = UDim2.new(
            startContainerPos.X.Scale, startContainerPos.X.Offset + delta.X,
            startContainerPos.Y.Scale, startContainerPos.Y.Offset + delta.Y
        )
    end

    -- Mouse drag
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragStart(input)
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragEnd()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            onDragMove(input)
        end
    end)

    -- Touch drag
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            onDragStart(input)
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            onDragEnd()
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            onDragMove(input)
        end
    end)

    -- ---- CLOSE / TOGGLE ----
    local function setVisible(v)
        win._visible = v
        if v then
            container.Visible = true
            panelDark.Size = UDim2.new(0, W, 0, 0)
            TweenService:Create(panelDark, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, W, 0, win._totalH)
            }):Play()
        else
            TweenService:Create(panelDark, TweenInfo.new(0.15), {
                Size = UDim2.new(0, W, 0, 0)
            }):Play()
            task.delay(0.18, function() container.Visible = false end)
        end
    end

    closeBtn.MouseButton1Click:Connect(function() setVisible(false) end)
    -- Touch close
    closeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            setVisible(false)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            setVisible(not win._visible)
        end
        -- Fire registered keybind callbacks
        for _, reg in ipairs(win._keybindRegs) do
            if not processed and input.KeyCode == reg.key then
                reg.callback(input.KeyCode)
            end
        end
    end)

    -- ---- RESIZE HELPER ----
    -- Called after each element is added
    function win:_resize()
        local contentH = self._yOffset + 2
        local totalH   = THEME.TitleH + 2 + contentH
        self._totalH   = totalH

        panelFace.Parent.Parent.Size = UDim2.new(0, W + 8, 0, totalH + 8)
        panelDark.Size               = UDim2.new(0, W, 0, totalH)
        panelFace.Parent.Size        = UDim2.new(1, -THEME.BevelInset, 1, -THEME.BevelInset)
        contentFrame.Size            = UDim2.new(1, -4, 1, -(THEME.TitleH + 2))
        container.Size               = UDim2.new(0, W + 8, 0, totalH + 8)
    end

    -- Initial slide-in
    win._totalH = 30
    panelDark.Size = UDim2.new(0, W, 0, 0)
    task.wait(0.1)
    TweenService:Create(panelDark, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, W, 0, 30)
    }):Play()

    return win
end

-- ============================================================
-- win:Toggle(label, default, callback?)
--   Adds a True/False toggle row
--   callback(state: boolean)
-- ============================================================
function BaldisUILib:Toggle(label, default, callback)
    local zBase  = 14
    local yOff   = self._yOffset

    local rowBg, _ = makeRow(self._contentFrame, label, yOff, zBase)

    -- Build 3D toggle button
    local btnOuter = Instance.new("Frame")
    btnOuter.Size = UDim2.new(0, 56, 0, 16)
    btnOuter.Position = UDim2.new(1, -64, 0.5, -8)
    btnOuter.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    btnOuter.BorderSizePixel = 0
    btnOuter.ZIndex = zBase + 2
    btnOuter.Parent = rowBg

    local state = default == true
    local btnFace = Instance.new("TextButton")
    btnFace.Size = UDim2.new(1, -2, 1, -2)
    btnFace.Position = UDim2.new(0, 0, 0, 0)
    btnFace.BorderSizePixel = 0
    btnFace.TextSize = THEME.TextSize
    btnFace.Font = THEME.Font
    btnFace.ZIndex = zBase + 3
    btnFace.Parent = btnOuter

    local btnHL = Instance.new("Frame")
    btnHL.Size = UDim2.new(1, 0, 0, 1)
    btnHL.Position = UDim2.new(0, 0, 0, 0)
    btnHL.BackgroundColor3 = THEME.BtnHL
    btnHL.BorderSizePixel = 0
    btnHL.ZIndex = zBase + 4
    btnHL.Parent = btnFace

    local function updateToggleVisual()
        btnFace.Text = state and "True" or "False"
        btnFace.TextColor3 = state and THEME.TextTrue or THEME.TextFalse
        btnFace.BackgroundColor3 = state and THEME.ToggleOnBg or THEME.ToggleOffBg
    end
    updateToggleVisual()

    -- Hover
    btnFace.MouseEnter:Connect(function() onEnter(rowBg) end)
    btnFace.MouseLeave:Connect(function() onLeave(rowBg, yOff) end)

    -- Press animation
    btnFace.MouseButton1Down:Connect(function() btnFace.Position = UDim2.new(0, 1, 0, 1) end)
    btnFace.MouseButton1Up:Connect(function() btnFace.Position = UDim2.new(0, 0, 0, 0) end)

    -- Click
    local function toggle()
        state = not state
        updateToggleVisual()
        flashRow(rowBg, state and THEME.ToggleOnFlash or THEME.ToggleOffFlash, yOff)
        if callback then callback(state) end
    end
    btnFace.MouseButton1Click:Connect(toggle)
    -- Touch
    btnFace.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then toggle() end
    end)

    self._yOffset = yOff + THEME.RowH
    self:_resize()

    -- Return controller so caller can read/set state programmatically
    return {
        GetState = function() return state end,
        SetState = function(_, v)
            state = v == true
            updateToggleVisual()
        end,
    }
end

-- ============================================================
-- win:Button(label, callback?)
--   Adds a clickable button row
--   callback()
-- ============================================================
function BaldisUILib:Button(label, callback)
    local zBase = 14
    local yOff  = self._yOffset

    local rowBg, _ = makeRow(self._contentFrame, label, yOff, zBase)

    -- 3D bevel button on the right side
    local btnOuter = Instance.new("Frame")
    btnOuter.Size = UDim2.new(0, 60, 0, 16)
    btnOuter.Position = UDim2.new(1, -68, 0.5, -8)
    btnOuter.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    btnOuter.BorderSizePixel = 0
    btnOuter.ZIndex = zBase + 2
    btnOuter.Parent = rowBg

    local btnFace = Instance.new("TextButton")
    btnFace.Size = UDim2.new(1, -2, 1, -2)
    btnFace.Position = UDim2.new(0, 0, 0, 0)
    btnFace.BackgroundColor3 = THEME.BtnBg
    btnFace.BorderSizePixel = 0
    btnFace.Text = "RUN"
    btnFace.TextColor3 = Color3.new(1, 1, 1)
    btnFace.TextSize = THEME.TextSize
    btnFace.Font = THEME.Font
    btnFace.ZIndex = zBase + 3
    btnFace.Parent = btnOuter

    local btnHL = Instance.new("Frame")
    btnHL.Size = UDim2.new(1, 0, 0, 1)
    btnHL.Position = UDim2.new(0, 0, 0, 0)
    btnHL.BackgroundColor3 = THEME.BtnHL
    btnHL.BorderSizePixel = 0
    btnHL.ZIndex = zBase + 4
    btnHL.Parent = btnFace

    -- Hover
    btnFace.MouseEnter:Connect(function()
        TweenService:Create(btnFace, TweenInfo.new(0.1), { BackgroundColor3 = THEME.BtnHoverBg }):Play()
        onEnter(rowBg)
    end)
    btnFace.MouseLeave:Connect(function()
        TweenService:Create(btnFace, TweenInfo.new(0.1), { BackgroundColor3 = THEME.BtnBg }):Play()
        onLeave(rowBg, yOff)
    end)

    -- Press animation
    btnFace.MouseButton1Down:Connect(function() btnFace.Position = UDim2.new(0, 1, 0, 1) end)
    btnFace.MouseButton1Up:Connect(function() btnFace.Position = UDim2.new(0, 0, 0, 0) end)

    local function fire()
        flashRow(rowBg, THEME.BtnHoverBg, yOff)
        if callback then callback() end
    end
    btnFace.MouseButton1Click:Connect(fire)
    btnFace.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            btnFace.Position = UDim2.new(0, 1, 0, 1)
            task.wait(0.08)
            btnFace.Position = UDim2.new(0, 0, 0, 0)
            fire()
        end
    end)

    self._yOffset = yOff + THEME.RowH
    self:_resize()
end

-- ============================================================
-- win:Keybind(label, defaultKey, callback?)
--   Shows current binding. Click to rebind. Press key to bind.
--   callback(keyCode: Enum.KeyCode)  — fires on the bound key
-- ============================================================
function BaldisUILib:Keybind(label, defaultKey, callback)
    local zBase = 14
    local yOff  = self._yOffset

    local rowBg, _ = makeRow(self._contentFrame, label, yOff, zBase)

    local boundKey = defaultKey or Enum.KeyCode.Unknown
    local listening = false

    local btnOuter = Instance.new("Frame")
    btnOuter.Size = UDim2.new(0, 70, 0, 16)
    btnOuter.Position = UDim2.new(1, -78, 0.5, -8)
    btnOuter.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    btnOuter.BorderSizePixel = 0
    btnOuter.ZIndex = zBase + 2
    btnOuter.Parent = rowBg

    local btnFace = Instance.new("TextButton")
    btnFace.Size = UDim2.new(1, -2, 1, -2)
    btnFace.Position = UDim2.new(0, 0, 0, 0)
    btnFace.BackgroundColor3 = THEME.KeybindBg
    btnFace.BorderSizePixel = 0
    btnFace.TextSize = THEME.TextSize
    btnFace.Font = THEME.Font
    btnFace.ZIndex = zBase + 3
    btnFace.Parent = btnOuter

    local function getKeyName(kc)
        local s = tostring(kc)
        return s:match("Enum%.KeyCode%.(.+)") or s
    end

    local function setLabel()
        if listening then
            btnFace.Text = "..."
            btnFace.TextColor3 = Color3.fromRGB(255, 220, 60)
            btnFace.BackgroundColor3 = Color3.fromRGB(50, 40, 10)
        else
            btnFace.Text = "[" .. getKeyName(boundKey) .. "]"
            btnFace.TextColor3 = Color3.new(1, 1, 1)
            btnFace.BackgroundColor3 = THEME.KeybindActive
        end
    end
    setLabel()

    -- Click to enter listening mode
    local function startListen()
        listening = true
        setLabel()
    end
    btnFace.MouseButton1Click:Connect(startListen)
    btnFace.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then startListen() end
    end)

    -- Listen for next key press
    UserInputService.InputBegan:Connect(function(input, processed)
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            listening = false
            boundKey = input.KeyCode
            setLabel()
            flashRow(rowBg, THEME.KeybindActive, yOff)
        end
    end)

    -- Register callback for bound key
    table.insert(self._keybindRegs, {
        key = function() return boundKey end,
        callback = callback or function() end,
    })

    -- Actually, rebuild to use dynamic getter:
    -- (replace simple key check in window's InputBegan with dynamic getter)
    -- Remove last inserted and re-insert with proper dynamic getter
    self._keybindRegs[#self._keybindRegs] = {
        getKey  = function() return boundKey end,
        callback = callback or function() end,
    }

    -- Patch the window's global keybind handler (done once in CreateWindow for static keys)
    -- For dynamic keybinds we need a separate hook:
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
            if not listening and input.KeyCode == boundKey then
                if callback then callback(boundKey) end
            end
        end
    end)

    -- Hover
    btnFace.MouseEnter:Connect(function() onEnter(rowBg) end)
    btnFace.MouseLeave:Connect(function() onLeave(rowBg, yOff) end)

    self._yOffset = yOff + THEME.RowH
    self:_resize()

    return {
        GetKey = function() return boundKey end,
        SetKey = function(_, kc) boundKey = kc; setLabel() end,
    }
end

-- ============================================================
-- win:Label(text, color?)
--   Adds a static section/header label row
-- ============================================================
function BaldisUILib:Label(text, color)
    local zBase = 14
    local yOff  = self._yOffset

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 20)
    lbl.Position = UDim2.new(0, 8, 0, yOff + 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or THEME.TextLabel
    lbl.TextSize = THEME.TextSize
    lbl.Font = THEME.Font
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextStrokeTransparency = 0.5
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.ZIndex = zBase + 1
    lbl.Parent = self._contentFrame

    self._yOffset = yOff + 32
    self:_resize()
end

-- ============================================================
-- win:Divider()
--   Adds a horizontal divider line
-- ============================================================
function BaldisUILib:Divider()
    local zBase = 14
    local yOff  = self._yOffset

    local div = Instance.new("Frame")
    div.Size = UDim2.new(1, -16, 0, 2)
    div.Position = UDim2.new(0, 8, 0, yOff + 4)
    div.BackgroundColor3 = THEME.DividerColor
    div.BorderSizePixel = 0
    div.ZIndex = zBase
    div.Parent = self._contentFrame

    local divHL = Instance.new("Frame")
    divHL.Size = UDim2.new(1, 0, 0, 1)
    divHL.Position = UDim2.new(0, 0, 1, 0)
    divHL.BackgroundColor3 = THEME.DividerHL
    divHL.BorderSizePixel = 0
    divHL.ZIndex = zBase + 1
    divHL.Parent = div

    self._yOffset = yOff + 12
    self:_resize()
end

-- ============================================================
-- win:Spacer(height?)
--   Adds blank vertical space
-- ============================================================
function BaldisUILib:Spacer(height)
    self._yOffset = self._yOffset + (height or 8)
    self:_resize()
end

-- ============================================================
-- win:Destroy()
--   Removes the window entirely
-- ============================================================
function BaldisUILib:Destroy()
    self._screenGui:Destroy()
end

-- ============================================================
-- RETURN LIBRARY
-- ============================================================
return BaldisUILib
