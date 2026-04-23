--[[
    ███████╗██████╗  █████╗  ██████╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗
    ██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║
    █████╗  ██████╔╝███████║██║        ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║
    ██╔══╝  ██╔══██╗██╔══██║██║        ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║
    ██║     ██║  ██║██║  ██║╚██████╗   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗
    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
    fracternal v1 | fracternal.cc
]]

-- ════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local LocalPlayer       = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════
--  VOID CONFIG
-- ════════════════════════════════════════════════════════════
local CFG = {
    VOID_METHOD         = "Fractal XAR (BEST)",
    VOID_Y_BASE         = 0,
    VOID_DRIFT_SPEED    = 500,
    VOID_DRIFT_CHAOS    = 0.5,
    VOID_Y_DRIFT_SPEED  = 200,
    VOID_Y_DRIFT_RANGE  = 500,
    VOID_GRAVITY_STR    = 1e9,
    VOID_FLICKER_INT    = 0.05,
    VOID_LISSAJOUS_A    = 3,
    VOID_LISSAJOUS_B    = 2,
    MAX_COORDS          = 2100000000,
    MIN_COORDS          = 0,
}

-- ════════════════════════════════════════════════════════════
--  UI STATE
-- ════════════════════════════════════════════════════════════
local UI = {
    AccentColor   = Color3.fromRGB(148, 148, 172),
    DarkBg        = Color3.fromRGB(12, 12, 16),
    MidBg         = Color3.fromRGB(18, 18, 24),
    LightBg       = Color3.fromRGB(26, 26, 34),
    SurfBg        = Color3.fromRGB(21, 21, 29),
    Border        = Color3.fromRGB(46, 46, 62),
    TextPri       = Color3.fromRGB(215, 215, 232),
    TextSec       = Color3.fromRGB(118, 118, 142),
    TextDim       = Color3.fromRGB(74, 74, 96),
    Font          = Enum.Font.Gotham,
    Bold          = Enum.Font.GothamBold,
    Mono          = Enum.Font.Code,
    VoidKeybind   = Enum.KeyCode.V,
    HideKeybind   = Enum.KeyCode.RightShift,
    UIVisible     = true,
    VoidActive    = false,
    ActiveTab     = "Void",
}

-- ════════════════════════════════════════════════════════════
--  VOID STATE
-- ════════════════════════════════════════════════════════════
local voidX, voidZ         = 0, 0
local voidYOffset          = 0
local voidDirX, voidDirZ   = 1, 0
local voidYDir             = 1
local elapsed              = 0
local _xarActive           = false
local voidConn             = nil
local capturingVoidKB      = false
local capturingHideKB      = false

-- ════════════════════════════════════════════════════════════
--  VOID LOGIC
-- ════════════════════════════════════════════════════════════
local function computeDriftDir(t)
    local a = t * 0.8
    return math.cos(a), math.sin(a)
end

local function stepVoid(dt)
    elapsed = elapsed + dt
    local m = CFG.VOID_METHOD

    if m == "Stable" then
        return Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)

    elseif m == "Fracternal Desync" then
        local t = elapsed * 5
        local x = math.sin(t) + math.sin(t*2.1)/2 + math.sin(t*3.2)/4
        local z = math.cos(t) + math.cos(t*2.2)/2 + math.cos(t*3.1)/4
        return Vector3.new(voidX + x*1e10, CFG.VOID_Y_BASE + math.sin(t*10)*1e9, voidZ + z*1e10)

    elseif m == "Drift" then
        local dx, dz = computeDriftDir(elapsed)
        voidDirX = voidDirX + (dx - voidDirX) * CFG.VOID_DRIFT_CHAOS * dt * 10
        voidDirZ = voidDirZ + (dz - voidDirZ) * CFG.VOID_DRIFT_CHAOS * dt * 10
        voidX = voidX + voidDirX * CFG.VOID_DRIFT_SPEED * dt
        voidZ = voidZ + voidDirZ * CFG.VOID_DRIFT_SPEED * dt
        voidYOffset = voidYOffset + voidYDir * CFG.VOID_Y_DRIFT_SPEED * dt
        if math.abs(voidYOffset) >= CFG.VOID_Y_DRIFT_RANGE then voidYDir = -voidYDir end
        return Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)

    elseif m == "Chaotic" then
        voidX = voidX + (math.random()-0.5) * CFG.VOID_DRIFT_SPEED * dt * 5
        voidZ = voidZ + (math.random()-0.5) * CFG.VOID_DRIFT_SPEED * dt * 5
        voidYOffset = voidYOffset + (math.random()-0.5) * CFG.VOID_Y_DRIFT_SPEED * dt * 5
        return Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)

    elseif m == "Eclipse Singularity" then
        local t = elapsed * 6
        local pulse = (math.sin(elapsed * 0.8) + 1) * 0.5
        local r = 8e10 + pulse * 4e10
        local x = math.sin(t)*r + math.sin(t*2.7)*2e10 + math.cos(t*5.3)*8e9
        local z = math.cos(t)*r + math.cos(t*2.4)*2e10 + math.sin(t*4.9)*8e9
        local y = CFG.VOID_Y_BASE + math.sin(t*1.3)*2e10 + math.cos(t*3.1)*7e9
        if math.floor(elapsed*8) % 6 == 0 then x=-x*1.15 z=-z*1.15 end
        return Vector3.new(voidX+x, y, voidZ+z)

    elseif m == "Fractal XAR (BEST)" then
        if not _xarActive then
            _xarActive = true
            local hrp, cc, cv, ca
            local function bRand(mi, ma, dmi, dma)
                local v, g = math.random(mi,ma), 0
                repeat v=math.random(mi,ma) g=g+1
                until v<dmi or v>dma or g>20
                return v
            end
            voidConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local ch = LocalPlayer.Character
                    if not ch then return end
                    hrp = ch:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    cc = hrp.CFrame
                    cv = hrp.AssemblyLinearVelocity
                    ca = hrp.AssemblyAngularVelocity
                    hrp.CFrame = CFrame.new(
                        bRand(-2147483646,2147483646,-1147483646,1147483646),
                        bRand(-2147483646,2147483646,-1147483646,1147483646),
                        bRand(-2147483646,2147483646,-1147483646,1147483646)
                    ) * CFrame.Angles(math.pi, math.pi, math.pi)
                    hrp.AssemblyLinearVelocity  = Vector3.new(
                        bRand(-2147483646,2147483646,-1147483646,1147483646),
                        bRand(-2147483646,2147483646,-1147483646,1147483646),
                        bRand(-2147483646,2147483646,-1147483646,1147483646)
                    )
                    hrp.AssemblyAngularVelocity = Vector3.new(
                        bRand(-2147483646,2147483646,-1147483646,1147483646),
                        bRand(-2147483646,2147483646,-1147483646,1147483646),
                        bRand(-2147483646,2147483646,-1147483646,1147483646)
                    )
                end)
            end)
            RunService:BindToRenderStep("FractalXAR", Enum.RenderPriority.First.Value, function()
                if hrp and cc then
                    pcall(function()
                        hrp.CFrame                  = cc
                        hrp.AssemblyLinearVelocity  = cv
                        hrp.AssemblyAngularVelocity = ca
                    end)
                end
            end)
        end
        return Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)
    end
    return Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)
