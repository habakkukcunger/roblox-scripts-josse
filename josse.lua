local P,T,U=game:GetService("Players"),game:GetService("TweenService"),game:GetService("UserInputService")
local LP,C,PG=P.LocalPlayer,workspace.CurrentCamera,P.LocalPlayer:WaitForChild("PlayerGui")
if PG:FindFirstChild("JHubV6") then PG.JHubV6:Destroy() end

local SL,FaceESP,ActiveBeams,JP,TD=false,false,{},false,nil
local UI=Instance.new("ScreenGui",PG)UI.Name="JHubV6"UI.ResetOnSpawn=false

-- Constants
local ACCENT = Color3.fromRGB(235, 35, 75)
local BG_DARK = Color3.fromRGB(12, 12, 15)
local BG_PANEL = Color3.fromRGB(18, 18, 22)
local BG_BUTTON = Color3.fromRGB(28, 28, 34)
local BG_BUTTON_ON = Color3.fromRGB(235, 35, 75)
local TEXT_PRIMARY = Color3.fromRGB(255, 255, 255)
local TEXT_SECONDARY = Color3.fromRGB(210, 210, 215)
local TEXT_DIM = Color3.fromRGB(140, 140, 145)

-- Main Frame
local M=Instance.new("Frame",UI)
M.Size = UDim2.new(0, 220, 0, 180)
M.Position = UDim2.new(0.05, 0, 0.35, 0)
M.BackgroundColor3 = BG_DARK
M.BackgroundTransparency = 0.08
M.Active = true
M.Draggable = true
M.Visible = false
M.BorderSizePixel = 0
M.ClipsDescendants = true

Instance.new("UICorner", M).CornerRadius = UDim.new(0, 8)
local S=Instance.new("UIStroke", M)
S.Color = ACCENT
S.Thickness = 1.2

-- Padding
local MP=Instance.new("UIPadding", M)
MP.PaddingLeft = UDim.new(0, 10)
MP.PaddingRight = UDim.new(0, 10)
MP.PaddingTop = UDim.new(0, 8)
MP.PaddingBottom = UDim.new(0, 8)

-- Layout
local L=Instance.new("UIListLayout", M)
L.Padding = UDim.new(0, 6)
L.HorizontalAlignment = Enum.HorizontalAlignment.Center
L.VerticalAlignment = Enum.VerticalAlignment.Top

-- Clamp to screen
local function Clamp()
    local vs = C.ViewportSize
    M.Position = UDim2.new(
        0, math.clamp(M.AbsolutePosition.X, 0, vs.X - M.AbsoluteSize.X),
        0, math.clamp(M.AbsolutePosition.Y, 0, vs.Y - M.AbsoluteSize.Y)
    )
end
M:GetPropertyChangedSignal("Position"):Connect(Clamp)
C:GetPropertyChangedSignal("ViewportSize"):Connect(Clamp)

-- Title
local Tl=Instance.new("TextLabel", M)
Tl.Size = UDim2.new(1, 0, 0, 16)
Tl.Text = "JOSSERPOPSIER"
Tl.TextColor3 = TEXT_PRIMARY
Tl.TextSize = 12
Tl.Font = Enum.Font.GothamBold
Tl.BackgroundTransparency = 1
Tl.TextXAlignment = Enum.TextXAlignment.Center

-- Toggle Button (HIDE/SHOW)
local Tg=Instance.new("TextButton", UI)
Tg.Size = UDim2.new(0, 65, 0, 24)
Tg.Position = UDim2.new(1, -85, 0, 45)
Tg.Text = "HIDE"
Tg.TextColor3 = TEXT_PRIMARY
Tg.Font = Enum.Font.GothamBold
Tg.TextSize = 9
Tg.BackgroundColor3 = BG_DARK
Tg.Visible = false
Tg.AutoButtonColor = false
Tg.BorderSizePixel = 0

Instance.new("UICorner", Tg).CornerRadius = UDim.new(0, 5)
local TgS=Instance.new("UIStroke", Tg)
TgS.Color = ACCENT
TgS.Thickness = 1

Tg.MouseButton1Click:Connect(function()
    M.Visible = not M.Visible
    Tg.Text = M.Visible and "HIDE" or "SHOW"
end)

