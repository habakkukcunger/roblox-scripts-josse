local P, T, R, U = game:GetService("Players"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, C = P.LocalPlayer, workspace.CurrentCamera
local PG = LP:WaitForChild("PlayerGui")
if PG:FindFirstChild("JHubV6") then PG.JHubV6:Destroy() end

local SL, JP, TD, JT, FaceESP = false, false, nil, nil, false
local ActiveBeams = {}

local UI = Instance.new("ScreenGui", PG) UI.Name = "JHubV6" UI.ResetOnSpawn = false

local M = Instance.new("Frame", UI) M.Size = UDim2.new(0, 220, 0, 140) M.Position = UDim2.new(0.05, 0, 0.35, 0) M.BackgroundColor3 = Color3.fromRGB(10, 10, 12) M.BackgroundTransparency = 0.15 M.Active, M.Draggable, M.Visible = true, true, false
Instance.new("UICorner", M).CornerRadius = UDim.new(0, 8)
local S = Instance.new("UIStroke", M) S.Color, S.Thickness = Color3.fromRGB(235, 35, 75), 1.2
local L = Instance.new("UIListLayout", M) L.Padding, L.HorizontalAlignment, L.VerticalAlignment = UDim.new(0, 10), Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center

local function ClampToScreen()
    local vs = C.ViewportSize
    local px = math.clamp(M.AbsolutePosition.X, 12, vs.X - M.AbsoluteSize.X - 12)
    local py = math.clamp(M.AbsolutePosition.Y, 35, vs.Y - M.AbsoluteSize.Y - 35)
    M.Position = UDim2.new(0, px, 0, py)
end
M:GetPropertyChangedSignal("Position"):Connect(ClampToScreen)
C:GetPropertyChangedSignal("ViewportSize"):Connect(ClampToScreen)

local Rec = Instance.new("TextButton", UI) Rec.Size = UDim2.new(0.2, 0, 0, 25) Rec.Position = UDim2.new(0.4, 0, 0, 0) Rec.BackgroundTransparency, Rec.Text = 1, ""
Rec.MouseButton1Click:Connect(function() M.Position = UDim2.new(0.05, 0, 0.35, 0) end)

local Tl = Instance.new("TextLabel", M) Tl.Size = UDim2.new(1, -20, 0, 16) Tl.Text = "JOSSERPOPSIER // V6" Tl.TextColor3 = Color3.fromRGB(255, 255, 255) Tl.TextSize, Tl.Font, Tl.TextXAlignment, Tl.BackgroundTransparency = 11, Enum.Font.GothamBold, Enum.TextXAlignment.Left, 1

local Tg = Instance.new("TextButton", UI) Tg.Size = UDim2.new(0, 65, 0, 24) Tg.Position = UDim2.new(1, -85, 0, 45) Tg.Text, Tg.TextColor3, Tg.Font, Tg.TextSize, Tg.BackgroundColor3, Tg.Visible = "HIDE", Color3.fromRGB(240, 240, 240), Enum.Font.GothamBold, 9, Color3.fromRGB(15, 15, 18), false
Instance.new("UICorner", Tg).CornerRadius = UDim.new(0, 5)
local TS = Instance.new("UIStroke", Tg) TS.Color, TS.Thickness = Color3.fromRGB(235, 35, 75), 1
Tg.MouseButton1Click:Connect(function() M.Visible = not M.Visible Tg.Text = M.Visible and "HIDE" or "SHOW" end)

local function MB(txt, cb)
    local Cd = Instance.new("Frame", M) Cd.Size, Cd.BackgroundColor3, Cd.BorderSizePixel = UDim2.new(1, -20, 0, 34), Color3.fromRGB(18, 18, 22), 0
    Instance.new("UICorner", Cd).CornerRadius = UDim.new(0, 5)
    local Lb = Instance.new("TextLabel", Cd) Lb.Size, Lb.Position, Lb.Text, Lb.TextColor3, Lb.TextSize, Lb.Font, Lb.TextXAlignment, Lb.BackgroundTransparency = UDim2.new(1, -75, 1, 0), UDim2.new(0, 10, 0, 0), txt, Color3.fromRGB(210, 210, 215), 11, Enum.Font.GothamMedium, Enum.TextXAlignment.Left, 1
    
    local B = Instance.new("TextButton", Cd) B.Size, B.Position, B.Text, B.Font, B.TextSize, B.BackgroundColor3, B.TextColor3 = UDim2.new(0, 48, 0, 20), UDim2.new(1, -58, 0, 7), "OFF", Enum.Font.GothamBold, 9, Color3.fromRGB(28, 28, 34), Color3.fromRGB(140, 140, 145)
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)
    
    local st = false B.MouseButton1Click:Connect(function()
        st = not st 
        B.Text = st and "ON" or "OFF"
        B.BackgroundColor3 = st and Color3.fromRGB(235, 35, 75) or Color3.fromRGB(28, 28, 34)
        B.TextColor3 = st and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 145)
        cb(st)
    end)
