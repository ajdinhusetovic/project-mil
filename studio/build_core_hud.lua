-- Migration: cores now use the Roblox hotbar. Paste in the Command Bar in Edit mode.
local gui = game:GetService("StarterGui"):FindFirstChild("CoreHUD")
if gui and gui:IsA("ScreenGui") then gui.Enabled = false end
print("Old CoreHUD disabled. Collected Unknown Cores now appear as Tools in the hotbar.")
