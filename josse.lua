-- Polyfills
if not math.clamp then math.clamp = function(v, min, max) if v < min then return min end if v > max then return max end return v end end
if not spawn then spawn = function(f) coroutine.wrap(f)() end end
if not delay then delay = function(t, f) spawn(function() wait(t) f() end) end end

print("=== JHub Mobile Pill ===")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local C = workspace.CurrentCamera

-- Wait for PlayerGui (done instantly)
local PG = LP:FindFirstChild("PlayerGui")
if not PG then for i = 1, 100 do wait(0.1) PG = LP:FindFirstChild("PlayerGui") if PG then break end end end
if not PG then warn("PlayerGui not found") return end
if PG:FindFirstChild("JHub") then PG.JHub:Destroy() end

local UI = Instance.new("ScreenGui")
UI.Name = "JHub"
UI.ResetOnSpawn = false
UI.Parent = PG

-- Colors
local ACCENT = Color3.fromRGB(235, 35, 75)
local BG_DARK = Color3.fromRGB(14, 14, 18)
local BG_PANEL = Color3.fromRGB(22, 22, 28)
local BG_BUTTON = Color3.fromRGB(35, 35, 42)
local BG_BUTTON_ON = Color3.fromRGB(235, 35, 75)
local TEXT_PRIMARY = Color3.fromRGB(255, 255, 255)
local TEXT_SECONDARY = Color3.fromRGB(210, 210, 215)
local TEXT_DIM = Color3.fromRGB(140, 140, 145)
local WARNING_BG = Color3.fromRGB(70, 50, 20)
local WARNING_TEXT = Color3.fromRGB(255, 220, 150)

-- ===== Persistent state variables =====
local boostEnabled = false
local shiftlockEnabled = false
local espEnabled = false
local antiLagEnabled = false
local asyncDesyncEnabled = false
local desyncDuration = 0.3          -- Always resets to 0.3
local ASYNC_COOLDOWN = 0.3

-- ===== HITBOX EXTENDER STATE =====
local hitboxEnabled = false
local hitboxSize = 2.5              -- Always resets to 2.5
local hitboxBallAddedConnection = nil

-- ===== CONFIG FILE =====
local configPath = "JHubConfig.json"

local function saveConfig()
    -- Still saves the current values if the user changes them during the session
    local config = {
        hitboxSize = hitboxSize,
        desyncDuration = desyncDuration,
    }
    local json = HttpService:JSONEncode(config)
    pcall(function() writefile(configPath, json) end)
    print("Config saved")
end

local function loadConfig()
    -- We no longer load hitboxSize or desyncDuration so they always start at the defaults above
    if not isfile(configPath) then
        print("No config file found, using defaults")
        return
    end
    print("Config file exists but slider defaults are forced (0.3 / 2.5)")
end

-- ===== HITBOX EXTENDER FUNCTIONS =====
local function findFirstPart(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
    end
    return nil
end

local function updateHitboxes(scale)
    if not hitboxEnabled then return end
    local count = 0
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
            local ball = model:FindFirstChild("Ball.001")
            if not ball then
                local basePart = findFirstPart(model)
                if basePart then
                    ball = Instance.new("Part")
                    ball.Name = "Ball.001"
                    ball.Shape = Enum.PartType.Ball
                    ball.Size = Vector3.new(2, 2, 2) * scale
                    ball.CFrame = basePart.CFrame
                    ball.Anchored = true
                    ball.CanCollide = false
                    ball.Transparency = 0.7
                    ball.Material = Enum.Material.ForceField
                    ball.Color = Color3.fromRGB(255, 50, 50)
                    ball.Parent = model
                end
            else
                ball.Size = Vector3.new(2, 2, 2) * scale
            end
            count = count + 1
            if count % 50 == 0 then task.wait() end
        end
    end
end

local function removeHitboxes()
    local count = 0
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
            local ball = model:FindFirstChild("Ball.001")
            if ball then ball:Destroy() end
            count = count + 1
            if count % 50 == 0 then task.wait() end
        end
    end
end

local function toggleHitboxExtender(enable)
    hitboxEnabled = enable
    task.spawn(function()
        if enable then
            if not hitboxBallAddedConnection then
                hitboxBallAddedConnection = Workspace.ChildAdded:Connect(function(child)
                    if child:IsA("Model") and child.Name:match("^CLIENT_BALL_%d+$") then
                        task.wait(0.1)
                        if hitboxEnabled then updateHitboxes(hitboxSize) end
                    end
                end)
            end
            updateHitboxes(hitboxSize)
        else
            if hitboxBallAddedConnection then
                hitboxBallAddedConnection:Disconnect()
                hitboxBallAddedConnection = nil
            end
            removeHitboxes()
        end
        saveConfig()
    end)
end

-- ===== Main Frame =====
local M = Instance.new("Frame")
M.Size = UDim2.new(0, 320, 0, 280)
M.Position = UDim2.new(0.5, -160, 0.5, -140)
M.BackgroundColor3 = BG_DARK
M.BackgroundTransparency = 0.05
M.Active = true
M.Draggable = false
M.Visible = true
M.BorderSizePixel = 0
M.ClipsDescendants = true
M.Parent = UI

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = M

local stroke = Instance.new("UIStroke")
stroke.Color = ACCENT
stroke.Thickness = 1
stroke.Parent = M

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent = M

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 180, 0, 20)
title.Position = UDim2.new(0, 6, 0, 3)
title.Text = "JOSSEPOPSIER"
title.TextColor3 = TEXT_PRIMARY
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = M

