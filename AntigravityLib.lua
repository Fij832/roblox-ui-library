--[[
    Antigravity Premium Roblox UI Library
    Version: 1.4.0
    Author: Antigravity Team
    Aesthetic: Cyber Glassmorphic & Neon Accent theme, featuring responsive dragging, smooth tweening, and sound effects!
    
    Usage:
    local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/DeepMind/antigravity/main/AntigravityLib.lua"))()
    local Window = Lib:CreateWindow({ Name = "Antigravity Hub" })
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local AntigravityLib = {}
AntigravityLib.Theme = {
    Background = Color3.fromRGB(15, 12, 28),
    Sidebar = Color3.fromRGB(8, 6, 16),
    WidgetBackground = Color3.fromRGB(25, 20, 45),
    AccentPrimary = Color3.fromRGB(147, 51, 234), -- Purple
    AccentSecondary = Color3.fromRGB(6, 182, 212), -- Cyan/Neon
    TextMain = Color3.fromRGB(243, 240, 252),
    TextMuted = Color3.fromRGB(142, 138, 159),
    Border = Color3.fromRGB(45, 40, 65)
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

-- Responsive Dragging Utility
local function MakeDraggable(frame, handle, tiltEnabled)
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        Tween(frame, TweenInfo.new(0.08, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), { Position = newPos })
        
        if tiltEnabled then
            -- Micro-tilt action
            local tiltAngle = math.clamp(delta.X * 0.05, -3, 3)
            Tween(frame, TweenInfo.new(0.1, Enum.EasingStyle.Out), { Rotation = tiltAngle })
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
-- CREATE WINDOW
-- ==========================================================================
function AntigravityLib:CreateWindow(config)
    config = config or {}
    local name = config.Name or "Antigravity Hub"
    local accentColor = config.ThemeAccent or AntigravityLib.Theme.AccentSecondary
    local toggleKey = config.DefaultToggleKey or Enum.KeyCode.RightControl
    local tilt = config.ResponsiveTilt ~= nil and config.ResponsiveTilt or true
    
    -- Root ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Antigravity_" .. name:gsub("%s+", "")
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
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Glass Corner Radius
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Glow Outline border
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 1.2
    UIStroke.Color = AntigravityLib.Theme.Border
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = MainFrame
    
    -- Titlebar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.BackgroundColor3 = Color3.fromRGB(12, 10, 22)
    TitleBar.BackgroundTransparency = 0.55
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 12)
    BarCorner.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = name
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextColor3 = AntigravityLib.Theme.TextMain
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    local TitleSubtitle = Instance.new("TextLabel")
    TitleSubtitle.Name = "TitleSubtitle"
    TitleSubtitle.Size = UDim2.new(0.3, 0, 1, 0)
    TitleSubtitle.Position = UDim2.new(0, TitleLabel.TextBounds.X + 24, 0, 0)
    TitleSubtitle.BackgroundTransparency = 1
    TitleSubtitle.Text = "| v1.4.0"
    TitleSubtitle.Font = Enum.Font.GothamSemibold
    TitleSubtitle.TextSize = 11
    TitleSubtitle.TextColor3 = AntigravityLib.Theme.TextMuted
    TitleSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    TitleSubtitle.Parent = TitleBar
    
    -- Left Nav Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 145, 1, -42)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.BackgroundColor3 = AntigravityLib.Theme.Sidebar
    Sidebar.BackgroundTransparency = 0.35
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 12)
    SideCorner.Parent = Sidebar
    
    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 4)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar
    
    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 12)
    SidebarPadding.Parent = Sidebar
    
    -- Content Frame Panel
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name = "ContentPanel"
    ContentPanel.Size = UDim2.new(1, -145, 1, -42)
    ContentPanel.Position = UDim2.new(0, 145, 0, 42)
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
    
    -- Toggle UI visibility binding
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == WindowObj.ToggleKey then
            WindowObj.Visible = not WindowObj.Visible
            MainFrame.Visible = WindowObj.Visible
            if WindowObj.Visible then
                Tween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 520, 0, 380) })
            else
                Tween(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 520, 0, 0) })
            end
        end
    end)
    
    setmetatable(WindowObj, WindowMetatable)
    return WindowObj
end

