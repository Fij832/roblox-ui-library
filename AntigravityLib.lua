--[[
    Lori Premium Roblox UI Library
    Version: 1.4.0
    Author: Lori Team / Antigravity
    Aesthetic: Razor-Sharp Cybernetic Glassmorphic theme with Unlimited Dragging, Smooth Easing, and Crimson Neon Accents!
    
    Usage:
    local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Fij832/roblox-ui-library/main/AntigravityLib.lua"))()
    local Window = Lib:CreateWindow({ Name = "Lori" })
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AntigravityLib = {}
AntigravityLib.Theme = {
    Background = Color3.fromRGB(8, 6, 14),      -- Obsidian Glass
    Sidebar = Color3.fromRGB(5, 4, 8),          -- Dark Sidebar
    WidgetBackground = Color3.fromRGB(15, 12, 26),
    AccentPrimary = Color3.fromRGB(244, 63, 94),   -- Tech Crimson Accent
    AccentSecondary = Color3.fromRGB(6, 182, 212), -- Ice Cyan Accent
    TextMain = Color3.fromRGB(249, 248, 252),
    TextMuted = Color3.fromRGB(149, 144, 171),
    TextDim = Color3.fromRGB(60, 55, 75),          -- Flat dim gray (fixed scrollingframe bug)
    Border = Color3.fromRGB(40, 35, 55)
}

local WindowMetatable = {}
WindowMetatable.__index = WindowMetatable

local TabMetatable = {}
TabMetatable.__index = TabMetatable

local FolderMetatable = {}
FolderMetatable.__index = FolderMetatable

-- Easing Tweens Utility
local function Tween(object, info, properties)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

-- Responsive Dragging Utility (With Unrestricted Screen boundaries!)
local function MakeDraggable(frame, handle, tiltEnabled)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        -- Free dragging - no border clamps, let user move it anywhere!
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        Tween(frame, TweenInfo.new(0.08, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), { Position = newPos })
        
        if tiltEnabled then
            -- Micro-tilt action (cybernetic rotation feeling)
            local tiltAngle = math.clamp(delta.X * 0.03, -2, 2)
            Tween(frame, TweenInfo.new(0.15, Enum.EasingStyle.Out), { Rotation = tiltAngle })
        end
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    Tween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Out), { Rotation = 0 })
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ==========================================================================
-- CREATE WINDOW (RAZOR-SHARP CYBERNETIC STYLE)
-- ==========================================================================
function AntigravityLib:CreateWindow(config)
    config = config or {}
    local name = config.Name or "Lori"
    local accentColor = config.ThemeAccent or AntigravityLib.Theme.AccentPrimary
    local toggleKey = config.DefaultToggleKey or Enum.KeyCode.RightControl
    local tilt = config.ResponsiveTilt ~= nil and config.ResponsiveTilt or true
    
    -- Root ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Lori_" .. name:gsub("%s+", "")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Support CoreGui Injection
    local success, _ = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
    MainFrame.BackgroundColor3 = AntigravityLib.Theme.Background
    MainFrame.BackgroundTransparency = 0.12 -- Slightly translucent glass look
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- NOTE: Razor-Sharp Style. No UICorners added, giving clean 90-degree edges!
    
    -- Beautiful Accent Colored Outline Border (Cyber outline matching the browser)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1.0
    UIStroke.Color = accentColor
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = MainFrame
    
    -- Top Glowing Accent Bar
    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Size = UDim2.new(1, 0, 0, 2)
    AccentBar.BackgroundColor3 = accentColor
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = MainFrame
    
    -- Titlebar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 44)
    TitleBar.Position = UDim2.new(0, 0, 0, 2)
    TitleBar.BackgroundColor3 = Color3.fromRGB(5, 4, 8)
    TitleBar.BackgroundTransparency = 0.5
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    -- Shield Icon in Titlebar
    local ShieldIcon = Instance.new("ImageLabel")
    ShieldIcon.Name = "ShieldIcon"
    ShieldIcon.Size = UDim2.new(0, 14, 0, 14)
    ShieldIcon.Position = UDim2.new(0, 16, 0.5, -7)
    ShieldIcon.BackgroundTransparency = 1
    ShieldIcon.Image = "rbxassetid://6034854524" -- Cyber shield icon
    ShieldIcon.ImageColor3 = accentColor
    ShieldIcon.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 38, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = name:upper()
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextColor3 = AntigravityLib.Theme.TextMain
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    local TitleSubtitle = Instance.new("TextLabel")
    TitleSubtitle.Name = "TitleSubtitle"
    TitleSubtitle.Size = UDim2.new(0.2, 0, 1, 0)
    TitleSubtitle.Position = UDim2.new(0, 85, 0, 0)
    TitleSubtitle.BackgroundTransparency = 1
    TitleSubtitle.Text = "| v1.4.0"
    TitleSubtitle.Font = Enum.Font.Code
    TitleSubtitle.TextSize = 10
    TitleSubtitle.TextColor3 = AntigravityLib.Theme.TextMuted
    TitleSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    TitleSubtitle.Parent = TitleBar
    
    -- Close and Minimize Control Buttons
    local Controls = Instance.new("Frame")
    Controls.Name = "Controls"
    Controls.Size = UDim2.new(0, 60, 1, 0)
    Controls.Position = UDim2.new(1, -70, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = TitleBar
    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    MinimizeBtn.Position = UDim2.new(0, 4, 0.5, -12)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "—"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 10
    MinimizeBtn.TextColor3 = AntigravityLib.Theme.TextMuted
    MinimizeBtn.Parent = Controls
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(0, 32, 0.5, -12)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 10
    CloseBtn.TextColor3 = AntigravityLib.Theme.TextMuted
    CloseBtn.Parent = Controls
    
    -- Left Nav Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -46)
    Sidebar.Position = UDim2.new(0, 0, 0, 46)
    Sidebar.BackgroundColor3 = AntigravityLib.Theme.Sidebar
    Sidebar.BackgroundTransparency = 0.45
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    -- Sidebar vertical separator line (matches web style)
    local Separator = Instance.new("Frame")
    Separator.Name = "Separator"
    Separator.Size = UDim2.new(0, 1, 1, 0)
    Separator.Position = UDim2.new(1, -1, 0, 0)
    Separator.BackgroundColor3 = AntigravityLib.Theme.Border
    Separator.BorderSizePixel = 0
    Separator.Parent = Sidebar
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 2)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 12)
    SidebarPadding.Parent = Sidebar
    
    -- Content Frame Panel
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name = "ContentPanel"
    ContentPanel.Size = UDim2.new(1, -140, 1, -46)
    ContentPanel.Position = UDim2.new(0, 140, 0, 46)
    ContentPanel.BackgroundTransparency = 1
    ContentPanel.Parent = MainFrame
    
    MakeDraggable(MainFrame, TitleBar, tilt)
    
    local WindowObj = {
        Gui = ScreenGui,
        Main = MainFrame,
        Content = ContentPanel,
        Sidebar = Sidebar,
        Accent = accentColor,
        ToggleKey = toggleKey,
        Tabs = {},
        CurrentTab = nil,
        Visible = true
    }
    
    -- Control actions events
    MinimizeBtn.MouseEnter:Connect(function()
        MinimizeBtn.TextColor3 = AntigravityLib.Theme.TextMain
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        MinimizeBtn.TextColor3 = AntigravityLib.Theme.TextMuted
    end)
    MinimizeBtn.MouseButton1Click:Connect(function()
        WindowObj.Visible = not WindowObj.Visible
        if WindowObj.Visible then
            Tween(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), { Size = UDim2.new(0, 520, 0, 380) })
        else
            Tween(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.In), { Size = UDim2.new(0, 520, 0, 46) })
        end
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        CloseBtn.TextColor3 = Color3.fromRGB(239, 68, 68)
    end)
    CloseBtn.MouseLeave:Connect(function()
        CloseBtn.TextColor3 = AntigravityLib.Theme.TextMuted
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        WindowObj:Destroy()
    end)
    
    -- Toggle UI visibility binding
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == WindowObj.ToggleKey then
            WindowObj.Visible = not WindowObj.Visible
            MainFrame.Visible = WindowObj.Visible
            if WindowObj.Visible then
                Tween(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), { Size = UDim2.new(0, 520, 0, 380) })
            else
                Tween(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.In), { Size = UDim2.new(0, 520, 0, 0) })
            end
        end
    end)
    
    setmetatable(WindowObj, WindowMetatable)
    return WindowObj