-- ===== 100% RELIABLE DRAG SYSTEM (Delta-based) =====
local dragging = false
local dragStartPos, mainFrameStartPos

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position
        local abs = M.AbsolutePosition
        local size = M.AbsoluteSize
        if pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y then
            dragging = true
            dragStartPos = pos
            mainFrameStartPos = M.Position
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        local vs = C.ViewportSize
        local size = M.AbsoluteSize
        M.Position = UDim2.new(
            0, math.clamp(mainFrameStartPos.X.Offset + delta.X, 0, vs.X - size.X),
            0, math.clamp(mainFrameStartPos.Y.Offset + delta.Y, 0, vs.Y - size.Y)
        )
    end
end)
-- ===== END RELIABLE DRAG SYSTEM =====

-- Hide button
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 64, 0, 26)
hideBtn.Position = UDim2.new(1, -74, 0, 4)
hideBtn.Text = "HIDE"
hideBtn.TextColor3 = TEXT_PRIMARY
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 10
hideBtn.BackgroundColor3 = BG_DARK
hideBtn.Visible = true
hideBtn.AutoButtonColor = false
hideBtn.BorderSizePixel = 0
hideBtn.Parent = UI

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 13)
hideCorner.Parent = hideBtn
local hStroke = Instance.new("UIStroke")
hStroke.Color = ACCENT
hStroke.Thickness = 1
hStroke.Parent = hideBtn

-- ===== HIDE BUTTON DRAG =====
local hideDragging = false
local hideDragStartPos, hideBtnStartPos

hideBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        hideDragging = true
        hideDragStartPos = input.Position
        hideBtnStartPos = hideBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                hideDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if hideDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - hideDragStartPos
        local vs = C.ViewportSize
        local size = hideBtn.AbsoluteSize
        hideBtn.Position = UDim2.new(
            0, math.clamp(hideBtnStartPos.X.Offset + delta.X, 0, vs.X - size.X),
            0, math.clamp(hideBtnStartPos.Y.Offset + delta.Y, 0, vs.Y - size.Y)
        )
    end
end)
-- ===== END HIDE BUTTON FIX =====

C:GetPropertyChangedSignal("ViewportSize"):Connect(function()
 local vs = C.ViewportSize
 hideBtn.Position = UDim2.new(0, math.clamp(hideBtn.AbsolutePosition.X, 0, vs.X - hideBtn.AbsoluteSize.X), 0, math.clamp(hideBtn.AbsolutePosition.Y, 0, vs.Y - hideBtn.AbsoluteSize.Y))
end)
hideBtn.MouseButton1Click:Connect(function()
 M.Visible = not M.Visible
 hideBtn.Text = M.Visible and "HIDE" or "SHOW"
end)

-- ===== Left Tab System =====
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 68, 1, -36)
tabContainer.Position = UDim2.new(0, 0, 0, 28)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = M

local contentArea = Instance.new("ScrollingFrame")
contentArea.Size = UDim2.new(1, -84, 1, -36)
contentArea.Position = UDim2.new(0, 76, 0, 28)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentArea.ScrollBarThickness = 6
contentArea.ScrollBarImageColor3 = ACCENT
contentArea.Parent = M

local contentPad = Instance.new("UIPadding")
contentPad.PaddingRight = UDim.new(0, 8)
contentPad.Parent = contentArea

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 4)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentArea

contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentArea.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
end)

local currentTab = nil
local tabButtons = {}

local function clearContent()
 for _, child in ipairs(contentArea:GetChildren()) do
  if child ~= contentLayout and child ~= contentPad then child:Destroy() end
 end
 contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
end

local function switchTab(tabName)
 if currentTab == tabName then return end
 currentTab = tabName
 for name, btn in pairs(tabButtons) do
  if name == tabName then
   btn.BackgroundColor3 = ACCENT
   btn.TextColor3 = TEXT_PRIMARY
  else
   btn.BackgroundColor3 = BG_BUTTON
   btn.TextColor3 = TEXT_DIM
  end
 end
 clearContent()
 if tabName == "Character" then buildCharacterTab()
 elseif tabName == "Automation" then buildAutomationTab() end
