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

local PG = LP:FindFirstChild("PlayerGui")
if not PG then for i = 1, 100 do wait(0.1) PG = LP:FindFirstChild("PlayerGui") if PG then break end end end
if not PG then warn("PlayerGui not found") return end
if PG:FindFirstChild("JHub") then PG.JHub:Destroy() end

local UI = Instance.new("ScreenGui")
UI.Name = "JHub"
UI.ResetOnSpawn = false
UI.Parent = PG

-- Colors
local ACCENT       = Color3.fromRGB(225, 55, 85)
local BG_MAIN      = Color3.fromRGB(16, 16, 20)
local BG_PANEL     = Color3.fromRGB(24, 24, 30)
local BG_ELEMENT   = Color3.fromRGB(32, 32, 40)
local TEXT_MAIN    = Color3.fromRGB(245, 245, 250)
local TEXT_SECOND  = Color3.fromRGB(180, 180, 190)
local TEXT_DIM     = Color3.fromRGB(120, 120, 130)
local STROKE       = Color3.fromRGB(50, 50, 60)

-- State
local boostEnabled = false
local shiftlockEnabled = false
local espEnabled = false
local antiLagEnabled = false
local asyncDesyncEnabled = false
local desyncDuration = 0.3
local ASYNC_COOLDOWN = 0.3
local hitboxEnabled = false
local hitboxSize = 5
local hitboxBallAddedConnection = nil

local configPath = "JHubConfig.json"

local function saveConfig()
	pcall(function()
		writefile(configPath, HttpService:JSONEncode({
			hitboxSize = hitboxSize,
			desyncDuration = desyncDuration
		}))
	end)
end

local function loadConfig()
	print("Defaults forced: Desync 0.3 | Hitbox 5")
end

-- Hitbox
local function findFirstPart(model)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then return d end
	end
end

local function updateHitboxes(scale)
	if not hitboxEnabled then return end
	local count = 0
	for _, model in ipairs(Workspace:GetChildren()) do
		if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
			local ball = model:FindFirstChild("Ball.001")
			if not ball then
				local base = findFirstPart(model)
				if base then
					ball = Instance.new("Part")
					ball.Name = "Ball.001"
					ball.Shape = Enum.PartType.Ball
					ball.Size = Vector3.new(2, 2, 2) * scale
					ball.CFrame = base.CFrame
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
			count += 1
			if count % 50 == 0 then task.wait() end
		end
	end
end

local function removeHitboxes()
	for _, model in ipairs(Workspace:GetChildren()) do
		if model:IsA("Model") and model.Name:match("^CLIENT_BALL_%d+$") then
			local ball = model:FindFirstChild("Ball.001")
			if ball then ball:Destroy() end
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

-- Main Window
local M = Instance.new("Frame")
M.Size = UDim2.new(0, 360, 0, 320)
M.Position = UDim2.new(0.5, -180, 0.5, -160)
M.BackgroundColor3 = BG_MAIN
M.BorderSizePixel = 0
M.Active = true
M.Parent = UI

Instance.new("UICorner", M).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", M)
stroke.Color = STROKE
stroke.Thickness = 1

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 24)
title.Position = UDim2.new(0, 14, 0, 8)
title.BackgroundTransparency = 1
title.Text = "JOSSEPOPSIER"
title.TextColor3 = TEXT_MAIN
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = M

-- Drag
local dragging, dragStart, startPos
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local pos = input.Position
		local abs = M.AbsolutePosition
		local size = M.AbsoluteSize
		if pos.X >= abs.X and pos.X <= abs.X + size.X and pos.Y >= abs.Y and pos.Y <= abs.Y + size.Y then
			dragging = true
			dragStart = pos
			startPos = M.AbsolutePosition
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
		local delta = input.Position - dragStart
		local vs = C.ViewportSize
		local size = M.AbsoluteSize
		M.Position = UDim2.new(0, math.clamp(startPos.X + delta.X, 0, vs.X - size.X), 0, math.clamp(startPos.Y + delta.Y, 0, vs.Y - size.Y))
	end
end)

