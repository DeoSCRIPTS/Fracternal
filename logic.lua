-- Enhanced Mobile Support with Touch Optimizations
-- Framework: LinoriaLib with Mobile Configurations

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Mobile Detection
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local MobileScale = IsMobile and 1.3 or 1.0 -- Scale up UI for mobile

-- Math utility functions
local function clamp(x, min, max)
    if x < min then return min end
    if x > max then return max end
    return x
end

-- [Dependencies] - ULTRA ASYNC LOADING to prevent freeze
local Library, ThemeManager, SaveManager
local LoadStatus = "Loading Libraries..."
local LibrariesLoaded = false
local scriptStartTime = tick()

-- Performance optimization: Create loading notification asynchronously
task.spawn(function()
    -- Wait for game to fully load before starting
    task.wait(3) -- Increased initial delay
    
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "Fracternalv1Loading"
    loadingGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 300, 0, 60)
    loadingFrame.Position = UDim2.new(0.5, -150, 0.9, -30)
    loadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    loadingFrame.BorderSizePixel = 0
    loadingFrame.Parent = loadingGui
    
    local loadingCorner = Instance.new("UICorner")
    loadingCorner.CornerRadius = UDim.new(0, 8)
    loadingCorner.Parent = loadingFrame
    
    local loadingLabel = Instance.new("TextLabel")
    loadingLabel.Size = UDim2.new(1, -20, 1, -20)
    loadingLabel.Position = UDim2.new(0, 10, 0, 10)
    loadingLabel.BackgroundTransparency = 1
    loadingLabel.Text = "Loading Fracternal v1..."
    loadingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingLabel.TextScaled = true
    loadingLabel.Font = Enum.Font.SourceSansBold
    loadingLabel.Parent = loadingFrame
    
    -- Load libraries with timeout and error handling
    local success, err = pcall(function()
        Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeoSCRIPTS/LinoraHubCopy/refs/heads/main/Library.lua'))()
        task.wait(0.5) -- Increased delay to prevent blocking
        ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeoSCRIPTS/LinoraHubCopy/refs/heads/main/ThemeManager.lua'))()
        task.wait(0.5) -- Increased delay to prevent blocking
        SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/DeoSCRIPTS/LinoraHubCopy/refs/heads/main/SaveManager.lua'))()
        task.wait(0.5) -- Increased delay to prevent blocking
    end)
    
    if success then
        LibrariesLoaded = true
        LoadStatus = "Libraries Loaded"
        loadingLabel.Text = "Initializing UI..."
        task.wait(0.5)
        loadingGui:Destroy()
    else
        loadingLabel.Text = "Load Failed: " .. tostring(err)
        task.wait(2)
        loadingGui:Destroy()
    end
end)

-- [Configuration]
getgenv().CFG = {
    -- Orbit Aura
    ORBIT_ENABLED = false,
    ORBIT_SPEED = 5,
    ORBIT_MODE = "Default",
    ORBIT_STABILITY = 1,
    ORBIT_JITTER = 0,
    HEIGHT_OFFSET = 50000,
    ELLIPSE_RATIO = 0.65,
    VERTICAL_WAVE_SPEED = 0.8,
    VERTICAL_WAVE_AMP = 0.12,
    MIN_RADIUS = 200000,
    MAX_RADIUS = 12000000000,
    ORBIT_EVASION_STRENGTH = 0,
    ORBIT_EVASION_SPEED = 0,
    
    -- Void System
    VOID_ENABLED = false,
    VOID_METHOD = "Drift",
    VOID_BYPASS_MODE = "None",
    VOID_DRIFT_SPEED = 9e6,
    VOID_DRIFT_CHAOS = 0.98,
    VOID_Y_BASE = 1e10 + math.random(-5e9, 5e9) + 7369123,
    VOID_Y_DRIFT_SPEED = 4e6,
    VOID_Y_DRIFT_RANGE = 2e9,
    VOID_SCRAMBLE_ENABLED = true,
    VOID_SCRAMBLE_TIME = 1.2,
    VOID_SCRAMBLE_RADIUS = 8e10,
    VOID_ANCHOR_CHECK = 0.016,
    VOID_ANCHOR_THRESH = 50,
    VOID_EVADE_ENABLED = true,
    VOID_EVADE_RADIUS = 8e9,
    VOID_EVADE_SPEED = 6e9,
    VOID_EVADE_COOLDOWN = 0.05,
    VOID_EVADE_VERT_SPEED = 3e9,
    VOID_EVADE_VERT_BIAS = 0.5,
    VOID_EVADE_FORCE_UP = false,
    VOID_LISSAJOUS_A = 2,
    VOID_LISSAJOUS_B = 3,
    VOID_FLICKER_INT = 0.05,
    VOID_GRAVITY_STR = 1e8,
    VOID_GHOSTING_ENABLED = false,
    VOID_GHOSTING_INTENSITY = 0.5,
    
    -- Targeting
    LOCK_FOV = 120,
    LOCK_SMOOTH = 0.72,
    LOCK_SMOOTH_ALPHA = 0.15,
    KILL_HP = 0,
    PREDICTION = 0.22,
    ACCEL_SMOOTH = 0.55,
    ACCEL_WEIGHT = 0.04,
    CAM_LERP_BASE = 0.12,
    AUTO_LOCK = false,
    AUTO_LOCK_RADIUS = 200,
    
    -- Combat / Resolver
    RESOLVER_ENABLED = false,
    RESOLVER_METHOD = "Predictive",
    RESOLVER_OFFSET = 3,
    RESOLVER_ADAPTIVE_SENS = 0.1,
    RESOLVER_MULTI_POINT = true,
    RESOLVER_HISTORY_SIZE = 10,
    
    -- Anti-Orbit (Defensive)
    ANTI_ORBIT_ENABLED = false,
    ANTI_ORBIT_METHOD = "None",
    ANTI_ORBIT_INTENSITY = 10,
    ANTI_ORBIT_RADIUS = 25,
    ANTI_ORBIT_SPEED = 15,
    
    -- Projectile TP
    PROJECTILE_TP_ENABLED = false,
    PROJECTILE_TP_METHOD = "None",
    PROJECTILE_TP_CHANCE = 100,
    PROJECTILE_TP_PART = "Head",

    -- Critical TP
    CRITICAL_TP_ENABLED = false,
    CRITICAL_TP_METHOD = "None",
    CRITICAL_TP_CHANCE = 100,
    CRITICAL_TP_DELAY = 0.05,
    
    -- Anti-Aim
    AA_ENABLED = false,
    AA_METHOD = "None",
    AA_SPEED = 20,
    AA_JITTER_RANGE = 180,
    AA_LBY_INTERVAL = 0.1,
    AA_SWAY_SPEED = 5,
    AA_DESYNC_INTENSITY = 0.5,
    AA_NETWORK_STUTTER = false,
    
    -- Void / Desync
    DESYNC_ENABLED = true,
    DESYNC_TICK_RATE = 0.18,
    DESYNC_SPOOF_Y = 3,
    DESYNC_SPOOF_RADIUS = 22,
    DESYNC_WANDER_SPEED = 3.5,
    DESYNC_WANDER_CHAOS = 0.4,
    
    -- Physics
    PHYSICS_S2_SENDER = true,
    PHYSICS_TPS = 120,
    PHYSICS_NETWORK_OWNER = true,
    PHYSICS_ALLOW_SLEEP = false,
    PHYSICS_THROTTLE = "Disabled",
    PHYSICS_STEPPING = "Default",
    PHYSICS_SIM_RATE = 120,
    PHYSICS_INTERP_THROTTLE = false,
    PHYSICS_NET_OWNER_V2 = false,
    PHYSICS_EXTREME_NET = false,
    PHYSICS_LATENCY_PATCH = false,
    PHYSICS_QUANTUM_SYNC = false,
    PHYSICS_JOB_LIMIT = 0,
    PHYSICS_REPLICATION_MODE = "Default",
    PHYSICS_FREQ_OSCILLATOR = 1000,
    
    -- Visuals
    SKY_NAME = "Default",
    VIBRANT_MAP = false,
    HIT_NOTIFIER_ENABLED = true,
    HIT_NOTIFIER_COLOR = Color3.fromRGB(160, 32, 240),
    HIT_NOTIFIER_SOUND = true,
    TRACERS_ENABLED = false,
    TRACERS_COLOR = Color3.fromRGB(160, 32, 240),
    TRACERS_DURATION = 1,
    
    -- Misc
    FFA_AUTO_KILL = false,
    FFA_AUTO_RESPAWN = true,
    WALLBANG_ENABLED = false,
    WALLBANG_MAX_DIST = 5,
    
    -- Mobile Settings
    MOBILE_SCALE = MobileScale,
    MOBILE_ENABLED = IsMobile,
    MOBILE_BUTTON_SIZE = IsMobile and 44 or 32,
    MOBILE_FONT_SIZE = IsMobile and 16 or 14,
    MOBILE_TOUCH_PADDING = IsMobile and 8 or 4,
    MOBILE_TOGGLE_SIZE = IsMobile and 60 or 40,
}

-- [Data Tables]
local skyPresets = { 
    ['Default'] = {}, 
    ['Deep Space'] = {SkyboxBk = 'rbxassetid://159454296', SkyboxDn = 'rbxassetid://159454296', SkyboxFt = 'rbxassetid://159454296', SkyboxLf = 'rbxassetid://159454296', SkyboxRt = 'rbxassetid://159454296', SkyboxUp = 'rbxassetid://159454296'}, 
    ['Realistic Starfield'] = {SkyboxBk = 'rbxassetid://159454299', SkyboxDn = 'rbxassetid://159454299', SkyboxFt = 'rbxassetid://159454299', SkyboxLf = 'rbxassetid://159454299', SkyboxRt = 'rbxassetid://159454299', SkyboxUp = 'rbxassetid://159454299'}, 
    ['Milky Way'] = {SkyboxBk = 'rbxassetid://159454236', SkyboxDn = 'rbxassetid://159454236', SkyboxFt = 'rbxassetid://159454236', SkyboxLf = 'rbxassetid://159454236', SkyboxRt = 'rbxassetid://159454236', SkyboxUp = 'rbxassetid://159454236'}, 
    ['Ethereal Galaxy'] = {SkyboxBk = 'rbxassetid://159454230', SkyboxDn = 'rbxassetid://159454230', SkyboxFt = 'rbxassetid://159454230', SkyboxLf = 'rbxassetid://159454230', SkyboxRt = 'rbxassetid://159454230', SkyboxUp = 'rbxassetid://159454230'}, 
    ['Night City'] = {SkyboxBk = 'rbxassetid://159454289', SkyboxDn = 'rbxassetid://159454289', SkyboxFt = 'rbxassetid://159454289', SkyboxLf = 'rbxassetid://159454289', SkyboxRt = 'rbxassetid://159454289', SkyboxUp = 'rbxassetid://159454289'},
    ['Cyberpunk'] = {SkyboxBk = 'rbxassetid://159454275', SkyboxDn = 'rbxassetid://159454275', SkyboxFt = 'rbxassetid://159454275', SkyboxLf = 'rbxassetid://159454275', SkyboxRt = 'rbxassetid://159454275', SkyboxUp = 'rbxassetid://159454275'},
    ['Cosmic Abyss'] = {SkyboxBk = 'rbxassetid://159454245', SkyboxDn = 'rbxassetid://159454245', SkyboxFt = 'rbxassetid://159454245', SkyboxLf = 'rbxassetid://159454245', SkyboxRt = 'rbxassetid://159454245', SkyboxUp = 'rbxassetid://159454245'},
    ['Void Realm'] = {SkyboxBk = 'rbxassetid://159454242', SkyboxDn = 'rbxassetid://159454242', SkyboxFt = 'rbxassetid://159454242', SkyboxLf = 'rbxassetid://159454242', SkyboxRt = 'rbxassetid://159454242', SkyboxUp = 'rbxassetid://159454242'},
    ['Starry Horizon'] = {SkyboxBk = 'rbxassetid://12064573', SkyboxDn = 'rbxassetid://12064573', SkyboxFt = 'rbxassetid://12064573', SkyboxLf = 'rbxassetid://12064573', SkyboxRt = 'rbxassetid://12064573', SkyboxUp = 'rbxassetid://12064573'},
    ['Nebula Storm'] = {SkyboxBk = 'rbxassetid://159454282', SkyboxDn = 'rbxassetid://159454282', SkyboxFt = 'rbxassetid://159454282', SkyboxLf = 'rbxassetid://159454282', SkyboxRt = 'rbxassetid://159454282', SkyboxUp = 'rbxassetid://159454282'},
    ['Dark Clouds'] = {SkyboxBk = 'rbxassetid://159454242', SkyboxDn = 'rbxassetid://159454242', SkyboxFt = 'rbxassetid://159454242', SkyboxLf = 'rbxassetid://159454242', SkyboxRt = 'rbxassetid://159454242', SkyboxUp = 'rbxassetid://159454242'},
    ['Galactic Core'] = {SkyboxBk = 'rbxassetid://159454233', SkyboxDn = 'rbxassetid://159454233', SkyboxFt = 'rbxassetid://159454233', SkyboxLf = 'rbxassetid://159454233', SkyboxRt = 'rbxassetid://159454233', SkyboxUp = 'rbxassetid://159454233'},
    ['Nebula Violet'] = {SkyboxBk = 'rbxassetid://159454251', SkyboxDn = 'rbxassetid://159454251', SkyboxFt = 'rbxassetid://159454251', SkyboxLf = 'rbxassetid://159454251', SkyboxRt = 'rbxassetid://159454251', SkyboxUp = 'rbxassetid://159454251'},
    ['Aether Drift'] = {SkyboxBk = 'rbxassetid://159454230', SkyboxDn = 'rbxassetid://159454230', SkyboxFt = 'rbxassetid://159454230', SkyboxLf = 'rbxassetid://159454230', SkyboxRt = 'rbxassetid://159454230', SkyboxUp = 'rbxassetid://159454230'},
} 
local skyNames = {}
for k in pairs(skyPresets) do table.insert(skyNames, k) end
table.sort(skyNames)

local crosshairNames = {"Heart", "Star", "Pulse", "Radar", "Scope", "Spinning Cross", "Wave", "Spiral", "Target", "Neon", "Tech"} 

local SoundPresets = {  
    ['Rust']   = 'rbxassetid://4764109000',  
    ['Silenced']         = 'rbxassetid://9125402735',  
    ['deep dark twink']     = 'rbxassetid://6042053626',  
    ['Laser']            = 'rbxassetid://3047508632',  
    ['Classic Pop']      = 'rbxassetid://131070686',  
    ['Shotgun Blast']    = 'rbxassetid://2697612040',  
    ['surfer']       = 'rbxassetid://2865227271',  
}  
local soundPresetNames = {}  
for k in pairs(SoundPresets) do table.insert(soundPresetNames, k) end  
table.sort(soundPresetNames)  

-- [Internal Variables]
local Character, HRP, Humanoid
local CrosshairAnimationData = {
    pulseScale = 1,
    rotationAngle = 0,
    radarAngle = 0,
    waveOffset = 0,
    spiralAngle = 0,
    targetPulse = 0,
    neonGlow = 0,
    techRotation = 0,
    lastUpdate = 0
}
local function getCharRefs()
    Character = LocalPlayer.Character
    if Character then
        HRP = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
    else
        HRP, Humanoid = nil, nil
    end
    return Character, HRP, Humanoid
