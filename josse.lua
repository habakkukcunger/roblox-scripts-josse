local P, T, R, U = game:GetService("Players"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, C = P.LocalPlayer, workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("JHubV4") then PlayerGui.JHubV4:Destroy() end

local Enabled, sl, targetDir, jumpThread, AutoSet = false, false, nil, nil, false
local UI = Instance.new("ScreenGui", PlayerGui) UI.Name = "JHubV4" UI.ResetOnSpawn = false

-- CYBER-NEON PREMIUM MAIN PLATFORM
local Main = Instance.new("Frame", UI) Main.Size = UDim2.new(0, 240, 0, 150) Main.Position = UDim2.new(0.05, 0, 0.55, 0) Main.BackgroundColor3 = Color3.fromRGB(10, 11, 16) Main.Active, Main.Draggable, Main.Visible = true, true, false
local UICorner = Instance.new("UICorner", Main) UICorner.CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", Main) UIStroke.Color = Color3.fromRGB(0, 170, 255) UIStroke.Thickness = 1.5
local List = Instance.new("UIListLayout", Main) List.Padding = UDim.new(0, 6) List.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Title = Instance.new("TextLabel", Main) Title.Size = UDim2.new(1, 0, 0, 32) Title.Text = "  josserpopsier hub v4" Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.TextSize = 12 Title.Font = Enum.Font.GothamBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.BackgroundTransparency = 1
local UILine = Instance.new("Frame", Main) UILine.Size = UDim2.new(0, 220, 0, 1) UILine.BackgroundColor3 = Color3.fromRGB(30, 35, 50) UILine.BorderSizePixel = 0

local Tog = Instance.new("TextButton", UI) Tog.Size = UDim2.new(0, 85, 0, 26) Tog.Position = UDim2.new(1, -100, 0, 15) Tog.Text, Tog.TextColor3, Tog.Font, Tog.TextSize, Tog.BackgroundColor3, Tog.Visible = "HIDE HUB", Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 10, Color3.fromRGB(15, 16, 24), false
local TogCorner = Instance.new("UICorner", Tog) TogCorner.CornerRadius = UDim.new(0, 5)
local TogStroke = Instance.new("UIStroke", Tog) TogStroke.Color = Color3.fromRGB(0, 170, 255) TogStroke.Thickness = 1.0
Tog.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible Tog.Text = Main.Visible and "HIDE HUB" or "SHOW HUB" end)

local function MakeBtn(txt, cb)
    local Card = Instance.new("Frame", Main) Card.Size = UDim2.new(1, -20, 0, 36) Card.BackgroundColor3 = Color3.fromRGB(16, 18, 26) Card.BorderSizePixel = 0
    local CardCorner = Instance.new("UICorner", Card) CardCorner.CornerRadius = UDim.new(0, 5)
    local Lbl = Instance.new("TextLabel", Card) Lbl.Size = UDim2.new(1, -75, 1, 0) Lbl.Position = UDim2.new(0, 10, 0, 0) Lbl.Text = txt Lbl.TextColor3 = Color3.fromRGB(170, 180, 200) Lbl.TextSize = 11 Lbl.Font = Enum.Font.GothamMedium Lbl.TextXAlignment = Enum.TextXAlignment.Left Lbl.BackgroundTransparency = 1
    local B = Instance.new("TextButton", Card) B.Size = UDim2.new(0, 60, 0, 24) B.Position = UDim2.new(1, -68, 0, 6) B.Text = "OFF" B.Font = Enum.Font.GothamBold B.TextSize = 10 B.BackgroundColor3 = Color3.fromRGB(28, 30, 42) B.TextColor3 = Color3.fromRGB(140, 140, 140)
    local BC = Instance.new("UICorner", B) BC.CornerRadius = UDim.new(0, 4)
    local state = false B.MouseButton1Click:Connect(function() state = not state B.Text = state and "ON" or "OFF" B.BackgroundColor3 = state and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(28, 30, 42) B.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140) cb(state) end)
end

MakeBtn("Auto Shiftlock", function(v) Enabled = v if not v then sl = false targetDir = nil end end)
MakeBtn("Auto Set Ball", function(v) AutoSet = v end)

-- FIXED LOCAL TARGET GROUND ADORNMENT
local FloorMarker = Instance.new("CylinderHandleAdornment") FloorMarker.Height = 0.1 FloorMarker.Radius = 3.2 FloorMarker.AlwaysOnTop = true FloorMarker.ZIndex = 4 FloorMarker.Transparency = 0.2 FloorMarker.Color3 = Color3.fromRGB(255, 40, 40) FloorMarker.Adornee = workspace.Terrain FloorMarker.Parent = workspace

