-- Carga obligatoria de la librería WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()

-- Inicialización de la ventana (Ajusta el título y tamaño según prefieras)
local Window = WindUI:CreateWindow({
    Title = "Morty Hub v2.6",
    Icon = "rbxassetid://10723343468", -- Puedes cambiar este ID
    Author = "Cypher",
    Size = UDim2.fromOffset(550, 400),
    Folder = "MortyHub",
    Transparent = true,
    Theme = "Dark"
})

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")


-- ── Remotes / Modules ────────────────────────────────────────
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local Util, BuyPromptUI, EmotesUI, EmotesList, CoreUI, CharModule, Net, Items, MeleeItems, CrateController
pcall(function() Util            = require(ReplicatedStorage.Modules.Core.Util) end)
pcall(function() BuyPromptUI     = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI) end)
pcall(function() EmotesUI        = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI) end)
pcall(function() EmotesList      = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList) end)
pcall(function() CoreUI          = require(ReplicatedStorage.Modules.Core.UI) end)
pcall(function() CharModule      = require(ReplicatedStorage.Modules.Core.Char) end)
pcall(function() Net             = require(ReplicatedStorage.Modules.Core.Net) end)
pcall(function() Items           = ReplicatedStorage:WaitForChild("Items", 5) end)
pcall(function() if Items then MeleeItems = Items:WaitForChild("melee", 5) end end)
pcall(function() CrateController = require(ReplicatedStorage.Modules.Game.CrateSystem.Crate) end)

-- ── Local Player ──────────────────────────────────────────────
print("Morty Hub Leaked by Cypher https://discord.gg/b8QsvrMCNq")

-- FIX PARA DELTA (agrega aquí)
pcall(function() game:GetService("ScriptContext"):SetTimeout(0.2) end)

local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HRP = newChar:WaitForChild("HumanoidRootPart")
    Backpack = LocalPlayer:WaitForChild("Backpack")
    if hideNameEnabled then applyHideNameToCharacter(newChar) end
end)

-- ── Misc Setup ───────────────────────────────────────────────
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local DroppedItems = Workspace:WaitForChild("DroppedItems")
local itemDrawings = {}
local espData = {}
local positionHistory = {}
local WeaponRegistry = {}
local PlayerBillboards = {}
local excludedPlayers = {}
local itemPickupTrack = {}
local originalAttribs = {}

local RarityColors = {
    Common   = Color3.fromRGB(255, 255, 255),
    Uncommon = Color3.fromRGB(99, 255, 52),
    Rare     = Color3.fromRGB(51, 170, 255),
    Epic     = Color3.fromRGB(237, 44, 255),
    Legendary= Color3.fromRGB(255, 150, 0),
    Omega    = Color3.fromRGB(255, 20, 51),
}

-- ── State Variables ──────────────────────────────────────────
local silentAimEnabled    = false
local fovRadius           = 120
local aimTarget           = nil
local nameESPEnabled      = false
local distanceESPEnabled  = false
local healthESPEnabled    = false
local inventoryESPEnabled = false
local droppedESPEnabled   = false
local jumpPowerEnabled    = false
local infiniteStaminaEnabled = false
local antiLockEnabled     = false
local antiKillEnabled     = false
local autoPickupEnabled   = false
local antiRagdollEnabled  = false
local meleeAuraEnabled    = false
local autoAttackEnabled   = false
local skipCrateEnabled    = false
local snapUnderMapEnabled = false
local snapActive          = false
local snapDepth           = 10
local underMapPos         = nil
local isFlickering        = false
local autoMinigameEnabled = false
local bumpAuraEnabled     = false
local hackerESPEnabled    = false
local fpsBoostEnabled     = false
local desyncEnabled       = false
local hideNameEnabled     = false
spectateEnabled = false
spectateTarget = nil
spectateConn = nil

-- ══════════════════════════════════════════════════════════════
--  SKIP ANIMATION (SIEMPRE ACTIVO)
-- ══════════════════════════════════════════════════════════════
local origTween
pcall(function()
    if Util and Util.tween then
        origTween = Util.tween
        Util.tween = function(obj, info, target)
            if obj and obj:IsA("NumberValue") and target and target.Value ~= nil then
                obj.Value = target.Value
                return { Cancel = function() end }
            end
            return origTween(obj, info, target)
        end
    end
end)

local function setupInstantSell()
    if not BuyPromptUI then return end
    local ok, sellBtn = pcall(function() return BuyPromptUI.get("SellPromptSellButton") end)
    if not ok or not sellBtn then return end
    local holdStroke = sellBtn:FindFirstChild("HoldStroke", true)
    if holdStroke then
        holdStroke.Enabled = false
        local grad = holdStroke:FindFirstChildOfClass("UIGradient")
        if grad then grad.Enabled = false end
    end
    for _, v in pairs(sellBtn:GetDescendants()) do
        if v:IsA("NumberValue") then v.Value = 1 end
    end
end

pcall(function()
    local BuyPromptUIModule = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI)
    if BuyPromptUIModule.loaded then
        local old_loaded = BuyPromptUIModule.loaded
        BuyPromptUIModule.loaded = function(...)
            local result = old_loaded(...)
            task.spawn(function() task.wait(0.1); setupInstantSell() end)
            return result
        end
    end
end)

task.spawn(function() task.wait(0.5); setupInstantSell() end)

pcall(function()
    local UtilModule = require(ReplicatedStorage.Modules.Core.Util)
    if UtilModule.tween then
        local old_tween = UtilModule.tween
        UtilModule.tween = function(instance, tweenInfo, properties, ...)
            if instance:IsA("NumberValue") and properties.Value == 1 then
                if tweenInfo.Time > 0 then
                    tweenInfo = TweenInfo.new(0, tweenInfo.EasingStyle, tweenInfo.EasingDirection, tweenInfo.RepeatCount, tweenInfo.Reverses, tweenInfo.DelayTime)
                end
            end
            return old_tween(instance, tweenInfo, properties, ...)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  FPS BOOST MEJORADO
-- ══════════════════════════════════════════════════════════════
local fpsBoostOriginals = {}

local function applyFpsBoost()
    local Lighting = game:GetService("Lighting")
    local Terrain = Workspace.Terrain

    fpsBoostOriginals.GlobalShadows   = Lighting.GlobalShadows
    fpsBoostOriginals.ShadowSoftness  = Lighting.ShadowSoftness
    fpsBoostOriginals.FogEnd          = Lighting.FogEnd
    fpsBoostOriginals.FogStart        = Lighting.FogStart
    fpsBoostOriginals.Brightness      = Lighting.Brightness
    fpsBoostOriginals.AmbientColor    = Lighting.Ambient
    fpsBoostOriginals.ClockTime       = Lighting.ClockTime
    fpsBoostOriginals.GlobalWind      = Workspace.GlobalWind
    fpsBoostOriginals.WaterWaveSpeed  = Terrain.WaterWaveSpeed
    fpsBoostOriginals.WaterReflectance = Terrain.WaterReflectance
    fpsBoostOriginals.Decoration      = Terrain.Decoration
    fpsBoostOriginals.effects         = {}
    fpsBoostOriginals.parts           = {}
    fpsBoostOriginals.particles       = {}
    fpsBoostOriginals.textures        = {}
    fpsBoostOriginals.fidelity        = {}

    Lighting.GlobalShadows  = false
    Lighting.ShadowSoftness = 0
    Lighting.FogEnd   = 100000
    Lighting.FogStart = 100000
    Lighting.Brightness = 0.4
    Lighting.Ambient = Color3.fromRGB(60,60,60)
    Lighting.ClockTime = 10
    Workspace.GlobalWind = Vector3.zero
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.Decoration = false

    for _, obj in ipairs(Lighting:GetDescendants()) do
        if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("Sky") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") then
            fpsBoostOriginals.effects[obj] = obj.Enabled
            pcall(function() obj.Enabled = false end)
        end
    end
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function() settings().Rendering.EagerBulkExecution = true end)
    pcall(function() Workspace.StreamingEnabled = true end)

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            fpsBoostOriginals.parts[v] = v.CastShadow
            pcall(function() v.CastShadow = false end)
            pcall(function() v.RenderFidelity = Enum.RenderFidelity.Performance end)
            if v:IsA("MeshPart") then
                pcall(function() sethiddenproperty(v, "LevelOfDetail", 0) end)
            end
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") then
            fpsBoostOriginals.particles[v] = v.Enabled
            pcall(function() v.Enabled = false end)
            if v:IsA("ParticleEmitter") then
                pcall(function() v.Rate = 0 end)
                pcall(function() v.LightEmission = 0 end)
            end
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
            fpsBoostOriginals.textures[v] = v.Transparency
            pcall(function() v.Transparency = 1 end)
        elseif v:IsA("SpecialMesh") then
            fpsBoostOriginals.fidelity[v] = v.Scale
            pcall(function() v.Scale = v.Scale * Vector3.new(1,1,1) end)
        end
    end

    for _, gui in ipairs(Workspace:GetDescendants()) do
        if gui:IsA("SurfaceGui") then
            pcall(function() gui.Enabled = false end)
        end
    end

    local fpsCap = 144
    pcall(function() setfpscap(fpsCap) end)
    pcall(function() syn.setfpscap(fpsCap) end)
    pcall(function() fluxus.setfpscap(fpsCap) end)
end

