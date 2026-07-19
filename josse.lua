local P,T,U=game:GetService("Players"),game:GetService("TweenService"),game:GetService("UserInputService")
local LP,C,PG=P.LocalPlayer,workspace.CurrentCamera,P.LocalPlayer:WaitForChild("PlayerGui")
if PG:FindFirstChild("JHubV6") then PG.JHubV6:Destroy() end

local SL,FaceESP,ActiveBeams,AntiLag,JT,JP,TD=false,false,{},false,nil,false,nil
local UI=Instance.new("ScreenGui",PG)UI.Name="JHubV6"UI.ResetOnSpawn=false

local M=Instance.new("Frame",UI)M.Size,M.Position,M.BackgroundColor3,M.BackgroundTransparency=UDim2.new(0,220,0,200),UDim2.new(0.05,0,0.35,0),Color3.fromRGB(10,10,12),0.15
M.Active,M.Draggable,M.Visible=true,true,false
Instance.new("UICorner",M).CornerRadius=UDim.new(0,8)
local S=Instance.new("UIStroke",M)S.Color,S.Thickness=Color3.fromRGB(235,35,75),1.2
local L=Instance.new("UIListLayout",M)L.Padding,L.HorizontalAlignment,L.VerticalAlignment=UDim.new(0,10),Enum.HorizontalAlignment.Center,Enum.VerticalAlignment.Center

local function Clamp() local vs=C.ViewportSize M.Position=UDim2.new(0,math.clamp(M.AbsolutePosition.X,12,vs.X-M.AbsoluteSize.X-12),0,math.clamp(M.AbsolutePosition.Y,35,vs.Y-M.AbsoluteSize.Y-35)) end
M:GetPropertyChangedSignal("Position"):Connect(Clamp)C:GetPropertyChangedSignal("ViewportSize"):Connect(Clamp)

local Tl=Instance.new("TextLabel",M)Tl.Size,Tl.Text,Tl.TextColor3,Tl.TextSize,Tl.Font,Tl.BackgroundTransparency=UDim2.new(1,-20,0,16),"JOSSERPOPSIER",Color3.fromRGB(255,255,255),11,Enum.Font.GothamBold,1

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

MB("Auto Shiftlock",function(v) SL=v if not v then JP,TD=false,nil end end)
MB("Direction Facing Esp",function(v) FaceESP=v if not v then CE() end end)

-- Anti-Lag System
local LagSettings={Textures=true,Shadows=true,Particles=true,MeshDetail=true,LightingQuality=true}
local OriginalStates={}

local function SaveOriginalState(obj)
    if OriginalStates[obj] then return end
    local state={}
    if obj:IsA("BasePart") then
        state.Material=obj.Material
        state.Color=obj.Color
        if obj:IsA("MeshPart") then
            state.TextureID=obj.TextureID
        end
    elseif obj:IsA("Texture") or obj:IsA("Decal") then
        state.Texture=obj.Texture
        state.Transparency=obj.Transparency
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        state.Enabled=obj.Enabled
    elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
        state.Enabled=obj.Enabled
        state.Brightness=obj.Brightness
    end
    if next(state) then OriginalStates[obj]=state end
end

local function ApplyAntiLag()
    if not AntiLag then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                SaveOriginalState(obj)
                if LagSettings.Textures then
                    obj.Material=Enum.Material.SmoothPlastic
                    if obj:IsA("MeshPart") then
                        obj.TextureID=""
                    end
                end
            elseif (obj:IsA("Texture") or obj:IsA("Decal")) and LagSettings.Textures then
                SaveOriginalState(obj)
                obj.Transparency=1
            elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail")) and LagSettings.Particles then
                SaveOriginalState(obj)
                obj.Enabled=false
            elseif (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) and LagSettings.Shadows then
                SaveOriginalState(obj)
                obj.Enabled=false
            end
        end)
    end
    if LagSettings.LightingQuality then
        local lighting=game:GetService("Lighting")
        OriginalStates[lighting]=OriginalStates[lighting] or {}
        if not OriginalStates[lighting].Technology then
            OriginalStates[lighting].Technology=lighting.Technology
        end
        if not OriginalStates[lighting].GlobalShadows then
            OriginalStates[lighting].GlobalShadows=lighting.GlobalShadows
        end
        lighting.Technology=Enum.Technology.Compatibility
        lighting.GlobalShadows=false
    end
