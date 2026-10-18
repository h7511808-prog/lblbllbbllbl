# TeaHack: Brick Orbital

## Install in Roblox Studio
1. Open a Roblox experience you own or are authorized to edit.
2. Add `BrickOrbital.server.lua` as a **Script** in `ServerScriptService`.
3. Add `BrickOrbital.client.lua` as a **LocalScript** in `StarterPlayer > StarterPlayerScripts`.
4. Press **Play**. The server script creates the RemoteEvent automatically.

## Mobile controls
- Add Brick / Remove: adjust orbiting brick count (up to 24).
- Height + / Height −: change orbit height.
- Reverse: reverse the orbit direction.
- Launch: spawn temporary physical bricks that fly outward.
- Clear / Rebuild: remove or restore orbiting bricks.

Orbiting bricks are local visual parts; launched bricks are server-created physical parts.
This is intended for Roblox Studio experiences you own or are authorized to edit, not an executor script for other people's games.
