local P,T,U=game:GetService("Players"),game:GetService("TweenService"),game:GetService("UserInputService")
local LP,C,PG=P.LocalPlayer,workspace.CurrentCamera,P.LocalPlayer:WaitForChild("PlayerGui")
if PG:FindFirstChild("JHubV6") then PG.JHubV6:Destroy() end
local SL,FaceESP,Opt,ActiveBeams,JT,JP,TD=false,false,false,{},nil,false,nil
local UI=Instance.new("ScreenGui",PG)UI.Name="JHubV6"UI.ResetOnSpawn=false
local M=Instance.new("Frame",UI)M.Size,M.Position,M.BackgroundColor3,M.BackgroundTransparency=UDim2.new(0,220,0,175),UDim2.new(0.05,0,0.35,0),Color3.fromRGB(10,10,12),0.15
M.Active,M.Draggable,M.Visible=true,true,false
Instance.new("UICorner",M).CornerRadius=UDim.new(0,8)
local S=Instance.new("UIStroke",M)S.Color,S.Thickness=Color3.fromRGB(235,35,75),1.2
local L=Instance.new("UIListLayout",M)L.Padding,L.HorizontalAlignment,L.VerticalAlignment=UDim.new(0,10),Enum.HorizontalAlignment.Center,Enum.VerticalAlignment.Center
local function Clamp() local vs=C.ViewportSize M.Position=UDim2.new(0,math.clamp(M.AbsolutePosition.X,12,vs.X-M.AbsoluteSize.X-12),0,math.clamp(M.AbsolutePosition.Y,35,vs.Y-M.AbsoluteSize.Y-35)) end
M:GetPropertyChangedSignal("Position"):Connect(Clamp)C:GetPropertyChangedSignal("ViewportSize"):Connect(Clamp)
local Tl=Instance.new("TextLabel",M)Tl.Size,Tl.Text,Tl.TextColor3,Tl.TextSize,Tl.Font,Tl.BackgroundTransparency=UDim2.new(1,-20,0,16),"JOSSERPOPSIER // V6",Color3.fromRGB(255,255,255),11,Enum.Font.GothamBold,1
local Tg=Instance.new("TextButton",UI)Tg.Size,Tg.Position,Tg.Text,Tg.TextColor3,Tg.Font,Tg.TextSize,Tg.BackgroundColor3,Tg.Visible=UDim2.new(0,65,0,24),UDim2.new(1,-85,0,45),"HIDE",Color3.fromRGB(240,240,240),Enum.Font.GothamBold,9,Color3.fromRGB(15,15,18),false
Instance.new("UICorner",Tg).CornerRadius=UDim.new(0,5)
Instance.new("UIStroke",Tg).Color,Instance.new("UIStroke",Tg).Thickness=Color3.fromRGB(235,35,75),1
Tg.MouseButton1Click:Connect(function() M.Visible=not M.Visible Tg.Text=M.Visible and "HIDE" or "SHOW" end)
local function MB(txt,cb)
    local Cd=Instance.new("Frame",M)Cd.Size,Cd.BackgroundColor3,Cd.BorderSizePixel=UDim2.new(1,-20,0,34),Color3.fromRGB(18,18,22),0
    Instance.new("UICorner",Cd).CornerRadius=UDim.new(0,5)
    local Lb=Instance.new("TextLabel",Cd)Lb.Size,Lb.Position,Lb.Text,Lb.TextColor3,Lb.TextSize,Lb.Font,Lb.TextXAlignment,Lb.BackgroundTransparency=UDim2.new(1,-75,1,0),UDim2.new(0,10,0,0),txt,Color3.fromRGB(210,210,215),11,Enum.Font.GothamMedium,Enum.TextXAlignment.Left,1
    local B=Instance.new("TextButton",Cd)B.Size,B.Position,B.Text,B.Font,B.TextSize,B.BackgroundColor3,B.TextColor3=UDim2.new(0,48,0,20),UDim2.new(1,-58,0,7),"OFF",Enum.Font.GothamBold,9,Color3.fromRGB(28,28,34),Color3.fromRGB(140,140,145)
    Instance.new("UICorner",B).CornerRadius=UDim.new(0,4)
    local st=false B.MouseButton1Click:Connect(function()
        st=not st B.Text=st and "ON" or "OFF"
        B.BackgroundColor3=st and Color3.fromRGB(235,35,75) or Color3.fromRGB(28,28,34)
        B.TextColor3=st and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,145)
        cb(st)
    end)
end
local function CE() for _,i in pairs(ActiveBeams) do pcall(function() i.Beam:Destroy() i.A0:Destroy() i.A1:Destroy() end) end table.clear(ActiveBeams) end

-- REALISTIC DARK LIGHTING & TOTAL SMOOTH PLASTIC SYSTEM
game:GetService("RunService").RenderStepped:Connect(function()
    if not Opt then return end
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        local lighting = game:GetService("Lighting")
        
        -- FORCES HIGH-CONTRAST COMPETITIVE DARK SHADOW MAP
        lighting.GlobalShadows = true
        lighting.Ambient = Color3.fromRGB(10, 10, 10)
        lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 10)
        lighting.Brightness = 0.2
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0
        
        for _,g in ipairs(lighting:GetChildren()) do 
            if g:IsA("PostEffect") or g:IsA("Atmosphere") or g:IsA("Clouds") or g:IsA("Sky") then g.Enabled = false end 
        end
        
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.MaterialVariant = ""
                if v:IsA("MeshPart") or v:IsA("UnionOperation") then
                    v.RenderFidelity = Enum.RenderFidelity.Performance
                    v.LevelOfDetail = Enum.LevelOfDetail.Low
                    pcall(function() v.TextureID = "" end) -- Nukes embedded court designs
                end
            elseif v:IsA("SurfaceAppearance") or v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Trail") then
                v:Destroy() -- Strips custom court decals instantly
            elseif v:IsA("Accessory") or v:IsA("Hat") or v:IsA("Clothing") or v:IsA("ShirtGraphic") then
                if not v:IsDescendantOf(LP.Character) then v:Destroy() end
            elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") or v:IsA("ScreenGui") then
                if not v:IsDescendantOf(LP) then v.Enabled = false end
            end
        end
    end)