local function removeFpsBoost()
    local Lighting = game:GetService("Lighting")
    local Terrain = Workspace.Terrain

    if fpsBoostOriginals.GlobalShadows  ~= nil then Lighting.GlobalShadows  = fpsBoostOriginals.GlobalShadows end
    if fpsBoostOriginals.ShadowSoftness ~= nil then Lighting.ShadowSoftness = fpsBoostOriginals.ShadowSoftness end
    if fpsBoostOriginals.FogEnd   ~= nil then Lighting.FogEnd   = fpsBoostOriginals.FogEnd end
    if fpsBoostOriginals.FogStart ~= nil then Lighting.FogStart = fpsBoostOriginals.FogStart end
    if fpsBoostOriginals.Brightness ~= nil then Lighting.Brightness = fpsBoostOriginals.Brightness end
    if fpsBoostOriginals.AmbientColor ~= nil then Lighting.Ambient = fpsBoostOriginals.AmbientColor end
    if fpsBoostOriginals.ClockTime ~= nil then Lighting.ClockTime = fpsBoostOriginals.ClockTime end
    if fpsBoostOriginals.GlobalWind ~= nil then Workspace.GlobalWind = fpsBoostOriginals.GlobalWind end
    if fpsBoostOriginals.WaterWaveSpeed ~= nil then Terrain.WaterWaveSpeed = fpsBoostOriginals.WaterWaveSpeed end
    if fpsBoostOriginals.WaterReflectance ~= nil then Terrain.WaterReflectance = fpsBoostOriginals.WaterReflectance end
    if fpsBoostOriginals.Decoration ~= nil then Terrain.Decoration = fpsBoostOriginals.Decoration end

    if fpsBoostOriginals.effects then for obj, v in pairs(fpsBoostOriginals.effects) do pcall(function() obj.Enabled = v end) end end
    if fpsBoostOriginals.particles then for v, e in pairs(fpsBoostOriginals.particles) do pcall(function() v.Enabled = e end) end end
    if fpsBoostOriginals.textures then for v, t in pairs(fpsBoostOriginals.textures) do pcall(function() v.Transparency = t end) end end
    if fpsBoostOriginals.parts then for v, c in pairs(fpsBoostOriginals.parts) do pcall(function() v.CastShadow = c end) end end
    if fpsBoostOriginals.fidelity then for v, f in pairs(fpsBoostOriginals.fidelity) do pcall(function() if v:IsA("MeshPart") then v.RenderFidelity = f end end) end end

    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    pcall(function() setfpscap(60) end)
    pcall(function() syn.setfpscap(60) end)
    pcall(function() fluxus.setfpscap(60) end)
    fpsBoostOriginals = {}
end

-- ══════════════════════════════════════════════════════════════
--  UTILITY
-- ══════════════════════════════════════════════════════════════
local function getPing()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return 0.2 end
    local stats = gui:FindFirstChild("NetworkStats")
    if not stats then return 0.2 end
    local label = stats:FindFirstChild("PingLabel")
    if not label then return 0.2 end
    local num = tonumber(tostring(label.Text):match("%d+"))
    if not num then return 0.2 end
    local ping = num / 1000
    return (ping < 0 or ping > 2) and 0.2 or ping
end

local function isPlayerExcluded(name)
    for _, entry in ipairs(excludedPlayers) do
        if entry ~= "" and string.find(string.lower(name), string.lower(entry)) then return true end
    end
    return false
end

local Counter
pcall(function()
    for _, v in ipairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "event") and rawget(v, "func") then
            Counter = v; break
        end
    end
end)

local function netGet(...)
    if not Counter or not Counter.func then return end
    local args = { ... }
    for i, v in ipairs(args) do
        if typeof(v) == "Instance" then
            if v:IsA("Model") and #v:GetChildren() == 0 then
                local dropped = Workspace:FindFirstChild("DroppedItems")
                if dropped then
                    local model = dropped:FindFirstChildWhichIsA("Model")
                    if model then args[i] = model else return end
                else return end
            end
        end
    end
    Counter.func = (Counter.func or 0) + 1
    local get = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Get")
    return get:InvokeServer(Counter.func, unpack(args))
end

local Send = {}
function Send.send(...)
    Counter.event = Counter.event + 1
    Remotes.Send:FireServer(Counter.event, ...)
end

-- ══════════════════════════════════════════════════════════════
--  PREDICTION / AIM HELPERS
-- ══════════════════════════════════════════════════════════════
local HISTORY_SIZE = 5

Players.PlayerRemoving:Connect(function(player)
    positionHistory[player] = nil
end)

local function calculateVelocity(player)
    local hist = positionHistory[player]
    if not hist or #hist < 2 then return Vector3.zero end
    local sum, totalWeight = Vector3.zero, 0
    for i = 2, #hist do
        local dt = hist[i].time - hist[i-1].time
        if dt > 0 then
            local vel = (hist[i].pos - hist[i-1].pos) / dt
            local weight = i
            sum = sum + vel * weight
            totalWeight = totalWeight + weight
        end
    end
    if totalWeight == 0 then return Vector3.zero end
    return sum / totalWeight
end

local function predictPosition(part, root)
    if not part then return part.Position end
    local player = part.Parent and Players:GetPlayerFromCharacter(part.Parent)
    local vel = (player and calculateVelocity(player)) or Vector3.zero
    local ping = math.clamp(getPing(), 0.06, 0.20)
    local hSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
    local mult = 1.15
    if hSpeed > 60 then mult = 1.50 elseif hSpeed > 50 then mult = 1.42 elseif hSpeed > 35 then mult = 1.32 elseif hSpeed > 20 then mult = 1.22 elseif hSpeed > 10 then mult = 1.15 end
    if ping > 0.15 then mult = mult * 0.93 end
    local horizontal = Vector3.new(vel.X, 0, vel.Z) * ping * mult
    local vertical   = Vector3.new(0, math.clamp(vel.Y * ping * 0.30, -4, 4), 0)
    local jumpBoost  = Vector3.new(0, vel.Y > 20 and 0.50 or vel.Y > 15 and 0.35 or 0, 0)
    local offset     = Vector3.zero
    if part.Name == "Head" then
        offset = Vector3.new(0, hSpeed > 30 and 0.14 or hSpeed > 22 and 0.10 or 0.05, 0)
    end
    return part.Position + horizontal + vertical + jumpBoost + offset
end

