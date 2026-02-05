-- Redesigned Script Searcher UI
-- Modern, clean interface with improved UX

local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local StarterGui = game:GetService('StarterGui')

-- Color Palette
local Colors = {
    Primary = Color3.fromRGB(99, 102, 241),      -- Indigo
    Secondary = Color3.fromRGB(139, 92, 246),    -- Purple
    Background = Color3.fromRGB(17, 24, 39),     -- Dark Gray
    Surface = Color3.fromRGB(31, 41, 55),        -- Medium Gray
    SurfaceLight = Color3.fromRGB(55, 65, 81),   -- Light Gray
    Text = Color3.fromRGB(243, 244, 246),        -- Off White
    TextSecondary = Color3.fromRGB(156, 163, 175), -- Gray
    Success = Color3.fromRGB(34, 197, 94),       -- Green
    Warning = Color3.fromRGB(251, 146, 60),      -- Orange
    Error = Color3.fromRGB(239, 68, 68),         -- Red
    Accent = Color3.fromRGB(59, 130, 246),       -- Blue
}

-- Create Main GUI
local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = 'ModernScriptSearcher'
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Main Container
local MainFrame = Instance.new('Frame')
MainFrame.Name = 'MainContainer'
MainFrame.BackgroundColor3 = Colors.Background
MainFrame.Size = UDim2.new(0, 520, 0, 650)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -325)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new('UICorner')
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new('UIStroke')
MainStroke.Color = Colors.SurfaceLight
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

-- Shadow Effect
local Shadow = Instance.new('ImageLabel')
Shadow.Name = 'Shadow'
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Image = 'rbxassetid://5554236805'
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- Header Section
local Header = Instance.new('Frame')
Header.Name = 'Header'
Header.BackgroundColor3 = Colors.Surface
Header.Size = UDim2.new(1, 0, 0, 70)
Header.Position = UDim2.new(0, 0, 0, 0)
Header.Parent = MainFrame

local HeaderCorner = Instance.new('UICorner')
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local HeaderCover = Instance.new('Frame')
HeaderCover.BackgroundColor3 = Colors.Surface
HeaderCover.BorderSizePixel = 0
HeaderCover.Size = UDim2.new(1, 0, 0, 20)
HeaderCover.Position = UDim2.new(0, 0, 1, -20)
HeaderCover.Parent = Header

-- Title
local Title = Instance.new('TextLabel')
Title.Name = 'Title'
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = '⚡ Script Searcher'
Title.TextColor3 = Colors.Text
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close Button
local CloseButton = Instance.new('TextButton')
CloseButton.Name = 'CloseButton'
CloseButton.BackgroundColor3 = Colors.Error
CloseButton.Size = UDim2.new(0, 36, 0, 36)
CloseButton.Position = UDim2.new(1, -50, 0.5, -18)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = '×'
CloseButton.TextColor3 = Colors.Text
CloseButton.TextSize = 24
CloseButton.Parent = Header

local CloseCorner = Instance.new('UICorner')
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Minimize Button
local MinimizeButton = Instance.new('TextButton')
MinimizeButton.Name = 'MinimizeButton'
MinimizeButton.BackgroundColor3 = Colors.Warning
MinimizeButton.Size = UDim2.new(0, 36, 0, 36)
MinimizeButton.Position = UDim2.new(1, -95, 0.5, -18)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Text = '−'
MinimizeButton.TextColor3 = Colors.Text
MinimizeButton.TextSize = 24
MinimizeButton.Parent = Header

local MinimizeCorner = Instance.new('UICorner')
MinimizeCorner.CornerRadius = UDim.new(0, 8)
MinimizeCorner.Parent = MinimizeButton

-- Search Section
local SearchContainer = Instance.new('Frame')
SearchContainer.Name = 'SearchContainer'
SearchContainer.BackgroundTransparency = 1
SearchContainer.Size = UDim2.new(1, -40, 0, 50)
SearchContainer.Position = UDim2.new(0, 20, 0, 85)
SearchContainer.Parent = MainFrame

local SearchBox = Instance.new('TextBox')
SearchBox.Name = 'SearchBox'
SearchBox.BackgroundColor3 = Colors.Surface
SearchBox.Size = UDim2.new(1, -120, 1, 0)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.Font = Enum.Font.Gotham
SearchBox.PlaceholderText = '🔍 Search scripts... (e.g., "Infinite Yield")'
SearchBox.PlaceholderColor3 = Colors.TextSecondary
SearchBox.Text = ''
SearchBox.TextColor3 = Colors.Text
SearchBox.TextSize = 14
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchContainer

