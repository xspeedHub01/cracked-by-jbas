local WindUI
do
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if not ok or not result then
        warn("Error cargando UI: " .. tostring(result))
        return
    end
    WindUI = result
end

local Window = WindUI:CreateWindow({
    Title = "BILLS | JEANS",
    Icon = "list",
    Author = "MICHAEL",
    Size = UDim2.fromOffset(420, 480),
    Theme = "Dark",
    Transparent = true,
    KeyCode = Enum.KeyCode.G,
})

local Tabs = {
    Combat = Window:Tab({ Title = "Combat", Icon = "sword" }),
    Visual = Window:Tab({ Title = "Visual", Icon = "eye" })
}

-- FUNCIONES DE SOPORTE
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getClosestPlayer()
    local closest, dist = nil, 9999
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
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
-- ESP AVANZADO (Cajas + Distancia + Salud)
local ESP_Enabled = false
local RunService = game:GetService("RunService")

-- Esta función crea la etiqueta de texto y la caja
local function createESP(player)
    local highlight = Instance.new("Highlight", player.Character)
    highlight.Name = "EspHighlight"
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Enabled = ESP_Enabled

    local billboard = Instance.new("BillboardGui", player.Character:FindFirstChild("HumanoidRootPart"))
    billboard.Name = "EspInfo"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    -- Actualizador en tiempo real
    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            label.Text = player.Name .. "\n" .. math.floor(dist) .. " studs | HP: " .. math.floor(player.Character.Humanoid.Health)
        end
    end)
end

-- Toggle en WindUI
Tabs.Visual:Toggle({
    Title = "ESP Pro (Cajas + Info)",
    Callback = function(state)
        ESP_Enabled = state
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if state then
                    if not p.Character:FindFirstChild("EspHighlight") then createESP(p) end
                    p.Character.EspHighlight.Enabled = true
                elseif p.Character:FindFirstChild("EspHighlight") then
                    p.Character.EspHighlight.Enabled = false
                end
            end
        end
    end
})


-- SILENT AIM
local SilentAimEnabled = false
Tabs.Combat:Toggle({
    Title = "Silent Aim (Net Hook)",
    Callback = function(state) SilentAimEnabled = state end
})

local success, Net = pcall(function() return require(game:GetService("ReplicatedStorage").Modules.Core.Net) end)
if success and Net then
    local oldFire = Net.Fire
    Net.Fire = function(self, name, ...)
        local args = {...}
        
        -- Filtramos: solo actuamos si el evento es de disparo y tenemos argumentos
        if SilentAimEnabled and args[1] then
    print("Evento de disparo detectado: " .. tostring(name))
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                -- Solo cambiamos si el evento tiene la estructura correcta
                if typeof(args[1]) == "Vector3" then
                    args[1] = target.Character.HumanoidRootPart.Position
                end
            end
        end
        
        return oldFire(self, name, unpack(args))
    end
end

