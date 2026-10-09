-- Run in Studio's EDIT Command Bar after Rojo synchronizes the new code.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before authoring UI")
local source = game.ReplicatedStorage.Shared
-- Edit-mode require caches old versions; use a fresh dependency tree.
local fresh = source:Clone()
fresh.Name = "ProgressionUIBuildCache"
fresh.Parent = game.ReplicatedStorage
assert(#require(fresh.Config).WeaponOrder == 15, "Connect Rojo to the updated project first")
local starter = game:GetService("StarterGui")
require(fresh.ShopTeleportMenuStyle).Weapons(starter.ShopGui)
require(fresh.RebirthMenuStyle).Apply(starter.OverchargeGui)
require(fresh.ShopTeleportMenuStyle).Teleport(starter.TeleportGui)
local retired = starter:FindFirstChild("ReactorGui")
if retired then retired.Enabled = false; retired.Shade.Visible = false end
local powerMultiplier, moneyMultiplier = require(fresh.OverchargeDefinitions).Multipliers(1)
local panel = starter.OverchargeGui.Shade.Panel
panel.PowerNext.ValueLabel.Text = tostring(powerMultiplier) .. "x Power"
panel.CashNext.ValueLabel.Text = tostring(moneyMultiplier) .. "x Money"
panel.LevelRequirement.Text = "Level: 1 / 15"
starter.ShopGui.Shade.Visible = false
starter.OverchargeGui.Shade.Visible = false
fresh.Parent = nil
print("PROGRESSION UI APPLIED: 15 editable weapons, level-only rebirth, no reactor menu")
