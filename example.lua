local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/BloodLetters/Ash-Libs/refs/heads/main/source.lua"))()

-- return GUI
GUI:CreateMain({
    Name = "Ashlabs",
    title = "Ashlabs GUI",
    ToggleUI = "K",
    Config = { -- not implemented yet
        Enabled = false,
    }
})

local main = GUI:CreateTab("Main") -- You can use IconID we didnt impleemnt lucid or any external icons

GUI:CreateSection(main, "Section")
GUI:CreateButton(main, "Click Me", function()
    GUI:CreateNotify("Button Clicked", "You clicked the button!")
end)

GUI:CreateButton(main, "Notify", function()
    GUI:CreateNotify("Welcome", "Welcome to the Ashlabs GUI! This is a notification example.")
end)

GUI:CreateToggle(main, "Toggle Me", false, function(state)
    print("Toggle state:", state)
end)

GUI:CreateDropdown(main, "Select Option", {"Option 1", "Option 2", "Option 3"}, function(selected)
    print("Selected option:", selected)
end)

GUI:CreateKeyBind(main, "Press a Key", "None", function(key, input, isPressed)
    if isPressed then
        print("Key pressed:", key)
    else
        print("Key released:", key)
    end
end)

GUI:CreateInput(main, "Enter Text", "Placeholder", function(text)
    print("Input text:", text)
end)

GUI:CreateParagraph(main, "This is a paragraph explaining something important. It can be multiple lines long and will adjust its size based on the content.")
GUI:CreateColorPicker(main, "Pick a Color", Color3.fromRGB(255, 0, 0), function(color)
    print("Selected color:", color)
end)
