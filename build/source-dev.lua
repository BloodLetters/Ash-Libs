---------------------------------------------- SOURCE ----------------------------------------------

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local GUI = {}
GUI.CurrentTab = nil

if _G.ModernGUIInstance then
    _G.ModernGUIInstance:Destroy()
    _G.ModernGUIInstance = nil
end

local DefaultTheme = {
    Background = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(35, 35, 45),
    Accent = Color3.fromRGB(138, 43, 226),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(50, 50, 60),
    NavBackground = Color3.fromRGB(20, 20, 30)
}

local Theme = DefaultTheme

-- Window
function GUI:CreateMain(config)
    local settings = {
        Name = config.Name or "Ashlabs",
        title = config.title or "Ashlabs UI",
        ToggleUI = config.ToggleUI or "K",
        WindowIcon = config.WindowIcon or nil,
        WindowHeight = config.WindowHeight or nil,
        WindowWidth = config.WindowWidth or nil,
        Theme = config.Theme or DefaultTheme,
        Config = {
            Enabled = config.Config and config.Config.Enabled or true,
            FolderName = config.Config and config.Config.FolderName or "Ashlabs",
            FileName = config.Config and config.Config.FileName or "Default"
        },
        Blur = {
            Enable = config.Blur and config.Blur.Enable or false,
            value = config.Blur and config.Blur.value or 0.5
        }
    }

    if config.Theme then
        Theme = {}
        for key, value in pairs(DefaultTheme) do
            Theme[key] = config.Theme[key] or DefaultTheme[key]
        end
    end

    -- Checking responsive size
    local windowSize
    if config.WindowHeight == nil and config.WindowWidth == nil then
        local camera = workspace.CurrentCamera
        local screenSize = camera.ViewportSize

        if screenSize.X < 800 then
            windowSize = UDim2.new(0, math.min(screenSize.X - 40, 350), 0, math.min(screenSize.Y - 40, 400))
        else
            windowSize = UDim2.new(0, 600, 0, 400)
        end
    else
        windowSize = UDim2.new(0, config.WindowWidth, 0, config.WindowHeight)
    end

    GUI.Settings = settings
    GUI.isMinimized = false

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = settings.Name
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _G.ModernGUIInstance = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = settings.Blur.Enable and Color3.fromRGB(255, 255, 255) or Theme.Background
    MainFrame.BackgroundTransparency = settings.Blur.Enable and settings.Blur.value or 0
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.Size = config.WindowSize or windowSize

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    if settings.Blur.Enable then
        local BlurEffect = Instance.new("BlurEffect")
        BlurEffect.Size = 50
        BlurEffect.Parent = workspace.CurrentCamera

        GUI.BlurEffect = BlurEffect
    end

    GUI.isDraggingEnabled = true

    local function isMouseOverContentContainer(mousePosition)
        if GUI.ContentContainer then
            local pos = GUI.ContentContainer.AbsolutePosition
            local size = GUI.ContentContainer.AbsoluteSize
            return mousePosition.X >= pos.X and mousePosition.X <= pos.X + size.X and 
                   mousePosition.Y >= pos.Y and mousePosition.Y <= pos.Y + size.Y
        end
        return false
    end

    local function makeDraggableConditional(frame)
        local dragging = false
        local dragStart = nil
        local startPos = nil

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and GUI.isDraggingEnabled then
                local mouse = Players.LocalPlayer:GetMouse()
                local mousePos = Vector2.new(mouse.X, mouse.Y)
                
                if not isMouseOverContentContainer(mousePos) then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                end
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging and GUI.isDraggingEnabled then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    local function setupToggleKeybind()
        local function getKeyName(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                return "M1"
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                return "M2"
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                return "M3"
            elseif input.UserInputType == Enum.UserInputType.Keyboard then
                return input.KeyCode.Name
            else
                return "Unknown"
            end
        end

        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end

            local keyName = getKeyName(input)
            if keyName == settings.ToggleUI then
                if GUI.isMinimized then
                    GUI:RestoreGUI()
                else
                    GUI:MinimizeGUI()
                end
            end
        end)
    end

    setupToggleKeybind()

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundTransparency = 1
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.Size = UDim2.new(1, 0, 0, 40)

    if config.WindowIcon and config.WindowIcon ~= "" and config.WindowIcon ~= nil then
        local iconData = getIcon(config.WindowIcon)
        local IconImage = Instance.new("ImageLabel")
        IconImage.Name = "WindowIcon"
        IconImage.Parent = TitleBar
        IconImage.BackgroundTransparency = 1
        IconImage.Position = UDim2.new(0, 10, 0.5, -10)
        IconImage.Size = UDim2.new(0, 20, 0, 20)
        IconImage.Image = getAssetUri(iconData.id)
        if iconData.imageRectSize ~= nil and iconData.imageRectOffset ~= nil then
            IconImage.ImageRectSize = iconData.imageRectSize 
            IconImage.ImageRectOffset = iconData.imageRectOffset
        else
            IconImage.ImageRectSize = Vector2.new(0, 0)
            IconImage.ImageRectOffset = Vector2.new(0, 0)
        end
        IconImage.ImageColor3 = Theme.Text
        IconImage.ScaleType = Enum.ScaleType.Fit
        IconImage.ImageTransparency = 0
    end

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TitleBar
    if config.WindowIcon and config.WindowIcon ~= "" and config.WindowIcon ~= nil then
        TitleLabel.Position = UDim2.new(0, 40, 0, 0)
        TitleLabel.Size = UDim2.new(0, 180, 1, 0)
    else
        TitleLabel.Position = UDim2.new(0, 15, 0, 0)
        TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    end
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = string.len(settings.title) > 38 and string.sub(settings.title, 1, 35) .. "..." or settings.title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TitleBar
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 189, 46)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Position = UDim2.new(1, -75, 0.5, -8)
    MinimizeButton.Size = UDim2.new(0, 16, 0, 16)
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.Text = ""
    MinimizeButton.TextColor3 = Theme.Text
    MinimizeButton.TextSize = 14

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(1, 0)
    MinimizeCorner.Parent = MinimizeButton

    local MaximizeButton = Instance.new("TextButton")
    MaximizeButton.Name = "MaximizeButton"
    MaximizeButton.Parent = TitleBar
    MaximizeButton.BackgroundColor3 = Color3.fromRGB(40, 201, 64)
    MaximizeButton.BorderSizePixel = 0
    MaximizeButton.Position = UDim2.new(1, -55, 0.5, -8)
    MaximizeButton.Size = UDim2.new(0, 16, 0, 16)
    MaximizeButton.Font = Enum.Font.Gotham
    MaximizeButton.Text = ""
    MaximizeButton.TextColor3 = Theme.Text
    MaximizeButton.TextSize = 14

    local MaximizeCorner = Instance.new("UICorner")
    MaximizeCorner.CornerRadius = UDim.new(1, 0)
    MaximizeCorner.Parent = MaximizeButton

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -35, 0.5, -8)
    CloseButton.Size = UDim2.new(0, 16, 0, 16)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Text = ""
    CloseButton.TextColor3 = Theme.Text
    CloseButton.TextSize = 14

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton

    local isContentHidden = false
    local originalSize = MainFrame.Size

    local NavFrame = Instance.new("Frame")
    NavFrame.Name = "Navigation"
    NavFrame.Parent = MainFrame
    NavFrame.BackgroundColor3 = settings.Blur.Enable and Color3.fromRGB(255, 255, 255) or Theme.NavBackground
    NavFrame.BackgroundTransparency = settings.Blur.Enable and 0.85 or 0
    NavFrame.BorderSizePixel = 0
    NavFrame.Position = UDim2.new(0, 10, 0, 45)
    NavFrame.Size = UDim2.new(0, 120, 1, -100)

    local NavCorner = Instance.new("UICorner")
    NavCorner.CornerRadius = UDim.new(0, 8)
    NavCorner.Parent = NavFrame

    if settings.Blur.Enable then
        local NavBorder = Instance.new("UIStroke")
        NavBorder.Parent = NavFrame
        NavBorder.Color = Color3.fromRGB(255, 255, 255)
        NavBorder.Thickness = 0.5
        NavBorder.Transparency = 0.8
    end

    local NavContent = Instance.new("ScrollingFrame")
    NavContent.Name = "NavContent"
    NavContent.Parent = NavFrame
    NavContent.BackgroundTransparency = 1
    NavContent.Position = UDim2.new(0, 0, 0, 0)
    NavContent.Size = UDim2.new(1, 0, 1, 0)
    NavContent.ScrollBarThickness = 3
    NavContent.ScrollBarImageColor3 = Theme.Accent
    NavContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    NavContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NavContent.ScrollingDirection = Enum.ScrollingDirection.Y

    local NavList = Instance.new("UIListLayout")
    NavList.Parent = NavContent
    NavList.Padding = UDim.new(0, 8)
    NavList.SortOrder = Enum.SortOrder.LayoutOrder

    local NavPadding = Instance.new("UIPadding")
    NavPadding.Parent = NavContent
    NavPadding.PaddingLeft = UDim.new(0, 8)
    NavPadding.PaddingRight = UDim.new(0, 8)
    NavPadding.PaddingTop = UDim.new(0, 15)
    NavPadding.PaddingBottom = UDim.new(0, 15)

    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Parent = MainFrame
    SettingsFrame.BackgroundColor3 = settings.Blur.Enable and Color3.fromRGB(255, 255, 255) or Theme.NavBackground
    SettingsFrame.BackgroundTransparency = settings.Blur.Enable and 0.85 or 0
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.Position = UDim2.new(0, 10, 1, -45)
    SettingsFrame.Size = UDim2.new(0, 120, 0, 35)

    local SettingsFrameCorner = Instance.new("UICorner")
    SettingsFrameCorner.CornerRadius = UDim.new(0, 8)
    SettingsFrameCorner.Parent = SettingsFrame

    if settings.Blur.Enable then
        local SettingsBorder = Instance.new("UIStroke")
        SettingsBorder.Parent = SettingsFrame
        SettingsBorder.Color = Color3.fromRGB(255, 255, 255)
        SettingsBorder.Thickness = 0.5
        SettingsBorder.Transparency = 0.8
    end

    local SettingsButton = Instance.new("TextButton")
    SettingsButton.Name = "SettingsButton"
    SettingsButton.Parent = SettingsFrame
    SettingsButton.BackgroundColor3 = Theme.Secondary
    SettingsButton.BackgroundTransparency = settings.Blur.Enable and 0.7 or 0
    SettingsButton.BorderSizePixel = 0
    SettingsButton.Position = UDim2.new(0, 5, 0, 5)
    SettingsButton.Size = UDim2.new(1, -10, 1, -10)
    SettingsButton.Font = Enum.Font.Gotham
    SettingsButton.Text = "⚙ Settings"
    SettingsButton.TextColor3 = Theme.TextSecondary
    SettingsButton.TextSize = 12
    SettingsButton.TextXAlignment = Enum.TextXAlignment.Center

    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 6)
    SettingsCorner.Parent = SettingsButton

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = settings.Blur.Enable and Color3.fromRGB(255, 255, 255) or Theme.NavBackground
    ContentContainer.BackgroundTransparency = settings.Blur.Enable and 0.85 or 0
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Position = UDim2.new(0, 140, 0, 45)
    ContentContainer.Size = UDim2.new(1, -150, 1, -55)

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 8)
    ContentCorner.Parent = ContentContainer

    if settings.Blur.Enable then
        local ContentBorder = Instance.new("UIStroke")
        ContentBorder.Parent = ContentContainer
        ContentBorder.Color = Color3.fromRGB(255, 255, 255)
        ContentBorder.Thickness = 0.5
        ContentBorder.Transparency = 0.8
    end

    makeDraggableConditional(MainFrame)

    local function updateScrollVisibility(scrollFrame)
        local contentList = scrollFrame:FindFirstChildOfClass("UIListLayout")
        if contentList then
            local totalContentHeight = contentList.AbsoluteContentSize.Y + 30
            local containerHeight = scrollFrame.AbsoluteSize.Y

            if totalContentHeight > containerHeight then
                scrollFrame.ScrollBarThickness = 3
                scrollFrame.ScrollingEnabled = true
            else
                scrollFrame.ScrollBarThickness = 0
                scrollFrame.ScrollingEnabled = false
            end
        end
    end

    local function connectScrollUpdate(scrollFrame)
        local contentList = scrollFrame:FindFirstChildOfClass("UIListLayout")
        if contentList then
            contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                updateScrollVisibility(scrollFrame)
            end)
        end

        scrollFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            updateScrollVisibility(scrollFrame)
        end)
    end

    connectScrollUpdate(NavContent)

    function GUI:MinimizeGUI()
        GUI.isMinimized = true
        ScreenGui.Enabled = false
    end

    function GUI:RestoreGUI()
        GUI.isMinimized = false
        ScreenGui.Enabled = true
    end

    MinimizeButton.MouseButton1Click:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 14, 0, 14)
        }):Play()
        task.wait(0.1)
        TweenService:Create(MinimizeButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 16, 0, 16)
        }):Play()
        
        GUI:MinimizeGUI()
    end)

    MaximizeButton.MouseButton1Click:Connect(function()
        isContentHidden = not isContentHidden

        TweenService:Create(MaximizeButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 14, 0, 14)
        }):Play()

        if isContentHidden then
            NavFrame.Visible = false
            SettingsFrame.Visible = false
            ContentContainer.Visible = false
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 40)
            }):Play()
        else
            NavFrame.Visible = true
            SettingsFrame.Visible = true
            ContentContainer.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Size = originalSize
            }):Play()
        end

        task.wait(0.1)
        TweenService:Create(MaximizeButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 16, 0, 16)
        }):Play()
    end)

    CloseButton.MouseButton1Click:Connect(function()
        if GUI.BlurEffect then
            GUI.BlurEffect:Destroy()
            GUI.BlurEffect = nil
        end
        task.wait(0.3)
        ScreenGui:Destroy()
    end)

    SettingsButton.MouseButton1Click:Connect(function()
        GUI:ShowSettingsTab()
    end)

    GUI.MainFrame = MainFrame
    GUI.NavFrame = NavContent
    GUI.ContentContainer = ContentContainer
    GUI.Tabs = {}
    GUI.UpdateScrollVisibility = updateScrollVisibility
    GUI.ConnectScrollUpdate = connectScrollUpdate

    return ScreenGui, ContentContainer
