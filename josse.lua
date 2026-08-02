local success, err = pcall(function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    
    local LP = Players.LocalPlayer
    local C = workspace.CurrentCamera
    
    -- Delta iOS: PlayerGui might not exist yet, wait for it
    local PG
    local attempts = 0
    repeat
        PG = LP:FindFirstChild("PlayerGui")
        attempts = attempts + 1
        if not PG then task.wait(0.1) end
    until PG or attempts > 50
    
    if not PG then
        warn("JHubV6: PlayerGui not found after 5 seconds!")
        return
    end
    
    -- Delta iOS: Destroy existing safely
    local existing = PG:FindFirstChild("JHubV6")
    if existing then
        pcall(function() existing:Destroy() end)
        task.wait(0.1)
    end

    local SL, FaceESP, ActiveBeams, JP, TD, JT = false, false, {}, false, nil, nil
    
    -- Delta iOS: Create ScreenGui with specific properties
    local UI = Instance.new("ScreenGui")
    UI.Name = "JHubV6"
    UI.ResetOnSpawn = false
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
    M.Size = UDim2.new(0, 220, 0, 246)  -- [CHANGED] 210 -> 246 to fit 5th toggle
    M.Position = UDim2.new(0.05, 0, 0.35, 0)
    M.BackgroundColor3 = BG_DARK
    M.BackgroundTransparency = 0.08
    M.Active = true
    M.Draggable = true
    M.Visible = false
    M.BorderSizePixel = 0
    M.ClipsDescendants = true
    M.Parent = UI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = M

    local S = Instance.new("UIStroke")
    S.Color = ACCENT
    S.Thickness = 1.2
    S.Parent = M

    -- Padding
    local MP = Instance.new("UIPadding")
    MP.PaddingLeft = UDim.new(0, 10)
    MP.PaddingRight = UDim.new(0, 10)
    MP.PaddingTop = UDim.new(0, 8)
    MP.PaddingBottom = UDim.new(0, 8)
    MP.Parent = M

    -- Layout
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 6)
    L.HorizontalAlignment = Enum.HorizontalAlignment.Center
    L.VerticalAlignment = Enum.VerticalAlignment.Top
    L.Parent = M

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
    local Tl = Instance.new("TextLabel")
    Tl.Size = UDim2.new(1, 0, 0, 16)
    Tl.Text = "JOSSERPOPSIER"
    Tl.TextColor3 = TEXT_PRIMARY
    Tl.TextSize = 12
    Tl.Font = Enum.Font.GothamBold
    Tl.BackgroundTransparency = 1
    Tl.TextXAlignment = Enum.TextXAlignment.Center
    Tl.Parent = M

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

    local tgCorner = Instance.new("UICorner")
    tgCorner.CornerRadius = UDim.new(0, 5)
    tgCorner.Parent = Tg

    local TgS = Instance.new("UIStroke")
    TgS.Color = ACCENT
    TgS.Thickness = 1
    TgS.Parent = Tg

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
        local Cd = Instance.new("Frame")
        Cd.Size = UDim2.new(1, 0, 0, 30)
        Cd.BackgroundColor3 = BG_PANEL
        Cd.BorderSizePixel = 0
        Cd.Parent = parent

        local cdCorner = Instance.new("UICorner")
        cdCorner.CornerRadius = UDim.new(0, 5)
        cdCorner.Parent = Cd
        
        local Lb = Instance.new("TextLabel")
        Lb.Size = UDim2.new(1, -70, 1, 0)
        Lb.Position = UDim2.new(0, 10, 0, 0)
        Lb.Text = text
        Lb.TextColor3 = TEXT_SECONDARY
        Lb.TextSize = 11
        Lb.Font = Enum.Font.GothamMedium
        Lb.TextXAlignment = Enum.TextXAlignment.Left
        Lb.BackgroundTransparency = 1
        Lb.Parent = Cd
        
        local B = Instance.new("TextButton")
        B.Size = UDim2.new(0, 48, 0, 18)
        B.Position = UDim2.new(1, -58, 0.5, -9)
        B.Text = "OFF"
        B.Font = Enum.Font.GothamBold
        B.TextSize = 9
        B.BackgroundColor3 = BG_BUTTON
        B.TextColor3 = TEXT_DIM
        B.AutoButtonColor = false
        B.BorderSizePixel = 0
        B.Parent = Cd

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 4)
        bCorner.Parent = B
        
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
        elseif obj:IsA("BillboardGui") then
            state.Enabled = obj.Enabled
        end
        if next(state) then OriginalStates[obj] = state end
    end

    local function ApplyAntiLag()
        local lighting = game:GetService("Lighting")
        
        local sky = lighting:FindFirstChildOfClass("Sky")
        if sky and not SavedSkybox then
            SavedSkybox = sky:Clone()
            sky.Parent = nil
        end
        
        local atm = lighting:FindFirstChildOfClass("Atmosphere")
        if atm and not SavedAtmosphere then
            SavedAtmosphere = atm:Clone()
            atm.Parent = nil
        end
        
        for _, cloud in ipairs(lighting:GetChildren()) do
            if cloud:IsA("Clouds") then
                pcall(function() cloud.Parent = nil end)
            end
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
        
        if SavedSkybox then
            pcall(function() SavedSkybox.Parent = lighting end)
            SavedSkybox = nil
        end
        
        if SavedAtmosphere then
            pcall(function() SavedAtmosphere.Parent = lighting end)
            SavedAtmosphere = nil
        end
        
        pcall(function()
            if SavedLightingTech then
                lighting.Technology = SavedLightingTech
                SavedLightingTech = nil
            end
            if SavedGlobalShadows ~= nil then
                lighting.GlobalShadows = SavedGlobalShadows
                SavedGlobalShadows = nil
            end
        end)
        
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

    CreateToggleRow(M, "Anti-Lag", function(v)
        AntiLagEnabled = v
        if v then
            ApplyAntiLag()
        else
            RestoreOriginal()
        end
    end)

    -- ==================== LEAD FEET SYSTEM ====================
    local LeadFeetEnabled = false

    -- Floating Lead Feet button
    local LFBtn = Instance.new("TextButton")
    LFBtn.Size = UDim2.new(0, 90, 0, 36)
    LFBtn.Position = UDim2.new(0.5, -45, 0.75, 0)
    LFBtn.Text = "LEAD FEET"
    LFBtn.TextColor3 = TEXT_PRIMARY
    LFBtn.Font = Enum.Font.GothamBold
    LFBtn.TextSize = 11
    LFBtn.BackgroundColor3 = BG_DARK
    LFBtn.Visible = false
    LFBtn.AutoButtonColor = false
    LFBtn.BorderSizePixel = 0
    LFBtn.Active = true
    LFBtn.Parent = UI

    local lfCorner = Instance.new("UICorner")
    lfCorner.CornerRadius = UDim.new(0, 6)
    lfCorner.Parent = LFBtn

    local lfStroke = Instance.new("UIStroke")
    lfStroke.Color = ACCENT
    lfStroke.Thickness = 1.4
    lfStroke.Parent = LFBtn

    -- Make the floating button draggable
    local draggingLF = false
    local dragStartLF, startPosLF

    LFBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingLF = true
            dragStartLF = input.Position
            startPosLF = LFBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    draggingLF = false
                end
            end)
        end
    end)

    LFBtn.InputChanged:Connect(function(input)
        if draggingLF and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartLF
            local vs = C.ViewportSize
            local newX = math.clamp(startPosLF.X.Offset + delta.X, 0, vs.X - LFBtn.AbsoluteSize.X)
            local newY = math.clamp(startPosLF.Y.Offset + delta.Y, 0, vs.Y - LFBtn.AbsoluteSize.Y)
            LFBtn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- Keep floating button on screen when resizing
    C:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local vs = C.ViewportSize
        local newX = math.clamp(LFBtn.AbsolutePosition.X, 0, vs.X - LFBtn.AbsoluteSize.X)
        local newY = math.clamp(LFBtn.AbsolutePosition.Y, 0, vs.Y - LFBtn.AbsoluteSize.Y)
        LFBtn.Position = UDim2.new(0, newX, 0, newY)
    end)

    -- Lead Feet activation function (smooth version)
    local function ActivateLeadFeet()
        local char = LP.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid or humanoid.Health <= 0 then return end
        
        local state = humanoid:GetState()
        if state ~= Enum.HumanoidStateType.Freefall and 
           state ~= Enum.HumanoidStateType.Jumping and
           state ~= Enum.HumanoidStateType.FallingDown then
            return
        end
        
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        
        local result = workspace:Raycast(hrp.Position, Vector3.new(0, -200, 0), params)
        
        if result then
            local targetPos = result.Position + Vector3.new(0, 3, 0)
            local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.rad(hrp.Orientation.Y), 0)
            
            -- Smooth fast drop
            local tweenInfo = TweenInfo.new(
                0.12,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )
            
            local tween = TweenService:Create(hrp, tweenInfo, {
                CFrame = targetCFrame
            })
            
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
            
            tween:Play()
            
            tween.Completed:Connect(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Landed)
            end)
        else
            hrp.AssemblyLinearVelocity = Vector3.new(0, -180, 0)
        end
    end

    LFBtn.MouseButton1Click:Connect(ActivateLeadFeet)

    -- Toggle that shows/hides the floating button
    CreateToggleRow(M, "Lead Feet", function(v)
        LeadFeetEnabled = v
        LFBtn.Visible = v
    end)
    -- ==========================================================

    -- ==================== INF LUCKY SPINS SYSTEM [NEW] ====================
    local InfSpinsEnabled = false
    local SpinTask = nil
    local LastSpinArgs = nil

    local SPIN_KEYWORDS = {"spin", "lucky", "wheel", "gacha", "roll", "crate", "chest"}

    -- Captures the exact args when you manually press spin once,
    -- so it can replay them automatically (executor-dependent, safe fallback)
    pcall(function()
        if not hookmetamethod or not getnamecallmethod then return end
        local OldNC = hookmetamethod(game, "__namecall", newcclosure(function(...)
            local self = ...
            local method = getnamecallmethod()
            if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
                local n = string.lower(self.Name)
                for _, kw in ipairs(SPIN_KEYWORDS) do
                    if string.find(n, kw, 1, true) then
                        LastSpinArgs = {select(2, ...)}
                        break
                    end
                end
            end
            return OldNC(...)
        end))
    end)

    local function FindSpinRemote()
        for _, obj in ipairs(game:GetDescendants()) do
            if not (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then continue end
            local n = string.lower(obj.Name)
            for _, kw in ipairs(SPIN_KEYWORDS) do
                if string.find(n, kw, 1, true) then
                    return obj
                end
            end
        end
        return nil
    end

    local function DoSpin()
        local remote = FindSpinRemote()
        if not remote then return end
        if LastSpinArgs and #LastSpinArgs > 0 then
            if remote:IsA("RemoteFunction") then
                remote:InvokeServer(unpack(LastSpinArgs))
            else
                remote:FireServer(unpack(LastSpinArgs))
            end
        else
            if remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            else
                remote:FireServer()
            end
        end
    end

    local function SpinLoop()
        while InfSpinsEnabled do
            task.wait(0.6)
            pcall(DoSpin)
        end
    end

    CreateToggleRow(M, "Inf Lucky Spins", function(v)
        InfSpinsEnabled = v
        if v then
            if not SpinTask then SpinTask = task.spawn(SpinLoop) end
        else
            if SpinTask then
                task.cancel(SpinTask)
                SpinTask = nil
            end
        end
    end)
    -- ============================================================

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

        local itCorner = Instance.new("UICorner")
        itCorner.CornerRadius = UDim.new(0, 6)
        itCorner.Parent = It
        
        local IS = Instance.new("UIStroke")
        IS.Color = ACCENT
        IS.Thickness = 1.2
        IS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        IS.Parent = It
        
        local Lb = Instance.new("TextLabel")
        Lb.Size = UDim2.new(1, 0, 0, 14)
        Lb.Position = UDim2.new(0, 0, 0, 5)
        Lb.Text = "INITIALIZING..."
        Lb.TextColor3 = Color3.fromRGB(150, 150, 155)
        Lb.TextSize = 8
        Lb.Font = Enum.Font.GothamBold
        Lb.BackgroundTransparency = 1
        Lb.Parent = It
        
        local BB = Instance.new("Frame")
        BB.Size = UDim2.new(1, -24, 0, 2)
        BB.Position = UDim2.new(0, 12, 1, -10)
        BB.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        BB.BorderSizePixel = 0
        BB.Parent = It

        local bbCorner = Instance.new("UICorner")
        bbCorner.CornerRadius = UDim.new(1, 0)
        bbCorner.Parent = BB
        
        local BF = Instance.new("Frame")
        BF.Size = UDim2.new(0, 0, 1, 0)
        BF.BackgroundColor3 = ACCENT
        BF.BorderSizePixel = 0
        BF.Parent = BB

        local bfCorner = Instance.new("UICorner")
        bfCorner.CornerRadius = UDim.new(1, 0)
        bfCorner.Parent = BF
        
        local G = Instance.new("UIGradient")
        G.Color = ColorSequence.new(ACCENT, Color3.fromRGB(255, 80, 120))
        G.Parent = BF
        
        TweenService:Create(BF, TweenInfo.new(1.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        
        task.wait(2.0)
        
        local o = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(It, o, {BackgroundTransparency = 1}):Play()
        TweenService:Create(IS, o, {Transparency = 1}):Play()
        TweenService:Create(BB, o, {BackgroundTransparency = 1}):Play()
        TweenService:Create(BF, o, {BackgroundTransparency = 1}):Play()
        TweenService:Create(Lb, o, {TextTransparency = 1}):Play()
        
        task.wait(0.25)
        pcall(function() It:Destroy() end)
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
    warn("JHubV6 FAILED: " .. tostring(err))
end
