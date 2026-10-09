local Style = {}
local Theme = require(script.Parent.UpgradeMenuStyle)
local surface, label, studs, get = Theme.Surface, Theme.Label, Theme.Studs, Theme.Get
local Format = require(script.Parent.NumberFormat)
local function icon(parent, name, glyph)
	local image = get(parent, "ImageLabel", name)
	image.Position, image.Size = UDim2.fromScale(.015,.04), UDim2.fromScale(.205,.92)
	image.BackgroundTransparency, image.ScaleType, image.ZIndex = 1, Enum.ScaleType.Fit, 9
	label(image,"FallbackIcon",glyph,0,0,1,1).Visible = image.Image == ""
	return image
end
local function price(button, text)
	button.Text = ""
	for _, child in button:GetChildren() do if child:IsA("TextLabel") then child.Visible=false end end
	local value = label(button,"PriceLabel",text,.025,.08,.95,.84)
	value.Visible, value.ZIndex = true,12
	surface(button,Color3.fromRGB(85,255,19),Color3.fromRGB(15,145,1),4)
	button.ZIndex=10
	studs(button,8,2)
end
function Style.Weapons(gui)
	gui:SetAttribute("ReferenceWeaponStyle",true)
	local header=gui.Shade.Window.Header
	local cash=label(header,"CashLabel","$0",.70,.2,.16,.6,Color3.fromRGB(255,239,65))
	cash.Visible=false
	get(header,"Frame","WeaponBadge").BackgroundTransparency=1
	local badge=header.WeaponBadge
	badge.Position,badge.Size,badge.ZIndex=UDim2.fromScale(-.02,-.15),UDim2.fromScale(.14,1.3),9
	local aspect=badge:FindFirstChildOfClass("UIAspectRatioConstraint") or Instance.new("UIAspectRatioConstraint",badge)
	aspect.AspectRatio=1
	label(badge,"Glyph","⚡",0,0,1,1,Color3.fromRGB(255,229,31))
	badge.Visible=false
	local page=gui.Shade.Window.Content.WeaponsPage
	for _,name in {"IntroLabel","FooterLabel"} do local child=page:FindFirstChild(name); if child then child.Visible=false end end
	local catalog=page.Catalog
	catalog.Position,catalog.Size=UDim2.fromScale(.015,.02),UDim2.fromScale(.97,.97)
	catalog.ScrollBarImageColor3=Color3.new(0,0,0)
	catalog.ScrollBarThickness=10
	catalog:SetAttribute("CatalogLayoutBound",nil)
	require(script.Parent.ShopCatalogLayout).Bind(catalog)
	local items=catalog.Items
	items:FindFirstChildOfClass("UIListLayout").Padding=UDim.new(.025,0)
	local pad=items:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding",items)
	pad.PaddingLeft,pad.PaddingRight=UDim.new(.02,0),UDim.new(.04,0)
	pad.PaddingTop,pad.PaddingBottom=UDim.new(.015,0),UDim.new(.025,0)
	local weapons=require(script.Parent.WeaponDefinitions)
	for order,key in require(script.Parent.Config).WeaponOrder do
		local definition=weapons[key]
		local card=items:FindFirstChild(definition.CardName)
		if not card then
			local template = items:FindFirstChild("PlasmaCard") or items:FindFirstChild("StarterCard")
			if not template then error("Weapon catalog needs an authored template card") end
			card = template:Clone()
			card.Name = definition.CardName
			card.Parent = items
		end
		card.Size,card.LayoutOrder=UDim2.fromScale(1,.36),order
		surface(card,definition.Color,definition.Color:Lerp(Color3.fromRGB(25,20,45),.55),5)
		studs(card,20,4)
		icon(card,"WeaponIcon","⚡")
		label(card,"NameLabel",key,.235,.07,.735,.29).TextXAlignment=Enum.TextXAlignment.Left
		label(card,"DetailLabel","+"..Format.Compact(definition.PowerPerClick).." POWER / CLICK",.235,.43,.42,.24,Color3.fromRGB(255,237,72)).TextXAlignment=Enum.TextXAlignment.Left
		label(card,"LevelLabel","LEVEL "..definition.Level,.235,.73,.42,.16).TextXAlignment=Enum.TextXAlignment.Left
		local status=card:FindFirstChild("StatusLabel")
		if status then status.Visible=false end
		local buy=card:FindFirstChild("BuyButton") or get(card,"TextButton","BuyButton")
		buy.Position,buy.Size=UDim2.fromScale(.66,.49),UDim2.fromScale(.31,.41)
		price(buy,order==1 and "EQUIPPED" or "$"..Format.Compact(definition.Price))
	end
	catalog.CanvasPosition=Vector2.zero
