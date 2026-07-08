local P, T, R, U = game:GetService("Players"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, C = P.LocalPlayer, workspace.CurrentCamera
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("JHubV6") then PG.JHubV6:Destroy() end

local SL, JP, TD, JT = false, false, nil, nil
local UI = Instance.new("ScreenGui", PG) UI.Name = "JHubV6" UI.ResetOnSpawn = false

-- CYBER-GLASS MAIN FRAME WITH OVERLAPPING SHADOW GLOW
local M = Instance.new("Frame", UI) M.Size = UDim2.new(0, 250, 0, 115) M.Position = UDim2.new(0.05, 0, 0.55, 0) M.BackgroundColor3 = Color3.fromRGB(8, 2, 4) M.BackgroundTransparency = 0.12 M.Active, M.Draggable, M.Visible = true, true, false
Instance.new("UICorner", M).CornerRadius = UDim.new(0, 14)
local S = Instance.new("UIStroke", M) S.Color, S.Thickness, S.ApplyStrokeMode = Color3.fromRGB(255, 15, 55), 2.5, Enum.ApplyStrokeMode.Border
local L = Instance.new("UIListLayout", M) L.Padding, L.HorizontalAlignment = UDim.new(0, 8), Enum.HorizontalAlignment.Center

local Tl = Instance.new("TextLabel", M) Tl.Size = UDim2.new(1, -20, 0, 36) Tl.Text = "⚡ JOSSERPOPSIER HUB v6" Tl.TextColor3 = Color3.fromRGB(255, 240, 242) Tl.TextSize, Tl.Font, Tl.TextXAlignment, Tl.BackgroundTransparency = 13, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 1
local Ln = Instance.new("Frame", M) Ln.Size, Ln.BackgroundColor3, Ln.BorderSizePixel = UDim2.new(0, 230, 0, 1), Color3.fromRGB(90, 20, 35), 0
Instance.new("UIGradient", Ln).Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 15, 55)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 20, 35)), ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 2, 4))})

local Tg = Instance.new("TextButton", UI) Tg.Size = UDim2.new(0, 90, 0, 28) Tg.Position = UDim2.new(1, -110, 0, 20) Tg.Text, Tg.TextColor3, Tg.Font, Tg.TextSize, Tg.BackgroundColor3, Tg.Visible = "❌ HIDE HUB", Color3.fromRGB(255, 210, 215), Enum.Font.GothamBold, 10, Color3.fromRGB(16, 4, 7), false
Instance.new("UICorner", Tg).CornerRadius = UDim.new(0, 8)
local TS = Instance.new("UIStroke", Tg) TS.Color, TS.Thickness = Color3.fromRGB(255, 20, 60), 1.5
Tg.MouseButton1Click:Connect(function() M.Visible = not M.Visible Tg.Text = M.Visible and "❌ HIDE HUB" or "👁️ SHOW HUB" end)

local function MB(txt, cb)
    local Cd = Instance.new("Frame", M) Cd.Size, Cd.BackgroundColor3, Cd.BorderSizePixel = UDim2.new(1, -16, 0, 40), Color3.fromRGB(24, 6, 10), 0
    Instance.new("UICorner", Cd).CornerRadius = UDim.new(0, 8)
    local CS = Instance.new("UIStroke", Cd) CS.Color, CS.Thickness = Color3.fromRGB(45, 12, 20), 1
    local Lb = Instance.new("TextLabel", Cd) Lb.Size, Lb.Position, Lb.Text, Lb.TextColor3, Lb.TextSize, Lb.Font, Lb.TextXAlignment, Lb.BackgroundTransparency = UDim2.new(1, -85, 1, 0), UDim2.new(0, 12, 0, 0), txt, Color3.fromRGB(245, 200, 205), 11, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 1
    local B = Instance.new("TextButton", Cd) B.Size, B.Position, B.Text, B.Font, B.TextSize, B.BackgroundColor3, B.TextColor3 = UDim2.new(0, 65, 0, 26), UDim2.new(1, -73, 0, 7), "OFF", Enum.Font.GothamBold, 10, Color3.fromRGB(40, 10, 16), Color3.fromRGB(180, 140, 145)
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    local BS = Instance.new("UIStroke", B) BS.Color, BS.Thickness = Color3.fromRGB(90, 20, 35), 1
    local st = false B.MouseButton1Click:Connect(function() st = not st B.Text = st and "ON" or "OFF" B.BackgroundColor3 = st and Color3.fromRGB(255, 15, 55) or Color3.fromRGB(40, 10, 16) B.TextColor3 = st and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 140, 145) BS.Color = st and Color3.fromRGB(255, 100, 120) or Color3.fromRGB(90, 20, 35) cb(st) end)