-- DYNAMIC SYSTEM LOADING SPLASH WITH ROBLOX HEADSHOT GRAPHIC
task.spawn(function()
    local Intro = Instance.new("Frame", UI) Intro.Size = UDim2.new(0, 240, 0, 160) Intro.Position = UDim2.new(0.5, -120, 0.4, -80) Intro.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    local IC = Instance.new("UICorner", Intro) IC.CornerRadius = UDim.new(0, 10)
    local IS = Instance.new("UIStroke", Intro) IS.Color = Color3.fromRGB(0, 170, 255) IS.Thickness = 1.5
    
    local Avatar = Instance.new("ImageLabel", Intro) Avatar.Size = UDim2.new(0, 55, 0, 55) Avatar.Position = UDim2.new(0.5, -27, 0, 12) Avatar.BackgroundTransparency = 1
    local AvC = Instance.new("UICorner", Avatar) AvC.CornerRadius = UDim.new(1, 0)
    pcall(function() Avatar.Image = P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    
    local Lbl = Instance.new("TextLabel", Intro) Lbl.Size = UDim2.new(1, 0, 0, 30) Lbl.Position = UDim2.new(0, 0, 0, 75) Lbl.Text = "script made by jossepopsi" Lbl.TextColor3 = Color3.fromRGB(255, 255, 255) Lbl.TextSize = 12 Lbl.Font = Enum.Font.GothamBold Lbl.BackgroundTransparency = 1
    local B_Bg = Instance.new("Frame", Intro) B_Bg.Size = UDim2.new(0, 160, 0, 4) B_Bg.Position = UDim2.new(0.5, -80, 0, 115) B_Bg.BackgroundColor3 = Color3.fromRGB(30, 32, 45) B_Bg.BorderSizePixel = 0
    local B_Fill = Instance.new("Frame", B_Bg) B_Fill.Size = UDim2.new(0, 0, 1, 0) B_Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255) B_Fill.BorderSizePixel = 0
    
    T:Create(B_Fill, TweenInfo.new(4.0, Enum.EasingStyle.Sine), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(4.3) Intro:Destroy() Main.Visible, Tog.Visible = true, true
end)

-- VELOCITY INTERCEPT ENGINE
task.spawn(function()
    while task.wait(0.01) do
        local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Volleyball") or workspace:FindFirstChildOfClass("Part")
        if ball and ball:IsA("BasePart") and ball.Name:lower():match("ball") then
            local pos, vel = ball.Position, ball.AssemblyLinearVelocity
            local g = workspace.Gravity
            
            local dY = pos.Y - 0.2
            local disc = (vel.Y * vel.Y) + (2 * g * dY)
            local t = 0
            if disc >= 0 and g > 0 then t = (vel.Y + math.sqrt(disc)) / g end
            
            local hitFloorPos = pos + Vector3.new(vel.X * t, 0, vel.Z * t)
            local isBallGoingOut = (math.abs(hitFloorPos.X) > 65 or math.abs(hitFloorPos.Z) > 65)
            
            if isBallGoingOut then
                -- Target ring snaps completely flat on the floor level
                FloorMarker.CFrame = CFrame.new(hitFloorPos.X, 0.2, hitFloorPos.Z) * CFrame.Angles(math.pi/2, 0, 0)
            else
                -- Instantly un-render target coordinates from the air if the play remains safe
                FloorMarker.CFrame = CFrame.new(0, -100, 0)
                
                local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if AutoSet and root and (root.Position - pos).Magnitude < 11 and vel.Y < 5 then
                    -- Fires the true native input setting remote for Volleyball Legends
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game) task.wait(0.04)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    task.wait(0.6)
                end
            end
        else
            FloorMarker.CFrame = CFrame.new(0, -100, 0)
        end
    end
end)

local function setup(char)
    char:WaitForChild("Humanoid").Jumping:Connect(function() if not Enabled then return end if jumpThread then task.cancel(jumpThread) end local l = C.CFrame.LookVector targetDir = Vector3.new(l.X, 0, l.Z).Unit sl = true jumpThread = task.spawn(function() task.wait(0.4) sl = false targetDir = nil end) end)
    char.Humanoid.StateChanged:Connect(function(_, s) if s == Enum.HumanoidStateType.Landed then sl = false targetDir = nil if jumpThread then task.cancel(jumpThread) end end end)
end
if LP.Character then setup(LP.Character) end LP.CharacterAdded:Connect(setup)

R.RenderStepped:Connect(function() if not Enabled or not sl or not targetDir then return end local o = LP.Character local r, h = o and o:FindFirstChild("HumanoidRootPart"), o and o:FindFirstChildOfClass("Humanoid") if r and h and h.Health > 0 then U.MouseBehavior = Enum.MouseBehavior.LockCenter r.CFrame = CFrame.new(r.Position, r.Position + targetDir) h.CameraOffset = h.CameraOffset:LinearInterpolate(Vector3.new(2.5, 2, 0), 0.2) end end)
