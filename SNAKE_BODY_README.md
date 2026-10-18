# TeaHack: Snake Body Replacement

A server-side Roblox Lua script that hides the standard avatar's visible body and displays a simple segmented snake body instead. It keeps the existing Humanoid and movement controls, so this is a character visual replacement, not a game.

## Install
1. Open your own Roblox experience in Roblox Studio.
2. Add a **Script** under **ServerScriptService**.
3. Copy the contents of `SnakeBody.server.lua` into it.
4. Press **Play** to test.

The script is server-side and its snake visuals replicate to other players (FE-compatible). It is designed for Roblox Studio experiences you own or have permission to edit, not for executors in other people's games.

## Customize
- Change `SEGMENT_COUNT` to make the body longer or shorter.
- Change `BODY_COLOR` and `BELLY_COLOR` to customize colors.
- Change `SAMPLE_SPACING` to adjust spacing between body segments.

This is a basic Part-based snake appearance; it does not replace the Humanoid's movement system or add snake-specific crawling physics.
