-- Polyfills
if not math.clamp then math.clamp = function(v, min, max) if v < min then return min end if v > max then return max end return v end end
if not spawn then spawn = function(f) coroutine.wrap(f)() end end
if not delay then delay = function(t, f) spawn(function() wait(t) f() end) end end

print("=== JHub Mobile Pill ===")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local C = workspace.CurrentCamera

-- Wait for PlayerGui (up to 10s)
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

-- ===== Main Frame (PILL SHAPE: CornerRadius = half height) =====
local M = Instance.new("Frame")
M.Size = UDim2.new(0, 280, 0, 280)   -- width = height to keep proportions, but actually pill needs width > height, but with radius 140 it becomes a circle if width=height. To keep pill shape, height 280, radius 140, so left/right edges will be perfect semicircles, top/bottom straight – still a pill because width 280, the corners will merge and the top/bottom edges will be points? Actually with radius = half height and width > height, the shape becomes a capsule. Here width=280, height=280, radius=140 makes a perfect circle. Let's change to width 300, height 280 to be pill-like. I'll adjust M.Size to UDim2.new(0, 300, 0, 280) and CornerRadius = UDim.new(0, 140). That will make the left/right sides fully rounded, top/bottom straight, resulting in a pill shape.
M.Size = UDim2.new(0, 300, 0, 280)
M.Position = UDim2.new(0.5, -150, 0.5, -140)
M.BackgroundColor3 = BG_DARK
M.BackgroundTransparency = 0.05
M.Active = true
M.Draggable = false   -- we'll handle drag manually for smoothness
M.Visible = true
M.BorderSizePixel = 0
M.ClipsDescendants = true
M.Parent = UI

-- Pill shape: radius half of height (140)
Instance.new("UICorner").CornerRadius = UDim.new(0, 140) Parent = M
local stroke = Instance.new("UIStroke") stroke.Color = ACCENT stroke.Thickness = 1 stroke.Parent = M
local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 10) pad.PaddingRight = UDim.new(0, 10) pad.PaddingTop = UDim.new(0, 10) pad.PaddingBottom = UDim.new(0, 10) pad.Parent = M

-- Smooth custom drag for main frame
local mainDragging = false
local mainDragStart, mainFrameStart
M.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
  mainDragging = true
  mainDragStart = input.Position
  mainFrameStart = M.Position
 end
end)
M.InputChanged:Connect(function(input)
 if mainDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
  local delta = input.Position - mainDragStart
  local vs = C.ViewportSize
  -- Clamp with 10px margin from edges
  local newX = math.clamp(mainFrameStart.X.Offset + delta.X, 10, vs.X - M.AbsoluteSize.X - 10)
  local newY = math.clamp(mainFrameStart.Y.Offset + delta.Y, 10, vs.Y - M.AbsoluteSize.Y - 10)
  M.Position = UDim2.new(0, newX, 0, newY)
 end
end)
M.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
  mainDragging = false
 end
end)

-- Hide button (pill, smooth drag)
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 70, 0, 30)
hideBtn.Position = UDim2.new(1, -85, 0, 10)
hideBtn.Text = "HIDE"
hideBtn.TextColor3 = TEXT_PRIMARY
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 12
hideBtn.BackgroundColor3 = BG_DARK
hideBtn.Visible = true
hideBtn.AutoButtonColor = false
hideBtn.BorderSizePixel = 0
hideBtn.Parent = UI

-- Pill shape for hide button (radius half height)
Instance.new("UICorner").CornerRadius = UDim.new(0, 15) Parent = hideBtn
local hStroke = Instance.new("UIStroke") hStroke.Color = ACCENT hStroke.Thickness = 1 hStroke.Parent = hideBtn
local hideDragging = false
local hideDragStart, hideFrameStart

hideBtn.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
  hideDragging = true
  hideDragStart = input.Position
  hideFrameStart = hideBtn.Position
 end
end)
hideBtn.InputChanged:Connect(function(input)
 if hideDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
  local delta = input.Position - hideDragStart
  local vs = C.ViewportSize
  local newX = math.clamp(hideFrameStart.X.Offset + delta.X, 0, vs.X - hideBtn.AbsoluteSize.X)
  local newY = math.clamp(hideFrameStart.Y.Offset + delta.Y, 0, vs.Y - hideBtn.AbsoluteSize.Y)
  hideBtn.Position = UDim2.new(0, newX, 0, newY)
 end
end)
hideBtn.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
  hideDragging = false
 end
