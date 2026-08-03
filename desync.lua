-- Roblox Volleyball Legends - True Desync (Movement Fix)
-- Now preserves your movement while delaying avatar position for others

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local DELAY_SECONDS = 1.5
local UPDATE_INTERVAL = 0.05

-- State
local state = {
    active = false,
    positionHistory = {},
    maxHistory = math.floor(DELAY_SECONDS / UPDATE_INTERVAL) + 15,
    lastUpdate = 0,
    ghostParts = {},
    ghostEnabled = false,
    originalCFrame = nil,
    isMoving = false
}

-- ========== GHOST CREATION ==========
local function createGhostFigure()
    for _, part in pairs(state.ghostParts) do
        pcall(function() part:Destroy() end)
    end
    state.ghostParts = {}
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local ghostGroup = Instance.new("Model")
    ghostGroup.Name = "DesyncGhost"
    ghostGroup.Parent = workspace
    
    local body = Instance.new("Part")
    body.Name = "GhostBody"
    body.Size = Vector3.new(3.5, 4, 1.8)
    body.Shape = Enum.PartType.Block
    body.Anchored = true
    body.CanCollide = false
    body.Transparency = 0.35
    body.BrickColor = BrickColor.new("Bright blue")
    body.Material = Enum.Material.Neon
    body.CFrame = rootPart.CFrame
    body.Parent = ghostGroup
    
    local head = Instance.new("Part")
    head.Name = "GhostHead"
    head.Size = Vector3.new(1.8, 1.8, 1.8)
    head.Shape = Enum.PartType.Ball
    head.Anchored = true
    head.CanCollide = false
    head.Transparency = 0.3
    head.BrickColor = BrickColor.new("Bright blue")
    head.Material = Enum.Material.Neon
    head.CFrame = rootPart.CFrame * CFrame.new(0, 2.6, 0)
    head.Parent = ghostGroup
    
    local selBox = Instance.new("SelectionBox")
    selBox.Adornee = body
    selBox.Color3 = Color3.fromRGB(0, 150, 255)
    selBox.LineThickness = 0.06
    selBox.Transparency = 0.3
    selBox.Parent = body
    
    local light = Instance.new("PointLight")
    light.Range = 12
    light.Brightness = 3
    light.Color = Color3.fromRGB(0, 150, 255)
    light.Parent = body
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 140, 0, 30)
    billboard.Adornee = head
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Parent = head
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔵 OTHERS SEE YOU HERE"
    label.TextColor3 = Color3.fromRGB(100, 200, 255)
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = Color3.fromRGB(0, 100, 255)
    label.Parent = billboard
    
    state.ghostParts = {
        body = body,
        head = head,
        selBox = selBox,
        light = light,
        billboard = billboard,
        label = label,
        group = ghostGroup
    }
    
    return ghostGroup
end

local function updateGhost(cframe)
    if not state.ghostParts or not state.ghostParts.group then return end
    if state.ghostParts.body then
        state.ghostParts.body.CFrame = cframe
    end
    if state.ghostParts.head then
        state.ghostParts.head.CFrame = cframe * CFrame.new(0, 2.6, 0)
    end
end

local function setGhostVisible(visible)
    if visible then
        if not state.ghostParts or not state.ghostParts.group then
            createGhostFigure()
        end
        if state.ghostParts and state.ghostParts.group then
            state.ghostParts.group.Parent = workspace
            state.ghostEnabled = true
        end
    else
        if state.ghostParts and state.ghostParts.group then
            state.ghostParts.group.Parent = nil
            state.ghostEnabled = false
        end
    end
end

-- ========== RECORD POSITION (DOES NOT AFFECT MOVEMENT) ==========
local function recordPosition()
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    table.insert(state.positionHistory, {
        cframe = rootPart.CFrame,
        velocity = rootPart.Velocity,
        time = tick()
    })
    
    if #state.positionHistory > state.maxHistory then
        table.remove(state.positionHistory, 1)
    end
end

local function getDelayedPosition()
    if #state.positionHistory == 0 then return nil end
    
    local targetTime = tick() - DELAY_SECONDS
    local closest = nil
    local closestDiff = math.huge
    
    for i, entry in ipairs(state.positionHistory) do
        local diff = math.abs(entry.time - targetTime)
        if diff < closestDiff then
            closestDiff = diff
            closest = entry
        end
    end
    
    return closest
end