-- Draggable Tg
Tg.Active = true
local draggingTg = false
local dragStartTg, startPosTg

Tg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTg = true
        dragStartTg = input.Position
        startPosTg = Tg.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingTg = false
            end
        end)
    end
end)

Tg.InputChanged:Connect(function(input)
    if draggingTg and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartTg
        local vs = C.ViewportSize
        local newX = math.clamp(startPosTg.X.Offset + delta.X, 0, vs.X - Tg.AbsoluteSize.X)
        local newY = math.clamp(startPosTg.Y.Offset + delta.Y, 0, vs.Y - Tg.AbsoluteSize.Y)
        Tg.Position = UDim2.new(0, newX, 0, newY)
    end
end)

C:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local vs = C.ViewportSize
    local newX = math.clamp(Tg.AbsolutePosition.X, 0, vs.X - Tg.AbsoluteSize.X)
    local newY = math.clamp(Tg.AbsolutePosition.Y, 0, vs.Y - Tg.AbsoluteSize.Y)
    Tg.Position = UDim2.new(0, newX, 0, newY)
end)

-- Toggle Row Template
local function CreateToggleRow(parent, text, callback)
    local Cd = Instance.new("Frame", parent)
    Cd.Size = UDim2.new(1, 0, 0, 30)
    Cd.BackgroundColor3 = BG_PANEL
    Cd.BorderSizePixel = 0
    Instance.new("UICorner", Cd).CornerRadius = UDim.new(0, 5)
    
    local Lb = Instance.new("TextLabel", Cd)
    Lb.Size = UDim2.new(1, -70, 1, 0)
    Lb.Position = UDim2.new(0, 10, 0, 0)
    Lb.Text = text
    Lb.TextColor3 = TEXT_SECONDARY
    Lb.TextSize = 11
    Lb.Font = Enum.Font.GothamMedium
    Lb.TextXAlignment = Enum.TextXAlignment.Left
    Lb.BackgroundTransparency = 1
    
    local B = Instance.new("TextButton", Cd)
    B.Size = UDim2.new(0, 48, 0, 18)
    B.Position = UDim2.new(1, -58, 0.5, -9)
    B.Text = "OFF"
    B.Font = Enum.Font.GothamBold
    B.TextSize = 9
    B.BackgroundColor3 = BG_BUTTON
    B.TextColor3 = TEXT_DIM
    B.AutoButtonColor = false
    B.BorderSizePixel = 0
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
    
    local st = false
    B.MouseButton1Click:Connect(function()
        st = not st
        B.Text = st and "ON" or "OFF"
        B.BackgroundColor3 = st and BG_BUTTON_ON or BG_BUTTON
        B.TextColor3 = st and TEXT_PRIMARY or TEXT_DIM
        callback(st)
    end)
    
    return Cd, B
end

local function CE()
    for _, i in pairs(ActiveBeams) do
        pcall(function()
            i.Beam:Destroy()
            i.A0:Destroy()
            i.A1:Destroy()
        end)
    end
    table.clear(ActiveBeams)
end

CreateToggleRow(M, "Auto Shiftlock", function(v)
    SL = v
    if not v then JP, TD = false, nil end
end)

CreateToggleRow(M, "Direction Facing Esp", function(v)
    FaceESP = v
    if not v then CE() end
end)

-- Anti-Lag Section
local AntiLagSection = Instance.new("Frame", M)
AntiLagSection.Size = UDim2.new(1, 0, 0, 30)
AntiLagSection.BackgroundColor3 = BG_PANEL
AntiLagSection.BorderSizePixel = 0
Instance.new("UICorner", AntiLagSection).CornerRadius = UDim.new(0, 5)

local AntiLagLabel = Instance.new("TextLabel", AntiLagSection)
AntiLagLabel.Size = UDim2.new(1, -50, 1, 0)
AntiLagLabel.Position = UDim2.new(0, 10, 0, 0)
AntiLagLabel.Text = "ANTI-LAG"
AntiLagLabel.TextColor3 = TEXT_SECONDARY
AntiLagLabel.TextSize = 11
AntiLagLabel.Font = Enum.Font.GothamMedium
AntiLagLabel.TextXAlignment = Enum.TextXAlignment.Left
AntiLagLabel.BackgroundTransparency = 1