end

local tabsOrder = {"Character", "Automation"}
for i, tabName in ipairs(tabsOrder) do
 local btn = Instance.new("TextButton")
 btn.Size = UDim2.new(1, -8, 0, 32)
 btn.Position = UDim2.new(0, 4, 0, 6 + (i-1) * 38)
 btn.Text = tabName
 btn.Font = Enum.Font.GothamBold
 btn.TextSize = 10
 btn.BackgroundColor3 = i == 1 and ACCENT or BG_BUTTON
 btn.TextColor3 = i == 1 and TEXT_PRIMARY or TEXT_DIM
 btn.AutoButtonColor = false
 btn.BorderSizePixel = 0
 btn.Parent = tabContainer
 local cornerBtn = Instance.new("UICorner")
 cornerBtn.CornerRadius = UDim.new(0, 16)
 cornerBtn.Parent = btn
 local btnStroke = Instance.new("UIStroke")
 btnStroke.Color = i == 1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(60,60,70)
 btnStroke.Thickness = 0.5
 btnStroke.Transparency = 0.3
 btnStroke.Parent = btn
 tabButtons[tabName] = btn
 btn.MouseButton1Click:Connect(function() switchTab(tabName) end)
end

-- ===== Helper: Reliable Toggle =====
local function CreateReliableToggle(parent, labelText, initialState, callback)
 local row = Instance.new("Frame")
 row.Size = UDim2.new(1, 0, 0, 26)
 row.BackgroundColor3 = BG_PANEL
 row.BorderSizePixel = 0
 row.Parent = parent
 Instance.new("UICorner").CornerRadius = UDim.new(0, 10) Parent = row

 local label = Instance.new("TextLabel")
 label.Size = UDim2.new(1, -74, 1, 0)
 label.Position = UDim2.new(0, 8, 0, 0)
 label.Text = labelText
 label.TextColor3 = TEXT_SECONDARY
 label.TextSize = 11
 label.Font = Enum.Font.GothamMedium
 label.TextXAlignment = Enum.TextXAlignment.Left
 label.BackgroundTransparency = 1
 label.Parent = row

 local btn = Instance.new("TextButton")
 btn.Size = UDim2.new(0, 44, 0, 18)
 btn.Position = UDim2.new(1, -52, 0.5, -9)
 btn.Font = Enum.Font.GothamBold
 btn.TextSize = 9
 btn.BackgroundColor3 = BG_BUTTON
 btn.TextColor3 = TEXT_DIM
 btn.AutoButtonColor = false
 btn.BorderSizePixel = 0
 btn.Parent = row
 Instance.new("UICorner").CornerRadius = UDim.new(0, 9) Parent = btn

 local enabled = (initialState == true)
 local debounce = false

 local function updateUI()
  if enabled then
   btn.Text = "ON"
   btn.BackgroundColor3 = BG_BUTTON_ON
   btn.TextColor3 = TEXT_PRIMARY
   label.TextColor3 = TEXT_PRIMARY
  else
   btn.Text = "OFF"
   btn.BackgroundColor3 = BG_BUTTON
   btn.TextColor3 = TEXT_DIM
   label.TextColor3 = TEXT_SECONDARY
  end
 end
 updateUI()

 local function toggle()
  if debounce then return end
  debounce = true
  enabled = not enabled
  updateUI()
  callback(enabled)
  delay(0.1, function() debounce = false end)
 end

 btn.MouseButton1Click:Connect(toggle)
 btn.TouchTap:Connect(toggle)

 return {
  toggle = toggle,
  setEnabled = function(v)
   v = (v == true)
   if enabled ~= v then
    enabled = v
    updateUI()
    callback(enabled)
   end
  end,
  getEnabled = function() return enabled end
 }
end

