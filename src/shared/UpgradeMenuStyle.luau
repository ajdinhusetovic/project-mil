local Style = {}
local black = Color3.fromRGB(5, 8, 2)
local white = Color3.new(1, 1, 1)
local function get(parent, class, name)
	local item = parent:FindFirstChild(name) or Instance.new(class)
	item.Name, item.Parent = name, parent
	return item
end
local function surface(item, top, bottom, thickness)
	item.BorderSizePixel = 0
	item.BackgroundTransparency = 0
	item.BackgroundColor3 = white
	local corner = item:FindFirstChildOfClass("UICorner")
	if corner then corner.CornerRadius = UDim.new(0.015, 0) end
	local stroke = item:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", item)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color, stroke.Thickness = black, thickness or 4
	stroke.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
	local gradient = item:FindFirstChildOfClass("UIGradient") or Instance.new("UIGradient", item)
	gradient.Color = ColorSequence.new(top, bottom)
	gradient.Rotation = 90
end
local function label(parent, name, value, x, y, w, h, color)
	local item = get(parent, "TextLabel", name)
	item.Position, item.Size = UDim2.fromScale(x,y), UDim2.fromScale(w,h)
	item.BackgroundTransparency = 1
	item.Text, item.TextColor3 = value, color or white
	item.Font, item.TextWrapped, item.TextScaled = Enum.Font.FredokaOne, true, true
	item.ZIndex = 9
	local stroke = item:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", item)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Color, stroke.Thickness = black, 3
	stroke.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize
	return item
end
local function studs(parent, columns, rows)
	local pattern = get(parent, "Frame", "StudPattern")
	pattern.Size = UDim2.fromScale(1,1)
	pattern.BackgroundTransparency = 1
	pattern.ZIndex = parent.ZIndex+1
	pattern.ClipsDescendants = true
	for x=1,columns do
		for y=1,rows do
			local stud = get(pattern,"Frame",x.."_"..y)
			stud.Position = UDim2.fromScale((x-.75)/columns,(y-.7)/rows)
			stud.Size = UDim2.fromScale(.48/columns,.35/rows)
			stud.BackgroundColor3 = white
			stud.BackgroundTransparency = .93
			stud.BorderSizePixel = 0
			stud.ZIndex = pattern.ZIndex
			local edge = stud:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke",stud)
			edge.Color, edge.Thickness, edge.Transparency = black, 1.5, .9
		end
	end
