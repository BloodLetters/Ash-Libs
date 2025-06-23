local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/BloodLetters/Ash-Libs/refs/heads/main/source.lua"))()

-- return GUI
GUI:CreateMain({
    Name = "Ashlabs",
    title = "Ashlabs GUI",
    ToggleUI = "K",
    -- WindowIcon = "home" -- you can use lucid icons
    -- WindowHeight = 600, -- default height
    -- WindowWidth = 800, -- default width
    Transparent = {
        Enable = true, -- transparent option
        value = 0.2
    },
    Config = { -- not implemented yet
        Enabled = false,
    }
})

local main = GUI:CreateTab("Main", "home")

GUI:CreateSection({
    parent = main, 
    text = "Section"
})

GUI:CreateButton({
    parent = main, 
    text = "Click Me", 
    callback = function()
        GUI:CreateNotify("Button Clicked", "You clicked the button!")
    end
})

GUI:CreateButton({
    parent = main, 
    text = "Notify", 
    callback = function()
        GUI:CreateNotify("Welcome", "Welcome to the Ashlabs GUI! This is a notification example.")
    end
})

GUI:CreateToggle({
    parent = main, 
    text = "Toggle Me", 
    default = false, 
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
    function(value)
        print("Slider value changed:", value)
    end
})

GUI:CreateDropdown({
    parent = main, 
    text = "Select Option", 
    options = {"Option 1", "Option 2", "Option 3"}, 
    callback = function(selected)
        print("Selected option:", selected)
    end
})

GUI:CreateKeyBind({
    parent = main, 
    text = "Press a Key", 
    default = "K", 
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
    callback = function(color)
        print("Selected color:", color)
    end
})
