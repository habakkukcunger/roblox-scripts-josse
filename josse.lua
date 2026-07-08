local P, T, R, U = game:GetService("Players"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, C = P.LocalPlayer, workspace.CurrentCamera
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("JHubV6") then PG.JHubV6:Destroy() end

local SL, JP, TD, JT = false, false, nil, nil
local UI = Instance.new("ScreenGui", PG) UI.Name = "JHubV6" UI.ResetOnSpawn = false

-- SAFE MOBILE FRAME POSITIONING (PERCENTAGE BASED)
local M = Instance.new("Frame", UI) M.Size = UDim2.new(0, 240, 0, 120) M.Position = UDim2.new(0.05, 0, 0.35, 0) M.BackgroundColor3 = Color3.fromRGB(5, 1, 2) M.BackgroundTransparency = 0.1 M.Active, M.Draggable, M.Visible = true, true, false
Instance.new("UICorner", M).CornerRadius = UDim.new(0, 16)

local S = Instance.new("UIStroke", M) S.Color, S.Thickness, S.ApplyStrokeMode = Color3.fromRGB(255, 10, 50), 2.5, Enum.ApplyStrokeMode.Border
local L = Instance.new("UIListLayout", M) L.Padding, L.HorizontalAlignment = UDim.new(0, 10), Enum.HorizontalAlignment.Center

-- OFF-SCREEN FAILSAFE PROTECTION
local function ClampToScreen()
    local viewSize = C.ViewportSize
    local posX = math.clamp(M.AbsolutePosition.X, 10, viewSize.X - M.AbsoluteSize.X - 10)
    local posY = math.clamp(M.AbsolutePosition.Y, 40, viewSize.Y - M.AbsoluteSize.Y - 40)
    M.Position = UDim2.new(0, posX, 0, posY)
end
M:GetPropertyChangedSignal("Position"):Connect(ClampToScreen)
C:GetPropertyChangedSignal("ViewportSize"):Connect(ClampToScreen)

task.spawn(function()
    while task.wait(0.02) do
        local t = tick()
        S.Color = Color3.fromRGB((math.sin(t * 2) * 35) + 220, 10, 50 + (math.cos(t * 2) * 20))
    end
end)

local Tl = Instance.new("TextLabel", M) Tl.Size = UDim2.new(1, -24, 0, 40) Tl.Text = "⚡ JOSSERPOPSIER // V6" Tl.TextColor3 = Color3.fromRGB(255, 245, 247) Tl.TextSize, Tl.Font, Tl.TextXAlignment, Tl.BackgroundTransparency = 12, Enum.Font.Code, Enum.TextXAlignment.Left, 1
local Ln = Instance.new("Frame", M) Ln.Size, Ln.BorderSizePixel = UDim2.new(0, 220, 0, 2), 0
local LnG = Instance.new("UIGradient", Ln) LnG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 10, 50)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 5, 10)), ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 1, 2))})

-- MOBILE ACCESSIBLE TOP-RIGHT BUTTON OVERLAY
local Tg = Instance.new("TextButton", UI) Tg.Size = UDim2.new(0, 110, 0, 30) Tg.Position = UDim2.new(1, -130, 0, 50) Tg.Text, Tg.TextColor3, Tg.Font, Tg.TextSize, Tg.BackgroundColor3, Tg.Visible = "[ TERMINAL: MIN ]", Color3.fromRGB(255, 215, 220) , Enum.Font.Code, 11, Color3.fromRGB(12, 2, 4), false
Instance.new("UICorner", Tg).CornerRadius = UDim.new(0, 8)
local TS = Instance.new("UIStroke", Tg) TS.Color, TS.Thickness = Color3.fromRGB(255, 10, 50), 1.5
Tg.MouseButton1Click:Connect(function() M.Visible = not M.Visible Tg.Text = M.Visible and "[ TERMINAL: MIN ]" or "[ TERMINAL: MAX ]" end)

