local Style={}
local Theme=require(script.Parent.UpgradeMenuStyle)
local get,label,surface=Theme.Get,Theme.Label,Theme.Surface
local Cores=require(script.Parent.StabilizerDefinitions)
function Style.Fit(gui)
	-- The launcher uses the full-screen coordinates of the other HUD buttons.
	-- Only the open Index window should be constrained by the Roblox top bar.
	local launchers=gui.Parent:FindFirstChild("CoreIndexButtonsGui")
	if not launchers then
		launchers=Instance.new("ScreenGui")
		launchers.Name="CoreIndexButtonsGui"
		launchers.ResetOnSpawn=false
		launchers.DisplayOrder=10
		launchers.Parent=gui.Parent
	end
	launchers.IgnoreGuiInset=true
	launchers.ScreenInsets=Enum.ScreenInsets.None
	local button=gui:FindFirstChild("IndexButton",true)
	if button then button.Parent=launchers end
	-- Reserve Roblox's top bar and device cutouts instead of drawing beneath them.
	gui.IgnoreGuiInset=false
	gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
	local items=gui.Shade.Panel.Cards:FindFirstChild("Items")
	if items then
		-- Borders extend outside cards, so keep a fixed inset inside the clipping frame.
		items.Position=UDim2.fromOffset(8,8)
		items.Size=UDim2.new(1,-16,1,-16)
	end
end
function Style.Apply(gui)
	gui:SetAttribute("ReferenceIndexStyle",true)
	local panel=gui.Shade.Panel
	panel.Size=UDim2.fromScale(.94,.86)
	surface(panel,Color3.fromRGB(43,78,81),Color3.fromRGB(36,45,39),6)
	panel.BackgroundTransparency=.15
	local limit=panel:FindFirstChildOfClass("UISizeConstraint") or Instance.new("UISizeConstraint",panel)
	limit.MinSize,limit.MaxSize=Vector2.zero,Vector2.new(1100,760)
	local header=panel.Header
	header.Position,header.Size=UDim2.fromScale(.005,.005),UDim2.fromScale(.99,.13)
	surface(header,Color3.fromRGB(48,68,70),Color3.fromRGB(37,48,51),4)
	label(header,"TitleLabel","INDEX - CORES",.035,.1,.78,.8).TextXAlignment=Enum.TextXAlignment.Left
	local close=header.CloseButton
	close.AnchorPoint=Vector2.new(1,0)
	close.Position,close.Size=UDim2.fromScale(.985,.035),UDim2.fromScale(.085,.93)
	close.Text=""
	surface(close,Color3.fromRGB(240,77,88),Color3.fromRGB(142,39,50),4)
	local aspect=close:FindFirstChildOfClass("UIAspectRatioConstraint") or Instance.new("UIAspectRatioConstraint",close)
	aspect.AspectRatio=1
	local touch=close:FindFirstChildOfClass("UISizeConstraint") or Instance.new("UISizeConstraint",close)
	touch.MinSize=Vector2.new(44,44)
	label(close,"CloseGlyph","X",.08,.03,.84,.94).ZIndex=12
	panel.CountLabel.Visible=false
	panel.HintLabel.Visible=false
	local cards=panel.Cards
	cards.Position,cards.Size=UDim2.fromScale(.025,.165),UDim2.fromScale(.625,.65)
	cards.AutomaticCanvasSize=Enum.AutomaticSize.None
	cards.CanvasSize=UDim2.fromScale(0,0)
	cards.ScrollBarThickness=6
	local items=get(cards,"Frame","Items")
	items.BackgroundTransparency=1
	items.Position,items.Size=UDim2.fromScale(.01,.01),UDim2.fromScale(.98,1)
	local grid=cards:FindFirstChild("CardGrid") or items:FindFirstChild("CardGrid")
	grid.Parent=items
	grid.CellSize,grid.CellPadding=UDim2.fromScale(.30,.45),UDim2.fromScale(.025,.035)
	grid.FillDirectionMaxCells=3
	for _,key in Cores.Order do
		local card=cards:FindFirstChild(key) or items:FindFirstChild(key)
		card.Parent=items
		local color=Cores.Rarities[Cores.Cores[key].Rarity]
		surface(card,color:Lerp(Color3.fromRGB(20,50,54),.7),color:Lerp(Color3.fromRGB(20,30,33),.45),3)
		card:FindFirstChildOfClass("UIStroke").Color=color
		label(card,"NameLabel",Cores.Cores[key].Name,.025,.025,.95,.15,color)
		card.Preview.Position,card.Preview.Size=UDim2.fromScale(.04,.19),UDim2.fromScale(.92,.58)
		card.Preview.ZIndex=6
		label(card,"RarityLabel",Cores.Cores[key].Rarity,.025,.76,.95,.1,color)
		label(card,"IncomeLabel","UNDISCOVERED",.025,.88,.95,.09)
		local select=get(card,"TextButton","SelectButton")
		select.Position,select.Size=UDim2.fromScale(0,0),UDim2.fromScale(1,1)
		select.BackgroundTransparency,select.Text,select.ZIndex=1,"",15
	end
	local detail=get(panel,"Frame","Details")
	detail.Position,detail.Size=UDim2.fromScale(.675,.165),UDim2.fromScale(.30,.65)
	surface(detail,Color3.fromRGB(45,74,76),Color3.fromRGB(62,56,31),4)
	label(detail,"NameLabel","Spark Core",.03,.025,.94,.10)
	label(detail,"RarityLabel","Common",.06,.14,.88,.09)
	local preview=get(detail,"ViewportFrame","Preview")
	preview.Position,preview.Size=UDim2.fromScale(.06,.25),UDim2.fromScale(.88,.42)
	preview.BackgroundTransparency,preview.ZIndex=1,6
	label(detail,"DiscoveryLabel","UNDISCOVERED",.04,.69,.92,.07)
	label(detail,"IncomeLabel","$2 / SEC",.04,.78,.92,.07,Color3.fromRGB(157,255,156))
	label(detail,"OddsLabel","Cracked: 45%\nCharged: 18%",.04,.87,.92,.10)
	local rewards=get(panel,"Frame","Rewards")
	rewards.Position,rewards.Size=UDim2.fromScale(.025,.845),UDim2.fromScale(.95,.13)
	surface(rewards,Color3.fromRGB(73,68,34),Color3.fromRGB(42,44,37),4)
	label(rewards,"RewardLabel","Discover 2 cores for +5% cash",.025,.04,.95,.37)
	label(rewards,"BonusLabel","PERMANENT CASH BONUS: +0%",.025,.49,.95,.23,Color3.fromRGB(140,255,121))
	local progress=panel:FindFirstChild("ProgressBar") or rewards.ProgressBar
	progress.Parent=rewards
	progress.Position,progress.Size=UDim2.fromScale(.025,.79),UDim2.fromScale(.95,.15)
	progress.BackgroundColor3=Color3.fromRGB(12,35,38)
	progress.Fill.BackgroundColor3=Color3.fromRGB(38,218,255)
	progress.ZIndex,progress.Fill.ZIndex=4,5
	label(progress,"CountLabel","0 / 2",0,0,1,1).ZIndex=9
	require(script.Parent.MenuLayers).Bind(gui.Parent)
	Style.Fit(gui)
	return gui
end
return Style
