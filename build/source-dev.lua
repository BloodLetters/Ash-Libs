local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local GUI = {}
GUI.CurrentTab = nil
GUI.Settings = {}

if _G.ModernGUIInstance then
    _G.ModernGUIInstance:Destroy()
    _G.ModernGUIInstance = nil
end

local DefaultTheme = {
    Background = Color3.fromRGB(15, 15, 25),
    Secondary = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(138, 43, 226),
    AccentSecondary = Color3.fromRGB(118, 23, 206),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(45, 45, 55),
    NavBackground = Color3.fromRGB(20, 20, 30),
    Surface = Color3.fromRGB(30, 30, 40),
    SurfaceVariant = Color3.fromRGB(35, 35, 45),
    Success = Color3.fromRGB(40, 201, 64),
    Warning = Color3.fromRGB(255, 189, 46),
    Error = Color3.fromRGB(255, 95, 87),
    Shadow = Color3.fromRGB(0, 0, 0)
}

local Theme = DefaultTheme
GUI.isMinimized = false

function GUI:CreateMain(config)
    local settings = {
        Name = config.Name or "Ashlabs",
        title = config.title or config.Title or "Ashlabs UI",
        ToggleUI = config.ToggleUI or "K",
        WindowIcon = config.WindowIcon or nil,
        WindowHeight = config.WindowHeight or nil,
        WindowWidth = config.WindowWidth or nil,
        Theme = config.Theme or DefaultTheme,
        alwaysIconOnly = config.alwaysIconOnly or config.alwaysIconOnly or false,
        Config = {
            Enabled = config.Config and config.Config.Enabled or false,
            FolderName = config.Config and config.Config.FolderName or "Ashlabs",
            FileName = config.Config and config.Config.FileName or config.Name
        },
        Blur = {
            Enable = config.Blur and config.Blur.Enable or false,
            value = config.Blur and config.Blur.value or 0.5
        },
    }

    if config.Theme then
        Theme = {}
        for key, value in pairs(DefaultTheme) do
            Theme[key] = config.Theme[key] or DefaultTheme[key]
        end
    end

    local windowSize
    if config.WindowHeight == nil and config.WindowWidth == nil then
        local camera = workspace.CurrentCamera
        local screenSize = camera.ViewportSize

        if screenSize.X < 800 then
            windowSize = UDim2.new(0, math.min(screenSize.X - 40, 420), 0, math.min(screenSize.Y - 40, 400))
        else
            windowSize = UDim2.new(0, 600, 0, 400)
        end
    else
        windowSize = UDim2.new(0, config.WindowWidth, 0, config.WindowHeight)
    end

    GUI.Settings = settings

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = settings.Name
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _G.ModernGUIInstance = ScreenGui

    local ShadowFrame = Instance.new("Frame")
    ShadowFrame.Name = "ShadowFrame"
    ShadowFrame.Parent = ScreenGui
    ShadowFrame.BackgroundColor3 = Theme.Shadow
    ShadowFrame.BackgroundTransparency = 0.7
    ShadowFrame.BorderSizePixel = 0
    ShadowFrame.Position = UDim2.new(0.5, -245, 0.5, -195)
    ShadowFrame.Size = UDim2.new(0, windowSize.X.Offset + 10, 0, windowSize.Y.Offset + 10)
    ShadowFrame.ZIndex = 0

    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 12)
    ShadowCorner.Parent = ShadowFrame

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = settings.Blur.Enable and Color3.fromRGB(255, 255, 255) or Theme.Background
    MainFrame.BackgroundTransparency = settings.Blur.Enable and settings.Blur.value or 0
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.Size = config.WindowSize or windowSize
    MainFrame.ZIndex = 1

    local BorderStroke = Instance.new("UIStroke")
    BorderStroke.Parent = MainFrame
    BorderStroke.Color = Theme.Border
    BorderStroke.Thickness = 1
    BorderStroke.Transparency = 0.5

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    local GradientOverlay = Instance.new("Frame")
    GradientOverlay.Name = "GradientOverlay"
    GradientOverlay.Parent = MainFrame
    GradientOverlay.BackgroundTransparency = 1
    GradientOverlay.Size = UDim2.new(1, 0, 1, 0)
    GradientOverlay.ZIndex = 2

    local GradientOverlayCorner = Instance.new("UICorner")
    GradientOverlayCorner.CornerRadius = UDim.new(0, 12)
    GradientOverlayCorner.Parent = GradientOverlay

    local BackgroundGradient = Instance.new("UIGradient")
    BackgroundGradient.Parent = GradientOverlay
    BackgroundGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    BackgroundGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.98),
        NumberSequenceKeypoint.new(0.5, 0.99),
        NumberSequenceKeypoint.new(1, 0.97)
    })
    BackgroundGradient.Rotation = 45

    if settings.Blur.Enable then
        local BlurEffect = Instance.new("BlurEffect")
        BlurEffect.Size = 50
        BlurEffect.Parent = workspace.CurrentCamera

        GUI.BlurEffect = BlurEffect
    end

    GUI.isDraggingEnabled = true

    local function makeDraggableConditional(frame)
        local dragging = false
        local dragStart = nil
        local startPos = nil

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and GUI.isDraggingEnabled then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                TweenService:Create(BorderStroke, TweenInfo.new(0.2), {
                    Color = Theme.Accent,
                    Transparency = 0.3
                }):Play()
            end

            if input.UserInputType == Enum.UserInputType.Touch and GUI.isDraggingEnabled then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if GUI.isDraggingEnabled then
                if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    ShadowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X - 5, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 5)
                elseif input.UserInputType == Enum.UserInputType.Touch and dragging then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    ShadowFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X - 5, startPos.Y.Scale, startPos.Y.Offset + delta.Y + 5)
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                TweenService:Create(BorderStroke, TweenInfo.new(0.2), {
                    Color = Theme.Border,
                    Transparency = 0.5
                }):Play()
            end
        end)
    end

    local restoreButton = nil
    local function showRestoreButton()
        if restoreButton then return end
        local restoreGui = Instance.new("ScreenGui")
        restoreGui.Name = "RestoreButtonGui"
        restoreGui.Parent = game:GetService("CoreGui")
        restoreGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        restoreButton = Instance.new("TextButton")
        restoreButton.Name = "RestoreButton"
        restoreButton.Parent = restoreGui
        restoreButton.AnchorPoint = Vector2.new(0, 0)
        restoreButton.Position = UDim2.new(0, 20, 0, 20)
        restoreButton.Size = UDim2.new(0, 44, 0, 44)
        restoreButton.BackgroundColor3 = Theme.Accent
        restoreButton.Text = "🏠"
        restoreButton.TextColor3 = Theme.Text
        restoreButton.TextSize = 20
        restoreButton.Font = Enum.Font.GothamBold
        restoreButton.AutoButtonColor = false
        restoreButton.ZIndex = 999

        local restoreStroke = Instance.new("UIStroke")
        restoreStroke.Parent = restoreButton
        restoreStroke.Color = Theme.AccentSecondary
        restoreStroke.Thickness = 2

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = restoreButton

        local TweenService = game:GetService("TweenService")
        local tween = TweenService:Create(
            restoreButton,
            TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 20, 0, 20) }
        )
        tween:Play()

        restoreButton.MouseEnter:Connect(function()
            TweenService:Create(restoreButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 48, 0, 48),
                BackgroundColor3 = Theme.AccentSecondary
            }):Play()
        end)

        restoreButton.MouseLeave:Connect(function()
            TweenService:Create(restoreButton, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 44, 0, 44),
                BackgroundColor3 = Theme.Accent
            }):Play()
        end)

        restoreButton.MouseButton1Click:Connect(function()
            GUI:RestoreGUI()
            if restoreButton then
                local parentGui = restoreButton.Parent
                restoreButton:Destroy()
                restoreButton = nil
                if parentGui then
                    parentGui:Destroy()
                end
            end
        end)
    end

    local function hideRestoreButton()
        if restoreButton then
            restoreButton:Destroy()
            restoreButton = nil
        end
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
    TitleBar.BackgroundColor3 = Theme.Surface
    TitleBar.BackgroundTransparency = 0.1
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.ZIndex = 3

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 12)
    TitleBarCorner.Parent = TitleBar

    local TitleBarGradient = Instance.new("UIGradient")
    TitleBarGradient.Parent = TitleBar
    TitleBarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    TitleBarGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    })

    local AccentLine = Instance.new("Frame")
    AccentLine.Name = "AccentLine"
    AccentLine.Parent = TitleBar
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Position = UDim2.new(0, 15, 1, -2)
    AccentLine.Size = UDim2.new(1, -30, 0, 2)

    local AccentLineCorner = Instance.new("UICorner")
    AccentLineCorner.CornerRadius = UDim.new(0, 1)
    AccentLineCorner.Parent = AccentLine

    if config.WindowIcon and config.WindowIcon ~= "" and config.WindowIcon ~= nil then
        local iconData = getIcon(config.WindowIcon)
        local IconContainer = Instance.new("Frame")
        IconContainer.Name = "IconContainer"
        IconContainer.Parent = TitleBar
        IconContainer.BackgroundColor3 = Theme.Accent
        IconContainer.BackgroundTransparency = 0.9
        IconContainer.BorderSizePixel = 0
        IconContainer.Position = UDim2.new(0, 15, 0.5, -15)
        IconContainer.Size = UDim2.new(0, 30, 0, 30)

        local IconContainerCorner = Instance.new("UICorner")
        IconContainerCorner.CornerRadius = UDim.new(0, 8)
        IconContainerCorner.Parent = IconContainer

        local IconImage = Instance.new("ImageLabel")
        IconImage.Name = "WindowIcon"
        IconImage.Parent = IconContainer
        IconImage.BackgroundTransparency = 1
        IconImage.Position = UDim2.new(0, 7, 0, 7)
        IconImage.Size = UDim2.new(0, 16, 0, 16)
        IconImage.Image = getAssetUri(iconData.id)
        if iconData.imageRectSize ~= nil and iconData.imageRectOffset ~= nil then
            IconImage.ImageRectSize = iconData.imageRectSize 
            IconImage.ImageRectOffset = iconData.imageRectOffset
        else
            IconImage.ImageRectSize = Vector2.new(0, 0)
            IconImage.ImageRectOffset = Vector2.new(0, 0)
        end
        IconImage.ImageColor3 = Theme.Accent
        IconImage.ScaleType = Enum.ScaleType.Fit
        IconImage.ImageTransparency = 0
    end

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = TitleBar
    if config.WindowIcon and config.WindowIcon ~= "" and config.WindowIcon ~= nil then
        TitleLabel.Position = UDim2.new(0, 55, 0, 0)
        TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    else
        TitleLabel.Position = UDim2.new(0, 20, 0, 0)
        TitleLabel.Size = UDim2.new(0, 220, 1, 0)
    end
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = string.len(settings.title) > 35 and string.sub(settings.title, 1, 32) .. "..." or settings.title
    TitleLabel.TextColor3 = Theme.Text
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextYAlignment = Enum.TextYAlignment.Center

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TitleBar
    MinimizeButton.BackgroundColor3 = Theme.Warning
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Position = UDim2.new(1, -85, 0.5, -10)
    MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.Text = ""
    MinimizeButton.TextColor3 = Theme.Text
    MinimizeButton.TextSize = 14
    MinimizeButton.AutoButtonColor = false

    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(1, 0)
    MinimizeCorner.Parent = MinimizeButton

    local MaximizeButton = Instance.new("TextButton")
    MaximizeButton.Name = "MaximizeButton"
    MaximizeButton.Parent = TitleBar
    MaximizeButton.BackgroundColor3 = Theme.Success
    MaximizeButton.BorderSizePixel = 0
    MaximizeButton.Position = UDim2.new(1, -60, 0.5, -10)
    MaximizeButton.Size = UDim2.new(0, 20, 0, 20)
    MaximizeButton.Font = Enum.Font.Gotham
    MaximizeButton.Text = ""
    MaximizeButton.TextColor3 = Theme.Text
    MaximizeButton.TextSize = 14
    MaximizeButton.AutoButtonColor = false

    local MaximizeCorner = Instance.new("UICorner")
    MaximizeCorner.CornerRadius = UDim.new(1, 0)
    MaximizeCorner.Parent = MaximizeButton

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Theme.Error
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -35, 0.5, -10)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Text = ""
    CloseButton.TextColor3 = Theme.Text
    CloseButton.TextSize = 14
    CloseButton.AutoButtonColor = false

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton

    local function addButtonHoverEffect(button, hoverColor)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 22, 0, 22),
                BackgroundColor3 = hoverColor
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundColor3 = button == MinimizeButton and Theme.Warning or 
                                button == MaximizeButton and Theme.Success or Theme.Error
            }):Play()
        end)
    end

    addButtonHoverEffect(MinimizeButton, Color3.fromRGB(255, 204, 0))
    addButtonHoverEffect(MaximizeButton, Color3.fromRGB(52, 225, 78))
    addButtonHoverEffect(CloseButton, Color3.fromRGB(255, 120, 110))

    local isContentHidden = false
    local originalSize = MainFrame.Size

    local function isSmallScreen()
        local camera = workspace.CurrentCamera
        local screenSize = camera.ViewportSize
        return config.alwaysIconOnly or screenSize.X < 800
    end

    local function getNavWidth()
        return isSmallScreen() and 55 or 140
    end

    local NavFrame = Instance.new("Frame")
    NavFrame.Name = "Navigation"
    NavFrame.Parent = MainFrame
    NavFrame.BackgroundColor3 = settings.Blur.Enable and Color3.fromRGB(255, 255, 255) or Theme.NavBackground
    NavFrame.BackgroundTransparency = settings.Blur.Enable and 0.85 or 0.05
    NavFrame.BorderSizePixel = 0
    NavFrame.Position = UDim2.new(0, 15, 0, 60)
    NavFrame.Size = UDim2.new(0, getNavWidth(), 1, -120)
    NavFrame.ZIndex = 3

    local NavCorner = Instance.new("UICorner")
    NavCorner.CornerRadius = UDim.new(0, 12)
    NavCorner.Parent = NavFrame

    local NavStroke = Instance.new("UIStroke")
    NavStroke.Parent = NavFrame
    NavStroke.Color = Theme.Border
    NavStroke.Thickness = 1
    NavStroke.Transparency = 0.7

    local NavGradient = Instance.new("UIGradient")
    NavGradient.Parent = NavFrame
    NavGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    NavGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.97),
        NumberSequenceKeypoint.new(1, 0.95)
    })
    NavGradient.Rotation = 90

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
    NavList.Padding = UDim.new(0, 10)
    NavList.SortOrder = Enum.SortOrder.LayoutOrder

    local NavPadding = Instance.new("UIPadding")
    NavPadding.Parent = NavContent
    NavPadding.PaddingLeft = UDim.new(0, 12)
    NavPadding.PaddingRight = UDim.new(0, 12)
    NavPadding.PaddingTop = UDim.new(0, 20)
    NavPadding.PaddingBottom = UDim.new(0, 20)

    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "SettingsFrame"
    SettingsFrame.Parent = MainFrame
    SettingsFrame.BackgroundColor3 = settings.Blur.Enable and Color3.fromRGB(255, 255, 255) or Theme.NavBackground
    SettingsFrame.BackgroundTransparency = settings.Blur.Enable and 0.85 or 0.05
    SettingsFrame.BorderSizePixel = 0
    SettingsFrame.Position = UDim2.new(0, 15, 1, -50)
    SettingsFrame.Size = UDim2.new(0, getNavWidth(), 0, 40)
    SettingsFrame.ZIndex = 3

    local SettingsFrameCorner = Instance.new("UICorner")
    SettingsFrameCorner.CornerRadius = UDim.new(0, 12)
    SettingsFrameCorner.Parent = SettingsFrame

    local SettingsStroke = Instance.new("UIStroke")
    SettingsStroke.Parent = SettingsFrame
    SettingsStroke.Color = Theme.Border
    SettingsStroke.Thickness = 1
    SettingsStroke.Transparency = 0.7

    local SettingsGradient = Instance.new("UIGradient")
    SettingsGradient.Parent = SettingsFrame
    SettingsGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    SettingsGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.97),
        NumberSequenceKeypoint.new(1, 0.95)
    })

    local SettingsButton = Instance.new("TextButton")
    SettingsButton.Name = "SettingsButton"
    SettingsButton.Parent = SettingsFrame
    SettingsButton.BackgroundColor3 = Theme.Secondary
    SettingsButton.BackgroundTransparency = 0.3
    SettingsButton.BorderSizePixel = 0
    SettingsButton.Position = UDim2.new(0, 8, 0, 8)
    SettingsButton.Size = UDim2.new(1, -16, 1, -16)
    SettingsButton.Font = Enum.Font.GothamMedium
    SettingsButton.Text = "⚙ Settings"
    SettingsButton.TextColor3 = Theme.TextSecondary
    SettingsButton.TextSize = 13
    SettingsButton.TextXAlignment = Enum.TextXAlignment.Center
    SettingsButton.AutoButtonColor = false

    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 8)
    SettingsCorner.Parent = SettingsButton

    SettingsButton.MouseEnter:Connect(function()
        TweenService:Create(SettingsButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.1,
            TextColor3 = Theme.Text
        }):Play()
    end)

    SettingsButton.MouseLeave:Connect(function()
        TweenService:Create(SettingsButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Secondary,
            BackgroundTransparency = 0.3,
            TextColor3 = Theme.TextSecondary
        }):Play()
    end)

    local function updateNavResponsive()
        local iconOnly = isSmallScreen()
        local newNavWidth = getNavWidth()
        
        NavFrame.Size = UDim2.new(0, newNavWidth, 1, -120)
        SettingsFrame.Size = UDim2.new(0, newNavWidth, 0, 40)
        
        if GUI.NavFrame then
            for _, tab in pairs(GUI.Tabs) do
                local btn = tab.Button
                local contentFrame = btn and btn:FindFirstChild("ContentFrame")
                if contentFrame then
                    local tabText = contentFrame:FindFirstChild("TabText")
                    if tabText then
                        tabText.Visible = not iconOnly
                    end
                end
            end
        end

        if iconOnly then
            SettingsButton.Text = "⚙"
        else
            SettingsButton.Text = "⚙ Settings"
        end
    end

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateNavResponsive)
    task.defer(updateNavResponsive)
    GUI.AlwaysIconOnly = config.alwaysIconOnly

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundColor3 = settings.Blur.Enable and Color3.fromRGB(255, 255, 255) or Theme.Surface
    ContentContainer.BackgroundTransparency = settings.Blur.Enable and 0.85 or 0.02
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ZIndex = 3

    local function updateContentContainerSize()
        local navWidth = getNavWidth()
        ContentContainer.Position = UDim2.new(0, navWidth + 25, 0, 60)
        ContentContainer.Size = UDim2.new(1, -(navWidth + 35), 1, -70)
    end

    updateContentContainerSize()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateContentContainerSize)

    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 12)
    ContentCorner.Parent = ContentContainer

    local ContentStroke = Instance.new("UIStroke")
    ContentStroke.Parent = ContentContainer
    ContentStroke.Color = Theme.Border
    ContentStroke.Thickness = 1
    ContentStroke.Transparency = 0.7

    local ContentGradient = Instance.new("UIGradient")
    ContentGradient.Parent = ContentContainer
    ContentGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    ContentGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.98),
        NumberSequenceKeypoint.new(1, 0.96)
    })
    ContentGradient.Rotation = 45

    local contentDragging = false
    ContentContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
        input.UserInputType == Enum.UserInputType.Touch then
            contentDragging = true
            GUI.isDraggingEnabled = false
        end
    end)

    ContentContainer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            contentDragging = false
            GUI.isDraggingEnabled = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if contentDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            contentDragging = false
            GUI.isDraggingEnabled = true
        end
    end)

    makeDraggableConditional(MainFrame)

    local function updateScrollVisibility(scrollFrame)
        local contentList = scrollFrame:FindFirstChildOfClass("UIListLayout")
        if contentList then
            local totalContentHeight = contentList.AbsoluteContentSize.Y + 30
            local containerHeight = scrollFrame.AbsoluteSize.Y

            if totalContentHeight > containerHeight then
                scrollFrame.ScrollBarThickness = 4
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
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            showRestoreButton()
        end
    end

    function GUI:RestoreGUI()
        GUI.isMinimized = false
        ScreenGui.Enabled = true
        hideRestoreButton()
    end

    MinimizeButton.MouseButton1Click:Connect(function()
        GUI:CreateNotify({
            title = "Minimized",
            description = "The GUI has been minimized. Press " .. settings.ToggleUI .. " to restore it.",
        })
        GUI:MinimizeGUI()
    end)

    MaximizeButton.MouseButton1Click:Connect(function()
        isContentHidden = not isContentHidden

        if isContentHidden then
            NavFrame.Visible = false
            SettingsFrame.Visible = false
            ContentContainer.Visible = false
            MainFrame.Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 50)
            ShadowFrame.Size = UDim2.new(0, MainFrame.Size.X.Offset + 10, 0, 60)
        else
            NavFrame.Visible = true
            SettingsFrame.Visible = true
            ContentContainer.Visible = true
            MainFrame.Size = originalSize
            ShadowFrame.Size = UDim2.new(0, originalSize.X.Offset + 10, 0, originalSize.Y.Offset + 10)
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        if GUI.BlurEffect then
            GUI.BlurEffect:Destroy()
            GUI.BlurEffect = nil
        end
        ScreenGui:Destroy()
        hideRestoreButton()
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

        if GUI.Settings and GUI.Settings.Config and GUI.Settings.Config.Enabled then
            GUI:CreateParagraph({
                parent = GUI.SettingsContent, 
                text = "This settings will auto loaded when you execute script. so make sure you save it!. if you didnt save it, the settings will not be loaded even you save it."
            })

            GUI:CreateToggle({
                parent = GUI.SettingsContent, 
                text = "Auto Load Saves", 
                flag = "GLOBAL_AutoLoad",
                default = (function()
                    local folderName = "AshLabs"
                    local fileName = "_GLOBAL"
                    local HttpService = game:GetService("HttpService")
                    local configPath = folderName .. "/" .. fileName .. ".json"
                    if isfile and isfile(configPath) then
                        local json = readfile(configPath)
                        local configData = HttpService:JSONDecode(json)
                        return configData.Load == true
                    end
                    return false
                end)(),
                callback = function(value)
                    GUI:AutoSaveLoad(value)
                end
            })

            GUI:CreateButton({
                parent = GUI.SettingsContent, 
                text = "Save Settings to local", 
                callback = function()
                    GUI:Save()
                    GUI:CreateNotify({title = "Settings Saved", description = "All settings have been saved successfully!"})
                end
        })

            GUI:CreateButton({parent = GUI.SettingsContent, text = "Delete Settings", callback = function()
                GUI:Delete()
                GUI:CreateNotify({title = "Settings Reset", description = "All settings have been delete successfully!"})
            end})

            GUI:CreateDivider({parent = GUI.SettingsContent})
        end

        local key = GUI:CreateKeyBind({parent = GUI.SettingsContent, text = "Show GUI", default = GUI.Settings.ToggleUI, callback = function(key, _, isTrigger)
            if not isTrigger then
                GUI.Settings.ToggleUI = key
            end
        end})

        GUI:CreateButton({
            parent = GUI.SettingsContent,
            text = "Close GUI",
            callback = function()
                _G.ModernGUIInstance:Destroy()
            end
        })
    end

    for _, tab in pairs(GUI.Tabs) do
        tab.Content.Visible = false
        tab.Button.BackgroundColor3 = Theme.Secondary

        local textLabel = tab.Button:FindFirstChild("ContentFrame"):FindFirstChild("TabText")
        if textLabel then
            textLabel.TextColor3 = Theme.TextSecondary
        end

        local icon = tab.Button:FindFirstChild("ContentFrame"):FindFirstChild("TabIcon")
        if icon and icon:IsA("ImageLabel") then
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

