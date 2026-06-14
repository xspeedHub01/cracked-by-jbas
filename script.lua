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
local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if not ok or not result then
        local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local errGui = Instance.new("ScreenGui", pg)
        errGui.Name = "MortyHubError"; errGui.ResetOnSpawn = false
        local bg = Instance.new("Frame", errGui)
        bg.Size = UDim2.fromOffset(340, 80); bg.Position = UDim2.new(0.5,-170,0,20)
        bg.BackgroundColor3 = Color3.fromRGB(20,10,10); bg.BorderSizePixel = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0,10)
        local stroke = Instance.new("UIStroke", bg)
        stroke.Color = Color3.fromRGB(255,60,60); stroke.Thickness = 1.5
        local lbl = Instance.new("TextLabel", bg)
        lbl.Size = UDim2.new(1,-16,1,0); lbl.Position = UDim2.new(0,8,0,0)
        lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
        lbl.TextColor3 = Color3.fromRGB(255,90,90); lbl.TextWrapped = true
        lbl.Text = "⚠ MortyHub: No se pudo cargar la UI.\n" .. tostring(result)
        task.delay(8, function() pcall(function() errGui:Destroy() end) end)
        return
    end
    WindUI = result
end

local Window = WindUI:CreateWindow({
    Title       = "JBAS TEST🏴",
    Icon        = "list",
    Author      = "JBAS",
    Folder      = "TEST",
    Size        = UDim2.fromOffset(420, 480),
    Theme       = "Dark",
    Transparent = true,
    Resizable   = true,
    Minimized   = false,
    KeyCode     = Enum.KeyCode.G,
})
Window:Tag({ Title = "v2.2", Color = Color3.fromHex("#ff3366"), Radius = 12 })
Window:EditOpenButton({ Enabled = true })
-- Pestañas del JBAS HUB
local TabCombat     = Window:Tab({ Title = "Combat" })
local TabMovement   = Window:Tab({ Title = "Movement" })
local TabWeapon     = Window:Tab({ Title = "Weapon" })
local TabVisual     = Window:Tab({ Title = "Visual" })
local TabAutoFarm   = Window:Tab({ Title = "Auto Farm" })
local TabGuns       = Window:Tab({ Title = "Guns" })
local TabAmmo       = Window:Tab({ Title = "Ammo" })
local TabSpectate   = Window:Tab({ Title = "Spectate" })
local TabMisc       = Window:Tab({ Title = "Misc" })
local TabConfig     = Window:Tab({ Title = "Config" })

-- EJEMPLOS DE ESTRUCTURA (Para que te guíes)

-- COMBAT
TabCombat:Toggle({ Title = "Kill Aura", Callback = function(s) end })

-- 1. Definimos la variable globalmente para que el botón la reconozca
local fovRadius = 120
local isMobile = UserInputService.TouchEnabled
local fovCircle -- Esta variable guardará nuestro círculo
local silentAimEnabled = false⁠

-- 2. Creamos el FOV (Lógica que sacaste de la source)
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
    fovCircle.Visible = false
end
TabCombat:Toggle({
    Title = "Show FOV",
    Callback = function(state)
        if fovCircle then
            fovCircle.Visible = state
        end
    end
})

-- MOVEMENT
TabMovement:Slider({ Title = "WalkSpeed", Min = 16, Max = 100, Callback = function(v) 
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
end })

-- WEAPON
TabWeapon:Toggle({ Title = "Fast Attack", Callback = function(s) end })

-- VISUAL
TabVisual:Toggle({ Title = "ESP Box", Callback = function(s) end })

-- AUTO FARM
TabAutoFarm:Toggle({ Title = "Auto Farm Mobs", Callback = function(s) end })

-- GUNS AMMO
TabGuns:Toggle({ Title = "Silent Aim", Callback = function(s) end })


-- SPECTATE
TabSpectate:Button({ Title = "Spectate Random", Callback = function() end })

-- MISC
TabMisc:Button({ Title = "Rejoin", Callback = function() 
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) 
end })

-- CONFIG
TabConfig:Button({ Title = "Destroy UI", Callback = function() Window:Destroy() end })
--  SILENT AIM HOOK
-- SILENT AIM HOOK (ACTUALIZADO PARA TU SISTEMA)
local oldSend = Send.send
Send.send = function(...)
    local args = { ... }
    
    -- Si el Silent Aim está prendido, buscamos al enemigo
    if silentAimEnabled and aimTarget and aimTarget.Character then
        local head = aimTarget.Character:FindFirstChild("Head")
        if head then
            -- Redirigimos el objetivo (ajusta el índice [2] si no funciona)
            args[2] = head 
        end
    end
    
    return oldSend(unpack(args))
end
