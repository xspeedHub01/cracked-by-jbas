-- 1. Cargar la librería WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()

-- 2. Crear la ventana principal
local Window = WindUI:CreateWindow({
    Title = "NOMBRE DE TU HUB",
    Icon = "rbxassetid://1234567890", -- Cambia esto por el ID de tu logo
    Resizable = true,
    Size = UDim2.fromOffset(580, 460),
    Transparency = 0.5,
})

-- 3. Crear una pestaña (Tab)
local Tab = Window:AddTab({
    Title = "INICIO",
    Icon = "rbxassetid://..." -- Opcional
})

-- 4. Agregar contenido a la pestaña
local Section = Tab:AddSection("Funciones Principales")

Section:AddButton({
    Title = "Mi primer botón",
    Callback = function()
        print("Botón presionado")
    end
})

-- 5. Ejemplo de un Toggle (Interruptor)
Section:AddToggle({
    Title = "Activar hack",
    Callback = function(state)
        if state then
            print("Activado")
        else
            print("Desactivado")
        end
    end
})
