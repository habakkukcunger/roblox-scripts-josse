-- Roblox Volleyball Legends - ALTERNATIVE DESYNC METHOD
-- This uses position interpolation + replication delay
-- Works by forcing the server to accept client-side prediction with a delay buffer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local DELAY_SECONDS = 1.5
local UPDATE_INTERVAL = 0.03

-- State
local state = {
    active = false,
    positionHistory = {},
    maxHistory = math.floor(DELAY_SECONDS / UPDATE_INTERVAL) + 30,
    lastUpdate = 0,
    ghostParts = {},
    ghostEnabled = false,
    fakeCFrame = nil,
    frameCounter = 0
}

-- ========== GHOST ==========
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
    body.Transparency = 0.3
    body.BrickColor = BrickColor.new("Bright red")
    body.Material = Enum.Material.Neon
    body.CFrame = rootPart.CFrame
    body.Parent = ghostGroup
    
    local head = Instance.new("Part")
    head.Name = "GhostHead"
    head.Size = Vector3.new(1.8, 1.8, 1.8)
    head.Shape = Enum.PartType.Ball
    head.Anchored = true
    head.CanCollide = false
    head.Transparency = 0.25
    head.BrickColor = BrickColor.new("Bright red")
    head.Material = Enum.Material.Neon
    head.CFrame = rootPart.CFrame * CFrame.new(0, 2.6, 0)
    head.Parent = ghostGroup
    
    local selBox = Instance.new("SelectionBox")
    selBox.Adornee = body
    selBox.Color3 = Color3.fromRGB(255, 50, 50)
    selBox.LineThickness = 0.08
    selBox.Transparency = 0.2
    selBox.Parent = body
    
    local light = Instance.new("PointLight")
    light.Range = 15
    light.Brightness = 4
    light.Color = Color3.fromRGB(255, 0, 0)
    light.Parent = body
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 180, 0, 35)
    billboard.Adornee = head
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = head
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🔴 DESYNC POSITION"
    label.TextColor3 = Color3.fromRGB(255, 100, 100)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.2
    label.TextStrokeColor3 = Color3.fromRGB(255, 0, 0)
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

-- ========== RECORD POSITION ==========
local function recordPosition()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    table.insert(state.positionHistory, {
        cframe = rootPart.CFrame,
        velocity = rootPart.Velocity,
        position = rootPart.Position,
        time = tick()
    })
    
    if #state.positionHistory > state.maxHistory then
        table.remove(state.positionHistory, 1)
    end
end

local function getDelayedPosition()
    if #state.positionHistory < 5 then return nil end
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

-- ========== ALTERNATIVE DESYNC METHOD ==========
-- This method actually moves the ghost and sends fake position data
-- without affecting your actual movement

local function applyDesyncAlternative()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local delayed = getDelayedPosition()
    if not delayed then return end
    
    -- Update ghost to show where others see you
    if state.ghostEnabled then
        updateGhost(delayed.cframe)
    end
    
    -- KEY METHOD: Force the server to accept a different position
    -- by temporarily setting position, then reverting
    -- The server remembers the fake position due to network lag
    
    pcall(function()
        -- Take full ownership
        if rootPart:GetNetworkOwner() ~= LocalPlayer then
            rootPart:SetNetworkOwner(LocalPlayer)
        end
        
        -- Store real values
        local realPos = rootPart.Position
        local realVel = rootPart.Velocity
        local realCF = rootPart.CFrame
        
        -- Apply delayed position to server
        rootPart.CFrame = delayed.cframe
        rootPart.Velocity = delayed.velocity
        
        -- Force network flush
        rootPart:SetNetworkOwner(LocalPlayer)
        
        -- Revert client-side instantly (server still sees the fake)
        task.spawn(function()
            wait(0.016) -- one frame
            if rootPart and rootPart.Parent then
                rootPart.CFrame = realCF
                rootPart.Velocity = realVel
                rootPart:SetNetworkOwner(LocalPlayer)
            end
        end)
    end)
end

-- ========== SECOND METHOD: VELOCITY INTERPOLATION ==========
-- This method continuously sends slightly delayed velocity data
-- Making the server think you're reacting slower than you are

local function applyVelocityDesync()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local delayed = getDelayedPosition()
    if not delayed then return end
    
    if state.ghostEnabled then
        updateGhost(delayed.cframe)
    end
    
    pcall(function()
        if rootPart:GetNetworkOwner() ~= LocalPlayer then
            rootPart:SetNetworkOwner(LocalPlayer)
        end
        
        -- Send velocity that's offset by delay
        -- This makes server think you're still moving from old position
        local currentVel = rootPart.Velocity
        local delayedVel = delayed.velocity
        
        -- Mix velocities - higher delayed = more desync
        local mixedVel = currentVel * 0.2 + delayedVel * 0.8
        
        -- Apply to server
        rootPart.Velocity = mixedVel
        
        -- Revert quickly
        task.spawn(function()
            wait(0.02)
            if rootPart and rootPart.Parent then
                rootPart.Velocity = currentVel
            end
        end)
    end)
end

-- ========== THIRD METHOD: POSITION OFFSET ==========
-- Sends a position that is slightly offset from reality
-- Creates a rubber-banding effect for other players