function GUI:CreateTab(name, iconName)
    if not GUI.NavFrame or not GUI.ContentContainer then
        error("Main GUI must be created first!")
    end

    local tabIndex = 1
    for _, _ in pairs(GUI.Tabs) do
        tabIndex = tabIndex + 1
    end

    local useNumberIcon = false
    if not iconName or iconName == "" then
        iconName = tostring(tabIndex)
        useNumberIcon = true
    end

    local displayName = name
    if iconName and not useNumberIcon then
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
        if useNumberIcon then
            local NumberLabel = Instance.new("TextLabel")
            NumberLabel.Name = "TabIcon"
            NumberLabel.Parent = ContentFrame
            NumberLabel.BackgroundTransparency = 1
            NumberLabel.Position = UDim2.new(0, 0, 0.5, -8)
            NumberLabel.Size = UDim2.new(0, 16, 0, 16)
            NumberLabel.Font = Enum.Font.Gotham
            NumberLabel.Text = iconName
            NumberLabel.TextColor3 = Theme.TextSecondary
            NumberLabel.TextSize = 14
            NumberLabel.TextXAlignment = Enum.TextXAlignment.Center
            NumberLabel.TextYAlignment = Enum.TextYAlignment.Center
            NumberLabel.ClipsDescendants = true
        else
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
        end

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
                if icon:IsA("TextLabel") then
                    icon.TextColor3 = Theme.TextSecondary
                else
                    icon.ImageColor3 = Theme.TextSecondary
                end
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
            if activeIcon:IsA("TextLabel") then
                activeIcon.TextColor3 = Theme.Text
            else
                activeIcon.ImageColor3 = Theme.Text
            end
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
            if activeIcon:IsA("TextLabel") then
                TweenService:Create(activeIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                    TextColor3 = Theme.Text
                }):Play()
            else
                TweenService:Create(activeIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                    ImageColor3 = Theme.Text
                }):Play()
            end
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
            if firstIcon:IsA("TextLabel") then
                firstIcon.TextColor3 = Theme.Text
            else
                firstIcon.ImageColor3 = Theme.Text
            end
        end
    end

    return TabContent
