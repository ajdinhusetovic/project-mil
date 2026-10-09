local MenuLayers = {}
local bindings = setmetatable({}, {__mode = "k"})

-- Keep launch buttons below every open window, including windows in other ScreenGuis.
function MenuLayers.Bind(parent)
	if bindings[parent] then bindings[parent](); return bindings[parent] end
	local watched = {}
	local player = game:GetService("Players").LocalPlayer
	local function refresh()
		local open = false
		for gui in watched do
			local shade = gui:FindFirstChild("Shade")
			if gui.Enabled and shade and shade.Visible then open = true end
			gui.DisplayOrder = gui.Enabled and shade and shade.Visible and 100 or 10
		end
		for _,gui in parent:GetChildren() do
			if not gui:IsA("ScreenGui") then continue end
			if gui.Name == "HotbarGui" then gui.Enabled = not open and not (player and player:GetAttribute("NpcDialogueOpen")) end
			for _, name in {"IndexButton", "OverchargeButton", "TeleportButton", "ShopButton"} do
				local button = gui:FindFirstChild(name, true)
				if button then button.Visible = not open end
			end
		end
	end
	local function watch(gui)
		if not gui:IsA("ScreenGui") or watched[gui] then return end
		local shade = gui:FindFirstChild("Shade")
		if not shade or not shade:IsA("GuiObject") then return end
		watched[gui] = true
		shade:GetPropertyChangedSignal("Visible"):Connect(refresh)
		gui:GetPropertyChangedSignal("Enabled"):Connect(refresh)
		gui.AncestryChanged:Connect(function()
			if gui.Parent ~= parent then watched[gui] = nil; refresh() end
		end)
		refresh()
	end
	bindings[parent] = refresh
	if player then player:GetAttributeChangedSignal("NpcDialogueOpen"):Connect(refresh) end
	local function attach(gui)
		if not gui:IsA("ScreenGui") then return end
		watch(gui)
		gui.ChildAdded:Connect(function() watch(gui); refresh() end)
	end
	parent.ChildAdded:Connect(function(gui)
		attach(gui)
	end)
	for _, gui in parent:GetChildren() do attach(gui) end
	refresh()
	return refresh
end

return MenuLayers
