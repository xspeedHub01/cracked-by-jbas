-- 1. SERVICIOS Y VARIABLES BASE
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- 2. CARGA DE WINDUI (Librería de Interfaz)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/init.lua"))()

local Window = WindUI:CreateWindow({ 
    Title = "JBAS HUB", 
    Author = "JBAS", 
    Folder = "JBAS_Settings" 
})

-- 3. PESTAÑAS
local VisualTab = Window:Tab({ Title = "Visual" })

-- 4. TOGGLE PARA ESP
_G.ESP_Enabled = false

VisualTab:Toggle({
    Title = "ESP Dropped Items",
    Callback = function(state)
        _G.ESP_Enabled = state
    end
})

-- 5. MOTOR DE ESP (RenderStepped)
RunService.RenderStepped:Connect(function()
    if _G.ESP_Enabled then
        -- Aquí pondremos la lógica que extraigamos del archivo que subiste
        -- Buscaremos en 'workspace' los ítems y dibujaremos.
    end
end)
