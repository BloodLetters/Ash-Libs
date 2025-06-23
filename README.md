<p align="center">
    <img src="./assets/image.png" alt="Ash-Libs Logo" />
</p>

<h3 align="center">
    Ash-Libs is a GUI library for Roblox featuring a minimalist, modern, and lightweight design<br> It helps developers create intuitive and responsive user interfaces without impacting game performance.
</h3>

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

## Credit
- [Lucide-Roblox](https://github.com/latte-soft/lucide-roblox)
- [Lucide-Icon](https://lucide.dev)

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
    Transparent = {
        Enable = false, -- transparent option
        value = 0.5
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

## Notify
```lua
-- function
GUI:CreateNotify(title, description)

-- sample
GUI:CreateNotify("title", "Content")
```