end

-- ==========================================================================
-- CREATE TAB
-- ==========================================================================
function WindowMetatable:CreateTab(tabName, iconId)
    local WindowObj = self
    
    -- Map default names to high-fidelity icons
    local activeIcon = iconId
    if not activeIcon then
        local upperName = tabName:upper()
        if upperName == "COMBAT" then
            activeIcon = "rbxassetid://6035041403" -- Crosshair icon
        elseif upperName == "VISUALS" then
            activeIcon = "rbxassetid://6031763426" -- Eye icon
        elseif upperName == "SETTINGS" then
            activeIcon = "rbxassetid://6031289139" -- Sliders icon
        else
            activeIcon = "rbxassetid://6031075932" -- Dot/bullet icon
        end
    end
    
    -- Create Sidebar tab button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName .. "_Btn"
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "      " .. tabName:upper() -- Indent for icon placement
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 11
    TabBtn.TextColor3 = AntigravityLib.Theme.TextMuted
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = WindowObj.Sidebar
    
    -- Tab Icon Label
    local TabIcon = Instance.new("ImageLabel")
    TabIcon.Name = "Icon"
    TabIcon.Size = UDim2.new(0, 13, 0, 13)
    TabIcon.Position = UDim2.new(0, 12, 0.5, -6)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Image = activeIcon
    TabIcon.ImageColor3 = AntigravityLib.Theme.TextMuted
    TabIcon.Parent = TabBtn
    
    -- Sharp Sidebar indicator glow line
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 2, 1, 0)
    Indicator.Position = UDim2.new(0, 0, 0, 0)
    Indicator.BackgroundColor3 = WindowObj.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = TabBtn
    
    -- Scroll view for tab content
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Name = tabName .. "_Scroll"
    TabScroll.Size = UDim2.new(1, 0, 1, 0)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 2 -- Thinner flat scrollbar
    TabScroll.ScrollBarImageColor3 = AntigravityLib.Theme.TextDim -- TextDim is now defined in theme, resolving Roblox error!
    TabScroll.Visible = false
    TabScroll.Parent = WindowObj.Content
    
    local ScrollLayout = Instance.new("UIListLayout")
    ScrollLayout.Padding = UDim.new(0, 10)
    ScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ScrollLayout.Parent = TabScroll
    
    local ScrollPadding = Instance.new("UIPadding")
    ScrollPadding.PaddingTop = UDim.new(0, 14)
    ScrollPadding.PaddingBottom = UDim.new(0, 14)
    ScrollPadding.Parent = TabScroll
    
    local TabObj = {
        Name = tabName,
        Window = WindowObj,
        Button = TabBtn,
        Scroll = TabScroll,
        Folders = {}
    }
    
    -- Activate Tab Callback
    local function selectTab()
        if WindowObj.CurrentTab then
            WindowObj.CurrentTab.Button.TextColor3 = AntigravityLib.Theme.TextMuted
            WindowObj.CurrentTab.Button.Icon.ImageColor3 = AntigravityLib.Theme.TextMuted
            WindowObj.CurrentTab.Button.Indicator.Visible = false
            WindowObj.CurrentTab.Scroll.Visible = false
        end
        
        WindowObj.CurrentTab = TabObj
        TabBtn.TextColor3 = WindowObj.Accent
        TabIcon.ImageColor3 = WindowObj.Accent
        Indicator.Visible = true
        TabScroll.Visible = true
        
        -- Flat Slide Transition
        TabScroll.Position = UDim2.new(0, 8, 0, 0)
        Tween(TabScroll, TweenInfo.new(0.2, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), { Position = UDim2.new(0, 0, 0, 0) })
    end
    
    TabBtn.MouseButton1Click:Connect(selectTab)
    
    -- Select first tab automatically
    if not WindowObj.CurrentTab then
        selectTab()
    end
    
    setmetatable(TabObj, TabMetatable)
    return TabObj