local offsetAmount = 0
local function applyOffsetDesync()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local delayed = getDelayedPosition()
    if not delayed then return end
    
    if state.ghostEnabled then
        updateGhost(delayed.cframe)
    end
    
    pcall(function()
        if rootPart:GetNetworkOwner() ~= LocalPlayer then
            rootPart:SetNetworkOwner(LocalPlayer)
        end
        
        -- Create a random offset that changes slowly
        offsetAmount = offsetAmount + (math.random(-2, 2) * 0.1)
        offsetAmount = math.clamp(offsetAmount, -3, 3)
        
        local offset = Vector3.new(offsetAmount, 0, math.random(-2, 2))
        local fakePos = delayed.position + offset
        
        -- Set fake position
        rootPart.Position = fakePos
        
        -- Revert
        task.spawn(function()
            wait(0.02)
            if rootPart and rootPart.Parent then
                rootPart.Position = delayed.position
            end
        end)
    end)
end

-- Switch between methods
local methodIndex = 1
local methods = {
    { name = "Velocity Desync", func = applyVelocityDesync },
    { name = "Position Offset", func = applyOffsetDesync },
    { name = "Full Desync", func = applyDesyncAlternative }
}

local function applyDesync()
    -- Rotate through methods for best effect
    methods[methodIndex].func()
    methodIndex = methodIndex % #methods + 1
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
frame.Size = UDim2.new(0, 220, 0, 190)
frame.Position = UDim2.new(0.5, -110, 0.5, -95)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local border = Instance.new("Frame")
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
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
title.Text = "🔴 DESYNC (ALTERNATIVE)"
title.TextColor3 = Color3.fromRGB(255, 200, 200)
title.TextSize = 15
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

local methodText = Instance.new("TextLabel")
methodText.Size = UDim2.new(1, 0, 0, 16)
methodText.Position = UDim2.new(0, 0, 0, 52)
methodText.BackgroundTransparency = 1
methodText.Text = "Method: Velocity"
methodText.TextColor3 = Color3.fromRGB(200, 200, 200)
methodText.TextSize = 11
methodText.Font = Enum.Font.Gotham
methodText.TextXAlignment = Enum.TextXAlignment.Center
methodText.Parent = frame

local ghostStatus = Instance.new("TextLabel")
ghostStatus.Size = UDim2.new(1, 0, 0, 16)
ghostStatus.Position = UDim2.new(0, 0, 0, 66)
ghostStatus.BackgroundTransparency = 1
ghostStatus.Text = "👻 Ghost: OFF"
ghostStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
ghostStatus.TextSize = 11
ghostStatus.Font = Enum.Font.Gotham
ghostStatus.TextXAlignment = Enum.TextXAlignment.Center
ghostStatus.Parent = frame

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, 0, 0, 30)
infoText.Position = UDim2.new(0, 0, 0, 82)
infoText.BackgroundTransparency = 1
infoText.Text = "If not working, try:\n- Re-enable\n- Change delay in script"
infoText.TextColor3 = Color3.fromRGB(150, 150, 180)
infoText.TextSize = 9
infoText.Font = Enum.Font.Gotham
infoText.TextXAlignment = Enum.TextXAlignment.Center
infoText.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 80, 0, 26)
toggleBtn.Position = UDim2.new(0.25, -40, 0, 135)
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
ghostBtn.Position = UDim2.new(0.75, -40, 0, 135)
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

-- Legend
local legend = Instance.new("TextLabel")
legend.Size = UDim2.new(1, 0, 0, 14)
legend.Position = UDim2.new(0, 0, 0, 172)
legend.BackgroundTransparency = 1
legend.Text = "🔴 Red ghost = where others see you"
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
        if y > 130 and y < 160 and x > 20 and x < 100 then return end
        if y > 130 and y < 160 and x > 120 and x < 200 then return end
        if y > 3 and y < 25 and x > 175 and x < 200 then return end
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

-- ========== TOGGLE ==========
local debounce = false

local function setDesyncState(newState)
    state.active = newState
    if newState then
        statusText.Text = "● ON"
        statusText.TextColor3 = Color3.fromRGB(80, 255, 130)
        toggleBtn.Text = "DISABLE"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        border.BackgroundTransparency = 0.3
        state.positionHistory = {}
        methodText.Text = "Method: " .. methods[methodIndex].name
        
        if not state.ghostEnabled then
            setGhostVisible(true)
            ghostBtn.Text = "GHOST ON"
            ghostBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            ghostStatus.Text = "👻 Ghost: ON"
            ghostStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
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
        ghostStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
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
        ghostStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
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
    
    recordPosition()
    
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
                    if k == "Value" then return 200 + math.random(0, 50) end
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

print("=== ALTERNATIVE DESYNC LOADED ===")
print("This uses 3 different methods rotating:")
print("1. Velocity Desync - sends delayed velocity")
print("2. Position Offset - adds small offset to position")
print("3. Full Desync - sends delayed position outright")
print("")
print("If still not working, Roblox may have patched this method.")
print("Try changing DELAY_SECONDS to 2.0 or 2.5 at the top of script.")
print("Red ghost shows where others see you.")
