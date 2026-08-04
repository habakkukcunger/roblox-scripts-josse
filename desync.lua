--[[ ULTIMATE DESYNC + LAG SWITCH (FINAL) ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local DEFAULT_DELAY = 2.0
local UPDATE_INTERVAL = 0.05
local HOLD_TIME = 0.1
local LAG_SWITCH_DURATION = 1.0
local LAG_SWITCH_COOLDOWN = 5.0

local state = {
    active = false,
    delay = DEFAULT_DELAY,
    history = {},
    maxHistory = 200,
    lastUpdate = 0,
    lagSwitchPaused = false,
    lagSwitchCooldown = 0,
    uiVisible = true,
    toggleButton = nil,
    mainFrame = nil,
    sliderKnob = nil,
    sliderFill = nil,
    sliderLabel = nil,
    statusText = nil,
    lagStatus = nil,
    desyncBtn = nil,
    lagBtn = nil,
    border = nil,
    isDragging = false,
    dragStart = nil,
    frameStart = nil
}

-- ========== CORE ==========
local function recordPosition()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    table.insert(state.history, {
        cframe = root.CFrame,
        velocity = root.Velocity,
        time = tick()
    })
    if #state.history > state.maxHistory then table.remove(state.history,1) end
end

local function getDelayedState()
    if #state.history < 10 then return nil end
    local target = tick() - state.delay
    local best, bestDiff = nil, math.huge
    for _, entry in ipairs(state.history) do
        local diff = math.abs(entry.time - target)
        if diff < bestDiff then
            bestDiff = diff
            best = entry
        end
    end
    return best
end

local function applyDesync()
    if not state.active or state.lagSwitchPaused then return end
    local delayed = getDelayedState()
    if not delayed then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    pcall(function()
        if root:GetNetworkOwner() ~= LocalPlayer then
            root:SetNetworkOwner(LocalPlayer)
        end
        local realCF = root.CFrame
        local realVel = root.Velocity
        root.CFrame = delayed.cframe
        root.Velocity = delayed.velocity
        task.spawn(function()
            wait(HOLD_TIME)
            if root and root.Parent then
                pcall(function()
                    root.CFrame = realCF
                    root.Velocity = realVel
                end)
            end
        end)
    end)
end

-- ========== UI FUNCTIONS ==========
local function setUIVisible(visible)
    state.uiVisible = visible
    if state.mainFrame then state.mainFrame.Visible = visible end
    if state.toggleButton then
        state.toggleButton.BackgroundColor3 = visible and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,50,50)
    end
end

local function createUIToggleButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DesyncToggleGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
    gui.Parent = playerGui
    local btn = Instance.new("TextButton")
    btn.Name = "UIToggleBtn"
    btn.Size = UDim2.new(0, 48, 0, 48)
    btn.Position = UDim2.new(0, 12, 0, 12)
    btn.BackgroundColor3 = Color3.fromRGB(0,200,100)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = "⚡"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 10
    btn.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0)
    corner.Parent = btn
    local shadow = Instance.new("UIShadow")
    shadow.Parent = btn
    btn.MouseButton1Click:Connect(function() setUIVisible(not state.uiVisible) end)
    btn.TouchTap:Connect(function() setUIVisible(not state.uiVisible) end)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            task.wait(0.05)
            setUIVisible(not state.uiVisible)
        end
    end)
    state.toggleButton = btn
    return btn
end

-- ========== MAIN UI ==========
local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("DesyncUI")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DesyncUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 320, 0, 270)
frame.Position = UDim2.new(0.5, -160, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui
state.mainFrame = frame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = frame

state.border = Instance.new("Frame")
state.border.Size = UDim2.new(1,0,1,0)
state.border.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
state.border.BackgroundTransparency = 0.75
state.border.BorderSizePixel = 0
state.border.Parent = frame
local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 18)
borderCorner.Parent = state.border

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 28))
})
gradient.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,36)
title.Position = UDim2.new(0,0,0,8)
title.BackgroundTransparency = 1
title.Text = "⏱️ DESYNC + LAG SWITCH"
title.TextColor3 = Color3.fromRGB(220, 235, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

state.statusText = Instance.new("TextLabel")
state.statusText.Size = UDim2.new(1,0,0,20)
state.statusText.Position = UDim2.new(0,0,0,46)
state.statusText.BackgroundTransparency = 1
state.statusText.Text = "● Desync: OFF"
state.statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
state.statusText.TextSize = 13
state.statusText.Font = Enum.Font.GothamMedium
state.statusText.TextXAlignment = Enum.TextXAlignment.Center
state.statusText.Parent = frame

state.lagStatus = Instance.new("TextLabel")
state.lagStatus.Size = UDim2.new(1,0,0,18)
state.lagStatus.Position = UDim2.new(0,0,0,66)
state.lagStatus.BackgroundTransparency = 1
state.lagStatus.Text = "● Lag Switch: READY"
state.lagStatus.TextColor3 = Color3.fromRGB(120, 255, 120)
state.lagStatus.TextSize = 12
state.lagStatus.Font = Enum.Font.Gotham
state.lagStatus.TextXAlignment = Enum.TextXAlignment.Center
state.lagStatus.Parent = frame

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1,0,0,16)
delayLabel.Position = UDim2.new(0,0,0,88)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay: " .. string.format("%.1f", state.delay) .. "s"
delayLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
delayLabel.TextSize = 12
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextXAlignment = Enum.TextXAlignment.Center
delayLabel.Parent = frame