local SearchBoxPadding = Instance.new('UIPadding')
SearchBoxPadding.PaddingLeft = UDim.new(0, 15)
SearchBoxPadding.Parent = SearchBox

local SearchBoxCorner = Instance.new('UICorner')
SearchBoxCorner.CornerRadius = UDim.new(0, 10)
SearchBoxCorner.Parent = SearchBox

local SearchButton = Instance.new('TextButton')
SearchButton.Name = 'SearchButton'
SearchButton.BackgroundColor3 = Colors.Primary
SearchButton.Size = UDim2.new(0, 100, 1, 0)
SearchButton.Position = UDim2.new(1, -100, 0, 0)
SearchButton.Font = Enum.Font.GothamBold
SearchButton.Text = 'Search'
SearchButton.TextColor3 = Colors.Text
SearchButton.TextSize = 14
SearchButton.Parent = SearchContainer

local SearchButtonCorner = Instance.new('UICorner')
SearchButtonCorner.CornerRadius = UDim.new(0, 10)
SearchButtonCorner.Parent = SearchButton

-- Results Container
local ResultsFrame = Instance.new('ScrollingFrame')
ResultsFrame.Name = 'ResultsFrame'
ResultsFrame.BackgroundColor3 = Colors.Background
ResultsFrame.BackgroundTransparency = 1
ResultsFrame.BorderSizePixel = 0
ResultsFrame.Size = UDim2.new(1, -40, 1, -225)
ResultsFrame.Position = UDim2.new(0, 20, 0, 150)
ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ResultsFrame.ScrollBarThickness = 6
ResultsFrame.ScrollBarImageColor3 = Colors.Primary
ResultsFrame.Parent = MainFrame

local ResultsLayout = Instance.new('UIListLayout')
ResultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ResultsLayout.Padding = UDim.new(0, 12)
ResultsLayout.Parent = ResultsFrame

-- Footer
local Footer = Instance.new('Frame')
Footer.Name = 'Footer'
Footer.BackgroundTransparency = 1
Footer.Size = UDim2.new(1, 0, 0, 50)
Footer.Position = UDim2.new(0, 0, 1, -50)
Footer.Parent = MainFrame

local PoweredBy = Instance.new('TextLabel')
PoweredBy.BackgroundTransparency = 1
PoweredBy.Size = UDim2.new(0.5, 0, 1, 0)
PoweredBy.Position = UDim2.new(0, 20, 0, 0)
PoweredBy.Font = Enum.Font.Gotham
PoweredBy.Text = '⚡ Powered by ScriptBlox'
PoweredBy.TextColor3 = Colors.TextSecondary
PoweredBy.TextSize = 12
PoweredBy.TextXAlignment = Enum.TextXAlignment.Left
PoweredBy.TextYAlignment = Enum.TextYAlignment.Center
PoweredBy.Parent = Footer