end
local OrbitEnabled = false
local VoidEnabled = false
local currentTarget = nil
local currentTargetScore = -math.huge
local targetLocked = false
local reacquireTimer = 0
local orbitAngle = math.random(0, 360)
local elapsed = 0
local lastCF = Camera.CFrame
local lastVelocity = Vector3.new()
local smoothAccel = Vector3.new()
local smoothedPredicted = nil
local voidX = math.random(-1e8, 1e8)
local voidZ = math.random(-1e8, 1e8)
local voidYOffset = 0
local voidYDir = 1
local voidDirX = math.random() * 2 - 1
local voidDirZ = math.random() * 2 - 1
local voidAnchorTimer = 0
local voidScrambleTimer = 0
local voidEvadeCooldown = 0
local intendedVoidPos = Vector3.new(voidX, CFG.VOID_Y_BASE, voidZ)
local desyncTimer = 0
local spoofAngle = math.random() * math.pi * 2
local spoofAngleDir = (math.random() > 0.5) and 1 or -1
local spoofBaseX, spoofBaseZ = 0, 0
local OrbitConnection = nil
local fakeGroundPos = Vector3.new(0, CFG.DESYNC_SPOOF_Y, 0)
local resolverHistory = {}
local drawBulletTracer = function() end
local inFlicker = false
local CrosshairLines = {}

-- [Helper Functions]
local function setPhysicsFFlags()
    pcall(function()
        settings().Physics.AllowSleep = CFG.PHYSICS_ALLOW_SLEEP
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle[CFG.PHYSICS_THROTTLE or "Disabled"]
        if setfflag then
            setfflag("S2PhysicsSenderRate", tostring(CFG.PHYSICS_TPS))
            setfflag("PhysicsReplicationRate", tostring(CFG.PHYSICS_TPS))
            setfflag("PhysicsSimulationRate", tostring(CFG.PHYSICS_SIM_RATE))
            setfflag("PhysicsSteppingMethod", CFG.PHYSICS_STEPPING)
            if CFG.PHYSICS_INTERP_THROTTLE then setfflag("InterpolationThrottling", "Always") end
            if CFG.PHYSICS_NET_OWNER_V2 then setfflag("NetworkOwnerV2", "True") end
            if CFG.PHYSICS_EXTREME_NET then
                setfflag("NetworkOwnershipHighFrequencyUpdate", "True")
                setfflag("PhysicsGridUpdateRate", "1000")
                setfflag("PriorityReplicationThreshold", "1")
                setfflag("PhysicsSendRate", "1000")
            end
            if CFG.PHYSICS_LATENCY_PATCH then
                setfflag("ReportHumanoidHealthChange", "True")
                setfflag("SimJobRate", "1000")
                setfflag("NetworkJobRate", "1000")
                setfflag("PhysicsJobRate", "1000")
            end
            if CFG.PHYSICS_QUANTUM_SYNC then
                setfflag("PhysicsAdaptiveStep", "True")
                setfflag("PhysicsInterpolationDynamicAlpha", "True")
                setfflag("ReplicationSendJobSleepMS", "0")
            end
            if CFG.PHYSICS_REPLICATION_MODE == "Extreme" then
                setfflag("ReplicationPacketSize", "65535")
                setfflag("ReplicationReliableSend", "True")
                setfflag("PhysicsSendStepLimit", "0")
            end
        end
    end)
end

-- ===================================================================
-- ADVANCED VOID SYSTEM - Quantum-Enhanced Spatial Manipulation
-- ===================================================================

local VoidController = {
    position = Vector3.new(0, 1e9, 0),
    velocity = Vector3.new(),
    acceleration = Vector3.new(),
    quantumState = {
        phase = 0,
        coherence = 1.0,
        entanglement = {},
        waveFunction = {},
        superposition = false
    },
    evasion = {
        threatMatrix = {},
        escapeVectors = {},
        cooldown = 0,
        adaptiveRadius = 1e9,
        predictionBuffer = {}
    },
    dynamics = {
        driftVector = Vector3.new(1, 0, 0),
        angularMomentum = 0,
        orbitalRadius = 1e9,
        temporalPhase = 0,
        chaosFactor = 0.98
    },
    flags = {
        isScrambling = false,
        isFlickering = false,
        isPhaseShifted = false,
        isQuantumLocked = false
    }
}

-- Void Movement Methods
local function computeVoidDriftDir(t)
    local nx = 0
    local nz = 0
    local amplitude = 1
    local frequency = 0.0001
    
    for i = 1, 4 do
        nx = nx + math.noise(t * frequency, 0.0) * amplitude
        nz = nz + math.noise(0.0, t * frequency) * amplitude
        frequency = frequency * 2.37
        amplitude = amplitude * 0.5
    end
    
    local secondaryPhase = t * 0.00073
    nx = nx + math.noise(secondaryPhase + 13.7, 7.3) * 0.3
    nz = nz + math.noise(secondaryPhase + 31.1, 17.9) * 0.3
    
    local chaosPhase = t * 0.00213
    local chaosX = math.sin(chaosPhase) * math.cos(chaosPhase * 1.618) * 0.2
    local chaosZ = math.cos(chaosPhase * 0.618) * math.sin(chaosPhase * 2.718) * 0.2
    
    nx = nx + chaosX
    nz = nz + chaosZ
    
    local len = math.sqrt(nx*nx + nz*nz)
    local smoothMin = 0.001
    if len < smoothMin then 
        local angle = t * 3.14159 * 0.1
        return math.cos(angle), math.sin(angle)
    end
    
    return nx/len, nz/len
end

local function stepVoidDrift(dt)
    local p = Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)
    if CFG.VOID_METHOD == "Stable" then return p
    elseif CFG.VOID_METHOD == "Drift" then
        local dx, dz = computeVoidDriftDir(elapsed)
        voidDirX = voidDirX + (dx - voidDirX) * CFG.VOID_DRIFT_CHAOS * dt * 10
        voidDirZ = voidDirZ + (dz - voidDirZ) * CFG.VOID_DRIFT_CHAOS * dt * 10
        voidX = voidX + voidDirX * CFG.VOID_DRIFT_SPEED * dt
        voidZ = voidZ + voidDirZ * CFG.VOID_DRIFT_SPEED * dt
        voidYOffset = voidYOffset + voidYDir * CFG.VOID_Y_DRIFT_SPEED * dt
        if math.abs(voidYOffset) >= CFG.VOID_Y_DRIFT_RANGE then voidYDir = -voidYDir end
        return Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)
    elseif CFG.VOID_METHOD == "Chaotic" then
        voidX = voidX + (math.random() - 0.5) * CFG.VOID_DRIFT_SPEED * dt * 5
        voidZ = voidZ + (math.random() - 0.5) * CFG.VOID_DRIFT_SPEED * dt * 5
        voidYOffset = voidYOffset + (math.random() - 0.5) * CFG.VOID_Y_DRIFT_SPEED * dt * 5
        return Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)
    elseif CFG.VOID_METHOD == "Circle" then
        local r = 1e9 local x = math.cos(elapsed * 2) * r local z = math.sin(elapsed * 2) * r
        return Vector3.new(voidX + x, CFG.VOID_Y_BASE + voidYOffset, voidZ + z)
    elseif CFG.VOID_METHOD == "Spiral" then
        local r = 1e9 * (1 + math.sin(elapsed)) local x = math.cos(elapsed * 3) * r local z = math.sin(elapsed * 3) * r
        return Vector3.new(voidX + x, CFG.VOID_Y_BASE + voidYOffset, voidZ + z)
    elseif CFG.VOID_METHOD == "Lissajous" then
        local r = 2e9 local x = math.sin(elapsed * CFG.VOID_LISSAJOUS_A) * r local z = math.sin(elapsed * CFG.VOID_LISSAJOUS_B) * r
        return Vector3.new(voidX + x, CFG.VOID_Y_BASE + voidYOffset, voidZ + z)
    elseif CFG.VOID_METHOD == "Perlin Noise" then
        local t = elapsed * 0.1
        local x = math.noise(t, 0) * 5e9 local z = math.noise(0, t) * 5e9
        return Vector3.new(voidX + x, CFG.VOID_Y_BASE + voidYOffset, voidZ + z)
    elseif CFG.VOID_METHOD == "Flicker Void" then
        local p = (tick() % (CFG.VOID_FLICKER_INT * 2) < CFG.VOID_FLICKER_INT) and Vector3.new(voidX, CFG.VOID_Y_BASE, voidZ) or Vector3.new(-voidX, CFG.VOID_Y_BASE + 1e9, -voidZ)
        return p
    elseif CFG.VOID_METHOD == "Gravity Well" then
        local t = elapsed * 0.5 local r = CFG.VOID_GRAVITY_STR * (1 + math.sin(t))
        return Vector3.new(voidX + math.cos(t) * r, CFG.VOID_Y_BASE + math.sin(t*0.7)*r, voidZ + math.sin(t)*r)
    elseif CFG.VOID_METHOD == "Helix" then
        local r = 1e9 local t = elapsed * 2
        return Vector3.new(voidX + math.cos(t) * r, CFG.VOID_Y_BASE + voidYOffset + math.sin(t*0.5)*r, voidZ + math.sin(t) * r)
    elseif CFG.VOID_METHOD == "Figure 8" then
        local r = 1.5e9 local t = elapsed * 1.5
        return Vector3.new(voidX + math.sin(t) * r, CFG.VOID_Y_BASE + voidYOffset, voidZ + math.sin(t) * math.cos(t) * r)
    elseif CFG.VOID_METHOD == "Tornado" then
        local r = 2e9 * math.abs(math.sin(elapsed))
        local t = elapsed * 5
        return Vector3.new(voidX + math.cos(t)*r, CFG.VOID_Y_BASE + math.sin(elapsed*2)*1e9, voidZ + math.sin(t)*r)
    elseif CFG.VOID_METHOD == "Butterfly" then
        local t = elapsed
        local r = (math.exp(math.sin(t)) - 2*math.cos(4*t) + math.sin((2*t-math.pi)/24)^5) * 5e8
        return Vector3.new(voidX + math.sin(t)*r, CFG.VOID_Y_BASE + math.cos(t)*r, voidZ + math.sin(t*0.5)*r)
    elseif CFG.VOID_METHOD == "Double Helix" then
        local r = 1e9 local t = elapsed * 3
        local off = (tick()%1 < 0.5) and 1 or -1
        return Vector3.new(voidX + math.cos(t)*r*off, CFG.VOID_Y_BASE + math.sin(t)*5e8, voidZ + math.sin(t)*r*off)
    elseif CFG.VOID_METHOD == "Chaotic Sphere" then
        local r = 2e9
        local t1, t2 = elapsed * 2, elapsed * 1.3
        return Vector3.new(voidX + math.sin(t1)*math.cos(t2)*r, CFG.VOID_Y_BASE + math.sin(t1)*math.sin(t2)*r, voidZ + math.cos(t1)*r)
    elseif CFG.VOID_METHOD == "Quantum Tunneling" then
        local r = 1e11 * (math.random() > 0.5 and 1 or -1)
        local jitter = Vector3.new(math.random(-1e9, 1e9), math.random(-1e8, 1e8), math.random(-1e9, 1e9))
        return Vector3.new(voidX + r, CFG.VOID_Y_BASE + jitter.Y, voidZ + r) + jitter
    elseif CFG.VOID_METHOD == "Eclipse Singularity" then
        local t = elapsed * 6
        local pulse = (math.sin(elapsed * 0.8) + 1) * 0.5
        local r = 8e10 + (pulse * 4e10)
        local x =
            math.sin(t) * r +
            math.sin(t * 2.7) * 2e10 +
            math.cos(t * 5.3) * 8e9
        local z =
            math.cos(t) * r +
            math.cos(t * 2.4) * 2e10 +
            math.sin(t * 4.9) * 8e9
        local y =
            CFG.VOID_Y_BASE +
            math.sin(t * 1.3) * 2e10 +
            math.cos(t * 3.1) * 7e9
        if math.floor(elapsed * 8) % 6 == 0 then
            x = -x * 1.15
            z = -z * 1.15
        end
        return Vector3.new(voidX + x, y, voidZ + z)
    elseif CFG.VOID_METHOD == "Fracternal Desync" then
        local t = elapsed * 5
        local x = math.sin(t) + math.sin(t * 2.1) / 2 + math.sin(t * 3.2) / 4
        local z = math.cos(t) + math.cos(t * 2.2) / 2 + math.cos(t * 3.1) / 4
        return Vector3.new(voidX + x * 1e10, CFG.VOID_Y_BASE + math.sin(t*10)*1e9, voidZ + z * 1e10)
    elseif CFG.VOID_METHOD ==  "HRP Desync" then
        local t = elapsed * 4
        local x = math.sin(t) * 1e10 + math.sin(t * 3.5) * 5e9
        local z = math.cos(t * 1.3) * 1e10 + math.cos(t * 2.8) * 5e9
        local y = CFG.VOID_Y_BASE + math.sin(t * 2.2) * 8e9 + math.cos(t * 4.1) * 6e9
        return Vector3.new(voidX + x, y, voidZ + z)
    elseif CFG.VOID_METHOD == "Extreme Desync" then
        local t = elapsed * 15
        local r = 1e12
        return Vector3.new(voidX + math.sin(t)*r, CFG.VOID_Y_BASE + math.cos(t*1.5)*r*0.1, voidZ + math.cos(t)*r)
    elseif CFG.VOID_METHOD == "Quantum Oscillation" then
        local t = elapsed * 50
        local r = 1e11 * math.sin(t)
        return Vector3.new(voidX + r, CFG.VOID_Y_BASE + math.cos(t)*1e10, voidZ + r)
    elseif CFG.VOID_METHOD == "Frame Skip" then
        local skip = (tick() % 0.1 < 0.05)
        if skip then return Vector3.new(voidX * 2, CFG.VOID_Y_BASE + 1e11, voidZ * 2) end
        return Vector3.new(voidX, CFG.VOID_Y_BASE, voidZ)
    elseif CFG.VOID_METHOD == "Fractal XAR (BEST)" then
        if not _quantumVoidActive then
            _quantumVoidActive = true
            local hrp
            local rs = game:GetService("RunService")
            local clientc
            local clientv
            local clientva
            
            local function betterRandom(mi, ma, dmi, dma)
                local val = math.random(mi, ma)
                repeat
                    val = math.random(mi, ma)
                until val < dmi or val > dma
                return val
            end
            
            rs.Heartbeat:Connect(function()
                pcall(function()
                    hrp = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
                    if not hrp then return end
                    clientc = hrp.CFrame
                    clientv = hrp.AssemblyLinearVelocity
                    clientva = hrp.AssemblyAngularVelocity
                    hrp.CFrame = CFrame.new(betterRandom(-2147483646, 2147483646, -1147483646, 1147483646), betterRandom(-2147483646, 2147483646, -1147483646, 1147483646), betterRandom(-2147483646, 2147483646, -1147483646, 1147483646)) * CFrame.Angles(math.rad(math.pi), math.rad(math.pi), math.rad(math.pi))
                    hrp.AssemblyLinearVelocity = Vector3.new(betterRandom(-2147483646, 2147483646, -1147483646, 1147483646), betterRandom(-2147483646, 2147483646, -1147483646, 1147483646), betterRandom(-2147483646, 2147483646, -1147483646, 1147483646))
                    hrp.AssemblyAngularVelocity = Vector3.new(betterRandom(-2147483646, 2147483646, -1147483646, 1147483646), betterRandom(-2147483646, 2147483646, -1147483646, 1147483646), betterRandom(-2147483646, 2147483646, -1147483646, 1147483646))
                end)
            end)
            rs:BindToRenderStep("quantumVoidSync", Enum.RenderPriority.First.Value, function()
                if hrp then
                    pcall(function() 
                        hrp.CFrame = clientc
                        hrp.AssemblyLinearVelocity = clientv
                        hrp.AssemblyAngularVelocity = clientva
                    end)
                end
            end)
        end
        return Vector3.new(voidX, CFG.VOID_Y_BASE + voidYOffset, voidZ)
    end
