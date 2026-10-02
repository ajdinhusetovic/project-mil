-- Paste this entire file into Roblox Studio's Command Bar in Edit mode.
-- Creates editable StarterGui.ShopGui. Re-running preserves your edits.
local starterGui = game:GetService("StarterGui")
if starterGui:FindFirstChild("ShopGui") then
	warn("ShopGui already exists in StarterGui; edit that copy in Explorer.")
	return
end

local black = Color3.fromRGB(5, 5, 7)
local white = Color3.fromRGB(255, 255, 255)
local gold = Color3.fromRGB(255, 222, 88)
local function rounded(parent, pixels)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, pixels)
	item.Parent = parent
end
local function outline(parent, pixels)
	local item = Instance.new("UIStroke")
	item.Color = black
	item.Thickness = pixels
	item.Parent = parent
end
local function gradient(parent, top, bottom)
	local item = Instance.new("UIGradient")
	item.Rotation = 90
	item.Color = ColorSequence.new(top, bottom)
	item.Parent = parent
end
local function frame(parent, name, position, size, color, z)
	local item = Instance.new("Frame")
	item.Name = name
	item.Position = position
	item.Size = size
	item.BackgroundColor3 = color
	item.BorderSizePixel = 0
	item.ZIndex = z or 3
	item.Parent = parent
	return item
end
local function label(parent, name, value, position, size, fontSize, color, align, z)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Position = position
	item.Size = size
	item.BackgroundTransparency = 1
	item.Text = value
	item.Font = Enum.Font.FredokaOne
	item.TextSize = fontSize
	item.TextScaled = true
	item.TextWrapped = true
	item.TextColor3 = color or white
	item.TextXAlignment = align or Enum.TextXAlignment.Left
	item.ZIndex = z or 5
	item.Parent = parent
	outline(item, 2.5)
	return item
end
local function button(parent, name, value, position, size, top, bottom)
	local item = Instance.new("TextButton")
	item.Name = name
	item.Position = position
	item.Size = size
	item.BackgroundColor3 = top
	item.BorderSizePixel = 0
	item.Text = value
	item.Font = Enum.Font.FredokaOne
	item.TextScaled = true
	item.TextWrapped = true
	item.TextColor3 = white
	item.ZIndex = 6
	item.Parent = parent
	rounded(item, 8)
	outline(item, 4)
	gradient(item, top, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)
	padding.Parent = item
	return item
end

local gui = Instance.new("ScreenGui")
gui.Name = "ShopGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 20
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.Parent = starterGui

local shade = frame(gui, "Shade", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), black, 1)
shade.BackgroundTransparency = 0.4
shade.Visible = false
local clickAway = Instance.new("TextButton")
clickAway.Name = "ClickAwayButton"
clickAway.Size = UDim2.fromScale(1, 1)
clickAway.BackgroundTransparency = 1
clickAway.Text = ""
clickAway.ZIndex = 2
clickAway.Parent = shade

local window = frame(shade, "Window", UDim2.fromScale(0.5, 0.5), UDim2.new(0.9, 0, 0.79, 0), Color3.fromRGB(25, 31, 30), 3)
window.AnchorPoint = Vector2.new(0.5, 0.5)
rounded(window, 12)
outline(window, 6)
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(760, 570)
limit.MinSize = Vector2.new(300, 350)
limit.Parent = window

local header = frame(window, "Header", UDim2.fromScale(0.015, 0.02), UDim2.new(0.97, 0, 0.17, 0), Color3.fromRGB(169, 66, 255), 4)
rounded(header, 8)
outline(header, 4)
label(header, "TitleLabel", "UPGRADES", UDim2.new(0.035, 0, 0.06, 0), UDim2.new(0.62, 0, 0.84, 0), 48)
label(header, "CashLabel", "$0", UDim2.new(0.66, 0, 0.21, 0), UDim2.new(0.21, 0, 0.58, 0), 32, gold, Enum.TextXAlignment.Right)
button(header, "CloseButton", "X", UDim2.new(0.91, 0, 0.2, 0), UDim2.new(0.07, 0, 0.6, 0), Color3.fromRGB(255, 102, 99), Color3.fromRGB(195, 44, 72))