-- ===== Helper: Slider =====
local function CreateSliderWithInput(parent, labelText, min, max, default, desc, callback, unit)
 unit = unit or "s"
 local row = Instance.new("Frame")
 row.Size = UDim2.new(1, 0, 0, 72)
 row.BackgroundColor3 = BG_PANEL
 row.BorderSizePixel = 0
 row.Parent = parent
 Instance.new("UICorner").CornerRadius = UDim.new(0, 10) Parent = row

 local label = Instance.new("TextLabel")
 label.Size = UDim2.new(0.5, 0, 0, 18)
 label.Position = UDim2.new(0, 8, 0, 2)
 label.BackgroundTransparency = 1
 label.Text = labelText
 label.TextColor3 = TEXT_SECONDARY
 label.TextSize = 12
 label.Font = Enum.Font.GothamMedium
 label.TextXAlignment = Enum.TextXAlignment.Left
 label.Parent = row

 local valueLabel = Instance.new("TextLabel")
 valueLabel.Size = UDim2.new(0, 50, 0, 18)
 valueLabel.Position = UDim2.new(1, -8, 0, 2)
 valueLabel.BackgroundTransparency = 1
 valueLabel.Text = string.format("%.2f", default) .. unit
 valueLabel.TextColor3 = TEXT_PRIMARY
 valueLabel.TextSize = 12
 valueLabel.Font = Enum.Font.GothamBold
 valueLabel.TextXAlignment = Enum.TextXAlignment.Right
 valueLabel.Parent = row

 local descLabel = Instance.new("TextLabel")
 descLabel.Size = UDim2.new(1, 0, 0, 14)
 descLabel.Position = UDim2.new(0, 8, 0, 22)
 descLabel.BackgroundTransparency = 1
 descLabel.Text = desc or ""
 descLabel.TextColor3 = TEXT_DIM
 descLabel.TextSize = 10
 descLabel.Font = Enum.Font.Gotham
 descLabel.TextXAlignment = Enum.TextXAlignment.Left
 descLabel.Parent = row

 local sliderBg = Instance.new("Frame")
 sliderBg.Size = UDim2.new(0, 120, 0, 12)
 sliderBg.Position = UDim2.new(0, 8, 0, 44)
 sliderBg.BackgroundColor3 = BG_BUTTON
 sliderBg.BorderSizePixel = 0
 sliderBg.Parent = row
 Instance.new("UICorner").CornerRadius = UDim.new(0, 6) Parent = sliderBg

 local fill = Instance.new("Frame")
 fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
 fill.BackgroundColor3 = ACCENT
 fill.BorderSizePixel = 0
 fill.Parent = sliderBg
 Instance.new("UICorner").CornerRadius = UDim.new(0, 6) Parent = fill

 local knob = Instance.new("TextButton")
 knob.Size = UDim2.new(0, 26, 0, 26)
 knob.Position = UDim2.new((default - min) / (max - min), -13, 0.5, -13)
 knob.BackgroundColor3 = ACCENT
 knob.BorderSizePixel = 0
 knob.Text = ""
 knob.Parent = sliderBg
 local knobCorner = Instance.new("UICorner")
 knobCorner.CornerRadius = UDim.new(1, 0)
 knobCorner.Parent = knob
 local gradient = Instance.new("UIGradient")
 gradient.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, ACCENT),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 120))
 })
 gradient.Rotation = 45
 gradient.Parent = knob
 local knobStroke = Instance.new("UIStroke")
 knobStroke.Color = Color3.fromRGB(255, 255, 255)
 knobStroke.Thickness = 2
 knobStroke.Transparency = 0.2
 knobStroke.Parent = knob

 local input = Instance.new("TextBox")
 input.Size = UDim2.new(0, 44, 0, 22)
 input.Position = UDim2.new(1, -52, 0, 40)
 input.BackgroundColor3 = BG_BUTTON
 input.BorderSizePixel = 0
 input.Text = string.format("%.2f", default)
 input.TextColor3 = TEXT_PRIMARY
 input.TextSize = 12
 input.Font = Enum.Font.GothamBold
 input.TextXAlignment = Enum.TextXAlignment.Center
 input.ClearTextOnFocus = false
 input.Parent = row
 Instance.new("UICorner").CornerRadius = UDim.new(0, 5) Parent = input

 local currentVal = default
 local dragging = false

 local function updateUI(val)
  val = math.clamp(val, min, max)
  val = math.floor(val * 100 + 0.5) / 100
  currentVal = val
  local percent = (val - min) / (max - min)
  fill.Size = UDim2.new(percent, 0, 1, 0)
  knob.Position = UDim2.new(percent, -13, 0.5, -13)
  valueLabel.Text = string.format("%.2f", val) .. unit
  input.Text = string.format("%.2f", val)
  callback(val)
 end

 knob.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
   dragging = true
   local pos = input.Position
   local sliderX = sliderBg.AbsolutePosition.X
   local sliderW = sliderBg.AbsoluteSize.X
   local percent = math.clamp((pos.X - sliderX) / sliderW, 0, 1)
   updateUI(min + percent * (max - min))
  end
 end)

 UserInputService.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
   dragging = false
  end
 end)

 UserInputService.InputChanged:Connect(function(input)
  if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
   local pos = input.Position
   local sliderX = sliderBg.AbsolutePosition.X
   local sliderW = sliderBg.AbsoluteSize.X
   local percent = math.clamp((pos.X - sliderX) / sliderW, 0, 1)
   updateUI(min + percent * (max - min))
  end
 end)

 input.FocusLost:Connect(function()
  local val = tonumber(input.Text)
  if val then updateUI(val) else input.Text = string.format("%.2f", currentVal) end
 end)

 return {
  getValue = function() return currentVal end,
  setValue = updateUI,
  row = row
 }
