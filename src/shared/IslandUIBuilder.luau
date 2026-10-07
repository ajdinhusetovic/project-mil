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
		text(plot,"TextLabel","DescriptionLabel","YOUR ISLAND • YOUR REACTOR",0.03,0.76,0.94,0.2)
		text(panel,"TextLabel","StatusLabel","Choose a destination",0.04,0.84,0.92,0.07)
		require(script.Parent.ShopTeleportMenuStyle).Teleport(gui)
	end
	local reactor=parent:FindFirstChild("ReactorGui")
	if not reactor then
		local gui,panel=window(parent,"ReactorGui","YOUR REACTOR",Color3.fromRGB(255,169,43))
		reactor=gui
		text(panel,"TextLabel","RateLabel","$0 / SEC",0.04,0.14,0.44,0.055,Color3.fromRGB(127,255,102))
		text(panel,"TextLabel","BonusLabel","CASH BONUS 1x",0.04,0.205,0.44,0.04)
		text(panel,"TextLabel","SlotCountLabel","0 / 5 INSTALLED",0.04,0.255,0.44,0.04)
		button(panel,"EquipBestButton","EQUIP BEST",0.54,0.145,0.42,0.065,Color3.fromRGB(178,84,255))
		button(panel,"CollectButton","COLLECT $0",0.54,0.225,0.42,0.065,Color3.fromRGB(95,222,68))
		scroll(panel,"Slots",0.325,0.27)
		text(panel,"TextLabel","InventoryTitle","STORED CORES — CLICK TO INSTALL",0.04,0.62,0.92,0.04)
		scroll(panel,"Inventory",0.68,0.2)
		text(panel,"TextLabel","EmptyLabel","Stabilize cores in this world, then bring them here!",0.06,0.7,0.88,0.12)
		text(panel,"TextLabel","StatusLabel","Click an installed core to take it out",0.04,0.92,0.92,0.045)
		local template=button(gui,"CoreCardTemplate","",0,0,0.18,0.27,Color3.fromRGB(77,57,115))
		template.Visible=false
		text(template,"TextLabel","NameLabel","EMPTY SLOT",0.025,0.015,0.95,0.17)
		text(template,"TextLabel","MutationLabel","",0.025,0.19,0.95,0.1)
		local preview=Instance.new("ViewportFrame")
		preview.Name="Preview"
		preview.Position=UDim2.fromScale(0.05,0.3)
		preview.Size=UDim2.fromScale(0.9,0.38)
		preview.BackgroundTransparency=1
		preview.Parent=template
		text(template,"TextLabel","IncomeLabel","",0.025,0.71,0.95,0.12,Color3.fromRGB(127,255,102))
		text(template,"TextLabel","ActionLabel","",0.025,0.86,0.95,0.1)
	end
	return teleport,reactor
end
return Builder
