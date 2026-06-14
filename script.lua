
local RunService = game:GetService("RunService")
local itemDrawings = {} -- Tabla para guardar los dibujos (círculos y nombres)
local ESP_Enabled = false -- Estado inicial del ESP (apagado)

-- Aquí deben ir tus variables que ya tenías: 'Items', 'RarityColors', etc.
-- Asegúrate de que estén definidas antes de usarlas.

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
