GUI:CreateMain({
    Name = "Ashlabs",
    title = "Ashlabs GUI",
    ToggleUI = "K",
    WindowIcon = "home", -- you can use lucid icons
    -- WindowHeight = 600, -- default height
    -- WindowWidth = 800, -- default width
    alwaysIconOnly = false, -- always show icons only in navigation
    Theme = {
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
    },
    Blur = { -- Buggy
        Enable = false, -- transparent option
        value = 0.2
    },
    Config = {
        Enabled = false,
        FileName = "AshLabs", -- name of the config file
        FolerName = "AshDir", -- folder to save configs
    }
})

local main = GUI:CreateTab("Main", "home") -- You can use IconID we didnt impleemnt lucid or any external icons
GUI:CreateSection({
    parent = main, 
    text = "Section"
})

GUI:CreateButton({
    parent = main, 
    text = "Click Me", 
    flag = "ClickMeBtn",
    callback = function()
        GUI:CreateNotify({title = "Button Clicked", description = "You clicked the button!"})
    end
})

GUI:CreateButton({
    parent = main, 
    text = "Notify", 
    flag = "NotifyBtn",
    callback = function()
        GUI:CreateNotify({title = "Welcome", description = "Welcome to the Ashlabs GUI! This is a notification exampled. You can use this to inform users about important events or actions. You can customize the title and description to fit your needs. description can be multiple lines long and will adjust its size based on the content."})
    end
})

GUI:CreateToggle({
    parent = main, 
    text = "Toggle Me", 
    default = false, 
    flag = "ToggleMe",
    callback = function(state)
        print("Toggle state:", state)
    end
})

GUI:CreateSlider({
    parent = main, 
    text = "Slider", 
    min = 0, 
    max = 100, 
    default = 50, 
    flag = "SliderValue",
    function(value)
        print("Slider value changed:", value)
    end
})

GUI:CreateDropdown({
    parent = main, 
    text = "Select Option", 
    options = {"Option 1", "Option 2", "Option 3"}, 
    default = "Option 1", 
    flag = "DropdownOption",
    callback = function(selected)
        print("Selected option:", selected)
    end
})

GUI:CreateKeyBind({
    parent = main, 
    text = "Press a Key", 
    default = "K", 
    flag = "KeyBind",
    callback = function(key, input, isPressed)
        if isPressed then
            print("Key pressed:", key)
        else
            print("Key released:", key)
        end
    end
})

GUI:CreateInput({
    parent = main, 
    text = "Enter Text", 
    placeholder = "Placeholder", 
    flaag = "InputText",
    callback = function(text)
        print("Input text:", text)
    end
})

GUI:CreateParagraph({
    parent = main, 
    text = "This is a paragraph explaining something important. It can be multiple lines long and will adjust its size based on the content."
})

GUI:CreateColorPicker({
    parent = main, 
    text = "Pick a Color", 
    default = Color3.fromRGB(255, 0, 0), 
    flag = "ColorPicker",
    callback = function(color)
        print("Selected color:", color)
    end
})

local settings = GUI:CreateTab("Settings", "settings")
GUI:CreateSection({
    parent = settings, 
    text = "Settings Section"
})

GUI:CreateButton({
    parent = settings, 
    text = "Reset Settings", 
    flag = "ResetSettingsBtn",
    callback = function()
        GUI:CreateNotify({ title = "Settings Reset", text = "All settings have been reset to default."})
    end
})

GUI:CreateDivider({
    parent = settings
})

GUI:CreateButton({
    parent = settings, 
    text = "Reset 2", 
    flag = "ResetSettingsBtn2",
    callback = function()
        GUI:CreateNotify({ title = "Settings Reset", text = "All settings have been reset to default."})
    end
})

local move = GUI:CreateTab("Settings")