end

local function StopVoid()
    UI.VoidActive = false
    _xarActive = false
    if voidConn then voidConn:Disconnect() voidConn = nil end
    pcall(function() RunService:UnbindFromRenderStep("FractalXAR") end)
    voidX=0 voidZ=0 voidYOffset=0
    voidDirX=1 voidDirZ=0 voidYDir=1 elapsed=0
end

local function StartVoid()
    if UI.VoidActive then StopVoid() return end
    UI.VoidActive = true
    if CFG.VOID_METHOD ~= "Fractal XAR (BEST)" then
        voidConn = RunService.Heartbeat:Connect(function(dt)
            local pos = stepVoid(dt)
            local ch  = LocalPlayer.Character
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then pcall(function() hrp.CFrame = CFrame.new(pos) end) end
        end)
    else
        stepVoid(0)
    end
end

-- ════════════════════════════════════════════════════════════
--  DESTROY OLD GUI
-- ════════════════════════════════════════════════════════════
pcall(function() CoreGui:FindFirstChild("FracternalUI"):Destroy() end)
pcall(function()
    local h = gethui and gethui()
    if h then local o=h:FindFirstChild("FracternalUI") if o then o:Destroy() end end
end)

-- ════════════════════════════════════════════════════════════
--  SCREENGUI
-- ════════════════════════════════════════════════════════════
local SG = Instance.new("ScreenGui")
SG.Name           = "FracternalUI"
SG.ResetOnSpawn   = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder   = 999
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(SG) end
    SG.Parent = CoreGui
end)
if not SG.Parent then
    pcall(function() SG.Parent = gethui and gethui() or CoreGui end)
end

-- ════════════════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════════════════
local function Tw(obj, props, t, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.2, sty or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function Fmt(n)
    local a = math.abs(n)
    if a>=1e9 then return string.format("%.2fB",n/1e9)
    elseif a>=1e6 then return string.format("%.1fM",n/1e6)
    elseif a>=1e3 then return string.format("%.1fK",n/1e3)
    else return tostring(math.floor(n)) end
end

local function RF(parent, size, pos, bg, cr, name)
    local f=Instance.new("Frame")
    f.Name=name or "Frame" f.Size=size f.Position=pos
    f.BackgroundColor3=bg f.BorderSizePixel=0 f.Parent=parent
    local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,cr or 8) c.Parent=f
    return f
end

local function Lbl(parent, text, size, pos, col, font, ts, xa)
    local l=Instance.new("TextLabel")
    l.Text=text l.Size=size l.Position=pos
    l.BackgroundTransparency=1 l.TextColor3=col or UI.TextPri
    l.Font=font or UI.Font l.TextSize=ts or 13
    l.TextXAlignment=xa or Enum.TextXAlignment.Left
    l.RichText=true l.Parent=parent
    return l
end

local function Stroke(p, col, th)
    local s=Instance.new("UIStroke")
    s.Color=col or UI.Border s.Thickness=th or 1 s.Parent=p
    return s
end

local accentTargets = {} -- track all accent-colored objects for live recolor

local function TrackAccent(obj, prop)
    table.insert(accentTargets, {obj=obj, prop=prop or "BackgroundColor3"})
end

local function ApplyAccent(c)
    UI.AccentColor = c
    for _, t in ipairs(accentTargets) do
        pcall(function()
            if t.prop == "Color" then t.obj.Color = c
            elseif t.prop == "TextColor3" then t.obj.TextColor3 = c
            else t.obj.BackgroundColor3 = c end
        end)
    end
end