end

function GUI:CreateSettingsTab()
    if not GUI.ContentContainer then
        error("Main GUI must be created first!")
    end

    local SettingsContent = Instance.new("ScrollingFrame")
    SettingsContent.Name = "SettingsContent"
    SettingsContent.Parent = GUI.ContentContainer
    SettingsContent.BackgroundTransparency = 1
    SettingsContent.Position = UDim2.new(0, 0, 0, 0)
    SettingsContent.Size = UDim2.new(1, 0, 1, 0)
    SettingsContent.ScrollBarThickness = 0
    SettingsContent.ScrollBarImageColor3 = Theme.Accent
    SettingsContent.ScrollingEnabled = false
    SettingsContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    SettingsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SettingsContent.Visible = false

    local ContentList = Instance.new("UIListLayout")
    ContentList.Parent = SettingsContent
    ContentList.Padding = UDim.new(0, 10)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder

    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.Parent = SettingsContent
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)

    GUI.ConnectScrollUpdate(SettingsContent)

    GUI.SettingsContent = SettingsContent

    return SettingsContent
end

function GUI:ShowSettingsTab()
    if not GUI.SettingsContent then
        GUI:CreateSettingsTab()

        GUI:CreateSection({parent = GUI.SettingsContent, text = "General Settings"})
        GUI:CreateParagraph({parent = GUI.SettingsContent, text = "This settings will auto loaded when you open the game. so make sure you save it!. if you didnt save it, the settings will not be saved and will reset to default when you rejoin the game."})

        GUI:CreateButton({parent = GUI.SettingsContent, text = "Save Settings to local", callback = function()
            GUI:CreateNotify({title = "Settings Saved", description = "All settings have been saved successfully!"})
        end})

        GUI:CreateButton({parent = GUI.SettingsContent, text = "Reset Settings", callback = function()
            GUI:CreateNotify({title = "Settings Reset", description = "All settings have been reset successfully!"})
        end})

        local key = GUI:CreateKeyBind({parent = GUI.SettingsContent, text = "Show GUI", default = GUI.Settings.ToggleUI, callback = function(key, _, isTrigger)
            if not isTrigger then
                GUI.Settings.ToggleUI = key
            end
        end})
    end

    for _, tab in pairs(GUI.Tabs) do
        tab.Content.Visible = false
        tab.Button.BackgroundColor3 = Theme.Secondary

        local textLabel = tab.Button:FindFirstChild("ContentFrame"):FindFirstChild("TabText")
        if textLabel then
            textLabel.TextColor3 = Theme.TextSecondary
        end

        local icon = tab.Button:FindFirstChild("ContentFrame"):FindFirstChild("TabIcon")
        if icon then
            icon.ImageColor3 = Theme.TextSecondary
        end
    end

    GUI.SettingsContent.Visible = true
    GUI.CurrentTab = GUI.SettingsContent

    local settingsButton = GUI.MainFrame:FindFirstChild("SettingsFrame"):FindFirstChild("SettingsButton")
    settingsButton.BackgroundColor3 = Theme.Accent
    settingsButton.TextColor3 = Theme.Text

    TweenService:Create(settingsButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
        BackgroundColor3 = Theme.Accent,
        TextColor3 = Theme.Text
    }):Play()
