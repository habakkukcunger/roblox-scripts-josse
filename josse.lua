-- ==========================================
-- AUTOMATIC CLEANUP & SAFE GUARD
-- ==========================================
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local oldUI = PlayerGui:FindFirstChild("JosserpopsierFluentHub")
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
-- PREMIUM FLUENT-INSPIRED NATIVE UI (GUI)
-- ==========================================
local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "JosserpopsierFluentHub"
UI.ResetOnSpawn = false

-- Fluent Style Dark Translucent Main Window
local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, 360, 0, 220)
MainFrame.Position = UDim2.new(0.15, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Glowing Accent Stroke
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(45, 45, 60)
UIStroke.Thickness = 1
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Left Sidebar Navigation Panel
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0

local SideCorner = Instance.new("UICorner", Sidebar)
SideCorner.CornerRadius = UDim.new(0, 10)

-- Cover the right rounded corners of the sidebar to keep clean fluid style
local SideFix = Instance.new("Frame", Sidebar)
SideFix.Size = UDim2.new(0, 15, 1, 0)
SideFix.Position = UDim2.new(1, -15, 0, 0)
SideFix.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
SideFix.BackgroundTransparency = 0.2
SideFix.BorderSizePixel = 0

-- Header Text / Branding
local HubName = Instance.new("TextLabel", Sidebar)
HubName.Size = UDim2.new(1, 0, 0, 45)
HubName.Position = UDim2.new(0, 12, 0, 0)
HubName.Text = "josserpopsier"
HubName.TextColor3 = Color3.fromRGB(255, 255, 255)
HubName.TextSize = 15
HubName.Font = Enum.Font.GothamBold
HubName.TextXAlignment = Enum.TextXAlignment.Left
HubName.BackgroundTransparency = 1

local TabIndicator = Instance.new("TextLabel", Sidebar)
TabIndicator.Size = UDim2.new(1, -12, 0, 30)
TabBtnPosition = UDim2.new(0, 8, 0, 50)
TabIndicator.Position = TabBtnPosition
TabIndicator.Text = "  Movement"
TabIndicator.TextColor3 = Color3.fromRGB(110, 140, 255) -- Premium blue text accent
TabIndicator.TextSize = 13
TabIndicator.Font = Enum.Font.GothamBold
TabIndicator.TextXAlignment = Enum.TextXAlignment.Left
TabIndicator.BackgroundColor3 = Color3.fromRGB(20, 22, 33)
TabIndicator.BorderSizePixel = 0

local TabCorner = Instance.new("UICorner", TabIndicator)
TabCorner.CornerRadius = UDim.new(0, 6)

-- Sleek Close Button
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 10)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(140, 140, 150)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.BackgroundTransparency = 1
CloseBtn.Active = true
CloseBtn.Selectable = true
CloseBtn.MouseButton1Click:Connect(function() UI:Destroy() end)

-- Main Display Field Container
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -125, 1, -55)
ContentArea.Position = UDim2.new(0, 120, 0, 45)
ContentArea.BackgroundTransparency = 1

-- Fluent-style Large Toggle Card Panel
local ToggleCard = Instance.new("Frame", ContentArea)
ToggleCard.Size = UDim2.new(1, 0, 0, 50)
ToggleCard.Position = UDim2.new(0, 0, 0, 10)
ToggleCard.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ToggleCard.BorderSizePixel = 0
ToggleCard.Active = true

local CardCorner = Instance.new("UICorner", ToggleCard)
CardCorner.CornerRadius = UDim.new(0, 8)

local CardStroke = Instance.new("UIStroke", ToggleCard)
CardStroke.Color = Color3.fromRGB(35, 35, 45)
CardStroke.Thickness = 1

local ToggleLabel = Instance.new("TextLabel", ToggleCard)
ToggleLabel.Size = UDim2.new(1, -100, 1, 0)
ToggleLabel.Position = UDim2.new(0, 14, 0, 0)
ToggleLabel.Text = "Auto Shiftlock (On Jump)"
ToggleLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
ToggleLabel.TextSize = 13
ToggleLabel.Font = Enum.Font.GothamMedium
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.BackgroundTransparency = 1

-- LARGE MOBILE-SAFE INTERACTIVE CHECKBOX TABS
local ActionButton = Instance.new("TextButton", ToggleCard)
ActionButton.Size = UDim2.new(0, 80, 0, 32)
ActionButton.Position = UDim2.new(1, -94, 0, 9)
ActionButton.Text = "Disabled"
ActionButton.TextColor3 = Color3.fromRGB(200, 200, 210)
ActionButton.TextSize = 11
ActionButton.Font = Enum.Font.GothamBold
ActionButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ActionButton.BorderSizePixel = 0
ActionButton.Active = true       -- Forces mobile register tracking
ActionButton.Selectable = true   -- Forces mobile handler visibility

local ActCorner = Instance.new("UICorner", ActionButton)
ActCorner.CornerRadius = UDim.new(0, 6)

local ActStroke = Instance.new("UIStroke", ActionButton)
ActStroke.Color = Color3.fromRGB(50, 50, 65)
ActStroke.Thickness = 1

-- Master Interactive Click Event Mapping
ActionButton.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        ActionButton.Text = "Enabled"
        ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ActionButton:TweenBackgroundColor3(Color3.fromRGB(0, 122, 255), "Out", "Quad", 0.12, true) -- Fluent Blue Glow
        ActStroke.Color = Color3.fromRGB(65, 165, 255)
    else
        ActionButton.Text = "Disabled"
        ActionButton.TextColor3 = Color3.fromRGB(200, 200, 210)
        ActionButton:TweenBackgroundColor3(Color3.fromRGB(35, 35, 45), "Out", "Quad", 0.12, true)
        ActStroke.Color = Color3.fromRGB(50, 50, 65)
        sl = false
        targetDir = nil
    end
end)
