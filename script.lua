
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/init.lua"))()
local Window = WindUI:CreateWindow({ 
    Title = "JBAS HUB", 
    Icon = "rbxassetid://12345678", -- Cambia por tu ID
    Author = "JBAS", 
    Folder = "JBAS HUB" 
})
-- 
local Window = WindUI:CreateWindow({
    Title       = "JBAS | Block Spin",
    Icon        = "list",
    Author      = "JBAS HUB",
    Folder      = "JBAS TEST",
    Size        = UDim2.fromOffset(420, 480),
    Theme       = "Dark",
    Transparent = true,
    Resizable   = true,
    Minimized   = true,
    KeyCode     = Enum.KeyCode.G,
})
Window:Tag({ Title = "v2.2", Color = Color3.fromHex("#ff3366"), Radius = 12 })
Window:EditOpenButton({ Enabled = true })
-- Pestaña de COMBATE
local TabCombat = Window:Tab({
    Title = "COMBAT",
    Icon = "crosshair" -- Icono de mira
})

-- Pestaña de MOVIMIENTO
local TabMovement = Window:Tab({
    Title = "MOVEMENT",
    Icon = "zap" -- Icono de rayo/velocidad
})

-- Pestaña de ARMAS
local TabWeapon = Window:Tab({
    Title = "WEAPON",
    Icon = "sword" -- Icono de espada
})

-- Pestaña de VISUALES (ESP, etc)
local TabVisual = Window:Tab({
    Title = "VISUAL",
    Icon = "eye" -- Icono de ojo
})
-- Pestaña de AUTO FARM
local TabAutoFarm = Window:Tab({
    Title = "AUTOFARM",
    Icon = "repeat" -- Icono de repetición
})

-- Pestaña de MISCELÁNEOS (Otros)
local TabMisc = Window:Tab({
    Title = "MISC",
    Icon = "plus-circle"
})

-- Pestaña de CONFIGURACIÓN
local TabConfig = Window:Tab({
    Title = "CONFIG",
    Icon = "settings" -- Icono de tuerca
})
