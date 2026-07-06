-- ==========================================
-- AUTOMATIC CLEANUP & SAFE GUARD
-- ==========================================
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local oldUI = PlayerGui:FindFirstChild("VBLegendsHub")
if oldUI then oldUI:Destroy() end
task.wait(0.1)

-- ==========================================
-- MAIN MECHANICS DATA
-- ==========================================
local P, R, U, C = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), workspace.CurrentCamera
local LP = P.LocalPlayer
local off = Vector3.new(2.5, 2, 0)

local ScriptEnabled = false 
local sl = false
local targetDir = nil 
local jumpTimeThread = nil 

local function setup(char)
    local hum = char:WaitForChild("Humanoid")
    
    hum.Jumping:Connect(function()
        if not ScriptEnabled then return end 
        if jumpTimeThread then task.cancel(jumpTimeThread) end
        
        local l = C.CFrame.LookVector
        targetDir = Vector3.new(l.X, 0, l.Z).Unit 
        sl = true
        
        jumpTimeThread = task.spawn(function()
            task.wait(0.4)
            sl = false
            targetDir = nil
        end)
    end)
    
    hum.StateChanged:Connect(function(_, s)
        if s == Enum.HumanoidStateType.Landed then
            sl = false
            targetDir = nil 
            if jumpTimeThread then
                task.cancel(jumpTimeThread)
                jumpTimeThread = nil
            end
        end
    end)
    
    hum.Died:Connect(function()
        sl = false
        targetDir = nil
        if jumpTimeThread then
            task.cancel(jumpTimeThread)
            jumpTimeThread = nil
        end
    end)
end

if LP.Character then setup(LP.Character) end
LP.CharacterAdded:Connect(setup)

R.RenderStepped:Connect(function()
    local o = LP.Character
    local r = o and o:FindFirstChild("HumanoidRootPart")
    local h = o and o:FindFirstChildOfClass("Humanoid")
    
    if ScriptEnabled and sl and targetDir and r and h and h.Health > 0 then
        U.MouseBehavior = Enum.MouseBehavior.LockCenter
        r.CFrame = CFrame.new(r.Position, r.Position + targetDir)
        h.CameraOffset = h.CameraOffset:LinearInterpolate(off, 0.2)
    elseif h then
        if U.MouseBehavior == Enum.MouseBehavior.LockCenter then
            U.MouseBehavior = Enum.MouseBehavior.Default
        end
        h.CameraOffset = h.CameraOffset:LinearInterpolate(Vector3.new(), 0.2)
    end
end)

-- ==========================================
-- CUSTOM NO-LAG USER INTERFACE (GUI)
-- ==========================================
local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "VBLegendsHub"
UI.ResetOnSpawn = false

-- Main Window
local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, 240, 0, 180)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Hub Title Bar
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "   josserpopsier hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 10)

-- Close Button
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() UI:Destroy() end)

-- Subtitle Label
local GameLabel = Instance.new("TextLabel", MainFrame)
GameLabel.Size = UDim2.new(1, -20, 0, 20)
GameLabel.Position = UDim2.new(0, 15, 0, 50)
GameLabel.Text = "Volleyball Legends Tool"
GameLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
GameLabel.TextSize = 11
GameLabel.Font = Enum.Font.GothamBold
GameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameLabel.BackgroundTransparency = 1

-- Auto Shiftlock Toggle Button
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -30, 0, 45)
ToggleBtn.Position = UDim2.new(0, 15, 0, 75)
ToggleBtn.Text = "Auto Shiftlock: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50) 
ToggleBtn.BorderSizePixel = 0

local BtnCorner1 = Instance.new("UICorner", ToggleBtn)
BtnCorner1.CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        ToggleBtn.Text = "Auto Shiftlock: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50) 
    else
        ToggleBtn.Text = "Auto Shiftlock: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50) 
        sl = false
        targetDir = nil
    end
end)

-- WalkSpeed Modifier Button
local SpeedBtn = Instance.new("TextButton", MainFrame)
SpeedBtn.Size = UDim2.new(1, -30, 0, 35)
SpeedBtn.Position = UDim2.new(0, 15, 0, 130)
SpeedBtn.Text = "Boost Court Speed (Normal)"
SpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedBtn.TextSize = 12
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50) 
SpeedBtn.BorderSizePixel = 0

local BtnCorner2 = Instance.new("UICorner", SpeedBtn)
BtnCorner2.CornerRadius = UDim.new(0, 6)

local SpeedToggle = false
SpeedBtn.MouseButton1Click:Connect(function()
    SpeedToggle = not SpeedToggle
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if SpeedToggle then
            hum.WalkSpeed = 28 -- Boosted Court Positioning speed
            SpeedBtn.Text = "Boost Court Speed (ACTIVE)"
            SpeedBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            hum.WalkSpeed = 16 -- Regular speed reset
            SpeedBtn.Text = "Boost Court Speed (Normal)"
            SpeedBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end)