end
function Style.TeleportButton(gui)
	local button = gui:FindFirstChild("TeleportButton")
	if not button then return end
	if not button:IsA("ImageButton") then
		local replacement = Instance.new("ImageButton")
		for _, property in {"Name", "Position", "Size", "AnchorPoint", "Rotation", "LayoutOrder",
			"ZIndex", "Visible", "Active", "Interactable", "Selectable", "AutoButtonColor", "Modal",
			"SizeConstraint", "AutomaticSize", "BorderSizePixel", "ClipsDescendants"} do
			replacement[property] = button[property]
		end
		for key, value in button:GetAttributes() do replacement:SetAttribute(key, value) end
		for _, child in button:GetChildren() do child.Parent = replacement end
		button.Parent = nil
		replacement.Parent = gui
		button = replacement
		button.ScaleType = Enum.ScaleType.Fit
	end
	button.BackgroundColor3 = Color3.new(0, 0, 0)
	button.BackgroundTransparency = 0.4
	return button
end
function Style.Teleport(gui)
	Style.TeleportButton(gui)
	local panel=gui.Shade.Panel
	panel.Size=UDim2.fromScale(.9,.78)
	surface(panel,Color3.fromRGB(6,20,31),Color3.fromRGB(6,20,31),6)
	local limit=panel:FindFirstChildOfClass("UISizeConstraint") or Instance.new("UISizeConstraint",panel)
	limit.MinSize,limit.MaxSize=Vector2.zero,Vector2.new(820,600)
	local header=panel.Header
	header.Position,header.Size=UDim2.fromScale(.005,.005),UDim2.fromScale(.99,.18)
	surface(header,Color3.fromRGB(83,230,255),Color3.fromRGB(26,129,239),4)
	studs(header,24,3)
	label(header,"TitleLabel","TELEPORT",.12,.1,.72,.8).TextXAlignment=Enum.TextXAlignment.Left
	icon(header,"TeleportIcon","🌍").Size=UDim2.fromScale(.10,.95)
	local close=header.CloseButton
	close.AnchorPoint=Vector2.new(1,0)
	close.Position,close.Size=UDim2.fromScale(.985,.035),UDim2.fromScale(.095,.93)
	close.Text=""
	surface(close,Color3.fromRGB(244,78,84),Color3.fromRGB(155,29,40),4)
	label(close,"CloseGlyph","X",.08,.03,.84,.94).ZIndex=12
	local destinations={
		{panel.WorldButton,"THIS WORLD","Mine • Shops • Sell • Stabilize","🌍",Color3.fromRGB(91,229,53),Color3.fromRGB(26,130,23)},
		{panel.PlotButton,"YOUR PLOT","Your personal island","🏝",Color3.fromRGB(192,91,255),Color3.fromRGB(105,37,165)},
	}
	for order,data in destinations do
		local card=data[1]
		card.Position,card.Size=UDim2.fromScale(.035,.225+(order-1)*.305),UDim2.fromScale(.93,.28)
		card.Text=""
		surface(card,data[5],data[6],5)
		studs(card,20,4)
		icon(card,"DestinationIcon",data[4])
		label(card,"TitleLabel",data[2],.235,.12,.57,.35).TextXAlignment=Enum.TextXAlignment.Left
		label(card,"DescriptionLabel",data[3],.235,.59,.57,.23).TextXAlignment=Enum.TextXAlignment.Left
		label(card,"GoLabel","▶",.84,.2,.12,.6,Color3.fromRGB(149,255,79))
	end
	label(panel,"StatusLabel","Choose a destination",.04,.88,.92,.065)
end
function Style.Apply(shop,teleport)
	Style.Weapons(shop)
	Style.Teleport(teleport)
end
return Style
