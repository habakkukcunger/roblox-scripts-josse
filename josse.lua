-- MOBILE-SAFE CLEANUP ROUTINE
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local oldUI = PlayerGui:FindFirstChild("JosserpopsierV2")
if oldUI then oldUI:Destroy() end
task.wait(0.1)

-- MAIN VARIABLES SET
local P, R, U, C = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), workspace.CurrentCamera
local LP = P.LocalPlayer
local off = Vector3.new(2.5, 2, 0)

local ScriptEnabled = false 
local DesyncEnabled = false
local sl = false
local targetDir = nil 
local jumpTimeThread = nil 

-- SAFE CHARACTER MOVEMENT LOGIC
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

-- Auto Shiftlock Framework Execution Loop
R.RenderStepped:Connect(function()
    if not ScriptEnabled or not sl or not targetDir then return end
    local o = LP.Character
    local r = o and o:FindFirstChild("HumanoidRootPart")
    local h = o and o:FindFirstChildOfClass("Humanoid")
    
    if r and h and h.Health > 0 then
        U.MouseBehavior = Enum.MouseBehavior.LockCenter
        r.CFrame = CFrame.new(r.Position, r.Position + targetDir)
        h.CameraOffset = h.CameraOffset:LinearInterpolate(off, 0.2)
    end
end)

-- Mobile-Safe Alternate Visual Desync Method
local desyncMultiplier = 0.08
R.Heartbeat:Connect(function()
    if not DesyncEnabled or not LP.Character then return end
    local r = LP.Character:FindFirstChild("HumanoidRootPart")
    local hum = LP.Character:FindFirstChildOfClass("Humanoid")
    if r and hum and hum.MoveDirection.Magnitude > 0 then
        r.CFrame = r.CFrame * CFrame.new(desyncMultiplier, 0, 0)
        R.RenderStepped:Wait()
        r.CFrame = r.CFrame * CFrame.new(-desyncMultiplier, 0, 0)
    end
end)

-- ==========================================
-- STABLE CORE INTERFACE CONSTRUCT
-- ==========================================
local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "JosserpopsierV2"
UI.ResetOnSpawn = false

-- Repositioned to Bottom-Left Corner out of court view
local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, 260, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.6, 0) 
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Active = true
MainFrame.Draggable = true 

local FrameCorner = Instance.new("UICorner", MainFrame)
FrameCorner.CornerRadius = UDim.new(0, 10)

local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(50, 50, 60)
FrameStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "josserpopsier hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Floating Toggle Button pinned to Top-Center edge
local ToggleUIBtn = Instance.new("TextButton", UI)
ToggleUIBtn.Size = UDim2.new(0, 80, 0, 28)
ToggleUIBtn.Position = UDim2.new(0.5, -40, 0, 5) 
ToggleUIBtn.Text = "Hide Hub"
ToggleUIBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleUIBtn.TextSize = 11
ToggleUIBtn.Font = Enum.Font.GothamBold
ToggleUIBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ToggleUIBtn.Active = true
ToggleUIBtn.Selectable = true

local ToggleUIBtnCorner = Instance.new("UICorner", ToggleUIBtn)
ToggleUIBtnCorner.CornerRadius = UDim.new(0, 6)

local ToggleStroke = Instance.new("UIStroke", ToggleUIBtn)
ToggleStroke.Color = Color3.fromRGB(50, 52, 68)

ToggleUIBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    ToggleUIBtn.Text = MainFrame.Visible and "Hide Hub" or "Show Hub"
    ToggleUIBtn.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(0, 110, 230)
end)

local List = Instance.new("UIListLayout", MainFrame)
List.Padding = UDim.new(0, 8)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder

local Spacer = Instance.new("Frame", MainFrame)
Spacer.Size = UDim2.new(1, 0, 0, 35)
Spacer.BackgroundTransparency = 1
Spacer.LayoutOrder = 1

-- Card Generator Function Structure
local function CreateCard(text, order, callback)
    local Card = Instance.new("Frame", MainFrame)
    Card.Size = UDim2.new(1, -20, 0, 40)
    Card.LayoutOrder = order
    Card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Card.BorderSizePixel = 0
    
    local CardCorner = Instance.new("UICorner", Card)
    CardCorner.CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Card)
    Label.Size = UDim2.new(1, -85, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 210)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Card)
    Btn.Size = UDim2.new(0, 70, 0, 28)
    Btn.Position = UDim2.new(1, -75, 0, 6)
    Btn.Text = "OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.BorderSizePixel = 0
    Btn.Active = true
    Btn.Selectable = true
    
    local BtnCorner = Instance.new("UICorner", Btn)
    BtnCorner.CornerRadius = UDim.new(0, 4)

    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        Btn.Text = enabled and "ON" or "OFF"
        Btn.TextColor3 = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        Btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 110, 230) or Color3.fromRGB(35, 35, 45)
        callback(enabled)
    end)
end

CreateCard("Auto Shiftlock", 2, function(val) ScriptEnabled = val if not val then sl = false targetDir = nil end end)
CreateCard("Desync Network", 3, function(val) DesyncEnabled = val end)