-- ==========================================================================
-- CREATE TAB
-- ==========================================================================
function WindowMetatable:CreateTab(tabName)
    local WindowObj = self
    
    -- Create Sidebar tab button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Name = tabName .. "_Btn"
    TabBtn.Size = UDim2.new(0.9, 0, 0, 32)
    TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "  " .. tabName
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    TabBtn.TextColor3 = AntigravityLib.Theme.TextMuted
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = WindowObj.Sidebar
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn
    
    -- Tab indicator glow line
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 3, 0.6, 0)
    Indicator.Position = UDim2.new(0, 0, 0.2, 0)
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
    TabScroll.ScrollBarThickness = 4
    TabScroll.ScrollBarImageColor3 = AntigravityLib.Theme.TextDim
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
            WindowObj.CurrentTab.Button.Indicator.Visible = false
            WindowObj.CurrentTab.Scroll.Visible = false
        end
        
        WindowObj.CurrentTab = TabObj
        TabBtn.TextColor3 = WindowObj.Accent
        Indicator.Visible = true
        TabScroll.Visible = true
        
        -- Bounce Transition
        TabScroll.Position = UDim2.new(0, 0, 0, 10)
        Tween(TabScroll, TweenInfo.new(0.25, Enum.EasingStyle.Out, Enum.EasingDirection.Quad), { Position = UDim2.new(0, 0, 0, 0) })
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
    
    -- Folder Base
    local FolderFrame = Instance.new("Frame")
    FolderFrame.Name = folderName .. "_Folder"
    FolderFrame.Size = UDim2.new(0.92, 0, 0, 36)
    FolderFrame.BackgroundColor3 = Color3.fromRGB(20, 16, 36)
    FolderFrame.BackgroundTransparency = 0.6
    FolderFrame.BorderSizePixel = 0
    FolderFrame.ClipsDescendants = true
    FolderFrame.Parent = TabObj.Scroll
    
    local FolderCorner = Instance.new("UICorner")
    FolderCorner.CornerRadius = UDim.new(0, 8)
    FolderCorner.Parent = FolderFrame
    
    local FolderStroke = Instance.new("UIStroke")
    FolderStroke.Thickness = 1
    FolderStroke.Color = Color3.fromRGB(45, 40, 65)
    FolderStroke.Parent = FolderFrame
    
    -- Header Trigger
    local Header = Instance.new("TextButton")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 36)
    Header.BackgroundTransparency = 1
    Header.Text = "   " .. folderName
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 11
    Header.TextColor3 = AntigravityLib.Theme.TextMain
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = FolderFrame
    
    local Chevron = Instance.new("ImageLabel")
    Chevron.Name = "Chevron"
    Chevron.Size = UDim2.new(0, 14, 0, 14)
    Chevron.Position = UDim2.new(1, -26, 0.5, -7)
    Chevron.BackgroundTransparency = 1
    Chevron.Image = "rbxassetid://6031094678" -- Chevron down asset ID
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
    ContainerLayout.Padding = UDim.new(0, 8)
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
            -- Calculate height needed for expanded widgets
            targetHeight = 36 + ContainerLayout.AbsoluteContentSize.Y + 12
            rotation = 90
        end
        
        Tween(Chevron, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Rotation = rotation })
        local tween = Tween(FolderFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = UDim2.new(0.92, 0, 0, targetHeight) })
        
        tween.Completed:Connect(function()
            -- Canvas height update support
            TabObj.Scroll.CanvasSize = UDim2.new(0, 0, 0, TabObj.Scroll.UIListLayout.AbsoluteContentSize.Y + 30)
        end)
    end
    
    Header.MouseButton1Click:Connect(toggleFolder)
    
    setmetatable(FolderObj, FolderMetatable)
    return FolderObj
end

-- ==========================================================================
-- CREATE BUTTON (WIDGET)
-- ==========================================================================
function FolderMetatable:CreateButton(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Click Action"
    local callback = config.Callback or function() end
    
    local ButtonRow = Instance.new("Frame")
    ButtonRow.Size = UDim2.new(0.96, 0, 0, 36)
    ButtonRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonRow.BackgroundTransparency = 0.98
    ButtonRow.BorderSizePixel = 0
    ButtonRow.Parent = FolderObj.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ButtonRow
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = AntigravityLib.Theme.TextMain
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ButtonRow
    
    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(0, 65, 0, 24)
    ClickBtn.Position = UDim2.new(1, -75, 0.5, -12)
    ClickBtn.BackgroundColor3 = FolderObj.Tab.Window.Accent
    ClickBtn.BackgroundTransparency = 0.8
    ClickBtn.Text = "Trigger"
    ClickBtn.Font = Enum.Font.GothamBold
    ClickBtn.TextSize = 10
    ClickBtn.TextColor3 = FolderObj.Tab.Window.Accent
    ClickBtn.Parent = ButtonRow
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = ClickBtn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 0.8
    Stroke.Color = FolderObj.Tab.Window.Accent
    Stroke.Parent = ClickBtn
    
    ClickBtn.MouseButton1Click:Connect(function()
        -- Bounce animation on trigger
        Tween(ClickBtn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 60, 0, 22), Position = UDim2.new(1, -70, 0.5, -11) })
        task.wait(0.08)
        Tween(ClickBtn, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 65, 0, 24), Position = UDim2.new(1, -75, 0.5, -12) })
        
        task.spawn(callback)
    end)
end

