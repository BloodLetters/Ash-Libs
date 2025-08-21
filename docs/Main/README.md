## Window
- [Load Main Window](#load-main-window)
- [Creating tab](#creating-tab)

## Element
- [Button](#button)
- [Toggle](#toggle)
- [Slider](#slider)
- [Dropdown](#dropdown)
- [Keybind](#keybind)
- [Paragraf](#paragraf)
- [Section](#section)
- [Color picker](#color-picker)
- [Notify](#notify)

## Module
- [Save](#save)

## Load Main Window
```lua
local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/BloodLetters/Ash-Libs/refs/heads/main/source.lua"))()

GUI:CreateMain({
    Name = "Ashlabs UI",
    title = "Ashlabs UI",
    ToggleUI = "K",
    WindowIcon = "home", -- lucide icon
    WindowHeight = 600, -- if you didnt want to use auto responsive system you can custom it by your own
    WindowWidth = 400, -- remove WindowHeight and WindowWidth to using auto responsive system
    Theme = {
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(138, 43, 226),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 50, 60),
        NavBackground = Color3.fromRGB(20, 20, 30)
    },
    Config = {
        Enabled = false, -- not implemented yet
    }
})
```

## Creating tab
```lua
-- function
GUI:CreateTab(title, iconid)

-- sample
local tab = GUI:CreateTab("Tab name", "home") -- with icon you can using lucide icon
local tab = GUI:CreateTab("Tab name") -- without icon
```

## Button
```lua
-- function
GUI:CreateButton({
    parent = tab, 
    text = "Button name", 
    callback = function(value)
})

-- sample
GUI:CreateButton({
    parent = tab, 
    text = "Test Button", 
    callback = function()
        print("this is button!")
    end
})
```

## Toggle
```lua
-- function
GUI:CreateToggle({
    parent = tab, 
    text = "Toggle name", 
    default = false, 
    callback = function(value)
})

-- sample
local toggle = GUI:CreateToggle({
    parent = tab, 
    text = "Test Toggle", 
    default = false, 
    callback = function(state)
        print("Toggle state:", state)
    end
})

toggle:Set(true) -- Set toggle to true
toggle:Get() -- Get toggle state
```

## Slider
```lua
-- function
GUI:CreateSlider({
    parent = tab, 
    text = "slider", 
    min = 1, 
    max = 10, 
    default = 5, 
    callback = function(value)
})

-- sample
local slider = GUI:CreateSlider({
    parent = tab, 
    text = "Slider", 
    min = 0, 
    max = 100, 
    default = 50, 
    callback = function(value)
        print("Slider value changed:", value)
    end
})

slider:Set(75) -- Set the slider to a specific value
slider:Get() -- Get the current value of the slider
```

## Dropdown
```lua
-- function
GUI:CreateDropdown({
    parent = tab, 
    text = "dropdown", 
    options = {"option 1", "option 2"}, 
    callback = function(value)
})

-- sample
local dropdown = GUI:CreateDropdown({
    parent = tab, 
    text = "Test Dropdown", 
    options = {"Option 1", "Option 2", "Option 3"}, 
    callback = function(value)
        print("Selected value:", value)
    end
})

dropdown:Add("Option 4") -- Add new option to dropdown
dropdown:Remove("Option 4") -- remove obj
dropdown:Delete("Option 4") -- remove obj
dropdown:Clear() -- Clear dropdown list
dropdown:List() -- List current options. return table
dropdown:Get() -- Get current selected value
```

## Keybind
```lua
-- function
GUI:CreateKeyBind({
    parent = tab, 
    text = "keybind", 
    default = "k", 
    callback = function(value)
})

-- sample
local input = GUI:CreateInput({
    parent = tab, 
    text = "Input Example", 
    placeholder "Type here...", 
    callback = function(value)
        print("Input value changed to: " .. value)
    end
})

input:Set("New Value") -- Set a new value for the input
input:Get() -- Get the current value of the input
```

## Paragraf
```lua
-- function
GUI:CreateParagraph({
    parent = tab, 
    text = text
})

-- sample
local paragraf = GUI:CreateParagraph({
    parent = tab, 
    title = "this is title",
    parent = "Test"
})

paragraf:Set("New text for the paragraph") -- Set new text for the paragraph
paragraf:Get() -- Get the current text of the paragraph
```

## Section
```lua
-- function
GUI:CreateSection({
    parent = tab, 
    title = text
})

-- sample
local section = GUI:CreateSection({
    parent = tab, 
    title = "Example Section"
})

section:Set("Example Section") -- Set the section title
section:Get() -- Get the section title
```

## Color picker
```lua
-- function
GUI:CreateColorPicker({
    parent = tab, 
    text = "colorpicker", 
    default = Color3.fromRGB(0, 255, 0), 
    callback = function(value)
})

-- sample
local colorpicker = GUI:CreateColorPicker({
    parent = tab, 
    text = "Color Picker", 
    default = Color3.fromRGB(255, 0, 0), 
    callback = function(color)
        print("Selected color:", color)
    end
})

colorpicker:Set(Color3.fromRGB(0, 255, 0)) -- Example of setting a color
colorpicker:Get() -- Example of getting the current color
```

## Divider
```lua
GUI:CreateDivider({
    parent = tab,
    -- height = 1, -- optional
})

-- sample
GUI:CreateDivider({
    parent = tab,
    height = 1, -- optional
})
```

## Notify
```lua
-- function
GUI:CreateNotify({
    title, text
})

-- sample
GUI:CreateNotify({
    title = "title",  
    text = "Content"
})
```

# Module
From here, these are optional features you can use. They are not required, but will be beneficial if you choose to use them.

## Save
```lua
GUI:Load() -- Load config from previous save
GUI:Save() -- Save config into file
```