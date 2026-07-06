-- AUTOMATIC CACHE CLEANUP
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
if PlayerGui:FindFirstChild("JosserpopsierV2") then PlayerGui.JosserpopsierV2:Destroy() end
task.wait(0.1)

-- MAIN SYSTEM CONTEXT
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
            if jumpTimeThread then task.cancel(jumpTimeThread) end
        end
    end)
end

if LP.Character then setup(LP.Character) end
LP.CharacterAdded:Connect(setup)

-- Auto Shiftlock Render System
R.RenderStepped:Connect(function()
    local o = LP.Character
    local r = o and o:FindFirstChild("HumanoidRootPart")
    local h = o and o:FindFirstChildOfClass("Humanoid")
    if ScriptEnabled and sl and targetDir and r and h and h.Health > 0 then
        U.MouseBehavior = Enum.MouseBehavior.LockCenter
        r.CFrame = CFrame.new(r.Position, r.Position + targetDir)
        h.CameraOffset = h.CameraOffset:LinearInterpolate(off, 0.2)
    elseif h then
        if U.MouseBehavior == Enum.MouseBehavior.LockCenter then U.MouseBehavior = Enum.MouseBehavior.Default end
        h.CameraOffset = h.CameraOffset:LinearInterpolate(Vector3.new(), 0.2)
    end
end)

-- MOBILE-SAFE DESYNC REPLICATION SYSTEM
local desyncFlip = true
R.Heartbeat:Connect(function()
    if DesyncEnabled and LP.Character then
        local r = LP.Character:FindFirstChild("HumanoidRootPart")
        if r then
            desyncFlip = not desyncFlip
            r.Velocity = desyncFlip and Vector3.new(0, 5, 0) or Vector3.new(0, -5, 0)
        end
    end
end)

-- CORE INTERFACE CONSTRUCT
local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "JosserpopsierV2"
UI.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, 310, 0, 215)
MainFrame.Position = UDim2.new(0.2, 0, 0.35, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 18)
MainFrame.Active = true
MainFrame.Draggable = true 
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(40, 42, 54)
FrameStroke.Thickness = 1.2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -70, 0, 45)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Text = "josserpopsier hub"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local ToggleUIBtn = Instance.new("TextButton", UI)
ToggleUIBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleUIBtn.Position = UDim2.new(0.5, -40, 0, 10) 
ToggleUIBtn.Text = "Hide Hub"
ToggleUIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleUIBtn.TextSize = 11
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Instance.new("UICorner", ToggleUIBtn).CornerRadius = UDim.new(0, 6)
local ToggleStroke = Instance.new("UIStroke", ToggleUIBtn)
ToggleStroke.Color = Color3.fromRGB(50, 52, 68)

ToggleUIBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleUIBtn.Text = MainFrame.Visible and "Hide Hub" or "Show Hub"
    ToggleUIBtn.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(24, 24, 30) or Color3.fromRGB(0, 110, 230)
end)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(160, 165, 180)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamMedium
CloseBtn.BackgroundTransparency = 1
CloseBtn.MouseButton1Click:Connect(function() UI:Destroy() end)

local Divider = Instance.new("Frame", MainFrame)
Divider.Size = UDim2.new(1, -32, 0, 1)
Divider.Position = UDim2.new(0, 16, 0, 45)
Divider.BackgroundColor3 = Color3.fromRGB(30, 32, 44)

-- CARD CONTAINER GENERATOR
local function CreateCard(text, pos, callback)
    local Card = Instance.new("Frame", MainFrame)
    Card.Size = UDim2.new(1, -32, 0, 64)
    Card.Position = pos
    Card.BackgroundColor3 = Color3.fromRGB(20, 21, 28)
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = Color3.fromRGB(32, 34, 46)

    local Label = Instance.new("TextLabel", Card)
    Label.Size = UDim2.new(1, -120, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(190, 195, 210)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Card)
    Btn.Size = UDim2.new(0, 85, 0, 34)
    Btn.Position = UDim2.new(1, -99, 0, 15)
    Btn.Text = "Disabled"
    Btn.TextColor3 = Color3.fromRGB(180, 185, 200)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = Color3.fromRGB(45, 48, 64)

    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Btn.Text = enabled and "Enabled" or "Disabled"
        Btn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 185, 200)
        Btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 110, 230) or Color3.fromRGB(32, 34, 46)
        BtnStroke.Color = enabled and Color3.fromRGB(60, 150, 255) or Color3.fromRGB(45, 48, 64)
        callback(enabled)
    end)
end

CreateCard("Auto Shiftlock (Jump)", UDim2.new(0, 16, 0, 62), function(val) ScriptEnabled = val if not val then sl = false targetDir = nil end end)
CreateCard("Desync", UDim2.new(0, 16, 0, 136), function(val) DesyncEnabled = val end)