-- ==========================================================================
-- CREATE TOGGLE (WIDGET)
-- ==========================================================================
function FolderMetatable:CreateToggle(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Toggle Feature"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local active = default
    
    local ToggleRow = Instance.new("Frame")
    ToggleRow.Size = UDim2.new(0.96, 0, 0, 36)
    ToggleRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleRow.BackgroundTransparency = 0.98
    ToggleRow.BorderSizePixel = 0
    ToggleRow.Parent = FolderObj.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleRow
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = AntigravityLib.Theme.TextMain
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleRow
    
    local ToggleBase = Instance.new("TextButton")
    ToggleBase.Size = UDim2.new(0, 32, 0, 18)
    ToggleBase.Position = UDim2.new(1, -42, 0.5, -9)
    ToggleBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBase.BackgroundTransparency = 0.9
    ToggleBase.Text = ""
    ToggleBase.Parent = ToggleRow
    
    local BaseCorner = Instance.new("UICorner")
    BaseCorner.CornerRadius = UDim.new(0, 12)
    BaseCorner.Parent = ToggleBase
    
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 12, 0, 12)
    Dot.Position = UDim2.new(0, 2, 0.5, -6)
    Dot.BackgroundColor3 = AntigravityLib.Theme.TextMuted
    Dot.BorderSizePixel = 0
    Dot.Parent = ToggleBase
    
    local DotCorner = Instance.new("UICorner")
    DotCorner.CornerRadius = UDim.new(0, 6)
    DotCorner.Parent = Dot
    
    local function updateVisuals()
        if active then
            Tween(ToggleBase, TweenInfo.new(0.2), { BackgroundColor3 = FolderObj.Tab.Window.Accent, BackgroundTransparency = 0.8 })
            Tween(Dot, TweenInfo.new(0.2), { Position = UDim2.new(0, 18, 0.5, -6), BackgroundColor3 = FolderObj.Tab.Window.Accent })
        else
            Tween(ToggleBase, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.9 })
            Tween(Dot, TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = AntigravityLib.Theme.TextMuted })
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
-- CREATE SLIDER (WIDGET / TWIST)
-- ==========================================================================
function FolderMetatable:CreateSlider(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Slider Adjust"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    
    local currentValue = default
    
    local SliderRow = Instance.new("Frame")
    SliderRow.Size = UDim2.new(0.96, 0, 0, 38)
    SliderRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderRow.BackgroundTransparency = 0.98
    SliderRow.BorderSizePixel = 0
    SliderRow.Parent = FolderObj.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = SliderRow
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 11
    Label.TextColor3 = AntigravityLib.Theme.TextMain
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderRow
    
    -- Slider Bar Track
    local Track = Instance.new("TextButton")
    Track.Size = UDim2.new(0, 120, 0, 4)
    Track.Position = UDim2.new(1, -165, 0.5, -2)
    Track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Track.BackgroundTransparency = 0.92
    Track.Text = ""
    Track.Parent = SliderRow
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 2)
    TrackCorner.Parent = Track
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = FolderObj.Tab.Window.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 2)
    FillCorner.Parent = Fill
    
    local Handle = Instance.new("Frame")
    Handle.Size = UDim2.new(0, 10, 0, 10)
    Handle.Position = UDim2.new(0, -5, 0.5, -5)
    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Handle.BorderSizePixel = 0
    Handle.Parent = Track
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(0, 5)
    HandleCorner.Parent = Handle
    
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
        Handle.Position = UDim2.new(pct, -5, 0.5, -5)
        
        task.spawn(callback, value)
    end
    
    -- Sliding mouse actions
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
    
    -- Initial value setup
    local initialPct = (default - min) / (max - min)
    updateValue(initialPct)
end

-- ==========================================================================
-- CREATE KEYBIND (WIDGET)
-- ==========================================================================
function FolderMetatable:CreateKeybind(config)
    local FolderObj = self
    config = config or {}
    local name = config.Name or "Keybind Toggle"
    local default = config.Default or Enum.KeyCode.F
    local callback = config.Callback or function() end
    
    local boundKey = default
    local listening = false
    
    local BindRow = Instance.new("Frame")
    BindRow.Size = UDim2.new(0.96, 0, 0, 36)
    BindRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BindRow.BackgroundTransparency = 0.98
    BindRow.BorderSizePixel = 0
    BindRow.Parent = FolderObj.Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = BindRow
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
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
    BindBox.BackgroundTransparency = 0.95
    BindBox.Text = boundKey.Name
    BindBox.Font = Enum.Font.Code
    BindBox.TextSize = 9
    BindBox.TextColor3 = FolderObj.Tab.Window.Accent
    BindBox.Parent = BindRow
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = BindBox
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 0.8
    Stroke.Color = Color3.fromRGB(45, 40, 65)
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
                Stroke.Color = Color3.fromRGB(45, 40, 65)
            end
        else
            if not processed and input.KeyCode == boundKey then
                task.spawn(callback)
            end
        end
    end)
end

-- ==========================================================================
-- DESTROY WINDOW
-- ==========================================================================
function WindowMetatable:Destroy()
    local WindowObj = self
    WindowObj.Gui:Destroy()
end

return AntigravityLib