end

-- ==========================================================================
-- CREATE FOLDER / SECTION
-- ==========================================================================
function TabMetatable:CreateFolder(folderName)
    local TabObj = self
    
    -- Folder Base Frame (Sharp 90-degree block)
    local FolderFrame = Instance.new("Frame")
    FolderFrame.Name = folderName .. "_Folder"
    FolderFrame.Size = UDim2.new(0.92, 0, 0, 36)
    FolderFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
    FolderFrame.BackgroundTransparency = 0.5
    FolderFrame.BorderSizePixel = 0
    FolderFrame.ClipsDescendants = true
    FolderFrame.Parent = TabObj.Scroll
    
    local FolderStroke = Instance.new("UIStroke")
    FolderStroke.Thickness = 1.0
    FolderStroke.Color = Color3.fromRGB(35, 30, 50)
    FolderStroke.Parent = FolderFrame
    
    -- Header Trigger
    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.BackgroundTransparency = 1
    Header.Text = "   " .. folderName:upper()
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 11
    Header.TextColor3 = AntigravityLib.Theme.TextMain
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = FolderFrame
    
    local Chevron = Instance.new("ImageLabel")
    Chevron.Name = "Chevron"
    Chevron.Size = UDim2.new(0, 12, 0, 12)
    Chevron.Position = UDim2.new(1, -26, 0.5, -6)
    Chevron.BackgroundTransparency = 1
    Chevron.Image = "rbxassetid://6031094678" -- Chevron down
    Chevron.ImageColor3 = AntigravityLib.Theme.TextMuted
    Chevron.Parent = Header
    
    -- Widgets Inner Content
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 1, -36)
    Container.Position = UDim2.new(0, 0, 0, 36)
    Container.BackgroundTransparency = 1
    Container.Parent = FolderFrame
    
    local ContainerLayout = Instance.new("UIListLayout")
    ContainerLayout.Padding = UDim.new(0, 6)
    ContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContainerLayout.Parent = Container
    
    local ContainerPadding = Instance.new("UIPadding")
    ContainerPadding.PaddingTop = UDim.new(0, 6)
    ContainerPadding.PaddingBottom = UDim.new(0, 6)
    ContainerPadding.Parent = Container
    
    local FolderObj = {
        Name = folderName,
        Frame = FolderFrame,
        Container = Container,
        Layout = ContainerLayout,
        Chevron = Chevron,
        Tab = TabObj,
        Collapsed = true
    }
    
    -- Expand/Collapse trigger
    local function toggleFolder()
        FolderObj.Collapsed = not FolderObj.Collapsed
        
        local targetHeight = 36
        local rotation = 0
        if not FolderObj.Collapsed then
            targetHeight = 36 + ContainerLayout.AbsoluteContentSize.Y + 12
            rotation = 90
        else
            FolderFrame.ClipsDescendants = true
        end
        
        Tween(Chevron, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Rotation = rotation })
        local tween = Tween(FolderFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = UDim2.new(0.92, 0, 0, targetHeight) })
        
        tween.Completed:Connect(function()
            TabObj.Scroll.CanvasSize = UDim2.new(0, 0, 0, TabObj.Scroll.UIListLayout.AbsoluteContentSize.Y + 30)
            if not FolderObj.Collapsed then
                FolderFrame.ClipsDescendants = false
            end
        end)
    end
    
    Header.MouseButton1Click:Connect(toggleFolder)
    
    setmetatable(FolderObj, FolderMetatable)
    return FolderObj