-- Script Card Template
local function CreateScriptCard()
    local Card = Instance.new('Frame')
    Card.Name = 'ScriptCard'
    Card.BackgroundColor3 = Colors.Surface
    Card.Size = UDim2.new(1, 0, 0, 160)
    Card.Visible = false
    
    local CardCorner = Instance.new('UICorner')
    CardCorner.CornerRadius = UDim.new(0, 12)
    CardCorner.Parent = Card
    
    local CardStroke = Instance.new('UIStroke')
    CardStroke.Color = Colors.SurfaceLight
    CardStroke.Thickness = 1
    CardStroke.Transparency = 0.7
    CardStroke.Parent = Card
    
    -- Thumbnail
    local Thumbnail = Instance.new('ImageLabel')
    Thumbnail.Name = 'Thumbnail'
    Thumbnail.BackgroundColor3 = Colors.SurfaceLight
    Thumbnail.Size = UDim2.new(0, 120, 0, 120)
    Thumbnail.Position = UDim2.new(0, 15, 0, 15)
    Thumbnail.Image = ''
    Thumbnail.ScaleType = Enum.ScaleType.Crop
    Thumbnail.Parent = Card
    
    local ThumbCorner = Instance.new('UICorner')
    ThumbCorner.CornerRadius = UDim.new(0, 8)
    ThumbCorner.Parent = Thumbnail
    
    -- Info Container
    local InfoContainer = Instance.new('Frame')
    InfoContainer.Name = 'InfoContainer'
    InfoContainer.BackgroundTransparency = 1
    InfoContainer.Size = UDim2.new(1, -155, 0, 90)
    InfoContainer.Position = UDim2.new(0, 145, 0, 15)
    InfoContainer.Parent = Card
    
    -- Script Title
    local ScriptTitle = Instance.new('TextLabel')
    ScriptTitle.Name = 'ScriptTitle'
    ScriptTitle.BackgroundTransparency = 1
    ScriptTitle.Size = UDim2.new(1, 0, 0, 20)
    ScriptTitle.Position = UDim2.new(0, 0, 0, 0)
    ScriptTitle.Font = Enum.Font.GothamBold
    ScriptTitle.Text = 'Script Name'
    ScriptTitle.TextColor3 = Colors.Text
    ScriptTitle.TextSize = 15
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left
    ScriptTitle.TextTruncate = Enum.TextTruncate.AtEnd
    ScriptTitle.Parent = InfoContainer
    
    -- Game Name
    local GameName = Instance.new('TextLabel')
    GameName.Name = 'GameName'
    GameName.BackgroundTransparency = 1
    GameName.Size = UDim2.new(1, 0, 0, 16)
    GameName.Position = UDim2.new(0, 0, 0, 24)
    GameName.Font = Enum.Font.Gotham
    GameName.Text = 'Universal'
    GameName.TextColor3 = Colors.TextSecondary
    GameName.TextSize = 12
    GameName.TextXAlignment = Enum.TextXAlignment.Left
    GameName.TextTruncate = Enum.TextTruncate.AtEnd
    GameName.Parent = InfoContainer
    
    -- Status Tags Container
    local TagsContainer = Instance.new('Frame')
    TagsContainer.Name = 'TagsContainer'
    TagsContainer.BackgroundTransparency = 1
    TagsContainer.Size = UDim2.new(1, 0, 0, 45)
    TagsContainer.Position = UDim2.new(0, 0, 0, 45)
    TagsContainer.Parent = InfoContainer
    
    local TagsLayout = Instance.new('UIListLayout')
    TagsLayout.FillDirection = Enum.FillDirection.Horizontal
    TagsLayout.Padding = UDim.new(0, 6)
    TagsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TagsLayout.Parent = TagsContainer
    
    -- Action Buttons Container
    local ButtonsContainer = Instance.new('Frame')
    ButtonsContainer.Name = 'ButtonsContainer'
    ButtonsContainer.BackgroundTransparency = 1
    ButtonsContainer.Size = UDim2.new(1, -30, 0, 32)
    ButtonsContainer.Position = UDim2.new(0, 15, 1, -45)
    ButtonsContainer.Parent = Card
    
    local ButtonsLayout = Instance.new('UIListLayout')
    ButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonsLayout.Padding = UDim.new(0, 8)
    ButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonsLayout.Parent = ButtonsContainer
    
    -- Execute Button
    local ExecuteButton = Instance.new('TextButton')
    ExecuteButton.Name = 'ExecuteButton'
    ExecuteButton.BackgroundColor3 = Colors.Success
    ExecuteButton.Size = UDim2.new(0.25, -6, 1, 0)
    ExecuteButton.Font = Enum.Font.GothamBold
    ExecuteButton.Text = '▶ Execute'
    ExecuteButton.TextColor3 = Colors.Text
    ExecuteButton.TextSize = 12
    ExecuteButton.Parent = ButtonsContainer
    
    local ExecCorner = Instance.new('UICorner')
    ExecCorner.CornerRadius = UDim.new(0, 6)
    ExecCorner.Parent = ExecuteButton
    
    -- Copy Button
    local CopyButton = Instance.new('TextButton')
    CopyButton.Name = 'CopyButton'
    CopyButton.BackgroundColor3 = Colors.Accent
    CopyButton.Size = UDim2.new(0.25, -6, 1, 0)
    CopyButton.Font = Enum.Font.GothamBold
    CopyButton.Text = '📋 Copy'
    CopyButton.TextColor3 = Colors.Text
    CopyButton.TextSize = 12
    CopyButton.Parent = ButtonsContainer
    
    local CopyCorner = Instance.new('UICorner')
    CopyCorner.CornerRadius = UDim.new(0, 6)
    CopyCorner.Parent = CopyButton
    
    -- Save Button
    local SaveButton = Instance.new('TextButton')
    SaveButton.Name = 'SaveButton'
    SaveButton.BackgroundColor3 = Colors.Secondary
    SaveButton.Size = UDim2.new(0.25, -6, 1, 0)
    SaveButton.Font = Enum.Font.GothamBold
    SaveButton.Text = '💾 Save'
    SaveButton.TextColor3 = Colors.Text
    SaveButton.TextSize = 12
    SaveButton.Parent = ButtonsContainer
    
    local SaveCorner = Instance.new('UICorner')
    SaveCorner.CornerRadius = UDim.new(0, 6)
    SaveCorner.Parent = SaveButton
    
    -- Hide Button
    local HideButton = Instance.new('TextButton')
    HideButton.Name = 'HideButton'
    HideButton.BackgroundColor3 = Colors.SurfaceLight
    HideButton.Size = UDim2.new(0.25, -6, 1, 0)
    HideButton.Font = Enum.Font.GothamBold
    HideButton.Text = '✕ Hide'
    HideButton.TextColor3 = Colors.Text
    HideButton.TextSize = 12
    HideButton.Parent = ButtonsContainer
    
    local HideCorner = Instance.new('UICorner')
    HideCorner.CornerRadius = UDim.new(0, 6)
    HideCorner.Parent = HideButton
    
    return Card