end

local function stepSpoofPos(dt)
    local noiseVal = math.noise(elapsed * 0.8, 42.0)
    spoofAngle = spoofAngle + spoofAngleDir * (1.5 + noiseVal * CFG.DESYNC_WANDER_CHAOS) * CFG.DESYNC_WANDER_SPEED * dt
    if math.noise(elapsed * 0.3, 7.7) > 0.6 then spoofAngleDir = -spoofAngleDir end
    local r = CFG.DESYNC_SPOOF_RADIUS * (0.5 + 0.5 * math.abs(math.noise(elapsed * 0.5, 0)))
    fakeGroundPos = Vector3.new(spoofBaseX + math.cos(spoofAngle) * r, CFG.DESYNC_SPOOF_Y, spoofBaseZ + math.sin(spoofAngle) * r)
end

local function runDesyncFlicker()
    if not HRP or inFlicker then return end
    inFlicker = true
    local savedVoid = intendedVoidPos
    HRP.CFrame = CFrame.new(fakeGroundPos)
    HRP.AssemblyLinearVelocity = Vector3.new(0, -0.01, 0)
    if CFG.PHYSICS_S2_SENDER then task.wait() else RunService.Heartbeat:Wait() end
    if HRP and VoidEnabled then HRP.CFrame = CFrame.new(savedVoid) HRP.AssemblyLinearVelocity = Vector3.zero end
    inFlicker = false
end

local function checkVoidEvasion()
    if not CFG.VOID_EVADE_ENABLED or voidEvadeCooldown > 0 then return end
    
    local closestThreat = nil
    local minDist = math.huge
    local threatVector = Vector3.new()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - intendedVoidPos).Magnitude
                local vel = hrp.AssemblyLinearVelocity
                local predictedPos = hrp.Position + vel * 0.5
                local predictedDist = (predictedPos - intendedVoidPos).Magnitude
                
                local threatScore = dist * 0.7 + predictedDist * 0.3
                
                if threatScore < minDist then
                    minDist = threatScore
                    closestThreat = hrp
                    threatVector = (predictedPos - intendedVoidPos).Unit
                end
            end
        end
    end
    
    if closestThreat and minDist < CFG.VOID_EVADE_RADIUS then
        local primaryEscape = threatVector * -1
        local perpendicular1 = Vector3.new(-threatVector.Z, 0, threatVector.X).Unit
        local perpendicular2 = Vector3.new(threatVector.Z, 0, -threatVector.X).Unit
        
        local threatLevel = math.max(0, 1 - (minDist / CFG.VOID_EVADE_RADIUS))
        local escapeWeight = 1 + threatLevel * 2
        
        local escapeVector = primaryEscape * escapeWeight
        escapeVector = escapeVector + perpendicular1 * (0.3 + threatLevel * 0.4)
        escapeVector = escapeVector + perpendicular2 * (0.2 + threatLevel * 0.3)
        
        voidX = voidX + escapeVector.X * CFG.VOID_EVADE_SPEED * 1.5
        voidZ = voidZ + escapeVector.Z * CFG.VOID_EVADE_SPEED * 1.5
        
        if math.random() < (CFG.VOID_EVADE_VERT_BIAS + threatLevel * 0.2) then
            local vertDir = CFG.VOID_EVADE_FORCE_UP and 1 or (math.random() > 0.5 and 1 or -1)
            local vertMomentum = closestThreat.AssemblyLinearVelocity.Y
            local vertCompensation = clamp(-vertMomentum * 0.1, -5, 5)
            voidYOffset = voidYOffset + (vertDir + vertCompensation) * CFG.VOID_EVADE_VERT_SPEED
        end
        
        voidEvadeCooldown = CFG.VOID_EVADE_COOLDOWN * (1 - threatLevel * 0.3)
    end
end

local function lockToVoid(dt)
    if not HRP or inFlicker then return end
    if voidEvadeCooldown > 0 then voidEvadeCooldown = voidEvadeCooldown - dt end
    if CFG.VOID_SCRAMBLE_ENABLED then
        voidScrambleTimer = voidScrambleTimer + dt
        if voidScrambleTimer >= CFG.VOID_SCRAMBLE_TIME then voidScrambleTimer = 0 end
    end
    checkVoidEvasion()
    intendedVoidPos = stepVoidDrift(dt)
    
    local targetPos = intendedVoidPos
    local antiDetectOffset = Vector3.new(0, 0, 0)
    
    if CFG.VOID_METHOD ~= "Stable" then
        local microTime = tick() * 1000
        local microX = math.sin(microTime * 0.1) * 50
        local microZ = math.cos(microTime * 0.13) * 50
        local microY = math.sin(microTime * 0.07) * 20
        antiDetectOffset = Vector3.new(microX, microY, microZ)
    end
    
    if CFG.VOID_GHOSTING_ENABLED then
        local ghostChance = CFG.VOID_GHOSTING_INTENSITY
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - intendedVoidPos).Magnitude
                    if dist < CFG.VOID_EVADE_RADIUS * 0.5 then
                        ghostChance = math.min(1, ghostChance + 0.3)
                    end
                end
            end
        end
        
        if math.random() < ghostChance then
            targetPos = fakeGroundPos + antiDetectOffset
        else
            targetPos = intendedVoidPos + antiDetectOffset
        end
    else
        targetPos = intendedVoidPos + antiDetectOffset
    end
    
    if CFG.VOID_BYPASS_MODE == "Velocity" then
        if HRP then HRP.AssemblyLinearVelocity = (targetPos - HRP.Position) * 100 end
    elseif CFG.VOID_BYPASS_MODE == "CFrame only" then
        if HRP then HRP.CFrame = CFrame.new(targetPos) end
    elseif CFG.VOID_BYPASS_MODE == "Hybrid" then
        if HRP then
            HRP.CFrame = CFrame.new(targetPos)
            HRP.AssemblyLinearVelocity = Vector3.new(0, 0.01, 0)
        end
    elseif CFG.VOID_BYPASS_MODE == "Network Spoof" then
        if HRP then
            HRP.CFrame = CFrame.new(targetPos)
            HRP.AssemblyLinearVelocity = (targetPos - HRP.Position) * 50
            HRP.AssemblyAngularVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
        end
    elseif CFG.VOID_BYPASS_MODE == "Physics Bypass" then
        if HRP then
            HRP.CFrame = CFrame.new(targetPos)
            HRP.AssemblyLinearVelocity = Vector3.new(math.random(-1,1), math.random(-1,1), math.random(-1,1)) * 1e5
        end
    else
        if HRP then
            HRP.CFrame = CFrame.new(targetPos)
            HRP.AssemblyLinearVelocity = Vector3.zero
        end
    end
    
    if CFG.DESYNC_ENABLED then
        stepSpoofPos(dt)
        desyncTimer = desyncTimer + dt
        if desyncTimer >= CFG.DESYNC_TICK_RATE then desyncTimer = 0 task.spawn(runDesyncFlicker) end
    end
end

-- ===================================================================
-- ORBIT SYSTEM - Camera Movement & Targeting
-- ===================================================================

local function findBestTarget()
    local bestTarget = nil
    local bestScore = -math.huge
    local cameraPos = Camera.CFrame.Position
    local cameraLook = Camera.CFrame.LookVector
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart and humanoid.Health > CFG.KILL_HP then
                local dist = (cameraPos - rootPart.Position).Magnitude
                local toTarget = (rootPart.Position - cameraPos).Unit
                local dot = toTarget:Dot(cameraLook)
                local angleDeg = math.deg(math.acos(clamp(dot, -1, 1)))
                
                if angleDeg <= CFG.LOCK_FOV then
                    local score = (1 / math.max(dist, 1)) * 1000
                    score = score + (humanoid.MaxHealth - humanoid.Health) * 10
                    score = score - angleDeg * 5
                    
                    if CFG.AUTO_LOCK and dist <= CFG.AUTO_LOCK_RADIUS then
                        score = score + 500
                    end
                    
                    if score > bestScore then
                        bestScore = score
                        bestTarget = player
                    end
                end
            end
        end
    end
    
    return bestTarget, bestScore
end