end

-- ==========================================================================
-- CREATE BUTTON (WIDGET / SHARP FLAT DESIGN)
-- ==========================================================================
function FolderMetatable:CreateButton(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Click Action"
    local callback = config.Callback or function() end
    local interactText = config.InteractText or "TRIGGER"
    local desc = config.Description
    
    local ButtonRow = Instance.new("Frame")
    local rowHeight = desc and 46 or 36
    ButtonRow.Size = UDim2.new(0.96, 0, 0, rowHeight)
    ButtonRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonRow.BackgroundTransparency = 0.985
    ButtonRow.BorderSizePixel = 0
    ButtonRow.Parent = FolderObj.Container
    
    local Label = Instance.new("TextLabel")
    if desc then
        Label.Size = UDim2.new(0.7, 0, 0, 18)
        Label.Position = UDim2.new(0, 10, 0, 6)
        
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(0.7, -10, 0, 16)
        DescLabel.Position = UDim2.new(0, 10, 0, 24)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = desc
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextSize = 9
        DescLabel.TextColor3 = AntigravityLib.Theme.TextMuted
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
        DescLabel.Parent = ButtonRow
    else
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
    end
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = AntigravityLib.Theme.TextMain
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ButtonRow
    
    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(0, 65, 0, 22)
    ClickBtn.Position = UDim2.new(1, -75, 0.5, -11)
    ClickBtn.BackgroundColor3 = FolderObj.Tab.Window.Accent
    ClickBtn.BackgroundTransparency = 0.82
    ClickBtn.Text = interactText:upper()
    ClickBtn.Font = Enum.Font.GothamBold
    ClickBtn.TextSize = 9
    ClickBtn.TextColor3 = FolderObj.Tab.Window.Accent
    ClickBtn.Parent = ButtonRow
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 0.8
    Stroke.Color = FolderObj.Tab.Window.Accent
    Stroke.Parent = ClickBtn
    
    ClickBtn.MouseButton1Click:Connect(function()
        Tween(ClickBtn, TweenInfo.new(0.06, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.7 })
        task.wait(0.06)
        Tween(ClickBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.82 })
        task.spawn(callback)
    end)