end

local function RestoreOriginal()
    for obj,state in pairs(OriginalStates) do
        pcall(function()
            if obj:IsA("BasePart") then
                if state.Material then obj.Material=state.Material end
                if state.Color then obj.Color=state.Color end
                if obj:IsA("MeshPart") and state.TextureID~=nil then obj.TextureID=state.TextureID end
            elseif obj:IsA("Texture") or obj:IsA("Decal") then
                if state.Texture then obj.Texture=obj.Texture end
                if state.Transparency then obj.Transparency=state.Transparency end
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                if state.Enabled~=nil then obj.Enabled=state.Enabled end
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                if state.Enabled~=nil then obj.Enabled=state.Enabled end
                if state.Brightness then obj.Brightness=state.Brightness end
            end
        end)
    end
    local lighting=game:GetService("Lighting")
    if OriginalStates[lighting] then
        if OriginalStates[lighting].Technology then lighting.Technology=OriginalStates[lighting].Technology end
        if OriginalStates[lighting].GlobalShadows~=nil then lighting.GlobalShadows=OriginalStates[lighting].GlobalShadows end
    end
    OriginalStates={}
end

-- Anti-Lag Toggle with Settings
local LagFrame=Instance.new("Frame",M)LagFrame.Size,LagFrame.BackgroundColor3,LagFrame.BorderSizePixel=UDim2.new(1,-20,0,80),Color3.fromRGB(18,18,22),0
Instance.new("UICorner",LagFrame).CornerRadius=UDim.new(0,5)
local LagTitle=Instance.new("TextLabel",LagFrame)LagTitle.Size,LagTitle.Position,LagTitle.Text,LagTitle.TextColor3,LagTitle.TextSize,LagTitle.Font,LagTitle.BackgroundTransparency=UDim2.new(1,0,0,14),UDim2.new(0,0,0,2),"ANTI-LAG",Color3.fromRGB(235,35,75),9,Enum.Font.GothamBold,1

local function LagToggle(name,setting,yPos)
    local Lb=Instance.new("TextLabel",LagFrame)Lb.Size,Lb.Position,Lb.Text,Lb.TextColor3,Lb.TextSize,Lb.Font,Lb.TextXAlignment,Lb.BackgroundTransparency=UDim2.new(0,80,0,14),UDim2.new(0,8,0,yPos),name,Color3.fromRGB(180,180,185),8,Enum.Font.GothamMedium,Enum.TextXAlignment.Left,1
    local B=Instance.new("TextButton",LagFrame)B.Size,B.Position,B.Text,B.Font,B.TextSize,B.BackgroundColor3,B.TextColor3=UDim2.new(0,28,0,14),UDim2.new(0,88,0,yPos),"ON",Enum.Font.GothamBold,7,Color3.fromRGB(235,35,75),Color3.fromRGB(255,255,255)
    Instance.new("UICorner",B).CornerRadius=UDim.new(0,3)
    B.MouseButton1Click:Connect(function()
        LagSettings[setting]=not LagSettings[setting]
        B.Text=LagSettings[setting] and "ON" or "OFF"
        B.BackgroundColor3=LagSettings[setting] and Color3.fromRGB(235,35,75) or Color3.fromRGB(28,28,34)
        B.TextColor3=LagSettings[setting] and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,140,145)
        if AntiLag then
            RestoreOriginal()
            ApplyAntiLag()
        end
    end)
end

LagToggle("Textures","Textures",18)
LagToggle("Shadows","Shadows",34)
LagToggle("Particles","Particles",50)
LagToggle("Mesh","MeshDetail",66)

MB("Anti Lag",function(v)
    AntiLag=v
    if v then
        ApplyAntiLag()
    else
        RestoreOriginal()
    end
end)