end)
C:GetPropertyChangedSignal("ViewportSize"):Connect(function()
 local vs = C.ViewportSize
 hideBtn.Position = UDim2.new(0, math.clamp(hideBtn.AbsolutePosition.X, 0, vs.X - hideBtn.AbsoluteSize.X), 0, math.clamp(hideBtn.AbsolutePosition.Y, 0, vs.Y - hideBtn.AbsoluteSize.Y))
end)
hideBtn.MouseButton1Click:Connect(function()
 M.Visible = not M.Visible
 hideBtn.Text = M.Visible and "HIDE" or "SHOW"
end)

-- ===== Helpers (tap‑only toggles, pill‑shaped toggle buttons) =====
local function CreateReliableToggle(parent, labelText, callback)
 local row = Instance.new("Frame")
 row.Size = UDim2.new(1, 0, 0, 34)
 row.BackgroundColor3 = BG_PANEL
 row.BorderSizePixel = 0
 row.Parent = parent
 Instance.new("UICorner").CornerRadius = UDim.new(0, 17) Parent = row   -- fully rounded row

 local label = Instance.new("TextLabel")
 label.Size = UDim2.new(1, -80, 1, 0)
 label.Position = UDim2.new(0, 12, 0, 0)
 label.Text = labelText
 label.TextColor3 = TEXT_SECONDARY
 label.TextSize = 12
 label.Font = Enum.Font.GothamMedium
 label.TextXAlignment = Enum.TextXAlignment.Left
 label.BackgroundTransparency = 1
 label.Parent = row

 local btn = Instance.new("TextButton")
 btn.Size = UDim2.new(0, 50, 0, 22)
 btn.Position = UDim2.new(1, -60, 0.5, -11)
 btn.Text = "OFF"
 btn.Font = Enum.Font.GothamBold
 btn.TextSize = 10
 btn.BackgroundColor3 = BG_BUTTON
 btn.TextColor3 = TEXT_DIM
 btn.AutoButtonColor = false
 btn.BorderSizePixel = 0
 btn.Parent = row
 Instance.new("UICorner").CornerRadius = UDim.new(0, 11) Parent = btn   -- pill toggle

 local enabled = false
 local debounce = false

 local function toggle()
  if debounce then return end
  debounce = true
  enabled = not enabled
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
  callback(enabled)
  wait(0.3)
  debounce = false
 end

 -- Only tap (no slide)
 btn.MouseButton1Click:Connect(toggle)
 btn.TouchTap:Connect(toggle)

 return {
  toggle = toggle,
  setEnabled = function(v) if enabled ~= v then toggle() end end,
  getEnabled = function() return enabled end
 }
end