local function MB(txt, cb)
    local Cd = Instance.new("Frame", M) Cd.Size, Cd.BackgroundColor3, Cd.BorderSizePixel = UDim2.new(1, -16, 0, 44), Color3.fromRGB(18, 3, 6), 0
    Instance.new("UICorner", Cd).CornerRadius = UDim.new(0, 10)
    local CS = Instance.new("UIStroke", Cd) CS.Color, CS.Thickness = Color3.fromRGB(60, 10, 22), 1.2
    
    local Lb = Instance.new("TextLabel", Cd) Lb.Size, Lb.Position, Lb.Text, Lb.TextColor3, Lb.TextSize, Lb.Font, Lb.TextXAlignment, Lb.BackgroundTransparency = UDim2.new(1, -90, 1, 0), UDim2.new(0, 14, 0, 0), txt:upper(), Color3.fromRGB(255, 210, 215), 11, Enum.Font.Code, Enum.TextXAlignment.Left, 1
    local B = Instance.new("TextButton", Cd) B.Size, B.Position, B.Text, B.Font, B.TextSize, B.BackgroundColor3, B.TextColor3 = UDim2.new(0, 70, 0, 26), UDim2.new(1, -80, 0, 9), "ONLINE_FALSE", Enum.Font.Code, 9, Color3.fromRGB(30, 5, 10), Color3.fromRGB(190, 140, 145)
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    local BS = Instance.new("UIStroke", B) BS.Color, BS.Thickness = Color3.fromRGB(80, 15, 30), 1
    
    local st = false B.MouseButton1Click:Connect(function()
        st = not st 
        B.Text = st and "SYSTEM_ACTIVE" or "ONLINE_FALSE"
        B.BackgroundColor3 = st and Color3.fromRGB(255, 10, 50) or Color3.fromRGB(30, 5, 10)
        B.TextColor3 = st and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 140, 145)
        BS.Color = st and Color3.fromRGB(255, 150, 160) or Color3.fromRGB(80, 15, 30)
        cb(st)
    end)
end

MB("Shiftlock Alignment", function(v) SL = v if not v then JP, TD = false, nil end end)