end

-- Element
function GUI:CreateTab(name, iconName)
    if not GUI.NavFrame or not GUI.ContentContainer then
        error("Main GUI must be created first!")
    end

    local displayName = name
    if iconName then
        if string.len(name) > 12 then
            displayName = string.sub(name, 1, 12) .. "..."
        end
    else
        if string.len(name) > 17 then
            displayName = string.sub(name, 1, 17) .. "..."
        end
    end

    local TabButton = Instance.new("TextButton")
    TabButton.Name = "TabButton_" .. name
    TabButton.Parent = GUI.NavFrame
    TabButton.BackgroundColor3 = Theme.Secondary
    TabButton.BorderSizePixel = 0
    TabButton.Size = UDim2.new(1, 0, 0, 35)
    TabButton.Font = Enum.Font.GothamSemibold
    TabButton.Text = ""
    TabButton.TextColor3 = Theme.TextSecondary
    TabButton.TextSize = 12
    TabButton.TextXAlignment = Enum.TextXAlignment.Left

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = TabButton
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 8, 0, 0)
    ContentFrame.Size = UDim2.new(1, -16, 1, 0)

    if iconName then
        local IconImage = Instance.new("ImageLabel")
        IconImage.Name = "TabIcon"
        IconImage.Parent = ContentFrame
        IconImage.BackgroundTransparency = 1
        IconImage.Position = UDim2.new(0, 0, 0.5, -8)
        IconImage.Size = UDim2.new(0, 16, 0, 16)
        IconImage.Image = getAssetUri(getIcon(iconName).id)
        IconImage.ImageRectSize = getIcon(iconName).imageRectSize
        IconImage.ImageRectOffset = getIcon(iconName).imageRectOffset
        IconImage.ImageColor3 = Theme.TextSecondary
        IconImage.ScaleType = Enum.ScaleType.Fit
        IconImage.ImageTransparency = 0

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TabText"
        TextLabel.Parent = ContentFrame
        TextLabel.BackgroundTransparency = 1
        TextLabel.Position = UDim2.new(0, 24, 0, 0)
        TextLabel.Size = UDim2.new(1, -24, 1, 0)
        TextLabel.Font = Enum.Font.GothamSemibold
        TextLabel.Text = displayName
        TextLabel.TextColor3 = Theme.TextSecondary
        TextLabel.TextSize = 12
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.TextYAlignment = Enum.TextYAlignment.Center
        TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
        TextLabel.ClipsDescendants = true
    else
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Name = "TabText"
        TextLabel.Parent = ContentFrame
        TextLabel.BackgroundTransparency = 1
        TextLabel.Position = UDim2.new(0, 0, 0, 0)
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Font = Enum.Font.GothamSemibold
        TextLabel.Text = displayName
        TextLabel.TextColor3 = Theme.TextSecondary
        TextLabel.TextSize = 12
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.TextYAlignment = Enum.TextYAlignment.Center
        TextLabel.TextTruncate = Enum.TextTruncate.AtEnd
        TextLabel.ClipsDescendants = true
    end

    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = "TabContent_" .. name
    TabContent.Parent = GUI.ContentContainer
    TabContent.BackgroundTransparency = 1
    TabContent.Position = UDim2.new(0, 0, 0, 0)
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.ScrollBarThickness = 0
    TabContent.ScrollBarImageColor3 = Theme.Accent
    TabContent.ScrollingEnabled = false
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContent.Visible = false

    local ContentList = Instance.new("UIListLayout")
    ContentList.Parent = TabContent
    ContentList.Padding = UDim.new(0, 10)
    ContentList.SortOrder = Enum.SortOrder.LayoutOrder

    local ContentPadding = Instance.new("UIPadding")
    ContentPadding.Parent = TabContent
    ContentPadding.PaddingLeft = UDim.new(0, 10)
    ContentPadding.PaddingRight = UDim.new(0, 10)
    ContentPadding.PaddingTop = UDim.new(0, 10)
    ContentPadding.PaddingBottom = UDim.new(0, 10)

    GUI.ConnectScrollUpdate(TabContent)

    TabButton.MouseButton1Click:Connect(function()

        if GUI.SettingsContent then
            GUI.SettingsContent.Visible = false
        end

        local settingsButton = GUI.MainFrame:FindFirstChild("SettingsFrame"):FindFirstChild("SettingsButton")
        if settingsButton then
            settingsButton.BackgroundColor3 = Theme.Secondary
            settingsButton.TextColor3 = Theme.TextSecondary
        end

        for _, tab in pairs(GUI.Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Theme.Secondary

            local textLabel = tab.Button:FindFirstChild("ContentFrame"):FindFirstChild("TabText")
            if textLabel then
                textLabel.TextColor3 = Theme.TextSecondary
            end

            local icon = tab.Button:FindFirstChild("ContentFrame"):FindFirstChild("TabIcon")
            if icon then
                icon.ImageColor3 = Theme.TextSecondary
            end
        end

        TabContent.Visible = true
        TabButton.BackgroundColor3 = Theme.Accent
        GUI.CurrentTab = TabContent

        local activeTextLabel = TabButton:FindFirstChild("ContentFrame"):FindFirstChild("TabText")
        if activeTextLabel then
            activeTextLabel.TextColor3 = Theme.Text
        end

        local activeIcon = TabButton:FindFirstChild("ContentFrame"):FindFirstChild("TabIcon")
        if activeIcon then
            activeIcon.ImageColor3 = Theme.Text
        end

        TweenService:Create(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            BackgroundColor3 = Theme.Accent
        }):Play()

        if activeTextLabel then
            TweenService:Create(activeTextLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                TextColor3 = Theme.Text
            }):Play()
        end

        if activeIcon then
            TweenService:Create(activeIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                ImageColor3 = Theme.Text
            }):Play()
        end
    end)

    GUI.Tabs[TabContent] = {
        Button = TabButton,
        Content = TabContent
    }

    if GUI.CurrentTab == nil then
        TabContent.Visible = true
        TabButton.BackgroundColor3 = Theme.Accent
        GUI.CurrentTab = TabContent

        local firstTextLabel = TabButton:FindFirstChild("ContentFrame"):FindFirstChild("TabText")
        if firstTextLabel then
            firstTextLabel.TextColor3 = Theme.Text
        end

        local firstIcon = TabButton:FindFirstChild("ContentFrame"):FindFirstChild("TabIcon")
        if firstIcon then
            firstIcon.ImageColor3 = Theme.Text
        end
    end

    return TabContent
