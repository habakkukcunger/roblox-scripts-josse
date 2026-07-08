local P, T, R, U = game:GetService("Players"), game:GetService("TweenService"), game:GetService("RunService"), game:GetService("UserInputService")
local LP, C = P.LocalPlayer, workspace.CurrentCamera
local PlayerGui = LP:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("JHub") then PlayerGui.JHub:Destroy() end

local Enabled, sl, targetDir, jumpThread, CloneEnabled, ActiveClone = false, false, nil, nil, false, nil

local UI = Instance.new("ScreenGui", PlayerGui) UI.Name = "JHub" UI.ResetOnSpawn = false
local Main = Instance.new("Frame", UI) Main.Size = UDim2.new(0, 240, 0, 150) Main.Position = UDim2.new(0.05, 0, 0.6, 0) Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20) Main.Active, Main.Draggable, Main.Visible = true, true, false
local List = Instance.new("UIListLayout", Main) List.Padding = UDim.new(0, 5) List.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Tog = Instance.new("TextButton", UI) Tog.Size = UDim2.new(0, 80, 0, 25) Tog.Position = UDim2.new(1, -90, 0, 10) Tog.Text, Tog.Visible = "Hide", false
Tog.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible Tog.Text = Main.Visible and "Hide" or "Show" end)

local function MakeBtn(txt, y, cb)
    local B = Instance.new("TextButton", Main) B.Size = UDim2.new(0, 220, 0, 35) B.Text = txt .. ": OFF" B.BackgroundColor3 = Color3.fromRGB(30, 30, 35) B.TextColor3 = Color3.fromRGB(200, 200, 200)
    local state = false B.MouseButton1Click:Connect(function() state = not state B.Text = txt .. (state and ": ON" or ": OFF") cb(state) end)
end

local function Clear() if ActiveClone then ActiveClone:Destroy() ActiveClone = nil end end

MakeBtn("Auto Shiftlock", 1, function(v) Enabled = v if not v then sl = false targetDir = nil end end)
MakeBtn("Shadow Clone", 2, function(v) CloneEnabled = v if not v then Clear() else
    local c = LP.Character if c and c:FindFirstChild("HumanoidRootPart") then Clear()
        c.Archivable = true local cl = c:Clone() c.Archivable = false
        for _, d in ipairs(cl:GetDescendants()) do if d:IsA("BasePart") then d.Anchored, d.CanCollide, d.CanTouch = true, false, false if d.Name ~= "HumanoidRootPart" then d.Transparency = 0.5 else d.Transparency = 1 end elseif d:IsA("Decal") then d.Transparency = 0.5 end end
        cl.Parent = workspace ActiveClone = cl
    end
end end)

task.spawn(function()
    local Intro = Instance.new("Frame", UI) Intro.Size = UDim2.new(0, 240, 0, 120) Intro.Position = UDim2.new(0.5, -120, 0.4, -60) Intro.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    local Lbl = Instance.new("TextLabel", Intro) Lbl.Size = UDim2.new(1, 0, 1, 0) Lbl.Text = "made by jossepopsi" Lbl.TextColor3 = Color3.fromRGB(255, 255, 255) Lbl.BackgroundTransparency = 1
    task.wait(3.5) Intro:Destroy() Main.Visible, Tog.Visible = true, true
end)

local function setup(char) char:WaitForChild("Humanoid").Died:Connect(Clear)
    char.Humanoid.Jumping:Connect(function() if not Enabled then return end if jumpThread then task.cancel(jumpThread) end local l = C.CFrame.LookVector targetDir = Vector3.new(l.X, 0, l.Z).Unit sl = true jumpThread = task.spawn(function() task.wait(0.4) sl = false targetDir = nil end) end)
    char.Humanoid.StateChanged:Connect(function(_, s) if s == Enum.HumanoidStateType.Landed then sl = false targetDir = nil if jumpThread then task.cancel(jumpThread) end end end)
end
if LP.Character then setup(LP.Character) end LP.CharacterAdded:Connect(setup)

R.RenderStepped:Connect(function() if not Enabled or not sl or not targetDir then return end local o = LP.Character local r, h = o and o:FindFirstChild("HumanoidRootPart"), o and o:FindFirstChildOfClass("Humanoid") if r and h and h.Health > 0 then U.MouseBehavior = Enum.MouseBehavior.LockCenter r.CFrame = CFrame.new(r.Position, r.Position + targetDir) h.CameraOffset = h.CameraOffset:LinearInterpolate(Vector3.new(2.5, 2, 0), 0.2) end end)