-- ════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ════════════════════════════════════════════════════════════
local NotifFrame = Instance.new("Frame")
NotifFrame.Size=UDim2.new(0,268,1,0) NotifFrame.Position=UDim2.new(1,-278,0,0)
NotifFrame.BackgroundTransparency=1 NotifFrame.Parent=SG

local notifN = 0
local function Notify(title, body, dur)
    dur = dur or 3.5
    notifN = notifN + 1
    local yBase = -(notifN * 70)
    local card = RF(NotifFrame, UDim2.new(1,0,0,62), UDim2.new(1.1,0,1,yBase-8), UI.MidBg, 9, "N")
    card.BackgroundTransparency = 1
    Stroke(card, UI.Border, 1)
    local bar = RF(card, UDim2.new(0,3,0,42), UDim2.new(0,0,0.5,-21), UI.AccentColor, 3, "Bar")
    TrackAccent(bar)
    Lbl(card, title, UDim2.new(1,-18,0,16), UDim2.new(0,13,0,7),  UI.TextPri, UI.Bold, 12)
    Lbl(card, body,  UDim2.new(1,-18,0,15), UDim2.new(0,13,0,25), UI.TextSec, UI.Font, 11)
    Tw(card, {BackgroundTransparency=0, Position=UDim2.new(0,0,1,yBase-8)}, 0.28, Enum.EasingStyle.Back)
    task.delay(dur, function()
        Tw(card, {BackgroundTransparency=1, Position=UDim2.new(1.1,0,1,yBase-8)}, 0.25)
        task.wait(0.3)
        pcall(function() card:Destroy() end)
        notifN = math.max(0, notifN-1)
    end)
end

-- ════════════════════════════════════════════════════════════
--  MINI HUD
-- ════════════════════════════════════════════════════════════
local HUD = RF(SG, UDim2.new(0,172,0,92), UDim2.new(1,-186,0,10), UI.MidBg, 10, "HUD")
HUD.BackgroundTransparency = 0.12
Stroke(HUD, UI.Border, 1)

local hudTop = RF(HUD, UDim2.new(1,0,0,2), UDim2.new(0,0,0,0), UI.AccentColor, 0, "HT")
TrackAccent(hudTop)

local hudTitleLbl = Lbl(HUD, "● POSITION", UDim2.new(1,-8,0,12), UDim2.new(0,7,0,6), UI.AccentColor, UI.Bold, 9)
TrackAccent(hudTitleLbl, "TextColor3")

local hudXL = Lbl(HUD, "X  —", UDim2.new(1,-8,0,13), UDim2.new(0,7,0,21), UI.TextSec, UI.Mono, 11)
local hudYL = Lbl(HUD, "Y  —", UDim2.new(1,-8,0,13), UDim2.new(0,7,0,36), UI.TextSec, UI.Mono, 11)
local hudZL = Lbl(HUD, "Z  —", UDim2.new(1,-8,0,13), UDim2.new(0,7,0,51), UI.TextSec, UI.Mono, 11)
Lbl(HUD, "fracternal v1  ·  fracternal.cc", UDim2.new(1,-4,0,12), UDim2.new(0,2,1,-16), UI.TextDim, UI.Font, 9, Enum.TextXAlignment.Center)

RunService.RenderStepped:Connect(function()
    local ch = LocalPlayer.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    if hrp then
        local p = hrp.Position
        hudXL.Text = string.format("X  %.1f", p.X)
        hudYL.Text = string.format("Y  %.1f", p.Y)
        hudZL.Text = string.format("Z  %.1f", p.Z)
    end
end)

-- ════════════════════════════════════════════════════════════
--  MAIN WINDOW
-- ════════════════════════════════════════════════════════════
local Main = RF(SG, UDim2.new(0,432,0,492), UDim2.new(0.5,-216,0.5,-246), UI.DarkBg, 12, "Main")
Main.ClipsDescendants = true
Stroke(Main, UI.Border, 1)

local mainGlow = Instance.new("Frame")
mainGlow.Name="TopGlow" mainGlow.Size=UDim2.new(1,0,0,2)
mainGlow.Position=UDim2.new(0,0,0,0) mainGlow.BackgroundColor3=UI.AccentColor
mainGlow.BorderSizePixel=0 mainGlow.ZIndex=10 mainGlow.Parent=Main
TrackAccent(mainGlow)

-- ════════════════════════════════════════════════════════════
--  TITLE BAR
-- ════════════════════════════════════════════════════════════
local TBar = RF(Main, UDim2.new(1,0,0,46), UDim2.new(0,0,0,0), UI.MidBg, 0, "TBar")

-- Logo mark
local logoMark = Instance.new("Frame")
logoMark.Size=UDim2.new(0,9,0,9) logoMark.Position=UDim2.new(0,15,0.5,-5)
logoMark.BackgroundColor3=UI.AccentColor logoMark.BorderSizePixel=0
logoMark.Rotation=45 logoMark.Parent=TBar
TrackAccent(logoMark)

Lbl(TBar, "FRACTERNAL", UDim2.new(0,145,1,0), UDim2.new(0,33,0,0), UI.TextPri, UI.Bold, 15)
Lbl(TBar, "v1", UDim2.new(0,20,0,14), UDim2.new(0,146,0,12), UI.AccentColor, UI.Font, 10)

-- Status pill
local pill = RF(TBar, UDim2.new(0,72,0,22), UDim2.new(1,-165,0.5,-11), UI.LightBg, 11, "Pill")
Stroke(pill, UI.Border, 1)
local pillDot = RF(pill, UDim2.new(0,6,0,6), UDim2.new(0,7,0.5,-3), Color3.fromRGB(95,95,110), 3, "Dot")
local pillTxt = Lbl(pill, "INACTIVE", UDim2.new(1,-22,1,0), UDim2.new(0,18,0,0), UI.TextSec, UI.Bold, 9)

