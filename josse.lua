print("=== JHub FINAL (Speed Fix) ===")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local C = workspace.CurrentCamera

-- Wait for PlayerGui
local PG = LP:FindFirstChild("PlayerGui")
if not PG then
    for i = 1, 30 do
        task.wait(0.1)
        PG = LP:FindFirstChild("PlayerGui")
        if PG then break end
    end
end
if not PG then warn("PlayerGui not found") return end

-- Destroy old UI
local old = PG:FindFirstChild("JHub")
if old then old:Destroy() end

local UI = Instance.new("ScreenGui")
UI.Name = "JHub"
UI.ResetOnSpawn = false
UI.Parent = PG

-- Colors
local ACCENT = Color3.fromRGB(235, 35, 75)
local BG_DARK = Color3.fromRGB(12, 12, 15)
local BG_PANEL = Color3.fromRGB(18, 18, 22)
local BG_BUTTON = Color3.fromRGB(28, 28, 34)
local BG_BUTTON_ON = Color3.fromRGB(235, 35, 75)
local TEXT_PRIMARY = Color3.fromRGB(255, 255, 255)
local TEXT_SECONDARY = Color3.fromRGB(210, 210, 215)
local TEXT_DIM = Color3.fromRGB(140, 140, 145)

-- ===== Main Frame (compact) =====
local M = Instance.new("Frame")
M.Size = UDim2.new(0, 240, 0, 260)
M.Position = UDim2.new(0.5, -120, 0.5, -130)
M.BackgroundColor3 = BG_DARK
M.BackgroundTransparency = 0.08
M.Active = true
M.Draggable = true
M.Visible = true
M.BorderSizePixel = 0
M.ClipsDescendants = true
M.Parent = UI

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = M

local stroke = Instance.new("UIStroke")
stroke.Color = ACCENT
stroke.Thickness = 1.2
stroke.Parent = M

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.PaddingTop = UDim.new(0, 12)
pad.PaddingBottom = UDim.new(0, 12)
pad.Parent = M

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = M

local function Clamp()
    local vs = C.ViewportSize
    M.Position = UDim2.new(
        0, math.clamp(M.AbsolutePosition.X, 0, vs.X - M.AbsoluteSize.X),
        0, math.clamp(M.AbsolutePosition.Y, 0, vs.Y - M.AbsoluteSize.Y)
    )
end
M:GetPropertyChangedSignal("Position"):Connect(Clamp)
C:GetPropertyChangedSignal("ViewportSize"):Connect(Clamp)

-- Title (emoji removed)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.Text = "JOSSERPOPSIER"
title.TextColor3 = TEXT_PRIMARY
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = M

-- ===== Floating Hide Button =====
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 80, 0, 32)
hideBtn.Position = UDim2.new(1, -95, 0, 15)
hideBtn.Text = "HIDE"
hideBtn.TextColor3 = TEXT_PRIMARY
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 12
hideBtn.BackgroundColor3 = BG_DARK
hideBtn.Visible = true
hideBtn.AutoButtonColor = false
hideBtn.BorderSizePixel = 0
hideBtn.Parent = UI

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 6)
hCorner.Parent = hideBtn
local hStroke = Instance.new("UIStroke")
hStroke.Color = ACCENT
hStroke.Thickness = 1.2
hStroke.Parent = hideBtn

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
    local newX = math.clamp(hideBtn.AbsolutePosition.X, 0, vs.X - hideBtn.AbsoluteSize.X)
    local newY = math.clamp(hideBtn.AbsolutePosition.Y, 0, vs.Y - hideBtn.AbsoluteSize.Y)
    hideBtn.Position = UDim2.new(0, newX, 0, newY)
end)

hideBtn.MouseButton1Click:Connect(function()
    M.Visible = not M.Visible
    hideBtn.Text = M.Visible and "HIDE" or "SHOW"
end)

-- ===== Helper: Reliable Toggle (Only Button Toggles) =====
local function CreateReliableToggle(parent, labelText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = BG_PANEL
    row.BorderSizePixel = 0
    row.Parent = parent
    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

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
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

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
        print("Toggled " .. labelText .. " to: " .. tostring(enabled))
        callback(enabled)
        task.wait(0.3)
        debounce = false
    end

    btn.MouseButton1Click:Connect(toggle)
    btn.TouchTap:Connect(toggle)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            task.wait(0.05)
            toggle()
        end
    end)

    return {
        toggle = toggle,
        setEnabled = function(v)
            if enabled ~= v then toggle() end
        end,
        getEnabled = function() return enabled end
    }
