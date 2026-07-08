local P, T, R, U = game:GetService("Players"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, C = P.LocalPlayer, workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("JHubV3") then PlayerGui.JHubV3:Destroy() end

local Enabled, sl, targetDir, jumpThread, AutoSet = false, false, nil, nil, false
local UI = Instance.new("ScreenGui", PlayerGui) UI.Name = "JHubV3" UI.ResetOnSpawn = false

-- MODERN CYBER-AESTHETIC MAIN CONTAINER
local Main = Instance.new("Frame", UI) Main.Size = UDim2.new(0, 250, 0, 160) Main.Position = UDim2.new(0.05, 0, 0.55, 0) Main.BackgroundColor3 = Color3.fromRGB(11, 12, 18) Main.Active, Main.Draggable, Main.Visible = true, true, false
local UICorner = Instance.new("UICorner", Main) UICorner.CornerRadius = UDim.new(0, 12)
local UIStroke = Instance.new("UIStroke", Main) UIStroke.Color = Color3.fromRGB(0, 170, 255) UIStroke.Thickness = 1.8
local List = Instance.new("UIListLayout", Main) List.Padding = UDim.new(0, 8) List.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Title = Instance.new("TextLabel", Main) Title.Size = UDim2.new(1, 0, 0, 35) Title.Text = "  josserpopsier hub v3" Title.TextColor3 = Color3.fromRGB(255, 255, 255) Title.TextSize = 13 Title.Font = Enum.Font.GothamBold Title.TextXAlignment = Enum.TextXAlignment.Left Title.BackgroundTransparency = 1
local UILine = Instance.new("Frame", Main) UILine.Size = UDim2.new(0, 230, 0, 1) UILine.BackgroundColor3 = Color3.fromRGB(35, 40, 55) UILine.BorderSizePixel = 0

-- NEON TOGGLE CORNER BUTTON
local Tog = Instance.new("TextButton", UI) Tog.Size = UDim2.new(0, 90, 0, 28) Tog.Position = UDim2.new(1, -105, 0, 15) Tog.Text, Tog.TextColor3, Tog.Font, Tog.TextSize, Tog.BackgroundColor3, Tog.Visible = "HIDE HUB", Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 11, Color3.fromRGB(20, 22, 33), false
local TogCorner = Instance.new("UICorner", Tog) TogCorner.CornerRadius = UDim.new(0, 6)
local TogStroke = Instance.new("UIStroke", Tog) TogStroke.Color = Color3.fromRGB(0, 170, 255) TogStroke.Thickness = 1.2
Tog.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible Tog.Text = Main.Visible and "HIDE HUB" or "SHOW HUB" end)

local function MakeBtn(txt, cb)
    local Card = Instance.new("Frame", Main) Card.Size = UDim2.new(1, -20, 0, 38) Card.BackgroundColor3 = Color3.fromRGB(18, 20, 28) Card.BorderSizePixel = 0
    local CardCorner = Instance.new("UICorner", Card) CardCorner.CornerRadius = UDim.new(0, 6)
    local Lbl = Instance.new("TextLabel", Card) Lbl.Size = UDim2.new(1, -80, 1, 0) Lbl.Position = UDim2.new(0, 10, 0, 0) Lbl.Text = txt Lbl.TextColor3 = Color3.fromRGB(180, 190, 210) Lbl.TextSize = 12 Lbl.Font = Enum.Font.GothamMedium Lbl.TextXAlignment = Enum.TextXAlignment.Left Lbl.BackgroundTransparency = 1
    local B = Instance.new("TextButton", Card) B.Size = UDim2.new(0, 65, 0, 26) B.Position = UDim2.new(1, -72, 0, 6) B.Text = "OFF" B.Font = Enum.Font.GothamBold B.TextSize = 11 B.BackgroundColor3 = Color3.fromRGB(30, 32, 45) B.TextColor3 = Color3.fromRGB(150, 150, 150)
    local BC = Instance.new("UICorner", B) BC.CornerRadius = UDim.new(0, 4)
    local state = false B.MouseButton1Click:Connect(function() state = not state B.Text = state and "ON" or "OFF" B.BackgroundColor3 = state and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(30, 32, 45) B.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150) cb(state) end)
end

MakeBtn("Auto Shiftlock", function(v) Enabled = v if not v then sl = false targetDir = nil end end)
MakeBtn("Auto Set Ball", function(v) AutoSet = v end)

