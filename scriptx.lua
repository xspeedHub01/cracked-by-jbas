local CombatTab = Window:Tab({ Title = "COMBAT", Icon = "crosshair" })
CombatTab:Section({ Title = "GUN" })
local SilentAimToggle = CombatTab:Toggle({ Title = "Silent Aim", Default = false, Callback = function(v) silentAimEnabled = v end })
local FOVSlider = CombatTab:Slider({ Title = "FOV Size", Step = 1, Value = { Min = 50, Max = 500, Default = 120 }, Callback = function(v) fovRadius = v end })
Config:Register("SilentAim", SilentAimToggle)
Config:Register("FOVRadius", FOVSlider)

local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    return names
end

local FriendDropdown = CombatTab:Dropdown({
    Title = "Safe Friend", Desc = "Selecciona jugadores a proteger",
    Values = getPlayerNames(), Default = {}, Multi = true,
    Callback = function(v)
        excludedPlayers = {}
        if type(v) == "table" then
            for name, selected in pairs(v) do
                if type(name) == "string" and selected == true then table.insert(excludedPlayers, name) end
            end
            if #excludedPlayers == 0 then
                for _, name in ipairs(v) do if type(name) == "string" then table.insert(excludedPlayers, name) end end
            end
        end
    end
})

Players.PlayerAdded:Connect(function() pcall(function() FriendDropdown:Refresh(getPlayerNames(), true) end) end)
Players.PlayerRemoving:Connect(function() pcall(function() FriendDropdown:Refresh(getPlayerNames(), true) end) end)

CombatTab:Divider()
CombatTab:Section({ Title = "MELEE & VEHICLES" })
local HitAuraToggle    = CombatTab:Toggle({ Title = "Melee Aura (Wide Fists)", Default = false, Callback = function(v) meleeAuraEnabled = v; checkAndModifyFists() end })
local AutoAttackToggle = CombatTab:Toggle({ Title = "Auto Attack", Default = false, Callback = function(v) autoAttackEnabled = v end })
local BumpAuraToggle   = CombatTab:Toggle({ Title = "Bump Aura (Vehicles)", Default = false, Callback = function(v) bumpAuraEnabled = v end })
Config:Register("MeleeAura", HitAuraToggle)
Config:Register("AutoAttack", AutoAttackToggle)
Config:Register("BumpAura", BumpAuraToggle)

CombatTab:Divider()
CombatTab:Section({ Title = "DEFENSE" })
local AntiKillToggle    = CombatTab:Toggle({ Title = "Anti Kill", Default = false, Callback = function(v) antiKillEnabled = v end })
local AntiRagdollToggle = CombatTab:Toggle({ Title = "Anti Ragdoll", Default = false, Callback = function(v) antiRagdollEnabled = v; if v then task.spawn(antiRagdollLoop) end end })
local AntiLockToggle    = CombatTab:Toggle({ Title = "Anti Lock", Default = false, Callback = function(v) antiLockEnabled = v end })
Config:Register("AntiKill", AntiKillToggle)
Config:Register("AntiRagdoll", AntiRagdollToggle)
Config:Register("AntiLock", AntiLockToggle)

-- ── MOVEMENT ──────────────────────────────────────────────────
local MovementTab = Window:Tab({ Title = "MOVEMENT", Icon = "user" })
MovementTab:Section({ Title = "MOVEMENT" })
local JumpToggle = MovementTab:Toggle({ Title = "High Jump", Default = false, Callback = function(v)
    jumpPowerEnabled = v
    if v then
        if jumpConn_HJ then pcall(function() jumpConn_HJ:Disconnect() end) end
        if LocalPlayer.Character then jumpConn_HJ = setupHighJump(LocalPlayer.Character) end
    else
        if jumpConn_HJ then pcall(function() jumpConn_HJ:Disconnect() end); jumpConn_HJ = nil end
    end
end })
local StaminaToggle = MovementTab:Toggle({ Title = "Infinite Stamina", Default = false, Callback = function(v)
    infiniteStaminaEnabled = v; if v then setupStamina() end
end })
Config:Register("HighJump", JumpToggle)
Config:Register("InfiniteStamina", StaminaToggle)

local function applyDesync(v)
    local done = false
    local raknetNames = {"Raknet","raknet","RakNet","RAKNET"}
    for _, name in ipairs(raknetNames) do
        if not done then pcall(function()
            local r = getgenv()[name] or _G[name]
            if r and r.desync then r.desync(v); done = true end
        end) end
    end
    if not done then pcall(function() if syn and syn.RakNet then syn.RakNet.desync(v); done = true end end) end
    local netNames = {"Network","network","NetworkManager","networkmanager"}
    for _, name in ipairs(netNames) do
        if not done then pcall(function()
            local n = getgenv()[name] or _G[name]
            if n and n.desync then n.desync(v); done = true end
        end) end
    end
    if not done then pcall(function() if fluxus and fluxus.desync then fluxus.desync(v); done = true end end) end