end

function GUI:CreateSlider(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "Slider"
    local min = config.min or config.Min or 0
    local max = config.max or config.Max or 100
    local default = config.default or config.Default or min
    local callback = config.callback or config.Callback

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider"
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Theme.Secondary
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 3)
    Label.Size = UDim2.new(1, -70, 0, 20)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(1, -60, 0, 3)
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.Text = tostring(default or min)
    ValueLabel.TextColor3 = Theme.Text
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Bar = Instance.new("Frame")
    Bar.Name = "Bar"
    Bar.Parent = SliderFrame
    Bar.BackgroundColor3 = Theme.Border
    Bar.BorderSizePixel = 0
    Bar.Position = UDim2.new(0, 10, 0, 30)
    Bar.Size = UDim2.new(1, -20, 0, 8)

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 4)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Parent = Bar
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Position = UDim2.new(0, 0, 0, 0)
    Fill.Size = UDim2.new(0, 0, 1, 0)

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Parent = Bar
    Knob.BackgroundColor3 = Theme.Accent
    Knob.BorderSizePixel = 0
    Knob.Size = UDim2.new(0, 16, 1.5, 0)
    Knob.Position = UDim2.new(0, 0, -0.25, 0)

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local dragging = false
    local value = default or min

    local function setValue(newValue, fireCallback)
        newValue = math.clamp(newValue, min, max)
        value = newValue
        local percent = (value - min) / (max - min)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Knob.Position = UDim2.new(percent, -8, -0.25, 0)
        ValueLabel.Text = string.format("%.2f", value)
        if callback and fireCallback then
            callback(value)
        end
    end

    local function beginDrag(input)
        dragging = true
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        local function update(pos)
            local x
            if pos then
                x = pos.X
            else
                x = mouse.X
            end
            local rel = math.clamp(x - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X)
            local percent = rel / Bar.AbsoluteSize.X
            local newValue = min + (max - min) * percent
            setValue(newValue, true)
        end
        if input.UserInputType == Enum.UserInputType.Touch then
            update(input.Position)
        else
            update()
        end

        local moveConn, upConn

        if input.UserInputType == Enum.UserInputType.Touch then
            moveConn = input.TouchMoved:Connect(function(touch)
                if dragging then
                    update(touch.Position)
                end
            end)
            upConn = input.TouchEnded:Connect(function()
                dragging = false
                if moveConn then moveConn:Disconnect() end
                if upConn then upConn:Disconnect() end
            end)
        else
            moveConn = game:GetService("UserInputService").InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i.Position)
                end
            end)
            upConn = game:GetService("UserInputService").InputEnded:Connect(function(i)
                if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                    dragging = false
                    if moveConn then moveConn:Disconnect() end
                    if upConn then upConn:Disconnect() end
                end
            end)
        end
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)

    setValue(value, false)

    local SliderObject = {}

    function SliderObject:Set(newValue)
        setValue(newValue, true)
    end

    function SliderObject:Get()
        return value
    end

    return SliderObject
end

function GUI:CreateButton(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "Button"
    local callback = config.callback or config.Callback

    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = "Button"
    ButtonFrame.Parent = parent
    ButtonFrame.BackgroundColor3 = Theme.Secondary
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Size = UDim2.new(1, 0, 0, 35)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ButtonFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ButtonFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Button = Instance.new("ImageButton")
    Button.Parent = ButtonFrame
    Button.BackgroundColor3 = Theme.Accent
    Button.BorderSizePixel = 0
    Button.Position = UDim2.new(1, -60, 0.5, -12)
    Button.Size = UDim2.new(0, 50, 0, 24)
    Button.Image = getAssetUri(getIcon("mouse-pointer-click").id)
    Button.ImageRectSize = getIcon("mouse-pointer-click").imageRectSize
    Button.ImageRectOffset = getIcon("mouse-pointer-click").imageRectOffset
    Button.ImageColor3 = Theme.Text
    Button.ScaleType = Enum.ScaleType.Fit

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(118, 23, 206)})
        tween:Play()
        tween.Completed:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
        end)
        if callback then callback() end
    end)

    return ButtonFrame
end