end

-- ===== Global functions =====
local boostConnection = nil
local speedLoopConnection = nil
local stateConnection = nil
local originalWalkSpeed = 16
local currentHumanoid = nil

local shiftlockJumpConnection = nil
local shiftlockStateConnection = nil
local shiftlockTimer = nil
local shiftlockDirection = nil
local shiftlockJumping = false

local espBeams = {}
local OriginalStates = {}
local asyncConnection = nil
local lastTriggerTime = 0
local MIN_INTERVAL = 0.5
local BANDWIDTH_LOW = 1

local function applyBoostJump(character)
 if not character then return end
 local hum = character:FindFirstChildOfClass("Humanoid")
 if not hum then return end
 if boostConnection then boostConnection:Disconnect() end
 if boostEnabled then
  boostConnection = hum.Jumping:Connect(function()
   local root = character:FindFirstChild("HumanoidRootPart")
   if root then
    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(0, 1.0, 0)
    if hum.JumpPower < 60 then hum.JumpPower = 55 end
   end
  end)
 end
end

local function applyBoostFull(character)
 applyBoostJump(character)
end

local function setupShiftlock(character)
 if not character then return end
 local hum = character:FindFirstChildOfClass("Humanoid")
 if not hum then return end
 if shiftlockJumpConnection then shiftlockJumpConnection:Disconnect() shiftlockJumpConnection = nil end
 if shiftlockStateConnection then shiftlockStateConnection:Disconnect() shiftlockStateConnection = nil end
 if shiftlockTimer then pcall(function() shiftlockTimer:Disconnect() end) shiftlockTimer = nil end

 shiftlockJumpConnection = hum.Jumping:Connect(function()
  if not shiftlockEnabled then return end
  if shiftlockTimer then pcall(function() shiftlockTimer:Disconnect() end) shiftlockTimer = nil end
  local look = C.CFrame.LookVector
  shiftlockDirection = Vector3.new(look.X, 0, look.Z).Unit
  shiftlockJumping = true
  shiftlockTimer = delay(0.4, function()
   shiftlockJumping = false
   shiftlockDirection = nil
  end)
 end)

 shiftlockStateConnection = hum.StateChanged:Connect(function(_, newState)
  if newState == Enum.HumanoidStateType.Landed then
   shiftlockJumping = false
   shiftlockDirection = nil
   if shiftlockTimer then pcall(function() shiftlockTimer:Disconnect() end) shiftlockTimer = nil end
  end
 end)
end

local function cleanupShiftlock()
 if shiftlockJumpConnection then shiftlockJumpConnection:Disconnect() shiftlockJumpConnection = nil end
 if shiftlockStateConnection then shiftlockStateConnection:Disconnect() shiftlockStateConnection = nil end
 if shiftlockTimer then pcall(function() shiftlockTimer:Disconnect() end) shiftlockTimer = nil end
 shiftlockDirection = nil
 shiftlockJumping = false
end

local function IsESPDown(obj)
 for _, entry in pairs(espBeams) do if entry.Beam == obj then return true end end
 return false
end

-- ===== SMARTER ANTI-LAG =====
local function SaveOriginalState(obj)
 if OriginalStates[obj] then return end
 local state = {}
 if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
  state.Rate = obj.Rate
  state.Lifetime = obj.Lifetime
  state.Enabled = obj.Enabled
 elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
  state.Enabled = obj.Enabled
 elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
  state.Enabled = obj.Enabled
  state.Brightness = obj.Brightness
 elseif obj:IsA("DepthOfFieldEffect") then
  state.Enabled = obj.Enabled
 end
 if next(state) then OriginalStates[obj] = state end
end

local function ApplyAntiLag()
 local lighting = game:GetService("Lighting")

 for _, effect in ipairs(lighting:GetChildren()) do
  if effect:IsA("DepthOfFieldEffect") then
   SaveOriginalState(effect)
   effect.Enabled = false
  end
 end

 for _, obj in ipairs(Workspace:GetDescendants()) do
  pcall(function()
   if obj:IsA("Fire") or obj:IsA("Smoke") then
    SaveOriginalState(obj)
    obj.Enabled = false
   elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
    SaveOriginalState(obj)
    if obj:IsA("ParticleEmitter") then
     obj.Rate = math.max(obj.Rate * 0.25, 1)
     if obj.Lifetime and typeof(obj.Lifetime) == "NumberRange" then
      obj.Lifetime = NumberRange.new(obj.Lifetime.Min * 0.6, obj.Lifetime.Max * 0.6)
     end
    elseif obj:IsA("Trail") then
     obj.Lifetime = obj.Lifetime * 0.5
    end
   elseif obj:IsA("Sparkles") then
    SaveOriginalState(obj)
    obj.Enabled = false
   elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
    SaveOriginalState(obj)
    obj.Brightness = obj.Brightness * 0.35
   end
  end)
 end

 pcall(function()
  local terrain = Workspace:FindFirstChildOfClass("Terrain")
  if terrain then
   terrain.WaterWaveSize = 0.08
   terrain.WaterWaveSpeed = 6
  end
 end)
