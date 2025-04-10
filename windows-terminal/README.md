# That Old CRT for Windows Terminal
This is the Windows Terminal version of the shader.

# Installation
- Download that-old-crt.hlsl and place it somewhere accessible.
- Press <kbd>CTRL</kbd> + <kbd>,</kbd> to open Settings.
- At bottom left of Settings page, click the config icon to open settings.json.
- Edit settings.json, adding the shader path under Profiles -> defaults.
```"experimental.pixelShaderPath": "C:\\your-path\\That Old CRT.hlsl"```
- Optionally, add a shader image for the background.
```"experimental.pixelShaderImagePath": "C:\\your-path\\img\\abandoned-4894406_1920.jpg"```
- Save your changes and the terminal should automatically update.