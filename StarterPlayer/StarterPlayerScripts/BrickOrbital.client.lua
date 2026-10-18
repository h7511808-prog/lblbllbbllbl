-- TeaHack: BRICK ORBITAL
-- Place in StarterPlayer > StarterPlayerScripts as a LocalScript.
-- For a Roblox Studio experience you own or are authorized to edit.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("BrickOrbitalEvent")

local brickCount, height, radius = 8, 4, 8
local speed, angle = 1.4, 0
local bricks = {}
local launchBusy = false

local gui = Instance.new("ScreenGui")
gui.Name = "BrickOrbitalControls"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -14, 1, -24)
panel.Size = UDim2.fromOffset(200, 300)
panel.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
panel.BackgroundTransparency = 0.06
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local outline = Instance.new("UIStroke", panel)
outline.Color = Color3.fromRGB(124, 91, 255)
outline.Thickness = 1.5

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(8, 5)
title.Size = UDim2.new(1, -16, 0, 30)
title.Text = "🧱 BRICK ORBITAL"
title.TextColor3 = Color3.fromRGB(230, 224, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = panel

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(8, 33)
status.Size = UDim2.new(1, -16, 0, 22)
status.TextColor3 = Color3.fromRGB(190, 194, 210)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = panel

local grid = Instance.new("Frame")
grid.BackgroundTransparency = 1
grid.Position = UDim2.fromOffset(8, 60)
grid.Size = UDim2.new(1, -16, 1, -68)
grid.Parent = panel
local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0.5, -4, 0, 43)
layout.CellPadding = UDim2.fromOffset(8, 7)
layout.Parent = grid

local function refreshStatus()
    status.Text = string.format("Bricks: %d  |  Height: %d", brickCount, height)
end

local function button(label, order, callback, color)
    local b = Instance.new("TextButton")
    b.LayoutOrder = order
    b.Text = label
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.BackgroundColor3 = color or Color3.fromRGB(54, 49, 82)
    b.AutoButtonColor = true
    b.Parent = grid
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    b.Activated:Connect(callback)
end

local function makeLocalBricks()
    for _, p in ipairs(bricks) do
        if p and p.Parent then p:Destroy() end
    end
    table.clear(bricks)
    for i = 1, brickCount do
        local p = Instance.new("Part")
        p.Name = "LocalOrbitBrick"
        p.Size = Vector3.new(1.4, 1.4, 1.4)
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromHSV(i / math.max(brickCount, 1), 0.7, 1)
        p.Anchored = true
        p.CanCollide = false
        p.CanTouch = false
        p.CanQuery = false
        p.Parent = workspace
        table.insert(bricks, p)
    end
end

button("＋ Add Brick", 1, function()
    if brickCount < 24 then
        brickCount += 1
        remote:FireServer("SetCount", brickCount)
        makeLocalBricks()
        refreshStatus()
    end
end, Color3.fromRGB(73, 62, 130))

button("－ Remove", 2, function()
    if brickCount > 0 then
        brickCount -= 1
        remote:FireServer("SetCount", brickCount)
        makeLocalBricks()
        refreshStatus()
    end
end)

button("⬆ Height +", 3, function()
    height = math.min(height + 2, 20)
    refreshStatus()
end)

button("⬇ Height −", 4, function()
    height = math.max(height - 2, 0)
    refreshStatus()
end)

button("🔄 Reverse", 5, function()
    speed = -speed
end)

button("⚡ Launch", 6, function()
    if launchBusy then return end
    launchBusy = true
    remote:FireServer("Launch")
    task.delay(1.2, function() launchBusy = false end)
end, Color3.fromRGB(140, 65, 65))

button("🛑 Clear", 7, function()
    brickCount = 0
    remote:FireServer("SetCount", 0)
    makeLocalBricks()
    refreshStatus()
end)

button("▶ Rebuild", 8, function()
    brickCount = math.max(brickCount, 8)
    remote:FireServer("SetCount", brickCount)
    makeLocalBricks()
    refreshStatus()
end, Color3.fromRGB(44, 105, 81))

remote.OnClientEvent:Connect(function(action, value)
    if action == "Rebuild" and typeof(value) == "number" then
        brickCount = math.clamp(math.floor(value), 0, 24)
        makeLocalBricks()
        refreshStatus()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    makeLocalBricks()
end)

refreshStatus()
makeLocalBricks()
remote:FireServer("SetCount", brickCount)

RunService.RenderStepped:Connect(function(dt)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or #bricks == 0 then return end
    angle += dt * speed
    for i, p in ipairs(bricks) do
        if p and p.Parent then
            local theta = angle + ((i - 1) / #bricks) * math.pi * 2
            local bob = math.sin(angle * 2 + i) * 0.5
            local pos = root.Position + Vector3.new(
                math.cos(theta) * radius,
                height + bob,
                math.sin(theta) * radius
            )
            p.CFrame = CFrame.new(pos) * CFrame.Angles(theta, theta * 0.6, theta * 0.4)
        end
    end
end)