end

function GUI:CreateSlider(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "Slider"
    local min = config.min or config.Min or 0
    local max = config.max or config.Max or 100
    local flag = config.flag or config.Flag or nil
    local default = config.default or config.Default or min
    local callback = config.callback or config.Callback

    if GUI.Settings.Config.Enabled and flag ~= nil and getAutoLoad() then
        local savedValue = GUI:GetFlagValue(flag)
        if savedValue ~= nil then
            default = tonumber(savedValue)
        end
    end

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider"
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Theme.Secondary
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Size = UDim2.new(1, 0, 0, 45)
    if flag ~= nil then
        SliderFrame:SetAttribute("Flag", flag)
    end

    SliderFrame:SetAttribute("Value", tonumber(default) or tonumber(min) or 0)

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
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.ClipsDescendants = true

    local function adjustTextSize()
        local maxWidth = Label.AbsoluteSize.X
        local textSize = 14
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 20))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 20))
        end
        Label.TextSize = textSize
    end

    Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustTextSize)
    Label:GetPropertyChangedSignal("Text"):Connect(adjustTextSize)
    task.defer(adjustTextSize)

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(1, -60, 0, 3)
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.Text = string.format("%.2f", tonumber(default or min))
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
    local value = tonumber(default) or tonumber(min) or 0

    local function setValue(newValue, fireCallback)
        newValue = math.clamp(newValue, min, max)
        value = newValue
        SliderFrame:SetAttribute("Value", value)
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

        local function updateSlider(position)
            local x = position.X
            local rel = math.clamp(x - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X)
            local percent = rel / Bar.AbsoluteSize.X
            local newValue = min + (max - min) * percent
            setValue(newValue, true)
        end

        if input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input.Position)
        else
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            updateSlider(Vector2.new(mouse.X, mouse.Y))
        end

        local moveConnection, releaseConnection
        if input.UserInputType == Enum.UserInputType.Touch then
            moveConnection = input.Changed:Connect(function(property)
                if property == "Position" and dragging then
                    updateSlider(input.Position)
                end
            end)

            releaseConnection = input.Changed:Connect(function(property)
                if property == "UserInputState" and input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if moveConnection then moveConnection:Disconnect() end
                    if releaseConnection then releaseConnection:Disconnect() end
                end
            end)
        else
            moveConnection = UserInputService.InputChanged:Connect(function(inputChanged)
                if dragging and inputChanged.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(inputChanged.Position)
                end
            end)

            releaseConnection = UserInputService.InputEnded:Connect(function(inputEnded)
                if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    if moveConnection then moveConnection:Disconnect() end
                    if releaseConnection then releaseConnection:Disconnect() end
                end
            end)
        end
    end

    local function handleInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
        input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end

    Bar.InputBegan:Connect(handleInput)
    Knob.InputBegan:Connect(handleInput)
    setValue(value, false)

    SliderFrame:GetAttributeChangedSignal("Value"):Connect(function()
        local attrValue = SliderFrame:GetAttribute("Value")
        if attrValue ~= nil then
            setValue(attrValue, true)
        end
    end)

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
    local flag = config.flag or config.Flag or nil
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
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.ClipsDescendants = true

    local function adjustTextSize()
        local maxWidth = Label.AbsoluteSize.X
        local textSize = 14
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        end
        Label.TextSize = textSize
    end

    Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustTextSize)
    Label:GetPropertyChangedSignal("Text"):Connect(adjustTextSize)
    task.defer(adjustTextSize)

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
    local flag = config.flag or config.Flag or nil
    local default = config.default or config.Default or false
    local callback = config.callback or config.Callback

    if GUI.Settings.Config.Enabled and flag ~= nil and getAutoLoad() then
        local savedValue = GUI:GetFlagValue(flag)
        if savedValue ~= nil then
            default = savedValue and true or false
        end
    end

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle"
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = Theme.Secondary
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame:SetAttribute("Flag", flag)
    ToggleFrame:SetAttribute("Value", default and true or false)

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
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.ClipsDescendants = true

    local function adjustTextSize()
        local maxWidth = Label.AbsoluteSize.X
        local textSize = 14
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        end
        Label.TextSize = textSize
    end

    Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustTextSize)
    Label:GetPropertyChangedSignal("Text"):Connect(adjustTextSize)
    task.defer(adjustTextSize)

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

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = Switch
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.Position = UDim2.new(0, 0, 0, 0)
    ToggleButton.Text = ""

    local toggled = default

    local function updateToggleVisual(state)
        TweenService:Create(Switch, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Accent or Theme.Border
        }):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(0, 26, 0, 2) or UDim2.new(0, 4, 0, 2)
        }):Play()
    end

    local ToggleObject = {}

    function ToggleObject:Set(value)
        toggled = value and true or false
        ToggleFrame:SetAttribute("Value", toggled)
        updateToggleVisual(toggled)
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

    ToggleFrame:GetAttributeChangedSignal("Value"):Connect(function()
        local attrValue = ToggleFrame:GetAttribute("Value")
        if attrValue ~= nil then
            toggled = attrValue and true or false
            updateToggleVisual(toggled)
            if callback then callback(toggled) end
        end
    end)

    return ToggleObject
