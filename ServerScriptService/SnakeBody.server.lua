-- TeaHack: SNAKE BODY REPLACEMENT
-- Put this Script in ServerScriptService in an experience you own.
-- This is a character-visual replacement, NOT a game.
-- Hides the standard avatar body and adds a snake head and curved body segments.
-- The player's Humanoid and controls remain in place.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SEGMENT_COUNT = 12
local SEGMENT_SPACING = 1.15
local BODY_RADIUS = 0.72
local HISTORY_STEP = 0.12
local SNAKE_COLOR = Color3.fromRGB(65, 170, 95)
local BELLY_COLOR = Color3.fromRGB(180, 220, 125)

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

local function hideOriginalCharacter(character)
    for _, item in ipairs(character:GetDescendants()) do
        if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
            item.Transparency = 1
            item.LocalTransparencyModifier = 0
            item.CastShadow = false
        elseif item:IsA("Decal") or item:IsA("Texture") then
            item.Transparency = 1
        elseif item:IsA("Accessory") then
            local handle = item:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.Transparency = 1
            end
        end
    end
end

local function buildSnake(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoid or not root then return end

    local old = character:FindFirstChild("TeaHackSnakeVisual")
    if old then old:Destroy() end

    hideOriginalCharacter(character)

    local model = Instance.new("Model")
    model.Name = "TeaHackSnakeVisual"
    model.Parent = character

    local segments = {}
    for i = 1, SEGMENT_COUNT do
        local scale = 1 - ((i - 1) / SEGMENT_COUNT) * 0.32
        local segment = makePart(
            model,
            "BodySegment" .. i,
            Vector3.new(BODY_RADIUS * 2 * scale, BODY_RADIUS * 1.7 * scale, BODY_RADIUS * 2 * scale),
            (i % 3 == 0) and BELLY_COLOR or SNAKE_COLOR,
            Enum.PartType.Ball
        )
        table.insert(segments, segment)
    end

    local head = makePart(model, "SnakeHead", Vector3.new(1.8, 1.25, 2), SNAKE_COLOR, Enum.PartType.Ball)
    local eyeLeft = makePart(model, "EyeLeft", Vector3.new(0.22, 0.22, 0.22), Color3.new(1, 1, 1))
    local eyeRight = makePart(model, "EyeRight", Vector3.new(0.22, 0.22, 0.22), Color3.new(1, 1, 1))
    local pupilLeft = makePart(model, "PupilLeft", Vector3.new(0.1, 0.1, 0.1), Color3.fromRGB(15, 15, 15))
    local pupilRight = makePart(model, "PupilRight", Vector3.new(0.1, 0.1, 0.1), Color3.fromRGB(15, 15, 15))

    local history = {}
    local lastHistoryPosition = root.Position
    for i = 0, SEGMENT_COUNT + 4 do
        table.insert(history, root.Position - root.CFrame.LookVector * (i * HISTORY_STEP))
    end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character.Parent or not root.Parent or humanoid.Health <= 0 then
            connection:Disconnect()
            model:Destroy()
            return
        end

        local currentPosition = root.Position
        if (currentPosition - lastHistoryPosition).Magnitude >= HISTORY_STEP then
            table.insert(history, 1, currentPosition)
            lastHistoryPosition = currentPosition
            local maxHistory = math.ceil((SEGMENT_COUNT * SEGMENT_SPACING + 8) / HISTORY_STEP)
            while #history > maxHistory do
                table.remove(history)
            end
        end

        local function pointAtDistance(distance)
            local remaining = distance
            for index = 1, #history - 1 do
                local a = history[index]
                local b = history[index + 1]
                local length = (a - b).Magnitude
                if length >= remaining then
                    if length > 0 then
                        return a:Lerp(b, remaining / length)
                    end
                    return a
                end
                remaining -= length
            end
            return history[#history] or currentPosition
        end

        local forward = root.CFrame.LookVector
        local headPosition = currentPosition + Vector3.new(0, 0.15, 0) + forward * 0.65
        head.CFrame = CFrame.lookAt(headPosition, headPosition + forward) * CFrame.Angles(0, math.rad(180), 0)

        local right = root.CFrame.RightVector
        local up = Vector3.new(0, 1, 0)
        eyeLeft.CFrame = CFrame.new(headPosition + forward * 0.42 - right * 0.48 + up * 0.28)
        eyeRight.CFrame = CFrame.new(headPosition + forward * 0.42 + right * 0.48 + up * 0.28)
        pupilLeft.CFrame = eyeLeft.CFrame * CFrame.new(0, 0, -0.08)
        pupilRight.CFrame = eyeRight.CFrame * CFrame.new(0, 0, -0.08)

        for i, segment in ipairs(segments) do
            local position = pointAtDistance((i * SEGMENT_SPACING) + 0.7)
            segment.CFrame = CFrame.new(position)
        end
    end)

    humanoid.Died:Connect(function()
        if connection then connection:Disconnect() end
        if model then model:Destroy() end
    end)
end

local function onPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.25)
        buildSnake(character)
    end)
    if player.Character then
        task.spawn(buildSnake, player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in ipairs(Players:GetPlayers()) do
    onPlayer(player)
end