end

-- ==========================================================================
-- CREATE TOGGLE (WIDGET / SHARP SQUARE TOGGLE)
-- ==========================================================================
function FolderMetatable:CreateToggle(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Toggle Feature"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local desc = config.Description
    
    local active = default
    
    local ToggleRow = Instance.new("Frame")
    local rowHeight = desc and 46 or 36
    ToggleRow.Size = UDim2.new(0.96, 0, 0, rowHeight)
    ToggleRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleRow.BackgroundTransparency = 0.985
    ToggleRow.BorderSizePixel = 0
    ToggleRow.Parent = FolderObj.Container
    
    local Label = Instance.new("TextLabel")
    if desc then
        Label.Size = UDim2.new(0.7, 0, 0, 18)
        Label.Position = UDim2.new(0, 10, 0, 6)
        
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(0.7, -10, 0, 16)
        DescLabel.Position = UDim2.new(0, 10, 0, 24)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = desc
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextSize = 9
        DescLabel.TextColor3 = AntigravityLib.Theme.TextMuted
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
        DescLabel.Parent = ToggleRow
    else
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
    end
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = AntigravityLib.Theme.TextMain
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleRow
    
    -- Sharp Square Toggle base
    local ToggleBase = Instance.new("TextButton")
    ToggleBase.Size = UDim2.new(0, 28, 0, 16)
    ToggleBase.Position = UDim2.new(1, -38, 0.5, -8)
    ToggleBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBase.BackgroundTransparency = 0.92
    ToggleBase.BorderSizePixel = 0
    ToggleBase.Text = ""
    ToggleBase.Parent = ToggleRow
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 10, 0, 10)
    Dot.Position = UDim2.new(0, 3, 0.5, -5)
    Dot.BackgroundColor3 = AntigravityLib.Theme.TextMuted
    Dot.BorderSizePixel = 0
    Dot.Parent = ToggleBase
    
    local function updateVisuals()
        if active then
            Tween(ToggleBase, TweenInfo.new(0.18), { BackgroundColor3 = FolderObj.Tab.Window.Accent, BackgroundTransparency = 0.85 })
            Tween(Dot, TweenInfo.new(0.18), { Position = UDim2.new(0, 15, 0.5, -5), BackgroundColor3 = FolderObj.Tab.Window.Accent })
        else
            Tween(ToggleBase, TweenInfo.new(0.18), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.92 })
            Tween(Dot, TweenInfo.new(0.18), { Position = UDim2.new(0, 3, 0.5, -5), BackgroundColor3 = AntigravityLib.Theme.TextMuted })
        end
    end
    
    ToggleBase.MouseButton1Click:Connect(function()
        active = not active
        updateVisuals()
        task.spawn(callback, active)
    end)
    
    updateVisuals()
end