end

-- Create Status Tag
local function CreateTag(text, color)
    local Tag = Instance.new('Frame')
    Tag.BackgroundColor3 = color
    Tag.Size = UDim2.new(0, 0, 0, 20)
    Tag.AutomaticSize = Enum.AutomaticSize.X
    
    local TagCorner = Instance.new('UICorner')
    TagCorner.CornerRadius = UDim.new(0, 4)
    TagCorner.Parent = Tag
    
    local TagLabel = Instance.new('TextLabel')
    TagLabel.BackgroundTransparency = 1
    TagLabel.Size = UDim2.new(1, 0, 1, 0)
    TagLabel.Font = Enum.Font.GothamBold
    TagLabel.Text = text
    TagLabel.TextColor3 = Colors.Text
    TagLabel.TextSize = 10
    TagLabel.Parent = Tag
    
    local TagPadding = Instance.new('UIPadding')
    TagPadding.PaddingLeft = UDim.new(0, 8)
    TagPadding.PaddingRight = UDim.new(0, 8)
    TagPadding.Parent = Tag
    
    return Tag
end

-- Add Script to Results
local function AddScript(scriptData)
    local card = CreateScriptCard()
    card.Parent = ResultsFrame
    card.Visible = true
    
    -- Set thumbnail
    if scriptData.isUniversal then
        card.Thumbnail.Image = 'https://assetgame.roblox.com/Game/Tools/ThumbnailAsset.ashx?aid=' .. scriptData.game.gameId .. '&fmt=png&wd=420&ht=420'
    else
        pcall(function()
            card.Thumbnail.Image = 'https://scriptblox.com' .. scriptData.game.imageUrl
        end)
    end
    
    -- Set info
    card.InfoContainer.ScriptTitle.Text = scriptData.title
    card.InfoContainer.GameName.Text = scriptData.game.name
    
    -- Add tags
    local tagsContainer = card.InfoContainer.TagsContainer
    
    if scriptData.scriptType == 'free' then
        CreateTag('FREE', Colors.Success).Parent = tagsContainer
    else
        CreateTag('PAID', Colors.Warning).Parent = tagsContainer
    end
    
    if not scriptData.isPatched then
        CreateTag('✓ Working', Colors.Success).Parent = tagsContainer
    else
        CreateTag('✕ Patched', Colors.Error).Parent = tagsContainer
    end
    
    if scriptData.verified then
        CreateTag('⭐ Verified', Colors.Accent).Parent = tagsContainer
    end
    
    if scriptData.isUniversal then
        CreateTag('🌐 Universal', Colors.Secondary).Parent = tagsContainer
    end
    
    CreateTag('👁 ' .. tostring(scriptData.views), Colors.SurfaceLight).Parent = tagsContainer
    
    -- Button actions
    card.ButtonsContainer.ExecuteButton.MouseButton1Click:Connect(function()
        pcall(function()
            loadstring(scriptData.script)()
            StarterGui:SetCore('SendNotification', {
                Title = '✓ Executed',
                Text = 'Script executed successfully!',
                Duration = 3,
            })
        end)
    end)
    
    card.ButtonsContainer.CopyButton.MouseButton1Click:Connect(function()
        setclipboard(scriptData.script)
        StarterGui:SetCore('SendNotification', {
            Title = '📋 Copied',
            Text = 'Script copied to clipboard!',
            Duration = 3,
        })
    end)
    
    card.ButtonsContainer.SaveButton.MouseButton1Click:Connect(function()
        writefile(scriptData.title .. '.lua', scriptData.script)
        StarterGui:SetCore('SendNotification', {
            Title = '💾 Saved',
            Text = 'Script saved to workspace!',
            Duration = 3,
        })
    end)
    
    card.ButtonsContainer.HideButton.MouseButton1Click:Connect(function()
        card:Destroy()
    end)
    
    -- Hover effect
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Colors.SurfaceLight}):Play()
    end)
    
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Surface}):Play()
    end)
    
    -- Update canvas size
    ResultsFrame.CanvasSize = UDim2.new(0, 0, 0, ResultsLayout.AbsoluteContentSize.Y + 20)