local content = frame(window, "Content", UDim2.new(0.025, 0, 0.22, 0), UDim2.new(0.95, 0, 0.74, 0), Color3.fromRGB(14, 23, 21), 4)
content.BackgroundTransparency = 0.15
rounded(content, 8)
outline(content, 3)

local function card(parent, name, top, bottom, y, height)
	local item = frame(parent, name, UDim2.new(0.04, 0, y, 0), UDim2.new(0.92, 0, height, 0), top, 5)
	rounded(item, 10)
	outline(item, 4)
	gradient(item, top, bottom)
	return item
end

local upgradePage = frame(content, "UpgradesPage", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Color3.fromRGB(14, 23, 21), 4)
upgradePage.BackgroundTransparency = 1
label(upgradePage, "IntroLabel", "BOOST YOUR MINING RUNS", UDim2.new(0.04, 0, 0.025, 0), UDim2.new(0.92, 0, 0.1, 0), 23, gold, Enum.TextXAlignment.Center)
local storage = card(upgradePage, "StorageCard", Color3.fromRGB(185, 95, 255), Color3.fromRGB(109, 45, 203), 0.18, 0.62)
label(storage, "NameLabel", "BACKPACK STORAGE", UDim2.new(0.04, 0, 0.07, 0), UDim2.new(0.92, 0, 0.25, 0), 31)
label(storage, "DetailLabel", "BAG CAPACITY  50  →  75", UDim2.new(0.04, 0, 0.38, 0), UDim2.new(0.92, 0, 0.16, 0), 22, white, Enum.TextXAlignment.Center)
button(storage, "BuyButton", "UPGRADE  •  $50", UDim2.new(0.19, 0, 0.65, 0), UDim2.new(0.62, 0, 0.25, 0), Color3.fromRGB(80, 236, 57), Color3.fromRGB(30, 151, 39))
label(upgradePage, "FooterLabel", "BIGGER BAG = MORE ORE EVERY TRIP", UDim2.new(0.04, 0, 0.84, 0), UDim2.new(0.92, 0, 0.1, 0), 19, white, Enum.TextXAlignment.Center)

local weaponPage = frame(content, "WeaponsPage", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), Color3.fromRGB(14, 23, 21), 4)
weaponPage.BackgroundTransparency = 1
weaponPage.Visible = false
label(weaponPage, "IntroLabel", "STRONGER ZAPS, FASTER POWER", UDim2.new(0.04, 0, 0.025, 0), UDim2.new(0.92, 0, 0.1, 0), 23, gold, Enum.TextXAlignment.Center)
local starter = card(weaponPage, "StarterCard", Color3.fromRGB(105, 213, 238), Color3.fromRGB(45, 111, 163), 0.15, 0.24)
label(starter, "NameLabel", "SCRAP ZAPPER", UDim2.new(0.04, 0, 0.1, 0), UDim2.new(0.52, 0, 0.35, 0), 25)
label(starter, "DetailLabel", "+1 POWER / CLICK", UDim2.new(0.04, 0, 0.53, 0), UDim2.new(0.55, 0, 0.25, 0), 17)
label(starter, "StatusLabel", "EQUIPPED", UDim2.new(0.62, 0, 0.24, 0), UDim2.new(0.34, 0, 0.48, 0), 21, gold, Enum.TextXAlignment.Center)
local arc = card(weaponPage, "ArcCard", Color3.fromRGB(97, 160, 255), Color3.fromRGB(42, 68, 207), 0.44, 0.46)
label(arc, "NameLabel", "ARC PISTOL", UDim2.new(0.04, 0, 0.06, 0), UDim2.new(0.92, 0, 0.26, 0), 29)
label(arc, "DetailLabel", "+3 POWER / CLICK  •  LEVEL 2", UDim2.new(0.04, 0, 0.35, 0), UDim2.new(0.92, 0, 0.17, 0), 19, white, Enum.TextXAlignment.Center)
button(arc, "BuyButton", "BUY  •  $150", UDim2.new(0.2, 0, 0.63, 0), UDim2.new(0.6, 0, 0.27, 0), Color3.fromRGB(80, 236, 57), Color3.fromRGB(30, 151, 39))

print("Created StarterGui.ShopGui. Paste studio/expand_shop_gui.lua next to add Chain, Magnet, and more weapons.")
