# Auto Save Feature Documentation

This module enables automatic load by previous saved config and by pressing the **"Auto load save"** button. 

To use this feature, follow these steps:

## How to Use

1. **Add the `flag` Property**  
    For each element you want to load automatically, add a `flag` property in the configuration.

2. **Saving Data**  
    After configuring the elements, press the **"Auto load save"** button to save the current state.

## Example Configuration

```lua
function GUI:CreateToggle({
    parent = test,
    flag = "Sigma" -- Important
    ...
})
```

## Notes

- The `flag` property is required for each element to be included in the auto load process.
- Make sure config saved before closing the application.