local CollapseBtn = Instance.new("TextButton", AntiLagSection)
CollapseBtn.Size = UDim2.new(0, 32, 0, 20)
CollapseBtn.Position = UDim2.new(1, -42, 0.5, -10)
CollapseBtn.Text = "▶"
CollapseBtn.Font = Enum.Font.GothamBold
CollapseBtn.TextSize = 10
CollapseBtn.BackgroundColor3 = BG_BUTTON
CollapseBtn.TextColor3 = TEXT_DIM
CollapseBtn.AutoButtonColor = false
CollapseBtn.BorderSizePixel = 0
Instance.new("UICorner", CollapseBtn).CornerRadius = UDim.new(0, 4)

-- Settings Container (parented to M, starts hidden)
local SettingsContainer = Instance.new("Frame", M)
SettingsContainer.Size = UDim2.new(1, 0, 0, 0)
SettingsContainer.BackgroundTransparency = 1
SettingsContainer.BorderSizePixel = 0
SettingsContainer.ClipsDescendants = true
SettingsContainer.Visible = false

local SettingsList = Instance.new("UIListLayout", SettingsContainer)
SettingsList.Padding = UDim.new(0, 6)
SettingsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SettingsList.VerticalAlignment = Enum.VerticalAlignment.Top

-- Anti-Lag System
local LagSettings = {
    Textures = true, Shadows = true, Particles = true, MeshDetail = true,
    LightingQuality = true, Billboards = true, Skybox = true,
    Atmosphere = true, Reflections = true, PostProcessing = true
}
local OriginalStates = {}
local SavedSkybox, SavedAtmosphere, SavedReflection, SavedPostProcessing = nil, nil, nil, nil
local CurrentPreset = "OFF"

local Presets = {
    OFF = {Textures=false, Shadows=false, Particles=false, MeshDetail=false, LightingQuality=false, Billboards=false, Skybox=false, Atmosphere=false, Reflections=false, PostProcessing=false},
    LOW = {Textures=true, Shadows=true, Particles=true, MeshDetail=true, LightingQuality=true, Billboards=true, Skybox=true, Atmosphere=true, Reflections=true, PostProcessing=true},
    MEDIUM = {Textures=true, Shadows=false, Particles=true, MeshDetail=true, LightingQuality=false, Billboards=true, Skybox=false, Atmosphere=false, Reflections=true, PostProcessing=true},
    HIGH = {Textures=true, Shadows=false, Particles=false, MeshDetail=true, LightingQuality=false, Billboards=false, Skybox=false, Atmosphere=false, Reflections=false, PostProcessing=false}
}

local function SaveOriginalState(obj)
    if OriginalStates[obj] then return end
    local state = {}
    if obj:IsA("BasePart") then
        state.Material = obj.Material
        state.Color = obj.Color
        if obj:IsA("MeshPart") then
            state.TextureID = obj.TextureID
        end
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        state.Texture = obj.Texture
        state.Transparency = obj.Transparency
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        state.Enabled = obj.Enabled
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        state.Enabled = obj.Enabled
        state.Brightness = obj.Brightness
    elseif obj:IsA("BillboardGui") then
        state.Enabled = obj.Enabled
    end
    if next(state) then OriginalStates[obj] = state end
end