local _rayParams = RaycastParams.new()
_rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function isBehindWall(origin, target)
    if not origin or not target then return false end
    local dir = target - origin
    if dir.Magnitude < 1 then return false end
    local myChar  = LocalPlayer.Character
    local aimChar = aimTarget and aimTarget.Character
    local excl = {}
    if myChar  then excl[#excl+1] = myChar  end
    if aimChar then excl[#excl+1] = aimChar end
    _rayParams.FilterDescendantsInstances = excl
    local result = workspace:Raycast(origin, dir, _rayParams)
    return result ~= nil
end

local function getClosestTarget()
    local best, bestDist = nil, fovRadius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum  = plr.Character:FindFirstChild("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if head and hum and hum.Health > 0 and root then
                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist <= fovRadius and not isPlayerExcluded(plr.Name) and dist < bestDist then
                        bestDist = dist; best = plr
                    end
                end
            end
        end
    end
    return best
end

-- ══════════════════════════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════════════════════════
local fovCircle
if not isMobile then
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Thickness = 2
    fovCircle.NumSides = 64
    fovCircle.Filled = false
    fovCircle.Transparency = 0.4
    fovCircle.Radius = fovRadius
    fovCircle.Visible = false
else
    local fovGui = Instance.new("ScreenGui")
    fovGui.Name = "MobileFOV"; fovGui.ResetOnSpawn = false; fovGui.IgnoreGuiInset = true
    fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.fromOffset(fovRadius*2, fovRadius*2)
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.Position = UDim2.fromScale(0.5, 0.5)
    fovCircle.BackgroundTransparency = 1
    Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", fovCircle)
    stroke.Color = Color3.fromRGB(255,255,255); stroke.Thickness = 2; stroke.Transparency = 0.3
    fovCircle.Parent = fovGui
end

local redLine = Drawing.new("Line")
redLine.Thickness = 1.3; redLine.Color = Color3.fromRGB(255,50,50); redLine.Transparency = 1; redLine.Visible = false
local tracerLines = {}
for i=1,4 do
    tracerLines[i] = Drawing.new("Line")
    tracerLines[i].Color = Color3.fromRGB(255,255,255)
    tracerLines[i].Thickness = 1.2; tracerLines[i].Transparency = 1; tracerLines[i].Visible = false
end

local function hideTracers()
    for i=1,4 do tracerLines[i].Visible = false end
    redLine.Visible = false
end

-- ══════════════════════════════════════════════════════════════
--  SILENT AIM HOOK
-- ══════════════════════════════════════════════════════════════
local SendRemote = Remotes:WaitForChild("Send")
local originalFireServer
pcall(function()
    originalFireServer = hookfunction(SendRemote.FireServer, function(self, ...)
        if self ~= SendRemote then return originalFireServer(self, ...) end
        local args = { ... }
        if silentAimEnabled and args[2] == "shoot_gun" and aimTarget and aimTarget.Character then
            local head = aimTarget.Character:FindFirstChild("Head")
            local root = aimTarget.Character:FindFirstChild("HumanoidRootPart")
            local hum  = aimTarget.Character:FindFirstChild("Humanoid")
            if head and root and hum then
                local aimPos = predictPosition(head, root)
                local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
                local originPos = myHead and myHead.Position or Camera.CFrame.Position
                local function isShotgun()
                    if not Character then return false end
                    for _, tool in ipairs(Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local ammo = tool:GetAttribute("AmmoType")
                            if ammo == "shotgun" or ammo == "shootgun" then return true end
                        end
                    end
                    return false
                end
                if isShotgun() then
                    args[4] = CFrame.new(originPos, aimPos)
                    local pellets = {}
                    for i = 1, 6 do
                        local spread = Vector3.new(math.random(-2,2)*0.03, math.random(-2,2)*0.03, math.random(-2,2)*0.03)
                        table.insert(pellets, { [1] = { Instance = head, Normal = Vector3.new(0,1,0), Position = aimPos + spread }})
                    end
                    args[5] = pellets
                else
                    local wallBlocked = isBehindWall(originPos, aimPos)
                    args[4] = wallBlocked and CFrame.new(math.huge, math.huge, math.huge) or CFrame.new(originPos, aimPos)
                    args[5] = { [1] = { [1] = { Instance = head, Normal = Vector3.new(0,1,0), Position = aimPos }}}
                end
                pcall(function()
                    local beam = Instance.new("Part")
                    beam.Anchored = true; beam.CanCollide = false
                    beam.Size = Vector3.new(0.06, 0.06, (aimPos - originPos).Magnitude)
                    beam.CFrame = CFrame.new(originPos, aimPos) * CFrame.new(0, 0, -beam.Size.Z/2)
                    beam.Material = Enum.Material.Neon; beam.Transparency = 0.35
                    beam.Color = Color3.fromRGB(255, 0, 0); beam.Parent = Workspace
                    Debris:AddItem(beam, 4)
                end)
            end
        end
        return originalFireServer(self, unpack(args))
    end)
end)

-- ══════════════════════════════════════════════════════════════
--  SNAP UNDER MAP
-- ══════════════════════════════════════════════════════════════
local snapThread = nil

local function startSnap()
    if snapThread then return end
    snapThread = task.spawn(function()
        local baseY = nil
        while snapActive do
            task.wait(0.01)
            local char = CharModule and CharModule.get and CharModule.get()
            local hrp  = CharModule and CharModule.get_hrp and CharModule.get_hrp()
            if char and hrp then
                if not baseY then baseY = hrp.Position.Y end
                local targetY = baseY - snapDepth
                local deltaY  = targetY - hrp.Position.Y
                char:PivotTo(hrp.CFrame * CFrame.new(0, deltaY, 0))
            else baseY = nil end
        end
    end)
end

local function stopSnap()
    if snapThread then task.cancel(snapThread); snapThread = nil end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Z and snapUnderMapEnabled then
        snapActive = not snapActive
        if snapActive then startSnap() else stopSnap() end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  BUMP AURA
-- ══════════════════════════════════════════════════════════════
local function bumpVehicles()
    if not bumpAuraEnabled then return end
    local root = HRP; if not root then return end
    local vehicles = Workspace:FindFirstChild("Vehicles"); if not vehicles then return end
    for _, vehicle in ipairs(vehicles:GetChildren()) do
        if vehicle:IsA("Model") then
            local primary = vehicle.PrimaryPart or vehicle:FindFirstChild("Chassis") or vehicle:FindFirstChild("HumanoidRootPart")
            if primary and primary:IsA("BasePart") then
                local dist = (primary.Position - root.Position).Magnitude
                if dist < 15 then
                    local dir = (primary.Position - root.Position).Unit
                    primary:ApplyImpulse(dir * 80 + Vector3.new(0, 50, 0))
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════
--  ESP HACKERS
-- ══════════════════════════════════════════════════════════════
local hackerESPs   = {}
local lastPositions = {}
local flagCounter  = {}

local function createHackerESP(player)
    if hackerESPs[player] then return end
    local char = player.Character
    local head = char and char:FindFirstChild("Head"); if not head then return end
    local bill = Instance.new("BillboardGui")
    bill.Name = "HackerESP"; bill.Size = UDim2.new(0,100,0,30)
    bill.AlwaysOnTop = true; bill.Adornee = head; bill.StudsOffset = Vector3.new(0,2.5,0)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,1,0); frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.BackgroundTransparency = 0.4; frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0); text.BackgroundTransparency = 1
    text.Text = "HACKER"; text.TextColor3 = Color3.fromRGB(255,50,50)
    text.TextScaled = true; text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.5; text.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    text.Parent = frame; frame.Parent = bill; bill.Parent = head
    hackerESPs[player] = bill
end

local function removeHackerESP(player)
    if hackerESPs[player] then hackerESPs[player]:Destroy(); hackerESPs[player] = nil end
end

local VELOCITY_LIMIT = 200
local DETECT_FRAMES  = 5

Players.PlayerRemoving:Connect(function(player)
    removeHackerESP(player); lastPositions[player] = nil; flagCounter[player] = nil
end)

-- ══════════════════════════════════════════════════════════════
--  ESP DE JUGADORES
-- ══════════════════════════════════════════════════════════════
local ESP = {}
local function createESP(player)
    if player == LocalPlayer then return end
    local name = Drawing.new("Text")
    name.Size = 12; name.Center = true; name.Outline = true
    name.Color = Color3.new(1,1,1); name.Visible = false; name.Font = 3
    local info = Drawing.new("Text")
    info.Size = 11; info.Center = true; info.Outline = true
    info.Color = Color3.new(1,1,1); info.Visible = false; info.Font = 3
    local hpBar = Drawing.new("Square")
    hpBar.Filled = true; hpBar.Transparency = 0.9; hpBar.Visible = false
    local hpBg = Drawing.new("Square")
    hpBg.Filled = false; hpBg.Thickness = 1
    hpBg.Color = Color3.fromRGB(0,0,0); hpBg.Transparency = 0.9; hpBg.Visible = false
    ESP[player] = { Name = name, Info = info, HpBar = hpBar, HpBg = hpBg }
end

for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(function(player)
    local data = ESP[player]
    if data then
        if data.Name then data.Name:Remove() end
        if data.Info then data.Info:Remove() end
        if data.HpBar then data.HpBar:Remove() end
        if data.HpBg then data.HpBg:Remove() end
        ESP[player] = nil
    end
end)

-- ══════════════════════════════════════════════════════════════
--  DROPPED ITEMS ESP
-- ══════════════════════════════════════════════════════════════
local _itemRarityCache = {}
local function _buildRarityCache()
    _itemRarityCache = {}
    for _, folder in ipairs(Items:GetChildren()) do
        if folder:IsA("Folder") then
            for _, item in ipairs(folder:GetChildren()) do
                _itemRarityCache[item.Name] = item:GetAttribute("RarityName") or "Common"
            end
        end
    end
end
_buildRarityCache()

local function getRarityColorForDrop(model)
    if model.Name == "Money" then return Color3.fromRGB(0,255,0) end
    local rarity = _itemRarityCache[model.Name]
    if not rarity then return Color3.fromRGB(255,255,255) end
    return RarityColors[rarity] or Color3.fromRGB(255,255,255)
end

local function cleanupItemDrawings()
    for model, data in pairs(itemDrawings) do
        if not model or not model.Parent then
            pcall(function() data.circle:Remove() end)
            pcall(function() data.innerCircle:Remove() end)
            pcall(function() data.name:Remove() end)
            pcall(function() data.amount:Remove() end)
            if data.highlight then data.highlight:Destroy() end
            itemDrawings[model] = nil
        end
    end
end

-- ══════════════════════════════════════════════════════════════
--  ANTI KILL / ANTI LOCK / ANTI RAGDOLL / SKIP CRATE
-- ══════════════════════════════════════════════════════════════
local function isDowned()
    local hum = CharModule and CharModule.get_hum and CharModule.get_hum()
    if not hum or hum.Health <= 0 then return false end
    return hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead")
end

local function getHRP()
    local char = CharModule and CharModule.current_char and CharModule.current_char.get and CharModule.current_char.get()
    if not char then return end
    return char:FindFirstChild("HumanoidRootPart")
end

local function teleportUnderground()
    local root = getHRP(); if not root then return end
    underMapPos = root.CFrame + Vector3.new(0, -55, 0)
    root.CFrame = underMapPos
end

local function flickerAndMove()
    if isFlickering then return end
    isFlickering = true
    task.spawn(function()
        while isFlickering and antiKillEnabled and isDowned() do
            local hum = CharModule and CharModule.get_hum and CharModule.get_hum()
            if hum and hum.Health <= 0 then break end
            local root = getHRP()
            if root and underMapPos then
                local angle = math.random() * math.pi * 2
                local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 30
                root.CFrame = CFrame.new(underMapPos.Position + offset)
                task.wait(0.05)
                root.CFrame = underMapPos
            end
            task.wait(0.1)
        end
        isFlickering = false
    end)
end

local function antiRagdollLoop()
    while antiRagdollEnabled do
        task.wait(0.15)
        pcall(function()
            local RagdollModule = require(ReplicatedStorage.Modules.Game.Ragdoll)
            if RagdollModule.is_ragdolling.get() then
                RagdollModule.is_ragdolling.set(false)
                Send.send("end_ragdoll_early")
                Send.send("clear_ragdoll")
            end
        end)
    end
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if skipCrateEnabled and CrateController then
            pcall(function()
                for _, crate in pairs(CrateController.class.objects) do
                    crate.states.open.set(true)
                    CrateController.skipping.set(true)
                end
            end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  GUN MODS / MELEE AURA / AUTO ATTACK
-- ══════════════════════════════════════════════════════════════
local GunItems = Items:WaitForChild("gun")
getgenv().FireRateValue = 1000
getgenv().AccuracyValue = 1
getgenv().RecoilValue   = 0
getgenv().Durability    = 999999999
getgenv().AutoValue     = true
getgenv().GunModsAutoApply = false

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return GunItems:FindFirstChild(tool.Name) ~= nil or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end

local function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute("fire_rate", getgenv().FireRateValue)
        tool:SetAttribute("accuracy",  getgenv().AccuracyValue)
        tool:SetAttribute("Recoil",    getgenv().RecoilValue)
        tool:SetAttribute("Durability",getgenv().Durability)
        tool:SetAttribute("automatic", getgenv().AutoValue)
    end)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if getgenv().GunModsAutoApply then
            if Character then
                for _, tool in ipairs(Character:GetChildren()) do
                    if tool:IsA("Tool") and isGunTool(tool) then pcall(applyGodGun, tool) end
                end
            end
            for _, tool in ipairs(Backpack:GetChildren()) do
                if tool:IsA("Tool") and isGunTool(tool) then pcall(applyGodGun, tool) end
            end
        end
    end
end)

local meleeNames = {}
for _, tool in ipairs(MeleeItems:GetChildren()) do table.insert(meleeNames, tool.Name) end

local function isMeleeByName(tool)
    if not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    for _, name in ipairs(meleeNames) do if tool.Name == name then return true end end
    return false
end

local function modifyFists(tool, enable)
    if not tool then return end
    local attrs = tool:GetAttributes()
    local keys = {}
    for k in pairs(attrs) do table.insert(keys, k) end
    table.sort(keys)
    if #keys >= 7 then
        local rangeKey = keys[6]; local dmgKey = keys[7]
        if enable then
            if originalAttribs[rangeKey] == nil then originalAttribs[rangeKey] = tool:GetAttribute(rangeKey) end
            if originalAttribs[dmgKey]   == nil then originalAttribs[dmgKey]   = tool:GetAttribute(dmgKey) end
            tool:SetAttribute(rangeKey, 360); tool:SetAttribute(dmgKey, 20)
        else
            if originalAttribs[rangeKey] then tool:SetAttribute(rangeKey, originalAttribs[rangeKey]) end
            if originalAttribs[dmgKey]   then tool:SetAttribute(dmgKey,   originalAttribs[dmgKey]) end
        end
    end
end

local function checkAndModifyFists()
    if Character then
        for _, tool in ipairs(Character:GetChildren()) do if isMeleeByName(tool) then modifyFists(tool, meleeAuraEnabled) end end
    end
    for _, tool in ipairs(Backpack:GetChildren()) do if isMeleeByName(tool) then modifyFists(tool, meleeAuraEnabled) end end
end

local function getPlayersInRange(range)
    local result = {}
    if not Character or not Character.PrimaryPart then return result end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character.PrimaryPart then
            local dist = (player.Character.PrimaryPart.Position - Character.PrimaryPart.Position).Magnitude
            if dist <= range then table.insert(result, player) end
        end
    end
    return result
end

local function getActiveTool()
    if Character then for _, v in ipairs(Character:GetChildren()) do if v:IsA("Tool") then return v end end end
    for _, v in ipairs(Backpack:GetChildren()) do if v:IsA("Tool") then return v end end
    return nil
end

local function isMeleeToolCheck(tool)
    if not tool then return false end
    if tool.Name == "Fists" then return true end
    local meleeFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("melee")
    local throwableFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("throwable")
    return meleeFolder:FindFirstChild(tool.Name) and not throwableFolder:FindFirstChild(tool.Name)
end

local function attackNearby()
    if not SendRemote then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar.PrimaryPart then return end
    local tool = getActiveTool()
    if not tool or not isMeleeToolCheck(tool) then return end
    if tool.Parent ~= myChar then return end
    local nearby = getPlayersInRange(20)
    if #nearby == 0 then return end
    local myPos = myChar.PrimaryPart.Position
    local targets, positions = {}, {}
    for _, player in pairs(nearby) do
        local head = player.Character:FindFirstChild("Head")
        local root = player.Character.PrimaryPart
        if head and root then
            local aimPos = predictPosition(head, root)
            table.insert(targets, player); table.insert(positions, aimPos)
        end
    end
    if #targets == 0 then return end
    local lookAt = CFrame.lookAt(myPos, positions[1])
    pcall(function() Send.send("melee_attack", tool, targets, lookAt, 0.75) end)
end

local autoAttackRunning = false
local function startAutoAttack()
    if autoAttackRunning then return end
    autoAttackRunning = true
    task.spawn(function()
        while autoAttackRunning do
            task.wait(0.4)
            if autoAttackEnabled and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                pcall(attackNearby)
            end
        end
    end)
end
startAutoAttack()

-- ══════════════════════════════════════════════════════════════
--  AUTO MINIGAME
-- ══════════════════════════════════════════════════════════════
local SliderModule
pcall(function() SliderModule = require(ReplicatedStorage.Modules.Game.Minigames.SliderMinigame) end)
local function clickMouse()
    VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
    VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
end
local function minigameLoop()
    while autoMinigameEnabled do
        task.wait(0.05)
        if SliderModule and SliderModule.enabled and SliderModule.enabled.get() then
            pcall(function() SliderModule.needle_pos.set(SliderModule.target_pos.get()) end)
            clickMouse(); task.wait(0.01); clickMouse()
        end
    end
end

-- ══════════════════════════════════════════════════════════════
--  SPECTATE
-- ══════════════════════════════════════════════════════════════
function startSpectate()
    if spectateConn then pcall(function() spectateConn:Disconnect() end); spectateConn = nil end
    if not spectateTarget or spectateTarget == "" then return end
    local targetPlayer = Players:FindFirstChild(spectateTarget)
    if not targetPlayer then return end
    spectateConn = RunService.RenderStepped:Connect(function()
        if not spectateEnabled or not spectateTarget then
            if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
            return
        end
        local tp = Players:FindFirstChild(spectateTarget)
        if tp and tp.Character then
            local hum = tp.Character:FindFirstChildOfClass("Humanoid")
            if hum then Camera.CameraSubject = hum; Camera.CameraType = Enum.CameraType.Custom end
        end
    end)
end

function stopSpectate()
    if spectateConn then pcall(function() spectateConn:Disconnect() end); spectateConn = nil end
    spectateTarget = nil
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then Camera.CameraSubject = hum end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  HIDE NAME
-- ══════════════════════════════════════════════════════════════
local function applyHideNameToCharacter(char)
    if not char then return end
    task.wait(0.2)
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local billboard = root:FindFirstChild("CharacterBillboardGui")
        if billboard then
            local nameLabel = billboard:FindFirstChild("PlayerName")
            if nameLabel and nameLabel:IsA("TextLabel") then
                nameLabel.Visible = not hideNameEnabled
            end
        end
    end
end

local function applyHideNameToCurrent()
    local char = LocalPlayer.Character
    if char then applyHideNameToCharacter(char) end
end

-- ══════════════════════════════════════════════════════════════
--  MOVEMENT
-- ══════════════════════════════════════════════════════════════
local function setupHighJump(char)
    if not jumpPowerEnabled then return end
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.UseJumpPower = true; humanoid.JumpPower = 55
    local conn = UserInputService.JumpRequest:Connect(function()
        if not jumpPowerEnabled then return end
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
    return conn
end
local jumpConn_HJ
LocalPlayer.CharacterAdded:Connect(function(char)
    if jumpPowerEnabled then
        if jumpConn_HJ then pcall(function() jumpConn_HJ:Disconnect() end) end
        jumpConn_HJ = setupHighJump(char)
    end
end)

local staminaLoopRunning = false
local function setupStamina()
    pcall(function()
        local SprintModule = require(ReplicatedStorage.Modules.Game.Sprint)
        local sprintBar = getupvalue(SprintModule.consume_stamina, 2).sprint_bar
        if sprintBar and not getgenv().OriginalSprintUpdate then
            local origUpdate = sprintBar.update
            sprintBar.update = function(...) return origUpdate(function() return 1 end) end
            getgenv().OriginalSprintUpdate = origUpdate
        end
    end)
    if staminaLoopRunning then return end
    staminaLoopRunning = true
    task.spawn(function()
        while infiniteStaminaEnabled do
            pcall(function() Send.send("set_sprinting_1", true) end)
            task.wait(0.5)
            if not infiniteStaminaEnabled then break end
            pcall(function() Send.send("set_sprinting_1", false) end)
            task.wait(0.1)
        end
        pcall(function() Send.send("set_sprinting_1", false) end)
        staminaLoopRunning = false
    end)
end

-- ══════════════════════════════════════════════════════════════
--  AUTO PICKUP
-- ══════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.2)
        if autoPickupEnabled then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, item in ipairs(DroppedItems:GetChildren()) do
                    if item:IsA("Model") and item:FindFirstChild("PickUpZone") then
                        if (item:GetPivot().Position - root.Position).Magnitude < 50 then
                            netGet("pickup_dropped_item", item)
                        end
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  INVENTORY ESP
-- ══════════════════════════════════════════════════════════════
local function registerItems(folder)
    if not folder then return end
    for _, tool in ipairs(folder:GetChildren()) do
        if tool:IsA("Tool") then
            local handle      = tool:FindFirstChild("Handle")
            local displayName = tool:GetAttribute("DisplayName") or tool.Name
            local itemId      = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
            local rarity      = tool:GetAttribute("RarityName") or "Common"
            local imageId     = tool:GetAttribute("ImageId") or "rbxassetid://7072725737"
            local key
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId ~= "" then
                    key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                    key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                end
            end
            if not key and itemId and itemId ~= "" and itemId ~= tool.Name then
                key = "ITEMID_" .. itemId .. "_RARITY_" .. rarity
            end
            if not key then
                key = "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
            end
            WeaponRegistry[key] = { Name = displayName, Rarity = rarity, ImageId = imageId, ToolName = tool.Name }
        end
    end
end

local function getItemKey(tool)
    local handle      = tool:FindFirstChild("Handle")
    local displayName = tool:GetAttribute("DisplayName") or tool.Name
    local itemId      = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity      = tool:GetAttribute("RarityName") or "Common"
    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then return mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity end
        if handle:IsA("MeshPart") and handle.MeshId ~= "" then return handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity end
    end
    if itemId and itemId ~= "" and itemId ~= tool.Name then return "ITEMID_" .. itemId .. "_RARITY_" .. rarity end
    return "NAME_" .. displayName .. "_" .. tool.Name .. "_RARITY_" .. rarity
end

local function getWeaponInfo(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    return WeaponRegistry[getItemKey(tool)]
end

local function createBillboardForPlayer(player)
    if not inventoryESPEnabled or player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if PlayerBillboards[player] then
        PlayerBillboards[player]:Destroy()
        PlayerBillboards[player] = nil
    end
    local gui = Instance.new("BillboardGui")
    gui.Adornee     = root
    gui.Size        = UDim2.new(0, 90, 0, 20)
    gui.StudsOffset = Vector3.new(0, -5, 0)
    gui.AlwaysOnTop = true
    gui.Parent      = char
    local layout = Instance.new("UIListLayout", gui)
    layout.FillDirection       = Enum.FillDirection.Horizontal
    layout.SortOrder           = Enum.SortOrder.LayoutOrder
    layout.Padding             = UDim.new(0, 5)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local tools = {}
    for _, bag in ipairs({ "Backpack", "StarterGear", "StarterPack" }) do
        local b = player:FindFirstChild(bag)
        if b then
            for _, t in ipairs(b:GetChildren()) do
                if t:IsA("Tool") and t.Name ~= "Fists" then table.insert(tools, t) end
            end
        end
    end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name ~= "Fists" then table.insert(tools, t) end
    end
    for _, tool in ipairs(tools) do
        local info = getWeaponInfo(tool)
        if info then
            local img = Instance.new("ImageLabel", gui)
            img.Size                   = UDim2.new(0, 20, 0, 20)
            img.BackgroundTransparency = 0.1
            img.Image                  = info.ImageId
            img.BackgroundColor3       = Color3.fromRGB(240, 248, 255)
            Instance.new("UICorner", img).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke", img)
            stroke.Color     = RarityColors[info.Rarity] or Color3.new(1, 1, 1)
            stroke.Thickness = 2
        end
    end
    PlayerBillboards[player] = gui
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if inventoryESPEnabled then
            task.wait(0.2)
            createBillboardForPlayer(player)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    if PlayerBillboards[player] then
        PlayerBillboards[player]:Destroy()
        PlayerBillboards[player] = nil
    end
end)

local inventoryConn
local _inventoryWatchers = {}
for _, folder in ipairs({ "gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish" }) do
    registerItems(Items[folder])
end

-- ══════════════════════════════════════════════════════════════
--  LOOP UNIFICADO - HEARTBEAT
--  ★ OPTIMIZADO: Anti-Lock ahora a 10 Hz con velocidad baja.
-- ══════════════════════════════════════════════════════════════
local _hbFrame      = 0
local _bumpTimer    = 0
local _antiLockTimer = 0

RunService.Heartbeat:Connect(function(dt)
    _hbFrame      = _hbFrame + 1
    _bumpTimer    = _bumpTimer + dt
    _antiLockTimer = _antiLockTimer + dt

    -- Posición history para predicción
    if silentAimEnabled or autoAttackEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                local hum  = player.Character:FindFirstChild("Humanoid")
                if root and hum and hum.Health > 0 then
                    positionHistory[player] = positionHistory[player] or {}
                    local hist = positionHistory[player]
                    hist[#hist+1] = { time = os.clock(), pos = root.Position }
                    if #hist > HISTORY_SIZE then table.remove(hist, 1) end
                else
                    positionHistory[player] = nil
                end
            end
        end
    end

    -- Melee Aura
    if meleeAuraEnabled then checkAndModifyFists() end

    -- Anti Kill
    if antiKillEnabled then
        if isDowned() then
            local root = getHRP()
            if root and not underMapPos then teleportUnderground() end
            flickerAndMove()
        else
            if underMapPos then
                local root = getHRP()
                if root then root.CFrame = underMapPos + Vector3.new(0, 55, 0) end
                underMapPos = nil
            end
            isFlickering = false
        end
    end

    -- ★ ANTI LOCK (optimizado: 10 Hz, velocidad 300)
    if antiLockEnabled and _antiLockTimer >= 0.1 then
        _antiLockTimer = 0
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local oldVel = root.AssemblyLinearVelocity
            local angle  = math.rad(tick() * 300 % 360)
            root.AssemblyLinearVelocity = Vector3.new(
                math.cos(angle) * 300,
                math.random(50, 150),
                math.sin(angle) * 300
            )
            task.defer(function()
                if root and root.Parent then
                    root.AssemblyLinearVelocity = oldVel
                end
            end)
        end
    end

    -- Bump Aura (~10 Hz)
    if _bumpTimer >= 0.1 then
        _bumpTimer = 0
        if bumpAuraEnabled then bumpVehicles() end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  LOOP UNIFICADO - RENDERSTEPPED
-- ══════════════════════════════════════════════════════════════
local smoothTarget  = Vector3.new()
local _rsFrame      = 0
local _cachedTarget = nil

RunService.RenderStepped:Connect(function()
    _rsFrame = _rsFrame + 1

    if _rsFrame % 2 == 0 or not silentAimEnabled then
        _cachedTarget = silentAimEnabled and getClosestTarget() or nil
    end
    aimTarget = _cachedTarget
    if fovCircle then
        if isMobile then
            fovCircle.Visible = silentAimEnabled
            fovCircle.Size = UDim2.fromOffset(fovRadius*2, fovRadius*2)
        else
            fovCircle.Visible = silentAimEnabled
            if silentAimEnabled then
                fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                fovCircle.Radius = fovRadius
            end
        end
    end
    if silentAimEnabled and aimTarget and aimTarget.Character then
        local aimPart = aimTarget.Character:FindFirstChild("Head")
        if aimPart then
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            smoothTarget = smoothTarget:Lerp(aimPart.Position, 0.75)
            local sp, vis = Camera:WorldToViewportPoint(smoothTarget)
            if vis then
                redLine.Visible = true; redLine.From = center; redLine.To = Vector2.new(sp.X, sp.Y)
                local top    = Camera:WorldToViewportPoint(aimPart.Position + Vector3.new(0, 0.5, 0))
                local bottom = Camera:WorldToViewportPoint(aimPart.Position - Vector3.new(0, 0.5, 0))
                local cx, cy = sp.X, sp.Y
                local halfH  = math.clamp((Vector2.new(top.X,top.Y)-Vector2.new(bottom.X,bottom.Y)).Magnitude/2, 8, 25)
                local halfW  = halfH
                tracerLines[1].From, tracerLines[1].To = Vector2.new(cx, cy-halfH), Vector2.new(cx+halfW, cy)
                tracerLines[2].From, tracerLines[2].To = Vector2.new(cx+halfW, cy), Vector2.new(cx, cy+halfH)
                tracerLines[3].From, tracerLines[3].To = Vector2.new(cx, cy+halfH), Vector2.new(cx-halfW, cy)
                tracerLines[4].From, tracerLines[4].To = Vector2.new(cx-halfW, cy), Vector2.new(cx, cy-halfH)
                for i=1,4 do tracerLines[i].Visible = true end
            else hideTracers() end
        else hideTracers() end
    else hideTracers(); smoothTarget = Vector3.new() end

    -- Player ESP cada 2 frames
    local anyESP = nameESPEnabled or distanceESPEnabled or healthESPEnabled
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos  = myRoot and myRoot.Position

    if anyESP and _rsFrame % 2 == 0 then
        for player, data in pairs(ESP) do
            local char = player.Character
            if char and anyESP then
                local hum  = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and head and root and hum.Health > 0 then
                    local posHead, visHead = Camera:WorldToViewportPoint(head.Position)
                    local phX, phY = posHead.X, posHead.Y

                    if nameESPEnabled and visHead then
                        data.Name.Visible = true
                        data.Name.Text = player.Name
                        data.Name.Position = Vector2.new(phX, phY - 30)
                    else data.Name.Visible = false end

                    if distanceESPEnabled and visHead then
                        local dist = myPos and math.floor((myPos - root.Position).Magnitude) or 0
                        data.Info.Visible = true
                        data.Info.Text = dist .. "M"
                        data.Info.Position = Vector2.new(phX, phY + 18)
                    else data.Info.Visible = false end

                    if healthESPEnabled and visHead then
                        local pct = hum.Health / math.max(hum.MaxHealth, 1)
                        local barW, barH = 70, 5
                        local barX = phX - barW/2
                        local barY = phY - 16
                        data.HpBg.Position = Vector2.new(barX, barY)
                        data.HpBg.Size = Vector2.new(barW, barH)
                        data.HpBg.Visible = true
                        data.HpBar.Position = Vector2.new(barX, barY)
                        data.HpBar.Size = Vector2.new(barW * math.clamp(pct, 0, 1), barH)
                        data.HpBar.Color = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 0)
                        data.HpBar.Visible = true
                    else
                        data.HpBar.Visible = false
                        data.HpBg.Visible = false
                    end
                else
                    data.Name.Visible = false
                    data.Info.Visible = false
                    data.HpBar.Visible = false
                    data.HpBg.Visible = false
                end
            else
                data.Name.Visible = false
                data.Info.Visible = false
                data.HpBar.Visible = false
                data.HpBg.Visible = false
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  DROPPED ITEMS ESP + HACKER ESP — HEARTBEAT THROTTLEADO
--  ★ SIN LÍMITE DE 20 OBJETOS: se muestran todos.
-- ══════════════════════════════════════════════════════════════
local _espHbFrame = 0
RunService.Heartbeat:Connect(function()
    _espHbFrame = _espHbFrame + 1

    -- Hacker ESP (~10 Hz)
    if _espHbFrame % 12 == 0 then
        if not hackerESPEnabled then
            for pl in pairs(hackerESPs) do removeHackerESP(pl) end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel = hrp.Velocity.Magnitude
                        flagCounter[player] = flagCounter[player] or 0
                        if vel > VELOCITY_LIMIT then flagCounter[player] = flagCounter[player] + 1
                        else flagCounter[player] = 0 end
                        if flagCounter[player] >= DETECT_FRAMES then createHackerESP(player)
                        else removeHackerESP(player) end
                    else
                        removeHackerESP(player); lastPositions[player] = nil; flagCounter[player] = nil
                    end
                end
            end
        end
    end

    -- Dropped Items ESP (~15 Hz)
    if _espHbFrame % 6 ~= 0 then return end

    if _espHbFrame % 300 == 0 then cleanupItemDrawings() end

    if not droppedESPEnabled then
        for _, data in pairs(itemDrawings) do
            if data.circle then data.circle.Visible = false end
            if data.innerCircle then data.innerCircle.Visible = false end
            if data.name then data.name.Visible = false end
            if data.amount then data.amount.Visible = false end
            if data.highlight then data.highlight.Enabled = false end
        end
        return
    end

    if not DroppedItems then return end
    local myRoot2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot2 then return end
    local myPos2 = myRoot2.Position

    -- Ocultamos todos los dibujos previos
    for _, data in pairs(itemDrawings) do
        if data.circle then data.circle.Visible = false end
        if data.innerCircle then data.innerCircle.Visible = false end
        if data.name then data.name.Visible = false end
        if data.amount then data.amount.Visible = false end
        if data.highlight then data.highlight.Enabled = false end
    end

    -- Procesamos TODOS los items (sin límite de cantidad)
    for _, model in ipairs(DroppedItems:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("PickUpZone") and not model:GetAttribute("Locked") then
            local data = itemDrawings[model]
            if not data then
                data = {}
                data.circle      = Drawing.new("Circle"); data.circle.Thickness = 2; data.circle.Transparency = 0.7; data.circle.Filled = false
                data.innerCircle = Drawing.new("Circle"); data.innerCircle.Thickness = 2; data.innerCircle.Transparency = 1; data.innerCircle.Filled = true
                data.name        = Drawing.new("Text");   data.name.Outline = true; data.name.OutlineColor = Color3.fromRGB(0,0,0); data.name.Center = true; data.name.Size = 16; data.name.Font = 4
                data.amount      = Drawing.new("Text");   data.amount.Outline = true; data.amount.OutlineColor = Color3.fromRGB(0,0,0); data.amount.Center = true; data.amount.Size = 13; data.amount.Color = Color3.fromRGB(200,200,200)
                itemDrawings[model] = data
            end
            if not data.highlight or not data.highlight.Parent then
                local h = Instance.new("Highlight")
                h.Name = "ESP_Highlight"; h.FillTransparency = 0.5; h.OutlineTransparency = 0.1; h.Adornee = model; h.Parent = model
                data.highlight = h
            end
            local pos, vis = Camera:WorldToViewportPoint(model.PickUpZone.Position)
            if vis then
                local color  = getRarityColorForDrop(model)
                local radius = math.clamp(100 / math.max(pos.Z, 0.1), 3, 6)
                data.highlight.FillColor = color; data.highlight.OutlineColor = color; data.highlight.Enabled = true
                data.circle.Position = Vector2.new(pos.X, pos.Y); data.circle.Radius = radius+5; data.circle.Color = color; data.circle.Visible = true
                data.innerCircle.Position = Vector2.new(pos.X, pos.Y); data.innerCircle.Radius = radius; data.innerCircle.Color = color; data.innerCircle.Visible = true
                data.name.Color = color; data.name.Position = Vector2.new(pos.X, pos.Y-radius-20); data.name.Text = model.Name; data.name.Visible = true
                local amt = model:GetAttribute("Amount") or 1
                data.amount.Position = Vector2.new(pos.X, pos.Y+radius+15); data.amount.Text = amt > 1 and "["..tostring(amt).."]" or ""; data.amount.Visible = amt > 1
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  UI WINDUI
-- ══════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
--  BOTÓN FLOTANTE (IMAGEN PERSONALIZADA)
-- ══════════════════════════════════════════════════════════════
local ToggleScreenGui = Instance.new("ScreenGui")
ToggleScreenGui.Name = "MortyHub_Toggle"
ToggleScreenGui.ResetOnSpawn = false
ToggleScreenGui.Parent = CoreGui

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Image = "rbxassetid://3926305904""   -- ¡Cambiada a tu imagen!
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ToggleScreenGui

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Thickness = 2
BtnStroke.Color = Color3.fromRGB(255, 255, 255)
BtnStroke.Transparency = 0.2
BtnStroke.Parent = ToggleBtn

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 12)
BtnCorner.Parent = ToggleBtn

local opened = true

local function toggleUI()
    opened = not opened
    if Window.UI then
        Window.UI.Enabled = opened
    else
        Window:Toggle()
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    ToggleBtn:TweenSize(
        UDim2.new(0, 56, 0, 56),
        Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true,
        function()
            ToggleBtn:TweenSize(UDim2.new(0, 50, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
        end
    )
    toggleUI()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then toggleUI() end
end)

-- ══════════════════════════════════════════════════════════════
--  WINDUI CONFIGURATION
-- ══════════════════════════════════════════════════════════════
local ConfigManager = Window.ConfigManager
local Config = ConfigManager:CreateConfig("MortyHubConfig")

-- ── COMBAT ────────────────────────────────────────────────────
local CombatTab = Window:Tab({ Title = "COMBAT", Icon = "crosshair" })
CombatTab:Section({ Title = "GUN" })
local SilentAimToggle = CombatTab:Toggle({ Title = "Silent Aim", Default = false, Callback = function(v) silentAimEnabled = v end })
local FOVSlider = CombatTab:Slider({ Title = "FOV Size", Step = 1, Value = { Min = 50, Max = 500, Default = 120 }, Callback = function(v) fovRadius = v end })
Config:Register("SilentAim", SilentAimToggle)
Config:Register("FOVRadius", FOVSlider)

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    return names
end

local FriendDropdown = CombatTab:Dropdown({
    Title = "Safe Friend", Desc = "Selecciona jugadores a proteger",
    Values = getPlayerNames(), Default = {}, Multi = true,
    Callback = function(v)
        excludedPlayers = {}
        if type(v) == "table" then
            for name, selected in pairs(v) do
                if type(name) == "string" and selected == true then table.insert(excludedPlayers, name) end
            end
            if #excludedPlayers == 0 then
                for _, name in ipairs(v) do if type(name) == "string" then table.insert(excludedPlayers, name) end end
            end
        end
    end
})

Players.PlayerAdded:Connect(function() pcall(function() FriendDropdown:Refresh(getPlayerNames(), true) end) end)
Players.PlayerRemoving:Connect(function() pcall(function() FriendDropdown:Refresh(getPlayerNames(), true) end) end)

CombatTab:Divider()
CombatTab:Section({ Title = "MELEE & VEHICLES" })
local HitAuraToggle    = CombatTab:Toggle({ Title = "Melee Aura (Wide Fists)", Default = false, Callback = function(v) meleeAuraEnabled = v; checkAndModifyFists() end })
local AutoAttackToggle = CombatTab:Toggle({ Title = "Auto Attack", Default = false, Callback = function(v) autoAttackEnabled = v end })
local BumpAuraToggle   = CombatTab:Toggle({ Title = "Bump Aura (Vehicles)", Default = false, Callback = function(v) bumpAuraEnabled = v end })
Config:Register("MeleeAura", HitAuraToggle)
Config:Register("AutoAttack", AutoAttackToggle)
Config:Register("BumpAura", BumpAuraToggle)

CombatTab:Divider()
CombatTab:Section({ Title = "DEFENSE" })
local AntiKillToggle    = CombatTab:Toggle({ Title = "Anti Kill", Default = false, Callback = function(v) antiKillEnabled = v end })
local AntiRagdollToggle = CombatTab:Toggle({ Title = "Anti Ragdoll", Default = false, Callback = function(v) antiRagdollEnabled = v; if v then task.spawn(antiRagdollLoop) end end })
local AntiLockToggle    = CombatTab:Toggle({ Title = "Anti Lock", Default = false, Callback = function(v) antiLockEnabled = v end })
Config:Register("AntiKill", AntiKillToggle)
Config:Register("AntiRagdoll", AntiRagdollToggle)
Config:Register("AntiLock", AntiLockToggle)

-- ── MOVEMENT ──────────────────────────────────────────────────
local MovementTab = Window:Tab({ Title = "MOVEMENT", Icon = "user" })
MovementTab:Section({ Title = "MOVEMENT" })
local JumpToggle = MovementTab:Toggle({ Title = "High Jump", Default = false, Callback = function(v)
    jumpPowerEnabled = v
    if v then
        if jumpConn_HJ then pcall(function() jumpConn_HJ:Disconnect() end) end
        if LocalPlayer.Character then jumpConn_HJ = setupHighJump(LocalPlayer.Character) end
    else
        if jumpConn_HJ then pcall(function() jumpConn_HJ:Disconnect() end); jumpConn_HJ = nil end
    end
end })
local StaminaToggle = MovementTab:Toggle({ Title = "Infinite Stamina", Default = false, Callback = function(v)
    infiniteStaminaEnabled = v; if v then setupStamina() end
end })
Config:Register("HighJump", JumpToggle)
Config:Register("InfiniteStamina", StaminaToggle)

local function applyDesync(v)
    local done = false
    local raknetNames = {"Raknet","raknet","RakNet","RAKNET"}
    for _, name in ipairs(raknetNames) do
        if not done then pcall(function()
            local r = getgenv()[name] or _G[name]
            if r and r.desync then r.desync(v); done = true end
        end) end
    end
    if not done then pcall(function() if syn and syn.RakNet then syn.RakNet.desync(v); done = true end end) end
    local netNames = {"Network","network","NetworkManager","networkmanager"}
    for _, name in ipairs(netNames) do
        if not done then pcall(function()
            local n = getgenv()[name] or _G[name]
            if n and n.desync then n.desync(v); done = true end
        end) end
    end
    if not done then pcall(function() if fluxus and fluxus.desync then fluxus.desync(v); done = true end end) end
end

local DesyncToggle   = MovementTab:Toggle({ Title = "Invisible (Desync)", Default = false, Callback = function(v) desyncEnabled = v; applyDesync(v) end })
local HideNameToggle = MovementTab:Toggle({ Title = "Hide Name", Default = false, Callback = function(v)
    hideNameEnabled = v; applyHideNameToCurrent()
end })
Config:Register("Desync", DesyncToggle)
Config:Register("HideName", HideNameToggle)

MovementTab:Divider()
MovementTab:Section({ Title = "SNAP UNDER MAP (Tecla Z)" })
local SnapToggle = MovementTab:Toggle({ Title = "Enable Snap", Default = false, Callback = function(v)
    snapUnderMapEnabled = v
    if v then snapActive = true; startSnap() else snapActive = false; stopSnap() end
end })
local SnapDepthSlider = MovementTab:Slider({ Title = "Snap Depth", Step = 1, Value = { Min = 1, Max = 100, Default = 10 }, Callback = function(v) snapDepth = v end })
Config:Register("SnapUnderMap", SnapToggle)
Config:Register("SnapDepth", SnapDepthSlider)

-- ── WEAPON ────────────────────────────────────────────────────
local WeaponTab = Window:Tab({ Title = "WEAPON", Icon = "wrench" })
WeaponTab:Section({ Title = "GUN MODS" })
local GunModToggle   = WeaponTab:Toggle({ Title = "Enable Gun Mods", Default = false, Callback = function(v) getgenv().GunModsAutoApply = v end })
local FireRateSlider = WeaponTab:Slider({ Title = "Fire Rate",   Step = 10,   Value = { Min = 100, Max = 3000, Default = 1000 }, Callback = function(v) getgenv().FireRateValue = v end })
local AccuracySlider = WeaponTab:Slider({ Title = "Accuracy",    Step = 0.01, Value = { Min = 0,   Max = 1,    Default = 1    }, Callback = function(v) getgenv().AccuracyValue = v end })
local RecoilSlider   = WeaponTab:Slider({ Title = "Recoil",      Step = 0.1,  Value = { Min = 0,   Max = 10,   Default = 0    }, Callback = function(v) getgenv().RecoilValue = v end })
local ReloadSlider   = WeaponTab:Slider({ Title = "Reload Time", Step = 0.1,  Value = { Min = 0.1, Max = 10,   Default = 0.1  }, Callback = function(v) getgenv().ReloadValue = v end })
local AutoToggle     = WeaponTab:Toggle({ Title = "Automatic", Default = true, Callback = function(v) getgenv().AutoValue = v end })
Config:Register("GunMods", GunModToggle)
Config:Register("FireRate", FireRateSlider)
Config:Register("Accuracy", AccuracySlider)
Config:Register("Recoil", RecoilSlider)
Config:Register("ReloadTime", ReloadSlider)
Config:Register("Automatic", AutoToggle)

-- ── VISUAL ────────────────────────────────────────────────────
local VisualTab = Window:Tab({ Title = "VISUAL", Icon = "eye" })
VisualTab:Section({ Title = "PLAYER ESP" })
local NameToggle     = VisualTab:Toggle({ Title = "Name ESP",     Default = false, Callback = function(v) nameESPEnabled = v end })
local HealthToggle   = VisualTab:Toggle({ Title = "Health ESP",   Default = false, Callback = function(v) healthESPEnabled = v end })
local DistanceToggle = VisualTab:Toggle({ Title = "Distance ESP", Default = false, Callback = function(v) distanceESPEnabled = v end })
Config:Register("NameESP", NameToggle)
Config:Register("HealthESP", HealthToggle)
Config:Register("DistanceESP", DistanceToggle)

VisualTab:Divider()
VisualTab:Section({ Title = "HACKER DETECTION" })
local HackerESPToggle = VisualTab:Toggle({ Title = "ESP Hackers (Anti-Aim)", Default = false, Callback = function(v) hackerESPEnabled = v end })
Config:Register("HackerESP", HackerESPToggle)

VisualTab:Divider()
VisualTab:Section({ Title = "ITEMS" })

local function _watchInventory(player)
    if _inventoryWatchers[player] then return end
    local conns = {}
    local function refresh() task.defer(createBillboardForPlayer, player) end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        conns[#conns+1] = backpack.ChildAdded:Connect(refresh)
        conns[#conns+1] = backpack.ChildRemoved:Connect(refresh)
    end
    local char = player.Character
    if char then
        conns[#conns+1] = char.ChildAdded:Connect(function(c) if c:IsA("Tool") then refresh() end end)
        conns[#conns+1] = char.ChildRemoved:Connect(function(c) if c:IsA("Tool") then refresh() end end)
    end
    _inventoryWatchers[player] = conns
end

local function _unwatchInventory(player)
    local conns = _inventoryWatchers[player]
    if conns then
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        _inventoryWatchers[player] = nil
    end
end

local InventoryToggle = VisualTab:Toggle({ Title = "Inventory Viewer", Default = false, Callback = function(v)
    inventoryESPEnabled = v
    if v then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createBillboardForPlayer(player)
                _watchInventory(player)
            end
        end
        inventoryConn = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(0.2)
                if inventoryESPEnabled then
                    createBillboardForPlayer(player)
                    _watchInventory(player)
                end
            end)
        end)
    else
        if inventoryConn then inventoryConn:Disconnect(); inventoryConn = nil end
        for _, player in ipairs(Players:GetPlayers()) do _unwatchInventory(player) end
        for _, gui in pairs(PlayerBillboards) do if gui then gui:Destroy() end end
        PlayerBillboards = {}
    end
end })
local DroppedToggle = VisualTab:Toggle({ Title = "Dropped Items ESP", Default = false, Callback = function(v) droppedESPEnabled = v end })
Config:Register("InventoryESP", InventoryToggle)
Config:Register("DroppedESP", DroppedToggle)

-- ── AUTOFARM ──────────────────────────────────────────────────
local AutofarmTab = Window:Tab({ Title = "AUTOFARM", Icon = "zap" })
AutofarmTab:Section({ Title = "FARM" })
local AutoPickupToggle   = AutofarmTab:Toggle({ Title = "Auto Pickup Items", Default = false, Callback = function(v) autoPickupEnabled = v end })
local AutoMinigameToggle = AutofarmTab:Toggle({ Title = "Auto Minigame (ATM/Fishing)", Default = false, Callback = function(v)
    autoMinigameEnabled = v; if v then task.spawn(minigameLoop) end
end })
Config:Register("AutoPickup", AutoPickupToggle)
Config:Register("AutoMinigame", AutoMinigameToggle)

-- ── GUNS AMMO ─────────────────────────────────────────────────
local GunsAmmoTab = Window:Tab({ Title = "GUNS AMMO", Icon = "box" })

local function getCrateOptions()
    local map = workspace:FindFirstChild("Map"); if not map then return nil end
    local tiles = map:FindFirstChild("Tiles"); if not tiles then return nil end
    local gunShopTile = tiles:FindFirstChild("GunShopTile"); if not gunShopTile then return nil end
    local patriotWeapons = gunShopTile:FindFirstChild("PatriotWeapons"); if not patriotWeapons then return nil end
    local interior = patriotWeapons:FindFirstChild("Interior"); if not interior then return nil end
    local crates = interior:FindFirstChild("Crates"); if not crates then return nil end
    local ammoCrate = crates:FindFirstChild("Ammo Crate"); if not ammoCrate then return nil end
    return ammoCrate:FindFirstChild("CrateOptions")
end

local function openCrateWithType(bulletType)
    local crateOptions = getCrateOptions()
    if not crateOptions then WindUI:Notify({Title = "❌ Ammo Crate not found", Duration = 2}); return end
    local targetItem = crateOptions:FindFirstChild(bulletType)
    if not targetItem then WindUI:Notify({Title = "❌ Tipo " .. bulletType .. " no disponible", Duration = 2}); return end
    local result = netGet("open_crate", targetItem, "money")
    WindUI:Notify({Title = result and ("✅ Abierto: " .. bulletType) or "❌ Fallo al abrir", Duration = 2})
end

local selectedAmmoType = "Pistol"
GunsAmmoTab:Dropdown({
    Title = "Tipo de Bala", Values = {"Pistol", "Rifle", "Shotgun", "Random"},
    Value = "Pistol", Multi = false,
    Callback = function(v) selectedAmmoType = v end
})
GunsAmmoTab:Button({
    Title = "BUY AMMO", Desc = "Abre el crate con el tipo seleccionado",
    Callback = function()
        local useType = selectedAmmoType
        if useType == "Random" then
            local opts = {"Pistol","Rifle","Shotgun"}
            useType = opts[math.random(1,#opts)]
            WindUI:Notify({Title = "🎲 Random: " .. useType, Duration = 1})
        end
        openCrateWithType(useType)
    end
})

-- ── SPECTATE ──────────────────────────────────────────────────
local SpectateTab = Window:Tab({ Title = "SPECTATE", Icon = "eye" })
SpectateTab:Section({ Title = "SPECTATE" })

local function getSpectatePlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    return names
end

local SpectateToggle = SpectateTab:Toggle({ Title = "Spectate Player", Default = false, Callback = function(v)
    spectateEnabled = v
    if v then startSpectate() else stopSpectate() end
end })

local SpectateDropdown = SpectateTab:Dropdown({
    Title = "Select Player", Desc = "Selecciona el jugador a espectear",
    Values = getSpectatePlayerNames(), Multi = false,
    Callback = function(v)
        spectateTarget = v
        if spectateEnabled then startSpectate() end
    end
})

Players.PlayerAdded:Connect(function() pcall(function() SpectateDropdown:Refresh(getSpectatePlayerNames(), true) end) end)
Players.PlayerRemoving:Connect(function()
    pcall(function() SpectateDropdown:Refresh(getSpectatePlayerNames(), true) end)
    pcall(function()
        if spectateTarget then
            local still = Players:FindFirstChild(spectateTarget)
            if not still then spectateEnabled = false; pcall(function() SpectateToggle:Set(false) end); stopSpectate() end
        end
    end)
end)

-- ── MISC ──────────────────────────────────────────────────────
local MiscTab = Window:Tab({ Title = "MISC", Icon = "settings" })

MiscTab:Section({ Title = "KEY INFO" })
local KeyTimeBtn = MiscTab:Button({ Title = "Tiempo restante", Desc = "Calculando..." })
task.spawn(function()
    while true do
        task.wait(1)
        local secs = _keySecondsRemaining
        if secs and secs > 0 then
            pcall(function() KeyTimeBtn:SetDesc(formatTime(math.max(0, secs))) end)
            _keySecondsRemaining = math.max(0, secs - 1)
        else
            pcall(function() KeyTimeBtn:SetDesc("Expirada") end)
        end
    end
end)

MiscTab:Divider()
MiscTab:Section({ Title = "MONEY" })
local BankBalance = MiscTab:Button({ Title = "🏦 Bank Balance", Desc = "N/A" })
local HandBalance = MiscTab:Button({ Title = "💸 Hand Balance", Desc = "N/A" })

local function HandMoney()
    local topRight = PlayerGui:FindFirstChild("TopRightHud")
    if topRight and topRight:FindFirstChild("Holder") then
        local money = topRight.Holder:FindFirstChild("MoneyTextLabel")
        if money then local val = money.Text:match("%$(%d+)"); return tonumber(val) or 0 end
    end
    return 0
end
local function ATMMoney()
    for _, v in ipairs(PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and string.find(v.Text, "Bank Balance") then
            local val = v.Text:match("%$(%d+)"); return tonumber(val) or 0
        end
    end
    return 0
end

task.spawn(function()
    while true do
        BankBalance:SetDesc('<b><font color="#00FF00">$' .. (ATMMoney() or 0) .. "</font></b>")
        HandBalance:SetDesc('<b><font color="#00f2ff">$' .. (HandMoney() or 0) .. "</font></b>")
        task.wait(0.2)
    end
end)

MiscTab:Divider()
MiscTab:Section({ Title = "SERVERS" })
local jobIdValue = ""
MiscTab:Input({
    Title       = "Server JobId",
    Placeholder = "Pega el JobId aquí...",
    Callback    = function(v) jobIdValue = (v or ""):gsub("%s+", "") end
})
MiscTab:Button({
    Title    = "▶ Join by JobId",
    Desc     = "Teleporta al servidor con el JobId pegado",
    Callback = function()
        local jid = (jobIdValue or ""):gsub("%s+", "")
        if jid == "" then
            WindUI:Notify({ Title = "❌ JobId vacío", Content = "Pega un JobId primero", Duration = 2 })
            return
        end
        WindUI:Notify({ Title = "🔄 Conectando...", Content = jid, Duration = 2 })
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jid, LocalPlayer)
        end)
        if not ok then
            WindUI:Notify({ Title = "❌ Error", Content = tostring(err):sub(1, 60), Duration = 4 })
        end
    end
})
MiscTab:Button({ Title = "Small Server (1-2 players)", Callback = function()
    local best, cursor = nil, nil
    for _=1,6 do
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        if cursor then url = url.."&cursor="..cursor end
        local ok, body = pcall(function() return game:HttpGet(url) end)
        if not ok or not body then break end
        local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not ok2 or not data or not data.data then break end
        for _, srv in ipairs(data.data) do
            if srv.id ~= game.JobId and srv.playing and srv.playing <= 2 then
                if not best or srv.playing < best.playing then best = srv end
            end
        end
        cursor = data.nextPageCursor; if not cursor then break end
    end
    if best then pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer) end) end
end })
MiscTab:Button({ Title = "Server Hop", Desc = "Salta al servidor más lleno con espacio", Callback = function()
    task.spawn(function()
        local best, cursor = nil, nil
        for _=1,6 do
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Desc&limit=100"
            if cursor then url = url.."&cursor="..cursor end
            local ok, body = pcall(function() return game:HttpGet(url) end)
            if not ok or not body then break end
            local ok2, data = pcall(function() return HttpService:JSONDecode(body) end)
            if not ok2 or not data or not data.data then break end
            for _, srv in ipairs(data.data) do
                if srv.id ~= game.JobId and srv.playing and srv.maxPlayers and srv.playing > 0 and (srv.playing+1) <= srv.maxPlayers then
                    if not best or srv.playing > best.playing then best = srv end
                end
            end
            cursor = data.nextPageCursor; if not cursor then break end
        end
        if best then
            local slots = best.maxPlayers - best.playing
            WindUI:Notify({ Title = "Server Hop", Content = best.playing.."/"..best.maxPlayers.." ("..slots.." libre"..(slots==1 and "" or "s")..")", Duration = 3 })
            task.wait(1.5)
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, best.id, LocalPlayer) end)
        else
            WindUI:Notify({ Title = "Server Hop", Content = "No se encontró servidor", Duration = 2 })
        end
    end)
end })

MiscTab:Divider()
MiscTab:Section({ Title = "OTHER" })
local SkipCrateToggle = MiscTab:Toggle({ Title = "Skip Crate Spin", Default = false, Callback = function(v) skipCrateEnabled = v end })
local FpsBoostToggle  = MiscTab:Toggle({
    Title = "FPS Boost", Desc = "Desactiva sombras y partículas para mejorar el FPS",
    Default = false, Callback = function(v)
        fpsBoostEnabled = v; if v then applyFpsBoost() else removeFpsBoost() end
    end
})
Config:Register("SkipCrate", SkipCrateToggle)
Config:Register("FpsBoost", FpsBoostToggle)

-- ══════════════════════════════════════════════════════════════
--  CONFIG TAB
-- ══════════════════════════════════════════════════════════════
local ConfigTab = Window:Tab({ Title = "CONFIG", Icon = "save" })
ConfigTab:Section({ Title = "CONFIG MANAGER" })

ConfigTab:Button({
    Title = "💾 Save Config",
    Callback = function()
        Config:Save()
        WindUI:Notify({ Title = "✅ Configuración guardada", Duration = 2 })
    end
})

ConfigTab:Button({
    Title = "📂 Load Config",
    Callback = function()
        Config:Load()
        WindUI:Notify({ Title = "✅ Configuración cargada", Duration = 2 })
    end
})

ConfigTab:Button({
    Title = "🗑 Delete Config",
    Callback = function()
        Config:Delete()
        WindUI:Notify({ Title = "🗑 Configuración eliminada", Duration = 2 })
    end
})

-- ══════════════════════════════════════════════════════════════
--  AUTO-CARGAR CONFIGURACIÓN AL INICIAR
-- ══════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(1.5)
    Config:Load()
    applyHideNameToCurrent()
    WindUI:Notify({ 
        Title = "MortyHub", 
        Content = "Configuración cargada automáticamente", 
        Duration = 3 
    })
end)