-- Hide Button
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 58, 0, 24)
hideBtn.Position = UDim2.new(1, -70, 0, 8)
hideBtn.BackgroundColor3 = BG_ELEMENT
hideBtn.Text = "HIDE"
hideBtn.TextColor3 = TEXT_MAIN
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 11
hideBtn.AutoButtonColor = false
hideBtn.Parent = UI
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 7)
Instance.new("UIStroke", hideBtn).Color = STROKE

local hideDragging, hideDragStart, hideStartPos
hideBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		hideDragging = true
		hideDragStart = input.Position
		hideStartPos = hideBtn.AbsolutePosition
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if hideDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - hideDragStart
		local vs = C.ViewportSize
		local size = hideBtn.AbsoluteSize
		hideBtn.Position = UDim2.new(0, math.clamp(hideStartPos.X + delta.X, 0, vs.X - size.X), 0, math.clamp(hideStartPos.Y + delta.Y, 0, vs.Y - size.Y))
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		hideDragging = false
	end
end)

hideBtn.MouseButton1Click:Connect(function()
	M.Visible = not M.Visible
	hideBtn.Text = M.Visible and "HIDE" or "SHOW"
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 88, 1, -44)
sidebar.Position = UDim2.new(0, 10, 0, 38)
sidebar.BackgroundColor3 = BG_PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = M
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -112, 1, -50)
content.Position = UDim2.new(0, 106, 0, 42)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = ACCENT
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = M

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 7)
list.Parent = content

local currentTab = nil
local tabButtons = {}

local function clearContent()
	for _, c in ipairs(content:GetChildren()) do
		if not c:IsA("UIListLayout") then c:Destroy() end
	end
end

local function switchTab(name)
	if currentTab == name then return end
	currentTab = name
	for n, btn in pairs(tabButtons) do
		btn.BackgroundColor3 = (n == name) and ACCENT or BG_ELEMENT
		btn.TextColor3 = (n == name) and TEXT_MAIN or TEXT_DIM
	end
	clearContent()
	if name == "Character" then buildCharacterTab()
	elseif name == "Desync" then buildDesyncTab()
	elseif name == "Hitbox" then buildHitboxTab()
	elseif name == "Auto" then buildAutomationTab() end
end

local tabs = {
	{id = "Character", label = "Character"},
	{id = "Desync", label = "Desync"},
	{id = "Hitbox", label = "Hitbox"},
	{id = "Auto", label = "Auto"}
}

for i, t in ipairs(tabs) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 34)
	btn.Position = UDim2.new(0, 6, 0, 8 + (i-1)*40)
	btn.BackgroundColor3 = i == 1 and ACCENT or BG_ELEMENT
	btn.Text = t.label
	btn.TextColor3 = i == 1 and TEXT_MAIN or TEXT_DIM
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.AutoButtonColor = false
	btn.Parent = sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	tabButtons[t.id] = btn
	btn.MouseButton1Click:Connect(function() switchTab(t.id) end)
end

-- Helpers
local function CreateToggle(parent, text, state, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 34)
	row.BackgroundColor3 = BG_PANEL
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -68, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TEXT_SECOND
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 48, 0, 22)
	btn.Position = UDim2.new(1, -56, 0.5, -11)
	btn.BackgroundColor3 = BG_ELEMENT
	btn.Text = "OFF"
	btn.TextColor3 = TEXT_DIM
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.AutoButtonColor = false
	btn.Parent = row
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local enabled = state
	local function update()
		btn.Text = enabled and "ON" or "OFF"
		btn.BackgroundColor3 = enabled and ACCENT or BG_ELEMENT
		btn.TextColor3 = enabled and TEXT_MAIN or TEXT_DIM
		label.TextColor3 = enabled and TEXT_MAIN or TEXT_SECOND
	end
	update()

	btn.MouseButton1Click:Connect(function()
		enabled = not enabled
		update()
		callback(enabled)
	end)
end

