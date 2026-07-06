-- ==========================================
-- SAFE MOBILE INITIALIZATION
-- ==========================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

-- Destroy any old layouts safely
if PlayerGui:FindFirstChild("JosserpopsierV2") then 
    PlayerGui.JosserpopsierV2:Destroy() 
end

local ScriptEnabled = false
local DesyncEnabled = false

-- ==========================================
-- CORE FUNCTION LOGIC (MOBILE-SAFE)
-- ==========================================
local function handleShiftlock(actionName, inputState, inputObj)
    if not ScriptEnabled then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    
    if inputState == Enum.UserInputState.Begin and hum and hrp and cam then
        local look = cam.CFrame.LookVector
        local targetDir = Vector3.new(look.X, 0, look.Z).Unit
        hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + targetDir)
        
        hum.CameraOffset = Vector3.new(2.5, 2, 0)
        task.wait(0.4)
        hum.CameraOffset = Vector3.new(0, 0, 0)
    end
end

ContextActionService:BindAction("VbJumpLock", handleShiftlock, false, Enum.KeyCode.Space)

-- MODERN HARDWARE-LEVEL VISUAL DESYNC LOOP
local desyncMultiplier = 0.08
RunService.Heartbeat:Connect(function()
    if DesyncEnabled and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        
        -- Only applies desync while moving to successfully break opponent camera interpolation
        if hrp and hum and hum.MoveDirection.Magnitude > 0 then
            -- Rapidly offsets your frame orientation back and forth horizontally
            hrp.CFrame = hrp.CFrame * CFrame.new(desyncMultiplier, 0, 0)
            RunService.RenderStepped:Wait()
            hrp.CFrame = hrp.CFrame * CFrame.new(-desyncMultiplier, 0, 0)
        end
    end
end)

-- ==========================================
-- SECURE NATIVE SCREEN GUI
-- ==========================================
local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "JosserpopsierV2"
UI.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, 260, 0, 150)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(50, 50, 60)
Stroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "josserpopsier hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local HideBtn = Instance.new("TextButton", UI)
HideBtn.Size = UDim2.new(0, 75, 0, 28)
HideBtn.Position = UDim2.new(0.5, -40, 0, 10)
HideBtn.Text = "Hide Hub"
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.TextSize = 11
HideBtn.Font = Enum.Font.GothamBold
HideBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", HideBtn).CornerRadius = UDim.new(0, 6)

HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    HideBtn.Text = MainFrame.Visible and "Hide Hub" or "Show Hub"
    HideBtn.BackgroundColor3 = MainFrame.Visible and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(0, 110, 230)
end)

local List = Instance.new("UIListLayout", MainFrame)
List.Padding = UDim.new(0, 8)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder

local Spacer = Instance.new("Frame", MainFrame)
Spacer.Size = UDim2.new(1, 0, 0, 35)
Spacer.BackgroundTransparency = 1
Spacer.LayoutOrder = 1

local function MakeButton(labelText, order, callback)
    local Row = Instance.new("Frame", MainFrame)
    Row.Size = UDim2.new(1, -20, 0, 40)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    Row.LayoutOrder = order
    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(1, -85, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(200, 200, 210)
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local Btn = Instance.new("TextButton", Row)
    Btn.Size = UDim2.new(0, 70, 0, 28)
    Btn.Position = UDim2.new(1, -75, 0, 6)
    Btn.Text = "OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = active and "ON" or "OFF"
        Btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 110, 230) or Color3.fromRGB(35, 35, 45)
        callback(active)
    end)
end

MakeButton("Auto Shiftlock", 2, function(state) ScriptEnabled = state end)
MakeButton("Desync Network", 3, function(state) DesyncEnabled = state end)