-- CLIENT-SIDE ESP BOUNDARY MARKER SETUP
local BallMarker = Instance.new("BoxHandleAdornment") BallMarker.Size = Vector3.new(2, 2, 2) BallMarker.Color3 = Color3.fromRGB(0, 255, 120) BallMarker.AlwaysOnTop = true BallMarker.ZIndex = 5 BallMarker.Transparency = 0.4 BallMarker.Adornee = nil BallMarker.Parent = workspace

-- HIGH-END TIMELINE INTRO SEQUENCE
task.spawn(function()
    local Intro = Instance.new("Frame", UI) Intro.Size = UDim2.new(0, 250, 0, 120) Intro.Position = UDim2.new(0.5, -125, 0.4, -60) Intro.BackgroundColor3 = Color3.fromRGB(11, 12, 18)
    local IC = Instance.new("UICorner", Intro) IC.CornerRadius = UDim.new(0, 12)
    local IS = Instance.new("UIStroke", Intro) IS.Color = Color3.fromRGB(0, 170, 255) IS.Thickness = 1.5
    local Lbl = Instance.new("TextLabel", Intro) Lbl.Size = UDim2.new(1, 0, 1, 0) Lbl.Text = "script made by jossepopsi" Lbl.TextColor3 = Color3.fromRGB(255, 255, 255) Lbl.TextSize = 14 Lbl.Font = Enum.Font.GothamBold Lbl.BackgroundTransparency = 1
    task.wait(4.0) Intro:Destroy() Main.Visible, Tog.Visible = true, true
end)

-- INTENSITY PREDICTOR & ENGINE LOOPS
task.spawn(function()
    while task.wait(0.02) do
        local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Volleyball") or workspace:FindFirstChildOfClass("Part")
        if ball and ball:IsA("BasePart") and ball.Name:lower():match("ball") then
            -- Predict Landing Coordinates via Physics Vectors
            local pos, vel = ball.Position, ball.AssemblyLinearVelocity
            local t = (vel.Y > 0 or vel.Y < 0) and (pos.Y / math.abs(vel.Y)) or 0
            local predictedLand = pos + Vector3.new(vel.X * t, -pos.Y, vel.Z * t)
            
            -- Volleyball Legends Bounding Court Limits (Approximated Field Area)
            local isBallGoingOut = (math.abs(predictedLand.X) > 65 or math.abs(predictedLand.Z) > 65)
            
            if AutoSet and not isBallGoingOut then
                BallMarker.Adornee = ball BallMarker.Color3 = Color3.fromRGB(0, 255, 120) -- Green inside limits
                local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if root and (root.Position - pos).Magnitude < 12 then
                    -- Forces an absolute Set Input (Simulates standard high ceiling set keys)
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game) task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    task.wait(0.6)
                end
            elseif isBallGoingOut then
                BallMarker.Adornee = ball BallMarker.Color3 = Color3.fromRGB(255, 40, 40) -- Neon Red Out of Bounds Alert
            else
                BallMarker.Adornee = nil
            end
        else
            BallMarker.Adornee = nil
        end
    end
end)

local function setup(char)
    char:WaitForChild("Humanoid").Jumping:Connect(function() if not Enabled then return end if jumpThread then task.cancel(jumpThread) end local l = C.CFrame.LookVector targetDir = Vector3.new(l.X, 0, l.Z).Unit sl = true jumpThread = task.spawn(function() task.wait(0.4) sl = false targetDir = nil end) end)
    char.Humanoid.StateChanged:Connect(function(_, s) if s == Enum.HumanoidStateType.Landed then sl = false targetDir = nil if jumpThread then task.cancel(jumpThread) end end end)
end
if LP.Character then setup(LP.Character) end LP.CharacterAdded:Connect(setup)

R.RenderStepped:Connect(function() if not Enabled or not sl or not targetDir then return end local o = LP.Character local r, h = o and o:FindFirstChild("HumanoidRootPart"), o and o:FindFirstChildOfClass("Humanoid") if r and h and h.Health > 0 then U.MouseBehavior = Enum.MouseBehavior.LockCenter r.CFrame = CFrame.new(r.Position, r.Position + targetDir) h.CameraOffset = h.CameraOffset:LinearInterpolate(Vector3.new(2.5, 2, 0), 0.2) end end)
