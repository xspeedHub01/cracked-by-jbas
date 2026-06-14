-- Definición de variables necesarias
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ESP_Enabled = false
local itemDrawings = {}

-- Carga la UI (esto es lo que mantiene tu menú vivo)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/init.lua"))()
local Window = WindUI:CreateWindow({ 
    Title = "JBAS HUB", 
    Icon = "rbxassetid://12345678", -- Cambia por tu ID
    Author = "JBAS", 
    Folder = "JBAS HUB" 
})

local _itemRarityCache = {}
local function _buildRarityCache()
    _itemRarityCache = {}
    for _, folder in ipairs(workspace:FindFirstChild("DroppedItems
"):GetChildren()) do
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
-- Añade el toggle del ESP aquí mismo:
local DroppedToggle = VisualTab:Toggle({ 
    Title = "Dropped Items ESP", 
    Default = false, 
    Callback = function(v) 
        ESP_Enabled = v -- 'ESP_Enabled' es la variable que definiste en la línea 4
        if not v then
            cleanupItemDrawings() -- Si lo apagas, limpiamos los círculos
        end
    end 
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
-- Motor del ESP: Se ejecuta constantemente
RunService.RenderStepped:Connect(function()
    if ESP_Enabled then
        -- Aquí es donde ocurre la magia. 
        -- Necesitas un bucle que recorra los items y cree los dibujos (Drawing.new).
        -- Si quieres, puedo pasarte el código base para dibujar el círculo y nombre.
    end
end)
-- Motor de dibujo final
game:GetService("RunService").RenderStepped:Connect(function()
    if droppedESPEnabled then -- Esta variable se activa con tu toggle
        local itemsFolder = workspace:FindFirstChild("DroppedItems")
        if itemsFolder then
            for _, item in pairs(itemsFolder:GetChildren()) do
                -- Aquí tu lógica de dibujo: 
                -- Si ya existe el dibujo, solo actualizas su posición
                -- Si no existe, creas el 'Drawing' (círculo o texto)
                -- (puedes usar la función 'createBillboardForDroppedItem' 
                -- si la tienes definida en el resto del código)
            end
        end
    end
end)
