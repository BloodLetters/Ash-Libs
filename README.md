> [!WARNING]
> This library still on BETA and maybe contains some bug and issue. feel free to open issue or fork this repository

<p align="center">
    <img src="./assets/preview/pc.png" alt="Ash-Libs Logo" width="350"/>
    <img src="./assets/preview/mobile.png" alt="Ash-Libs Logo" width="300"/>
</p>

<h3 align="center">
    Ash-Libs is a simple design, responsive, and easy-to-use GUI library for Roblox
</h3>

## Content
- [Release Example](./example.lua)
- [Dev Example](./build/test.lua)
- [Docs](./docs/README.md)
- [Preview PC & Mobile](./assets/preview/README.md)

## Building Development `source.lua`
You can create `source.lua` in two ways: **manually** or **automatically**.

### Manual Build
1. Navigate to the `build` directory.
2. Download `icons.lua` and `source-dev.lua`.
3. Add the following line at the end of `source-dev.lua`:
    ```lua
    return GUI
    ```
4. Combine the contents of `icons.lua` and the updated `source-dev.lua` into a single file.

### Automatic Build
1. Clone this repository.
2. Open `build.py` and set `Release = True`.
3. Run the build script:
    ```bash
    py build.py
    ```
4. Find the generated `source.lua` in the `out/` directory.

## Credit
- [Lucide-Roblox](https://github.com/latte-soft/lucide-roblox)
- [Lucide-Icon](https://lucide.dev)