end)

MB("Auto Shiftlock",function(v) SL=v if not v then JP,TD=false,nil end end)
MB("Player Face Lines",function(v) FaceESP=v if not v then CE() end end)
MB("Fast Flags",function(v) Opt=v end)
local function IT(p) if p==LP or (LP.Team and p.Team and LP.Team==p.Team) then return true end return false end
game:GetService("RunService").RenderStepped:Connect(function()
    if not FaceESP then return end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and not IT(p) and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then
            local h,r,d=p.Character.Head,p.Character:FindFirstChild("HumanoidRootPart") or p.Character.Head,ActiveBeams[p]
            if not d then
                local a0,a1,b=Instance.new("Attachment",workspace.Terrain),Instance.new("Attachment",workspace.Terrain),Instance.new("Beam",workspace.Terrain)
                b.Attachment0,b.Attachment1,b.Width0,b.Width1,b.Color,b.FaceCamera,b.LightEmission,b.LightInfluence,b.ZOffset=a0,a1,0.45,0.20,ColorSequence.new(Color3.fromRGB(0,255,120)),true,1.0,0.0,2
                d={Beam=b,A0=a0,A1=a1}ActiveBeams[p]=d
            end
            local l=r.CFrame.LookVector local f=Vector3.new(l.X,0,l.Z).Unit
            d.A0.WorldPosition=h.Position+(f*0.6) d.A1.WorldPosition=h.Position+(f*30)
        elseif ActiveBeams[p] then pcall(function() ActiveBeams[p].Beam:Destroy() ActiveBeams[p].A0:Destroy() ActiveBeams[p].A1:Destroy() end) ActiveBeams[p]=nil end
    end
end)
P.PlayerRemoving:Connect(function(p) if ActiveBeams[p] then pcall(function() ActiveBeams[p].Beam:Destroy() ActiveBeams[p].A0:Destroy() ActiveBeams[p].A1:Destroy() end) ActiveBeams[p]=nil end end)
task.spawn(function()
    local It=Instance.new("Frame",UI)It.Size,It.Position,It.BackgroundColor3=UDim2.new(0,160,0,30),UDim2.new(0.5,-80,0.45,-15),Color3.fromRGB(10,10,12)
    Instance.new("UICorner",It).CornerRadius=UDim.new(0,6)
    local IS=Instance.new("UIStroke",It)IS.Color,IS.Thickness=Color3.fromRGB(235,35,75),1.2
    local BB=Instance.new("Frame",It)BB.Size,BB.Position,BB.BackgroundColor3,BB.BorderSizePixel=UDim2.new(1,-24,0,3),UDim2.new(0,12,0.5,-1),Color3.fromRGB(24,24,30),0
    Instance.new("UICorner",BB).CornerRadius=UDim.new(1,0)
    local BF=Instance.new("Frame",BB)BF.Size,BF.BackgroundColor3,BF.BorderSizePixel=UDim2.new(0,0,1,0),Color3.fromRGB(235,35,75),0
    Instance.new("UICorner",BF).CornerRadius=UDim.new(1,0)
    T:Create(BF,TweenInfo.new(1.8,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,0)}):Play()
    task.wait(2.0)
    local o=TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    T:Create(It,o,{BackgroundTransparency=1}):Play()T:Create(IS,o,{Transparency=1}):Play()T:Create(BB,o,{BackgroundTransparency=1}):Play()T:Create(BF,o,{BackgroundTransparency=1}):Play()
    task.wait(0.25)It:Destroy()M.Visible,Tg.Visible=true,true Clamp()
end)
local function SU(ch)
    local hm=ch:WaitForChild("Humanoid")
    hm.Jumping:Connect(function() if not SL then return end if JT then task.cancel(JT) end local l=C.CFrame.LookVector TD,JP=Vector3.new(l.X,0,l.Z).Unit,true JT=task.spawn(function() task.wait(0.4) JP,TD=false,nil end) end)
    hm.StateChanged:Connect(function(_,s) if s==Enum.HumanoidStateType.Landed then JP,TD=false,nil if JT then task.cancel(JT) end end end)
end
if LP.Character then SU(LP.Character) end LP.CharacterAdded:Connect(SU)
game:GetService("RunService").RenderStepped:Connect(function()
    if not SL or not JP or not TD then return end
    local ch=LP.Character local rt,hm=ch and ch:FindFirstChild("HumanoidRootPart"),ch and ch:FindFirstChildOfClass("Humanoid")
    if rt and hm and hm.Health>0 then U.MouseBehavior=Enum.MouseBehavior.LockCenter rt.CFrame=CFrame.new(rt.Position,rt.Position+TD) hm.CameraOffset=hm.CameraOffset:LinearInterpolate(Vector3.new(2.5,2,0),0.2) end
end)