-- Minimize button
local minF = RF(TBar, UDim2.new(0,28,0,28), UDim2.new(1,-78,0.5,-14), UI.LightBg, 7, "Min")
Stroke(minF, UI.Border, 1)
local minB = Instance.new("TextButton")
minB.Size=UDim2.new(1,0,1,0) minB.BackgroundTransparency=1
minB.Text="─" minB.TextColor3=UI.TextSec minB.Font=UI.Bold
minB.TextSize=12 minB.Parent=minF minB.AutoButtonColor=false
minF.MouseEnter:Connect(function() Tw(minF,{BackgroundColor3=Color3.fromRGB(36,36,48)},0.12) Tw(minF:FindFirstChildOfClass("UIStroke"),{Color=UI.AccentColor},0.12) end)
minF.MouseLeave:Connect(function() Tw(minF,{BackgroundColor3=UI.LightBg},0.12) Tw(minF:FindFirstChildOfClass("UIStroke"),{Color=UI.Border},0.12) end)
minB.MouseButton1Click:Connect(function()
    UI.UIVisible = false
    Tw(Main, {Size=UDim2.new(0,432,0,0), Position=Main.Position+UDim2.new(0,0,0,246)}, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.32)
    Main.Visible = false
    HUD.Visible  = false
end)

-- Close button
local clsF = RF(TBar, UDim2.new(0,28,0,28), UDim2.new(1,-42,0.5,-14), UI.LightBg, 7, "Cls")
Stroke(clsF, UI.Border, 1)
local clsB = Instance.new("TextButton")
clsB.Size=UDim2.new(1,0,1,0) clsB.BackgroundTransparency=1
clsB.Text="✕" clsB.TextColor3=UI.TextSec clsB.Font=UI.Bold
clsB.TextSize=11 clsB.Parent=clsF clsB.AutoButtonColor=false
clsF.MouseEnter:Connect(function() Tw(clsF,{BackgroundColor3=Color3.fromRGB(48,22,22)},0.12) Tw(clsF:FindFirstChildOfClass("UIStroke"),{Color=Color3.fromRGB(160,60,60)},0.12) end)
clsF.MouseLeave:Connect(function() Tw(clsF,{BackgroundColor3=UI.LightBg},0.12) Tw(clsF:FindFirstChildOfClass("UIStroke"),{Color=UI.Border},0.12) end)
clsB.MouseButton1Click:Connect(function()
    if UI.VoidActive then StopVoid() end
    Tw(Main, {BackgroundTransparency=1, Size=UDim2.new(0,432,0,0)}, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.wait(0.32)
    SG:Destroy()
end)

-- Title divider
local tdiv = Instance.new("Frame")
tdiv.Size=UDim2.new(1,0,0,1) tdiv.Position=UDim2.new(0,0,1,-1)
tdiv.BackgroundColor3=UI.Border tdiv.BorderSizePixel=0 tdiv.Parent=TBar

-- DRAG
do
    local drag, ds, sp = false, nil, nil
    TBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true ds=i.Position sp=Main.Position
        end
    end)
    TBar.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            Main.Position=UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

-- ════════════════════════════════════════════════════════════
--  TAB BAR
-- ════════════════════════════════════════════════════════════
local TabBar = RF(Main, UDim2.new(1,-18,0,30), UDim2.new(0,9,0,52), UI.MidBg, 7, "TabBar")
Stroke(TabBar, UI.Border, 1)

local tabLL = Instance.new("UIListLayout")
tabLL.FillDirection=Enum.FillDirection.Horizontal tabLL.Padding=UDim.new(0,3)
tabLL.VerticalAlignment=Enum.VerticalAlignment.Center tabLL.Parent=TabBar
local tabPP = Instance.new("UIPadding")
tabPP.PaddingLeft=UDim.new(0,3) tabPP.PaddingRight=UDim.new(0,3)
tabPP.PaddingTop=UDim.new(0,3) tabPP.PaddingBottom=UDim.new(0,3)
tabPP.Parent = TabBar

local tabInd = Instance.new("Frame")
tabInd.Name="Ind" tabInd.Size=UDim2.new(0,97,0,2)
tabInd.Position=UDim2.new(0,3,1,-3) tabInd.BackgroundColor3=UI.AccentColor
tabInd.BorderSizePixel=0 tabInd.ZIndex=5 tabInd.Parent=TabBar
TrackAccent(tabInd)
Instance.new("UICorner",tabInd).CornerRadius=UDim.new(1,0)

local tabBtns, tabPages = {}, {}

local function SwitchTab(name)
    UI.ActiveTab = name
    for n, b in pairs(tabBtns) do
        local on = (n==name)
        Tw(b, {TextColor3=on and UI.TextPri or UI.TextSec}, 0.15)
        Tw(b, {BackgroundTransparency=on and 0 or 1}, 0.15)
    end
    for n, f in pairs(tabPages) do f.Visible=(n==name) end
    Tw(tabInd, {Position=UDim2.new(0, name=="Void" and 3 or 104, 1, -3)}, 0.2)
end