local function CreateSliderWithInput(parent, labelText, min, max, default, desc, callback)
 local row = Instance.new("Frame")
 row.Size = UDim2.new(1, 0, 0, 50)
 row.BackgroundColor3 = BG_PANEL
 row.BorderSizePixel = 0
 row.Parent = parent
 Instance.new("UICorner").CornerRadius = UDim.new(0, 17) Parent = row

 local label = Instance.new("TextLabel")
 label.Size = UDim2.new(0.6, 0, 0, 20)
 label.Position = UDim2.new(0, 12, 0, 2)
 label.BackgroundTransparency = 1
 label.Text = labelText
 label.TextColor3 = TEXT_SECONDARY
 label.TextSize = 12
 label.Font = Enum.Font.GothamMedium
 label.TextXAlignment = Enum.TextXAlignment.Left
 label.Parent = row

 local valueLabel = Instance.new("TextLabel")
 valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
 valueLabel.Position = UDim2.new(0.7, 0, 0, 2)
 valueLabel.BackgroundTransparency = 1
 valueLabel.Text = string.format("%.2f", default) .. "s"
 valueLabel.TextColor3 = TEXT_PRIMARY
 valueLabel.TextSize = 12
 valueLabel.Font = Enum.Font.GothamBold
 valueLabel.TextXAlignment = Enum.TextXAlignment.Right
 valueLabel.Parent = row

 local descLabel = Instance.new("TextLabel")
 descLabel.Size = UDim2.new(1, 0, 0, 14)
 descLabel.Position = UDim2.new(0, 12, 0, 22)
 descLabel.BackgroundTransparency = 1
 descLabel.Text = desc or ""
 descLabel.TextColor3 = TEXT_DIM
 descLabel.TextSize = 10
 descLabel.Font = Enum.Font.Gotham
 descLabel.TextXAlignment = Enum.TextXAlignment.Left
 descLabel.Parent = row

 local sliderBg = Instance.new("Frame")
 sliderBg.Size = UDim2.new(0, 130, 0, 6)
 sliderBg.Position = UDim2.new(0, 12, 0, 38)
 sliderBg.BackgroundColor3 = BG_BUTTON
 sliderBg.BorderSizePixel = 0
 sliderBg.Parent = row
 Instance.new("UICorner").CornerRadius = UDim.new(0, 3) Parent = sliderBg

 local fill = Instance.new("Frame")
 fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
 fill.BackgroundColor3 = ACCENT
 fill.BorderSizePixel = 0
 fill.Parent = sliderBg
 Instance.new("UICorner").CornerRadius = UDim.new(0, 3) Parent = fill

 local knob = Instance.new("TextButton")
 knob.Size = UDim2.new(0, 14, 0, 14)
 knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
 knob.BackgroundColor3 = TEXT_PRIMARY
 knob.BorderSizePixel = 0
 knob.Text = ""
 knob.Parent = sliderBg
 Instance.new("UICorner").CornerRadius = UDim.new(1, 0) Parent = knob

 local input = Instance.new("TextBox")
 input.Size = UDim2.new(0, 50, 0, 20)
 input.Position = UDim2.new(1, -62, 0, 36)
 input.BackgroundColor3 = BG_BUTTON
 input.BorderSizePixel = 0
 input.Text = string.format("%.2f", default)
 input.TextColor3 = TEXT_PRIMARY
 input.TextSize = 12
 input.Font = Enum.Font.GothamBold
 input.TextXAlignment = Enum.TextXAlignment.Center
 input.ClearTextOnFocus = false
 input.Parent = row
 Instance.new("UICorner").CornerRadius = UDim.new(0, 4) Parent = input

 local currentVal = default
 local dragging = false

 local function updateUI(val)
  val = math.clamp(val, min, max)
  val = math.floor(val * 100 + 0.5) / 100
  currentVal = val
  local percent = (val - min) / (max - min)
  fill.Size = UDim2.new(percent, 0, 1, 0)
  knob.Position = UDim2.new(percent, -7, 0.5, -7)
  valueLabel.Text = string.format("%.2f", val) .. "s"
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

 return { getValue = function() return currentVal end, setValue = updateUI }
end