local function resolveTarget(target, dt)
    if not target or not target:FindFirstChild("HumanoidRootPart") then return nil end
    local thrp = target.HumanoidRootPart
    local pos, vel = thrp.Position, thrp.AssemblyLinearVelocity
    local name = target.Name
    if not resolverHistory[name] then resolverHistory[name] = {lastPos = pos, lastVel = vel, adaptiveOffset = Vector3.zero, history = {}} end
    local history = resolverHistory[name]
    table.insert(history.history, 1, {pos = pos, vel = vel, tick = tick()})
    if #history.history > CFG.RESOLVER_HISTORY_SIZE then table.remove(history.history) end
    
    local targetPart = thrp
    if CFG.RESOLVER_MULTI_POINT then
        for _, pName in ipairs({"Head", "HumanoidRootPart", "LowerTorso"}) do
            local p = target:FindFirstChild(pName)
            if p then
                local ray = workspace:Raycast(Camera.CFrame.Position, (p.Position - Camera.CFrame.Position).Unit * 1000)
                if ray and ray.Instance:IsDescendantOf(target) then targetPart = p break end
            end
        end
    end
    pos = targetPart.Position

    local floorRay = workspace:Raycast(pos + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0))
    local isUnderground = not floorRay or pos.Y < (floorRay.Position.Y - 1)
    
    if isUnderground and CFG.RESOLVER_ENABLED then
        if CFG.RESOLVER_METHOD == "Predictive" then
            local pred = pos + (vel * CFG.PREDICTION)
            return Vector3.new(pred.X, floorRay and floorRay.Position.Y or pos.Y + CFG.RESOLVER_OFFSET, pred.Z)
        elseif CFG.RESOLVER_METHOD == "Adaptive" then
            local delta = vel - history.lastVel
            history.adaptiveOffset = history.adaptiveOffset:Lerp(delta * CFG.RESOLVER_ADAPTIVE_SENS, 0.1)
            history.lastVel = vel
            local groundY = floorRay and floorRay.Position.Y or pos.Y + 2
            return Vector3.new(pos.X + (vel.X * CFG.PREDICTION), groundY, pos.Z + (vel.Z * CFG.PREDICTION)) + history.adaptiveOffset
        end
    end

    if CFG.RESOLVER_METHOD == "Predictive" then return pos + (vel * CFG.PREDICTION) + (smoothAccel * CFG.ACCEL_WEIGHT)
    elseif CFG.RESOLVER_METHOD == "Raycast" then
        local ray = workspace:Raycast(pos + Vector3.new(0, 10, 0), Vector3.new(0, -50, 0))
        return ray and ray.Position or pos
    elseif CFG.RESOLVER_METHOD == "Velocity" then return pos + (vel.Unit * CFG.RESOLVER_OFFSET)
    elseif CFG.RESOLVER_METHOD == "Adaptive" then
        local delta = vel - history.lastVel
        history.adaptiveOffset = history.adaptiveOffset:Lerp(delta * CFG.RESOLVER_ADAPTIVE_SENS, 0.1)
        history.lastVel = vel
        return pos + (vel * CFG.PREDICTION) + history.adaptiveOffset
    elseif CFG.RESOLVER_METHOD == "Interpolate" then
        if #history.history > 2 then
            local p1, p2 = history.history[1].pos, history.history[2].pos
            return p1 + (p1 - p2) * CFG.PREDICTION
        end
    elseif CFG.RESOLVER_METHOD == "Dynamic Y" then
        local yOff = math.sin(tick() * 2) * CFG.RESOLVER_OFFSET
        return pos + (vel * CFG.PREDICTION) + Vector3.new(0, yOff, 0)
    elseif CFG.RESOLVER_METHOD == "Bypass Check" then
        local ray = workspace:Raycast(Camera.CFrame.Position, (pos - Camera.CFrame.Position).Unit * 1000)
        if ray then return ray.Position end
        return pos + (vel * CFG.PREDICTION)
    elseif CFG.RESOLVER_METHOD == "Desync Inverse" then
        return pos + (vel * CFG.PREDICTION) - (smoothAccel * CFG.ACCEL_WEIGHT * 2)
    elseif CFG.RESOLVER_METHOD == "Tick History" then
        if #history.history >= 3 then
            local avgVel = (history.history[1].vel + history.history[2].vel + history.history[3].vel) / 3
            return pos + (avgVel * CFG.PREDICTION)
        end
    elseif CFG.RESOLVER_METHOD == "Multi Point" then
        local points = {target:FindFirstChild("Head"), target:FindFirstChild("HumanoidRootPart"), target:FindFirstChild("LowerTorso")}
        local bestPoint = nil
        local bestDist = math.huge
        for _, p in ipairs(points) do
            if p then
                local ray = workspace:Raycast(Camera.CFrame.Position, (p.Position - Camera.CFrame.Position).Unit * 1000)
                if not ray then
                    local dist = (p.Position - Camera.CFrame.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        bestPoint = p
                    end
                end
            end
        end
        if bestPoint then return bestPoint.Position + (vel * CFG.PREDICTION) end
    elseif CFG.RESOLVER_METHOD == "Hit Scan" then
        local hits = {}
        for _, pName in ipairs({"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
            local part = target:FindFirstChild(pName)
            if part then
                local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                if not ray then table.insert(hits, part.Position) end
            end
        end
        if #hits > 0 then
            local avgPos = Vector3.new(0, 0, 0)
            for _, hit in ipairs(hits) do avgPos = avgPos + hit end
            return (avgPos / #hits) + (vel * CFG.PREDICTION)
        end
    end
    return pos + (vel * CFG.PREDICTION)
end

local function setCamera(dt)
    if not OrbitEnabled then return end
    
    local camPos = Camera.CFrame.Position
    local camLook = Camera.CFrame.LookVector
    
    if reacquireTimer > 0 then
        reacquireTimer = reacquireTimer - dt
        if reacquireTimer <= 0 then
            currentTarget = nil
            currentTargetScore = -math.huge
        end
    end
    
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local newTarget, newScore = findBestTarget()
        if newTarget and newScore > currentTargetScore then
            currentTarget = newTarget
            currentTargetScore = newScore
            targetLocked = true
            reacquireTimer = 0.5
        end
    end
    
    if not currentTarget then return end
    
    local resolvedPos = resolveTarget(currentTarget, dt)
    if not resolvedPos then return end
    
    local currentVelocity = (resolvedPos - (smoothedPredicted or resolvedPos)) / dt
    smoothAccel = smoothAccel:Lerp((currentVelocity - lastVelocity) / dt, CFG.ACCEL_SMOOTH)
    lastVelocity = currentVelocity
    smoothedPredicted = resolvedPos + currentVelocity * CFG.PREDICTION
    
    orbitAngle = orbitAngle + CFG.ORBIT_SPEED * dt
    
    local orbitOffset = Vector3.new(0, 0, 0)
    
    if CFG.ORBIT_MODE == "Default" then
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * (0.5 + 0.5 * math.sin(elapsed * 0.3))
        orbitOffset = Vector3.new(math.cos(orbitAngle) * radius, CFG.HEIGHT_OFFSET, math.sin(orbitAngle) * radius)
    elseif CFG.ORBIT_MODE == "Spiral" then
        local radius = CFG.MIN_RADIUS + (elapsed * 100000) % (CFG.MAX_RADIUS - CFG.MIN_RADIUS)
        orbitOffset = Vector3.new(math.cos(orbitAngle) * radius, CFG.HEIGHT_OFFSET, math.sin(orbitAngle) * radius)
    elseif CFG.ORBIT_MODE == "Random" then
        local radius = CFG.MIN_RADIUS + math.random() * (CFG.MAX_RADIUS - CFG.MIN_RADIUS)
        orbitOffset = Vector3.new(math.cos(orbitAngle) * radius, CFG.HEIGHT_OFFSET + math.random(-10000, 10000), math.sin(orbitAngle) * radius)
    elseif CFG.ORBIT_MODE == "Smart" then
        local dist = (Camera.CFrame.Position - resolvedPos).Magnitude
        local radius = clamp(dist, CFG.MIN_RADIUS, CFG.MAX_RADIUS)
        orbitOffset = Vector3.new(math.cos(orbitAngle) * radius, CFG.HEIGHT_OFFSET, math.sin(orbitAngle) * radius)
    elseif CFG.ORBIT_MODE == "Lissajous" then
        local radiusX = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.7
        local radiusZ = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.3
        orbitOffset = Vector3.new(math.sin(orbitAngle * 3) * radiusX, CFG.HEIGHT_OFFSET, math.sin(orbitAngle * 2) * radiusZ)
    elseif CFG.ORBIT_MODE == "Helix" then
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.5
        local height = CFG.HEIGHT_OFFSET + math.sin(orbitAngle * 2) * 50000
        orbitOffset = Vector3.new(math.cos(orbitAngle) * radius, height, math.sin(orbitAngle) * radius)
    elseif CFG.ORBIT_MODE == "Figure 8" then
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.5
        orbitOffset = Vector3.new(math.sin(orbitAngle) * radius, CFG.HEIGHT_OFFSET, math.sin(orbitAngle * 2) * radius)
    elseif CFG.ORBIT_MODE == "Pulse" then
        local pulseRadius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * (0.5 + 0.5 * math.sin(elapsed * 5))
        orbitOffset = Vector3.new(math.cos(orbitAngle) * pulseRadius, CFG.HEIGHT_OFFSET, math.sin(orbitAngle) * pulseRadius)
    elseif CFG.ORBIT_MODE == "Lissajous 3D" then
        local t = orbitAngle
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.6
        orbitOffset = Vector3.new(
            math.sin(t * 3) * radius,
            CFG.HEIGHT_OFFSET + math.sin(t * 2) * 30000,
            math.cos(t * 4) * radius
        )
    elseif CFG.ORBIT_MODE == "Tornado" then
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * (0.3 + 0.7 * math.abs(math.sin(elapsed * 2)))
        local height = CFG.HEIGHT_OFFSET + math.sin(elapsed * 10) * 100000
        orbitOffset = Vector3.new(math.cos(orbitAngle * 3) * radius, height, math.sin(orbitAngle * 3) * radius)
    elseif CFG.ORBIT_MODE == "Butterfly" then
        local t = orbitAngle
        local r = (math.exp(math.sin(t)) - 2*math.cos(4*t) + math.sin((2*t-math.pi)/24)^5) * (CFG.MIN_RADIUS / 1000000)
        orbitOffset = Vector3.new(math.sin(t) * r, CFG.HEIGHT_OFFSET + math.cos(t) * r * 0.3, math.sin(t*0.5) * r)
    elseif CFG.ORBIT_MODE == "Double Helix" then
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.4
        local offset = (tick() % 1 < 0.5) and 1 or -1
        orbitOffset = Vector3.new(math.cos(orbitAngle * 2) * radius * offset, CFG.HEIGHT_OFFSET + math.sin(orbitAngle) * 50000, math.sin(orbitAngle * 2) * radius * offset)
    elseif CFG.ORBIT_MODE == "Chaotic Sphere" then
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.5
        local t1, t2 = orbitAngle, orbitAngle * 1.3
        orbitOffset = Vector3.new(math.sin(t1) * math.cos(t2) * radius, CFG.HEIGHT_OFFSET + math.sin(t1) * math.sin(t2) * radius * 0.3, math.cos(t1) * radius)
    elseif CFG.ORBIT_MODE == "Hyper Elliptical" then
        local radiusX = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * CFG.ELLIPSE_RATIO
        local radiusZ = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * (1 - CFG.ELLIPSE_RATIO)
        orbitOffset = Vector3.new(math.cos(orbitAngle) * radiusX, CFG.HEIGHT_OFFSET, math.sin(orbitAngle) * radiusZ)
    elseif CFG.ORBIT_MODE == "4D Hypercube" then
        local t = orbitAngle
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.5
        orbitOffset = Vector3.new(
            math.cos(t) * radius,
            CFG.HEIGHT_OFFSET + math.sin(t * 1.618) * 30000,
            math.sin(t) * radius + math.cos(t * 2.718) * radius * 0.3
        )
    elseif CFG.ORBIT_MODE == "Quantum Orbit" then
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * (0.5 + 0.5 * math.sin(elapsed * 13))
        local quantumPhase = math.sin(elapsed * 7) * math.pi
        orbitOffset = Vector3.new(
            math.cos(orbitAngle + quantumPhase) * radius,
            CFG.HEIGHT_OFFSET + math.sin(quantumPhase * 2) * 50000,
            math.sin(orbitAngle + quantumPhase) * radius
        )
    elseif CFG.ORBIT_MODE == "Adaptive Orbit" then
        local dist = (Camera.CFrame.Position - resolvedPos).Magnitude
        local adaptiveRadius = clamp(dist, CFG.MIN_RADIUS, CFG.MAX_RADIUS)
        local adaptiveSpeed = CFG.ORBIT_SPEED * (1 + (dist / CFG.MAX_RADIUS))
        orbitAngle = orbitAngle + adaptiveSpeed * dt
        orbitOffset = Vector3.new(math.cos(orbitAngle) * adaptiveRadius, CFG.HEIGHT_OFFSET, math.sin(orbitAngle) * adaptiveRadius)
    elseif CFG.ORBIT_MODE == "Predatory Orbit" then
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.3
        local huntAngle = math.atan2(resolvedPos.Z - camPos.Z, resolvedPos.X - camPos.X)
        orbitAngle = orbitAngle + CFG.ORBIT_SPEED * dt * 2
        orbitOffset = Vector3.new(math.cos(orbitAngle + huntAngle) * radius, CFG.HEIGHT_OFFSET, math.sin(orbitAngle + huntAngle) * radius)
    elseif CFG.ORBIT_MODE == "Dimensional Shift" then
        local dimension = math.floor(elapsed * 0.5) % 3
        local radius = CFG.MIN_RADIUS + (CFG.MAX_RADIUS - CFG.MIN_RADIUS) * 0.6
        if dimension == 0 then
            orbitOffset = Vector3.new(math.cos(orbitAngle) * radius, CFG.HEIGHT_OFFSET, math.sin(orbitAngle) * radius)
        elseif dimension == 1 then
            orbitOffset = Vector3.new(math.cos(orbitAngle) * radius, CFG.HEIGHT_OFFSET + math.sin(orbitAngle) * radius * 0.5, 0)
        else
            orbitOffset = Vector3.new(0, CFG.HEIGHT_OFFSET, math.cos(orbitAngle) * radius)
        end
    end
    
    local jitterOffset = Vector3.new(
        math.random(-CFG.ORBIT_JITTER, CFG.ORBIT_JITTER),
        math.random(-CFG.ORBIT_JITTER, CFG.ORBIT_JITTER),
        math.random(-CFG.ORBIT_JITTER, CFG.ORBIT_JITTER)
    )
    
    orbitOffset = orbitOffset + jitterOffset
    
    local targetPosition = resolvedPos + orbitOffset
    local lookAtPosition = resolvedPos
    
    local cameraCFrame = CFrame.lookAt(targetPosition, lookAtPosition)
    local lerpFactor = clamp(
        CFG.CAM_LERP_BASE + currentVelocity.Magnitude * 0.004,
        CFG.CAM_LERP_BASE,
        0.45
    )
    
    Camera.CFrame = Camera.CFrame:Lerp(cameraCFrame, lerpFactor * CFG.ORBIT_STABILITY)
end

local function toggleOrbit(enabled)
    OrbitEnabled = enabled
    if enabled then
        if OrbitConnection then OrbitConnection:Disconnect() end
        OrbitConnection = RunService.RenderStepped:Connect(function(dt)
            setCamera(dt)
        end)
        
        -- Check for targets and notify
        local targetCount = 0
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                targetCount = targetCount + 1
            end
        end
        
        if targetCount > 0 then
            Library:Notify('Orbit activated - ' .. targetCount .. ' targets found', 2)
        else
            Library:Notify('Orbit activated - No targets available', 3)
        end
    else
        if OrbitConnection then
            OrbitConnection:Disconnect()
            OrbitConnection = nil
        end
        if Humanoid then
            Camera.CameraSubject = Humanoid
            Camera.CameraType = Enum.CameraType.Follow
        end
        Library:Notify('Orbit deactivated', 2)
    end
end

-- Metatable Hook
local function applyNamecallHook()
    local ok, mt = pcall(getrawmetatable, game)
    if not ok or not mt then return end
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        local changed = false
        if OrbitEnabled and (method == "FireServer" or method == "InvokeServer") then
            for i, v in ipairs(args) do
                if typeof(v) == "Vector3" and math.abs(v.Y) > 1000 then args[i] = fakeGroundPos changed = true
                elseif typeof(v) == "CFrame" and math.abs(v.Position.Y) > 1000 then args[i] = CFrame.new(fakeGroundPos) * (v - CFrame.new(v.Position)) changed = true end
            end
        end
        if CFG.PROJECTILE_TP_ENABLED and math.random(1, 100) <= CFG.PROJECTILE_TP_CHANCE and currentTarget then
            if method == "FireServer" or method == "InvokeServer" then
                local selfName = tostring(self)
                if selfName == "UseItem" or selfName:find("Shoot") or selfName:find("Fire") or selfName:find("Weapon") then
                    local targetPart = currentTarget:FindFirstChild(CFG.PROJECTILE_TP_PART) or currentTarget:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local meth = CFG.PROJECTILE_TP_METHOD
                        if meth == "Instant" then
                            for i, v in ipairs(args) do
                                if typeof(v) == "Vector3" then args[i] = targetPart.Position changed = true
                                elseif typeof(v) == "CFrame" then args[i] = CFrame.new(targetPart.Position) changed = true end
                            end
                        elseif meth == "Predictive" then
                            local vel = targetPart.AssemblyLinearVelocity
                            local pred = targetPart.Position + vel * CFG.PREDICTION
                            for i, v in ipairs(args) do
                                if typeof(v) == "Vector3" then args[i] = pred changed = true
                                elseif typeof(v) == "CFrame" then args[i] = CFrame.new(pred) changed = true end
                            end
                        elseif meth == "Velocity" then
                            local dir = (targetPart.Position - HRP.Position).Unit
                            for i, v in ipairs(args) do if typeof(v) == "Vector3" and v.Magnitude > 10 then args[i] = dir * v.Magnitude changed = true end end
                        elseif meth == "Curved" then
                            local curve = Vector3.new(0, 5, 0)
                            for i, v in ipairs(args) do
                                if typeof(v) == "Vector3" then args[i] = targetPart.Position + curve changed = true end
                            end
                        elseif meth == "Multi Point" then
                            local points = {"Head", "HumanoidRootPart", "LowerTorso"}
                            local p = currentTarget:FindFirstChild(points[math.random(1, #points)])
                            if p then
                                for i, v in ipairs(args) do
                                    if typeof(v) == "Vector3" then args[i] = p.Position changed = true end
                                end
                            end
                        elseif meth == "Silent" then
                            for i, v in ipairs(args) do
                                if typeof(v) == "table" and v.Hit then v.Hit = targetPart v.Pos = targetPart.Position changed = true end
                            end
                        elseif meth == "Backtrack" then
                            local hist = resolverHistory[currentTarget.Name]
                            if hist and #hist.history > 2 then
                                local oldPos = hist.history[3].pos
                                for i, v in ipairs(args) do if typeof(v) == "Vector3" then args[i] = oldPos changed = true end end
                            end
                        end
                        if changed then drawBulletTracer(HRP.Position, targetPart.Position) end
                    end
                end
            end
        end

        if CFG.CRITICAL_TP_ENABLED and math.random(1, 100) <= CFG.CRITICAL_TP_CHANCE and currentTarget then
            if method == "FireServer" or method == "InvokeServer" then
                local selfName = tostring(self)
                if selfName == "UseItem" or selfName:find("Shoot") or selfName:find("Fire") or selfName:find("Weapon") then
                    local targetPart = currentTarget:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local meth = CFG.CRITICAL_TP_METHOD
                        local savedCF = HRP.CFrame
                        
                        if meth == "Above" then
                            HRP.CFrame = targetPart.CFrame * CFrame.new(0, 5, 0)
                        elseif meth == "Behind" then
                            HRP.CFrame = targetPart.CFrame * CFrame.new(0, 0, 3)
                        elseif meth == "Offset" then
                            HRP.CFrame = targetPart.CFrame * CFrame.new(3, 0, 3)
                        elseif meth == "Jitter" then
                            HRP.CFrame = targetPart.CFrame * CFrame.new(math.random(-5,5), 2, math.random(-5,5))
                        elseif meth == "Spin" then
                            HRP.CFrame = targetPart.CFrame * CFrame.Angles(0, tick()*20, 0) * CFrame.new(0, 0, 5)
                        elseif meth == "Orbit Target" then
                            local t = tick() * 10
                            HRP.CFrame = CFrame.new(targetPart.Position + Vector3.new(math.cos(t)*5, 2, math.sin(t)*5), targetPart.Position)
                        elseif meth == "Rapid Flicker" then
                            HRP.CFrame = (tick() % 0.1 < 0.05) and targetPart.CFrame * CFrame.new(0, 5, 0) or targetPart.CFrame * CFrame.new(0, -5, 0)
                        end
                        task.delay(CFG.CRITICAL_TP_DELAY, function() if HRP then HRP.CFrame = savedCF end end)
                    end
                end
            end
        end
        
        return old(self, ...)
    end)
    mt.__namecall = old
end

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    
    -- Re-enable systems if they were active
    if VoidEnabled then
        -- Void will automatically re-enable in next heartbeat
    end
    if OrbitEnabled then
        toggleOrbit(true)
    end
end)

-- Heartbeat System - EMERGENCY OPTIMIZATION (10Hz for maximum performance)
local lastUpdate = 0
local updateInterval = 1/10 -- Reduced to 10Hz for emergency performance
local frameCount = 0
local performanceMode = true -- Enable performance mode by default
local startupMode = true -- Startup mode for first 30 seconds

-- Disable startup mode after 30 seconds
task.delay(30, function()
    startupMode = false
    print("Fracternal v1: Startup mode disabled - Full performance enabled")
end)

RunService.Heartbeat:Connect(function(dt)
    -- Emergency performance: skip frames during startup
    frameCount = frameCount + 1
    if performanceMode and frameCount % 3 == 0 then return end
    
    -- During startup, only run essential functions
    if startupMode and frameCount % 5 ~= 0 then return end
    
    local now = tick()
    if now - lastUpdate < updateInterval then return end
    lastUpdate = now
    
    local char, hrp, hum = getCharRefs()
    if not char or not hrp or not hum or hum.Health <= 0 then return end
    
    -- During startup, disable all expensive operations
    if not startupMode then
        -- Optimized Void System - Single Update Per Frame
        if VoidEnabled then
            lockToVoid(dt)
            
            -- EMERGENCY THROTTLED hitbox manipulation (only every 40 frames)
            if CFG.VOID_ENABLED and frameCount % 40 == 0 then
                hrp.Size = Vector3.new(0.1, 0.1, 0.1)
                hrp.Transparency = 1
                
                -- Optimized body part updates (batch operation)
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") and part ~= hrp then
                        part.Transparency = 1
                        part.Size = part.Size * 0.001
                    end
                end
            end
            
            -- EMERGENCY THROTTLED velocity chaos (only every 20 frames)
            if frameCount % 20 == 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    math.random(-5e7, 5e7), -- Further reduced
                    math.random(-5e7, 5e7),
                    math.random(-5e7, 5e7)
                )
                hrp.AssemblyAngularVelocity = Vector3.new(
                    math.random(-5e6, 5e6), -- Further reduced
                    math.random(-5e6, 5e6),
                    math.random(-5e6, 5e6)
                )
            end
            
            -- EMERGENCY THROTTLED anchor spam (only every 60 frames)
            if frameCount % 60 == 0 and math.random() > 0.9 then
                hrp.Anchored = true
                hrp.Anchored = false
            end
        end
        
        -- Anti-Aim (only when orbit is not enabled) - EMERGENCY THROTTLED
        if not OrbitEnabled and CFG.AA_ENABLED and frameCount % 12 == 0 then
            hum.AutoRotate = false
            local meth = CFG.AA_METHOD
            local t = tick()
            
            -- Only run basic AA methods during startup
            if meth == "Spin" then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(CFG.AA_SPEED), 0)
            elseif meth == "Jitter" then
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-CFG.AA_JITTER_RANGE/2, CFG.AA_JITTER_RANGE/2)), 0)
            elseif meth == "Backwards" then
                hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position - Camera.CFrame.LookVector)
            end
        else
            if hum then hum.AutoRotate = true end
        end
        
        -- Anti-Orbit Defensive Logic - EMERGENCY THROTTLED
        if CFG.ANTI_ORBIT_ENABLED and not OrbitEnabled and frameCount % 20 == 0 then
            local meth = CFG.ANTI_ORBIT_METHOD
            local intensity = CFG.ANTI_ORBIT_INTENSITY
            local radius = CFG.ANTI_ORBIT_RADIUS
            local t = tick() * CFG.ANTI_ORBIT_SPEED
            
            -- Only run basic anti-orbit methods
            if meth == "Vector Jitter" then
                hrp.AssemblyLinearVelocity = Vector3.new(math.sin(t*2)*intensity*5, math.cos(t*1.5)*intensity*2, math.cos(t*2)*intensity*5)
            elseif meth == "Phase Shift" and tick() % 0.2 < 0.05 then
                hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-radius/2, radius/2), 0, math.random(-radius/2, radius/2))
            end
        end
    end
