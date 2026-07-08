local P, T, R, U = game:GetService("Players"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, C = P.LocalPlayer, workspace.CurrentCamera
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("JHubV6") then PG.JHubV6:Destroy() end

local SL, JP, TD, JT = false, false, nil, nil
local UI = Instance.new("ScreenGui", PG) UI.Name = "JHubV6" UI.ResetOnSpawn = false

-- CRIMSON & CYBER-NEON DESIGN
local M = Instance.new("Frame", UI) M.Size = UDim2.new(0, 240, 0, 110) M.Position = UDim2.new(0.05, 0, 0.55, 0) M.BackgroundColor3 = Color3.fromRGB(12, 4, 6) M.BackgroundTransparency = 0.15 M.Active, M.Draggable, M.Visible = true, true, false
Instance.new("UICorner", M).CornerRadius = UDim.new(0, 12)
local S = Instance.new("UIStroke", M) S.Color, S.Thickness, S.ApplyStrokeMode = Color3.fromRGB(255, 20, 60), 2, Enum.ApplyStrokeMode.Border
local L = Instance.new("UIListLayout", M) L.Padding, L.HorizontalAlignment = UDim.new(0, 6), Enum.HorizontalAlignment.Center

local Tl = Instance.new("TextLabel", M) Tl.Size = UDim2.new(1, 0, 0, 32) Tl.Text = "  josserpopsier hub v6" Tl.TextColor3 = Color3.fromRGB(255, 230, 235) Tl.TextSize, Tl.Font, Tl.TextXAlignment, Tl.BackgroundTransparency = 12, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 1
local Ln = Instance.new("Frame", M) Ln.Size, Ln.BackgroundColor3, Ln.BorderSizePixel = UDim2.new(0, 220, 0, 1), Color3.fromRGB(60, 15, 25), 0

local Tg = Instance.new("TextButton", UI) Tg.Size = UDim2.new(0, 85, 0, 26) Tg.Position = UDim2.new(1, -100, 0, 15) Tg.Text, Tg.TextColor3, Tg.Font, Tg.TextSize, Tg.BackgroundColor3, Tg.Visible = "HIDE HUB", Color3.fromRGB(255, 230, 235), Enum.Font.GothamBold, 10, Color3.fromRGB(18, 5, 8), false
Instance.new("UICorner", Tg).CornerRadius = UDim.new(0, 6)
local TS = Instance.new("UIStroke", Tg) TS.Color, TS.Thickness = Color3.fromRGB(220, 15, 50), 1.2
Tg.MouseButton1Click:Connect(function() M.Visible = not M.Visible Tg.Text = M.Visible and "HIDE HUB" or "SHOW HUB" end)

local function MB(txt, cb)
    local Cd = Instance.new("Frame", M) Cd.Size, Cd.BackgroundColor3, Cd.BorderSizePixel = UDim2.new(1, -20, 0, 36), Color3.fromRGB(22, 7, 11), 0
    Instance.new("UICorner", Cd).CornerRadius = UDim.new(0, 6)
    local Lb = Instance.new("TextLabel", Cd) Lb.Size, Lb.Position, Lb.Text, Lb.TextColor3, Lb.TextSize, Lb.Font, Lb.TextXAlignment, Lb.BackgroundTransparency = UDim2.new(1, -75, 1, 0), UDim2.new(0, 10, 0, 0), txt, Color3.fromRGB(230, 180, 190), 11, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 1
    local B = Instance.new("TextButton", Cd) B.Size, B.Position, B.Text, B.Font, B.TextSize, B.BackgroundColor3, B.TextColor3 = UDim2.new(0, 60, 0, 24), UDim2.new(1, -68, 0, 6), "OFF", Enum.Font.GothamBold, 10, Color3.fromRGB(35, 10, 16), Color3.fromRGB(160, 130, 135)
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 5)
    local st = false B.MouseButton1Click:Connect(function() st = not st B.Text = st and "ON" or "OFF" B.BackgroundColor3 = st and Color3.fromRGB(255, 20, 60) or Color3.fromRGB(35, 10, 16) B.TextColor3 = st and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 130, 135) cb(st) end)
end

MB("Auto Shiftlock", function(v) SL = v if not v then JP, TD = false, nil end end)

task.spawn(function()
    local It = Instance.new("Frame", UI) It.Size, It.Position, It.BackgroundColor3 = UDim2.new(0, 240, 0, 160), UDim2.new(0.5, -120, 0.4, -80), Color3.fromRGB(12, 4, 6)
    Instance.new("UICorner", It).CornerRadius = UDim.new(0, 12)
    local IS = Instance.new("UIStroke", It) IS.Color, IS.Thickness = Color3.fromRGB(255, 20, 60), 2
    local Av = Instance.new("ImageLabel", It) Av.Size, Av.Position, Av.BackgroundTransparency = UDim2.new(0, 55, 0, 55), UDim2.new(0.5, -27, 0, 12), 1
    Instance.new("UICorner", Av).CornerRadius = UDim.new(1, 0)
    pcall(function() Av.Image = P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    local Lb = Instance.new("TextLabel", It) Lb.Size, Lb.Position, Lb.Text, Lb.TextColor3, Lb.TextSize, Lb.Font, Lb.BackgroundTransparency = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 75), "script made by jossepopsi", Color3.fromRGB(255, 230, 235), 12, Enum.Font.GothamBold, 1
    local BB = Instance.new("Frame", It) BB.Size, BB.Position, BB.BackgroundColor3, BB.BorderSizePixel = UDim2.new(0, 160, 0, 4), UDim2.new(0.5, -80, 0, 115), Color3.fromRGB(45, 12, 18), 0
    local BF = Instance.new("Frame", BB) BF.Size, BF.BackgroundColor3, BF.BorderSizePixel = UDim2.new(0, 0, 1, 0), Color3.fromRGB(255, 20, 60), 0
    T:Create(BF, TweenInfo.new(4, Enum.EasingStyle.Sine), {Size = UDim2.new(1, 0, 1, 0)}):Play() task.wait(4.3) It:Destroy() M.Visible, Tg.Visible = true, true
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
