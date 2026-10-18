-- TeaHack: BRICK ORBITAL SERVER
-- Place in ServerScriptService as a Script.
-- Orbit visuals are local; launched bricks are server-created physical parts.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local remote = ReplicatedStorage:FindFirstChild("BrickOrbitalEvent")
if not remote then
    remote = Instance.new("RemoteEvent")
    remote.Name = "BrickOrbitalEvent"
    remote.Parent = ReplicatedStorage
end

local counts, lastLaunch = {}, {}

remote.OnServerEvent:Connect(function(player, action, value)
    if action == "SetCount" then
        if typeof(value) ~= "number" then return end
        counts[player] = math.clamp(math.floor(value), 0, 24)
        remote:FireClient(player, "Rebuild", counts[player])
    elseif action == "Launch" then
        local now = os.clock()
        if lastLaunch[player] and now - lastLaunch[player] < 1 then return end
        lastLaunch[player] = now

        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local count = math.clamp(counts[player] or 8, 1, 24)
        for i = 1, count do
            local theta = i / count * math.pi * 2
            local brick = Instance.new("Part")
            brick.Name = "LaunchedOrbitBrick"
            brick.Size = Vector3.new(1.4, 1.4, 1.4)
            brick.Material = Enum.Material.Neon
            brick.Color = Color3.fromHSV(i / count, 0.75, 1)
            brick.CFrame = root.CFrame * CFrame.new(math.cos(theta) * 4, 2, math.sin(theta) * 4)
            brick.Anchored = false
            brick.CanCollide = true
            brick.Parent = workspace
            brick.AssemblyLinearVelocity = root.CFrame.LookVector * 70
                + Vector3.new(math.cos(theta) * 28, 24, math.sin(theta) * 28)
            brick.AssemblyAngularVelocity = Vector3.new(math.random(-8, 8), math.random(-8, 8), math.random(-8, 8))
            Debris:AddItem(brick, 4)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    counts[player] = nil
    lastLaunch[player] = nil
end)