end

-- ===== 1. Superhuman Boost (Jump + Speed 15%) =====
local boostEnabled = false
local BOOST_AMOUNT = 1.0
local SPEED_MULTIPLIER = 1.15
local boostConnection = nil
local originalWalkSpeed = 16
local speedLoopConnection = nil

local function applySpeed(character)
    if not character then return end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Store original speed once (only if not already set)
    if originalWalkSpeed == 16 then
        originalWalkSpeed = hum.WalkSpeed
    end

    if boostEnabled then
        hum.WalkSpeed = originalWalkSpeed * SPEED_MULTIPLIER
    else
        hum.WalkSpeed = originalWalkSpeed
    end
end

local function setupSpeedLoop(character)
    -- Remove old loop if exists
    if speedLoopConnection then
        speedLoopConnection:Disconnect()
        speedLoopConnection = nil
    end
    -- Create new loop that forces speed every frame (0.1s interval)
    speedLoopConnection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then
            -- Character lost, try to get current character
            character = LP.Character
            if not character then return end
        end
        applySpeed(character)
    end)
end

local function applyBoostJump(character)
    if not character then return end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if boostConnection then
        boostConnection:Disconnect()
        boostConnection = nil
    end

    if boostEnabled then
        boostConnection = hum.Jumping:Connect(function()
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local vel = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = vel + Vector3.new(0, BOOST_AMOUNT, 0)
                if hum.JumpPower < 60 then hum.JumpPower = 55 end
            end
        end)
    end
end

local function applyBoostFull(character)
    if not character then return end
    applySpeed(character)
    applyBoostJump(character)
end

CreateReliableToggle(M, "Superhuman Boost", function(v)
    boostEnabled = v
    local char = LP.Character
    if char then
        applyBoostFull(char)
        -- Start/stop the speed loop
        if v then
            setupSpeedLoop(char)
        else
            if speedLoopConnection then
                speedLoopConnection:Disconnect()
                speedLoopConnection = nil
            end
            -- Force reset speed once
            applySpeed(char)
        end
    end
end)

LP.CharacterAdded:Connect(function(ch)
    task.wait(0.2)
    if boostEnabled then
        applyBoostFull(ch)
        setupSpeedLoop(ch)
    else
        if speedLoopConnection then
            speedLoopConnection:Disconnect()
            speedLoopConnection = nil
        end
        applySpeed(ch)
    end
end)

-- Initial apply
task.wait(0.3)
local char = LP.Character
if char then
    applyBoostFull(char)
    if boostEnabled then
        setupSpeedLoop(char)
    end
end

-- ===== 2. Auto Shiftlock =====
local shiftlockEnabled = false
local shiftlockDirection = nil
local shiftlockJumping = false
local shiftlockTimer = nil

CreateReliableToggle(M, "Auto Shiftlock", function(v)
    shiftlockEnabled = v
    if not v then
        shiftlockJumping = false
        shiftlockDirection = nil
        if shiftlockTimer then task.cancel(shiftlockTimer) end
    end
end)

local function setupShiftlock(character)
    local hum = character:WaitForChild("Humanoid")
    hum.Jumping:Connect(function()
        if not shiftlockEnabled then return end
        if shiftlockTimer then task.cancel(shiftlockTimer) end
        local look = C.CFrame.LookVector
        shiftlockDirection = Vector3.new(look.X, 0, look.Z).Unit
        shiftlockJumping = true
        shiftlockTimer = task.spawn(function()
            task.wait(0.4)
            shiftlockJumping = false
            shiftlockDirection = nil
        end)
    end)
    hum.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Landed then
            shiftlockJumping = false
            shiftlockDirection = nil
            if shiftlockTimer then task.cancel(shiftlockTimer) end
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

-- ===== 3. Direction Facing ESP =====
local espEnabled = false
local espBeams = {}