end

local function RestoreOriginal()
 for obj, state in pairs(OriginalStates) do
  pcall(function()
   if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
    if state.Rate then obj.Rate = state.Rate end
    if state.Lifetime then obj.Lifetime = state.Lifetime end
    if state.Enabled ~= nil then obj.Enabled = state.Enabled end
   elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
    if state.Enabled ~= nil then obj.Enabled = state.Enabled end
   elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
    if state.Enabled ~= nil then obj.Enabled = state.Enabled end
    if state.Brightness then obj.Brightness = state.Brightness end
   elseif obj:IsA("DepthOfFieldEffect") then
    if state.Enabled ~= nil then obj.Enabled = state.Enabled end
   end
  end)
 end

 pcall(function()
  local terrain = Workspace:FindFirstChildOfClass("Terrain")
  if terrain then
   terrain.WaterWaveSize = 0.15
   terrain.WaterWaveSpeed = 10
  end
 end)

 OriginalStates = {}
end

local function applyDesync(state)
 local bandwidth = state and tostring(BANDWIDTH_LOW) or "999999"
 pcall(function()
  setfflag("PhysicsSenderMaxBandwidthBps", bandwidth)
 end)
end

local function onJump(isActive)
 if not asyncDesyncEnabled then return end
 if not isActive then return end
 local now = tick()
 if now - lastTriggerTime < MIN_INTERVAL then return end
 lastTriggerTime = now
 applyDesync(true)
 wait(ASYNC_COOLDOWN)
 applyDesync(false)
end

local function setupAsyncDesync(char)
 if asyncConnection then asyncConnection:Disconnect() end
 local hum = char:FindFirstChildOfClass("Humanoid")
 if hum then
  asyncConnection = hum.Jumping:Connect(onJump)
 end
end

-- ===== Ranked loop variables =====
local rankedEnabled = { style = false, yen = false, ability = false }
local rankedLoopActive = false
local RANKED_FIXED_DELAY = 3.0

local function fireRankedReward(arg)
 local remote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("SeasonService"):WaitForChild("RF"):WaitForChild("RequestRankedReward")
 pcall(function() remote:InvokeServer(arg) end)
end

local function rankedStealthLoop()
 while rankedLoopActive do
  local anyActive = rankedEnabled.style or rankedEnabled.yen or rankedEnabled.ability
  if not anyActive then
   wait(0.5)
  else
   for _, info in ipairs({{name="style", arg=1}, {name="yen", arg=2}, {name="ability", arg=4}}) do
    if rankedLoopActive and rankedEnabled[info.name] then
     fireRankedReward(info.arg)
     local delay = RANKED_FIXED_DELAY + (math.random() * 2 - 1) * 0.8
     if math.random() < 0.1 then delay = delay + math.random() * 0.7 end
     wait(delay)
    end
   end
  end
 end
end

local function updateRankedLoop()
 local anyOn = rankedEnabled.style or rankedEnabled.yen or rankedEnabled.ability
 if anyOn and not rankedLoopActive then
  rankedLoopActive = true
  coroutine.wrap(rankedStealthLoop)()
 end
end

