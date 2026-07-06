-- ==========================================
-- ANTI-EXECUTION GUARD (Prevents Duplicates)
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("Orion") or CoreGui:FindFirstChild("Orion") then
    print("josserpopsier Hub is already running! Execution stopped to prevent clutter.")
    return
end

-- Load Orion UI Library
local OrionLib = loadstring(game:HttpGet(('https://githubusercontent.com')))()

-- ==========================================
-- MAIN MECHANICS DATA
-- ==========================================
local P, R, U, C = game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), workspace.CurrentCamera
local LP = P.LocalPlayer
local off = Vector3.new(2.5, 2, 0)

-- Core Control Variables
local ScriptEnabled = false 
local sl = false
local targetDir = nil 
local jumpTimeThread = nil 

-- Core Shiftlock Setup
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

-- Continuous Render Loop
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
-- ORION WINDOW & TABS CONFIGURATION
-- ==========================================
local Window = OrionLib:MakeWindow({
    Name = "josserpopsier Hub | Volleyball Legends", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroText = "Loading josserpopsier..."
})

-- TAB 1: Movement Controls
local MovementTab = Window:MakeTab({
    Name = "Movement",
    Icon = "rbxassetid://4483345998"
})

MovementTab:AddToggle({
    Name = "Auto Shiftlock (On Jump)",
    Default = false,
    Callback = function(Value)
        ScriptEnabled = Value
        if not ScriptEnabled then
            sl = false
            targetDir = nil
        end
    end    
})

-- TAB 2: Utility Modifiers
local UtilsTab = Window:MakeTab({
    Name = "Utilities",
    Icon = "rbxassetid://4483345998"
})

UtilsTab:AddSlider({
    Name = "WalkSpeed Customizer",
    Min = 16,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(80, 120, 250),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Value
        end
    end    
})

UtilsTab:AddSlider({
    Name = "JumpPower Customizer",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(250, 120, 80),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = Value
        end
    end    
})

-- Initialize the library layout completely
OrionLib:Init()