end)

-- UI Setup - EMERGENCY ASYNC to prevent freeze
task.spawn(function()
    -- Wait for libraries to load with timeout to prevent freeze
    local startTime = tick()
    local maxWaitTime = 15 -- Increased timeout for slow connections
    
    -- Wait even longer for game stability
    task.wait(5) -- Increased initial delay
    
    repeat 
        task.wait(1) -- Increased wait time to reduce CPU usage
        if tick() - startTime > maxWaitTime then
            print("Library loading timeout - continuing with fallback")
            break
        end
    until Library and ThemeManager and SaveManager
    
    -- Add another delay to ensure game is fully loaded
    task.wait(3)
    
    -- Pre-allocate UI elements to prevent lag
    local windowConfig = {
        Title = 'Fracternal v1', 
        Center = true, 
        AutoShow = true, -- Enable auto-show to ensure GUI appears
        TabPadding = IsMobile and 15 or 10,
        MenuFadeTime = IsMobile and 0.3 or 0.2
    }
    
    -- Create window with error handling
    local success, Window = pcall(function()
        return Library:CreateWindow(windowConfig)
    end)
    
    if not success or not Window then
        print("Failed to create UI window")
        return
    end

-- GUI Entrance Animation - EMERGENCY OPTIMIZED
task.spawn(function()
    task.wait(1) -- Increased delay for stability
    if Library and Library.Main then
        pcall(function()
            -- Show window immediately - skip animation for performance
            if Window and Window.Show then
                Window:Show()
                print("Fracternal v1: Window shown successfully")
            else
                print("Fracternal v1: Failed to show window - Window object invalid")
            end
            
            -- Minimal animation - just set transparency
            Library.Main.BackgroundTransparency = 0
            
            -- Batch transparency changes for better performance
            local descendants = Library.Main:GetDescendants()
            for i = 1, #descendants do
                local v = descendants[i]
                if v:IsA("Frame") then
                    v.BackgroundTransparency = 0
                elseif v:IsA("TextLabel") or v:IsA("TextButton") then
                    v.BackgroundTransparency = 0
                    v.TextTransparency = 0
                end
                
                -- Yield every 100 objects to prevent freeze
                if i % 100 == 0 then
                    task.wait()
                end
            end
            
            print("Fracternal v1: GUI setup completed")
        end)
    else
        print("Fracternal v1: Library or Library.Main not available")
    end
end)

local Tabs = { 
    Void = Window:AddTab('Void'), 
    Orbit = Window:AddTab('Orbit'), 
    Extras = Window:AddTab('Extras'),
    ['UI Settings'] = Window:AddTab('UI Settings') 
}

-- VOID TAB
local VoidMain = Tabs.Void:AddLeftGroupbox('Void Control')
local VoidEvasion = Tabs.Void:AddRightGroupbox('Evasion & Desync')

VoidMain:AddToggle('VoidEnable', { Text = 'Enable Void', Default = false })
local originalPosition = nil
local voidActive = false

Toggles.VoidEnable:OnChanged(function() 
    VoidEnabled = Toggles.VoidEnable.Value
    CFG.VOID_ENABLED = VoidEnabled
    
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if not hrp then
        warn("HRP not found!")
        return
    end
    
    if VoidEnabled and not voidActive then
        -- Void is turning ON - save original position
        task.delay(0.1, function()
            originalPosition = hrp.Position
            voidActive = true
            print("✓ Void enabled. Position saved: " .. tostring(originalPosition))
        end)
    elseif not VoidEnabled and voidActive then
        -- Void is turning OFF - return to original position
        task.delay(0.2, function()
            voidActive = false
            if originalPosition then
                print("Restoring position: " .. tostring(originalPosition))
                hrp.CFrame = CFrame.new(originalPosition)
                
                -- Add code here to modify humanoid properties when void is disabled
                if humanoid and hrp then
                    hrp.Anchored = false
                    humanoid.PlatformStand = false
                    humanoid.WalkSpeed = 16
                    humanoid.JumpPower = 50
                end
                
                Library:Notify('Void Disabled.')
            else
                warn("No original position saved!")
            end
        end)
    end
end)

VoidMain:AddLabel('Hotkey'):AddKeyPicker('VoidKeybind', { Default = 'V', Mode = 'Toggle', Text = 'Void On/Off', MobileButton = IsMobile })
Options.VoidKeybind:OnClick(function() Toggles.VoidEnable:SetValue(not Toggles.VoidEnable.Value) end)

VoidMain:AddDropdown('VoidMethod', { Text = 'Void Method', Values = {'Stable', 'Fracternal Desync', 'Drift', 'Chaotic',  'Eclipse Singularity', 'Fractal XAR (BEST)', 'HRP Desync', 'Circle', 'Spiral', 'Lissajous', 'Quantum Void', 'Perlin Noise', 'Flicker Void', 'Gravity Well', 'Helix', 'Figure 8', 'Tornado', 'Butterfly', 'Double Helix', 'Chaotic Sphere', 'Quantum Tunneling', 'Extreme Desync', 'Quantum Oscillation', 'Frame Skip'}, Default = 'Quantum Tunneling' })
Options.VoidMethod:OnChanged(function() CFG.VOID_METHOD = Options.VoidMethod.Value end)

VoidMain:AddDropdown('VoidBypass', { Text = 'Bypass Method', Values = {'None', 'Velocity', 'CFrame only', 'Hybrid', 'Physics Bypass', 'Network Spoof'}, Default = 'Velocity' })
Options.VoidBypass:OnChanged(function() CFG.VOID_BYPASS_MODE = Options.VoidBypass.Value end)

VoidMain:AddSlider('VoidDriftSpeed', { Text = 'Drift Speed', Default = 200, Min = 1, Max = 200, Rounding = 0, Suffix = ' M/s' })
Options.VoidDriftSpeed:OnChanged(function() CFG.VOID_DRIFT_SPEED = Options.VoidDriftSpeed.Value * 1e6 end)

VoidMain:AddSlider('VoidDriftChaos', { Text = 'Drift Chaos', Default = 98, Min = 1, Max = 100, Rounding = 0, Suffix = '%' })
Options.VoidDriftChaos:OnChanged(function() CFG.VOID_DRIFT_CHAOS = Options.VoidDriftChaos.Value * 0.01 end)

VoidMain:AddSlider('VoidYBase', { Text = 'Void Altitude', Default = 1000, Min = 1, Max = 1000, Rounding = 1, Suffix = 'B' })
Options.VoidYBase:OnChanged(function() CFG.VOID_Y_BASE = Options.VoidYBase.Value * 1e12 end)

VoidMain:AddToggle('VoidScramble', { Text = 'Scramble Position', Default = false })
Toggles.VoidScramble:OnChanged(function() CFG.VOID_SCRAMBLE_ENABLED = Toggles.VoidScramble.Value end)

VoidMain:AddSlider('VoidLissA', { Text = 'Lissajous A', Default = 2, Min = 1, Max = 10, Rounding = 1 })
Options.VoidLissA:OnChanged(function() CFG.VOID_LISSAJOUS_A = Options.VoidLissA.Value end)

VoidMain:AddSlider('VoidLissB', { Text = 'Lissajous B', Default = 3, Min = 1, Max = 10, Rounding = 1 })
Options.VoidLissB:OnChanged(function() CFG.VOID_LISSAJOUS_B = Options.VoidLissB.Value end)

VoidEvasion:AddToggle('DesyncEnable', { Text = 'Enable Desync', Default = true })
Toggles.DesyncEnable:OnChanged(function() CFG.DESYNC_ENABLED = Toggles.DesyncEnable.Value end)

VoidEvasion:AddSlider('DesyncTick', { Text = 'Desync Rate', Default = 18, Min = 1, Max = 100, Rounding = 0, Suffix = 'x0.01s' })
Options.DesyncTick:OnChanged(function() CFG.DESYNC_TICK_RATE = Options.DesyncTick.Value * 0.01 end)

VoidEvasion:AddSlider('DesyncRadius', { Text = 'Desync Radius', Default = 22, Min = 1, Max = 100, Rounding = 0, Suffix = ' studs' })
Options.DesyncRadius:OnChanged(function() CFG.DESYNC_SPOOF_RADIUS = Options.DesyncRadius.Value end)

VoidEvasion:AddToggle('VoidEvade', { Text = 'Dodge Enemies', Default = true })
Toggles.VoidEvade:OnChanged(function() CFG.VOID_EVADE_ENABLED = Toggles.VoidEvade.Value end)

VoidEvasion:AddSlider('EvadeRadius', { Text = 'Evasion Radius', Default = 8, Min = 1, Max = 50, Rounding = 1, Suffix = 'B' })
Options.EvadeRadius:OnChanged(function() CFG.VOID_EVADE_RADIUS = Options.EvadeRadius.Value * 1e9 end)

VoidEvasion:AddSlider('EvadeSpeed', { Text = 'Evasion Speed', Default = 6, Min = 1, Max = 50, Rounding = 1, Suffix = 'B' })
Options.EvadeSpeed:OnChanged(function() CFG.VOID_EVADE_SPEED = Options.EvadeSpeed.Value * 1e9 end)

VoidEvasion:AddToggle('GhostingEnable', { Text = 'Enable Ghosting', Default = false })
Toggles.GhostingEnable:OnChanged(function() CFG.VOID_GHOSTING_ENABLED = Toggles.GhostingEnable.Value end)

VoidEvasion:AddSlider('GhostingIntensity', { Text = 'Ghosting Intensity', Default = 50, Min = 1, Max = 100, Rounding = 0, Suffix = '%' })
Options.GhostingIntensity:OnChanged(function() CFG.VOID_GHOSTING_INTENSITY = Options.GhostingIntensity.Value * 0.01 end)

-- ORBIT TAB
local OrbitMain = Tabs.Orbit:AddLeftGroupbox('Orbit Control')
local OrbitAdvanced = Tabs.Orbit:AddRightGroupbox('Advanced Settings')

OrbitMain:AddToggle('OrbitEnable', { Text = 'Enable Orbit', Default = false })
Toggles.OrbitEnable:OnChanged(function() 
    OrbitEnabled = Toggles.OrbitEnable.Value
    CFG.ORBIT_ENABLED = OrbitEnabled 
    toggleOrbit(OrbitEnabled) 
end)
OrbitMain:AddLabel('Hotkey'):AddKeyPicker('OrbitKeybind', { Default = 'L', Mode = 'Toggle', Text = 'Orbit On/Off', MobileButton = IsMobile })
Options.OrbitKeybind:OnClick(function() Toggles.OrbitEnable:SetValue(not Toggles.OrbitEnable.Value) end)

OrbitMain:AddDropdown('OrbitPattern', { Text = 'Orbit Pattern', Values = {'Default', 'Spiral', 'Random', 'Smart', 'Lissajous', 'Helix', 'Figure 8', 'Pulse', 'Lissajous 3D', 'Tornado', 'Butterfly', 'Double Helix', 'Chaotic Sphere', 'Hyper Elliptical', '4D Hypercube', 'Quantum Orbit', 'Adaptive Orbit', 'Predatory Orbit', 'Dimensional Shift'}, Default = 'Default' })
Options.OrbitPattern:OnChanged(function() CFG.ORBIT_MODE = Options.OrbitPattern.Value end)

OrbitMain:AddSlider('OrbitSpeed', { Text = 'Orbit Speed', Default = 50, Min = 0, Max = 100, Rounding = 0, Suffix = ' x0.1' })
Options.OrbitSpeed:OnChanged(function() CFG.ORBIT_SPEED = Options.OrbitSpeed.Value * 0.1 end)

OrbitMain:AddSlider('OrbitJitter', { Text = 'Orbit Jitter', Default = 0, Min = 0, Max = 360, Rounding = 0, Suffix = '°' })
Options.OrbitJitter:OnChanged(function() CFG.ORBIT_JITTER = Options.OrbitJitter.Value end)

OrbitMain:AddSlider('OrbitStability', { Text = 'Orbit Stability', Default = 10, Min = 1, Max = 100, Rounding = 0, Suffix = '%' })
Options.OrbitStability:OnChanged(function() CFG.ORBIT_STABILITY = Options.OrbitStability.Value * 0.1 end)

OrbitMain:AddSlider('HeightOffset', { Text = 'Camera Height', Default = 50, Min = 0, Max = 2000, Rounding = 0, Suffix = 'k studs' })
Options.HeightOffset:OnChanged(function() CFG.HEIGHT_OFFSET = Options.HeightOffset.Value * 1000 end)

OrbitMain:AddSlider('MinRadius', { Text = 'Min Radius', Default = 20, Min = 1, Max = 1000, Rounding = 0, Suffix = 'k' })
Options.MinRadius:OnChanged(function() CFG.MIN_RADIUS = Options.MinRadius.Value * 10000 end)

OrbitMain:AddSlider('MaxRadius', { Text = 'Max Radius', Default = 120, Min = 1, Max = 10000, Rounding = 0, Suffix = 'B' })
Options.MaxRadius:OnChanged(function() CFG.MAX_RADIUS = Options.MaxRadius.Value * 1e8 end)

OrbitAdvanced:AddSlider('LockFOV', { Text = 'Lock FOV', Default = 120, Min = 1, Max = 180, Rounding = 0, Suffix = '°' })
Options.LockFOV:OnChanged(function() CFG.LOCK_FOV = Options.LockFOV.Value end)

OrbitAdvanced:AddSlider('LockSmooth', { Text = 'Lock Smoothness', Default = 72, Min = 1, Max = 100, Rounding = 0, Suffix = '%' })
Options.LockSmooth:OnChanged(function() CFG.LOCK_SMOOTH_ALPHA = (101 - Options.LockSmooth.Value) * 0.01 end)

OrbitAdvanced:AddSlider('Prediction', { Text = 'Orbit Prediction', Default = 22, Min = 1, Max = 100, Rounding = 0, Suffix = '%' })
Options.Prediction:OnChanged(function() CFG.PREDICTION = Options.Prediction.Value * 0.01 end)

OrbitAdvanced:AddToggle('AutoLock', { Text = 'Enable Auto Lock', Default = false })
Toggles.AutoLock:OnChanged(function() CFG.AUTO_LOCK = Toggles.AutoLock.Value end)

OrbitAdvanced:AddSlider('AutoLockRadius', { Text = 'Auto Lock Radius', Default = 200, Min = 10, Max = 2000, Rounding = 0, Suffix = ' studs' })
Options.AutoLockRadius:OnChanged(function() CFG.AUTO_LOCK_RADIUS = Options.AutoLockRadius.Value end)

OrbitAdvanced:AddButton('Restore Camera', function() if Humanoid then Camera.CameraSubject = Humanoid Camera.CameraType = Enum.CameraType.Follow end Library:Notify('Camera restored.') end)

OrbitAdvanced:AddButton('Drop Target', function() currentTarget = nil currentTargetScore = -math.huge Library:Notify('Target dropped.') end)

-- ADVANCED COMBO SYSTEM
local comboMode = "Dominance"
local AdvancedCombo = Tabs.Orbit:AddRightGroupbox('Advanced Combo System')

AdvancedCombo:AddToggle('UltimateCombo', { Text = 'Enable Advanced Combo', Default = false, Tooltip = 'Combines void and orbit systems for better performance' })
Toggles.UltimateCombo:OnChanged(function() 
    if Toggles.UltimateCombo.Value then
        comboMode = "Dominance"
        Library:Notify('Advanced Combo System Activated', 3)
    end
end)

AdvancedCombo:AddLabel('Current Mode: ' .. comboMode)
AdvancedCombo:AddButton('Force Predator Mode', function() comboMode = "Predator" Library:Notify('Predator Mode Active', 2) end)
AdvancedCombo:AddButton('Force Quantum Mode', function() comboMode = "Quantum" Library:Notify('Quantum Mode Active', 2) end)
AdvancedCombo:AddButton('Force Ghost Mode', function() comboMode = "Ghost" Library:Notify('Ghost Mode Active', 2) end)
AdvancedCombo:AddButton('Force Dominance Mode', function() comboMode = "Dominance" Library:Notify('Dominance Mode Active', 2) end)
AdvancedCombo:AddLabel('Enemy Detection Active')
AdvancedCombo:AddLabel('Automatically counters enemy movement')

-- ANTI-ORBIT SYSTEM
local AntiOrbitGroup = Tabs.Orbit:AddRightGroupbox('Anti Orbit (Defensive)')

AntiOrbitGroup:AddToggle('AntiOrbitEnable', { Text = 'Enable Anti Orbit', Default = false, Tooltip = 'Breaks enemy target locking and orbit scripts' })
Toggles.AntiOrbitEnable:OnChanged(function() CFG.ANTI_ORBIT_ENABLED = Toggles.AntiOrbitEnable.Value end)

AntiOrbitGroup:AddLabel('Hotkey'):AddKeyPicker('AntiOrbitKeybind', { Default = 'None', Mode = 'Toggle', Text = 'Anti Orbit On/Off', MobileButton = IsMobile })
Options.AntiOrbitKeybind:OnClick(function() Toggles.AntiOrbitEnable:SetValue(not Toggles.AntiOrbitEnable.Value) end)

AntiOrbitGroup:AddDropdown('AntiOrbitMethod', { Text = 'Evasion Method', Values = {'Phase Shift', 'Vector Jitter', 'Elastic Snap', 'Orbital Inverse', 'Helix Evasion', 'Null Point', 'Gravity Well', 'CFrame Scramble', 'Desync Spiral', 'Quantum Flicker', '4D Displacement', 'Ghost Step'}, Default = 'Vector Jitter' })
Options.AntiOrbitMethod:OnChanged(function() CFG.ANTI_ORBIT_METHOD = Options.AntiOrbitMethod.Value end)

AntiOrbitGroup:AddSlider('AntiOrbitIntensity', { Text = 'Intensity', Default = 10, Min = 1, Max = 100, Rounding = 1 })
Options.AntiOrbitIntensity:OnChanged(function() CFG.ANTI_ORBIT_INTENSITY = Options.AntiOrbitIntensity.Value end)

AntiOrbitGroup:AddSlider('AntiOrbitRadius', { Text = 'Evasion Radius', Default = 25, Min = 1, Max = 100, Rounding = 1 })
Options.AntiOrbitRadius:OnChanged(function() CFG.ANTI_ORBIT_RADIUS = Options.AntiOrbitRadius.Value end)

AntiOrbitGroup:AddSlider('AntiOrbitSpeed', { Text = 'Evasion Speed', Default = 15, Min = 1, Max = 100, Rounding = 1 })
Options.AntiOrbitSpeed:OnChanged(function() CFG.ANTI_ORBIT_SPEED = Options.AntiOrbitSpeed.Value end)

-- ADDITIONAL VOID FEATURES
local VoidAdvanced = Tabs.Void:AddLeftGroupbox('Advanced Void Settings')

VoidAdvanced:AddSlider('VoidYDrift', { Text = 'Y Drift Range', Default = 10, Min = 0, Max = 10, Rounding = 1, Suffix = 'B' })
Options.VoidYDrift:OnChanged(function() CFG.VOID_Y_DRIFT_RANGE = Options.VoidYDrift.Value * 1e9 end)

VoidAdvanced:AddSlider('ScrambleTime', { Text = 'Scramble Interval', Default = 12, Min = 1, Max = 100, Rounding = 0, Suffix = 'x0.1s' })
Options.ScrambleTime:OnChanged(function() CFG.VOID_SCRAMBLE_TIME = Options.ScrambleTime.Value * 0.1 end)

VoidAdvanced:AddSlider('VoidFlickerInt', { Text = 'Flicker Interval', Default = 5, Min = 1, Max = 50, Rounding = 0, Suffix = 'ms' })
Options.VoidFlickerInt:OnChanged(function() CFG.VOID_FLICKER_INT = Options.VoidFlickerInt.Value * 0.01 end)

VoidAdvanced:AddToggle('EvadeUp', { Text = 'Force Vertical Evasion', Default = false })
Toggles.EvadeUp:OnChanged(function() CFG.VOID_EVADE_FORCE_UP = Toggles.EvadeUp.Value end)

VoidAdvanced:AddSlider('VoidGravityStr', { Text = 'Gravity Well Strength', Default = 100, Min = 1, Max = 1000, Rounding = 0, Suffix = ' M' })
Options.VoidGravityStr:OnChanged(function() CFG.VOID_GRAVITY_STR = Options.VoidGravityStr.Value * 1e6 end)

-- EXTRAS TAB
local ExtrasVisuals = Tabs.Extras:AddLeftGroupbox('Visual Enhancements')
local ExtrasAudio = Tabs.Extras:AddRightGroupbox('Audio & Sound')
local ExtrasPhysics = Tabs.Extras:AddLeftGroupbox('Physics & Performance')

ExtrasPhysics:AddToggle('S2Physics', { Text = 'Simulate S2Physics', Default = true })
Toggles.S2Physics:OnChanged(function() CFG.PHYSICS_S2_SENDER = Toggles.S2Physics.Value setPhysicsFFlags() end)

ExtrasPhysics:AddSlider('PhysicsTPS', { Text = 'Update Rate', Default = 120, Min = 60, Max = 500, Rounding = 0, Suffix = ' Hz' })
Options.PhysicsTPS:OnChanged(function() CFG.PHYSICS_TPS = Options.PhysicsTPS.Value setPhysicsFFlags() end)

ExtrasPhysics:AddToggle('InterpThrottle', { Text = 'Interpolation Throttling', Default = false })
Toggles.InterpThrottle:OnChanged(function() CFG.PHYSICS_INTERP_THROTTLE = Toggles.InterpThrottle.Value setPhysicsFFlags() end)

ExtrasPhysics:AddToggle('NetOwnerV2', { Text = 'Network Owner V2', Default = false })
Toggles.NetOwnerV2:OnChanged(function() CFG.PHYSICS_NET_OWNER_V2 = Toggles.NetOwnerV2.Value setPhysicsFFlags() end)

ExtrasPhysics:AddToggle('PhysicsSleep', { Text = 'Allow Physics Sleep', Default = false })
Toggles.PhysicsSleep:OnChanged(function() CFG.PHYSICS_ALLOW_SLEEP = Toggles.PhysicsSleep.Value setPhysicsFFlags() end)

ExtrasPhysics:AddDropdown('PhysicsThrottle', { Text = 'Environmental Throttle', Values = {'Disabled', 'Default', 'Always'}, Default = 'Disabled' })
Options.PhysicsThrottle:OnChanged(function() CFG.PHYSICS_THROTTLE = Options.PhysicsThrottle.Value setPhysicsFFlags() end)

ExtrasPhysics:AddSlider('SimRate', { Text = 'Simulation Rate', Default = 120, Min = 60, Max = 500, Rounding = 0, Suffix = ' Hz' })
Options.SimRate:OnChanged(function() CFG.PHYSICS_SIM_RATE = Options.SimRate.Value setPhysicsFFlags() end)

ExtrasPhysics:AddToggle('ExtremeNet', { Text = 'Extreme Networking', Default = false })
Toggles.ExtremeNet:OnChanged(function() CFG.PHYSICS_EXTREME_NET = Toggles.ExtremeNet.Value setPhysicsFFlags() end)

ExtrasPhysics:AddToggle('LatencyPatch', { Text = 'Latency Patch (Sub-ms)', Default = false })
Toggles.LatencyPatch:OnChanged(function() CFG.PHYSICS_LATENCY_PATCH = Toggles.LatencyPatch.Value setPhysicsFFlags() end)

ExtrasPhysics:AddToggle('QuantumSync', { Text = 'Quantum Physics Sync', Default = false })
Toggles.QuantumSync:OnChanged(function() CFG.PHYSICS_QUANTUM_SYNC = Toggles.QuantumSync.Value setPhysicsFFlags() end)

ExtrasPhysics:AddDropdown('ReplicationMode', { Text = 'Replication Mode', Values = {'Default', 'High', 'Extreme'}, Default = 'Default' })
Options.ReplicationMode:OnChanged(function() CFG.PHYSICS_REPLICATION_MODE = Options.ReplicationMode.Value setPhysicsFFlags() end)

local darkTexturesLoaded = false
ExtrasVisuals:AddToggle('HitNotifier', { Text = 'Hit Notifier', Default = false, Tooltip = 'Notifies you when you hit someone' }) 
Toggles.HitNotifier:OnChanged(function() CFG.HIT_NOTIFIER_ENABLED = Toggles.HitNotifier.Value end) 

ExtrasVisuals:AddButton('Fps Booster', function()  
    if darkTexturesLoaded then  
        Library:Notify('Dark Textures already loaded!', 2)  
        return  
    end  
    darkTexturesLoaded = true  
    pcall(function()  
        local decalsyeeted = true 
        local g = game  
        local w = g.Workspace  
        local l = g.Lighting  
        local t = w.Terrain  
        t.WaterWaveSize = 0; t.WaterWaveSpeed = 0; t.WaterReflectance = 0; t.WaterTransparency = 0  
        l.GlobalShadows = false; l.FogEnd = 9e9; l.Brightness = 0  
        settings().Rendering.QualityLevel = "Level01"  
        
        -- Optimized batch processing for better performance
        local allDescendants = w:GetDescendants()
        for i = 1, #allDescendants do
            local v = allDescendants[i]
            if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then  
                v.Material = "Plastic"; v.Reflectance = 0
            elseif v:IsA("Decal") or (v:IsA("Texture") and decalsyeeted) then  
                v.Transparency = 1  
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then  
                v.Lifetime = NumberRange.new(0)  
            elseif v:IsA("Explosion") then  
                v.BlastPressure = 1; v.BlastRadius = 1  
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then  
                v.Enabled = false  
            elseif v:IsA("MeshPart") then  
                v.Material = "Plastic"; v.Reflectance = 0; v.TextureID = ""  
            end
            
            -- Yield every 100 objects to prevent freeze
            if i % 100 == 0 then
                task.wait()
            end
        end
        
        -- Optimized lighting effects removal
        local lightingChildren = l:GetChildren()
        for i = 1, #lightingChildren do
            local e = lightingChildren[i]
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then  
                e.Enabled = false  
            end
        end
        
        -- Additional performance optimizations
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Always
        settings().Physics.AllowSleep = true
        if setfflag then
            setfflag("S2PhysicsSenderRate", "30")
            setfflag("PhysicsReplicationRate", "30")
            setfflag("PhysicsSimulationRate", "30")
        end
    end)  
    Library:Notify('FPS Booster loaded! Performance optimized.', 3)  
end)  

local soundChangerLoaded = false  
local selectedSoundName = 'Rust'  

ExtrasAudio:AddDropdown('SoundPreset', { Text = 'Select Sound', Values = soundPresetNames, Default = 'Rust', Tooltip = 'Choose which sound to replace weapon firing sounds with' })  
Options.SoundPreset:OnChanged(function() selectedSoundName = Options.SoundPreset.Value end)  

ExtrasAudio:AddButton('Sound Changer', function()  
    if soundChangerLoaded then Library:Notify('Sound Changer already loaded!', 2) return end  
    soundChangerLoaded = true  
    local chosenId = SoundPresets[selectedSoundName] or 'rbxassetid://4764109000'  
    pcall(function()  
        game:GetService("Players").LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel.ChildAdded:Connect(function(v)  
            if v:IsA("Sound") and v.SoundId ~= "rbxassetid://16537449730" then  
                v.SoundId = chosenId; v.Pitch = 1; v.Volume = 1  
            end  
        end)  
    end)  
    Library:Notify('Sound Changer applied: ' .. selectedSoundName, 3)  
end)  

ExtrasAudio:AddLabel('Select a sound preset from')  
ExtrasAudio:AddLabel('the dropdown, then press')  
ExtrasAudio:AddLabel('"Sound Changer" to apply.')

local ExtrasGameModes = Tabs.Extras:AddRightGroupbox('Game Modes')

ExtrasGameModes:AddButton('FFA Advanced', function()
    pcall(function()
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        local TweenService = game:GetService("TweenService")
        local Player = Players.LocalPlayer

        if game.CreatorId ~= 3461453 then
            Player:Kick("Not Supported game")
            return
        end

        -- ══════════════════════════════════════════════════════
        -- SERVICES & CORE REFERENCES
        -- ══════════════════════════════════════════════════════
        local Camera = workspace.CurrentCamera
        local Heartbeat = RunService.Heartbeat
        local RenderStepped = RunService.RenderStepped

        -- ══════════════════════════════════════════════════════
        -- STATE MANAGEMENT
        -- ══════════════════════════════════════════════════════
        local States = {
            autoHealth = true,
            autoAmmo = true,
            autoRespawn = true,
            fakeHRP = false,
            fakeLag = false,
            desync = false,
            velocityDesync = false,
            hideVoid = false,
            voidAura = false,
            orbitAura = false,
        }

        local Config = {
            desyncOffset = 12,
            orbitRadius = 8,
            orbitSpeed = 3,
            voidDepth = -350,
            velocityPower = 200,
            fakeLagInterval = 0.13,
            voidAuraRange = 35,
        }

        local minimized = false
        local _connections = {}
        local _internal = {
            fakeHRPPart = nil,
            fakeHRPWeld = nil,
            orbitAngle = 0,
            fakeLagTimer = 0,
            fakeLagAnchored = false,
            desyncTick = 0,
            velocityTick = 0,
            savedCFrame = nil,
            voidActive = false,
        }

        -- ══════════════════════════════════════════════════════
        -- UTILITY FUNCTIONS
        -- ══════════════════════════════════════════════════════
        local function getCharacter()
            return Player.Character
        end

        local function getHRP()
            local char = getCharacter()
            return char and char:FindFirstChild("HumanoidRootPart")
        end

        local function getHumanoid()
            local char = getCharacter()
            return char and char:FindFirstChild("Humanoid")
        end

        local function isAlive()
            local hum = getHumanoid()
            return hum and hum.Health > 0
        end

        local function getNearestEnemy(maxDist)
            local hrp = getHRP()
            if not hrp then return nil, nil, math.huge end
            local best, bestChar, bestDist = nil, nil, maxDist or math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    local oHRP = p.Character:FindFirstChild("HumanoidRootPart")
                    local oHum = p.Character:FindFirstChild("Humanoid")
                    if oHRP and oHum and oHum.Health > 0 then
                        local d = (hrp.Position - oHRP.Position).Magnitude
                        if d < bestDist then
                            best = p
                            bestChar = p.Character
                            bestDist = d
                        end
                    end
                end
            end
            return best, bestChar, bestDist
        end

        local function safeSetVelocity(hrp, vel)
            pcall(function()
                hrp.AssemblyLinearVelocity = vel
            end)
        end

        local function safeSetCFrame(part, cf)
            pcall(function()
                part.CFrame = cf
            end)
        end

        -- ══════════════════════════════════════════════════════
        -- FEATURE: FAKE HRP ENGINE
        -- Creates a desync anchor that makes server-side position
        -- differ from client-side position
        -- ══════════════════════════════════════════════════════
        local FakeHRPEngine = {}

        function FakeHRPEngine:Create()
            if _internal.fakeHRPPart then return end
            local hrp = getHRP()
            if not hrp then return end

            local fake = Instance.new("Part")
            fake.Name = "DesyncAnchor"
            fake.Size = Vector3.new(2, 2, 1)
            fake.Transparency = 1
            fake.Anchored = false
            fake.CanCollide = false
            fake.CanTouch = false
            fake.CanQuery = false
            fake.Massless = true
            fake.Parent = workspace

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = hrp
            weld.Part1 = fake
            weld.Parent = fake

            _internal.fakeHRPPart = fake
            _internal.fakeHRPWeld = weld
            _internal.savedCFrame = hrp.CFrame
        end

        function FakeHRPEngine:Update(dt)
            local hrp = getHRP()
            if not hrp or not _internal.fakeHRPPart then return end

            pcall(function()
                local offset = CFrame.new(
                    math.sin(tick() * 2) * Config.desyncOffset,
                    0,
                    math.cos(tick() * 2) * Config.desyncOffset
                )
                _internal.fakeHRPPart.CFrame = hrp.CFrame * offset
            end)
        end

        function FakeHRPEngine:Destroy()
            if _internal.fakeHRPWeld then
                pcall(function() _internal.fakeHRPWeld:Destroy() end)
                _internal.fakeHRPWeld = nil
            end
            if _internal.fakeHRPPart then
                pcall(function() _internal.fakeHRPPart:Destroy() end)
                _internal.fakeHRPPart = nil
            end
            _internal.savedCFrame = nil
        end

        -- ══════════════════════════════════════════════════════
        -- FEATURE: FAKE LAG ENGINE
        -- Simulates network stutter by rapidly toggling HRP anchoring
        -- Other players see you teleporting/stuttering
        -- ══════════════════════════════════════════════════════
        local FakeLagEngine = {}

        function FakeLagEngine:Update(dt)
            local hrp = getHRP()
            if not hrp then return end

            _internal.fakeLagTimer = _internal.fakeLagTimer + dt
            if _internal.fakeLagTimer >= Config.fakeLagInterval then
                _internal.fakeLagTimer = 0
                _internal.fakeLagAnchored = not _internal.fakeLagAnchored
                pcall(function()
                    hrp.Anchored = _internal.fakeLagAnchored
                end)
            end
        end

        function FakeLagEngine:Stop()
            local hrp = getHRP()
            if hrp then
                pcall(function() hrp.Anchored = false end)
            end
            _internal.fakeLagAnchored = false
            _internal.fakeLagTimer = 0
        end

        -- ══════════════════════════════════════════════════════
        -- FEATURE: DESYNC ENGINE
        -- CFrame-based server/client position mismatch
        -- Oscillates the real HRP position while visual stays put
        -- ══════════════════════════════════════════════════════
        local DesyncEngine = {}

        function DesyncEngine:Update(dt)
            local hrp = getHRP()
            if not hrp then return end

            _internal.desyncTick = _internal.desyncTick + dt
            pcall(function()
                local angle = _internal.desyncTick * 3
                local offsetVec = Vector3.new(
                    math.sin(angle) * Config.desyncOffset,
                    math.sin(angle * 1.5) * 2,
                    math.cos(angle) * Config.desyncOffset
                )
                local pulseVel = offsetVec * 15
                hrp.AssemblyLinearVelocity = Vector3.new(pulseVel.X, hrp.AssemblyLinearVelocity.Y, pulseVel.Z)
                task.delay(0.03, function()
                    if hrp and hrp.Parent and States.desync then
                        hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                    end
                end)
            end)
        end

        function DesyncEngine:Stop()
            _internal.desyncTick = 0
            local hrp = getHRP()
            if hrp then
                safeSetVelocity(hrp, Vector3.new(0, 0, 0))
            end
        end

        -- ══════════════════════════════════════════════════════
        -- FEATURE: VELOCITY DESYNC ENGINE
        -- Applies randomized high-velocity bursts for
        -- unpredictable server-side position jitter
        -- ══════════════════════════════════════════════════════
        local VelocityDesyncEngine = {}

        function VelocityDesyncEngine:Update(dt)
            local hrp = getHRP()
            if not hrp then return end

            _internal.velocityTick = _internal.velocityTick + dt
            if _internal.velocityTick >= 0.06 then
                _internal.velocityTick = 0
                pcall(function()
                    local rx = (math.random() - 0.5) * 2
                    local rz = (math.random() - 0.5) * 2
                    local dir = Vector3.new(rx, 0, rz).Unit
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        dir.X * Config.velocityPower,
                        hrp.AssemblyLinearVelocity.Y,
                        dir.Z * Config.velocityPower
                    )
                    task.delay(0.03, function()
                        if hrp and hrp.Parent and States.velocityDesync then
                            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                        end
                    end)
                end)
            end
        end

        function VelocityDesyncEngine:Stop()
            _internal.velocityTick = 0
            local hrp = getHRP()
            if hrp then
                safeSetVelocity(hrp, Vector3.new(0, 0, 0))
            end
        end

        -- ══════════════════════════════════════════════════════
        -- FEATURE: HIDE VOID ENGINE
        -- Teleports character below the map to become invisible
        -- Maintains X/Z position while Y is set to void depth
        -- ══════════════════════════════════════════════════════
        local HideVoidEngine = {}

        function HideVoidEngine:Update(dt)
            local hrp = getHRP()
            if not hrp then return end

            pcall(function()
                local pos = hrp.Position
                if pos.Y > Config.voidDepth + 10 then
                    hrp.CFrame = CFrame.new(pos.X, Config.voidDepth, pos.Z) * (hrp.CFrame - hrp.CFrame.Position)
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            end)
        end

        function HideVoidEngine:Stop()
            local hrp = getHRP()
            if hrp then
                pcall(function()
                    hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z) * (hrp.CFrame - hrp.CFrame.Position)
                end)
            end
        end

        -- ══════════════════════════════════════════════════════
        -- FEATURE: VOID AURA ENGINE
        -- Sends nearby enemy players below the map
        -- Uses network ownership to push targets into void
        -- ══════════════════════════════════════════════════════
        local VoidAuraEngine = {}

        function VoidAuraEngine:Update(dt)
            local hrp = getHRP()
            if not hrp then return end

            pcall(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character then
                        local oHRP = p.Character:FindFirstChild("HumanoidRootPart")
                        local oHum = p.Character:FindFirstChild("Humanoid")
                        if oHRP and oHum and oHum.Health > 0 then
                            local dist = (hrp.Position - oHRP.Position).Magnitude
                            if dist <= Config.voidAuraRange then
                                pcall(function()
                                    oHRP.CFrame = CFrame.new(oHRP.Position.X, Config.voidDepth, oHRP.Position.Z)
                                    oHRP.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
                                end)
                            end
                        end
                    end
                end
            end)
        end

        -- ══════════════════════════════════════════════════════
        -- FEATURE: ORBIT AURA ENGINE
        -- Smoothly orbits around the nearest enemy player
        -- Maintains configurable radius and speed
        -- ══════════════════════════════════════════════════════
        local OrbitAuraEngine = {}

        function OrbitAuraEngine:Update(dt)
            local hrp = getHRP()
            if not hrp then return end

            local enemy, enemyChar, dist = getNearestEnemy()
            if not enemy or not enemyChar then return end

            local targetHRP = enemyChar:FindFirstChild("HumanoidRootPart")
            if not targetHRP then return end

            _internal.orbitAngle = _internal.orbitAngle + (dt * Config.orbitSpeed)
            if _internal.orbitAngle > math.pi * 2 then
                _internal.orbitAngle = _internal.orbitAngle - math.pi * 2
            end

            pcall(function()
                local ox = math.cos(_internal.orbitAngle) * Config.orbitRadius
                local oz = math.sin(_internal.orbitAngle) * Config.orbitRadius
                local targetPos = targetHRP.Position + Vector3.new(ox, 0, oz)
                local lookAt = targetHRP.Position
                hrp.CFrame = CFrame.new(targetPos, Vector3.new(lookAt.X, targetPos.Y, lookAt.Z))
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
        end

        function OrbitAuraEngine:Stop()
            _internal.orbitAngle = 0
        end

        -- ══════════════════════════════════════════════════════
        -- AUTO RESPAWN HANDLER
        -- ══════════════════════════════════════════════════════
        table.insert(_connections, Player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                if not States.autoRespawn then return end
                -- Clean up features on death
                FakeHRPEngine:Destroy()
                FakeLagEngine:Stop()
                DesyncEngine:Stop()
                VelocityDesyncEngine:Stop()

                task.spawn(function()
                    while States.autoRespawn do
                        local char = Player.Character
                        if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                            break
                        end
                        pcall(keypress, 0x20)
                        task.wait(0.1)
                        pcall(keyrelease, 0x20)
                        task.wait(0.1)
                    end
                end)
            end)
        end))

        -- ══════════════════════════════════════════════════════
        -- GUI CONSTRUCTION
        -- ══════════════════════════════════════════════════════
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FFA_Advanced"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = game:GetService("CoreGui")

        -- Main Frame
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 300, 0, 0)
        mainFrame.Position = UDim2.new(0, 20, 0, 50)
        mainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        mainFrame.BorderSizePixel = 0
        mainFrame.ClipsDescendants = true
        mainFrame.Parent = screenGui
        Instance.new("UIDragDetector", mainFrame)

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 8)
        mainCorner.Parent = mainFrame

        local mainStroke = Instance.new("UIStroke")
        mainStroke.Color = Color3.fromRGB(80, 40, 120)
        mainStroke.Thickness = 1.5
        mainStroke.Transparency = 0.3
        mainStroke.Parent = mainFrame

        -- Title Bar
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 42)
        titleBar.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        titleBar.BorderSizePixel = 0
        titleBar.ZIndex = 2
        titleBar.Parent = mainFrame

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 8)
        titleCorner.Parent = titleBar

        local titlePatch = Instance.new("Frame")
        titlePatch.Size = UDim2.new(1, 0, 0, 8)
        titlePatch.Position = UDim2.new(0, 0, 1, -8)
        titlePatch.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        titlePatch.BorderSizePixel = 0
        titlePatch.ZIndex = 2
        titlePatch.Parent = titleBar

        -- Accent line under title
        local accentLine = Instance.new("Frame")
        accentLine.Size = UDim2.new(1, -20, 0, 2)
        accentLine.Position = UDim2.new(0, 10, 1, -1)
        accentLine.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
        accentLine.BorderSizePixel = 0
        accentLine.ZIndex = 3
        accentLine.Parent = titleBar

        local accentGradient = Instance.new("UIGradient")
        accentGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 30, 200)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 60, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 30, 200)),
        })
        accentGradient.Parent = accentLine

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -100, 1, 0)
        titleLabel.Position = UDim2.new(0, 14, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "FFA Advanced Panel"
        titleLabel.TextColor3 = Color3.fromRGB(200, 140, 255)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.ZIndex = 3
        titleLabel.Parent = titleBar

        -- Minimize Button
        local minBtn = Instance.new("TextButton")
        minBtn.Size = UDim2.new(0, 30, 0, 26)
        minBtn.Position = UDim2.new(1, -70, 0.5, -13)
        minBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        minBtn.Text = "—"
        minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        minBtn.Font = Enum.Font.GothamBold
        minBtn.TextSize = 14
        minBtn.BorderSizePixel = 0
        minBtn.ZIndex = 3
        minBtn.Parent = titleBar
        Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

        -- Close Button
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 30, 0, 26)
        closeBtn.Position = UDim2.new(1, -36, 0.5, -13)
        closeBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.TextSize = 12
        closeBtn.BorderSizePixel = 0
        closeBtn.ZIndex = 3
        closeBtn.Parent = titleBar
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

        -- Scroll Frame for Content
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -16, 1, -52)
        scrollFrame.Position = UDim2.new(0, 8, 0, 48)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(120, 50, 180)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scrollFrame.Parent = mainFrame

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 5)
        listLayout.FillDirection = Enum.FillDirection.Vertical
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = scrollFrame

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingRight = UDim.new(0, 4)
        contentPadding.Parent = scrollFrame

        -- Dynamic sizing
        local maxHeight = 520
        local function updateSize()
            local h = listLayout.AbsoluteContentSize.Y + 62
            if h > maxHeight then h = maxHeight end
            mainFrame.Size = UDim2.new(0, 300, 0, h)
        end
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)

        local orderIndex = 0
        local function nextOrder()
            orderIndex = orderIndex + 1
            return orderIndex
        end

        -- ══════════════════════════════════════════════════════
        -- GUI WIDGET BUILDERS
        -- ══════════════════════════════════════════════════════

        -- Section Header
        local function createSection(name, icon)
            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 28)
            header.BackgroundColor3 = Color3.fromRGB(20, 16, 28)
            header.BorderSizePixel = 0
            header.LayoutOrder = nextOrder()
            header.Parent = scrollFrame
            Instance.new("UICorner", header).CornerRadius = UDim.new(0, 5)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -12, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = (icon or "⚡") .. "  " .. string.upper(name)
            label.TextColor3 = Color3.fromRGB(140, 90, 220)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = header
        end

        -- Toggle Widget
        local function createToggle(name, default, callback)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 38)
            row.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
            row.BorderSizePixel = 0
            row.LayoutOrder = nextOrder()
            row.Parent = scrollFrame
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.65, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 12, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.fromRGB(210, 210, 220)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 13
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = row

            local toggleBg = Instance.new("Frame")
            toggleBg.Size = UDim2.new(0, 42, 0, 20)
            toggleBg.Position = UDim2.new(1, -52, 0.5, -10)
            toggleBg.BackgroundColor3 = default and Color3.fromRGB(120, 50, 180) or Color3.fromRGB(45, 45, 55)
            toggleBg.BorderSizePixel = 0
            toggleBg.Parent = row
            Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.Parent = toggleBg
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local state = default
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = row

            btn.MouseButton1Click:Connect(function()
                state = not state
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(toggleBg, tweenInfo, {
                    BackgroundColor3 = state and Color3.fromRGB(120, 50, 180) or Color3.fromRGB(45, 45, 55)
                }):Play()
                TweenService:Create(knob, tweenInfo, {
                    Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
                }):Play()
                callback(state)
            end)

            return function() return state end
        end

        -- Slider Widget
        local function createSlider(name, min, max, default, step, callback)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 50)
            container.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
            container.BorderSizePixel = 0
            container.LayoutOrder = nextOrder()
            container.Parent = scrollFrame
            Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.6, 0, 0, 20)
            nameLabel.Position = UDim2.new(0, 12, 0, 4)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = name
            nameLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = container

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0.35, 0, 0, 20)
            valueLabel.Position = UDim2.new(0.65, -4, 0, 4)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = Color3.fromRGB(160, 100, 240)
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 12
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = container

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -24, 0, 6)
            track.Position = UDim2.new(0, 12, 0, 32)
            track.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            track.BorderSizePixel = 0
            track.Parent = container
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            local pct = (default - min) / (max - min)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(120, 50, 180)
            fill.BorderSizePixel = 0
            fill.Parent = track
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local fillGradient = Instance.new("UIGradient")
            fillGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 30, 200)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 60, 255)),
            })
            fillGradient.Parent = fill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new(pct, -7, 0.5, -7)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 2
            knob.Parent = track
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local trackBtn = Instance.new("TextButton")
            trackBtn.Size = UDim2.new(1, 0, 1, 16)
            trackBtn.Position = UDim2.new(0, 0, 0, -8)
            trackBtn.BackgroundTransparency = 1
            trackBtn.Text = ""
            trackBtn.ZIndex = 3
            trackBtn.Parent = track

            local function updateSlider(inputX)
                local trackPos = track.AbsolutePosition.X
                local trackSize = track.AbsoluteSize.X
                local relX = math.clamp((inputX - trackPos) / trackSize, 0, 1)
                local rawVal = min + (max - min) * relX
                local steppedVal = math.floor(rawVal / step + 0.5) * step
                steppedVal = math.clamp(steppedVal, min, max)
                local newPct = (steppedVal - min) / (max - min)
                fill.Size = UDim2.new(newPct, 0, 1, 0)
                knob.Position = UDim2.new(newPct, -7, 0.5, -7)
                valueLabel.Text = tostring(steppedVal)
                callback(steppedVal)
            end

            trackBtn.MouseButton1Down:Connect(function()
                dragging = true
            end)

            table.insert(_connections, UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end))

            table.insert(_connections, UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end))

            trackBtn.MouseButton1Click:Connect(function()
                local mouse = Player:GetMouse()
                updateSlider(mouse.X)
            end)
        end

        -- ══════════════════════════════════════════════════════
        -- BUILD UI ELEMENTS
        -- ══════════════════════════════════════════════════════

        -- COLLECTION SECTION
        createSection("Collection", "📦")
        createToggle("Auto Health", true, function(v) States.autoHealth = v end)
        createToggle("Auto Ammo", true, function(v) States.autoAmmo = v end)
        createToggle("Auto Respawn", true, function(v) States.autoRespawn = v end)

        -- DESYNC SECTION
        createSection("Desync", "⚡")
        createToggle("Fake HRP", false, function(v)
            States.fakeHRP = v
            if not v then FakeHRPEngine:Destroy() end
        end)
        createToggle("Fake Lag", false, function(v)
            States.fakeLag = v
            if not v then FakeLagEngine:Stop() end
        end)
        createToggle("Desync", false, function(v)
            States.desync = v
            if not v then DesyncEngine:Stop() end
        end)
        createToggle("Velocity Desync", false, function(v)
            States.velocityDesync = v
            if not v then VelocityDesyncEngine:Stop() end
        end)
        createSlider("Desync Offset", 2, 30, 12, 1, function(v) Config.desyncOffset = v end)
        createSlider("V-Desync Power", 50, 500, 200, 10, function(v) Config.velocityPower = v end)
        createSlider("Fake Lag Delay", 0.05, 0.5, 0.13, 0.01, function(v) Config.fakeLagInterval = v end)

        -- VOID SECTION
        createSection("Void", "🕳️")
        createToggle("Hide Void", false, function(v)
            States.hideVoid = v
            if not v then HideVoidEngine:Stop() end
        end)
        createToggle("Void Aura", false, function(v)
            States.voidAura = v
        end)
        createSlider("Void Depth", -1000, -100, -350, 10, function(v) Config.voidDepth = v end)
        createSlider("Void Aura Range", 10, 80, 35, 1, function(v) Config.voidAuraRange = v end)

        -- COMBAT SECTION
        createSection("Combat", "⚔️")
        createToggle("Orbit Aura", false, function(v)
            States.orbitAura = v
            if not v then OrbitAuraEngine:Stop() end
        end)
        createSlider("Orbit Radius", 3, 20, 8, 1, function(v) Config.orbitRadius = v end)
        createSlider("Orbit Speed", 1, 10, 3, 0.5, function(v) Config.orbitSpeed = v end)

        -- Initial size
        task.defer(updateSize)

        -- ══════════════════════════════════════════════════════
        -- TITLE BAR CONTROLS
        -- ══════════════════════════════════════════════════════
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            scrollFrame.Visible = not minimized
            if minimized then
                mainFrame.Size = UDim2.new(0, 300, 0, 42)
                minBtn.Text = "+"
            else
                updateSize()
                minBtn.Text = "—"
            end
        end)

        closeBtn.MouseButton1Click:Connect(function()
            -- Clean up all features
            FakeHRPEngine:Destroy()
            FakeLagEngine:Stop()
            DesyncEngine:Stop()
            VelocityDesyncEngine:Stop()
            HideVoidEngine:Stop()
            OrbitAuraEngine:Stop()
            for _, conn in ipairs(_connections) do
                pcall(function() conn:Disconnect() end)
            end
            _connections = {}
            screenGui:Destroy()
        end)

        -- ══════════════════════════════════════════════════════
        -- MAIN RENDER LOOP
        -- Core engine loop that dispatches to all active features
        -- ══════════════════════════════════════════════════════
        local t = 0
        local mainLoop = RenderStepped:Connect(function(dt)
            local character = Player.Character
            if not character then return end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end

            t = t + dt

            -- ── Auto Collect ──
            local bounce = math.sin(t * 8) * 4
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name == "_drop" and obj:IsA("BasePart") then
                    if (States.autoAmmo and obj:FindFirstChild("Ammo")) or
                       (States.autoHealth and obj:FindFirstChild("Health")) then
                        pcall(function()
                            obj.Anchored = true
                            obj.CFrame = CFrame.new(hrp.Position + Vector3.new(0, bounce, 0))
                            obj.Transparency = 1
                            for _, child in pairs(obj:GetDescendants()) do
                                if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("MeshPart") or child:IsA("SpecialMesh") then
                                    pcall(function() child.Transparency = 1 end)
                                end
                                if child:IsA("BillboardGui") or child:IsA("SurfaceGui") or child:IsA("ParticleEmitter") or child:IsA("SelectionBox") then
                                    pcall(function() child.Enabled = false end)
                                end
                            end
                        end)
                    end
                end
            end

            -- ── Feature Engines ──
            if States.fakeHRP then FakeHRPEngine:Update(dt) end
            if States.fakeLag then FakeLagEngine:Update(dt) end
            if States.desync then DesyncEngine:Update(dt) end
            if States.velocityDesync then VelocityDesyncEngine:Update(dt) end
            if States.hideVoid then HideVoidEngine:Update(dt) end
            if States.voidAura then VoidAuraEngine:Update(dt) end
            if States.orbitAura then OrbitAuraEngine:Update(dt) end
        end)
        table.insert(_connections, mainLoop)

        Library:Notify('FFA Advanced Panel loaded!', 3)
    end)
