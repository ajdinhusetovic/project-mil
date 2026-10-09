local Builder = {}
local white = Color3.new(1, 1, 1)
local function style(item, color)
	item.BackgroundColor3 = color
	item.BorderSizePixel = 0
	Instance.new("UICorner", item).CornerRadius = UDim.new(0.06, 0)
	local stroke = Instance.new("UIStroke", item)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Thickness = 3
	local gradient = Instance.new("UIGradient", item)
	gradient.Color = ColorSequence.new(white, Color3.fromRGB(167, 153, 198))
	gradient.Rotation = 90
end
local function text(parent, class, name, value, x, y, w, h, color)
	local item = Instance.new(class)
	item.Name, item.Text = name, value
	item.Position, item.Size = UDim2.fromScale(x,y), UDim2.fromScale(w,h)
	item.BackgroundTransparency = 1
	item.TextColor3 = color or white
	item.Font = Enum.Font.FredokaOne
	item.TextScaled, item.TextWrapped = true, true
	item.TextStrokeTransparency = 0
	item.Parent = parent
	return item
end
local function button(parent,name,value,x,y,w,h,color)
	local b=text(parent,"TextButton",name,value,x,y,w,h)
	b.BackgroundTransparency=0
	style(b,color)
	return b
end
local function window(parent,name,title,color)
	local gui=Instance.new("ScreenGui")
	gui.Name=name
	gui.ResetOnSpawn=false
	gui.IgnoreGuiInset=true
	gui.DisplayOrder=name=="ReactorGui" and 65 or 60
	gui.Parent=parent
	local shade=Instance.new("Frame")
	shade.Name="Shade"
	shade.Size=UDim2.fromScale(1,1)
	shade.BackgroundColor3=Color3.new(0,0,0)
	shade.BackgroundTransparency=0.4
	shade.BorderSizePixel=0
	shade.Active=true
	shade.Visible=false
	shade.Parent=gui
	local panel=Instance.new("Frame")
	panel.Name="Panel"
	panel.AnchorPoint=Vector2.new(0.5,0.5)
	panel.Position=UDim2.fromScale(0.5,0.5)
	panel.Size=UDim2.fromScale(0.88,0.88)
	panel.Active=true
	panel.Parent=shade
	style(panel,Color3.fromRGB(28,20,47))
	local header=Instance.new("Frame")
	header.Name="Header"
	header.Position=UDim2.fromScale(0.02,0.02)
	header.Size=UDim2.fromScale(0.96,0.1)
	header.Parent=panel
	style(header,color)
	text(header,"TextLabel","TitleLabel",title,0.02,0.12,0.73,0.76)
	local close=button(header,"CloseButton","X",0.82,0.1,0.15,0.8,Color3.fromRGB(240,58,70))
	Instance.new("UIAspectRatioConstraint",close).AspectRatio=1
	Instance.new("UISizeConstraint",close).MinSize=Vector2.new(44,44)
	return gui,panel
end
local function scroll(panel,name,y,h)
	local area=Instance.new("ScrollingFrame")
	area.Name=name
	area.Position=UDim2.fromScale(0.035,y)
	area.Size=UDim2.fromScale(0.93,h)
	area.BackgroundTransparency=1
	area.BorderSizePixel=0
	area.ScrollBarThickness=5
	area.ScrollingDirection=Enum.ScrollingDirection.Y
	area.CanvasSize=UDim2.fromScale(0,1)
	area.Parent=panel
	local grid=Instance.new("UIGridLayout",area)
	grid.Name="CardGrid"
	grid.CellSize=UDim2.fromScale(0.18,0.96)
	grid.CellPadding=UDim2.fromScale(0.02,0.02)
	grid.SortOrder=Enum.SortOrder.LayoutOrder
	return area
end
function Builder.Build(parent)
 assert(not game:GetService("RunService"):IsRunning(), "Create UI through Studio Command Bar in Edit mode")
	local teleport=parent:FindFirstChild("TeleportGui")
	if not teleport then
		local gui,panel=window(parent,"TeleportGui","TELEPORT",Color3.fromRGB(53,174,255))
		teleport=gui
		panel.Size=UDim2.fromScale(0.78,0.7)
		local open=Instance.new("ImageButton")
		open.Name="TeleportButton"
		open.Position,open.Size=UDim2.fromScale(0.865,0.17),UDim2.fromScale(0.1,0.1)
		open.ScaleType=Enum.ScaleType.Fit
		open.Parent=gui
		style(open,Color3.new(0,0,0))
		open.BackgroundTransparency=0.4
		Instance.new("UIAspectRatioConstraint",open).AspectRatio=1
		Instance.new("UISizeConstraint",open).MinSize=Vector2.new(48,48)
		text(open,"TextLabel","TitleLabel","TELEPORT",-0.12,0.78,1.24,0.24)
		local world=button(panel,"WorldButton","",0.06,0.2,0.88,0.25,Color3.fromRGB(61,199,83))
		text(world,"TextLabel","TitleLabel","THIS WORLD",0.03,0.12,0.94,0.55)
		text(world,"TextLabel","DescriptionLabel","MINE • SHOPS • SELL • STABILIZE",0.03,0.76,0.94,0.2)
		local plot=button(panel,"PlotButton","",0.06,0.52,0.88,0.25,Color3.fromRGB(170,80,255))
		text(plot,"TextLabel","TitleLabel","YOUR PLOT",0.03,0.12,0.94,0.55)
		text(plot,"TextLabel","DescriptionLabel","YOUR ISLAND",0.03,0.76,0.94,0.2)
		text(panel,"TextLabel","StatusLabel","Choose a destination",0.04,0.84,0.92,0.07)
		require(script.Parent.ShopTeleportMenuStyle).Teleport(gui)
	end
	local retired = parent:FindFirstChild("ReactorGui")
	if retired then retired.Enabled = false; retired.Shade.Visible = false end
	return teleport
end
return Builder
