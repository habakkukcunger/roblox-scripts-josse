local P = game:GetService("Players")
local T = game:GetService("TweenService")
local R = game:GetService("RunService")
local U = game:GetService("UserInputService")
local LP = P.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")
local C = workspace.CurrentCamera

local oldUI = PlayerGui:FindFirstChild("JosserpopsierV2")
if oldUI then oldUI:Destroy() end
task.wait(0.1)

local ScriptEnabled, sl, targetDir, jumpTimeThread = false, false, nil, nil
local off = Vector3.new(2.5, 2, 0)

local UI = Instance.new("ScreenGui", PlayerGui)
UI.Name = "JosserpopsierV2"
UI.ResetOnSpawn = false

-- ==========================================
-- PROFILE INTRO ANIMATION CONSTRUCT
-- ==========================================
local Intro = Instance.new("Frame", UI)
Intro.Size = UDim2.new(0, 280, 0, 150)
Intro.Position = UDim2.new(0.5, -140, 0.4, -75)
Intro.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Intro.BackgroundTransparency = 1

local IntroCorner = Instance.new("UICorner", Intro)
IntroCorner.CornerRadius = UDim.new(0, 10)

local IntroStroke = Instance.new("UIStroke", Intro)
IntroStroke.Color = Color3.fromRGB(50, 50, 60)
IntroStroke.Thickness = 1.5
IntroStroke.Transparency = 1

local Avatar = Instance.new("ImageLabel", Intro)
Avatar.Size = UDim2.new(0, 60, 0, 60)
Avatar.Position = UDim2.new(0.5, -30, 0, 15)
Avatar.BackgroundTransparency = 1
Avatar.ImageTransparency = 1

local AvCorner = Instance.new("UICorner", Avatar)
AvCorner.CornerRadius = UDim.new(1, 0)

task.spawn(function()
    pcall(function()
        local content, isReady = P:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        if isReady then Avatar.Image = content end
    end)
end)

local IntroText = Instance.new("TextLabel", Intro)
IntroText.Size = UDim2.new(1, 0, 0, 25)
IntroText.Position = UDim2.new(0, 0, 0, 85)
IntroText.Text = "script made by jossepopsi"
IntroText.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroText.TextSize = 14
IntroText.Font = Enum.Font.GothamBold
IntroText.TextTransparency = 1
IntroText.BackgroundTransparency = 1

local BarBg = Instance.new("Frame", Intro)
BarBg.Size = UDim2.new(0, 180, 0, 4)
BarBg.Position = UDim2.new(0.5, -90, 0, 120)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BarBg.BackgroundTransparency = 1

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 110, 230)
BarFill.BackgroundTransparency = 1

-- ==========================================
-- MAIN HUB INTERFACE CONSTRUCT
-- ==========================================
local Main = Instance.new("Frame", UI)
Main.Size = UDim2.new(0, 260, 0, 110)
Main.Position = UDim2.new(0.05, 0, 0.6, 0) 
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true 
Main.Visible = false

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(50, 50, 60)
MainStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "josserpopsier hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local TogBtn = Instance.new("TextButton", UI)
TogBtn.Size = UDim2.new(0, 85, 0, 28)
TogBtn.Position = UDim2.new(1, -100, 0, 15) 
TogBtn.Text = "Hide Hub"
TogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TogBtn.TextSize = 11
TogBtn.Font = Enum.Font.GothamBold
TogBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TogBtn.Visible = false

local TogCorner = Instance.new("UICorner", TogBtn)
TogCorner.CornerRadius = UDim.new(0, 6)

local TogStroke = Instance.new("UIStroke", TogBtn)
TogStroke.Color = Color3.fromRGB(50, 52, 68)

TogBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    TogBtn.Text = Main.Visible and "Hide Hub" or "Show Hub"
    TogBtn.BackgroundColor3 = Main.Visible and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(0, 110, 230)
end)

local List = Instance.new("UIListLayout", Main)
List.Padding = UDim.new(0, 8)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.SortOrder = Enum.SortOrder.LayoutOrder

local Spacer = Instance.new("Frame", Main)
Spacer.Size = UDim2.new(1, 0, 0, 35)
Spacer.BackgroundTransparency = 1
Spacer.LayoutOrder = 1

local Card = Instance.new("Frame", Main)
Card.Size = UDim2.new(1, -20, 0, 40)
Card.LayoutOrder = 2
Card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)

local CardCorner = Instance.new("UICorner", Card)
CardCorner.CornerRadius = UDim.new(0, 6)

local Label = Instance.new("TextLabel", Card)
Label.Size = UDim2.new(1, -85, 1, 0)
Label.Position = UDim2.new(0, 10, 0, 0)
Label.Text = "Auto Shiftlock"
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

local BtnCorner = Instance.new("UICorner", Btn)
BtnCorner.CornerRadius = UDim.new(0, 4)

Btn.MouseButton1Click:Connect(function()
    ScriptEnabled = not ScriptEnabled
    Btn.Text = ScriptEnabled and "ON" or "OFF"
    Btn.TextColor3 = ScriptEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    Btn.BackgroundColor3 = ScriptEnabled and Color3.fromRGB(0, 110, 230) or Color3.fromRGB(35, 35, 45)
    if not ScriptEnabled then sl = false targetDir = nil end
end)

-- ==========================================
-- TIMELINE SEQUENCER & CORE LOGIC
-- ==========================================
task.spawn(function()
    local info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    T:Create(Intro, info, {BackgroundTransparency = 0}):Play()
    T:Create(IntroStroke, info, {Transparency = 0}):Play()
    T:Create(Avatar, info, {ImageTransparency = 0}):Play()
    T:Create(IntroText, info, {TextTransparency = 0}):Play()
    T:Create(BarBg, info, {BackgroundTransparency = 0}):Play()
    T:Create(BarFill, info, {BackgroundTransparency = 0}):Play()
    task.wait(0.5)
    
    -- Extended loading bar tween from 1.5 seconds to 4.0 seconds
    local load = T:Create(BarFill, TweenInfo.new(4.0, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
    load:Play()
    load.Completed:Wait()
    task.wait(0.2)
    
    local out = T:Create(Intro, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -140, 1.1, 0), BackgroundTransparency = 1})
    T:Create(IntroStroke, info, {Transparency = 1}):Play()
    T:Create(Avatar, info, {ImageTransparency = 1}):Play()
    T:Create(IntroText, info, {TextTransparency = 1}):Play()
    T:Create(BarBg, info, {BackgroundTransparency = 1}):Play()
    T:Create(BarFill, info, {BackgroundTransparency = 1}):Play()
    out:Play()
    out.Completed:Wait()
    
    Intro:Destroy()
    Main.Visible = true
    TogBtn.Visible = true
end)

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
