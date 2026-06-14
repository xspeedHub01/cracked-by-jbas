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
    Title       = "BILLS | JEANS",
    Icon        = "list",
    Author      = "MICHAEL",
    Folder      = "BETA",
    Size        = UDim2.fromOffset(420, 480),
    Theme       = "Dark",
    Transparent = true,
    Resizable   = true,
    Minimized   = true,
    KeyCode     = Enum.KeyCode.G,
})
Window:Tag({ Title = "V1", Color = Color3.fromHex("#ff3366"), Radius = 12 })
Window:EditOpenButton({ Enabled = true })
-- Definición de pestañas con sección inicial de estado
local Tabs = {
    Combat    = Window:Tab({ Title = "Combat",    Icon = "sword" }),
    Movement  = Window:Tab({ Title = "Movement",  Icon = "move" }),
    Weapon    = Window:Tab({ Title = "Weapon",    Icon = "crosshair" }),
    Visual    = Window:Tab({ Title = "Visual",    Icon = "eye" }),
    Automatic = Window:Tab({ Title = "Automatic", Icon = "zap" }),
    Ammo      = Window:Tab({ Title = "Guns ammo", Icon = "package" }),
    Spectate  = Window:Tab({ Title = "Spectate",  Icon = "camera" }),
    Misc      = Window:Tab({ Title = "Misc",      Icon = "settings" })
}

-- Añadimos un punto de estado/ubicación a cada una
for name, tab in pairs(Tabs) do
    tab:Section({ Title = "● Estás en: " .. name })
end
-- ESP LIMPITO Y FUNCIONAL
-- ESP Funcional para WindUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP_Enabled = false

-- Función interna para resaltar
local function applyHighlight(player)
    if player == LocalPlayer then return end
    if player.Character and not player.Character:FindFirstChild("EspHighlight") then
        local hl = Instance.new("Highlight")
        hl.Name = "EspHighlight"
        hl.Parent = player.Character
        hl.FillColor = Color3.fromRGB(255, 0, 0) -- Rojo
        hl.FillTransparency = 0.5
        hl.Enabled = ESP_Enabled
    end
end

-- Toggle en WindUI
Tabs.Visual:Toggle({
    Title = "Show ESP",
    Callback = function(state)
        ESP_Enabled = state
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("EspHighlight") then
                p.Character.EspHighlight.Enabled = state
            elseif p.Character and state then
                applyHighlight(p)
            end
        end
    end
})

-- Detector de nuevos jugadores
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if ESP_Enabled then applyHighlight(p) end
    end)
end)
-- SILENT AIM USANDO EL MOTOR NET (Más estable y sin bloquear pantalla)
local RS = game:GetService("ReplicatedStorage")
local Net = require(RS.Modules.Core.Net)
local SilentAimEnabled = false
-- Esta función DEBE ir antes de Net.Fire para que el script la encuentre
local function getClosestPlayer()
    local closest, dist = nil, 9999
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
            if onScreen and mag < dist then
                closest = v
                dist = mag
            end
        end
    end
    return closest
end

Tabs.Combat:Toggle({
    Title = "Silent Aim (Net Hook)",
    Callback = function(state)
        SilentAimEnabled = state
    end
})

-- Interceptamos la función Fire del módulo Net
local oldFire = Net.Fire
Net.Fire = function(self, name, ...)
    local args = {...}
    
    -- Si el evento es de disparo, redirigimos al enemigo
    if SilentAimEnabled and (name == "FireBullet" or name == "Shoot" or name == "Hit") then
        local target = getClosestPlayer() -- Usando la misma función que ya tienes
        if target then
            -- Aquí inyectamos la posición del objetivo en el paquete de red
            args[1] = target.Character.HumanoidRootPart.Position
        end
    end
    
    return oldFire(self, name, unpack(args))
end