end

local DesyncToggle   = MovementTab:Toggle({ Title = "Invisible (Desync)", Default = false, Callback = function(v) desyncEnabled = v; applyDesync(v) end })
local HideNameToggle = MovementTab:Toggle({ Title = "Hide Name", Default = false, Callback = function(v)
    hideNameEnabled = v; applyHideNameToCurrent()
end })
Config:Register("Desync", DesyncToggle)
Config:Register("HideName", HideNameToggle)

MovementTab:Divider()
MovementTab:Section({ Title = "SNAP UNDER MAP (Tecla Z)" })
local SnapToggle = MovementTab:Toggle({ Title = "Enable Snap", Default = false, Callback = function(v)
    snapUnderMapEnabled = v
    if v then snapActive = true; startSnap() else snapActive = false; stopSnap() end
end })
local SnapDepthSlider = MovementTab:Slider({ Title = "Snap Depth", Step = 1, Value = { Min = 1, Max = 100, Default = 10 }, Callback = function(v) snapDepth = v end })
Config:Register("SnapUnderMap", SnapToggle)
Config:Register("SnapDepth", SnapDepthSlider)

-- ── WEAPON ────────────────────────────────────────────────────
local WeaponTab = Window:Tab({ Title = "WEAPON", Icon = "wrench" })
WeaponTab:Section({ Title = "GUN MODS" })
local GunModToggle   = WeaponTab:Toggle({ Title = "Enable Gun Mods", Default = false, Callback = function(v) getgenv().GunModsAutoApply = v end })
local FireRateSlider = WeaponTab:Slider({ Title = "Fire Rate",   Step = 10,   Value = { Min = 100, Max = 3000, Default = 1000 }, Callback = function(v) getgenv().FireRateValue = v end })
local AccuracySlider = WeaponTab:Slider({ Title = "Accuracy",    Step = 0.01, Value = { Min = 0,   Max = 1,    Default = 1    }, Callback = function(v) getgenv().AccuracyValue = v end })
local RecoilSlider   = WeaponTab:Slider({ Title = "Recoil",      Step = 0.1,  Value = { Min = 0,   Max = 10,   Default = 0    }, Callback = function(v) getgenv().RecoilValue = v end })
local ReloadSlider   = WeaponTab:Slider({ Title = "Reload Time", Step = 0.1,  Value = { Min = 0.1, Max = 10,   Default = 0.1  }, Callback = function(v) getgenv().ReloadValue = v end })
local AutoToggle     = WeaponTab:Toggle({ Title = "Automatic", Default = true, Callback = function(v) getgenv().AutoValue = v end })
Config:Register("GunMods", GunModToggle)
Config:Register("FireRate", FireRateSlider)
Config:Register("Accuracy", AccuracySlider)
Config:Register("Recoil", RecoilSlider)
Config:Register("ReloadTime", ReloadSlider)
Config:Register("Automatic", AutoToggle)

-- ── VISUAL ────────────────────────────────────────────────────
local VisualTab = Window:Tab({ Title = "VISUAL", Icon = "eye" })
VisualTab:Section({ Title = "PLAYER ESP" })
local NameToggle     = VisualTab:Toggle({ Title = "Name ESP",     Default = false, Callback = function(v) nameESPEnabled = v end })
local HealthToggle   = VisualTab:Toggle({ Title = "Health ESP",   Default = false, Callback = function(v) healthESPEnabled = v end })
local DistanceToggle = VisualTab:Toggle({ Title = "Distance ESP", Default = false, Callback = function(v) distanceESPEnabled = v end })
Config:Register("NameESP", NameToggle)
Config:Register("HealthESP", HealthToggle)
Config:Register("DistanceESP", DistanceToggle)

VisualTab:Divider()
VisualTab:Section({ Title = "HACKER DETECTION" })
local HackerESPToggle = VisualTab:Toggle({ Title = "ESP Hackers (Anti-Aim)", Default = false, Callback = function(v) hackerESPEnabled = v end })
Config:Register("HackerESP", HackerESPToggle)

VisualTab:Divider()
VisualTab:Section({ Title = "ITEMS" })