local function MkTab(name)
    local b = Instance.new("TextButton")
    b.Name="TB_"..name b.Size=UDim2.new(0,97,1,0)
    b.BackgroundColor3=UI.AccentColor:Lerp(UI.LightBg,0.85)
    b.BackgroundTransparency=1 b.BorderSizePixel=0
    b.Text=name:upper() b.TextColor3=UI.TextSec
    b.Font=UI.Bold b.TextSize=11 b.AutoButtonColor=false
    b.Parent=TabBar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    b.MouseButton1Click:Connect(function() SwitchTab(name) end)
    tabBtns[name] = b
end

MkTab("Void")
MkTab("Settings")

-- ════════════════════════════════════════════════════════════
--  CONTENT AREA
-- ════════════════════════════════════════════════════════════
local CA = Instance.new("Frame")
CA.Name="CA" CA.Size=UDim2.new(1,-16,1,-96)
CA.Position=UDim2.new(0,8,0,88) CA.BackgroundTransparency=1
CA.ClipsDescendants=true CA.Parent=Main

local function MkPage(name)
    local f=Instance.new("Frame")
    f.Name=name f.Size=UDim2.new(1,0,1,0)
    f.BackgroundTransparency=1 f.Visible=false f.Parent=CA
    tabPages[name]=f
    return f
end

-- Scrolling content helper
local function MkScroll(parent)
    local s=Instance.new("ScrollingFrame")
    s.Size=UDim2.new(1,0,1,0) s.BackgroundTransparency=1
    s.BorderSizePixel=0 s.ScrollBarThickness=3
    s.ScrollBarImageColor3=UI.Border s.CanvasSize=UDim2.new(0,0,0,400)
    s.Parent=parent
    local ll=Instance.new("UIListLayout")
    ll.Padding=UDim.new(0,8) ll.Parent=s
    local pad=Instance.new("UIPadding")
    pad.PaddingTop=UDim.new(0,3) pad.PaddingLeft=UDim.new(0,1) pad.PaddingRight=UDim.new(0,1)
    pad.Parent=s
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        s.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+16)
    end)
    return s
end

-- Card helper
local function Card(scroll, h, name)
    local c=RF(scroll, UDim2.new(1,0,0,h), UDim2.new(0,0,0,0), UI.SurfBg, 9, name or "Card")
    Stroke(c, UI.Border, 1)
    return c
end

-- Section micro-label
local function SecLbl(parent, text, x, y)
    return Lbl(parent, text:upper(), UDim2.new(0,200,0,12), UDim2.new(0,x or 10,0,y or 6), UI.TextDim, UI.Bold, 9)
end

-- ════════════════════════════════════════════════════════════
--  ▶ VOID TAB
-- ════════════════════════════════════════════════════════════
local VoidPage = MkPage("Void")
local vScroll  = MkScroll(VoidPage)

-- ─── Activate ────────────────────────────────────────────
local actCard = Card(vScroll, 50, "Activate")

local actBtn = Instance.new("TextButton")
actBtn.Size = UDim2.new(1,-16,0,34)
actBtn.Position = UDim2.new(0,8,0,8)
actBtn.BackgroundColor3 = UI.LightBg
actBtn.BorderSizePixel = 0
actBtn.Text = "▶   ACTIVATE VOID"
actBtn.TextColor3 = UI.TextPri
actBtn.Font = UI.Bold
actBtn.TextSize = 13
actBtn.AutoButtonColor = false
actBtn.Parent = actCard

Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0,7)
local actStroke = Stroke(actBtn, UI.Border, 1)

local function RefreshActivateBtn()
    if UI.VoidActive then
        Tw(actBtn,{BackgroundColor3=Color3.fromRGB(38,18,18)},0.2)
        Tw(actStroke,{Color=Color3.fromRGB(150,50,50)},0.2)
        actBtn.Text = "■   DEACTIVATE VOID"

        Tw(pillDot,{BackgroundColor3=Color3.fromRGB(72,210,110)},0.2)
        Tw(pillTxt,{TextColor3=Color3.fromRGB(72,210,110)},0.2)
        pillTxt.Text = "ACTIVE"
    else
        Tw(actBtn,{BackgroundColor3=UI.LightBg},0.2)
        Tw(actStroke,{Color=UI.Border},0.2)
        actBtn.Text = "▶   ACTIVATE VOID"

        Tw(pillDot,{BackgroundColor3=Color3.fromRGB(95,95,110)},0.2)
        Tw(pillTxt,{TextColor3=UI.TextSec},0.2)
        pillTxt.Text = "INACTIVE"
    end
end

actBtn.MouseEnter:Connect(function()
    Tw(actBtn,{
        BackgroundColor3 = UI.VoidActive
            and Color3.fromRGB(50,22,22)
            or Color3.fromRGB(36,36,52)
    },0.12)
end)

actBtn.MouseLeave:Connect(function()
    Tw(actBtn,{
        BackgroundColor3 = UI.VoidActive
            and Color3.fromRGB(38,18,18)
            or UI.LightBg
    },0.12)
end)

actBtn.MouseButton1Click:Connect(function()
    if UI.VoidActive then
        StopVoid()
        Notify("Void", "Void deactivated.", 2.5)
    else
        StartVoid()
        Notify("Void", "Void activated — "..CFG.VOID_METHOD, 3)
    end

    RefreshActivateBtn()
end)

-- ─── Void Keybind ────────────────────────────────────────
local kbCard = Card(vScroll, 50, "VoidKB")
SecLbl(kbCard, "Void Keybind", 10, 6)

