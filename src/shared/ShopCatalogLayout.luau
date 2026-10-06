-- Scale-height cards size against a fixed viewport-height frame, not their canvas.
local Layout = {}
function Layout.Bind(catalog)
	if catalog:GetAttribute("CatalogLayoutBound") then return end
	catalog:SetAttribute("CatalogLayoutBound", true)
	catalog.AutomaticCanvasSize = Enum.AutomaticSize.None
	catalog.ScrollingDirection = Enum.ScrollingDirection.Y
	local items = catalog:FindFirstChild("Items")
	if not items then
		items = Instance.new("Frame")
		items.Name = "Items"
		items.BackgroundTransparency = 1
		items.BorderSizePixel = 0
		items.ZIndex = catalog.ZIndex
		items.Parent = catalog
	end
	for _, child in catalog:GetChildren() do
		if child ~= items and (child:IsA("GuiObject") or child:IsA("UIListLayout") or child:IsA("UIPadding")) then child.Parent = items end
	end
	local list = items:FindFirstChildOfClass("UIListLayout")
	if not list then return end
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	local padding = items:FindFirstChildOfClass("UIPadding")
	local function update()
		local height = catalog.AbsoluteWindowSize.Y
		-- Only this sizing frame uses calculated pixels; cards retain authored scale.
		items.Size = UDim2.new(1, 0, 0, height)
		local edges = 0
		if padding then
			edges = (padding.PaddingTop.Scale + padding.PaddingBottom.Scale) * height
				+ padding.PaddingTop.Offset + padding.PaddingBottom.Offset
		end
		catalog.CanvasSize = UDim2.fromOffset(0, math.ceil(list.AbsoluteContentSize.Y + edges + 6))
	end
	catalog:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(update)
	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	if padding then padding.Changed:Connect(update) end
	update()
	task.defer(update)
end
return Layout
