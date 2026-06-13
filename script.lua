-- Morty Hub v2.6 - Versión Reparada para Delta
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/lerkermer/lua-projects/master/WindUI/Main.lua"))()
local Window = WindUI:CreateWindow({Title = "Morty Hub v2.6", Icon = "rbxassetid://6031257405", Width = 400})

-- Servicios
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Definir módulos como tablas vacías para evitar errores si no existen
local Util, BuyPromptUI, EmotesUI, EmotesList = {}, {}, {}, {}

-- Intentar cargar módulos de forma segura
pcall(function() Util = require(ReplicatedStorage.Modules.Core.Util) end)
pcall(function() BuyPromptUI = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI) end)
pcall(function() EmotesUI = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI) end)
pcall(function() EmotesList = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList) end)

-- Crear la pestaña de Configuración
if Window then
    local ConfigTab = Window:Tab({ Title = "CONFIG", Icon = "save" })
    ConfigTab:Section({ Title = "Panel de Control" })
    
    ConfigTab:Button({
        Title = "Probando conexión...",
        Callback = function()
            WindUI:Notify({ Title = "¡El script está vivo!", Duration = 3 })
        end
    })
    
    WindUI:Notify({ Title = "Morty Hub cargado", Duration = 5 })
end
