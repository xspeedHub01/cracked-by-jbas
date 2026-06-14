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
    Title       = "JBAS BETA | Block Spin",
    Icon        = "list",
    Author      = "JBAS",
    Folder      = "TEST",
    Size        = UDim2.fromOffset(420, 480),
    Theme       = "Dark",
    Transparent = true,
    Resizable   = true,
    Minimized   = false,
    KeyCode     = Enum.KeyCode.G,
})
Window:Tag({ Title = "v2.2", Color = Color3.fromHex("#ff3366"), Radius = 12 })
Window:EditOpenButton({ Enabled = true })
-- Pestañas del JBAS HUB
local TabCombat     = Window:Tab({ Title = "Combat" })
local TabMovement   = Window:Tab({ Title = "Movement" })
local TabWeapon     = Window:Tab({ Title = "Weapon" })
local TabVisual     = Window:Tab({ Title = "Visual" })
local TabAutoFarm   = Window:Tab({ Title = "Auto Farm" })
local TabGuns       = Window:Tab({ Title = "Guns" })
local TabAmmo       = Window:Tab({ Title = "Ammo" })
local TabSpectate   = Window:Tab({ Title = "Spectate" })
local TabMisc       = Window:Tab({ Title = "Misc" })
local TabConfig     = Window:Tab({ Title = "Config" })

-- EJEMPLOS DE ESTRUCTURA (Para que te guíes)

-- COMBAT
TabCombat:Toggle({ Title = "Kill Aura", Callback = function(s) end })

-- MOVEMENT
TabMovement:Slider({ Title = "WalkSpeed", Min = 16, Max = 100, Callback = function(v) 
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
end })

-- WEAPON
TabWeapon:Toggle({ Title = "Fast Attack", Callback = function(s) end })

-- VISUAL
TabVisual:Toggle({ Title = "ESP Box", Callback = function(s) end })

-- AUTO FARM
TabAutoFarm:Toggle({ Title = "Auto Farm Mobs", Callback = function(s) end })

-- GUNS AMMO
TabGuns:Toggle({ Title = "Silent Aim", Callback = function(s) end })


-- SPECTATE
TabSpectate:Button({ Title = "Spectate Random", Callback = function() end })

-- MISC
TabMisc:Button({ Title = "Rejoin", Callback = function() 
    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) 
end })

-- CONFIG
TabConfig:Button({ Title = "Destroy UI", Callback = function() Window:Destroy() end })