CreateReliableToggle(M, "Direction Facing ESP", function(v)
    espEnabled = v
    if not v then
        for _, data in pairs(espBeams) do
            pcall(function()
                data.Beam:Destroy()
                data.A0:Destroy()
                data.A1:Destroy()
            end)
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
            data = {Beam = beam, A0 = a0, A1 = a1}
            espBeams[p] = data
        end

        local look = torso.CFrame.LookVector
        local dir = Vector3.new(look.X, 0, look.Z).Unit
        if dir.Magnitude < 0.001 then dir = Vector3.new(0, 0, -1) end
        data.A0.WorldPosition = torso.Position + (dir * 0.6)
        data.A1.WorldPosition = torso.Position + (dir * 55)
    end

    -- Clean up dead players
    for p, data in pairs(espBeams) do
        if not p.Parent then
            pcall(function()
                data.Beam:Destroy()
                data.A0:Destroy()
                data.A1:Destroy()
            end)
            espBeams[p] = nil
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if espBeams[p] then
        pcall(function()
            espBeams[p].Beam:Destroy()
            espBeams[p].A0:Destroy()
            espBeams[p].A1:Destroy()
        end)
        espBeams[p] = nil
    end
end)

-- ===== 4. Anti-Lag (Sound Preserved) =====
local antiLagEnabled = false
local OriginalStates = {}
local SavedSkybox, SavedAtmosphere, SavedLightingTech, SavedGlobalShadows = nil, nil, nil, nil
local SavedRenderQuality, SavedQualityLevel = nil, nil

local function IsESPDown(obj)
    for _, entry in pairs(espBeams) do
        if entry.Beam == obj then return true end
    end
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
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") then
        state.Enabled = obj.Enabled
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        state.Enabled = obj.Enabled
        state.Brightness = obj.Brightness
    elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
        state.Enabled = obj.Enabled
    -- No Sound – skip
    elseif obj:IsA("Mesh") or obj:IsA("SpecialMesh") or obj:IsA("BlockMesh") or obj:IsA("CylinderMesh") then
        state.Scale = obj.Scale
    end
    if next(state) then OriginalStates[obj] = state end
end

local function ApplyAntiLag()
    local lighting = game:GetService("Lighting")
    local sky = lighting:FindFirstChildOfClass("Sky")
    if sky and not SavedSkybox then SavedSkybox = sky:Clone(); sky.Parent = nil end
    local atm = lighting:FindFirstChildOfClass("Atmosphere")
    if atm and not SavedAtmosphere then SavedAtmosphere = atm:Clone(); atm.Parent = nil end
    for _, cloud in ipairs(lighting:GetChildren()) do
        if cloud:IsA("Clouds") then pcall(function() cloud.Parent = nil end) end
    end
    for _, effect in ipairs(lighting:GetChildren()) do
        if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
            pcall(function() effect.Enabled = false end)
        end
    end
    pcall(function()
        lighting.Ambient = Color3.fromRGB(128, 128, 128)
        lighting.Brightness = 2
        lighting.ColorShift_Bottom = Color3.fromRGB(128, 128, 128)
        lighting.ColorShift_Top = Color3.fromRGB(128, 128, 128)
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end)
    pcall(function()
        if not SavedLightingTech then
            SavedLightingTech = lighting.Technology
            SavedGlobalShadows = lighting.GlobalShadows
        end
        lighting.Technology = Enum.Technology.Compatibility
        lighting.GlobalShadows = false
    end)
    pcall(function()
        if settings() and settings().Rendering then
            if not SavedQualityLevel then SavedQualityLevel = settings().Rendering.QualityLevel end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end
    end)
    pcall(function()
        if UserSettings() and UserSettings().GameSettings then
            if not SavedRenderQuality then SavedRenderQuality = UserSettings().GameSettings.RenderQuality end
            UserSettings().GameSettings.RenderQuality = 0
        end
    end)

    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Beam") and IsESPDown(obj) then return end
            if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                SaveOriginalState(obj)
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                if obj:IsA("MeshPart") then obj.TextureID = "" end
            elseif (obj:IsA("Texture") or obj:IsA("Decal")) then
                SaveOriginalState(obj)
                obj.Transparency = 1
            elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam")) then
                if not IsESPDown(obj) then
                    SaveOriginalState(obj)
                    obj.Enabled = false
                end
            elseif (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
                SaveOriginalState(obj)
                obj.Enabled = false
            -- Skip Sound
            elseif obj:IsA("Mesh") or obj:IsA("SpecialMesh") or obj:IsA("BlockMesh") or obj:IsA("CylinderMesh") then
                SaveOriginalState(obj)
                obj.Scale = Vector3.new(0, 0, 0)
            end
        end)
    end

    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterColor = Color3.fromRGB(128, 128, 128)
            terrain.WaterTransparency = 1
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end
    end)