end)

ExtrasGameModes:AddLabel('Opens the FFA Advanced Panel')
ExtrasGameModes:AddLabel('with Desync, Void, Orbit &')
ExtrasGameModes:AddLabel('Collection features + sliders.')

-- UI SETTINGS TAB
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
local UISettings = Tabs['UI Settings']:AddRightGroupbox('Settings')
local MobileSettings = Tabs['UI Settings']:AddLeftGroupbox('Mobile Settings')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Open / Close Menu', MobileButton = IsMobile })  
Library.ToggleKeybind = Options.MenuKeybind  

UISettings:AddToggle('Watermark', { Text = 'Show Watermark', Default = false })
Toggles.Watermark:OnChanged(function() Library:SetWatermarkVisibility(Toggles.Watermark.Value) end)

UISettings:AddToggle('KeybindList', { Text = 'Show Keybind List', Default = false })
Toggles.KeybindList:OnChanged(function() Library.KeybindFrame.Visible = Toggles.KeybindList.Value end)

-- Mobile-specific settings
MobileSettings:AddToggle('MobileMode', { Text = 'Mobile Mode Active', Default = IsMobile, Disabled = true })
MobileSettings:AddLabel('Device: ' .. (IsMobile and 'Mobile Device' or 'Desktop/Console'))
MobileSettings:AddSlider('MobileScale', { Text = 'UI Scale', Default = MobileScale * 100, Min = 100, Max = 200, Rounding = 0, Suffix = '%' })
Options.MobileScale:OnChanged(function() 
    CFG.MOBILE_SCALE = Options.MobileScale.Value * 0.01
    Library:Notify('Scale applied: ' .. Options.MobileScale.Value .. '% (Restart script to fully apply)', 3)
end)