local function _watchInventory(player)
    if _inventoryWatchers[player] then return end
    local conns = {}
    local function refresh() task.defer(createBillboardForPlayer, player) end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        conns[#conns+1] = backpack.ChildAdded:Connect(refresh)
        conns[#conns+1] = backpack.ChildRemoved:Connect(refresh)
    end
    local char = player.Character
    if char then
        conns[#conns+1] = char.ChildAdded:Connect(function(c) if c:IsA("Tool") then refresh() end end)
        conns[#conns+1] = char.ChildRemoved:Connect(function(c) if c:IsA("Tool") then refresh() end end)
    end
    _inventoryWatchers[player] = conns
end

local function _unwatchInventory(player)
    local conns = _inventoryWatchers[player]
    if conns then
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        _inventoryWatchers[player] = nil
    end
end

local InventoryToggle = VisualTab:Toggle({ Title = "Inventory Viewer", Default = false, Callback = function(v)
    inventoryESPEnabled = v
    if v then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                createBillboardForPlayer(player)
                _watchInventory(player)
            end
        end
        inventoryConn = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(0.2)
                if inventoryESPEnabled then
                    createBillboardForPlayer(player)
                    _watchInventory(player)
                end
            end)
        end)
    else
        if inventoryConn then inventoryConn:Disconnect(); inventoryConn = nil end
        for _, player in ipairs(Players:GetPlayers()) do _unwatchInventory(player) end
        for _, gui in pairs(PlayerBillboards) do if gui then gui:Destroy() end end
        PlayerBillboards = {}
    end
end })
local DroppedToggle = VisualTab:Toggle({ Title = "Dropped Items ESP", Default = false, Callback = function(v) droppedESPEnabled = v end })
Config:Register("InventoryESP", InventoryToggle)
Config:Register("DroppedESP", DroppedToggle)

-- ── AUTOFARM ──────────────────────────────────────────────────
local AutofarmTab = Window:Tab({ Title = "AUTOFARM", Icon = "zap" })
AutofarmTab:Section({ Title = "FARM" })
local AutoPickupToggle   = AutofarmTab:Toggle({ Title = "Auto Pickup Items", Default = false, Callback = function(v) autoPickupEnabled = v end })
local AutoMinigameToggle = AutofarmTab:Toggle({ Title = "Auto Minigame (ATM/Fishing)", Default = false, Callback = function(v)
    autoMinigameEnabled = v; if v then task.spawn(minigameLoop) end
end })
Config:Register("AutoPickup", AutoPickupToggle)
Config:Register("AutoMinigame", AutoMinigameToggle)

-- ── GUNS AMMO ─────────────────────────────────────────────────
local GunsAmmoTab = Window:Tab({ Title = "GUNS AMMO", Icon = "box" })

local function getCrateOptions()
    local map = workspace:FindFirstChild("Map"); if not map then return nil end
    local tiles = map:FindFirstChild("Tiles"); if not tiles then return nil end
    local gunShopTile = tiles:FindFirstChild("GunShopTile"); if not gunShopTile then return nil end
    local patriotWeapons = gunShopTile:FindFirstChild("PatriotWeapons"); if not patriotWeapons then return nil end
    local interior = patriotWeapons:FindFirstChild("Interior"); if not interior then return nil end
    local crates = interior:FindFirstChild("Crates"); if not crates then return nil end
    local ammoCrate = crates:FindFirstChild("Ammo Crate"); if not ammoCrate then return nil end
    return ammoCrate:FindFirstChild("CrateOptions")
end

local function openCrateWithType(bulletType)
    local crateOptions = getCrateOptions()
    if not crateOptions then WindUI:Notify({Title = "❌ Ammo Crate not found", Duration = 2}); return end
    local targetItem = crateOptions:FindFirstChild(bulletType)
    if not targetItem then WindUI:Notify({Title = "❌ Tipo " .. bulletType .. " no disponible", Duration = 2}); return end
    local result = netGet("open_crate", targetItem, "money")
    WindUI:Notify({Title = result and ("✅ Abierto: " .. bulletType) or "❌ Fallo al abrir", Duration = 2})
end

local selectedAmmoType = "Pistol"
GunsAmmoTab:Dropdown({
    Title = "Tipo de Bala", Values = {"Pistol", "Rifle", "Shotgun", "Random"},
    Value = "Pistol", Multi = false,
    Callback = function(v) selectedAmmoType = v end
})
GunsAmmoTab:Button({
    Title = "BUY AMMO", Desc = "Abre el crate con el tipo seleccionado",
    Callback = function()
        local useType = selectedAmmoType
        if useType == "Random" then
            local opts = {"Pistol","Rifle","Shotgun"}
            useType = opts[math.random(1,#opts)]
            WindUI:Notify({Title = "🎲 Random: " .. useType, Duration = 1})
        end
        openCrateWithType(useType)
    end
})

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