end

local function RestoreOriginal()
    local lighting = game:GetService("Lighting")
    if SavedSkybox then pcall(function() SavedSkybox.Parent = lighting end); SavedSkybox = nil end
    if SavedAtmosphere then pcall(function() SavedAtmosphere.Parent = lighting end); SavedAtmosphere = nil end
    pcall(function()
        if SavedLightingTech then lighting.Technology = SavedLightingTech; SavedLightingTech = nil end
        if SavedGlobalShadows ~= nil then lighting.GlobalShadows = SavedGlobalShadows; SavedGlobalShadows = nil end
    end)
    pcall(function()
        if settings() and settings().Rendering and SavedQualityLevel then
            settings().Rendering.QualityLevel = SavedQualityLevel; SavedQualityLevel = nil
        end
        if UserSettings() and UserSettings().GameSettings and SavedRenderQuality ~= nil then
            UserSettings().GameSettings.RenderQuality = SavedRenderQuality; SavedRenderQuality = nil
        end
    end)
    for obj, state in pairs(OriginalStates) do
        pcall(function()
            if obj:IsA("BasePart") then
                if state.Material then obj.Material = state.Material end
                if state.Color then obj.Color = state.Color end
                if state.Reflectance ~= nil then obj.Reflectance = state.Reflectance end
                if obj:IsA("MeshPart") and state.TextureID ~= nil then obj.TextureID = state.TextureID end
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                if state.Texture then obj.Texture = state.Texture end
                if state.Transparency then obj.Transparency = state.Transparency end
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") then
                if state.Enabled ~= nil then obj.Enabled = state.Enabled end
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                if state.Enabled ~= nil then obj.Enabled = state.Enabled end
                if state.Brightness then obj.Brightness = state.Brightness end
            elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                if state.Enabled ~= nil then obj.Enabled = state.Enabled end
            elseif obj:IsA("Mesh") or obj:IsA("SpecialMesh") or obj:IsA("BlockMesh") or obj:IsA("CylinderMesh") then
                if state.Scale then obj.Scale = state.Scale end
            end
        end)
    end
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = true
            terrain.WaterColor = Color3.fromRGB(12, 84, 92)
            terrain.WaterTransparency = 0.3
            terrain.WaterWaveSize = 0.15
            terrain.WaterWaveSpeed = 10
        end
    end)
    OriginalStates = {}
end

CreateReliableToggle(M, "Anti-Lag", function(v)
    antiLagEnabled = v
    if v then ApplyAntiLag() else RestoreOriginal() end
end)

-- ===== Auto-reapply Anti-Lag =====
workspace.DescendantAdded:Connect(function(obj)
    if not antiLagEnabled then return end
    task.wait(0.1)
    pcall(function()
        if obj:IsA("Beam") and IsESPDown(obj) then return end
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            SaveOriginalState(obj)
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            if obj:IsA("MeshPart") then obj.TextureID = "" end
        elseif (obj:IsA("Texture") or obj:IsA("Decal")) then
            SaveOriginalState(obj)
            obj.Transparency = 1
        elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam")) then
            if not IsESPDown(obj) then
                SaveOriginalState(obj)
                obj.Enabled = false
            end
        elseif (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
            SaveOriginalState(obj)
            obj.Enabled = false
        -- Skip Sound
        elseif obj:IsA("Mesh") or obj:IsA("SpecialMesh") or obj:IsA("BlockMesh") or obj:IsA("CylinderMesh") then
            SaveOriginalState(obj)
            obj.Scale = Vector3.new(0, 0, 0)
        end
    end)
end)

print("JHub FINAL loaded – Superhuman Boost speed forced every frame.")