local function CreateSlider(parent, text, min, max, default, callback, unit)
	unit = unit or ""
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 78)
	row.BackgroundColor3 = BG_PANEL
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.55, 0, 0, 18)
	label.Position = UDim2.new(0, 12, 0, 6)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TEXT_SECOND
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(0, 50, 0, 18)
	valueLbl.Position = UDim2.new(1, -62, 0, 6)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = string.format("%.2f%s", default, unit)
	valueLbl.TextColor3 = TEXT_MAIN
	valueLbl.Font = Enum.Font.GothamBold
	valueLbl.TextSize = 13
	valueLbl.TextXAlignment = Enum.TextXAlignment.Right
	valueLbl.Parent = row

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, -24, 0, 6)
	bar.Position = UDim2.new(0, 12, 0, 36)
	bar.BackgroundColor3 = BG_ELEMENT
	bar.Parent = row
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
	fill.BackgroundColor3 = ACCENT
	fill.Parent = bar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
	knob.BackgroundColor3 = TEXT_MAIN
	knob.Text = ""
	knob.Parent = bar
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local input = Instance.new("TextBox")
	input.Size = UDim2.new(0, 52, 0, 22)
	input.Position = UDim2.new(1, -64, 0, 48)
	input.BackgroundColor3 = BG_ELEMENT
	input.Text = string.format("%.2f", default)
	input.TextColor3 = TEXT_MAIN
	input.Font = Enum.Font.GothamBold
	input.TextSize = 12
	input.TextXAlignment = Enum.TextXAlignment.Center
	input.ClearTextOnFocus = false
	input.Parent = row
	Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

	local currentVal = default
	local dragging = false

	local function set(val)
		val = math.clamp(val, min, max)
		val = math.floor(val * 100 + 0.5) / 100
		currentVal = val
		local pct = (val - min) / (max - min)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		knob.Position = UDim2.new(pct, -8, 0.5, -8)
		valueLbl.Text = string.format("%.2f%s", val, unit)
		input.Text = string.format("%.2f", val)
		callback(val)
	end

	knob.InputBegan:Connect(function(inputObj)
		if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(inputObj)
		if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(inputObj)
		if dragging and (inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch) then
			local pct = math.clamp((inputObj.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			set(min + pct * (max - min))
		end
	end)

	input.FocusLost:Connect(function()
		local num = tonumber(input.Text)
		if num then set(num) else input.Text = string.format("%.2f", currentVal) end
	end)
end

-- ===== VISUAL ONLY SHIFTLOCK (Blue on jump, default on land) =====
local shiftlockButtons = {} -- store original colors
local BLUE_COLOR = Color3.fromRGB(0, 162, 255) -- typical Roblox shiftlock blue

local function findShiftlockButtons()
	shiftlockButtons = {}
	for _, obj in ipairs(LP.PlayerGui:GetDescendants()) do
		if obj:IsA("ImageButton") or obj:IsA("TextButton") then
			local name = string.lower(obj.Name)
			if name:find("shift") or name:find("lock") or name:find("mouse") or name:find("cameralock") then
				-- Store original colors
				shiftlockButtons[obj] = {
					ImageColor3 = obj.ImageColor3,
					BackgroundColor3 = obj.BackgroundColor3,
					Image = obj:IsA("ImageButton") and obj.Image or nil
				}
			end
		end
	end
end

local function setShiftlockVisual(active)
	for btn, original in pairs(shiftlockButtons) do
		if btn and btn.Parent then
			if active then
				-- Turn blue
				if btn:IsA("ImageButton") then
					btn.ImageColor3 = BLUE_COLOR
				end
				btn.BackgroundColor3 = BLUE_COLOR
			else
				-- Restore original
				if btn:IsA("ImageButton") and original.ImageColor3 then
					btn.ImageColor3 = original.ImageColor3
				end
				if original.BackgroundColor3 then
					btn.BackgroundColor3 = original.BackgroundColor3
				end
			end
		end
	end
end

local boostConnection
local shiftlockJumpConnection
local shiftlockStateConnection

local function applyBoostJump(char)
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	if boostConnection then boostConnection:Disconnect() end
	if boostEnabled then
		boostConnection = hum.Jumping:Connect(function()
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(0, 1, 0)
				if hum.JumpPower < 60 then hum.JumpPower = 55 end
			end
		end)
	end
end

local function setupShiftlock(char)
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if shiftlockJumpConnection then shiftlockJumpConnection:Disconnect() end
	if shiftlockStateConnection then shiftlockStateConnection:Disconnect() end

	-- Find the buttons once
	findShiftlockButtons()

	shiftlockJumpConnection = hum.Jumping:Connect(function()
		if not shiftlockEnabled then return end

		-- Turn the shiftlock button blue
		setShiftlockVisual(true)

		-- Also face the camera direction
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then
			local look = C.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)
			if flat.Magnitude > 0.05 then
				root.CFrame = CFrame.new(root.Position, root.Position + flat.Unit)
			end
		end
	end)

	-- When landing, turn it back to default
	shiftlockStateConnection = hum.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
			setShiftlockVisual(false)
		end
	end)
