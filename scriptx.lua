-- Carga de emergencia de WindUI
local WindUI
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Error en el Script",
        Text = "No se pudo cargar WindUI: " .. tostring(result),
        Duration = 10
    })
    return -- Si falla, se detiene para no romper más cosas
end
WindUI = result

-- Si llega aquí, es que cargó bien. Creamos la ventana:
local Window = WindUI:CreateWindow({
    Title = "BILLS | JEANS",
    Icon = "list",
    Author = "MICHAEL",
    Size = UDim2.fromOffset(420, 480),
    Theme = "Dark",
    Transparent = true,
    KeyCode = Enum.KeyCode.G,
})

-- Solo una pestaña para probar que todo va bien
local Tab = Window:Tab({ Title = "Test", Icon = "sword" })
Tab:Section({ Title = "Si ves esto, la UI funciona" })

print("Script cargado exitosamente.")
