-- TeaHack: SNAKE BODY REPLACEMENT (FE-compatible)
-- Put this Script in ServerScriptService in a Roblox Studio experience you own.
-- It hides the avatar's visible body and creates a replicated snake body.
-- The normal Humanoid/controls remain, so this is a character visual replacement,
-- not a standalone game and not an executor script.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SEGMENT_COUNT = 12
local SAMPLE_SPACING = 5 -- frames between body segments; increase for a longer snake
local BODY_COLOR = Color3.fromRGB(52, 170, 84)
local BELLY_COLOR = Color3.fromRGB(205, 190, 126)
local SNAKE_NAME = "TeaHackSnakeBody"

local active = {}

local function makePart(parent, name, size, color, shape)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = Enum.Material.SmoothPlastic
    part.Shape = shape or Enum.PartType.Ball
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = true
    part.Parent = parent
    return part
end

local function hideAvatar(character)
    for _, item in ipairs(character:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Transparency = 1
            item.CastShadow = false
        elseif item:IsA("Decal") or item:IsA("Texture") then
            item.Transparency = 1
        end
    end
end

local function buildSnake(player, character)
    if active[player] then
        active[player].connection:Disconnect()
        active[player].model:Destroy()
        active[player] = nil
    end

    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not root then return end

    hideAvatar(character)

    local model = Instance.new("Model")
    model.Name = SNAKE_NAME .. "_" .. player.UserId
    model.Parent = workspace

    local head = makePart(model, "SnakeHead", Vector3.new(2.8, 2, 2.8), BODY_COLOR)
    local eyeL = makePart(model, "EyeLeft", Vector3.new(0.42, 0.42, 0.42), Color3.new(1, 1, 1))
    local eyeR = makePart(model, "EyeRight", Vector3.new(0.42, 0.42, 0.42), Color3.new(1, 1, 1))
    local pupilL = makePart(model, "PupilLeft", Vector3.new(0.2, 0.2, 0.2), Color3.fromRGB(20, 20, 20))
    local pupilR = makePart(model, "PupilRight", Vector3.new(0.2, 0.2, 0.2), Color3.fromRGB(20, 20, 20))
    local tongue = makePart(model, "Tongue", Vector3.new(0.12, 0.12, 1.1), Color3.fromRGB(225, 50, 80), Enum.PartType.Block)

    local segments = {}
    for i = 1, SEGMENT_COUNT do
        local scale = 1 - ((i - 1) / SEGMENT_COUNT) * 0.55
        local size = Vector3.new(2.1, 1.45, 1.8) * scale
        local segment = makePart(model, "BodySegment" .. i, size, i % 2 == 0 and BODY_COLOR or BELLY_COLOR)
        table.insert(segments, segment)
    end

    local history = {}
    local maxHistory = SEGMENT_COUNT * SAMPLE_SPACING + 20
    local connection

    connection = RunService.Heartbeat:Connect(function()
        if not character.Parent or humanoid.Health <= 0 or not root.Parent then
            if connection then connection:Disconnect() end
            if model.Parent then model:Destroy() end
            if active[player] and active[player].model == model then active[player] = nil end
            return
        end

        local rootCF = root.CFrame
        table.insert(history, 1, root.Position)
        if #history > maxHistory then
            table.remove(history)
        end

        local forward = rootCF.LookVector
        local right = rootCF.RightVector
        local headPos = root.Position + forward * 1.25 + Vector3.new(0, 0.15, 0)
        head.CFrame = CFrame.lookAt(headPos, headPos + forward)

        local eyeOffsetForward = forward * 0.75
        local eyeOffsetSide = right * 0.72
        local eyeOffsetUp = Vector3.new(0, 0.48, 0)
        eyeL.Position = headPos + eyeOffsetForward + eyeOffsetSide + eyeOffsetUp
        eyeR.Position = headPos + eyeOffsetForward - eyeOffsetSide + eyeOffsetUp
        pupilL.Position = eyeL.Position + forward * 0.16
        pupilR.Position = eyeR.Position + forward * 0.16
        local tongueStart = headPos + forward * 1.15
        tongue.CFrame = CFrame.lookAt(tongueStart + forward * 0.48, tongueStart + forward * 1.2)

        for i, segment in ipairs(segments) do
            local sampleIndex = 1 + i * SAMPLE_SPACING
            local pos = history[math.min(sampleIndex, #history)] or root.Position
            local nextPos = history[math.min(sampleIndex + 1, #history)]
            local direction = nextPos and (pos - nextPos) or -forward
            if direction.Magnitude < 0.01 then direction = -forward end
            segment.CFrame = CFrame.lookAt(pos - forward * 0.8, pos - forward * 0.8 + direction.Unit)
        end
    end)

    active[player] = { model = model, connection = connection }
end

local function onPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.25)
        buildSnake(player, character)
    end)
    if player.Character then
        task.spawn(buildSnake, player, player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
    local state = active[player]
    if state then
        state.connection:Disconnect()
        state.model:Destroy()
        active[player] = nil
    end
end)