end

local function cleanupShiftlock()
	if shiftlockJumpConnection then shiftlockJumpConnection:Disconnect() end
	if shiftlockStateConnection then shiftlockStateConnection:Disconnect() end
	setShiftlockVisual(false) -- make sure it's reset
end

-- Anti-Lag + Desync + Ranked + ESP (unchanged)
local espBeams = {}
local OriginalStates = {}
local asyncConnection
local lastTriggerTime = 0
local MIN_INTERVAL = 0.5
local BANDWIDTH_LOW = 1

local function SaveOriginalState(obj)
	if OriginalStates[obj] then return end
	local s = {}
	if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
		s.Rate, s.Lifetime, s.Enabled = obj.Rate, obj.Lifetime, obj.Enabled
	elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
		s.Enabled = obj.Enabled
	elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
		s.Enabled, s.Brightness = obj.Enabled, obj.Brightness
	end
	if next(s) then OriginalStates[obj] = s end
end

local function ApplyAntiLag()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		pcall(function()
			if obj:IsA("Fire") or obj:IsA("Smoke") then
				SaveOriginalState(obj)
				obj.Enabled = false
			elseif obj:IsA("ParticleEmitter") then
				SaveOriginalState(obj)
				obj.Rate = math.max(obj.Rate * 0.25, 1)
			elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
				SaveOriginalState(obj)
				obj.Brightness = obj.Brightness * 0.35
			end
		end)
	end
end

local function RestoreOriginal()
	for obj, s in pairs(OriginalStates) do
		pcall(function()
			if s.Rate then obj.Rate = s.Rate end
			if s.Lifetime then obj.Lifetime = s.Lifetime end
			if s.Enabled ~= nil then obj.Enabled = s.Enabled end
			if s.Brightness then obj.Brightness = s.Brightness end
		end)
	end
	OriginalStates = {}
end

local function applyDesync(state)
	pcall(function()
		setfflag("PhysicsSenderMaxBandwidthBps", state and tostring(BANDWIDTH_LOW) or "999999")
	end)
end

local function onJump(active)
	if not asyncDesyncEnabled or not active then return end
	local now = tick()
	if now - lastTriggerTime < MIN_INTERVAL then return end
	lastTriggerTime = now
	applyDesync(true)
	task.wait(ASYNC_COOLDOWN)
	applyDesync(false)
end

local function setupAsyncDesync(char)
	if asyncConnection then asyncConnection:Disconnect() end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then asyncConnection = hum.Jumping:Connect(onJump) end
end

local rankedEnabled = {style = false, yen = false, ability = false}
local rankedLoopActive = false

local function fireRankedReward(arg)
	local remote = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("SeasonService"):WaitForChild("RF"):WaitForChild("RequestRankedReward")
	pcall(function() remote:InvokeServer(arg) end)
end

local function rankedStealthLoop()
	while rankedLoopActive do
		if not (rankedEnabled.style or rankedEnabled.yen or rankedEnabled.ability) then
			task.wait(0.5)
		else
			for _, info in ipairs({{name="style",arg=1},{name="yen",arg=2},{name="ability",arg=4}}) do
				if rankedLoopActive and rankedEnabled[info.name] then
					fireRankedReward(info.arg)
					task.wait(3 + math.random()*1.6 - 0.8)
				end
			end
		end
	end
end

local function updateRankedLoop()
	if (rankedEnabled.style or rankedEnabled.yen or rankedEnabled.ability) and not rankedLoopActive then
		rankedLoopActive = true
		task.spawn(rankedStealthLoop)
	end
end