local kbFrame = RF(kbCard, UDim2.new(0,140,0,28), UDim2.new(1,-150,0.5,-14), UI.LightBg, 7, "KBF")
Stroke(kbFrame, UI.Border, 1)
local kbLbl = Lbl(kbFrame, "[ "..UI.VoidKeybind.Name.." ]", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), UI.TextPri, UI.Mono, 12, Enum.TextXAlignment.Center)

local kbBtn = Instance.new("TextButton")
kbBtn.Size=UDim2.new(1,0,1,0) kbBtn.BackgroundTransparency=1 kbBtn.Text="" kbBtn.Parent=kbFrame
kbFrame.MouseEnter:Connect(function() Tw(kbFrame,{BackgroundColor3=Color3.fromRGB(34,34,48)},0.1) Tw(kbFrame:FindFirstChildOfClass("UIStroke"),{Color=UI.AccentColor},0.1) end)
kbFrame.MouseLeave:Connect(function() Tw(kbFrame,{BackgroundColor3=UI.LightBg},0.1) Tw(kbFrame:FindFirstChildOfClass("UIStroke"),{Color=UI.Border},0.1) end)
kbBtn.MouseButton1Click:Connect(function()
    if capturingVoidKB then return end
    capturingVoidKB = true
    kbLbl.Text = "[ PRESS KEY... ]"
    Notify("Keybind", "Press any key to bind Void.", 2)
    local c; c=UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            UI.VoidKeybind=inp.KeyCode
            kbLbl.Text="[ "..inp.KeyCode.Name.." ]"
            capturingVoidKB=false
            Notify("Keybind", "Void → "..inp.KeyCode.Name, 2.5)
            c:Disconnect()
        end
    end)
end)

-- ─── Void Method Dropdown ────────────────────────────────
local METHODS = {
    "Stable",
    "Fracternal Desync",
    "Drift",
    "Chaotic",
    "Eclipse Singularity",
    "Fractal XAR (BEST)",
}

local ddCard = Card(vScroll, 56, "Method")
SecLbl(ddCard, "Void Method", 10, 6)

local ddOuter = RF(ddCard, UDim2.new(1,-16,0,30), UDim2.new(0,8,0,20), UI.LightBg, 7, "DD")
Stroke(ddOuter, UI.Border, 1)
local ddValLbl  = Lbl(ddOuter, CFG.VOID_METHOD, UDim2.new(1,-34,1,0), UDim2.new(0,10,0,0), UI.TextPri, UI.Font, 12)
local ddArrowL  = Lbl(ddOuter, "▾", UDim2.new(0,20,1,0), UDim2.new(1,-26,0,0), UI.TextSec, UI.Bold, 14, Enum.TextXAlignment.Center)
local ddClickB  = Instance.new("TextButton")
ddClickB.Size=UDim2.new(1,0,1,0) ddClickB.BackgroundTransparency=1 ddClickB.Text="" ddClickB.Parent=ddOuter

local ddList, ddOpen = nil, false
ddOuter.MouseEnter:Connect(function() Tw(ddOuter,{BackgroundColor3=Color3.fromRGB(34,34,48)},0.1) Tw(ddOuter:FindFirstChildOfClass("UIStroke"),{Color=UI.AccentColor},0.1) end)
ddOuter.MouseLeave:Connect(function() Tw(ddOuter,{BackgroundColor3=UI.LightBg},0.1) Tw(ddOuter:FindFirstChildOfClass("UIStroke"),{Color=UI.Border},0.1) end)

ddClickB.MouseButton1Click:Connect(function()
    ddOpen = not ddOpen
    if ddOpen then
        ddArrowL.Text = "▴"
        local listH = #METHODS * 28 + 8
        ddList = RF(Main, UDim2.new(0,ddOuter.AbsoluteSize.X,0,listH), UDim2.new(0,0,0,0), UI.MidBg, 8, "DDList")
        ddList.ZIndex=60
        Stroke(ddList, UI.Border, 1)
        local ap = ddOuter.AbsolutePosition - Main.AbsolutePosition
        ddList.Position = UDim2.new(0, ap.X + 8, 0, ap.Y + ddOuter.AbsoluteSize.Y + 3)
        for i, mname in ipairs(METHODS) do
            local isBest = mname:find("BEST") ~= nil
            local opt = Instance.new("TextButton")
            opt.Size=UDim2.new(1,-8,0,26) opt.Position=UDim2.new(0,4,0,(i-1)*28+4)
            opt.BackgroundColor3=UI.MidBg opt.BackgroundTransparency=1
            opt.BorderSizePixel=0
            opt.Text=mname opt.TextColor3=(mname==CFG.VOID_METHOD) and UI.AccentColor or UI.TextSec
            opt.Font=(isBest) and UI.Bold or UI.Font
            opt.TextSize=12 opt.TextXAlignment=Enum.TextXAlignment.Left
            opt.ZIndex=61 opt.AutoButtonColor=false opt.Parent=ddList
            Instance.new("UICorner",opt).CornerRadius=UDim.new(0,5)
            local pp=Instance.new("UIPadding") pp.PaddingLeft=UDim.new(0,10) pp.Parent=opt
            opt.MouseEnter:Connect(function() Tw(opt,{BackgroundTransparency=0,BackgroundColor3=UI.LightBg},0.08) end)
            opt.MouseLeave:Connect(function() Tw(opt,{BackgroundTransparency=1},0.08) end)
            opt.MouseButton1Click:Connect(function()
                CFG.VOID_METHOD = mname
                ddValLbl.Text   = mname
                ddArrowL.Text   = "▾"
                ddOpen          = false
                if ddList then ddList:Destroy() ddList=nil end
                Notify("Method", "Method → "..mname, 2.5)
            end)
        end
    else
        ddArrowL.Text = "▾"
        if ddList then ddList:Destroy() ddList=nil end
    end
end)

