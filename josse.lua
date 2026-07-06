local P, R, U, C = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), workspace.CurrentCamera
local LP = P.LocalPlayer
local off = Vector3.new(2.5, 2, 0)

-- Core Control Variables
local ScriptEnabled = false 
local sl = false
local targetDir = nil 
local jumpTimeThread = nil 

-- Core Mechanic Setup
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
-- SCRIPT HUB USER INTERFACE (GUI)
-- ==========================================

local UI = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
UI.Name = "VBLegendsHub"
UI.ResetOnSpawn = false

-- Main Window
local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.1, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

-- Hub Title Bar (UPDATED TITLE HERE)
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "  josserpopsier"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 8)

-- Subtitle / Game Label
local GameLabel = Instance.new("TextLabel", MainFrame)
GameLabel.Size = UDim2.new(1, -20, 0, 20)
GameLabel.Position = UDim2.new(0, 10, 0, 45)
GameLabel.Text = "Volleyball Legends Edition"
GameLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
GameLabel.TextSize = 11
GameLabel.Font = Enum.Font.GothamBold
GameLabel.TextXAlignment = Enum.TextXAlignment.Left
GameLabel.BackgroundTransparency = 1

-- Auto Shiftlock Toggle Button
local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, -20, 0, 45)
ToggleBtn.Position = UDim2.new(0, 10, 0, 75)
ToggleBtn.Text = "Auto Shiftlock: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50) 
ToggleBtn.BorderSizePixel = 0

local BtnCorner = Instance.new("UICorner", ToggleBtn)
BtnCorner.CornerRadius = UDim.new(0, 6)

-- Toggle Functionality
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