local function ApplyAntiLag()
    if CurrentPreset == "OFF" then return end
    local lighting = game:GetService("Lighting")

    if LagSettings.Skybox then
        local sky = lighting:FindFirstChildOfClass("Sky")
        if sky and not SavedSkybox then
            SavedSkybox = sky:Clone()
            sky.Parent = nil
        end
    end

    if LagSettings.Atmosphere then
        local atm = lighting:FindFirstChildOfClass("Atmosphere")
        if atm and not SavedAtmosphere then
            SavedAtmosphere = atm:Clone()
            atm.Parent = nil
        end
    end

    if LagSettings.Reflections then
        if not SavedReflection then
            SavedReflection = lighting.EnvironmentDiffuseScale
        end
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0
    end

    if LagSettings.PostProcessing then
        SavedPostProcessing = SavedPostProcessing or {}
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                if not SavedPostProcessing[effect] then
                    SavedPostProcessing[effect] = effect.Enabled
                end
                effect.Enabled = false
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                SaveOriginalState(obj)
                if LagSettings.Textures then
                    obj.Material = Enum.Material.SmoothPlastic
                    if obj:IsA("MeshPart") then
                        obj.TextureID = ""
                    end
                end
            elseif (obj:IsA("Texture") or obj:IsA("Decal")) and LagSettings.Textures then
                SaveOriginalState(obj)
                obj.Transparency = 1
            elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail")) and LagSettings.Particles then
                SaveOriginalState(obj)
                obj.Enabled = false
            elseif (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) and LagSettings.Shadows then
                SaveOriginalState(obj)
                obj.Enabled = false
            elseif obj:IsA("BillboardGui") and LagSettings.Billboards then
                SaveOriginalState(obj)
                obj.Enabled = false
            end
        end)
    end

    if LagSettings.LightingQuality then
        OriginalStates[lighting] = OriginalStates[lighting] or {}
        if not OriginalStates[lighting].Technology then
            OriginalStates[lighting].Technology = lighting.Technology
        end
        if not OriginalStates[lighting].GlobalShadows then
            OriginalStates[lighting].GlobalShadows = lighting.GlobalShadows
        end
        lighting.Technology = Enum.Technology.Compatibility
        lighting.GlobalShadows = false
    end
end

local function RestoreOriginal()
    local lighting = game:GetService("Lighting")

    if SavedSkybox then
        SavedSkybox.Parent = lighting
        SavedSkybox = nil
    end

    if SavedAtmosphere then
        SavedAtmosphere.Parent = lighting
        SavedAtmosphere = nil
    end

    if SavedReflection then
        lighting.EnvironmentDiffuseScale = SavedReflection
        lighting.EnvironmentSpecularScale = SavedReflection
        SavedReflection = nil
    end

    if SavedPostProcessing then
        for effect, enabled in pairs(SavedPostProcessing) do
            if effect and effect.Parent then
                effect.Enabled = enabled
            end
        end
        SavedPostProcessing = nil
    end

    for obj, state in pairs(OriginalStates) do
        pcall(function()
            if obj:IsA("BasePart") then
                if state.Material then obj.Material = state.Material end
                if state.Color then obj.Color = state.Color end
                if obj:IsA("MeshPart") and state.TextureID ~= nil then obj.TextureID = state.TextureID end
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                if state.Texture then obj.Texture = state.Texture end
                if state.Transparency then obj.Transparency = state.Transparency end
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                if state.Enabled ~= nil then obj.Enabled = state.Enabled end
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                if state.Enabled ~= nil then obj.Enabled = state.Enabled end
                if state.Brightness then obj.Brightness = state.Brightness end
            elseif obj:IsA("BillboardGui") then
                if state.Enabled ~= nil then obj.Enabled = state.Enabled end
            end
        end)
    end

    if OriginalStates[lighting] then
        if OriginalStates[lighting].Technology then lighting.Technology = OriginalStates[lighting].Technology end
        if OriginalStates[lighting].GlobalShadows ~= nil then lighting.GlobalShadows = OriginalStates[lighting].GlobalShadows end
    end
    OriginalStates = {}
end

local function ApplyPreset(presetName)
    CurrentPreset = presetName
    for k, v in pairs(Presets[presetName]) do
        LagSettings[k] = v
    end
    if presetName == "OFF" then
        RestoreOriginal()
    else
        RestoreOriginal()
        task.wait(0.05)
        ApplyAntiLag()
    end
end

-- Preset Panel
local PresetFrame = Instance.new("Frame", SettingsContainer)
PresetFrame.Size = UDim2.new(1, 0, 0, 46)
PresetFrame.BackgroundColor3 = BG_PANEL
PresetFrame.BorderSizePixel = 0
Instance.new("UICorner", PresetFrame).CornerRadius = UDim.new(0, 5)