MobileSettings:AddSlider('MobilePadding', { Text = 'Touch Padding', Default = CFG.MOBILE_TOUCH_PADDING, Min = 0, Max = 20, Rounding = 0, Suffix = ' px' })
Options.MobilePadding:OnChanged(function() CFG.MOBILE_TOUCH_PADDING = Options.MobilePadding.Value end)

MobileSettings:AddToggle('MobileButtons', { Text = 'Show Mobile Toggle Buttons', Default = IsMobile, Tooltip = 'Show on-screen buttons for keybinds on mobile devices' })
Toggles.MobileButtons:OnChanged(function() CFG.MOBILE_BUTTONS_ENABLED = Toggles.MobileButtons.Value end)

Library:SetWatermarkVisibility(false)  

Library:OnUnload(function()  
    if OrbitEnabled then OrbitEnabled = false toggleOrbit(false) end  
    if VoidEnabled then VoidEnabled = false end
    Library.Unloaded = true  
end)  

-- Initialize systems (Auto CFG Load Enabled)
pcall(function()
    ThemeManager:SetLibrary(Library)  
    SaveManager:SetLibrary(Library)  
    SaveManager:IgnoreThemeSettings()  
    SaveManager:SetIgnoreIndexes({'MenuKeybind'})  
    ThemeManager:SetFolder('OrbitScript')  
    SaveManager:SetFolder('OrbitScript')  
    SaveManager:BuildConfigSection(Tabs['UI Settings'])  
    ThemeManager:ApplyToTab(Tabs['UI Settings'])  
    SaveManager:LoadAutoloadConfig() 
    
    -- Restore void and orbit states after config loads
    task.wait(0.1)
    
    if CFG.VOID_ENABLED then
        VoidEnabled = true
        if Toggles.VoidEnable then Toggles.VoidEnable:SetValue(true) end
        Library:Notify('Void System Restored', 2)
    end
    
    if CFG.ORBIT_ENABLED then
        OrbitEnabled = true
        if Toggles.OrbitEnable then Toggles.OrbitEnable:SetValue(true) end
        toggleOrbit(true)
        Library:Notify('Orbit System Restored', 2)
    end
end) -- End pcall

end) -- End UI Setup defer block

-- Apply metatable hook
task.defer(applyNamecallHook)

task.delay(0.5, function()
    print(identifyexecutor() .. " Is Supported")
end)