-- Auto-reapply when new objects spawn
workspace.DescendantAdded:Connect(function(obj)
    if not AntiLag then return end
    task.wait(0.1)
    pcall(function()
        if obj:IsA("BasePart") and not obj:IsA("Terrain") and LagSettings.Textures then
            SaveOriginalState(obj)
            obj.Material=Enum.Material.SmoothPlastic
            if obj:IsA("MeshPart") then obj.TextureID="" end
        elseif (obj:IsA("Texture") or obj:IsA("Decal")) and LagSettings.Textures then
            SaveOriginalState(obj)
            obj.Transparency=1
        elseif (obj:IsA("ParticleEmitter") or obj:IsA("Trail")) and LagSettings.Particles then
            SaveOriginalState(obj)
            obj.Enabled=false
        elseif (obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight")) and LagSettings.Shadows then
            SaveOriginalState(obj)
            obj.Enabled=false
        end
    end)
end)

-- Face ESP
local function IT(p) if p==LP or (LP.Team and p.Team and LP.Team==p.Team) then return true end return false end

game:GetService("RunService").RenderStepped:Connect(function()
    if not FaceESP then return end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and not IT(p) and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then
            local h,r,d=p.Character.Head,p.Character:FindFirstChild("HumanoidRootPart") or p.Character.Head,ActiveBeams[p]
            if not d then
                local a0,a1,b=Instance.new("Attachment",workspace.Terrain),Instance.new("Attachment",workspace.Terrain),Instance.new("Beam",workspace.Terrain)
                b.Attachment0,b.Attachment1,b.Width0,b.Width1,b.Color,b.FaceCamera,b.LightEmission,b.LightInfluence,b.ZOffset=a0,a1,0.45,0.45,ColorSequence.new(Color3.fromRGB(0,255,120)),true,1.0,0.0,2
                d={Beam=b,A0=a0,A1=a1}ActiveBeams[p]=d
            end
            local l=r.CFrame.LookVector local f=Vector3.new(l.X,0,l.Z).Unit
            d.A0.WorldPosition=h.Position+(f*0.6) d.A1.WorldPosition=h.Position+(f*30)
        elseif ActiveBeams[p] then pcall(function() ActiveBeams[p].Beam:Destroy() ActiveBeams[p].A0:Destroy() ActiveBeams[p].A1:Destroy() end) ActiveBeams[p]=nil end
    end
end)

P.PlayerRemoving:Connect(function(p) if ActiveBeams[p] then pcall(function() ActiveBeams[p].Beam:Destroy() ActiveBeams[p].A0:Destroy() ActiveBeams[p].A1:Destroy() end) ActiveBeams[p]=nil end end)

-- Init screen
task.spawn(function()
    local It=Instance.new("Frame",UI)It.Size,It.Position,It.BackgroundColor3=UDim2.new(0,180,0,35),UDim2.new(0.5,-90,0.45,-17),Color3.fromRGB(12,12,15)
    Instance.new("UICorner",It).CornerRadius=UDim.new(0,6)
    local IS=Instance.new("UIStroke",It)IS.Color,IS.Thickness,IS.ApplyStrokeMode=Color3.fromRGB(235,35,75),1.2,Enum.ApplyStrokeMode.Border
    local Lb=Instance.new("TextLabel",It)Lb.Size,Lb.Position,Lb.Text,Lb.TextColor3,Lb.TextSize,Lb.Font,Lb.BackgroundTransparency=UDim2.new(1,0,0,14),UDim2.new(0,0,0,5),"INITIALIZING...",Color3.fromRGB(150,150,155),8,Enum.Font.GothamBold,1
    local BB=Instance.new("Frame",It)BB.Size,BB.Position,BB.BackgroundColor3,BB.BorderSizePixel=UDim2.new(1,-24,0,2),UDim2.new(0,12,1,-10),Color3.fromRGB(24,24,30),0
    Instance.new("UICorner",BB).CornerRadius=UDim.new(1,0)
    local BF=Instance.new("Frame",BB)BF.Size,BB.BackgroundColor3,BF.BorderSizePixel=UDim2.new(0,0,1,0),Color3.fromRGB(235,35,75),0
    Instance.new("UICorner",BF).CornerRadius=UDim.new(1,0)
    local G=Instance.new("UIGradient",BF)G.Color=ColorSequence.new(Color3.fromRGB(235,35,75),Color3.fromRGB(255,80,120))
    T:Create(BF,TweenInfo.new(1.8,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,0)}):Play()
    task.wait(2.0)
    local o=TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    T:Create(It,o,{BackgroundTransparency=1}):Play()T:Create(IS,o,{Transparency=1}):Play()T:Create(BB,o,{BackgroundTransparency=1}):Play()T:Create(BF,o,{BackgroundTransparency=1}):Play()T:Create(Lb,o,{TextTransparency=1}):Play()
    task.wait(0.25)It:Destroy()M.Visible,Tg.Visible=true,true Clamp()
end)

-- Shiftlock
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