end
function Style.Apply(gui)
	local window = gui.Shade.Window
	local header, content = window.Header, window.Content
	local page = content.UpgradesPage
	gui:SetAttribute("ReferenceUpgradeStyle", true)
	window.Size = UDim2.fromScale(.9,.82)
	window.BackgroundTransparency = 0
	window.BackgroundColor3 = Color3.fromRGB(5,19,1)
	local edge = window:FindFirstChildOfClass("UIStroke")
	if edge then edge.Color, edge.Thickness = black, 6; edge.StrokeSizingMode = Enum.StrokeSizingMode.FixedSize end
	local corner = window:FindFirstChildOfClass("UICorner")
	if corner then corner.CornerRadius = UDim.new(.01,0) end
	local limit = window:FindFirstChildOfClass("UISizeConstraint")
	if limit then limit.MaxSize,limit.MinSize = Vector2.new(820,650),Vector2.zero end
	header.Position, header.Size = UDim2.fromScale(.005,.005),UDim2.fromScale(.99,.165)
	surface(header,Color3.fromRGB(224,255,51),Color3.fromRGB(109,219,26),4)
	studs(header,24,3)
	local title = label(header,"TitleLabel","UPGRADES",.12,.1,.68,.8)
	title.TextXAlignment = Enum.TextXAlignment.Left
	header.CashLabel.Visible = false
	local close = header.CloseButton
	close.AnchorPoint=Vector2.new(1,0)
	close.Position,close.Size = UDim2.fromScale(.985,.035),UDim2.fromScale(.095,.93)
	close.TextStrokeTransparency = 0
	close.Text = ""
	for _, child in close:GetChildren() do if child:IsA("TextLabel") then child.Visible=false end end
	label(close,"CloseGlyph","X",.08,.03,.84,.94).Visible=true
	close.CloseGlyph.ZIndex=12
	surface(close,Color3.fromRGB(244,78,84),Color3.fromRGB(155,29,40),4)
	local square = close:FindFirstChildOfClass("UIAspectRatioConstraint") or Instance.new("UIAspectRatioConstraint",close)
	square.AspectRatio = 1
	local touchLimit=close:FindFirstChildOfClass("UISizeConstraint") or Instance.new("UISizeConstraint",close)
	touchLimit.MinSize=Vector2.new(44,44)
	local badge = get(header,"Frame","UpgradeBadge")
	badge.Position,badge.Size = UDim2.fromScale(-.02,-.15),UDim2.fromScale(.14,1.3)
	badge.BackgroundTransparency,badge.ZIndex = 1,9
	local aspect = badge:FindFirstChildOfClass("UIAspectRatioConstraint") or Instance.new("UIAspectRatioConstraint",badge)
	aspect.AspectRatio = 1
	label(badge,"Arrow1","⬆",0,-.05,1,.65,Color3.fromRGB(200,255,24))
	label(badge,"Arrow2","⬆",0,.38,1,.65,Color3.fromRGB(151,255,28))
	content.Position,content.Size = UDim2.fromScale(.015,.185),UDim2.fromScale(.97,.8)
	content.BackgroundTransparency = 1
	local contentEdge = content:FindFirstChildOfClass("UIStroke")
	if contentEdge then contentEdge.Transparency = 1 end
	for _,name in {"IntroLabel","FooterLabel"} do local item=page:FindFirstChild(name); if item then item.Visible=false end end
	local catalog=page.Catalog
	catalog.Position,catalog.Size = UDim2.fromScale(.015,.02),UDim2.fromScale(.97,.97)
	catalog.ScrollBarImageColor3 = black
	catalog.ScrollBarThickness = 10
	require(script.Parent.ShopCatalogLayout).Bind(catalog)
	local items=catalog.Items
	local layout=items:FindFirstChildOfClass("UIListLayout")
	layout.Padding=UDim.new(.025,0)
	local pad=items:FindFirstChildOfClass("UIPadding")
	if pad then
		pad.PaddingLeft,pad.PaddingRight=UDim.new(.02,0),UDim.new(.04,0)
		pad.PaddingTop,pad.PaddingBottom=UDim.new(.015,0),UDim.new(.025,0)
	end
	local definitions={
		{"StorageCard","Backpack Storage",Color3.fromRGB(210,170,123),Color3.fromRGB(126,95,66),"rbxassetid://119321111466594","",50,75,50},
		{"ChainCard","Chain Targets",Color3.fromRGB(238,98,41),Color3.fromRGB(149,48,24),"","⚡",1,2,75},
		{"MagnetCard","Collection Range",Color3.fromRGB(173,45,231),Color3.fromRGB(104,27,152),"","🧲",18,24,100},
	}
	for order,definition in definitions do
		local card=items:FindFirstChild(definition[1])
		if not card then continue end
		card.Size,card.LayoutOrder=UDim2.fromScale(1,.36),order
		surface(card,definition[3],definition[4],5)
		studs(card,20,4)
		card.DetailLabel.Visible=false
		local name=label(card,"NameLabel",definition[2],.235,.09,.735,.29)
		name.TextXAlignment=Enum.TextXAlignment.Left
		local icon=get(card,"ImageLabel","UpgradeIcon")
		icon.Image=definition[5]
		icon.Position,icon.Size=UDim2.fromScale(.015,.04),UDim2.fromScale(.205,.92)
		icon.BackgroundTransparency,icon.ScaleType,icon.ZIndex=1,Enum.ScaleType.Fit,9
		label(icon,"FallbackIcon",definition[6],0,0,1,1).Visible=icon.Image==""
		label(card,"CurrentValue",tostring(definition[7]),.235,.54,.14,.3)
		label(card,"ArrowLabel","▶",.395,.54,.085,.3,Color3.fromRGB(153,231,255))
		label(card,"NextValue",tostring(definition[8]),.49,.54,.14,.3,Color3.fromRGB(112,255,0))
		local buy=card.BuyButton
		buy.Position,buy.Size=UDim2.fromScale(.66,.49),UDim2.fromScale(.31,.41)
		buy.Text=""
		for _, child in buy:GetChildren() do if child:IsA("TextLabel") then child.Visible=false end end
		local priceLabel=label(buy,"PriceLabel","$"..definition[9],.025,.08,.95,.84)
		priceLabel.Visible,priceLabel.ZIndex=true,12
		buy.TextStrokeTransparency=0
		surface(buy,Color3.fromRGB(85,255,19),Color3.fromRGB(15,145,1),4)
		studs(buy,8,2)
		buy.ZIndex=10
		buy.StudPattern.ZIndex=11
		for _,stud in buy.StudPattern:GetChildren() do if stud:IsA("Frame") then stud.ZIndex=11 end end
	end
	catalog.CanvasPosition=Vector2.zero
	return gui
end
-- Shared styling primitives keep the other editable menus consistent.
Style.Surface = surface
Style.Label = label
Style.Studs = studs
Style.Get = get
return Style