function GUI:CreateToggle(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "Toggle"
    local default = config.default or config.Default or false
    local callback = config.callback or config.Callback

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle"
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = Theme.Secondary
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    -- Switch background
    local Switch = Instance.new("Frame")
    Switch.Name = "Switch"
    Switch.Parent = ToggleFrame
    Switch.BackgroundColor3 = default and Theme.Accent or Theme.Border
    Switch.BorderSizePixel = 0
    Switch.Position = UDim2.new(1, -60, 0.5, -12)
    Switch.Size = UDim2.new(0, 50, 0, 24)

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(0, 12)
    SwitchCorner.Parent = Switch

    -- Knob
    local Knob = Instance.new("Frame")
    Knob.Name = "Knob"
    Knob.Parent = Switch
    Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Knob.BorderSizePixel = 0
    Knob.Size = UDim2.new(0, 20, 0, 20)
    Knob.Position = default and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 4, 0, 2)

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    -- Make the whole switch clickable
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = Switch
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
    ToggleButton.Text = ""

    local toggled = default

    local ToggleObject = {}

    function ToggleObject:Set(value)
        toggled = value
        -- Animate background color
        TweenService:Create(Switch, TweenInfo.new(0.2), {
            BackgroundColor3 = toggled and Theme.Accent or Theme.Border
        }):Play()
        -- Animate knob position
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = toggled and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 4, 0, 2)
        }):Play()
        if callback then callback(toggled) end
    end

    function ToggleObject:Get()
        return toggled
    end

    task.defer(function()
        if callback then callback(toggled) end
    end)

    ToggleButton.MouseButton1Click:Connect(function()
        ToggleObject:Set(not toggled)
    end)

    return ToggleObject
end

function GUI:CreateDropdown(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "Dropdown"
    local options = config.options or config.Options or {}
    local callback = config.callback or config.Callback

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown"
    DropdownFrame.Parent = parent
    DropdownFrame.BackgroundColor3 = Theme.Secondary
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Size = UDim2.new(1, 0, 0, 35)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = DropdownFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = DropdownFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -120, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundColor3 = Theme.Border
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Position = UDim2.new(1, -110, 0.5, -12)
    DropdownButton.Size = UDim2.new(0, 100, 0, 24)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = options[1] or "Select..."
    DropdownButton.TextColor3 = Theme.Text
    DropdownButton.TextSize = 12
    DropdownButton.ZIndex = 50

    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownButton

    local DropdownList = Instance.new("Frame")
    DropdownList.Name = "DropdownList"
    DropdownList.Parent = GUI.MainFrame.Parent
    DropdownList.BackgroundColor3 = Theme.Background
    DropdownList.BorderSizePixel = 0
    DropdownList.Position = UDim2.new(0, 0, 0, 0)
    DropdownList.Size = UDim2.new(0, 100, 0, #options * 30)
    DropdownList.Visible = false
    DropdownList.ZIndex = 100

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = DropdownList
    UIStroke.Color = Theme.Border
    UIStroke.Thickness = 1

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropdownList

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = DropdownList

    local currentOptions = {}
    local currentValue = options[1] or nil

    for _, option in ipairs(options) do
        table.insert(currentOptions, option)
    end

    local function createOptionButton(option)
        local OptionButton = Instance.new("TextButton")
        OptionButton.Parent = DropdownList
        OptionButton.BackgroundTransparency = 1
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.Text = option
        OptionButton.TextColor3 = Theme.TextSecondary
        OptionButton.TextSize = 12
        OptionButton.ZIndex = 11

        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Theme.Accent
            OptionButton.BackgroundTransparency = 0.8
        end)

        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundTransparency = 1
        end)

        OptionButton.MouseButton1Click:Connect(function()
            currentValue = option
            DropdownButton.Text = option
            DropdownList.Visible = false

            if callback then
                callback(option)
            end
        end)

        return OptionButton
    end

    local function refreshDropdownList()
        for _, child in ipairs(DropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, option in ipairs(currentOptions) do
            createOptionButton(option)
        end

        DropdownList.Size = UDim2.new(0, 100, 0, #currentOptions * 30)
    end

    refreshDropdownList()

    local function updateDropdownPosition()
        local buttonPos = DropdownButton.AbsolutePosition
        local buttonSize = DropdownButton.AbsoluteSize
        DropdownList.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 5)
    end

    DropdownButton.MouseButton1Click:Connect(function()
        if not DropdownList.Visible then
            updateDropdownPosition()
            DropdownList.Visible = true
        else
            DropdownList.Visible = false
        end
    end)

    local DropdownObject = {}

    function DropdownObject:Add(item)
        if type(item) == "table" then
            for _, value in ipairs(item) do
                if not table.find(currentOptions, value) then
                    table.insert(currentOptions, value)
                end
            end
        elseif type(item) == "string" then
            if not table.find(currentOptions, item) then
                table.insert(currentOptions, item)
            end
        end
        refreshDropdownList()
    end

    task.defer(function()
        if callback then callback(options[1]) end
    end)

    function DropdownObject:List()
        return currentOptions
    end

    function DropdownObject:Get()
        return currentValue
    end

    return DropdownObject
end

function GUI:CreateKeyBind(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "KeyBind"
    local default = config.default or config.Default or "None"
    local callback = config.callback or config.Callback

    local KeyBindFrame = Instance.new("Frame")
    KeyBindFrame.Name = "KeyBind"
    KeyBindFrame.Parent = parent
    KeyBindFrame.BackgroundColor3 = Theme.Secondary
    KeyBindFrame.BorderSizePixel = 0
    KeyBindFrame.Size = UDim2.new(1, 0, 0, 35)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = KeyBindFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = KeyBindFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -120, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local KeyBindButton = Instance.new("TextButton")
    KeyBindButton.Parent = KeyBindFrame
    KeyBindButton.BackgroundColor3 = Theme.Border
    KeyBindButton.BorderSizePixel = 0
    KeyBindButton.Position = UDim2.new(1, -110, 0.5, -12)
    KeyBindButton.Size = UDim2.new(0, 100, 0, 24)
    KeyBindButton.Font = Enum.Font.Gotham
    KeyBindButton.Text = default or "None"
    KeyBindButton.TextColor3 = Theme.Text
    KeyBindButton.TextSize = 12

    local KeyBindCorner = Instance.new("UICorner")
    KeyBindCorner.CornerRadius = UDim.new(0, 8)
    KeyBindCorner.Parent = KeyBindButton

    local currentKey = default
    local isListening = false
    local connection = nil

    local function getKeyName(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            return "M1"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            return "M2"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            return "M3"
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            return input.KeyCode.Name
        else
            return "Unknown"
        end
    end

    local function stopListening()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        isListening = false
        KeyBindButton.Text = currentKey or "None"
        KeyBindButton.BackgroundColor3 = Theme.Border
        GUI.isDraggingEnabled = true
    end

    local function startListening()
        if isListening then return end

        isListening = true
        GUI.isDraggingEnabled = false
        KeyBindButton.Text = "Press any key..."
        KeyBindButton.BackgroundColor3 = Theme.Accent

        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end

            if input.UserInputType == Enum.UserInputType.Keyboard or
               input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.MouseButton2 or
               input.UserInputType == Enum.UserInputType.MouseButton3 then

                if input.KeyCode == Enum.KeyCode.Escape then
                    stopListening()
                    return
                end

                local keyName = getKeyName(input)
                currentKey = keyName
                stopListening()

                if callback then
                    callback(keyName, input)
                end
            end
        end)
    end

    local triggerConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or isListening then return end

        if currentKey and currentKey ~= "None" then
            local inputKeyName = getKeyName(input)
            if inputKeyName == currentKey and callback then
                callback(currentKey, input, true)
            end
        end
    end)

    KeyBindButton.MouseButton1Click:Connect(function()
        if isListening then
            stopListening()
        else
            startListening()
        end
    end)

    KeyBindFrame.AncestryChanged:Connect(function()
        if not KeyBindFrame.Parent then
            if connection then
                connection:Disconnect()
            end
            if triggerConnection then
                triggerConnection:Disconnect()
            end
        end
    end)

    local KeyBindObject = {}

    function KeyBindObject:Set(key)
        currentKey = key
        KeyBindButton.Text = key or "None"
        KeyBindButton.BackgroundColor3 = Theme.Border
    end

    function KeyBindObject:Get()
        return currentKey
    end

    return KeyBindObject
end

function GUI:CreateInput(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "Input"
    local placeholder = config.placeholder or config.Placeholder or ""
    local callback = config.callback or config.Callback

    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "Input"
    InputFrame.Parent = parent
    InputFrame.BackgroundColor3 = Theme.Secondary
    InputFrame.BorderSizePixel = 0
    InputFrame.Size = UDim2.new(1, 0, 0, 35)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = InputFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = InputFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -120, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local TextBox = Instance.new("TextBox")
    TextBox.Parent = InputFrame
    TextBox.BackgroundColor3 = Theme.Border
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(1, -110, 0.5, -12)
    TextBox.Size = UDim2.new(0, 100, 0, 24)
    TextBox.Font = Enum.Font.Gotham
    TextBox.PlaceholderText = placeholder
    TextBox.Text = ""
    TextBox.TextColor3 = Theme.Text
    TextBox.TextSize = 12
    TextBox.TextXAlignment = Enum.TextXAlignment.Center
    TextBox.ClipsDescendants = true

    local TextBoxPadding = Instance.new("UIPadding")
    TextBoxPadding.Parent = TextBox
    TextBoxPadding.PaddingLeft = UDim.new(0, 5)
    TextBoxPadding.PaddingRight = UDim.new(0, 5)

    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 8)
    TextBoxCorner.Parent = TextBox

    local InputObject = {}

    function InputObject:Set(value)
        TextBox.Text = tostring(value)
        if callback then
            callback(TextBox.Text)
        end
    end

    function InputObject:Get()
        return TextBox.Text
    end

    if callback then
        TextBox.FocusLost:Connect(function()
            callback(TextBox.Text)
        end)
    end

    return InputObject
end

function GUI:CreateParagraph(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or ""

    local ParagraphFrame = Instance.new("Frame")
    ParagraphFrame.Name = "Paragraph"
    ParagraphFrame.Parent = parent
    ParagraphFrame.BackgroundColor3 = Theme.Secondary
    ParagraphFrame.BorderSizePixel = 0
    ParagraphFrame.Size = UDim2.new(1, 0, 0, 60)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ParagraphFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = ParagraphFrame
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 10, 0, 10)
    TextLabel.Size = UDim2.new(1, -20, 1, -20)
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.Text = text
    TextLabel.TextColor3 = Theme.TextSecondary
    TextLabel.TextSize = 15
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top

    local currentText = text

    local function updateSize()
        local textBounds = game:GetService("TextService"):GetTextSize(
            currentText, 15, Enum.Font.Gotham, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)
        )
        ParagraphFrame.Size = UDim2.new(1, 0, 0, textBounds.Y + 20)
    end

    TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
    updateSize()

    local ParagraphObject = {}

    function ParagraphObject:Set(value)
        currentText = tostring(value)
        TextLabel.Text = currentText
        updateSize()
    end

    function ParagraphObject:Get()
        return currentText
    end

    return ParagraphObject