end

function GUI:CreateDropdown(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or "Dropdown"
    local options = config.options or config.Options or {}
    local flag = config.flag or config.Flag or nil
    local callback = config.callback or config.Callback

    local default = options[1] or ""
    if GUI.Settings.Config.Enabled and flag ~= nil and getAutoLoad() then
        local savedValue = GUI:GetFlagValue(flag)
        if savedValue ~= nil then
            default = savedValue
        end
    end

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown"
    DropdownFrame.Parent = parent
    DropdownFrame.BackgroundColor3 = Theme.Secondary
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
    DropdownFrame:SetAttribute("Flag", flag)
    DropdownFrame:SetAttribute("Value", tostring(default))

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = DropdownFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = DropdownFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.ClipsDescendants = true

    local function adjustTextSize()
        local maxWidth = Label.AbsoluteSize.X
        local textSize = 14
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        end
        Label.TextSize = textSize
    end

    Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustTextSize)
    Label:GetPropertyChangedSignal("Text"):Connect(adjustTextSize)
    task.defer(adjustTextSize)

    local function truncateText(text, limit)
        if string.len(text) > limit then
            return string.sub(text, 1, limit) .. "..."
        else
            return text
        end
    end

    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundColor3 = Theme.Border
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Position = UDim2.new(1, -80, 0.5, -12)
    DropdownButton.Size = UDim2.new(0, 70, 0, 24)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = truncateText(default or "Select...", 10)
    DropdownButton.TextColor3 = Theme.Text
    DropdownButton.TextSize = 12
    DropdownButton.TextTruncate = Enum.TextTruncate.None
    DropdownButton.ClipsDescendants = true
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
    DropdownList.Size = UDim2.new(0, 220, 0, 180)
    DropdownList.Visible = false
    DropdownList.ZIndex = 100

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = DropdownList
    UIStroke.Color = Theme.Border
    UIStroke.Thickness = 1

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropdownList

    local SearchBox = Instance.new("TextBox")
    SearchBox.Parent = DropdownList
    SearchBox.BackgroundColor3 = Theme.Surface
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(0, 10, 0, 10)
    SearchBox.Size = UDim2.new(1, -20, 0, 28)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.PlaceholderText = "Search..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = Theme.Text
    SearchBox.TextSize = 13
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ZIndex = 101
    SearchBox.ClipsDescendants = true
    SearchBox.TextTruncate = Enum.TextTruncate.AtEnd

    local SearchPadding = Instance.new("UIPadding")
    SearchPadding.Parent = SearchBox
    SearchPadding.PaddingLeft = UDim.new(0, 8)

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Parent = DropdownList
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.Position = UDim2.new(0, 10, 0, 48)
    ScrollFrame.Size = UDim2.new(1, -20, 1, -58)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Theme.Accent
    ScrollFrame.ZIndex = 101
    ScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y

    local GridLayout = Instance.new("UIGridLayout")
    GridLayout.Parent = ScrollFrame
    GridLayout.CellSize = UDim2.new(0, 95, 0, 28)
    GridLayout.CellPadding = UDim2.new(0, 10, 0, 8)
    GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    GridLayout.FillDirectionMaxCells = 2
    GridLayout.FillDirection = Enum.FillDirection.Horizontal
    GridLayout.StartCorner = Enum.StartCorner.TopLeft

    local currentOptions = {}
    local currentValue = default

    for _, option in ipairs(options) do
        table.insert(currentOptions, option)
    end

    local function createOptionButton(option)
        local OptionButton = Instance.new("TextButton")
        OptionButton.Parent = ScrollFrame
        OptionButton.BackgroundColor3 = Theme.Secondary
        OptionButton.BorderSizePixel = 0
        OptionButton.Size = UDim2.new(0, 95, 0, 28)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.Text = truncateText(option, 18)
        OptionButton.TextColor3 = Theme.TextSecondary
        OptionButton.TextSize = 12
        OptionButton.TextTruncate = Enum.TextTruncate.AtEnd
        OptionButton.ClipsDescendants = true
        OptionButton.ZIndex = 102

        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 6)
        OptionCorner.Parent = OptionButton

        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Theme.Accent
            OptionButton.TextColor3 = Theme.Text
        end)

        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundColor3 = Theme.Secondary
            OptionButton.TextColor3 = Theme.TextSecondary
        end)

        OptionButton.MouseButton1Click:Connect(function()
            currentValue = option
            DropdownFrame:SetAttribute("Value", tostring(option))
            DropdownButton.Text = truncateText(option, 10)
            DropdownList.Visible = false
            if callback then
                callback(option)
            end
        end)

        return OptionButton
    end

    local function filterOptions(query)
        if query == "" then
            return currentOptions
        end
        local filtered = {}
        query = string.lower(query)
        for _, option in ipairs(currentOptions) do
            if string.find(string.lower(option), query, 1, true) then
                table.insert(filtered, option)
            end
        end

        table.sort(filtered, function(a, b)
            local aStart = string.lower(a):sub(1, #query) == query
            local bStart = string.lower(b):sub(1, #query) == query
            if aStart and not bStart then return true end
            if not aStart and bStart then return false end
            return a < b
        end)
        return filtered
    end

    local function refreshDropdownList(query)
        for _, child in ipairs(ScrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        local filtered = filterOptions(query or "")
        for _, option in ipairs(filtered) do
            createOptionButton(option)
        end
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.min(#filtered * 36, 200))
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        refreshDropdownList(SearchBox.Text)
    end)

    local function updateDropdownPosition()
        local buttonPos = DropdownButton.AbsolutePosition
        local buttonSize = DropdownButton.AbsoluteSize
        local camera = workspace.CurrentCamera
        local screenSize = camera.ViewportSize
        local maxHeight = math.min(180, screenSize.Y - buttonPos.Y - buttonSize.Y - 40)
        DropdownList.Size = UDim2.new(0, 220, 0, maxHeight)
        DropdownList.Position = UDim2.new(0, buttonPos.X, 0, buttonPos.Y + buttonSize.Y + 5)
        ScrollFrame.Size = UDim2.new(1, -20, 1, -58)
    end

    DropdownButton.MouseButton1Click:Connect(function()
        if not DropdownList.Visible then
            updateDropdownPosition()
            DropdownList.Visible = true
            SearchBox.Text = ""
            SearchBox:CaptureFocus()
            refreshDropdownList("")
        else
            DropdownList.Visible = false
        end
    end)

    DropdownFrame:GetAttributeChangedSignal("Value"):Connect(function()
        local attrValue = DropdownFrame:GetAttribute("Value")
        if attrValue ~= nil then
            DropdownButton.Text = truncateText(attrValue, 10)
            currentValue = attrValue
            if callback then
                callback(attrValue)
            end
        end
    end)

    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input)
        if DropdownList.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = UIS:GetMouseLocation()
            local absPos = DropdownList.AbsolutePosition
            local absSize = DropdownList.AbsoluteSize
            if not (mouse.X >= absPos.X and mouse.X <= absPos.X + absSize.X and mouse.Y >= absPos.Y and mouse.Y <= absPos.Y + absSize.Y) then
                DropdownList.Visible = false
            end
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
        refreshDropdownList(SearchBox.Text)
    end

    task.defer(function()
        if callback then callback(default) end
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
    local flag = config.flag or config.Flag or nil
    local default = config.default or config.Default or "None"
    local callback = config.callback or config.Callback

    if GUI.Settings.Config.Enabled and flag ~= nil and getAutoLoad() then
        local savedValue = GUI:GetFlagValue(flag)
        if savedValue ~= nil then
            default = tostring(savedValue)
        end
    end

    local KeyBindFrame = Instance.new("Frame")
    KeyBindFrame.Name = "KeyBind"
    KeyBindFrame.Parent = parent
    KeyBindFrame.BackgroundColor3 = Theme.Secondary
    KeyBindFrame.BorderSizePixel = 0
    KeyBindFrame.Size = UDim2.new(1, 0, 0, 35)
    KeyBindFrame:SetAttribute("Flag", flag)
    KeyBindFrame:SetAttribute("Value", tostring(default))

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = KeyBindFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = KeyBindFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -90, 1, 0) 
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.ClipsDescendants = true

    local function adjustTextSize()
        local maxWidth = Label.AbsoluteSize.X
        local textSize = 14
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        end
        Label.TextSize = textSize
    end

    Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustTextSize)
    Label:GetPropertyChangedSignal("Text"):Connect(adjustTextSize)
    task.defer(adjustTextSize)

    local KeyBindButton = Instance.new("TextButton")
    KeyBindButton.Parent = KeyBindFrame
    KeyBindButton.BackgroundColor3 = Theme.Border
    KeyBindButton.BorderSizePixel = 0
    KeyBindButton.Position = UDim2.new(1, -75, 0.5, -12) 
    KeyBindButton.Size = UDim2.new(0, 65, 0, 24) 
    KeyBindButton.Font = Enum.Font.Gotham
    KeyBindButton.Text = tostring(default)
    KeyBindButton.TextColor3 = Theme.Text
    KeyBindButton.TextSize = 12
    KeyBindButton.TextTruncate = Enum.TextTruncate.AtEnd
    KeyBindButton.ClipsDescendants = true

    local function adjustButtonTextSize()
        local maxWidth = KeyBindButton.AbsoluteSize.X - 8
        local textSize = 12
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(KeyBindButton.Text, textSize, KeyBindButton.Font, Vector2.new(math.huge, 24))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(KeyBindButton.Text, textSize, KeyBindButton.Font, Vector2.new(math.huge, 24))
        end
        KeyBindButton.TextSize = textSize
    end

    KeyBindButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustButtonTextSize)
    KeyBindButton:GetPropertyChangedSignal("Text"):Connect(adjustButtonTextSize)
    task.defer(adjustButtonTextSize)

    local KeyBindCorner = Instance.new("UICorner")
    KeyBindCorner.CornerRadius = UDim.new(0, 8)
    KeyBindCorner.Parent = KeyBindButton

    local currentKey = tostring(default)
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
                KeyBindFrame:SetAttribute("Value", keyName)
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

    KeyBindFrame:GetAttributeChangedSignal("Value"):Connect(function()
        local attrValue = KeyBindFrame:GetAttribute("Value")
        if attrValue ~= nil then
            currentKey = tostring(attrValue)
            KeyBindButton.Text = currentKey
            KeyBindButton.BackgroundColor3 = Theme.Border
        end
    end)

    local KeyBindObject = {}

    function KeyBindObject:Set(key)
        currentKey = tostring(key)
        KeyBindFrame:SetAttribute("Value", currentKey)
        KeyBindButton.Text = currentKey or "None"
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
    local flag = config.flag or config.Flag or nil
    local callback = config.callback or config.Callback

    local InputFrame = Instance.new("Frame")
    InputFrame.Name = "Input"
    InputFrame.Parent = parent
    InputFrame.BackgroundColor3 = Theme.Secondary
    InputFrame.BorderSizePixel = 0
    InputFrame.Size = UDim2.new(1, 0, 0, 35)
    InputFrame:SetAttribute("Flag", flag)
    InputFrame:SetAttribute("Value", "")

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = InputFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = InputFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.ClipsDescendants = true

    local function adjustTextSize()
        local maxWidth = Label.AbsoluteSize.X
        local textSize = 14
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        end
        Label.TextSize = textSize
    end

    Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustTextSize)
    Label:GetPropertyChangedSignal("Text"):Connect(adjustTextSize)
    task.defer(adjustTextSize)

    local TextBox = Instance.new("TextBox")
    TextBox.Parent = InputFrame
    TextBox.BackgroundColor3 = Theme.Border
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(1, -80, 0.5, -12)
    TextBox.Size = UDim2.new(0, 70, 0, 24)
    TextBox.Font = Enum.Font.Gotham
    TextBox.PlaceholderText = placeholder
    TextBox.Text = ""
    TextBox.TextColor3 = Theme.Text
    TextBox.TextSize = 12
    TextBox.TextXAlignment = Enum.TextXAlignment.Center
    TextBox.ClipsDescendants = true

    local function adjustBoxTextSize()
        local maxWidth = TextBox.AbsoluteSize.X - 8
        local textSize = 12
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(TextBox.Text, textSize, TextBox.Font, Vector2.new(math.huge, 24))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(TextBox.Text, textSize, TextBox.Font, Vector2.new(math.huge, 24))
        end
        TextBox.TextSize = textSize
    end

    TextBox:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustBoxTextSize)
    TextBox:GetPropertyChangedSignal("Text"):Connect(adjustBoxTextSize)
    task.defer(adjustBoxTextSize)

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
        InputFrame:SetAttribute("Value", tostring(value))
        if callback then
            callback(TextBox.Text)
        end
    end

    function InputObject:Get()
        return TextBox.Text
    end

    TextBox.FocusLost:Connect(function()
        InputFrame:SetAttribute("Value", TextBox.Text)
        if callback then
            callback(TextBox.Text)
        end
    end)

    InputFrame:GetAttributeChangedSignal("Value"):Connect(function()
        local attrValue = InputFrame:GetAttribute("Value")
        if attrValue ~= nil then
            TextBox.Text = tostring(attrValue)
            if callback then
                callback(TextBox.Text)
            end
        end
    end)

    return InputObject