-- ===== Build Tabs =====
function buildCharacterTab()
    CreateReliableToggle(contentArea, "Kazana Jump", boostEnabled, function(v)
        boostEnabled = v
        local char = LP.Character
        if char then
            if boostEnabled then 
                applyBoostFull(char)
            else
                if boostConnection then boostConnection:Disconnect() boostConnection = nil end
            end
        end
        saveConfig()
    end)

    CreateReliableToggle(contentArea, "Auto Shiftlock", shiftlockEnabled, function(v)
        shiftlockEnabled = v
        if v then
            local char = LP.Character
            if char then setupShiftlock(char) end
        else
            cleanupShiftlock()
        end
        saveConfig()
    end)

    CreateReliableToggle(contentArea, "Direction Facing ESP", espEnabled, function(v)
        espEnabled = v
        if not v then
            for _, data in pairs(espBeams) do
                pcall(function() data.Beam:Destroy() data.A0:Destroy() data.A1:Destroy() end)
            end
            table.clear(espBeams)
        end
        saveConfig()
    end)

    CreateReliableToggle(contentArea, "Anti-Lag", antiLagEnabled, function(v)
        antiLagEnabled = v
        if v then ApplyAntiLag() else RestoreOriginal() end
        saveConfig()
    end)

    local sliderRow = nil
    CreateReliableToggle(contentArea, "Async Desync", asyncDesyncEnabled, function(v)
        asyncDesyncEnabled = v
        local char = LP.Character
        if char then
            if v then setupAsyncDesync(char) else
                if asyncConnection then asyncConnection:Disconnect() asyncConnection = nil end
                applyDesync(false)
            end
        end
        if sliderRow then sliderRow.Visible = v end
        saveConfig()
    end)

    local slider = CreateSliderWithInput(
        contentArea,
        "Desync Duration",
        0.05, 1.0, desyncDuration,
        "Time bandwidth is low",
        function(val)
            desyncDuration = val
            ASYNC_COOLDOWN = val
            saveConfig()
        end,
        "s"
    )
    sliderRow = slider.row
    sliderRow.Visible = asyncDesyncEnabled

    CreateReliableToggle(contentArea, "Hitbox Extender", hitboxEnabled, function(v)
        toggleHitboxExtender(v)
    end)

    CreateSliderWithInput(
        contentArea,
        "Hitbox Size (radius)",
        1, 20, hitboxSize,
        "Visual radius of the overlay",
        function(val)
            hitboxSize = val
            if hitboxEnabled then updateHitboxes(hitboxSize) end
            saveConfig()
        end,
        ""
    )

    task.spawn(function()
        local char = LP.Character
        if char then
            if boostEnabled then applyBoostFull(char) end
            if shiftlockEnabled then setupShiftlock(char) end
            if asyncDesyncEnabled then setupAsyncDesync(char) end
            if hitboxEnabled then toggleHitboxExtender(true) end
            if hitboxSize > 0 and hitboxEnabled then updateHitboxes(hitboxSize) end
        end
    end)
end

function buildAutomationTab()
    local warn1 = Instance.new("Frame")
    warn1.Size = UDim2.new(1, 0, 0, 26)
    warn1.BackgroundColor3 = WARNING_BG
    warn1.BorderSizePixel = 0
    warn1.Parent = contentArea
    local wc1 = Instance.new("UICorner")
    wc1.CornerRadius = UDim.new(0, 8)
    wc1.Parent = warn1
    local ws1 = Instance.new("UIStroke")
    ws1.Color = Color3.fromRGB(180, 140, 80)
    ws1.Thickness = 1.5
    ws1.Transparency = 0.5
    ws1.Parent = warn1
    local l1 = Instance.new("TextLabel")
    l1.Size = UDim2.new(1, 0, 1, 0)
    l1.BackgroundTransparency = 1
    l1.Text = "⚠ Only one Inf toggle can be ON at a time."
    l1.TextColor3 = WARNING_TEXT
    l1.TextSize = 11
    l1.Font = Enum.Font.GothamBold
    l1.TextWrapped = true
    l1.TextXAlignment = Enum.TextXAlignment.Center
    l1.Parent = warn1

    local warn2 = Instance.new("Frame")
    warn2.Size = UDim2.new(1, 0, 0, 26)
    warn2.BackgroundColor3 = WARNING_BG
    warn2.BorderSizePixel = 0
    warn2.Parent = contentArea
    local wc2 = Instance.new("UICorner")
    wc2.CornerRadius = UDim.new(0, 8)
    wc2.Parent = warn2
    local ws2 = Instance.new("UIStroke")
    ws2.Color = Color3.fromRGB(180, 140, 80)
    ws2.Thickness = 1.5
    ws2.Transparency = 0.5
    ws2.Parent = warn2
    local l2 = Instance.new("TextLabel")
    l2.Size = UDim2.new(1, 0, 1, 0)
    l2.BackgroundTransparency = 1
    l2.Text = "⚠ Do not exceed 400 lucky spins per session to avoid ban."
    l2.TextColor3 = WARNING_TEXT
    l2.TextSize = 11
    l2.Font = Enum.Font.GothamBold
    l2.TextWrapped = true
    l2.TextXAlignment = Enum.TextXAlignment.Center
    l2.Parent = warn2

    local styleToggle = CreateReliableToggle(contentArea, "Inf Lucky Style Spins", rankedEnabled.style, function(v)
        rankedEnabled.style = v
        updateRankedLoop()
        if v then fireRankedReward(1) end
        saveConfig()
    end)
    styleToggle:setEnabled(rankedEnabled.style)

    local yenToggle = CreateReliableToggle(contentArea, "Inf Yen", rankedEnabled.yen, function(v)
        rankedEnabled.yen = v
        updateRankedLoop()
        if v then fireRankedReward(2) end
        saveConfig()
    end)
    yenToggle:setEnabled(rankedEnabled.yen)

    local abilityToggle = CreateReliableToggle(contentArea, "Inf Lucky Ability Spins", rankedEnabled.ability, function(v)
        rankedEnabled.ability = v
        updateRankedLoop()
        if v then fireRankedReward(4) end
        saveConfig()
    end)
    abilityToggle:setEnabled(rankedEnabled.ability)