end

function GUI:CreateSection(config)
    local parent = config.parent or config.Parent
    local title = config.text or config.Text or config.title or config.Title or "Section"

    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "Section"
    SectionFrame.Parent = parent
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Size = UDim2.new(1, 0, 0, 30)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = SectionFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 4, 0, 4)
    TitleLabel.Size = UDim2.new(1, -8, 0, 18)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

    local Divider = Instance.new("Frame")
    Divider.Parent = SectionFrame
    Divider.BackgroundColor3 = Theme.Border
    Divider.BorderSizePixel = 0
    Divider.Position = UDim2.new(0, 0, 0, 26)
    Divider.Size = UDim2.new(1, 0, 0, 1)

    local currentTitle = title

    local SectionObject = {}

    function SectionObject:Set(value)
        currentTitle = tostring(value)
        TitleLabel.Text = currentTitle
    end

    function SectionObject:Get()
        return currentTitle
    end

    return SectionObject
end

function GUI:CreateColorPicker(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "Color Picker"
    local default = config.default or config.Default or Color3.fromRGB(255, 0, 0)
    local callback = config.callback or config.Callback

    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Name = "ColorPicker"
    ColorPickerFrame.Parent = parent
    ColorPickerFrame.BackgroundColor3 = Theme.Secondary
    ColorPickerFrame.BorderSizePixel = 0
    ColorPickerFrame.Size = UDim2.new(1, 0, 0, 35)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ColorPickerFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ColorPickerFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ColorButton = Instance.new("TextButton")
    ColorButton.Parent = ColorPickerFrame
    ColorButton.BackgroundColor3 = default
    ColorButton.BorderSizePixel = 0
    ColorButton.Position = UDim2.new(1, -60, 0.5, -12)
    ColorButton.Size = UDim2.new(0, 50, 0, 24)
    ColorButton.Text = ""

    local ColorCorner = Instance.new("UICorner")
    ColorCorner.CornerRadius = UDim.new(0, 8)
    ColorCorner.Parent = ColorButton

    local isColorPickerOpen = false
    local currentColor = default

    ColorButton.MouseButton1Click:Connect(function()
        if isColorPickerOpen then return end

        isColorPickerOpen = true
        GUI.isDraggingEnabled = false

        local ColorPickerGui = Instance.new("ScreenGui")
        ColorPickerGui.Name = "ColorPickerGui"
        ColorPickerGui.Parent = game.CoreGui
        ColorPickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local ColorWindow = Instance.new("Frame")
        ColorWindow.Name = "ColorWindow"
        ColorWindow.Parent = ColorPickerGui
        ColorWindow.BackgroundColor3 = Theme.Background
        ColorWindow.BorderSizePixel = 0
        ColorWindow.Position = UDim2.new(0.5, -150, 0.5, -125)
        ColorWindow.Size = UDim2.new(0, 300, 0, 250)

        local WindowCorner = Instance.new("UICorner")
        WindowCorner.CornerRadius = UDim.new(0, 8)
        WindowCorner.Parent = ColorWindow

        local TitleBar = Instance.new("Frame")
        TitleBar.Name = "TitleBar"
        TitleBar.Parent = ColorWindow
        TitleBar.BackgroundTransparency = 1
        TitleBar.Position = UDim2.new(0, 0, 0, 0)
        TitleBar.Size = UDim2.new(1, 0, 0, 30)

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = TitleBar
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Position = UDim2.new(0, 10, 0, 0)
        TitleLabel.Size = UDim2.new(1, -40, 1, 0)
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.Text = "Color Picker"
        TitleLabel.TextColor3 = Theme.Text
        TitleLabel.TextSize = 14
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Parent = TitleBar
        CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 87)
        CloseBtn.BorderSizePixel = 0
        CloseBtn.Position = UDim2.new(1, -25, 0.5, -8)
        CloseBtn.Size = UDim2.new(0, 16, 0, 16)
        CloseBtn.Text = ""

        local CloseCorner = Instance.new("UICorner")
        CloseCorner.CornerRadius = UDim.new(1, 0)
        CloseCorner.Parent = CloseBtn

        local ColorCanvas = Instance.new("Frame")
        ColorCanvas.Name = "ColorCanvas"
        ColorCanvas.Parent = ColorWindow
        ColorCanvas.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ColorCanvas.BorderSizePixel = 0
        ColorCanvas.Position = UDim2.new(0, 10, 0, 40)
        ColorCanvas.Size = UDim2.new(0, 200, 0, 150)

        local CanvasCorner = Instance.new("UICorner")
        CanvasCorner.CornerRadius = UDim.new(0, 4)
        CanvasCorner.Parent = ColorCanvas

        local SaturationGradient = Instance.new("UIGradient")
        SaturationGradient.Parent = ColorCanvas
        SaturationGradient.Rotation = 0
        SaturationGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        })

        local ValueOverlay = Instance.new("Frame")
        ValueOverlay.Parent = ColorCanvas
        ValueOverlay.BackgroundTransparency = 0
        ValueOverlay.BorderSizePixel = 0
        ValueOverlay.Position = UDim2.new(0, 0, 0, 0)
        ValueOverlay.Size = UDim2.new(1, 0, 1, 0)

        local ValueGradient = Instance.new("UIGradient")
        ValueGradient.Parent = ValueOverlay
        ValueGradient.Rotation = 270
        ValueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
        ValueGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })

        local HueBar = Instance.new("Frame")
        HueBar.Name = "HueBar"
        HueBar.Parent = ColorWindow
        HueBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        HueBar.BorderSizePixel = 0
        HueBar.Position = UDim2.new(0, 220, 0, 40)
        HueBar.Size = UDim2.new(0, 20, 0, 150)

        local HueCorner = Instance.new("UICorner")
        HueCorner.CornerRadius = UDim.new(0, 4)
        HueCorner.Parent = HueBar

        local ColorPreview = Instance.new("Frame")
        ColorPreview.Name = "ColorPreview"
        ColorPreview.Parent = ColorWindow
        ColorPreview.BackgroundColor3 = currentColor
        ColorPreview.BorderSizePixel = 0
        ColorPreview.Position = UDim2.new(0, 250, 0, 40)
        ColorPreview.Size = UDim2.new(0, 40, 0, 40)

        local PreviewCorner = Instance.new("UICorner")
        PreviewCorner.CornerRadius = UDim.new(0, 4)
        PreviewCorner.Parent = ColorPreview

        local RGBLabel = Instance.new("TextLabel")
        RGBLabel.Parent = ColorWindow
        RGBLabel.BackgroundTransparency = 1
        RGBLabel.Position = UDim2.new(0, 250, 0, 90)
        RGBLabel.Size = UDim2.new(0, 40, 0, 20)
        RGBLabel.Font = Enum.Font.Gotham
        RGBLabel.Text = string.format("%d,%d,%d", currentColor.R*255, currentColor.G*255, currentColor.B*255)
        RGBLabel.TextColor3 = Theme.Text
        RGBLabel.TextSize = 10
        RGBLabel.TextXAlignment = Enum.TextXAlignment.Center

        local ButtonFrame = Instance.new("Frame")
        ButtonFrame.Name = "ButtonFrame"
        ButtonFrame.Parent = ColorWindow
        ButtonFrame.BackgroundTransparency = 1
        ButtonFrame.Position = UDim2.new(0, 10, 0, 200)
        ButtonFrame.Size = UDim2.new(1, -20, 0, 40)

        local OKButton = Instance.new("TextButton")
        OKButton.Parent = ButtonFrame
        OKButton.BackgroundColor3 = Theme.Accent
        OKButton.BorderSizePixel = 0
        OKButton.Position = UDim2.new(1, -140, 0, 10)
        OKButton.Size = UDim2.new(0, 60, 0, 25)
        OKButton.Font = Enum.Font.Gotham
        OKButton.Text = "OK"
        OKButton.TextColor3 = Theme.Text
        OKButton.TextSize = 12

        local OKCorner = Instance.new("UICorner")
        OKCorner.CornerRadius = UDim.new(0, 4)
        OKCorner.Parent = OKButton

        local CancelButton = Instance.new("TextButton")
        CancelButton.Parent = ButtonFrame
        CancelButton.BackgroundColor3 = Theme.Border
        CancelButton.BorderSizePixel = 0
        CancelButton.Position = UDim2.new(1, -70, 0, 10)
        CancelButton.Size = UDim2.new(0, 60, 0, 25)
        CancelButton.Font = Enum.Font.Gotham
        CancelButton.Text = "Cancel"
        CancelButton.TextColor3 = Theme.Text
        CancelButton.TextSize = 12

        local CancelCorner = Instance.new("UICorner")
        CancelCorner.CornerRadius = UDim.new(0, 4)
        CancelCorner.Parent = CancelButton

        local hue = 0
        local saturation = 1
        local value = 1

        local function HSVtoRGB(h, s, v)
            local r, g, b
            local i = math.floor(h * 6)
            local f = h * 6 - i
            local p = v * (1 - s)
            local q = v * (1 - f * s)
            local t = v * (1 - (1 - f) * s)

            local remainder = i % 6
            if remainder == 0 then
                r, g, b = v, t, p
            elseif remainder == 1 then
                r, g, b = q, v, p
            elseif remainder == 2 then
                r, g, b = p, v, t
            elseif remainder == 3 then
                r, g, b = p, q, v
            elseif remainder == 4 then
                r, g, b = t, p, v
            elseif remainder == 5 then
                r, g, b = v, p, q
            end

            return Color3.fromRGB(math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
        end

        local function updateColor()
            currentColor = HSVtoRGB(hue, saturation, value)
            ColorPreview.BackgroundColor3 = currentColor
            RGBLabel.Text = string.format("%d,%d,%d", currentColor.R*255, currentColor.G*255, currentColor.B*255)
        end

        local function updateCanvasGradient()
            local hueColor = HSVtoRGB(hue, 1, 1)
            SaturationGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, hueColor)
            })
        end

        local function updateHueBar()
            HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            local gradient = Instance.new("UIGradient")
            gradient.Parent = HueBar
            gradient.Rotation = 90
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
        end

        updateHueBar()
        updateCanvasGradient()
        updateColor()

        ColorCanvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = Players.LocalPlayer:GetMouse()
                local connection
                connection = UserInputService.InputChanged:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativePos = Vector2.new(mouse.X - ColorCanvas.AbsolutePosition.X, mouse.Y - ColorCanvas.AbsolutePosition.Y)
                        saturation = math.clamp(relativePos.X / ColorCanvas.AbsoluteSize.X, 0, 1)
                        value = math.clamp(1 - (relativePos.Y / ColorCanvas.AbsoluteSize.Y), 0, 1)
                        updateColor()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input3)
                    if input3.UserInputType == Enum.UserInputType.MouseButton1 then
                        connection:Disconnect()
                    end
                end)
            end
        end)

        HueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = Players.LocalPlayer:GetMouse()
                local connection
                connection = UserInputService.InputChanged:Connect(function(input2)
                    if input2.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeY = mouse.Y - HueBar.AbsolutePosition.Y
                        hue = math.clamp(relativeY / HueBar.AbsoluteSize.Y, 0, 1)
                        updateCanvasGradient()
                        updateColor()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input3)
                    if input3.UserInputType == Enum.UserInputType.MouseButton1 then
                        connection:Disconnect()
                    end
                end)
            end
        end)

        local function closeColorPicker()
            isColorPickerOpen = false
            GUI.isDraggingEnabled = true
            ColorPickerGui:Destroy()
        end

        OKButton.MouseButton1Click:Connect(function()
            ColorButton.BackgroundColor3 = currentColor
            if callback then
                callback(currentColor)
            end
            closeColorPicker()
        end)

        CancelButton.MouseButton1Click:Connect(function()
            closeColorPicker()
        end)

        CloseBtn.MouseButton1Click:Connect(function()
            closeColorPicker()
        end)
    end)

    local ColorPickerObject = {}

    function ColorPickerObject:Set(value)
        if typeof(value) == "Color3" then
            currentColor = value
            ColorButton.BackgroundColor3 = value
            if callback then
                callback(currentColor)
            end
        end
    end

    function ColorPickerObject:Get()
        return currentColor
    end

    return ColorPickerObject
