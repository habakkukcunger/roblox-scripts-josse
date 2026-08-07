local Library = {
    Flags = {
        ["A Sync Enabled"] = true,
        ["A Sync Cooldown"] = 0.3, -- How long it stays active after jumping
    }
}


pcall(function()
    setfflag("PhysicsSenderMaxBandwidthBps", "40000")
end)


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui") 
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Hrp = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

local isAsyncRunning = false  


local function ConnectCharacter(NewCharacter)
    Character = NewCharacter
    Hrp = NewCharacter:WaitForChild("HumanoidRootPart")
    Humanoid = NewCharacter:WaitForChild("Humanoid")
    
  
    Humanoid.Jumping:Connect(function(isActive)
     
        if Library.Flags["A Sync Enabled"] and isActive and not isAsyncRunning then
            isAsyncRunning = true
            
          
            pcall(function()
                setfflag("PhysicsSenderMaxBandwidthBps", "1")
            end)

            task.wait(Library.Flags["A Sync Cooldown"])
            
           
            pcall(function()
                setfflag("PhysicsSenderMaxBandwidthBps", "999999")
            end)
            
            task.wait(0.05)
            isAsyncRunning = false
        end
    end)
end


ConnectCharacter(Character)
LocalPlayer.CharacterAdded:Connect(ConnectCharacter)
