--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")


-- ── Remotes / Modules ────────────────────────────────────────
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local Util, BuyPromptUI, EmotesUI, EmotesList, CoreUI, CharModule, Net, Items, MeleeItems, CrateController
pcall(function() Util            = require(ReplicatedStorage.Modules.Core.Util) end)
pcall(function() BuyPromptUI     = require(ReplicatedStorage.Modules.Game.UI.BuyPromptUI) end)
pcall(function() EmotesUI        = require(ReplicatedStorage.Modules.Game.Emotes.EmotesUI) end)
pcall(function() EmotesList      = require(ReplicatedStorage.Modules.Game.Emotes.EmotesList) end)
pcall(function() CoreUI          = require(ReplicatedStorage.Modules.Core.UI) end)
pcall(function() CharModule      = require(ReplicatedStorage.Modules.Core.Char) end)
pcall(function() Net             = require(ReplicatedStorage.Modules.Core.Net) end)
pcall(function() Items           = ReplicatedStorage:WaitForChild("Items", 5) end)
pcall(function() if Items then MeleeItems = Items:WaitForChild("melee", 5) end end)
pcall(function() CrateController = require(ReplicatedStorage.Modules.Game.CrateSystem.Crate) end)

-- ── Local Player ──────────────────────────────────────────────
print("Morty Hub Leaked by Cypher https://discord.gg/b8QsvrMCNq")

-- FIX PARA DELTA (agrega aquí)
pcall(function() game:GetService("ScriptContext"):SetTimeout(0.2) end)

local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HRP = newChar:WaitForChild("HumanoidRootPart")
    Backpack = LocalPlayer:WaitForChild("Backpack")
    if hideNameEnabled then applyHideNameToCharacter(newChar) end
end)