end

function GUI:CreateNotify(config)
    local title = config.title or config.Title or "Notification"
    local description = config.description or config.Description or config.text or config.Text or "No description provided"
    local duration = config.time or config.duration or 5

    if not _G.NotificationStack then
        _G.NotificationStack = {}
    end

    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "NotificationGui"
    NotificationGui.Parent = game.CoreGui
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local camera = workspace.CurrentCamera
    local screenSize = camera.ViewportSize

    local notifWidth = math.min(screenSize.X * 0.25, 300)
    local notifHeight = 90
    local notifSpacing = 10

    if screenSize.X < 400 then
        notifWidth = screenSize.X - 20
    end

    -- Always insert new notification at the top (index 1)
    table.insert(_G.NotificationStack, 1, {
        Frame = nil, -- will be set after creation
        Gui = NotificationGui,
        Index = 1
    })

    local function repositionNotifications()
        for i, notif in ipairs(_G.NotificationStack) do
            if notif.Frame and notif.Frame.Parent then
                local newYOffset = 20 + ((i - 1) * (notifHeight + notifSpacing))
                TweenService:Create(
                    notif.Frame,
                    TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {Position = UDim2.new(1, -notifWidth - 20, 1, -newYOffset - notifHeight)}
                ):Play()
            end
        end
    end

    local yOffset = 20 -- always at the top

    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Parent = NotificationGui
    NotificationFrame.BackgroundColor3 = Theme.Background
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Position = UDim2.new(1, 20, 1, -yOffset - notifHeight)
    NotificationFrame.Size = UDim2.new(0, notifWidth, 0, notifHeight)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = NotificationFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = NotificationFrame
    UIStroke.Color = Theme.Accent
    UIStroke.Thickness = 1

    local AccentBar = Instance.new("Frame")
    AccentBar.Name = "AccentBar"
    AccentBar.Parent = NotificationFrame
    AccentBar.BackgroundColor3 = Theme.Accent
    AccentBar.BorderSizePixel = 0
    AccentBar.Position = UDim2.new(0, 0, 0, 0)
    AccentBar.Size = UDim2.new(0, 4, 1, 0)

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(0, 8)
    BarCorner.Parent = AccentBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = NotificationFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 8)
    TitleLabel.Size = UDim2.new(1, -50, 0, 28)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
    TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd

    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Name = "DescriptionLabel"
    DescriptionLabel.Parent = NotificationFrame
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Position = UDim2.new(0, 15, 0, 38)
    DescriptionLabel.Size = UDim2.new(1, -50, 0, 48)
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.Text = description
    DescriptionLabel.TextColor3 = Theme.TextSecondary
    DescriptionLabel.TextSize = 14
    DescriptionLabel.TextWrapped = true
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.TextYAlignment = Enum.TextYAlignment.Top

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = NotificationFrame
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Theme.TextSecondary
    CloseButton.TextSize = 20

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Parent = NotificationFrame
    ProgressBar.BackgroundColor3 = Theme.Accent
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Position = UDim2.new(0, 0, 1, -2)
    ProgressBar.Size = UDim2.new(1, 0, 0, 2)

    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 1)
    ProgressCorner.Parent = ProgressBar

    -- Set the Frame in the stack entry
    _G.NotificationStack[1].Frame = NotificationFrame

    local function removeFromStack(targetFrame)
        for i, notif in ipairs(_G.NotificationStack) do
            if notif.Frame == targetFrame then
                table.remove(_G.NotificationStack, i)
                break
            end
        end
        repositionNotifications()
    end

    local slideInTween = TweenService:Create(
        NotificationFrame,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -notifWidth - 20, 1, -yOffset - notifHeight)}
    )

    local slideOutTween = TweenService:Create(
        NotificationFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {Position = UDim2.new(1, 20, 1, -yOffset - notifHeight)}
    )

    local progressTween = TweenService:Create(
        ProgressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )

    local function closeNotification()
        progressTween:Cancel()
        slideOutTween:Play()
        slideOutTween.Completed:Connect(function()
            removeFromStack(NotificationFrame)
            NotificationGui:Destroy()
        end)
    end

    CloseButton.MouseButton1Click:Connect(closeNotification)

    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            TextColor3 = Theme.Text
        }):Play()
    end)

    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            TextColor3 = Theme.TextSecondary
        }):Play()
    end)

    local function updatePosition()
        local newScreenSize = workspace.CurrentCamera.ViewportSize
        local newNotifWidth = math.min(newScreenSize.X * 0.25, 300)

        if newScreenSize.X < 400 then
            newNotifWidth = newScreenSize.X - 20
        end

        NotificationFrame.Size = UDim2.new(0, newNotifWidth, 0, notifHeight)
        repositionNotifications()
    end

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updatePosition)

    slideInTween:Play()
    slideInTween.Completed:Connect(function()
        repositionNotifications()
        progressTween:Play()
        progressTween.Completed:Connect(closeNotification)
    end)

    -- Reposition all notifications so the new one is at the top
    repositionNotifications()

    return NotificationFrame
end

function GUI:CreateDivider(config)
    local parent = (config and (config.parent or config.Parent)) or nil
    local height = (config and (config.height or config.Height)) or 1

    local DividerFrame = Instance.new("Frame")
    DividerFrame.Name = "Divider"
    DividerFrame.BackgroundTransparency = 1
    DividerFrame.BorderSizePixel = 0
    DividerFrame.Size = UDim2.new(1, 0, 0, height)
    if parent then
        DividerFrame.Parent = parent
    end

    return DividerFrame
end