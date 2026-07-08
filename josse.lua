local P, T, R, U = game:GetService("Players"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, C = P.LocalPlayer, workspace.CurrentCamera
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("JHubV6") then PG.JHubV6:Destroy() end

local SL, JP, TD, JT = false, false, nil, nil
local UI = Instance.new("ScreenGui", PG) UI.Name = "JHubV6" UI.ResetOnSpawn = false

-- SLEEK GLASSMORPHIC MINIMALIST DESIGN (NO CORNY SCI-FI LOGS)
local M = Instance.new("Frame", UI) M.Size = UDim2.new(0, 230, 0, 100) M.Position = UDim2.new(0.05, 0, 0.35, 0) M.BackgroundColor3 = Color3.fromRGB(15, 15, 15) M.BackgroundTransparency = 0.2 M.Active, M.Draggable, M.Visible = true, true, false
Instance.new("UICorner", M).CornerRadius = UDim.new(0, 10)
local S = Instance.new("UIStroke", M) S.Color, S.Thickness = Color3.fromRGB(220, 20, 60), 1.5
local L = Instance.new("UIListLayout", M) L.Padding, L.HorizontalAlignment, L.VerticalAlignment = UDim.new(0, 12), Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center

-- RIGID SCREEN CLAMP (FORCES UI TO STAY 100% IN BOUNDS)
local function ClampToScreen()
    M.Position = UDim2.new(
        0, math.clamp(M.AbsolutePosition.X, 10, C.ViewportSize.X - M.AbsoluteSize.X - 10),
        0, math.clamp(M.AbsolutePosition.Y, 30, C.ViewportSize.Y - M.AbsoluteSize.Y - 30)
    )
end
M:GetPropertyChangedSignal("Position"):Connect(ClampToScreen)
C:GetPropertyChangedSignal("ViewportSize"):Connect(ClampToScreen)

-- MINIMAL TEXT VIEWPORT (CLEAN INTERFACE)
local Tl = Instance.new("TextLabel", M) Tl.Size = UDim2.new(1, -24, 0, 20) Tl.Text = "JOSSERPOPSIER HUB V6" Tl.TextColor3 = Color3.fromRGB(240, 240, 240) Tl.TextSize, Tl.Font, Tl.TextXAlignment, Tl.BackgroundTransparency = 13, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 1

-- TOP CONTROL BAR SWITCH
local Tg = Instance.new("TextButton", UI) Tg.Size = UDim2.new(0, 80, 0, 26) Tg.Position = UDim2.new(1, -100, 0, 45) Tg.Text, Tg.TextColor3, Tg.Font, Tg.TextSize, Tg.BackgroundColor3, Tg.Visible = "CLOSE", Color3.fromRGB(240, 240, 240), Enum.Font.GothamBold, 10, Color3.fromRGB(20, 20, 20), false
Instance.new("UICorner", Tg).CornerRadius = UDim.new(0, 6)
local TS = Instance.new("UIStroke", Tg) TS.Color, TS.Thickness = Color3.fromRGB(220, 20, 60), 1
Tg.MouseButton1Click:Connect(function() M.Visible = not M.Visible Tg.Text = M.Visible and "CLOSE" or "OPEN" end)

local function MB(txt, cb)
    local Cd = Instance.new("Frame", M) Cd.Size, Cd.BackgroundColor3, Cd.BorderSizePixel = UDim2.new(1, -24, 0, 36), Color3.fromRGB(25, 25, 25), 0
    Instance.new("UICorner", Cd).CornerRadius = UDim.new(0, 6)
    local Lb = Instance.new("TextLabel", Cd) Lb.Size, Lb.Position, Lb.Text, Lb.TextColor3, Lb.TextSize, Lb.Font, Lb.TextXAlignment, Lb.BackgroundTransparency = UDim2.new(1, -80, 1, 0), UDim2.new(0, 12, 0, 0), txt, Color3.fromRGB(200, 200, 200), 12, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 1
    
    local B = Instance.new("TextButton", Cd) B.Size, B.Position, B.Text, B.Font, B.TextSize, B.BackgroundColor3, B.TextColor3 = UDim2.new(0, 55, 0, 22), UDim2.new(1, -67, 0, 7), "OFF", Enum.Font.GothamBold, 10, Color3.fromRGB(35, 35, 35), Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
    
    local st = false B.MouseButton1Click:Connect(function()
        st = not st 
        B.Text = st and "ON" or "OFF"
        B.BackgroundColor3 = st and Color3.fromRGB(220, 20, 60) or Color3.fromRGB(35, 35, 35)
        B.TextColor3 = st and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        cb(st)
    end)
end

MB("Auto Shiftlock", function(v) SL = v if not v then JP, TD = false, nil end end)

-- CLEAN LOADING BAR WITHOUT TEXT CLUTTER
task.spawn(function()
    local It = Instance.new("Frame", UI) It.Size, It.Position, It.BackgroundColor3 = UDim2.new(0, 200, 0, 50), UDim2.new(0.5, -100, 0.45, -25), Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", It).CornerRadius = UDim.new(0, 8)
    local IS = Instance.new("UIStroke", It) IS.Color, IS.Thickness = Color3.fromRGB(220, 20, 60), 1.5
    
    local BB = Instance.new("Frame", It) BB.Size, BB.Position, BB.BackgroundColor3, BB.BorderSizePixel = UDim2.new(1, -32, 0, 4), UDim2.new(0, 16, 0.5, -2), Color3.fromRGB(30, 30, 30), 0
    Instance.new("UICorner", BB).CornerRadius = UDim.new(1, 0)
    local BF = Instance.new("Frame", BB) BF.Size, BF.BackgroundColor3, BF.BorderSizePixel = UDim2.new(0, 0, 1, 0), Color3.fromRGB(220, 20, 60), 0
    Instance.new("UICorner", BF).CornerRadius = UDim.new(1, 0)
    
    T:Create(BF, TweenInfo.new(2.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(2.4)
    
    local out = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    T:Create(It, out, {BackgroundTransparency = 1}):Play()
    T:Create(IS, out, {Transparency = 1}):Play()
    T:Create(BB, out, {BackgroundTransparency = 1}):Play()
    T:Create(BF, out, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.3) It:Destroy() M.Visible, Tg.Visible = true, true
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
