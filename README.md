<p align="center">
    <img src="./assets/image.png" alt="Ash-Libs Logo" />
</p>

<h3 align="center">
    Ash-Libs is a GUI library for Roblox featuring a minimalist, modern, and lightweight design<br> It helps developers create intuitive and responsive user interfaces without impacting game performance.
</h3>

## Component
- [Load Main Window](#load-main-window)
- [Creating tab](#creating-tab)
- [Button](#button)
- [Toggle](#toggle)
- [Slider](#slider)
- [Dropdown](#dropdown)
- [Keybind](#keybind)
- [Paragraf](#paragraf)
- [Section](#section)
- [Color picker](#color-picker)
- [Notify](#notify)

## Load Main Window
```lua
local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/BloodLetters/Ash-Libs/refs/heads/main/source.lua"))()

GUI:CreateMain({
        Name = "Ashlabs UI",
        title = "Ashlabs UI",
        ToggleUI = "K",
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
GUI:CreateTab("Tab name", icon_id) -- with icon
GUI:CreateTab("Tab name") -- without icon
```

## Button
```lua
-- function
GUI:CreateButton(tab, "Button name", callback)

-- sample
GUI:CreateButton(tab, "Test Button", function()
        print("this is button!")
end)
```

## Toggle
```lua
-- function
GUI:CreateToggle(tab, "Toggle name", callback)

-- sample
local toggle = GUI:CreateToggle(tab, "Test Toggle", false, function(state)
        print("Toggle state:", state)
end)

toggle:Set(true) -- Set toggle to true
toggle:Get() -- Get toggle state
```

## Slider
```lua
-- function
GUI:CreateSlider(parent, text, min, max, default, callback)

-- sample
local slider = GUI:CreateSlider(tab, "Slider", 0, 100, 50, function(value)
    print("Slider value changed:", value)
end)

slider:Set(75) -- Set the slider to a specific value
slider:Get() -- Get the current value of the slider
```

## Dropdown
```lua
-- function
GUI:CreateDropdown(parent, text, options, callback)

-- sample
local dropdown = GUI:CreateDropdown(tab, "Test Dropdown", {"Option 1", "Option 2", "Option 3"}, function(value)
        print("Selected value:", value)
end)

dropdown:Add("Option 4") -- Add new option to dropdown
dropdown:List() -- List current options. return table
dropdown:Get() -- Get current selected value
```

## Keybind
```lua
-- function
GUI:CreateKeyBind(parent, text, default, callback)

-- sample
local input = GUI:CreateInput(tab, "Input Example", "Type here...", function(value)
        print("Input value changed to: " .. value)
end)

input:Set("New Value") -- Set a new value for the input
input:Get() -- Get the current value of the input
```

## Paragraf
```lua
--function
GUI:CreateParagraph(tab, text)

-- sample
local paragraf = GUI:CreateParagraph(tab, "Test")

paragraf:Set("New text for the paragraph") -- Set new text for the paragraph
paragraf:Get() -- Get the current text of the paragraph
```

## Section
```lua
-- function
GUI:CreateSection(tab, text)

-- sample
local section = GUI:CreateSection(tab, "Example Section")
section:Set("Example Section") -- Set the section title
section:Get() -- Get the section title
```

## Color picker
```lua
-- function
GUI:CreateColorPicker(parent, text, default, callback)

-- sample
local colorpicker = GUI:CreateColorPicker(tab, "Color Picker", Color3.fromRGB(255, 0, 0), function(color)
        print("Selected color:", color)
end)

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