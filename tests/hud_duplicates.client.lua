-- Run as a temporary LocalScript in Studio. Uses an isolated GUI folder.
local Shared = game.ReplicatedStorage.Shared
local Layout = require(Shared.HUDMenuLayout)
local parent = Instance.new("Folder")
local names = {"ShopButton", "OverchargeButton", "IndexButton", "TeleportButton"}
game.StarterGui.HUDMenuGui:Clone().Parent = parent
local hud = Layout.Bind(parent)
local original = {}
for _, name in names do original[name] = Layout.Find(parent, name) end

-- Reproduce the authored StarterGui HUD arriving after controller binding.
local duplicate = hud:Clone()
duplicate.Parent = parent
local oldMenu = Instance.new("ScreenGui")
oldMenu.Name = "OverchargeGui"
local oldButton = Instance.new("ImageButton")
oldButton.Name = "OverchargeButton"
oldButton.Parent = oldMenu
local shade = Instance.new("Frame")
shade.Name, shade.Visible = "Shade", false
shade.Parent = oldMenu
oldMenu.Parent = parent
task.wait()
local updateMenus = require(Shared.MenuLayers).Bind(parent)
updateMenus()
assert(not duplicate.Enabled, "Late HUD copy must not cover the bound HUD")
assert(not oldButton.Visible and not oldButton.Interactable, "Standalone rebirth must stay hidden")
for _, name in names do
	assert(Layout.Find(parent, name) == original[name], "Controller must retain original button")
	assert(original[name].Visible, "Bound button must stay visible")
end
shade.Visible = true
updateMenus()
for _, name in names do assert(not original[name].Visible, "Open menus hide launchers") end
shade.Visible = false
updateMenus()
assert(not oldButton.Visible, "Closing a menu must not revive a legacy button")
assert(Layout.Bind(parent) == hud, "Repeated binding must retain bound HUD")
parent:Destroy()
print("HUD DUPLICATES PASS: late clone, standalone rebirth, stable bindings and menu visibility")