state.sliderLabel = Instance.new("TextLabel")
state.sliderLabel.Size = UDim2.new(1,0,0,16)
state.sliderLabel.Position = UDim2.new(0,0,0,106)
state.sliderLabel.BackgroundTransparency = 1
state.sliderLabel.Text = "1.0s"
state.sliderLabel.TextColor3 = Color3.fromRGB(180, 220, 255)
state.sliderLabel.TextSize = 12
state.sliderLabel.Font = Enum.Font.GothamBold
state.sliderLabel.TextXAlignment = Enum.TextXAlignment.Center
state.sliderLabel.Parent = frame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(0, 200, 0, 6)
sliderBg.Position = UDim2.new(0.5, -100, 0, 126)
sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = frame
local sliderBgCorner = Instance.new("UICorner")
sliderBgCorner.CornerRadius = UDim.new(0, 4)
sliderBgCorner.Parent = sliderBg

state.sliderFill = Instance.new("Frame")
state.sliderFill.Size = UDim2.new((state.delay - 0.5) / 2.5, 0, 1, 0)
state.sliderFill.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
state.sliderFill.BorderSizePixel = 0
state.sliderFill.Parent = sliderBg
local sliderFillCorner = Instance.new("UICorner")
sliderFillCorner.CornerRadius = UDim.new(0, 4)
sliderFillCorner.Parent = state.sliderFill

state.sliderKnob = Instance.new("Frame")
state.sliderKnob.Size = UDim2.new(0, 18, 0, 18)
state.sliderKnob.Position = UDim2.new((state.delay - 0.5) / 2.5, -9, 0.5, -9)
state.sliderKnob.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
state.sliderKnob.BorderSizePixel = 0
state.sliderKnob.Parent = sliderBg
local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1,0)
knobCorner.Parent = state.sliderKnob

local minLabel = Instance.new("TextLabel")
minLabel.Size = UDim2.new(0, 30, 0, 14)
minLabel.Position = UDim2.new(0.5, -115, 0, 134)
minLabel.BackgroundTransparency = 1
minLabel.Text = "0.5s"
minLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
minLabel.TextSize = 10
minLabel.Font = Enum.Font.Gotham
minLabel.Parent = frame

local maxLabel = Instance.new("TextLabel")
maxLabel.Size = UDim2.new(0, 30, 0, 14)
maxLabel.Position = UDim2.new(0.5, 85, 0, 134)
maxLabel.BackgroundTransparency = 1
maxLabel.Text = "3.0s"
maxLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
maxLabel.TextSize = 10
maxLabel.Font = Enum.Font.Gotham
maxLabel.Parent = frame

state.desyncBtn = Instance.new("TextButton")
state.desyncBtn.Size = UDim2.new(0, 120, 0, 34)
state.desyncBtn.Position = UDim2.new(0, 20, 0, 165)
state.desyncBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
state.desyncBtn.BorderSizePixel = 0
state.desyncBtn.Text = "DESYNC"
state.desyncBtn.TextColor3 = Color3.fromRGB(255,255,255)
state.desyncBtn.TextSize = 13
state.desyncBtn.Font = Enum.Font.GothamBold
state.desyncBtn.AutoButtonColor = true
state.desyncBtn.Parent = frame
local desyncCorner = Instance.new("UICorner")
desyncCorner.CornerRadius = UDim.new(0, 8)
desyncCorner.Parent = state.desyncBtn

state.lagBtn = Instance.new("TextButton")
state.lagBtn.Size = UDim2.new(0, 120, 0, 34)
state.lagBtn.Position = UDim2.new(0, 180, 0, 165)
state.lagBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
state.lagBtn.BorderSizePixel = 0
state.lagBtn.Text = "LAG SWITCH"
state.lagBtn.TextColor3 = Color3.fromRGB(255,255,255)
state.lagBtn.TextSize = 13
state.lagBtn.Font = Enum.Font.GothamBold
state.lagBtn.AutoButtonColor = true
state.lagBtn.Parent = frame
local lagCorner = Instance.new("UICorner")
lagCorner.CornerRadius = UDim.new(0, 8)
lagCorner.Parent = state.lagBtn

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1,0,0,18)
footer.Position = UDim2.new(0,0,0,220)
footer.BackgroundTransparency = 1
footer.Text = "Drag anywhere to move • ⚡ toggles UI"
footer.TextColor3 = Color3.fromRGB(130, 140, 160)
footer.TextSize = 10
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0, 6)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(170, 180, 200)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = true
closeBtn.Parent = frame