-- ==========================================================================
-- CREATE SLIDER (WIDGET / SHARP COMPACT SLIDER)
-- ==========================================================================
function FolderMetatable:CreateSlider(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Slider Adjust"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    local desc = config.Description
    
    local currentValue = default
    
    local SliderRow = Instance.new("Frame")
    local rowHeight = desc and 46 or 38
    SliderRow.Size = UDim2.new(0.96, 0, 0, rowHeight)
    SliderRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderRow.BackgroundTransparency = 0.985
    SliderRow.BorderSizePixel = 0
    SliderRow.Parent = FolderObj.Container
    
    local Label = Instance.new("TextLabel")
    if desc then
        Label.Size = UDim2.new(0.5, 0, 0, 18)
        Label.Position = UDim2.new(0, 10, 0, 6)
        
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(0.5, -10, 0, 16)
        DescLabel.Position = UDim2.new(0, 10, 0, 24)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = desc
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextSize = 9
        DescLabel.TextColor3 = AntigravityLib.Theme.TextMuted
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
        DescLabel.Parent = SliderRow
    else
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
    end
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = AntigravityLib.Theme.TextMain
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderRow
    
    -- Slider thin track
    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(0, 110, 0, 2)
    Track.Position = UDim2.new(1, -155, 0.5, -1)
    Track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Track.BackgroundTransparency = 0.92
    Track.BorderSizePixel = 0
    Track.Text = ""
    Track.Parent = SliderRow
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = FolderObj.Tab.Window.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    -- Sharp rectangular block handle
    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 6, 0, 10)
    Handle.Position = UDim2.new(0, -3, 0.5, -5)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Handle.BorderSizePixel = 0
    Handle.Parent = Track
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 30, 1, 0)
    ValueLabel.Position = UDim2.new(1, -38, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextSize = 10
    ValueLabel.TextColor3 = AntigravityLib.Theme.TextMain
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderRow
    
    local function updateValue(pct)
        pct = math.clamp(pct, 0, 1)
        local value = min + (pct * (max - min))
        value = math.round(value)
        
        currentValue = value
        ValueLabel.Text = tostring(value)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Handle.Position = UDim2.new(pct, -3, 0.5, -5)
        
        task.spawn(callback, value)
    end
    
    local sliding = false
    
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local trackX = Track.AbsolutePosition.X
            local trackWidth = Track.AbsoluteSize.X
            local pct = (Mouse.X - trackX) / trackWidth
            updateValue(pct)
        end
    end)
    
    local initialPct = (default - min) / (max - min)
    updateValue(initialPct)
end