-- Tabs
function buildCharacterTab()
	CreateToggle(content, "Kazana Jump", boostEnabled, function(v)
		boostEnabled = v
		if LP.Character then
			if v then applyBoostJump(LP.Character)
			elseif boostConnection then boostConnection:Disconnect() end
		end
	end)

	CreateToggle(content, "Auto Shiftlock", shiftlockEnabled, function(v)
		shiftlockEnabled = v
		if v then
			if LP.Character then setupShiftlock(LP.Character) end
		else
			cleanupShiftlock()
		end
	end)

	CreateToggle(content, "Direction ESP", espEnabled, function(v)
		espEnabled = v
		if not v then
			for _, d in pairs(espBeams) do
				pcall(function() d.Beam:Destroy() d.A0:Destroy() d.A1:Destroy() end)
			end
			table.clear(espBeams)
		end
	end)

	CreateToggle(content, "Anti-Lag", antiLagEnabled, function(v)
		antiLagEnabled = v
		if v then ApplyAntiLag() else RestoreOriginal() end
	end)
end

function buildDesyncTab()
	CreateToggle(content, "Desync", asyncDesyncEnabled, function(v)
		asyncDesyncEnabled = v
		if v then
			if LP.Character then setupAsyncDesync(LP.Character) end
		else
			if asyncConnection then asyncConnection:Disconnect() end
			applyDesync(false)
		end
	end)

	CreateSlider(content, "Duration", 0.05, 1, desyncDuration, function(v)
		desyncDuration = v
		ASYNC_COOLDOWN = v
		saveConfig()
	end, "s")
end

function buildHitboxTab()
	CreateToggle(content, "Hitbox Extender", hitboxEnabled, function(v)
		toggleHitboxExtender(v)
	end)

	CreateSlider(content, "Size", 1, 20, hitboxSize, function(v)
		hitboxSize = v
		if hitboxEnabled then updateHitboxes(v) end
		saveConfig()
	end)
end

function buildAutomationTab()
	CreateToggle(content, "Inf Style Spins", rankedEnabled.style, function(v)
		rankedEnabled.style = v
		updateRankedLoop()
		if v then fireRankedReward(1) end
	end)
	CreateToggle(content, "Inf Yen", rankedEnabled.yen, function(v)
		rankedEnabled.yen = v
		updateRankedLoop()
		if v then fireRankedReward(2) end
	end)
	CreateToggle(content, "Inf Ability Spins", rankedEnabled.ability, function(v)
		rankedEnabled.ability = v
		updateRankedLoop()
		if v then fireRankedReward(4) end
	end)
end

-- Connections
LP.CharacterAdded:Connect(function(ch)
	task.wait(0.2)
	if boostEnabled then applyBoostJump(ch) end
	if shiftlockEnabled then setupShiftlock(ch) end
	if asyncDesyncEnabled then setupAsyncDesync(ch) end
	if hitboxEnabled then updateHitboxes(hitboxSize) end
end)

RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LP and not (LP.Team and p.Team and LP.Team == p.Team) then
			local char = p.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
				if hum and hum.Health > 0 and torso then
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
						data = {Beam = beam, A0 = a0, A1 = a1}
						espBeams[p] = data
					end
					local dir = Vector3.new(torso.CFrame.LookVector.X, 0, torso.CFrame.LookVector.Z).Unit
					data.A0.WorldPosition = torso.Position + dir * 0.6
					data.A1.WorldPosition = torso.Position + dir * 55
				end
			end
		end
	end
end)

Workspace.DescendantAdded:Connect(function(obj)
	if not antiLagEnabled then return end
	task.wait(0.1)
	pcall(function()
		if obj:IsA("Fire") or obj:IsA("Smoke") then
			SaveOriginalState(obj)
			obj.Enabled = false
		elseif obj:IsA("ParticleEmitter") then
			SaveOriginalState(obj)
			obj.Rate = math.max(obj.Rate * 0.25, 1)
		elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			SaveOriginalState(obj)
			obj.Brightness = obj.Brightness * 0.35
		end
	end)
end)

task.spawn(function()
	loadConfig()
	switchTab("Character")
	print("JHub ready - Visual Shiftlock only")
end)