end

-- ===== CharacterAdded connections =====
LP.CharacterAdded:Connect(function(ch)
 wait(0.2)
 if boostEnabled then applyBoostFull(ch) end
 if shiftlockEnabled then setupShiftlock(ch) end
 if asyncDesyncEnabled then setupAsyncDesync(ch) end
 if hitboxEnabled then updateHitboxes(hitboxSize) end
end)

-- Shiftlock render loop
RunService.RenderStepped:Connect(function()
 if not shiftlockEnabled or not shiftlockJumping or not shiftlockDirection then return end
 local char = LP.Character
 if not char then return end
 local root = char:FindFirstChild("HumanoidRootPart")
 local hum = char:FindFirstChildOfClass("Humanoid")
 if not root or not hum or hum.Health <= 0 then return end
 if not UserInputService.TouchEnabled then
  UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
 end
 root.CFrame = CFrame.new(root.Position, root.Position + shiftlockDirection)
 hum.CameraOffset = hum.CameraOffset:LinearInterpolate(Vector3.new(2.5, 2, 0), 0.2)
end)

-- ESP render loop
RunService.RenderStepped:Connect(function()
 if not espEnabled then return end
 for _, p in ipairs(Players:GetPlayers()) do
  if p == LP then continue end
  if LP.Team and p.Team and LP.Team == p.Team then continue end
  local char = p.Character
  if not char then continue end
  local hum = char:FindFirstChildOfClass("Humanoid")
  if not hum or hum.Health <= 0 then continue end
  local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
  if not torso then continue end
  local data = espBeams[p]
  if not data then
   local a0 = Instance.new("Attachment", Workspace.Terrain)
   local a1 = Instance.new("Attachment", Workspace.Terrain)
   local beam = Instance.new("Beam", Workspace.Terrain)
   beam.Attachment0 = a0
   beam.Attachment1 = a1
   beam.Width0 = 0.35
   beam.Width1 = 0.35
   beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
   beam.FaceCamera = true
   beam.LightEmission = 0.3
   beam.LightInfluence = 0
   beam.ZOffset = 2
   beam.Transparency = NumberSequence.new(0)
   data = { Beam = beam, A0 = a0, A1 = a1 }
   espBeams[p] = data
  end
  local look = torso.CFrame.LookVector
  local dir = Vector3.new(look.X, 0, look.Z).Unit
  if dir.Magnitude < 0.001 then dir = Vector3.new(0, 0, -1) end
  data.A0.WorldPosition = torso.Position + (dir * 0.6)
  data.A1.WorldPosition = torso.Position + (dir * 55)
 end
 for p, data in pairs(espBeams) do
  if not p.Parent then
   pcall(function() data.Beam:Destroy() data.A0:Destroy() data.A1:Destroy() end)
   espBeams[p] = nil
  end
 end
end)

Players.PlayerRemoving:Connect(function(p)
 if espBeams[p] then
  pcall(function() espBeams[p].Beam:Destroy() espBeams[p].A0:Destroy() espBeams[p].A1:Destroy() end)
  espBeams[p] = nil
 end
end)

-- Anti-lag new objects (smarter version)
Workspace.DescendantAdded:Connect(function(obj)
 if not antiLagEnabled then return end
 task.wait(0.1)
 pcall(function()
  if obj:IsA("Beam") and IsESPDown(obj) then return end
  if obj:IsA("Fire") or obj:IsA("Smoke") then
   SaveOriginalState(obj)
   obj.Enabled = false
  elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
   SaveOriginalState(obj)
   if obj:IsA("ParticleEmitter") then
    obj.Rate = math.max(obj.Rate * 0.25, 1)
    if obj.Lifetime and typeof(obj.Lifetime) == "NumberRange" then
     obj.Lifetime = NumberRange.new(obj.Lifetime.Min * 0.6, obj.Lifetime.Max * 0.6)
    end
   elseif obj:IsA("Trail") then
    obj.Lifetime = obj.Lifetime * 0.5
   end
  elseif obj:IsA("Sparkles") then
   SaveOriginalState(obj)
   obj.Enabled = false
  elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
   SaveOriginalState(obj)
   obj.Brightness = obj.Brightness * 0.35
  elseif obj:IsA("DepthOfFieldEffect") then
   SaveOriginalState(obj)
   obj.Enabled = false
  end
 end)
end)

-- ===== INSTANT LOAD INITIALIZATION =====
task.spawn(function()
    loadConfig()
    switchTab("Character")
    print("JHub Pill ready - Desync default 0.3 | Hitbox default 2.5")
end)