-- ===== LEFT TAB SYSTEM =====
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 65, 1, 0)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = M

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -73, 1, 0)
contentArea.Position = UDim2.new(0, 73, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.BorderSizePixel = 0
contentArea.Parent = M

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
contentLayout.Parent = contentArea

local currentTab = nil
local tabButtons = {}

local function clearContent()
 for _, child in ipairs(contentArea:GetChildren()) do
  if child ~= contentLayout then child:Destroy() end
 end
end

-- ===== PERSISTENT RANKED LOOP (global, fixed 3s delay) =====
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

-- ===== BUILD TABS =====
local function buildCharacterTab()
 clearContent()

 -- 1. Kazana Jump
 local boostEnabled = false
 local BOOST_AMOUNT = 1.0
 local SPEED_MULTIPLIER = 1.15
 local boostConnection = nil
 local originalWalkSpeed = 16
 local speedLoopConnection = nil
 local stateConnection = nil
 local currentHumanoid = nil

 local function applySpeedBasedOnState(humanoid)
  if not humanoid then return end
  if not boostEnabled then humanoid.WalkSpeed = originalWalkSpeed return end
  local state = humanoid:GetState()
  if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Sprinting then
   humanoid.WalkSpeed = originalWalkSpeed * SPEED_MULTIPLIER
  else
   humanoid.WalkSpeed = originalWalkSpeed
  end
 end

 local function onStateChanged() applySpeedBasedOnState(currentHumanoid) end

 local function setupSpeedLogic(character)
  if not character then return end
  local hum = character:FindFirstChildOfClass("Humanoid")
  if not hum then return end
  currentHumanoid = hum
  if originalWalkSpeed == 16 then originalWalkSpeed = hum.WalkSpeed end
  if stateConnection then stateConnection:Disconnect() end
  if speedLoopConnection then speedLoopConnection:Disconnect() end
  stateConnection = hum.StateChanged:Connect(onStateChanged)
  speedLoopConnection = RunService.Heartbeat:Connect(function()
   if hum and hum.Parent then applySpeedBasedOnState(hum) end
  end)
  applySpeedBasedOnState(hum)
 end

 local function applyBoostJump(character)
  if not character then return end
  local hum = character:FindFirstChildOfClass("Humanoid")
  if not hum then return end
  if boostConnection then boostConnection:Disconnect() end
  if boostEnabled then
   boostConnection = hum.Jumping:Connect(function()
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
     root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(0, BOOST_AMOUNT, 0)
     if hum.JumpPower < 60 then hum.JumpPower = 55 end
    end
   end)
  end
 end

 local function applyBoostFull(character)
  setupSpeedLogic(character)
  applyBoostJump(character)
 end

 CreateReliableToggle(contentArea, "Kazana Jump", function(v)
  boostEnabled = v
  local char = LP.Character
  if char then applyBoostFull(char) end
 end)

 LP.CharacterAdded:Connect(function(ch)
  wait(0.2)
  if boostEnabled then
   applyBoostFull(ch)
  else
   if stateConnection then stateConnection:Disconnect() stateConnection = nil end
   if speedLoopConnection then speedLoopConnection:Disconnect() speedLoopConnection = nil end
   if boostConnection then boostConnection:Disconnect() boostConnection = nil end
   local hum = ch:FindFirstChildOfClass("Humanoid")
   if hum then hum.WalkSpeed = originalWalkSpeed end
  end
 end)

 wait(0.3)
 local char = LP.Character
 if char then
  if boostEnabled then applyBoostFull(char)
  else
   local hum = char:FindFirstChildOfClass("Humanoid")
   if hum and originalWalkSpeed ~= 16 then hum.WalkSpeed = originalWalkSpeed end
  end
 end

 -- 2. Auto Shiftlock
 local shiftlockEnabled = false
 local shiftlockDirection = nil
 local shiftlockJumping = false
 local shiftlockTimer = nil

 CreateReliableToggle(contentArea, "Auto Shiftlock", function(v)
  shiftlockEnabled = v
  if not v then
   shiftlockJumping = false
   shiftlockDirection = nil
   if shiftlockTimer then
    pcall(function() shiftlockTimer:Disconnect() end)
    shiftlockTimer = nil
   end
  end
 end)

 local function setupShiftlock(character)
  local hum = character:WaitForChild("Humanoid")
  hum.Jumping:Connect(function()
   if not shiftlockEnabled then return end
   if shiftlockTimer then
    pcall(function() shiftlockTimer:Disconnect() end)
    shiftlockTimer = nil
   end
   local look = C.CFrame.LookVector
   shiftlockDirection = Vector3.new(look.X, 0, look.Z).Unit
   shiftlockJumping = true
   shiftlockTimer = delay(0.4, function()
    shiftlockJumping = false
    shiftlockDirection = nil
   end)
  end)
  hum.StateChanged:Connect(function(_, newState)
   if newState == Enum.HumanoidStateType.Landed then
    shiftlockJumping = false
    shiftlockDirection = nil
    if shiftlockTimer then
     pcall(function() shiftlockTimer:Disconnect() end)
     shiftlockTimer = nil
    end
   end
  end)
 end

 if LP.Character then setupShiftlock(LP.Character) end
 LP.CharacterAdded:Connect(setupShiftlock)

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

 -- 3. Direction Facing ESP
 local espEnabled = false
 local espBeams = {}

 CreateReliableToggle(contentArea, "Direction Facing ESP", function(v)
  espEnabled = v
  if not v then
   for _, data in pairs(espBeams) do
    pcall(function() data.Beam:Destroy() data.A0:Destroy() data.A1:Destroy() end)
   end
   table.clear(espBeams)
  end
 end)

 local function isEnemy(p)
  if p == LP then return true end
  if LP.Team and p.Team and LP.Team == p.Team then return true end
  return false
 end

 RunService.RenderStepped:Connect(function()
  if not espEnabled then return end
  for _, p in ipairs(Players:GetPlayers()) do
   if isEnemy(p) then continue end
   local char = p.Character
   if not char then continue end
   local hum = char:FindFirstChildOfClass("Humanoid")
   if not hum or hum.Health <= 0 then continue end
   local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
   if not torso then continue end
   local data = espBeams[p]
   if not data then
    local a0 = Instance.new("Attachment", workspace.Terrain)
    local a1 = Instance.new("Attachment", workspace.Terrain)
    local beam = Instance.new("Beam", workspace.Terrain)
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

 -- 4. Anti-Lag
 local antiLagEnabled = false
 local OriginalStates = {}
 local SavedSkybox, SavedAtmosphere, SavedLightingTech, SavedGlobalShadows = nil, nil, nil, nil
 local SavedQualityLevel = nil

 local function IsESPDown(obj)
  for _, entry in pairs(espBeams) do if entry.Beam == obj then return true end end
  return false
 end

 local function SaveOriginalState(obj)
  if OriginalStates[obj] then return end
  local state = {}
  if obj:IsA("BasePart") then
   state.Material = obj.Material
   state.Color = obj.Color
   state.Reflectance = obj.Reflectance
   if obj:IsA("MeshPart") then state.TextureID = obj.TextureID end
  elseif obj:IsA("Texture") or obj:IsA("Decal") then
   state.Texture = obj.Texture
   state.Transparency = obj.Transparency
  elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
   state.Enabled = obj.Enabled
  elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
   state.Enabled = obj.Enabled
   state.Brightness = obj.Brightness
  end
  if next(state) then OriginalStates[obj] = state end
 end

 local function ApplyAntiLag()
  local lighting = game:GetService("Lighting")
  local sky = lighting:FindFirstChildOfClass("Sky")
  if sky and not SavedSkybox then SavedSkybox = sky:Clone() sky.Parent = nil end
  local atm = lighting:FindFirstChildOfClass("Atmosphere")
  if atm and not SavedAtmosphere then SavedAtmosphere = atm:Clone() atm.Parent = nil end
  for _, cloud in ipairs(lighting:GetChildren()) do
   if cloud:IsA("Clouds") then pcall(function() cloud.Parent = nil end) end
  end
  for _, effect in ipairs(lighting:GetChildren()) do
   if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
    pcall(function() effect.Enabled = false end)
   end
  end
  pcall(function()
   if not SavedLightingTech then SavedLightingTech = lighting.Technology SavedGlobalShadows = lighting.GlobalShadows end
   lighting.GlobalShadows = false
  end)
  pcall(function()
   if settings() and settings().Rendering then
    if not SavedQualityLevel then SavedQualityLevel = settings().Rendering.QualityLevel end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level05
   end
  end)
  for _, obj in ipairs(workspace:GetDescendants()) do
   pcall(function()
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
     SaveOriginalState(obj)
     obj.Enabled = false
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
     SaveOriginalState(obj)
     obj.Enabled = false
    end
   end)
  end
  pcall(function()
   local terrain = workspace:FindFirstChildOfClass("Terrain")
   if terrain then terrain.WaterWaveSize = 0 terrain.WaterWaveSpeed = 0 terrain.WaterTransparency = 0.5 end
  end)
 end

 local function RestoreOriginal()
  local lighting = game:GetService("Lighting")
  if SavedSkybox then pcall(function() SavedSkybox.Parent = lighting end) SavedSkybox = nil end
  if SavedAtmosphere then pcall(function() SavedAtmosphere.Parent = lighting end) SavedAtmosphere = nil end
  pcall(function()
   if SavedLightingTech then lighting.Technology = SavedLightingTech end
   if SavedGlobalShadows ~= nil then lighting.GlobalShadows = SavedGlobalShadows end
  end)
  pcall(function()
   if settings() and settings().Rendering and SavedQualityLevel then settings().Rendering.QualityLevel = SavedQualityLevel end
  end)
  for obj, state in pairs(OriginalStates) do
   pcall(function()
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
     if state.Enabled ~= nil then obj.Enabled = state.Enabled end
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
     if state.Enabled ~= nil then obj.Enabled = state.Enabled end
     if state.Brightness then obj.Brightness = state.Brightness end
    end
   end)
  end
  pcall(function()
   local terrain = workspace:FindFirstChildOfClass("Terrain")
   if terrain then terrain.WaterWaveSize = 0.15 terrain.WaterWaveSpeed = 10 terrain.WaterTransparency = 0.3 end
  end)
  OriginalStates = {}
 end

 CreateReliableToggle(contentArea, "Anti-Lag", function(v)
  antiLagEnabled = v
  if v then ApplyAntiLag() else RestoreOriginal() end
 end)

 workspace.DescendantAdded:Connect(function(obj)
  if not antiLagEnabled then return end
  wait(0.1)
  pcall(function()
   if obj:IsA("Beam") and IsESPDown(obj) then return end
   if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
    SaveOriginalState(obj)
    obj.Enabled = false
   elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
    SaveOriginalState(obj)
    obj.Enabled = false
   end
  end)
 end)

 -- ===== 5. Async Desync =====
 local asyncDesyncEnabled = false
 local asyncConnection = nil
 local ASYNC_COOLDOWN = 0.3
 local lastTriggerTime = 0
 local MIN_INTERVAL = 0.5
 local BANDWIDTH_LOW = 1

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

 CreateReliableToggle(contentArea, "Async Desync", function(v)
  asyncDesyncEnabled = v
  local char = LP.Character
  if char then
   if v then setupAsyncDesync(char) else
    if asyncConnection then asyncConnection:Disconnect() asyncConnection = nil end
    applyDesync(false)
   end
  end
 end)

 CreateSliderWithInput(
  contentArea,
  "Desync Duration",
  0.05,
  1.0,
  0.3,
  "Time bandwidth is low",
  function(val)
   ASYNC_COOLDOWN = val
  end
 )

 LP.CharacterAdded:Connect(function(ch)
  wait(0.2)
  if asyncDesyncEnabled then setupAsyncDesync(ch) else
   if asyncConnection then asyncConnection:Disconnect() asyncConnection = nil end
  end
 end)

 wait(0.3)
 local initialChar = LP.Character
 if initialChar and asyncDesyncEnabled then setupAsyncDesync(initialChar) end
end

local function buildAutomationTab()
 clearContent()

 -- Inf Style, Yen, Ability toggles
 CreateReliableToggle(contentArea, "Inf Style", function(v)
  rankedEnabled.style = v
  updateRankedLoop()
  if v then fireRankedReward(1) end
 end)

 CreateReliableToggle(contentArea, "Inf Yen", function(v)
  rankedEnabled.yen = v
  updateRankedLoop()
  if v then fireRankedReward(2) end
 end)

 CreateReliableToggle(contentArea, "Inf Ability", function(v)
  rankedEnabled.ability = v
  updateRankedLoop()
  if v then fireRankedReward(4) end
 end)
end

-- Tab switching
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
 if tabName == "Character" then buildCharacterTab()
 elseif tabName == "Automation" then buildAutomationTab() end
end

-- Left tab buttons (pill-shaped)
local tabsOrder = {"Character", "Automation"}
for i, tabName in ipairs(tabsOrder) do
 local btn = Instance.new("TextButton")
 btn.Size = UDim2.new(1, -8, 0, 30)
 btn.Position = UDim2.new(0, 4, 0, 8 + (i-1) * 38)
 btn.Text = tabName
 btn.Font = Enum.Font.GothamBold
 btn.TextSize = 12
 btn.BackgroundColor3 = i == 1 and ACCENT or BG_BUTTON
 btn.TextColor3 = i == 1 and TEXT_PRIMARY or TEXT_DIM
 btn.AutoButtonColor = false
 btn.BorderSizePixel = 0
 btn.Parent = tabContainer
 Instance.new("UICorner").CornerRadius = UDim.new(0, 15) Parent = btn   -- pill
 tabButtons[tabName] = btn
 btn.MouseButton1Click:Connect(function() switchTab(tabName) end)
end

switchTab("Character")
print("JHub Pill ready.")