local PresetTitle = Instance.new("TextLabel", PresetFrame)
PresetTitle.Size = UDim2.new(1, 0, 0, 14)
PresetTitle.Position = UDim2.new(0, 0, 0, 4)
PresetTitle.Text = "QUALITY PRESET"
PresetTitle.TextColor3 = ACCENT
PresetTitle.TextSize = 9
PresetTitle.Font = Enum.Font.GothamBold
PresetTitle.BackgroundTransparency = 1

local PresetButtons = {}
local PRESET_COLORS = {
    OFF = Color3.fromRGB(60, 60, 65),
    LOW = Color3.fromRGB(235, 35, 75),
    MED = Color3.fromRGB(235, 120, 35),
    HIGH = Color3.fromRGB(35, 180, 75)
}

local function MakePresetButton(name, xPos, color)
    local B = Instance.new("TextButton", PresetFrame)
    B.Size = UDim2.new(0, 42, 0, 20)
    B.Position = UDim2.new(0, xPos, 0, 20)
    B.Text = name
    B.Font = Enum.Font.GothamBold
    B.TextSize = 7
    B.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    B.TextColor3 = TEXT_DIM
    B.AutoButtonColor = false
    B.BorderSizePixel = 0
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 3)
    
    PresetButtons[name] = B
    
    B.MouseButton1Click:Connect(function()
        for n, btn in pairs(PresetButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
            btn.TextColor3 = TEXT_DIM
        end
        B.BackgroundColor3 = color
        B.TextColor3 = TEXT_PRIMARY
        ApplyPreset(name)
    end)
    
    return B
end

MakePresetButton("OFF", 8, PRESET_COLORS.OFF)
MakePresetButton("LOW", 54, PRESET_COLORS.LOW)
MakePresetButton("MED", 100, PRESET_COLORS.MED)
MakePresetButton("HIGH", 146, PRESET_COLORS.HIGH)

PresetButtons["OFF"].BackgroundColor3 = PRESET_COLORS.OFF
PresetButtons["OFF"].TextColor3 = TEXT_PRIMARY

-- Custom Settings
local LagFrame = Instance.new("Frame", SettingsContainer)
LagFrame.Size = UDim2.new(1, 0, 0, 120)
LagFrame.BackgroundColor3 = BG_PANEL
LagFrame.BorderSizePixel = 0
Instance.new("UICorner", LagFrame).CornerRadius = UDim.new(0, 5)

local LagTitle = Instance.new("TextLabel", LagFrame)
LagTitle.Size = UDim2.new(1, 0, 0, 14)
LagTitle.Position = UDim2.new(0, 0, 0, 4)
LagTitle.Text = "CUSTOM SETTINGS"
LagTitle.TextColor3 = ACCENT
LagTitle.TextSize = 9
LagTitle.Font = Enum.Font.GothamBold
LagTitle.BackgroundTransparency = 1

local function LagToggle(name, setting, xPos, yPos)
    local Lb = Instance.new("TextLabel", LagFrame)
    Lb.Size = UDim2.new(0, 60, 0, 12)
    Lb.Position = UDim2.new(0, xPos, 0, yPos)
    Lb.Text = name
    Lb.TextColor3 = Color3.fromRGB(180, 180, 185)
    Lb.TextSize = 7
    Lb.Font = Enum.Font.GothamMedium
    Lb.TextXAlignment = Enum.TextXAlignment.Left
    Lb.BackgroundTransparency = 1
    
    local B = Instance.new("TextButton", LagFrame)
    B.Size = UDim2.new(0, 26, 0, 12)
    B.Position = UDim2.new(0, xPos + 62, 0, yPos)
    B.Text = "ON"
    B.Font = Enum.Font.GothamBold
    B.TextSize = 6
    B.BackgroundColor3 = BG_BUTTON_ON
    B.TextColor3 = TEXT_PRIMARY
    B.AutoButtonColor = false
    B.BorderSizePixel = 0
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 2)
    
    B.MouseButton1Click:Connect(function()
        LagSettings[setting] = not LagSettings[setting]
        B.Text = LagSettings[setting] and "ON" or "OFF"
        B.BackgroundColor3 = LagSettings[setting] and BG_BUTTON_ON or BG_BUTTON
        B.TextColor3 = LagSettings[setting] and TEXT_PRIMARY or TEXT_DIM
        CurrentPreset = "CUSTOM"
        for n, btn in pairs(PresetButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
            btn.TextColor3 = TEXT_DIM
        end
        if CurrentPreset ~= "OFF" then
            RestoreOriginal()
            ApplyAntiLag()
        end
    end)
end

LagToggle("Textures", "Textures", 10, 20)
LagToggle("Shadows", "Shadows", 10, 36)
LagToggle("Particles", "Particles", 10, 52)
LagToggle("Mesh", "MeshDetail", 10, 68)
LagToggle("Billboards", "Billboards", 10, 84)

LagToggle("Skybox", "Skybox", 118, 20)
LagToggle("Atmosphere", "Atmosphere", 118, 36)
LagToggle("Reflections", "Reflections", 118, 52)
LagToggle("PostFX", "PostProcessing", 118, 68)

-- Collapse/Expand with hardcoded heights
local BASE_HEIGHT = 180
local EXPANDED_HEIGHT = BASE_HEIGHT + 46 + 6 + 120 + 6  -- presets + gap + settings + gap

local isExpanded = false
local function UpdateCollapse()
    if isExpanded then
        SettingsContainer.Visible = true
        CollapseBtn.Text = "▼"
        M.Size = UDim2.new(0, 220, 0, EXPANDED_HEIGHT)
    else
        SettingsContainer.Visible = false
        CollapseBtn.Text = "▶"
        M.Size = UDim2.new(0, 220, 0, BASE_HEIGHT)
    end
    Clamp()
end

CollapseBtn.MouseButton1Click:Connect(function()
    isExpanded = not isExpanded
    UpdateCollapse()
end)

-- Auto-reapply
workspace.DescendantAdded:Connect(function(obj)
    if CurrentPreset == "OFF" then return end
    task.wait(0.1)
    pcall(function()
        if obj:IsA("BasePart") and not obj:IsA("Terrain") and LagSettings.Textures then
            SaveOriginalState(obj)
            obj.Material = Enum.Material.SmoothPlastic
            if obj:IsA("MeshPart") then obj.TextureID = "" end
        elseif (obj:IsA("Texture") or obj:IsA("Decal")) and LagSettings.Textures then
            SaveOriginalState(obj)
            obj.Transparency = 1
        elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail")) and LagSettings.Particles then
            SaveOriginalState(obj)
            obj.Enabled = false
        elseif (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) and LagSettings.Shadows then
            SaveOriginalState(obj)
            obj.Enabled = false
        elseif obj:IsA("BillboardGui") and LagSettings.Billboards then
            SaveOriginalState(obj)
            obj.Enabled = false
        end
    end)
end)

-- Face ESP
local function IT(p)
    if p == LP or (LP.Team and p.Team and LP.Team == p.Team) then return true end
    return false
end

game:GetService("RunService").RenderStepped:Connect(function()
    if not FaceESP then return end
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP and not IT(p) and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local torso = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso")
            if not torso then continue end
            local d = ActiveBeams[p]
            if not d then
                local a0, a1 = Instance.new("Attachment", workspace.Terrain), Instance.new("Attachment", workspace.Terrain)
                local b = Instance.new("Beam", workspace.Terrain)
                b.Attachment0 = a0
                b.Attachment1 = a1
                b.Width0 = 0.35
                b.Width1 = 0.35
                b.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                b.FaceCamera = true
                b.LightEmission = 0.3
                b.LightInfluence = 0
                b.ZOffset = 2
                b.Transparency = NumberSequence.new(0)
                d = {Beam = b, A0 = a0, A1 = a1}
                ActiveBeams[p] = d
            end
            local lv = torso.CFrame.LookVector
            local f = Vector3.new(lv.X, 0, lv.Z).Unit
            if f.Magnitude < 0.001 then f = Vector3.new(0, 0, -1) end
            d.A0.WorldPosition = torso.Position + (f * 0.6)
            d.A1.WorldPosition = torso.Position + (f * 55)
        elseif ActiveBeams[p] then
            pcall(function()
                ActiveBeams[p].Beam:Destroy()
                ActiveBeams[p].A0:Destroy()
                ActiveBeams[p].A1:Destroy()
            end)
            ActiveBeams[p] = nil
        end
    end
end)

P.PlayerRemoving:Connect(function(p)
    if ActiveBeams[p] then
        pcall(function()
            ActiveBeams[p].Beam:Destroy()
            ActiveBeams[p].A0:Destroy()
            ActiveBeams[p].A1:Destroy()
        end)
        ActiveBeams[p] = nil
    end
end)

-- Init screen
task.spawn(function()
    local It = Instance.new("Frame", UI)
    It.Size = UDim2.new(0, 180, 0, 35)
    It.Position = UDim2.new(0.5, -90, 0.45, -17)
    It.BackgroundColor3 = BG_DARK
    It.BorderSizePixel = 0
    Instance.new("UICorner", It).CornerRadius = UDim.new(0, 6)
    
    local IS = Instance.new("UIStroke", It)
    IS.Color = ACCENT
    IS.Thickness = 1.2
    IS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local Lb = Instance.new("TextLabel", It)
    Lb.Size = UDim2.new(1, 0, 0, 14)
    Lb.Position = UDim2.new(0, 0, 0, 5)
    Lb.Text = "INITIALIZING..."
    Lb.TextColor3 = Color3.fromRGB(150, 150, 155)
    Lb.TextSize = 8
    Lb.Font = Enum.Font.GothamBold
    Lb.BackgroundTransparency = 1
    
    local BB = Instance.new("Frame", It)
    BB.Size = UDim2.new(1, -24, 0, 2)
    BB.Position = UDim2.new(0, 12, 1, -10)
    BB.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    BB.BorderSizePixel = 0
    Instance.new("UICorner", BB).CornerRadius = UDim.new(1, 0)
    
    local BF = Instance.new("Frame", BB)
    BF.Size = UDim2.new(0, 0, 1, 0)
    BF.BackgroundColor3 = ACCENT
    BF.BorderSizePixel = 0
    Instance.new("UICorner", BF).CornerRadius = UDim.new(1, 0)
    
    local G = Instance.new("UIGradient", BF)
    G.Color = ColorSequence.new(ACCENT, Color3.fromRGB(255, 80, 120))
    
    T:Create(BF, TweenInfo.new(1.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    
    task.wait(2.0)
    
    local o = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    T:Create(It, o, {BackgroundTransparency = 1}):Play()
    T:Create(IS, o, {Transparency = 1}):Play()
    T:Create(BB, o, {BackgroundTransparency = 1}):Play()
    T:Create(BF, o, {BackgroundTransparency = 1}):Play()
    T:Create(Lb, o, {TextTransparency = 1}):Play()
    
    task.wait(0.25)
    It:Destroy()
    M.Visible = true
    Tg.Visible = true
    Clamp()
    isExpanded = false
    UpdateCollapse()
end)

-- Shiftlock
local function SU(ch)
    local hm = ch:WaitForChild("Humanoid")
    hm.Jumping:Connect(function()
        if not SL then return end
        if JT then task.cancel(JT) end
        local l = C.CFrame.LookVector
        TD, JP = Vector3.new(l.X, 0, l.Z).Unit, true
        JT = task.spawn(function()
            task.wait(0.4)
            JP, TD = false, nil
        end)
    end)
    hm.StateChanged:Connect(function(_, s)
        if s == Enum.HumanoidStateType.Landed then
            JP, TD = false, nil
            if JT then task.cancel(JT) end
        end
    end)
end

if LP.Character then SU(LP.Character) end
LP.CharacterAdded:Connect(SU)

game:GetService("RunService").RenderStepped:Connect(function()
    if not SL or not JP or not TD then return end
    local ch = LP.Character
    local rt, hm = ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChildOfClass("Humanoid")
    if rt and hm and hm.Health > 0 then
        U.MouseBehavior = Enum.MouseBehavior.LockCenter
        rt.CFrame = CFrame.new(rt.Position, rt.Position + TD)
        hm.CameraOffset = hm.CameraOffset:LinearInterpolate(Vector3.new(2.5, 2, 0), 0.2)
    end
end)