-- ─── Slider factory ──────────────────────────────────────
local function MkSlider(parent, label, minV, maxV, defV, onCh)
    local c = Card(parent, 60, "Slider_"..label)
    SecLbl(c, label, 10, 6)
    local valL = Lbl(c, Fmt(defV), UDim2.new(0,80,0,12), UDim2.new(1,-92,0,6), UI.AccentColor, UI.Mono, 11, Enum.TextXAlignment.Right)
    TrackAccent(valL, "TextColor3")

    local track = RF(c, UDim2.new(1,-16,0,4), UDim2.new(0,8,0,34), UI.LightBg, 2, "Track")
    Stroke(track, UI.Border, 1)
    local fill  = RF(track, UDim2.new((defV-minV)/(maxV-minV),0,1,0), UDim2.new(0,0,0,0), UI.AccentColor, 2, "Fill")
    TrackAccent(fill)
    local thumb = RF(track, UDim2.new(0,12,0,12), UDim2.new((defV-minV)/(maxV-minV),0,0.5,-6), UI.TextPri, 6, "Thumb")
    local tStroke = Stroke(thumb, UI.AccentColor, 1)
    TrackAccent(tStroke, "Color")

    local dragging = false
    local tBtn = Instance.new("TextButton")
    tBtn.Size=UDim2.new(1,0,1,0) tBtn.BackgroundTransparency=1 tBtn.Text="" tBtn.Parent=track
    tBtn.MouseButton1Down:Connect(function() dragging=true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    local function set()
        local a = math.clamp((UserInputService:GetMouseLocation().X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + a*(maxV-minV))
        fill.Size = UDim2.new(a,0,1,0)
        thumb.Position = UDim2.new(a,-6,0.5,-6)
        valL.Text = Fmt(v)
        if onCh then onCh(v) end
    end
    tBtn.MouseButton1Down:Connect(set)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then set() end
    end)
    return c
end

MkSlider(vScroll, "Max Coords", 0, 2100000000, CFG.MAX_COORDS, function(v) CFG.MAX_COORDS=v end)
MkSlider(vScroll, "Min Coords", 0, 2100000000, CFG.MIN_COORDS, function(v) CFG.MIN_COORDS=v end)

-- ════════════════════════════════════════════════════════════
--  ▶ SETTINGS TAB
-- ════════════════════════════════════════════════════════════
local SettingsPage = MkPage("Settings")
local sScroll = MkScroll(SettingsPage)

-- ─── Hide UI Keybind ─────────────────────────────────────
local hkCard = Card(sScroll, 50, "HideKB")
SecLbl(hkCard, "Hide UI Keybind", 10, 6)

local hkFrame = RF(hkCard, UDim2.new(0,140,0,28), UDim2.new(1,-150,0.5,-14), UI.LightBg, 7, "HKF")
Stroke(hkFrame, UI.Border, 1)
local hkLbl = Lbl(hkFrame, "[ "..UI.HideKeybind.Name.." ]", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), UI.TextPri, UI.Mono, 12, Enum.TextXAlignment.Center)
local hkBtn = Instance.new("TextButton")
hkBtn.Size=UDim2.new(1,0,1,0) hkBtn.BackgroundTransparency=1 hkBtn.Text="" hkBtn.Parent=hkFrame
hkFrame.MouseEnter:Connect(function() Tw(hkFrame,{BackgroundColor3=Color3.fromRGB(34,34,48)},0.1) Tw(hkFrame:FindFirstChildOfClass("UIStroke"),{Color=UI.AccentColor},0.1) end)
hkFrame.MouseLeave:Connect(function() Tw(hkFrame,{BackgroundColor3=UI.LightBg},0.1) Tw(hkFrame:FindFirstChildOfClass("UIStroke"),{Color=UI.Border},0.1) end)
hkBtn.MouseButton1Click:Connect(function()
    if capturingHideKB then return end
    capturingHideKB = true
    hkLbl.Text = "[ PRESS KEY... ]"
    Notify("Keybind", "Press any key to bind Hide UI.", 2)
    local c; c=UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            UI.HideKeybind=inp.KeyCode
            hkLbl.Text="[ "..inp.KeyCode.Name.." ]"
            capturingHideKB=false
            Notify("Keybind", "Hide UI → "..inp.KeyCode.Name, 2.5)
            c:Disconnect()
        end
    end)
end)

-- ─── Color Customizer ────────────────────────────────────
local colorCard = Card(sScroll, 195, "Color")
SecLbl(colorCard, "Accent Color", 10, 8)

-- Preview swatch
local prevSwatch = RF(colorCard, UDim2.new(0,34,0,34), UDim2.new(1,-48,0,22), UI.AccentColor, 8, "Swatch")
Stroke(prevSwatch, UI.Border, 1)
TrackAccent(prevSwatch)

local rV = math.floor(UI.AccentColor.R*255)
local gV = math.floor(UI.AccentColor.G*255)
local bV = math.floor(UI.AccentColor.B*255)

