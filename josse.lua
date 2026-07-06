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
local DesyncEnabled = false
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

-- Render Loop handles Shiftlock Camera snappings
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

-- Network Replication Interceptor For Desync
R.Heartbeat:Connect(function()
    if DesyncEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        -- Artificially forces the internal engine replication pipeline to drop/stutter frame packets
        sethiddenproperty(game:GetService("Providers"):FindFirstChild("NetworkPeer"), "SimulatedSecondsLag", 1.0)
    elseif not DesyncEnabled then
        -- Returns connection parameters back to zero lag/normal latency bounds
        pcall(function()
            sethiddenproperty(game:GetService("Providers"):FindFirstChild("NetworkPeer"), "SimulatedSecondsLag", 0.0)
        end)
    end
end)

-- ==========================================
-- MOBILE OPTIMIZED MODERN UI FRAMEWORK
-- ==========================================
local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "JosserpopsierV2"
UI.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, 310, 0, 215)
MainFrame.Position = UDim2.new(0.2, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 18) 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(40, 42, 54)
FrameStroke.Thickness = 1.2
FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -50, 0, 45)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Text = "josserpopsier hub"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

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

local Divider = Instance.new("Frame", MainFrame)
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.Position = UDim2.new(0, 16, 0, 45)
Divider.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
Divider.BorderSizePixel = 0

-- ==========================================
-- CARD 1: AUTO SHIFTLOCK BUTTON
-- ==========================================
local Card1 = Instance.new("Frame", MainFrame)
Card1.Size = UDim2.new(1, -32, 0, 64)
Card1.Position = UDim2.new(0, 16, 0, 62)
Card1.BackgroundColor3 = Color3.fromRGB(20, 21, 28) 
Card1.BorderSizePixel = 0

local CardCorner1 = Instance.new("UICorner", Card1)
CardCorner1.CornerRadius = UDim.new(0, 8)

local CardStroke1 = Instance.new("UIStroke", Card1)
CardStroke1.Color = Color3.fromRGB(32, 34, 46)
CardStroke1.Thickness = 1

local Label1 = Instance.new("TextLabel", Card1)
Label1.Size = UDim2.new(1, -120, 1, 0)
Label1.Position = UDim2.new(0, 14, 0, 0)
Label1.Text = "Auto Shiftlock (Jump)"
Label1.TextColor3 = Color3.fromRGB(190, 195, 210)
Label1.TextSize = 13
Label1.Font = Enum.Font.GothamMedium
Label1.TextXAlignment = Enum.TextXAlignment.Left
Label1.BackgroundTransparency = 1

local ToggleBtn1 = Instance.new("TextButton", Card1)
ToggleBtn1.Size = UDim2.new(0, 85, 0, 34)
ToggleBtn1.Position = UDim2.new(1, -99, 0, 15)
ToggleBtn1.Text = "Disabled"
ToggleBtn1.TextColor3 = Color3.fromRGB(180, 185, 200)
ToggleBtn1.TextSize = 12
ToggleBtn1.Font = Enum.Font.GothamBold
ToggleBtn1.BackgroundColor3 = Color3.fromRGB(32, 34, 46) 
ToggleBtn1.BorderSizePixel = 0
ToggleBtn1.Active = true       
ToggleBtn1.Selectable = true   

local BtnCorner1 = Instance.new("UICorner", ToggleBtn1)
BtnCorner1.CornerRadius = UDim.new(0, 6)

local BtnStroke1 = Instance.new("UIStroke", ToggleBtn1)
BtnStroke1.Color = Color3.fromRGB(45, 48, 64)
BtnStroke1.Thickness = 1

ToggleBtn1.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    if ScriptEnabled then
        ToggleBtn1.Text = "Enabled"
        ToggleBtn1.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn1.BackgroundColor3 = Color3.fromRGB(0, 110, 230) 
        BtnStroke1.Color = Color3.fromRGB(60, 150, 255)
    else
        ToggleBtn1.Text = "Disabled"
        ToggleBtn1.TextColor3 = Color3.fromRGB(180, 185, 200)
        ToggleBtn1.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
        BtnStroke1.Color = Color3.fromRGB(45, 48, 64)
        sl = false
        targetDir = nil
    end
end)

-- ==========================================
-- CARD 2: DESYNC REPLICATION BUTTON
-- ==========================================
local Card2 = Instance.new("Frame", MainFrame)
Card2.Size = UDim2.new(1, -32, 0, 64)
Card2.Position = UDim2.new(0, 16, 0, 136) 
Card2.BackgroundColor3 = Color3.fromRGB(20, 21, 28) 
Card2.BorderSizePixel = 0

local CardCorner2 = Instance.new("UICorner", Card2)
CardCorner2.CornerRadius = UDim.new(0, 8)

local CardStroke2 = Instance.new("UIStroke", Card2)
CardStroke2.Color = Color3.fromRGB(32, 34, 46)
CardStroke2.Thickness = 1

local Label2 = Instance.new("TextLabel", Card2)
Label2.Size = UDim2.new(1, -120, 1, 0)
Label2.Position = UDim2.new(0, 14, 0, 0)
Label2.Text = "Desync"
Label2.TextColor3 = Color3.fromRGB(190, 195, 210)
Label2.TextSize = 13
Label2.Font = Enum.Font.GothamMedium
Label2.TextXAlignment = Enum.TextXAlignment.Left
Label2.BackgroundTransparency = 1

local ToggleBtn2 = Instance.new("TextButton", Card2)
ToggleBtn2.Size = UDim2.new(0, 85, 0, 34)
ToggleBtn2.Position = UDim2.new(1, -99, 0, 15)
ToggleBtn2.Text = "Disabled"
ToggleBtn2.TextColor3 = Color3.fromRGB(180, 185, 200)
ToggleBtn2.TextSize = 12
ToggleBtn2.Font = Enum.Font.GothamBold
ToggleBtn2.BackgroundColor3 = Color3.fromRGB(32, 34, 46) 
ToggleBtn2.BorderSizePixel = 0
ToggleBtn2.Active = true       
ToggleBtn2.Selectable = true   

local BtnCorner2 = Instance.new("UICorner", ToggleBtn2)
BtnCorner2.CornerRadius = UDim.new(0, 6)

local BtnStroke2 = Instance.new("UIStroke", ToggleBtn2)
BtnStroke2.Color = Color3.fromRGB(45, 48, 64)
BtnStroke2.Thickness = 1

ToggleBtn2.MouseButton1Click:Connect(function()
    DesyncEnabled = not DesyncEnabled
    if DesyncEnabled then
        ToggleBtn2.Text = "Enabled"
        ToggleBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn2.BackgroundColor3 = Color3.fromRGB(0, 110, 230) 
        BtnStroke2.Color = Color3.fromRGB(60, 150, 255)
    else
        ToggleBtn2.Text = "Disabled"
        ToggleBtn2.TextColor3 = Color3.fromRGB(180, 185, 200)
        ToggleBtn2.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
        BtnStroke2.Color = Color3.fromRGB(45, 48, 64)
    end
end)
