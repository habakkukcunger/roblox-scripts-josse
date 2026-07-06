-- ==========================================
-- AUTOMATIC CLEANUP & SAFE GUARD
-- ==========================================
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local oldUI = PlayerGui:FindFirstChild("JosserpopsierV2")
if oldUI then oldUI:Destroy() end
task.wait(0.1)

-- ==========================================
-- MAIN ENGINE MECHANICS (Volleyball Legends)
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
-- MOBILE OPTIMIZED MODERN UI FRAMEWORK
-- ==========================================
local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "JosserpopsierV2"
UI.ResetOnSpawn = false

-- Glass-style Translucent Base Main Frame
local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, 310, 0, 145)
MainFrame.Position = UDim2.new(0.2, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 18) -- Dark Slate Theme
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Thin Tech Border Outline (Mimics High-End Frameworks)
local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(40, 42, 54)
FrameStroke.Thickness = 1.2
FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Header Text Element
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -50, 0, 45)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Text = "josserpopsier hub"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Sleek Close Indicator TouchButton
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(160, 165, 180)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.BackgroundTransparency = 1
CloseBtn.Active = true
CloseBtn.Selectable = true
CloseBtn.MouseButton1Click:Connect(function() UI:Destroy() end)

-- Split Layout Line Divider
local Divider = Instance.new("Frame", MainFrame)
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.Position = UDim2.new(0, 16, 0, 45)
Divider.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
Divider.BorderSizePixel = 0

-- Card Container Panel For Actions
local Card = Instance.new("Frame", MainFrame)
Card.Size = UDim2.new(1, -32, 0, 64)
Card.Position = UDim2.new(0, 16, 0, 62)
Card.BackgroundColor3 = Color3.fromRGB(20, 21, 28) -- Slightly lighter card background
Card.BorderSizePixel = 0

local CardCorner = Instance.new("UICorner", Card)
CardCorner.CornerRadius = UDim.new(0, 8)

local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Color = Color3.fromRGB(32, 34, 46)
CardStroke.Thickness = 1

-- Label Description Field
local Label = Instance.new("TextLabel", Card)
Label.Size = UDim2.new(1, -120, 1, 0)
Label.Position = UDim2.new(0, 14, 0, 0)
Label.Text = "Auto Shiftlock (Jump)"
Label.TextColor3 = Color3.fromRGB(190, 195, 210)
Label.TextSize = 13
Label.Font = Enum.Font.GothamMedium
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.BackgroundTransparency = 1

-- REPAIRED MASTER INTERACTION TOGGLE BOX BUTTON
local ToggleBtn = Instance.new("TextButton", Card)
ToggleBtn.Size = UDim2.new(0, 85, 0, 34)
ToggleBtn.Position = UDim2.new(1, -99, 0, 15)
ToggleBtn.Text = "Disabled"
ToggleBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 34, 46) -- Base state dark color
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Active = true       -- CRITICAL: Tells mobile engine this object intercepts touches
ToggleBtn.Selectable = true   -- CRITICAL: Grants rendering priority to mobile viewport

local BtnCorner = Instance.new("UICorner", ToggleBtn)
BtnCorner.CornerRadius = UDim.new(0, 6)

local BtnStroke = Instance.new("UIStroke", ToggleBtn)
BtnStroke.Color = Color3.fromRGB(45, 48, 64)
BtnStroke.Thickness = 1

-- 100% RELIABLE TAP LOGIC ROUTINE
ToggleBtn.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        ToggleBtn.Text = "Enabled"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 230) -- Premium Royal Blue Glow Accent
        BtnStroke.Color = Color3.fromRGB(60, 150, 255)
    else
        ToggleBtn.Text = "Disabled"
        ToggleBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
        BtnStroke.Color = Color3.fromRGB(45, 48, 64)
        sl = false
        targetDir = nil
    end
end)
