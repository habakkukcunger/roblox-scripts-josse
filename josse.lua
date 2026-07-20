local success, err = pcall(function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    
    local LP = Players.LocalPlayer
    local C = workspace.CurrentCamera
    local PG = LP:WaitForChild("PlayerGui", 5)
    
    if not PG then
        warn("JHubV6: PlayerGui not found!")
        return
    end
    
    if PG:FindFirstChild("JHubV6") then 
        PG.JHubV6:Destroy() 
    end

    local SL, FaceESP, ActiveBeams, JP, TD, JT = false, false, {}, false, nil, nil
    local UI = Instance.new("ScreenGui")
    UI.Name = "JHubV6"
    UI.ResetOnSpawn = false
    UI.Parent = PG

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
    local M = Instance.new("Frame")
    M.Size = UDim2.new(0, 220, 0, 180)
    M.Position = UDim2.new(0.05, 0, 0.35, 0)
    M.BackgroundColor3 = BG_DARK
    M.BackgroundTransparency = 0.08
    M.Active = true
    M.Draggable = true
    M.Visible = false
    M.BorderSizePixel = 0
    M.ClipsDescendants = true
    M.Parent = UI

    Instance.new("UICorner", M).CornerRadius = UDim.new(0, 8)
    local S = Instance.new("UIStroke", M)
    S.Color = ACCENT
    S.Thickness = 1.2

    -- Padding
    local MP = Instance.new("UIPadding", M)
    MP.PaddingLeft = UDim.new(0, 10)
    MP.PaddingRight = UDim.new(0, 10)
    MP.PaddingTop = UDim.new(0, 8)
    MP.PaddingBottom = UDim.new(0, 8)

    -- Layout
    local L = Instance.new("UIListLayout", M)
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
    local Tl = Instance.new("TextLabel", M)
    Tl.Size = UDim2.new(1, 0, 0, 16)
    Tl.Text = "JOSSERPOPSIER"
    Tl.TextColor3 = TEXT_PRIMARY
    Tl.TextSize = 12
    Tl.Font = Enum.Font.GothamBold
    Tl.BackgroundTransparency = 1
    Tl.TextXAlignment = Enum.TextXAlignment.Center

    -- Toggle Button (HIDE/SHOW)
    local Tg = Instance.new("TextButton")
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
    Tg.Parent = UI

    Instance.new("UICorner", Tg).CornerRadius = UDim.new(0, 5)
    local TgS = Instance.new("UIStroke", Tg)
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

    -- ANTI-LAG SYSTEM
    local AntiLagEnabled = false
    local OriginalStates = {}
    local SavedSkybox, SavedAtmosphere, SavedLightingTech, SavedGlobalShadows = nil, nil, nil, nil

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
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            state.Enabled = obj.Enabled
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            state.Enabled = obj.Enabled
            state.Brightness = obj.Brightness
        elseif obj:IsA("BillboardGui") or obj:IsA("ScreenGui") then
            state.Enabled = obj.Enabled
        end
        if next(state) then OriginalStates[obj] = state end
    end

    local function ApplyAntiLag()
        local lighting = game:GetService("Lighting")
        
        -- Gray sky (remove skybox)
        local sky = lighting:FindFirstChildOfClass("Sky")
        if sky and not SavedSkybox then
            SavedSkybox = sky:Clone()
            sky.Parent = nil
        end
        
        -- Remove atmosphere
        local atm = lighting:FindFirstChildOfClass("Atmosphere")
        if atm and not SavedAtmosphere then
            SavedAtmosphere = atm:Clone()
            atm.Parent = nil
        end
        
        -- Remove clouds
        for _, cloud in ipairs(lighting:GetChildren()) do
            if cloud:IsA("Clouds") then
                pcall(function() cloud.Parent = nil end)
            end
        end
        
        -- Remove post-processing effects
        for _, effect in ipairs(lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("Atmosphere") then
                pcall(function() effect.Enabled = false end)
            end
        end
        
        -- Force gray background
        lighting.Ambient = Color3.fromRGB(128, 128, 128)
        lighting.Brightness = 2
        lighting.ColorShift_Bottom = Color3.fromRGB(128, 128, 128)
        lighting.ColorShift_Top = Color3.fromRGB(128, 128, 128)
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        
        -- Save and change lighting tech
        if not SavedLightingTech then
            SavedLightingTech = lighting.Technology
            SavedGlobalShadows = lighting.GlobalShadows
        end
        lighting.Technology = Enum.Technology.Compatibility
        lighting.GlobalShadows = false
        
        -- Strip all workspace visuals
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                    SaveOriginalState(obj)
                    obj.Material = Enum.Material.SmoothPlastic
                    if obj:IsA("MeshPart") then
                        obj.TextureID = ""
                    end
                elseif (obj:IsA("Texture") or obj:IsA("Decal")) then
                    SaveOriginalState(obj)
                    obj.Transparency = 1
                elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")) then
                    SaveOriginalState(obj)
                    obj.Enabled = false
                elseif (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
                    SaveOriginalState(obj)
                    obj.Enabled = false
                elseif obj:IsA("BillboardGui") then
                    SaveOriginalState(obj)
                    obj.Enabled = false
                elseif obj:IsA("Water") then
                    SaveOriginalState(obj)
                    obj.Transparency = 1
                end
            end)
        end
        
        -- Optimize terrain
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = false
            terrain.WaterColor = Color3.fromRGB(128, 128, 128)
            terrain.WaterTransparency = 1
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end
    end

    local function RestoreOriginal()
        local lighting = game:GetService("Lighting")
        
        -- Restore skybox
        if SavedSkybox then
            SavedSkybox.Parent = lighting
            SavedSkybox = nil
        end
        
        -- Restore atmosphere
        if SavedAtmosphere then
            SavedAtmosphere.Parent = lighting
            SavedAtmosphere = nil
        end
        
        -- Restore lighting
        if SavedLightingTech then
            lighting.Technology = SavedLightingTech
            SavedLightingTech = nil
        end
        if SavedGlobalShadows ~= nil then
            lighting.GlobalShadows = SavedGlobalShadows
            SavedGlobalShadows = nil
        end
        
        -- Restore all objects
        for obj, state in pairs(OriginalStates) do
            pcall(function()
                if obj:IsA("BasePart") then
                    if state.Material then obj.Material = state.Material end
                    if state.Color then obj.Color = state.Color end
                    if obj:IsA("MeshPart") and state.TextureID ~= nil then obj.TextureID = state.TextureID end
                elseif obj:IsA("Texture") or obj:IsA("Decal") then
                    if state.Texture then obj.Texture = state.Texture end
                    if state.Transparency then obj.Transparency = state.Transparency end
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    if state.Enabled ~= nil then obj.Enabled = state.Enabled end
                elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    if state.Enabled ~= nil then obj.Enabled = state.Enabled end
                    if state.Brightness then obj.Brightness = state.Brightness end
                elseif obj:IsA("BillboardGui") then
                    if state.Enabled ~= nil then obj.Enabled = state.Enabled end
                elseif obj:IsA("Water") then
                    if state.Transparency then obj.Transparency = state.Transparency end
                end
            end)
        end
        
        -- Restore terrain
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = true
            terrain.WaterColor = Color3.fromRGB(12, 84, 92)
            terrain.WaterTransparency = 0.3
            terrain.WaterWaveSize = 0.15
            terrain.WaterWaveSpeed = 10
        end
        
        OriginalStates = {}
    end

    -- Anti-Lag Toggle Row
    local AntiLagCd, AntiLagBtn = CreateToggleRow(M, "Anti-Lag", function(v)
        AntiLagEnabled = v
        if v then
            ApplyAntiLag()
        else
            RestoreOriginal()
        end
    end)

    -- Auto-reapply for new objects
    workspace.DescendantAdded:Connect(function(obj)
        if not AntiLagEnabled then return end
        task.wait(0.1)
        pcall(function()
            if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                SaveOriginalState(obj)
                obj.Material = Enum.Material.SmoothPlastic
                if obj:IsA("MeshPart") then obj.TextureID = "" end
            elseif (obj:IsA("Texture") or obj:IsA("Decal")) then
                SaveOriginalState(obj)
                obj.Transparency = 1
            elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")) then
                SaveOriginalState(obj)
                obj.Enabled = false
            elseif (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) then
                SaveOriginalState(obj)
                obj.Enabled = false
            elseif obj:IsA("BillboardGui") then
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

    RunService.RenderStepped:Connect(function()
        if not FaceESP then return end
        for _, p in ipairs(Players:GetPlayers()) do
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

    Players.PlayerRemoving:Connect(function(p)
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
        local It = Instance.new("Frame")
        It.Size = UDim2.new(0, 180, 0, 35)
        It.Position = UDim2.new(0.5, -90, 0.45, -17)
        It.BackgroundColor3 = BG_DARK
        It.BorderSizePixel = 0
        It.Parent = UI
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
        
        TweenService:Create(BF, TweenInfo.new(1.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        
        task.wait(2.0)
        
        local o = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(It, o, {BackgroundTransparency = 1}):Play()
        TweenService:Create(IS, o, {Transparency = 1}):Play()
        TweenService:Create(BB, o, {BackgroundTransparency = 1}):Play()
        TweenService:Create(BF, o, {BackgroundTransparency = 1}):Play()
        TweenService:Create(Lb, o, {TextTransparency = 1}):Play()
        
        task.wait(0.25)
        It:Destroy()
        M.Visible = true
        Tg.Visible = true
        Clamp()
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

    RunService.RenderStepped:Connect(function()
        if not SL or not JP or not TD then return end
        local ch = LP.Character
        local rt, hm = ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChildOfClass("Humanoid")
        if rt and hm and hm.Health > 0 then
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            rt.CFrame = CFrame.new(rt.Position, rt.Position + TD)
            hm.CameraOffset = hm.CameraOffset:LinearInterpolate(Vector3.new(2.5, 2, 0), 0.2)
        end
    end)

    print("JHubV6 loaded successfully!")
end)

if not success then
    warn("JHubV6 FAILED to load: " .. tostring(err))
end