end

local function ClearAllBeams()
    for _, item in pairs(ActiveBeams) do pcall(function() item.Beam:Destroy() item.A0:Destroy() item.A1:Destroy() end) end
    table.clear(ActiveBeams)
end

MB("Auto Shiftlock", function(v) SL = v if not v then JP, TD = false, nil end end)
MB("Player Face Lines", function(v) FaceESP = v if not v then ClearAllBeams() end end)

local function IsTeammate(player)
    if player == LP then return true end
    if LP.Team and player.Team and LP.Team == player.Team then return true end
    if LP.TeamColor and player.TeamColor and LP.TeamColor == player.TeamColor then return true end
    local myChar, targetChar = LP.Character, player.Character
    if myChar and targetChar and myChar.Parent == targetChar.Parent and myChar.Parent.Name:lower():match("team") then return true end
    return false
end

R.RenderStepped:Connect(function()
    if not FaceESP then return end
    for _, player in ipairs(P:GetPlayers()) do
        if player ~= LP and not IsTeammate(player) and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local root = player.Character:FindFirstChild("HumanoidRootPart") or head
            local data = ActiveBeams[player]
            
            if not data then
                local a0, a1, beam = Instance.new("Attachment", workspace.Terrain), Instance.new("Attachment", workspace.Terrain), Instance.new("Beam", workspace.Terrain)
                beam.Attachment0, beam.Attachment1 = a0, a1
                beam.Width0, beam.Width1, beam.Color = 0.45, 0.20, ColorSequence.new(Color3.fromRGB(0, 255, 120))
                beam.FaceCamera, beam.LightEmission, beam.LightInfluence, beam.ZOffset = true, 1.0, 0.0, 2
                data = {Beam = beam, A0 = a0, A1 = a1}
                ActiveBeams[player] = data
            end
            
            local look = root.CFrame.LookVector
            local flat = Vector3.new(look.X, 0, look.Z).Unit
            data.A0.WorldPosition = head.Position + (flat * 0.6)
            data.A1.WorldPosition = head.Position + (flat * 30)
        else
            if ActiveBeams[player] then pcall(function() ActiveBeams[player].Beam:Destroy() ActiveBeams[player].A0:Destroy() ActiveBeams[player].A1:Destroy() end) ActiveBeams[player] = nil end
        end
    end
end)

P.PlayerRemoving:Connect(function(p) if ActiveBeams[p] then pcall(function() ActiveBeams[p].Beam:Destroy() ActiveBeams[p].A0:Destroy() ActiveBeams[p].A1:Destroy() end) ActiveBeams[p] = nil end end)

task.spawn(function()
    local It = Instance.new("Frame", UI) It.Size, It.Position, It.BackgroundColor3 = UDim2.new(0, 160, 0, 30), UDim2.new(0.5, -80, 0.45, -15), Color3.fromRGB(10, 10, 12)
    Instance.new("UICorner", It).CornerRadius = UDim.new(0, 6)
    local IS = Instance.new("UIStroke", It) IS.Color, IS.Thickness = Color3.fromRGB(235, 35, 75), 1.2
    
    local BB = Instance.new("Frame", It) BB.Size, BB.Position, BB.BackgroundColor3, BB.BorderSizePixel = UDim2.new(1, -24, 0, 3), UDim2.new(0, 12, 0.5, -1), Color3.fromRGB(24, 24, 30), 0
    Instance.new("UICorner", BB).CornerRadius = UDim.new(1, 0)
    local BF = Instance.new("Frame", BB) BF.Size, BF.BackgroundColor3, BF.BorderSizePixel = UDim2.new(0, 0, 1, 0), Color3.fromRGB(235, 35, 75), 0
    Instance.new("UICorner", BF).CornerRadius = UDim.new(1, 0)
    
    T:Create(BF, TweenInfo.new(1.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(2.0)
    
    local out = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    T:Create(It, out, {BackgroundTransparency = 1}):Play()
    T:Create(IS, out, {Transparency = 1}):Play()
    T:Create(BB, out, {BackgroundTransparency = 1}):Play()
    T:Create(BF, out, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.25) It:Destroy() M.Visible, Tg.Visible = true, true
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
