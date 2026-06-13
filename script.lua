-- Bloque principal de carga
local success, err = pcall(function()
    local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()

    local Window = WindUI:CreateWindow({
        Title = "JBAS PAPI HUB",
        Icon = "rbxassetid://10723343450", -- Pon aquí el ID de tu logo
        Resizable = true,
        Size = UDim2.fromOffset(580, 460),
        Transparency = 0.5,
    })

    -- Ejemplo: Pestaña de estadísticas
    local StatsTab = Window:AddTab({Title = "STATS"})
    StatsTab:AddLabel("Dinero en banco: " .. game.Players.LocalPlayer.leaderstats.Money.Value)

    -- Aquí iría el resto de tu código...
end)

if not success then
    -- Si falla, que te avise en la consola del ejecutor
    warn("El Hub falló al cargar: " .. tostring(err))
end