end

-- Search Function
local function PerformSearch()
    local query = SearchBox.Text
    
    if query == '' then
        StarterGui:SetCore('SendNotification', {
            Title = '⚠ Warning',
            Text = 'Please enter a search query!',
            Duration = 3,
        })
        return
    end
    
    -- Clear existing results
    for _, child in ipairs(ResultsFrame:GetChildren()) do
        if child:IsA('Frame') then
            child:Destroy()
        end
    end
    
    -- Show loading
    SearchButton.Text = '⏳ Searching...'
    SearchButton.BackgroundColor3 = Colors.TextSecondary
    
    -- Fetch scripts
    local success, result = pcall(function()
        local url = 'https://www.scriptblox.com/api/script/search?q=' .. HttpService:UrlEncode(query)
        local response = game:HttpGetAsync(url)
        return HttpService:JSONDecode(response)
    end)
    
    SearchButton.Text = 'Search'
    SearchButton.BackgroundColor3 = Colors.Primary
    
    if success and result.result and result.result.scripts then
        for _, script in ipairs(result.result.scripts) do
            AddScript(script)
        end
        
        if #result.result.scripts == 0 then
            StarterGui:SetCore('SendNotification', {
                Title = '🔍 No Results',
                Text = 'No scripts found for "' .. query .. '"',
                Duration = 3,
            })
        end
    else
        StarterGui:SetCore('SendNotification', {
            Title = '❌ Error',
            Text = 'Failed to fetch scripts. Try again!',
            Duration = 3,
        })
    end
end

-- Button Connections
SearchButton.MouseButton1Click:Connect(PerformSearch)
SearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        PerformSearch()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    -- Create minimized icon (optional)
end)

-- Improved Universal Draggable Logic
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    -- Explicitly setting the position of the MainFrame
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

Header.InputBegan:Connect(function(input)
    -- Recognize both Mouse Click and Finger Touch
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        -- Keeps the drag active even if the finger/mouse leaves the Header area
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

game:GetService('UserInputService').InputChanged:Connect(function(input)
    -- This moves the frame while you are actively dragging
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Intro Animation
local function PlayIntro()
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    
    local introTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 520, 0, 650)
    })
    
    introTween:Play()
    
    wait(0.3)
    
    StarterGui:SetCore('SendNotification', {
        Title = '💅 Welcome!',
        Text = 'Welcome to Ternal Scriptblox Searcher, ' .. game.Players.LocalPlayer.DisplayName,
        Duration = 4,
    })
end

-- Button hover effects
local function AddButtonHover(button, hoverColor, normalColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

AddButtonHover(SearchButton, Color3.fromRGB(79, 82, 221), Colors.Primary)
AddButtonHover(CloseButton, Color3.fromRGB(220, 38, 38), Colors.Error)
AddButtonHover(MinimizeButton, Color3.fromRGB(234, 179, 8), Colors.Warning)

-- Play intro
PlayIntro()

-- Placeholder animation
task.spawn(function()
    local placeholders = {
        '🔍 Try "Infinite Yield"',
        '🔍 Try "Admin Commands"',
        '🔍 Try "Aimbot"',
        '🔍 Try "ESP"',
        '🔍 Try "Speed Hack"',
        '🔍 Try "Fly Script"',
    }
    
    wait(3)
    
    while true do
        for _, placeholder in ipairs(placeholders) do
            SearchBox.PlaceholderText = placeholder
            wait(3)
        end
    end
end)

return ScreenGui
