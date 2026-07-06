-- ==========================================
-- AUTOMATIC CLEANUP & SAFE GUARD
-- ==========================================
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local oldUI = PlayerGui:FindFirstChild("JosserpopsierRayMod")
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
-- REPAIRED RAYFIELD-INSPIRED NATIVE UI (GUI)
-- ==========================================
local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "JosserpopsierRayMod"
UI.ResetOnSpawn = false

-- Outer Frame Window
local ShadowFrame = Instance.new("Frame", UI)
ShadowFrame.Size = UDim2.new(0, 340, 0, 120)
ShadowFrame.Position = UDim2.new(0.15, 0, 0.3, 0)
ShadowFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ShadowFrame.BackgroundTransparency = 0.4
ShadowFrame.BorderSizePixel = 0
ShadowFrame.Active = true
ShadowFrame.Draggable = true

local ShadowCorner = Instance.new("UICorner", ShadowFrame)
ShadowCorner.CornerRadius = UDim.new(0, 14)

-- Main Body Content Window
local MainFrame = Instance.new("Frame", ShadowFrame)
MainFrame.Size = UDim2.new(1, -6, 1, -6)
MainFrame.Position = UDim2.new(0, 3, 0, 3)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Header/Title Layout Banner
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Header.BorderSizePixel = 0
Header.Active = true

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 12)

local HeaderFix = Instance.new("Frame", Header)
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
HeaderFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Text = "josserpopsier hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Close TextButton
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 9)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.BackgroundTransparency = 1
CloseBtn.Active = true
CloseBtn.Selectable = true
CloseBtn.MouseButton1Click:Connect(function() UI:Destroy() end)

-- Minimalist Sidebar Navigation
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 90, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Sidebar.BorderSizePixel = 0

local TabBtn = Instance.new("TextButton", Sidebar)
TabBtn.Size = UDim2.new(1, -12, 0, 30)
TabBtn.Position = UDim2.new(0, 6, 0, 10)
TabBtn.Text = "  Movement"
TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabBtn.TextSize = 12
TabBtn.Font = Enum.Font.GothamBold
TabBtn.TextXAlignment = Enum.TextXAlignment.Left
TabBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
TabBtn.BorderSizePixel = 0
TabBtn.Active = true
TabBtn.Selectable = true

local TabBtnCorner = Instance.new("UICorner", TabBtn)
TabBtnCorner.CornerRadius = UDim.new(0, 6)

-- Main Component Display Panel
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -102, 1, -54)
ContentArea.Position = UDim2.new(0, 96, 0, 48)
ContentArea.BackgroundTransparency = 1

-- Custom High-End Dynamic Toggle Component Container
local ToggleContainer = Instance.new("Frame", ContentArea)
ToggleContainer.Size = UDim2.new(1, 0, 0, 44)
ToggleContainer.Position = UDim2.new(0, 0, 0, 6)
ToggleContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
ToggleContainer.BorderSizePixel = 0
ToggleContainer.Active = true

local ToggleCorner = Instance.new("UICorner", ToggleContainer)
ToggleCorner.CornerRadius = UDim.new(0, 8)

local ToggleLabel = Instance.new("TextLabel", ToggleContainer)
ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
ToggleLabel.Text = "Auto Shiftlock"
ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
ToggleLabel.TextSize = 12
ToggleLabel.Font = Enum.Font.GothamMedium
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.BackgroundTransparency = 1

-- FIXED HOVER/CLICK INTERACTION BACKPLATE BUTTON
local SwitchBase = Instance.new("TextButton", ToggleContainer)
SwitchBase.Size = UDim2.new(0, 36, 0, 20)
SwitchBase.Position = UDim2.new(1, -48, 0, 12)
SwitchBase.Text = ""
SwitchBase.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
SwitchBase.BorderSizePixel = 0
SwitchBase.Active = true       -- CRITICAL FOR MOBILE INTERACTION
SwitchBase.Selectable = true   -- CRITICAL FOR MOBILE EXECUTION

local BaseCorner = Instance.new("UICorner", SwitchBase)
BaseCorner.CornerRadius = UDim.new(1, 0)

-- Inner Interactive Toggle Indicator Bead
local SwitchBall = Instance.new("Frame", SwitchBase)
SwitchBall.Size = UDim2.new(0, 14, 0, 14)
SwitchBall.Position = UDim2.new(0, 3, 0, 3)
SwitchBall.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
SwitchBall.BorderSizePixel = 0

local BallCorner = Instance.new("UICorner", SwitchBall)
BallCorner.CornerRadius = UDim.new(1, 0)

-- CLICK LISTENER EXECUTION
SwitchBase.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        SwitchBase:TweenBackgroundColor3(Color3.fromRGB(60, 180, 110), "Out", "Quad", 0.15, true)
        SwitchBall:TweenPosition(UDim2.new(0, 19, 0, 3), "Out", "Quad", 0.15, true)
        SwitchBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    else
        SwitchBase:TweenBackgroundColor3(Color3.fromRGB(45, 45, 55), "Out", "Quad", 0.15, true)
        SwitchBall:TweenPosition(UDim2.new(0, 3, 0, 3), "Out", "Quad", 0.15, true)
        SwitchBall.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
        sl = false
        targetDir = nil
    end
end)