end

function GUI:CreateParagraph(config)
    local parent = config.parent or config.Parent
    local text = config.text or config.Text or ""
    local flag = config.flag or config.Flag or nil

    local ParagraphFrame = Instance.new("Frame")
    ParagraphFrame.Name = "Paragraph"
    ParagraphFrame.Parent = parent
    ParagraphFrame.BackgroundColor3 = Theme.Secondary
    ParagraphFrame.BorderSizePixel = 0
    ParagraphFrame.Size = UDim2.new(1, 0, 0, 60)
    ParagraphFrame:SetAttribute("Flag", flag)

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
    TextLabel.TextColor3 = Theme.Text
    TextLabel.TextSize = 15
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top

    local currentText = text

    local function adjustTextSize()
        local maxHeight = 120 
        local minTextSize = 10
        local textSize = 15
        local textService = game:GetService("TextService")
        local bounds = function(size)
            return textService:GetTextSize(currentText, size, TextLabel.Font, Vector2.new(TextLabel.AbsoluteSize.X, math.huge))
        end

        while bounds(textSize).Y > maxHeight and textSize > minTextSize do
            textSize = textSize - 1
        end
        TextLabel.TextSize = textSize
        ParagraphFrame.Size = UDim2.new(1, 0, 0, math.min(bounds(textSize).Y + 20, maxHeight + 20))
    end

    TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustTextSize)
    TextLabel:GetPropertyChangedSignal("Text"):Connect(adjustTextSize)
    task.defer(adjustTextSize)

    local ParagraphObject = {}

    function ParagraphObject:Set(value)
        currentText = tostring(value)
        TextLabel.Text = currentText
        adjustTextSize()
    end

    function ParagraphObject:Get()
        return currentText
    end

    return ParagraphObject