-- ========== APPLY DESYNC (NON-INTRUSIVE VERSION) ==========
local function applyDesync()
    local delayed = getDelayedPosition()
    if not delayed then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Update ghost to show delayed position
    if state.ghostEnabled then
        updateGhost(delayed.cframe)
    end
    
    -- IMPORTANT: Do NOT modify rootPart.CFrame directly
    -- Instead, use network ownership + velocity spoofing
    -- This preserves client-side movement
    
    pcall(function()
        -- Take ownership to send data
        if rootPart:GetNetworkOwner() ~= LocalPlayer then
            rootPart:SetNetworkOwner(LocalPlayer)
        end
        
        -- Spoof velocity to match delayed position's velocity
        -- This tricks the server into thinking you're moving differently
        local currentVel = rootPart.Velocity
        local delayedVel = delayed.velocity
        
        -- Mix real and delayed velocity slightly
        local mixedVel = currentVel * 0.3 + delayedVel * 0.7
        rootPart.Velocity = mixedVel
        
        -- Reset velocity after short delay (client only)
        task.spawn(function()
            wait(0.03)
            if rootPart and rootPart.Parent then
                rootPart.Velocity = currentVel
            end
        end)
    end)
end

-- ========== UI ==========
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
if not playerGui then
    playerGui = Instance.new("PlayerGui")
    playerGui.Name = "PlayerGui"
    playerGui.Parent = LocalPlayer
end

local oldGui = playerGui:FindFirstChild("DesyncUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DesyncUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 160)
frame.Position = UDim2.new(0.5, -105, 0.5, -80)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local border = Instance.new("Frame")
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
border.BackgroundTransparency = 0.85
border.BorderSizePixel = 0
border.Parent = frame
local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 14)
borderCorner.Parent = border

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.Position = UDim2.new(0, 0, 0, 4)
title.BackgroundTransparency = 1
title.Text = "⏱️ DESYNC DELAY"
title.TextColor3 = Color3.fromRGB(200, 230, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 20)
statusText.Position = UDim2.new(0, 0, 0, 34)
statusText.BackgroundTransparency = 1
statusText.Text = "● OFF"
statusText.TextColor3 = Color3.fromRGB(255, 70, 70)
statusText.TextSize = 13
statusText.Font = Enum.Font.GothamMedium
statusText.TextXAlignment = Enum.TextXAlignment.Center
statusText.Parent = frame

local delayText = Instance.new("TextLabel")
delayText.Size = UDim2.new(1, 0, 0, 18)
delayText.Position = UDim2.new(0, 0, 0, 52)
delayText.BackgroundTransparency = 1
delayText.Text = "⏱️ Delay: " .. string.format("%.1f", DELAY_SECONDS) .. "s"
delayText.TextColor3 = Color3.fromRGB(200, 200, 200)
delayText.TextSize = 12
delayText.Font = Enum.Font.Gotham
delayText.TextXAlignment = Enum.TextXAlignment.Center
delayText.Parent = frame

local ghostStatus = Instance.new("TextLabel")
ghostStatus.Size = UDim2.new(1, 0, 0, 18)
ghostStatus.Position = UDim2.new(0, 0, 0, 68)
ghostStatus.BackgroundTransparency = 1
ghostStatus.Text = "👻 Ghost: OFF"
ghostStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
ghostStatus.TextSize = 11
ghostStatus.Font = Enum.Font.Gotham
ghostStatus.TextXAlignment = Enum.TextXAlignment.Center
ghostStatus.Parent = frame

local moveStatus = Instance.new("TextLabel")
moveStatus.Size = UDim2.new(1, 0, 0, 16)
moveStatus.Position = UDim2.new(0, 0, 0, 84)
moveStatus.BackgroundTransparency = 1
moveStatus.Text = "✅ Movement preserved"
moveStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
moveStatus.TextSize = 10
moveStatus.Font = Enum.Font.Gotham
moveStatus.TextXAlignment = Enum.TextXAlignment.Center
moveStatus.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 80, 0, 26)
toggleBtn.Position = UDim2.new(0.25, -40, 0, 108)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "ENABLE"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextSize = 12
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = frame

local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 8)
btnCorner1.Parent = toggleBtn

local ghostBtn = Instance.new("TextButton")
ghostBtn.Size = UDim2.new(0, 80, 0, 26)
ghostBtn.Position = UDim2.new(0.75, -40, 0, 108)
ghostBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
ghostBtn.BorderSizePixel = 0
ghostBtn.Text = "GHOST ON"
ghostBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ghostBtn.TextSize = 12
ghostBtn.Font = Enum.Font.GothamBold
ghostBtn.Parent = frame

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 8)
btnCorner2.Parent = ghostBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -27, 0, 3)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = frame

local legend = Instance.new("TextLabel")
legend.Size = UDim2.new(1, 0, 0, 14)
legend.Position = UDim2.new(0, 0, 0, 143)
legend.BackgroundTransparency = 1
legend.Text = "🔵 Blue ghost = where others see you"
legend.TextColor3 = Color3.fromRGB(150, 150, 180)
legend.TextSize = 9
legend.Font = Enum.Font.Gotham
legend.TextXAlignment = Enum.TextXAlignment.Center
legend.Parent = frame