end

MB("Auto Shiftlock System", function(v) SL = v if not v then JP, TD = false, nil end end)

-- HIGH-END AESTHETIC SPLASH SCREEN INTRO
task.spawn(function()
    local It = Instance.new("Frame", UI) It.Size, It.Position, It.BackgroundColor3 = UDim2.new(0, 260, 0, 180), UDim2.new(0.5, -130, 0.4, -90), Color3.fromRGB(10, 3, 5)
    Instance.new("UICorner", It).CornerRadius = UDim.new(0, 16)
    local IS = Instance.new("UIStroke", It) IS.Color, IS.Thickness = Color3.fromRGB(255, 15, 55), 2.5
    
    local Av = Instance.new("ImageLabel", It) Av.Size, Av.Position, Av.BackgroundColor3 = UDim2.new(0, 64, 0, 64), UDim2.new(0.5, -32, 0, 16), Color3.fromRGB(20, 5, 10)
    Instance.new("UICorner", Av).CornerRadius = UDim.new(1, 0)
    local AS = Instance.new("UIStroke", Av) AS.Color, AS.Thickness = Color3.fromRGB(255, 15, 55), 1.5
    pcall(function() Av.Image = P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    
    local Lb = Instance.new("TextLabel", It) Lb.Size, Lb.Position, Lb.Text, Lb.TextColor3, Lb.TextSize, Lb.Font, Lb.BackgroundTransparency = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 90), "LOADING SYSTEM CONFIG...", Color3.fromRGB(255, 230, 235), 10, Enum.Font.GothamBold, 1
    
    -- ADVANCED LAYERED LOADING PROGRESS BAR (NEON DEPTH EFFECT)
    local BB = Instance.new("Frame", It) BB.Size, BB.Position, BB.BackgroundColor3, BB.BorderSizePixel = UDim2.new(0, 190, 0, 6), UDim2.new(0.5, -95, 0, 130), Color3.fromRGB(35, 10, 15), 0
    Instance.new("UICorner", BB).CornerRadius = UDim.new(1, 0)
    local BBS = Instance.new("UIStroke", BB) BBS.Color, BBS.Thickness = Color3.fromRGB(65, 15, 25), 1
    
    local BF = Instance.new("Frame", BB) BF.Size, BF.BackgroundColor3, BF.BorderSizePixel = UDim2.new(0, 0, 1, 0), Color3.fromRGB(255, 15, 55), 0
    Instance.new("UICorner", BF).CornerRadius = UDim.new(1, 0)
    local G = Instance.new("UIGradient", BF) G.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 5, 35)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 110))})
    
    -- SUB-GLOW UNDERLAY TRACKER FOR HIGH-END ILLUMINATION
    local Glow = Instance.new("Frame", BB) Glow.Size, Glow.BackgroundColor3, Glow.BackgroundTransparency, Glow.BorderSizePixel, Glow.ZIndex = UDim2.new(0, 0, 2, 4), Color3.fromRGB(255, 15, 55), 0.6, 0, 0
    Glow.Position = UDim2.new(0, 0, -0.5, 0)
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(1, 0)
    
    T:Create(BF, TweenInfo.new(3.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    T:Create(Glow, TweenInfo.new(3.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 2, 4)}):Play()
    
    task.wait(3.8)
    T:Create(It, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1, Size = UDim2.new(0, 220, 0, 140), Position = UDim2.new(0.5, -110, 0.4, -70)}):Play()
    T:Create(IS, TweenInfo.new(0.4), {Transparency = 1}):Play()
    T:Create(Av, TweenInfo.new(0.3), {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
    T:Create(AS, TweenInfo.new(0.3), {Transparency = 1}):Play()
    T:Create(Lb, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    T:Create(BB, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    T:Create(BBS, TweenInfo.new(0.3), {Transparency = 1}):Play()
    T:Create(BF, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    T:Create(Glow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    
    task.wait(0.45) It:Destroy() M.Visible, Tg.Visible = true, true
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