task.spawn(function()
    local It = Instance.new("Frame", UI) It.Size, It.Position, It.BackgroundColor3 = UDim2.new(0, 260, 0, 200), UDim2.new(0.5, -130, 0.4, -100), Color3.fromRGB(8, 1, 3)
    Instance.new("UICorner", It).CornerRadius = UDim.new(0, 20)
    local IS = Instance.new("UIStroke", It) IS.Color, IS.Thickness = Color3.fromRGB(255, 10, 50), 3
    
    local Av = Instance.new("ImageLabel", It) Av.Size, Av.Position, Av.BackgroundColor3 = UDim2.new(0, 72, 0, 72), UDim2.new(0.5, -36, 0, 20), Color3.fromRGB(25, 4, 8)
    Instance.new("UICorner", Av).CornerRadius = UDim.new(1, 0)
    local AS = Instance.new("UIStroke", Av) AS.Color, AS.Thickness = Color3.fromRGB(255, 10, 50), 2
    pcall(function() Av.Image = P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    
    local Flare = Instance.new("Frame", It) Flare.Size, Flare.Position, Flare.BackgroundColor3, Flare.BackgroundTransparency, Flare.BorderSizePixel = UDim2.new(1, -40, 0, 1), UDim2.new(0, 20, 0, 105), Color3.fromRGB(255, 10, 50), 0.4, 0
    local Lb = Instance.new("TextLabel", It) Lb.Size, Lb.Position, Lb.Text, Lb.TextColor3, Lb.TextSize, Lb.Font, Lb.BackgroundTransparency = UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 115), "INITIALIZING MATRIX INTERFACE...", Color3.fromRGB(255, 235, 240), 9, Enum.Font.Code, 1
    
    local BB = Instance.new("Frame", It) BB.Size, BB.Position, BB.BackgroundColor3, BB.BorderSizePixel = UDim2.new(0, 200, 0, 4), UDim2.new(0.5, -100, 0, 145), Color3.fromRGB(30, 4, 8), 0
    Instance.new("UICorner", BB).CornerRadius = UDim.new(1, 0)
    local BBS = Instance.new("UIStroke", BB) BBS.Color, BBS.Thickness = Color3.fromRGB(70, 10, 20), 1
    
    local BF = Instance.new("Frame", BB) BF.Size, BF.BackgroundColor3, BF.BorderSizePixel = UDim2.new(0, 0, 1, 0), Color3.fromRGB(255, 10, 50), 0
    Instance.new("UICorner", BF).CornerRadius = UDim.new(1, 0)
    local G = Instance.new("UIGradient", BF) G.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 0, 25)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 10, 50)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 200))})
    
    local Glow = Instance.new("Frame", BB) Glow.Size, Glow.BackgroundColor3, Glow.BackgroundTransparency, Glow.BorderSizePixel, Glow.ZIndex = UDim2.new(0, 0, 4, 8), Color3.fromRGB(255, 10, 50), 0.7, 0, 0
    Glow.Position = UDim2.new(0, 0, -1.5, 0)
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(1, 0)
    
    local ti = TweenInfo.new(3.0, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    T:Create(BF, ti, {Size = UDim2.new(1, 0, 1, 0)}):Play()
    T:Create(Glow, ti, {Size = UDim2.new(1, 0, 4, 8)}):Play()
    
    task.spawn(function()
        for i = 1, 100 do
            Lb.Text = "CONNECTING PROTOCOL // DATA_STREAM_["..tostring(i).."%]"
            task.wait(2.8 / 100)
        end
        Lb.Text = "HANDSHAKE SUCCESSFUL // READY"
    end)
    
    task.wait(3.4)
    local out = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    T:Create(It, out, {BackgroundTransparency = 1, Size = UDim2.new(0, 200, 0, 120), Position = UDim2.new(0.5, -100, 0.4, -60)}):Play()
    T:Create(IS, out, {Transparency = 1}):Play()
    T:Create(Av, out, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
    T:Create(AS, out, {Transparency = 1}):Play()
    T:Create(Lb, out, {TextTransparency = 1}):Play()
    T:Create(BB, out, {BackgroundTransparency = 1}):Play()
    T:Create(BBS, out, {Transparency = 1}):Play()
    T:Create(BF, out, {BackgroundTransparency = 1}):Play()
    T:Create(Glow, out, {BackgroundTransparency = 1}):Play()
    T:Create(Flare, out, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.45) It:Destroy() M.Visible, Tg.Visible = true, true
    ClampToScreen()
end)

local function SU(ch)
    local hm = ch:WaitForChild("Humanoid")
    hm.Jumping:Connect(function() if not SL then return end if JT then task.cancel(JT) end local l = C.CFrame.LookVector TD, JP = Vector3.new(l.X, 0, l.Z).Unit, true JT = task.spawn(function() task.wait(0.4) JP, TD = false, nil end) end)
    hm.StateChanged:Connect(function(_, s) if s == Enum.HumanoidStateType.Landed then JP, TD = false, nil if JT then task.cancel(JT) end end end)
end
if LP.Character then SU(LP.Character) end LP.CharacterAdded:Connect(SU)

R.RenderStepped:Connect(function()
    if not SL or not JP or not TD then return end
    local ch = LP.Character local rt, hm = ch and ch:FindFirstChild("HumanoidRootPart"), ch and ch:FindFirstChildOfClass("Humanoid")
    if rt and hm and hm.Health > 0 then U.MouseBehavior = Enum.MouseBehavior.LockCenter rt.CFrame = CFrame.new(rt.Position, rt.Position + TD) hm.CameraOffset = hm.CameraOffset:LinearInterpolate(Vector3.new(2.5, 2, 0), 0.2) end
end)