-- ========== SLIDER DRAG ==========
local sliderDragging = false
local function updateSlider(input)
    if not sliderDragging then return end
    local pos = input.Position.X
    local sliderX = sliderBg.AbsolutePosition.X
    local sliderW = sliderBg.AbsoluteSize.X
    local percent = math.clamp((pos - sliderX) / sliderW, 0, 1)
    local value = 0.5 + percent * 2.5
    value = math.round(value * 10) / 10
    state.delay = math.clamp(value, 0.5, 3.0)
    state.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    state.sliderKnob.Position = UDim2.new(percent, -9, 0.5, -9)
    state.sliderLabel.Text = string.format("%.1f", state.delay) .. "s"
    delayLabel.Text = "Delay: " .. string.format("%.1f", state.delay) .. "s"
end

state.sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- ========== DRAG FRAME ==========
local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local x,y = input.Position.X, input.Position.Y
        local absX,absY = frame.AbsolutePosition.X, frame.AbsolutePosition.Y
        local relX,relY = x - absX, y - absY
        if relY > 160 and relY < 205 and relX > 15 and relX < 145 then return end
        if relY > 160 and relY < 205 and relX > 175 and relX < 305 then return end
        if relY > 80 and relY < 140 and relX > 30 and relX < 290 then return end
        if relY > 3 and relY < 36 and relX > 10 and relX < 290 then return end
        state.isDragging = true
        state.dragStart = input.Position
        state.frameStart = frame.Position
    end
end
local function moveDrag(input)
    if state.isDragging then
        local delta = input.Position - state.dragStart
        frame.Position = UDim2.new(state.frameStart.X.Scale, state.frameStart.X.Offset + delta.X, state.frameStart.Y.Scale, state.frameStart.Y.Offset + delta.Y)
    end
end
local function endDrag() state.isDragging = false end
title.InputBegan:Connect(startDrag)
title.InputChanged:Connect(moveDrag)
title.InputEnded:Connect(endDrag)
frame.InputBegan:Connect(startDrag)
frame.InputChanged:Connect(moveDrag)
frame.InputEnded:Connect(endDrag)

-- ========== BUTTON FUNCTIONS ==========
local debounce = false

local function toggleDesync()
    if debounce then return end
    debounce = true
    state.active = not state.active
    if state.active then
        state.statusText.Text = "● Desync: ON"
        state.statusText.TextColor3 = Color3.fromRGB(120, 255, 120)
        state.desyncBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        state.border.BackgroundTransparency = 0.3
        TweenService:Create(state.border, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = 0.3
        }):Play()
        state.history = {}
    else
        state.statusText.Text = "● Desync: OFF"
        state.statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
        state.desyncBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
        state.border.BackgroundTransparency = 0.75
        TweenService:Create(state.border, TweenInfo.new(0.3), { BackgroundTransparency = 0.75 }):Play()
        state.lagSwitchPaused = false
    end
    task.wait(0.2)
    debounce = false
end

local function triggerLagSwitch()
    if debounce then return end
    if state.lagSwitchPaused then
        state.lagStatus.Text = "● Lag Switch: COOLDOWN"
        state.lagStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    if not state.active then
        state.lagStatus.Text = "● Lag Switch: Desync OFF"
        state.lagStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    if tick() - state.lagSwitchCooldown < LAG_SWITCH_COOLDOWN then
        state.lagStatus.Text = "● Lag Switch: COOLDOWN"
        state.lagStatus.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    debounce = true
    state.lagSwitchPaused = true
    state.lagSwitchCooldown = tick()
    state.lagStatus.Text = "● Lag Switch: ACTIVE"
    state.lagStatus.TextColor3 = Color3.fromRGB(255, 150, 150)
    state.lagBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    task.spawn(function()
        wait(LAG_SWITCH_DURATION)
        state.lagSwitchPaused = false
        state.lagStatus.Text = "● Lag Switch: READY"
        state.lagStatus.TextColor3 = Color3.fromRGB(120, 255, 120)
        state.lagBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        debounce = false
    end)
end

state.desyncBtn.MouseButton1Click:Connect(toggleDesync)
state.desyncBtn.TouchTap:Connect(toggleDesync)
state.lagBtn.MouseButton1Click:Connect(triggerLagSwitch)
state.lagBtn.TouchTap:Connect(triggerLagSwitch)
closeBtn.MouseButton1Click:Connect(function() setUIVisible(false) end)
closeBtn.TouchTap:Connect(function() setUIVisible(false) end)

createUIToggleButton()

-- ========== MAIN LOOP ==========
RunService.Heartbeat:Connect(function(delta)
    if state.active then
        recordPosition()
        state.lastUpdate = state.lastUpdate + delta
        if state.lastUpdate >= UPDATE_INTERVAL then
            state.lastUpdate = 0
            applyDesync()
        end
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
                mt.__index = function(t,k)
                    if k == "Value" then return 250 + math.random(0,80) end
                    return rawget(t,k)
                end
                setrawmetatable(ping, mt)
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    state.history = {}
    state.lagSwitchPaused = false
    state.lagSwitchCooldown = 0
end)

print("=== FINAL DESYNC + LAG SWITCH LOADED ===")
print("Desync applies delayed CFrame and velocity every 0.05s, holds for 0.1s.")
print("Test with a second account. If still not working, the technique is patched.")