local function MkChanSlider(parent, ch, yOff, init, onCh)
    local bg = RF(parent, UDim2.new(1,-16,0,22), UDim2.new(0,8,0,yOff), UI.LightBg, 5, ch)
    Stroke(bg, UI.Border, 1)
    Lbl(bg, ch, UDim2.new(0,14,1,0), UDim2.new(0,7,0,0), UI.TextSec, UI.Bold, 9)
    local vl = Lbl(bg, tostring(init), UDim2.new(0,28,1,0), UDim2.new(1,-36,0,0), UI.TextSec, UI.Mono, 10, Enum.TextXAlignment.Right)
    local tr = RF(bg, UDim2.new(1,-52,0,3), UDim2.new(0,22,0.5,-1.5), UI.MidBg, 2, "Tr")
    local fi = RF(tr, UDim2.new(init/255,0,1,0), UDim2.new(0,0,0,0), UI.AccentColor, 2, "Fi")
    TrackAccent(fi)
    local th = RF(tr, UDim2.new(0,9,0,9), UDim2.new(init/255,0,0.5,-4.5), UI.TextPri, 5, "Th")
    local ts = Stroke(th, UI.AccentColor, 1)
    TrackAccent(ts, "Color")
    local drag=false
    local tb=Instance.new("TextButton") tb.Size=UDim2.new(1,0,1,0) tb.BackgroundTransparency=1 tb.Text="" tb.Parent=tr
    tb.MouseButton1Down:Connect(function() drag=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    local function upd()
        local a=math.clamp((UserInputService:GetMouseLocation().X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        local v=math.floor(a*255)
        fi.Size=UDim2.new(a,0,1,0) th.Position=UDim2.new(a,-4.5,0.5,-4.5) vl.Text=tostring(v)
        if onCh then onCh(v) end
    end
    tb.MouseButton1Down:Connect(upd)
    UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd() end end)
end

MkChanSlider(colorCard, "R", 38,  rV, function(v) rV=v ApplyAccent(Color3.fromRGB(rV,gV,bV)) end)
MkChanSlider(colorCard, "G", 66,  gV, function(v) gV=v ApplyAccent(Color3.fromRGB(rV,gV,bV)) end)
MkChanSlider(colorCard, "B", 94,  bV, function(v) bV=v ApplyAccent(Color3.fromRGB(rV,gV,bV)) end)

-- Presets
local PRESETS = {
    {148,148,172,"Default"},
    {72, 155,255,"Blue"},
    {72, 215,135,"Teal"},
    {215,72, 115,"Red"},
    {210,150,50, "Gold"},
    {155,75, 240,"Purple"},
}
Lbl(colorCard, "PRESETS", UDim2.new(1,0,0,12), UDim2.new(0,10,0,124), UI.TextDim, UI.Bold, 9)
for i, p in ipairs(PRESETS) do
    local px = 8 + (i-1)*66
    local dot = RF(colorCard, UDim2.new(0,56,0,22), UDim2.new(0,px,0,140), Color3.fromRGB(p[1],p[2],p[3]), 6, "P"..i)
    Stroke(dot, UI.Border, 1)
    local db=Instance.new("TextButton") db.Size=UDim2.new(1,0,1,0) db.BackgroundTransparency=1
    db.Text=p[4] db.TextColor3=Color3.fromRGB(255,255,255) db.Font=UI.Bold db.TextSize=8 db.Parent=dot
    local pr, pg, pb = p[1], p[2], p[3]
    db.MouseButton1Click:Connect(function()
        rV=pr gV=pg bV=pb
        ApplyAccent(Color3.fromRGB(rV,gV,bV))
        Notify("Color", "Accent → "..p[4], 2)
    end)
end

-- ─── About card ──────────────────────────────────────────
local aboutCard = Card(sScroll, 46, "About")
Lbl(aboutCard, "fracternal", UDim2.new(1,-16,0,16), UDim2.new(0,12,0,7), UI.TextPri, UI.Bold, 14)
Lbl(aboutCard, "v1  ·  fracternal.cc", UDim2.new(1,-16,0,14), UDim2.new(0,12,0,24), UI.TextSec, UI.Mono, 11)

-- ════════════════════════════════════════════════════════════
--  GLOBAL KEYBIND HANDLER
-- ════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if capturingVoidKB or capturingHideKB then return end

    if input.KeyCode == UI.HideKeybind then
        -- INSTANT — no tween
        UI.UIVisible = not UI.UIVisible
        Main.Visible = UI.UIVisible
        HUD.Visible  = UI.UIVisible
        return
    end

    if input.KeyCode == UI.VoidKeybind then
        if UI.VoidActive then
            StopVoid()
            Notify("Void", "Void deactivated.", 2.5)
        else
            originalPosition = hrp.CFrame
            StartVoid()
            Notify("Void", "Void activated  —  "..CFG.VOID_METHOD, 3)
        end
        RefreshActivateBtn()
    end
end)

-- ════════════════════════════════════════════════════════════
--  BOOT
-- ════════════════════════════════════════════════════════════
SwitchTab("Void")

-- Entrance animation
local origPos = Main.Position
Main.Size     = UDim2.new(0,432,0,0)
Main.Position = origPos + UDim2.new(0,0,0,246)
Main.BackgroundTransparency = 1
task.wait(0.05)
Tw(Main, {
    Size     = UDim2.new(0,432,0,492),
    Position = origPos,
    BackgroundTransparency = 0,
}, 0.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

task.wait(0.6)
Notify("fracternal", "Loaded successfully  ·  fracternal.cc", 4)

--[[
    ════════════════════════════════════════
    fracternal v1 | fracternal.cc
    ════════════════════════════════════════
]]
