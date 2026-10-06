local MenuLayers = {}

-- Keep launch buttons below every open window, including windows in other ScreenGuis.
function MenuLayers.Bind(parent)
	local watched = {}
	local function refresh()
		local open = false
		for gui in watched do
			local shade = gui:FindFirstChild("Shade")
			if gui.Enabled and shade and shade.Visible then open = true end
			gui.DisplayOrder = gui.Enabled and shade and shade.Visible and 100 or 10
		end
		for gui in watched do
			for _, name in {"IndexButton", "OverchargeButton", "TeleportButton"} do
				local button = gui:FindFirstChild(name)
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
	parent.ChildAdded:Connect(function(gui)
		watch(gui)
		gui.ChildAdded:Connect(function() watch(gui) end)
	end)
	for _, gui in parent:GetChildren() do watch(gui) end
	refresh()
end

return MenuLayers