end

function GUI:CreateSection(config)
    local parent = config.parent or config.Parent
    local flag = config.flag or config.Flag or nil
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
    local flag = config.flag or config.Flag or nil
    local default = config.default or config.Default or Color3.fromRGB(255, 0, 0)
    local callback = config.callback or config.Callback

    if GUI.Settings.Config.Enabled and flag ~= nil and getAutoLoad() then
        local savedValue = GUI:GetFlagValue(flag)
        if savedValue ~= nil then
            local r, g, b = string.match(savedValue, "(%d+),(%d+),(%d+)")
            if r and g and b then
                default = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            end
        end
    end

    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Name = "ColorPicker"
    ColorPickerFrame.Parent = parent
    ColorPickerFrame.BackgroundColor3 = Theme.Secondary
    ColorPickerFrame.BorderSizePixel = 0
    ColorPickerFrame.Size = UDim2.new(1, 0, 0, 35)
    ColorPickerFrame:SetAttribute("Flag", flag)
    ColorPickerFrame:SetAttribute("Value", string.format("%d,%d,%d", default.R*255, default.G*255, default.B*255))

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = ColorPickerFrame

    local Label = Instance.new("TextLabel")
    Label.Parent = ColorPickerFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(1, -120, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd
    Label.ClipsDescendants = true

    local function adjustTextSize()
        local maxWidth = Label.AbsoluteSize.X
        local textSize = 14
        local minTextSize = 10
        local textService = game:GetService("TextService")
        local bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        while bounds.X > maxWidth and textSize > minTextSize do
            textSize = textSize - 1
            bounds = textService:GetTextSize(Label.Text, textSize, Label.Font, Vector2.new(math.huge, 35))
        end
        Label.TextSize = textSize
    end

    Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(adjustTextSize)
    Label:GetPropertyChangedSignal("Text"):Connect(adjustTextSize)
    task.defer(adjustTextSize)

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

    local function setColorValue(color)
        currentColor = color
        ColorButton.BackgroundColor3 = color
        local valueStr = string.format("%d,%d,%d", color.R*255, color.G*255, color.B*255)
        ColorPickerFrame:SetAttribute("Value", valueStr)
        if callback then callback(color) end
    end

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

        local function handleCanvasInput(pos)
            local rel = Vector2.new(
                pos.X - ColorCanvas.AbsolutePosition.X,
                pos.Y - ColorCanvas.AbsolutePosition.Y
            )
            saturation = math.clamp(rel.X / ColorCanvas.AbsoluteSize.X, 0, 1)
            value = math.clamp(1 - (rel.Y / ColorCanvas.AbsoluteSize.Y), 0, 1)
            updateColor()
        end

        ColorCanvas.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                handleCanvasInput(input.Position)
                local moveConn, upConn
                moveConn = UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement then
                        handleCanvasInput(i.Position)
                    end
                end)
                upConn = UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        if moveConn then moveConn:Disconnect() end
                        if upConn then upConn:Disconnect() end
                    end
                end)
            elseif input.UserInputType == Enum.UserInputType.Touch then
                handleCanvasInput(input.Position)
                local moveConn, upConn
                moveConn = input.TouchMoved:Connect(function(touch)
                    handleCanvasInput(touch.Position)
                end)
                upConn = input.TouchEnded:Connect(function()
                    if moveConn then moveConn:Disconnect() end
                    if upConn then upConn:Disconnect() end
                end)
            end
        end)

        local function handleHueInput(pos)
            local relY = pos.Y - HueBar.AbsolutePosition.Y
            hue = math.clamp(relY / HueBar.AbsoluteSize.Y, 0, 1)
            updateCanvasGradient()
            updateColor()
        end

        HueBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                handleHueInput(input.Position)
                local moveConn, upConn
                moveConn = UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement then
                        handleHueInput(i.Position)
                    end
                end)
                upConn = UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        if moveConn then moveConn:Disconnect() end
                        if upConn then upConn:Disconnect() end
                    end
                end)
            elseif input.UserInputType == Enum.UserInputType.Touch then
                handleHueInput(input.Position)
                local moveConn, upConn
                moveConn = input.TouchMoved:Connect(function(touch)
                    handleHueInput(touch.Position)
                end)
                upConn = input.TouchEnded:Connect(function()
                    if moveConn then moveConn:Disconnect() end
                    if upConn then upConn:Disconnect() end
                end)
            end
        end)

        local function closeColorPicker()
            isColorPickerOpen = false
            GUI.isDraggingEnabled = true
            ColorPickerGui:Destroy()
        end

        OKButton.MouseButton1Click:Connect(function()
            setColorValue(currentColor)
            closeColorPicker()
        end)

        CancelButton.MouseButton1Click:Connect(function()
            closeColorPicker()
        end)

        CloseBtn.MouseButton1Click:Connect(function()
            closeColorPicker()
        end)
    end)

    ColorPickerFrame:GetAttributeChangedSignal("Value"):Connect(function()
        local attrValue = ColorPickerFrame:GetAttribute("Value")
        if attrValue ~= nil then
            local r, g, b = string.match(attrValue, "(%d+),(%d+),(%d+)")
            if r and g and b then
                local color = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
                ColorButton.BackgroundColor3 = color
                currentColor = color
                if callback then callback(color) end
            end
        end
    end)

    local ColorPickerObject = {}

    function ColorPickerObject:Set(value)
        if typeof(value) == "Color3" then
            setColorValue(value)
        elseif type(value) == "string" then
            local r, g, b = string.match(value, "(%d+),(%d+),(%d+)")
            if r and g and b then
                setColorValue(Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)))
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

    table.insert(_G.NotificationStack, 1, {
        Frame = nil, 
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

    local yOffset = 20 

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

function GUI:Save()
    if not GUI.Settings.Config.Enabled then
        return
    end

    local HttpService = game:GetService("HttpService")
    local folderName = GUI.Settings.Config.FolderName or "Ashlabs"
    local fileName = GUI.Settings.Config.FileName or GUI.Settings.Name or "Ashlabs"
    local settingsData = {}

    local function collectAttributes(obj)
        for _, child in ipairs(obj:GetChildren()) do
            local flag = child:GetAttribute("Flag")
            local value = child:GetAttribute("Value")
            if flag ~= nil and value ~= nil then
                settingsData[flag] = value
            end
            collectAttributes(child)
        end
    end

    local coreGui = game:GetService("CoreGui")
    local guiRoot = coreGui:FindFirstChild(GUI.Settings.Name)
    if guiRoot then
        local mainFrame = guiRoot:FindFirstChild("MainFrame")
        if mainFrame then
            collectAttributes(mainFrame)
        end
    end

    local json = HttpService:JSONEncode(settingsData)

    if not isfile then
        return
    end

    if not isfolder(folderName) then
        makefolder(folderName)
    end

    writefile(folderName .. "/" .. fileName .. ".json", json)
end

function GUI:Delete()
    if not GUI.Settings.Config.Enabled then
        return
    end

    local folderName = GUI.Settings.Config.FolderName or "Ashlabs"
    local fileName = GUI.Settings.Config.FileName or GUI.Settings.Name or "Ashlabs"

    if isfile(folderName .. "/" .. fileName .. ".json") then
        delfile(folderName .. "/" .. fileName .. ".json")
    end
end

function GUI:Load()
    if not GUI.Settings.Config.Enabled then
        return
    end

    local HttpService = game:GetService("HttpService")
    local folderName = GUI.Settings.Config.FolderName or "Ashlabs"
    local fileName = GUI.Settings.Config.FileName or GUI.Settings.Name or "Ashlabs"

    if not isfile(folderName .. "/" .. fileName .. ".json") then
        return
    end

    local json = readfile(folderName .. "/" .. fileName .. ".json")
    local settingsData = HttpService:JSONDecode(json)

    local function scanAndApply(obj)
        for _, child in ipairs(obj:GetChildren()) do
            local flag = child:GetAttribute("Flag")
            if flag and settingsData[flag] ~= nil then
                child:SetAttribute("Value", settingsData[flag])
            end
            scanAndApply(child)
        end
    end

    local guiRoot = game:GetService("CoreGui"):FindFirstChild(GUI.Settings.Name)
    if guiRoot then
        local mainFrame = guiRoot:FindFirstChild("MainFrame")
        if mainFrame then
            scanAndApply(mainFrame)
        end
    end
end


function GUI:AutoSaveLoad(value)
    local folderName = "AshLabs"
    local fileName = "_GLOBAL"
    local HttpService = game:GetService("HttpService")
    local configPath = folderName .. "/" .. fileName .. ".json"

    if not isfolder(folderName) then
        makefolder(folderName)
    end

    if value == nil then
        local configData
        if isfile(configPath) then
            local json = readfile(configPath)
            configData = HttpService:JSONDecode(json)
        else
            configData = { Load = false }
            writefile(configPath, HttpService:JSONEncode(configData))
        end

        if configData.Load == true then
            if GUI.ContentContainer then
                local mainFrame = game:GetService("CoreGui"):FindFirstChild(GUI.Settings.Name)
                if mainFrame then
                    local main = mainFrame:FindFirstChild("MainFrame")
                    if main then
                        for _, child in ipairs(main:GetDescendants()) do
                            if child:GetAttribute("Flag") == "GLOBAL_AutoLoad" then
                                child:SetAttribute("Value", true)
                            end
                        end
                    end
                end
            end
        else
            if GUI.ContentContainer then
                local mainFrame = game:GetService("CoreGui"):FindFirstChild(GUI.Settings.Name)
                if mainFrame then
                    local main = mainFrame:FindFirstChild("MainFrame")
                    if main then
                        for _, child in ipairs(main:GetDescendants()) do
                            if child:GetAttribute("Flag") == "GLOBAL_AutoLoad" then
                                child:SetAttribute("Value", false)
                            end
                        end
                    end
                end
            end
        end
    else
        local configData = { Load = value and true or false }
        writefile(configPath, HttpService:JSONEncode(configData))
    end
end

function GUI:GetFlagValue(flag)
    local folderName = GUI.Settings.Config.FolderName or "Ashlabs"
    local fileName = GUI.Settings.Config.FileName or GUI.Settings.Name or "Ashlabs"
    local configPath = folderName .. "/" .. fileName .. ".json"

    if not isfile or not isfile(configPath) then
        return nil
    end

    local HttpService = game:GetService("HttpService")
    local json = readfile(configPath)
    local settingsData = HttpService:JSONDecode(json)
    return settingsData[flag]
end

function getAutoLoad()
    local folderName = "AshLabs"
    local fileName = "_GLOBAL"
    local HttpService = game:GetService("HttpService")
    local configPath = folderName .. "/" .. fileName .. ".json"

    if not isfile or not isfile(configPath) then
        return false
    end

    local json = readfile(configPath)
    local configData = HttpService:JSONDecode(json)
    return configData.Load == true
end