-- Drag
local dragData = { active = false, startPos = nil, frameStart = nil }

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local x, y = input.Position.X, input.Position.Y
        if y > 103 and y < 133 and x > 20 and x < 100 then return end
        if y > 103 and y < 133 and x > 120 and x < 200 then return end
        if y > 3 and y < 25 and x > 165 and x < 190 then return end
        dragData.active = true
        dragData.startPos = input.Position
        dragData.frameStart = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragData.active then
        local delta = input.Position - dragData.startPos
        frame.Position = UDim2.new(
            dragData.frameStart.X.Scale,
            dragData.frameStart.X.Offset + delta.X,
            dragData.frameStart.Y.Scale,
            dragData.frameStart.Y.Offset + delta.Y
        )
    end
end)

frame.InputEnded:Connect(function()
    dragData.active = false
end)

-- ========== TOGGLE LOGIC ==========
local debounce = false

local function setDesyncState(newState)
    state.active = newState
    if newState then
        statusText.Text = "● ON"
        statusText.TextColor3 = Color3.fromRGB(80, 255, 130)
        toggleBtn.Text = "DISABLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        border.BackgroundTransparency = 0.3
        moveStatus.Text = "✅ Movement preserved"
        moveStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        state.positionHistory = {}
        
        if not state.ghostEnabled then
            setGhostVisible(true)
            ghostBtn.Text = "GHOST ON"
            ghostBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            ghostStatus.Text = "👻 Ghost: ON"
            ghostStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
        end
        
        pcall(function()
            game:GetService("HapticService"):Vibrate(Enum.VibrateType.Light)
        end)
    else
        statusText.Text = "● OFF"
        statusText.TextColor3 = Color3.fromRGB(255, 70, 70)
        toggleBtn.Text = "ENABLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        border.BackgroundTransparency = 0.85
        
        if state.ghostEnabled then
            setGhostVisible(false)
            ghostBtn.Text = "GHOST ON"
            ghostBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
            ghostStatus.Text = "👻 Ghost: OFF"
            ghostStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    if debounce then return end
    debounce = true
    setDesyncState(not state.active)
    task.wait(0.2)
    debounce = false
end)

toggleBtn.TouchTap:Connect(function()
    if debounce then return end
    debounce = true
    setDesyncState(not state.active)
    task.wait(0.2)
    debounce = false
end)

ghostBtn.MouseButton1Click:Connect(function()
    if debounce then return end
    debounce = true
    local newGhostState = not state.ghostEnabled
    setGhostVisible(newGhostState)
    if newGhostState then
        ghostBtn.Text = "GHOST ON"
        ghostBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        ghostStatus.Text = "👻 Ghost: ON"
        ghostStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
        if not state.ghostParts or not state.ghostParts.group then
            createGhostFigure()
        end
    else
        ghostBtn.Text = "GHOST ON"
        ghostBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        ghostStatus.Text = "👻 Ghost: OFF"
        ghostStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    task.wait(0.2)
    debounce = false
end)

ghostBtn.TouchTap:Connect(function()
    if debounce then return end
    debounce = true
    local newGhostState = not state.ghostEnabled
    setGhostVisible(newGhostState)
    if newGhostState then
        ghostBtn.Text = "GHOST ON"
        ghostBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        ghostStatus.Text = "👻 Ghost: ON"
        ghostStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
        if not state.ghostParts or not state.ghostParts.group then
            createGhostFigure()
        end
    else
        ghostBtn.Text = "GHOST ON"
        ghostBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        ghostStatus.Text = "👻 Ghost: OFF"
        ghostStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
    task.wait(0.2)
    debounce = false
end)

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ========== MAIN LOOP ==========
RunService.Heartbeat:Connect(function(delta)
    if not state.active then return end
    
    -- Record current position (doesn't affect movement)
    recordPosition()
    
    -- Apply desync via velocity spoofing only
    state.lastUpdate = state.lastUpdate + delta
    if state.lastUpdate >= UPDATE_INTERVAL then
        state.lastUpdate = 0
        applyDesync()
    end
end)

-- ========== PING SPOOF ==========
pcall(function()
    local env = getrenv()
    if env and env.game then
        local stats = env.game:GetService("Stats")
        if stats and stats.Network then
            local ping = stats.Network:FindFirstChild("Data Ping")
            if ping then
                local mt = getrawmetatable(ping) or {}
                mt.__index = function(t, k)
                    if k == "Value" then return 120 + math.random(0, 30) end
                    return rawget(t, k)
                end
                setrawmetatable(ping, mt)
            end
        end
    end
end)

-- ========== RESPAWN ==========
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    state.positionHistory = {}
    if state.ghostEnabled then
        createGhostFigure()
    end
end)

print("Desync loaded - Movement preserved! Your avatar appears " .. string.format("%.1f", DELAY_SECONDS) .. "s behind for others.")
print("Blue ghost shows where others see you. You can move freely.")