-- ==========================================================================
-- CREATE KEYBIND (WIDGET / SHARP COMPACT BOX)
-- ==========================================================================
function FolderMetatable:CreateKeybind(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Keybind Toggle"
    local default = config.Default or Enum.KeyCode.F
    local callback = config.Callback or function() end
    local desc = config.Description
    
    local boundKey = default
    local listening = false
    
    local BindRow = Instance.new("Frame")
    local rowHeight = desc and 46 or 36
    BindRow.Size = UDim2.new(0.96, 0, 0, rowHeight)
    BindRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BindRow.BackgroundTransparency = 0.985
    BindRow.BorderSizePixel = 0
    BindRow.Parent = FolderObj.Container
    
    local Label = Instance.new("TextLabel")
    if desc then
        Label.Size = UDim2.new(0.7, 0, 0, 18)
        Label.Position = UDim2.new(0, 10, 0, 6)
        
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(0.7, -10, 0, 16)
        DescLabel.Position = UDim2.new(0, 10, 0, 24)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = desc
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextSize = 9
        DescLabel.TextColor3 = AntigravityLib.Theme.TextMuted
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
        DescLabel.Parent = BindRow
    else
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
    end
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = AntigravityLib.Theme.TextMain
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = BindRow
    
    local BindBox = Instance.new("TextButton")
    BindBox.Size = UDim2.new(0, 45, 0, 20)
    BindBox.Position = UDim2.new(1, -55, 0.5, -10)
    BindBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BindBox.BackgroundTransparency = 0.96
    BindBox.Text = boundKey.Name
    BindBox.Font = Enum.Font.Code
    BindBox.TextSize = 9
    BindBox.TextColor3 = FolderObj.Tab.Window.Accent
    BindBox.Parent = BindRow
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 0.8
    Stroke.Color = Color3.fromRGB(40, 35, 55)
    Stroke.Parent = BindBox
    
    BindBox.MouseButton1Click:Connect(function()
        listening = true
        BindBox.Text = "..."
        Stroke.Color = FolderObj.Tab.Window.Accent
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    boundKey = input.KeyCode
                    BindBox.Text = boundKey.Name
                else
                    BindBox.Text = boundKey.Name
                end
                Stroke.Color = Color3.fromRGB(40, 35, 55)
            end
        else
            if not processed and input.KeyCode == boundKey then
                task.spawn(callback)
            end
        end
    end)
end

-- ==========================================================================
-- CREATE DROPDOWN (WIDGET / SHARP COMPACT DROPDOWN)
-- ==========================================================================
function FolderMetatable:CreateDropdown(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Select Option"
    local options = config.Options or {}
    local default = config.Default or options[1] or ""
    local callback = config.Callback or function() end
    local desc = config.Description

    local selected = default
    local open = false

    local DropdownRow = Instance.new("Frame")
    local rowHeight = desc and 46 or 36
    DropdownRow.Size = UDim2.new(0.96, 0, 0, rowHeight)
    DropdownRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropdownRow.BackgroundTransparency = 0.985
    DropdownRow.BorderSizePixel = 0
    DropdownRow.Parent = FolderObj.Container

    local Label = Instance.new("TextLabel")
    if desc then
        Label.Size = UDim2.new(0.5, 0, 0, 18)
        Label.Position = UDim2.new(0, 10, 0, 6)
        
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(0.5, -10, 0, 16)
        DescLabel.Position = UDim2.new(0, 10, 0, 24)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = desc
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextSize = 9
        DescLabel.TextColor3 = AntigravityLib.Theme.TextMuted
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
        DescLabel.Parent = DropdownRow
    else
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
    end
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = AntigravityLib.Theme.TextMain
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownRow

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 100, 0, 22)
    DropBtn.Position = UDim2.new(1, -110, 0.5, -11)
    DropBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.BackgroundTransparency = 0.96
    DropBtn.Text = selected
    DropBtn.Font = Enum.Font.GothamMedium
    DropBtn.TextSize = 10
    DropBtn.TextColor3 = FolderObj.Tab.Window.Accent
    DropBtn.Parent = DropdownRow

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 0.8
    Stroke.Color = Color3.fromRGB(40, 35, 55)
    Stroke.Parent = DropBtn

    local ListFrame = Instance.new("Frame")
    ListFrame.Name = "DropdownList"
    ListFrame.Size = UDim2.new(0, 100, 0, 0)
    ListFrame.Position = UDim2.new(1, -110, 0.5, 11)
    ListFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
    ListFrame.BorderSizePixel = 0
    ListFrame.ClipsDescendants = true
    ListFrame.ZIndex = 5
    ListFrame.Parent = DropdownRow

    local ListStroke = Instance.new("UIStroke")
    ListStroke.Thickness = 0.8
    ListStroke.Color = Color3.fromRGB(40, 35, 55)
    ListStroke.Parent = ListFrame

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame

    local function toggleDropdown()
        open = not open
        local targetSize = UDim2.new(0, 100, 0, 0)
        if open then
            targetSize = UDim2.new(0, 100, 0, #options * 22)
            Stroke.Color = FolderObj.Tab.Window.Accent
        else
            Stroke.Color = Color3.fromRGB(40, 35, 55)
        end
        Tween(ListFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Size = targetSize })
    end

    DropBtn.MouseButton1Click:Connect(toggleDropdown)

    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Name = opt
        OptBtn.Size = UDim2.new(1, 0, 0, 22)
        OptBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = opt
        OptBtn.Font = Enum.Font.GothamMedium
        OptBtn.TextSize = 9
        OptBtn.TextColor3 = AntigravityLib.Theme.TextMuted
        OptBtn.ZIndex = 6
        OptBtn.Parent = ListFrame

        OptBtn.MouseEnter:Connect(function()
            OptBtn.BackgroundTransparency = 0.95
            OptBtn.TextColor3 = AntigravityLib.Theme.TextMain
        end)

        OptBtn.MouseLeave:Connect(function()
            OptBtn.BackgroundTransparency = 1
            if selected ~= opt then
                OptBtn.TextColor3 = AntigravityLib.Theme.TextMuted
            else
                OptBtn.TextColor3 = FolderObj.Tab.Window.Accent
            end
        end)

        OptBtn.MouseButton1Click:Connect(function()
            selected = opt
            DropBtn.Text = selected
            toggleDropdown()
            task.spawn(callback, selected)
        end)
    end
end

-- ==========================================================================
-- DESTROY WINDOW
-- ==========================================================================
function WindowMetatable:Destroy()
    local WindowObj = self
    WindowObj.Gui:Destroy()
end

return AntigravityLib
