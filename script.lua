-- ESP Completo y Adaptado para Delta
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function createESP(player)
    -- Crear elementos visuales
    local nameTag = Drawing.new("Text")
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Outline = true
    nameTag.Visible = false

    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            
            if onScreen then
                -- Nombre
                nameTag.Position = Vector2.new(pos.X, pos.Y - 50)
                nameTag.Text = player.Name
                
                -- Inventario (Intentamos leer un modelo equipado si existe)
                -- Nota: Cambia "EquippedItem" por el nombre real de la carpeta/atributo en Blox Spin
                local inv = player.Character:FindFirstChild("EquippedItem") 
                if inv then
                    nameTag.Text = player.Name .. "\n[" .. inv.Name .. "]"
                end
                
                nameTag.Visible = true
            else
                nameTag.Visible = false
            end
        else
            nameTag.Visible = false
        end
    end)
end

-- Inicializar para todos
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

print("ESP Avanzado Cargado")
