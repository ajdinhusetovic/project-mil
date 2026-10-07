local Style = {}
local Theme = require(script.Parent.UpgradeMenuStyle)
local surface,label,studs,get=Theme.Surface,Theme.Label,Theme.Studs,Theme.Get
local purple=Color3.fromRGB(179,84,255)
local function box(parent,name,x,y,w,h,top,bottom)
	local frame=get(parent,"Frame",name)
	frame.Position,frame.Size=UDim2.fromScale(x,y),UDim2.fromScale(w,h)
	surface(frame,top,bottom,4)
	studs(frame,12,3)
	return frame
end
-- Keep the existing name and authored layout so menu bindings remain compatible.
function Style.Button(gui)
	local button = gui:FindFirstChild("OverchargeButton")
	if not button then return end
	if not button:IsA("ImageButton") then
		local replacement = Instance.new("ImageButton")
		for _, property in {"Name", "Position", "Size", "AnchorPoint", "Rotation", "LayoutOrder",
			"ZIndex", "Visible", "Active", "Interactable", "Selectable", "AutoButtonColor", "Modal", "SizeConstraint", "AutomaticSize", "BackgroundColor3",
			"BackgroundTransparency", "BorderSizePixel", "ClipsDescendants"} do
			replacement[property] = button[property]
		end
		for key, value in button:GetAttributes() do replacement:SetAttribute(key, value) end
		for _, child in button:GetChildren() do child.Parent = replacement end
		button.Parent = nil
		replacement.Parent = gui
		button = replacement
		button.ScaleType = Enum.ScaleType.Fit
	end
	local bolt = button:FindFirstChild("BoltIcon")
	if bolt then bolt.Visible = false end
	local title = button:FindFirstChild("TitleLabel")
	if title then title.Text = "REBIRTH" end
	return button
end
function Style.Apply(gui)
	gui:SetAttribute("ReferenceRebirthStyle",true)
	local panel=gui.Shade.Panel
	panel.Size=UDim2.fromScale(.9,.84)
	surface(panel,Color3.fromRGB(19,25,13),Color3.fromRGB(19,25,13),6)
	panel.BackgroundTransparency=.12
	local limit=panel:FindFirstChildOfClass("UISizeConstraint") or Instance.new("UISizeConstraint",panel)
	limit.MinSize,limit.MaxSize=Vector2.zero,Vector2.new(760,650)
	local header=panel.Header
	header.Position,header.Size=UDim2.fromScale(.005,.005),UDim2.fromScale(.99,.15)
	surface(header,Color3.fromRGB(198,125,255),Color3.fromRGB(131,69,232),4)
	studs(header,24,3)
	label(header,"TitleLabel","REBIRTH",.13,.12,.68,.76).TextXAlignment=Enum.TextXAlignment.Left
	local icon=get(header,"ImageLabel","RebirthIcon")
	icon.Position,icon.Size=UDim2.fromScale(-.025,-.12),UDim2.fromScale(.15,1.25)
	icon.BackgroundTransparency,icon.ScaleType,icon.ZIndex=1,Enum.ScaleType.Fit,9
	label(icon,"FallbackIcon","🔄",0,0,1,1).Visible=icon.Image==""
	local close=header.CloseButton
	close.AnchorPoint=Vector2.new(1,0)
	close.Position,close.Size=UDim2.fromScale(.985,.035),UDim2.fromScale(.095,.93)
	close.Text=""
	surface(close,Color3.fromRGB(244,78,84),Color3.fromRGB(155,29,40),4)
	label(close,"CloseGlyph","X",.08,.03,.84,.94).ZIndex=12
	for _,name in {"CountLabel","PowerReward","CashReward"} do panel[name].Visible=false end
	for i,key in {"Power","Cash"} do
		local y=.215+(i-1)*.13
		local current=box(panel,key.."Current",.055,y,.40,.11,Color3.fromRGB(107,109,111),Color3.fromRGB(55,57,61))
		local nextBox=box(panel,key.."Next",.545,y,.40,.11,purple,Color3.fromRGB(121,30,209))
		for _,frame in {current,nextBox} do
			local image=get(frame,"ImageLabel","Icon")
			image.Position,image.Size=UDim2.fromScale(-.01,-.08),UDim2.fromScale(.22,1.16)
			image.BackgroundTransparency,image.ScaleType,image.ZIndex=1,Enum.ScaleType.Fit,9
			-- Replace these editable icons with your own artwork in Studio.
			label(image,"FallbackIcon",key=="Power" and "⚡" or "💵",0,0,1,1).Visible=image.Image==""
			local power,cash=require(script.Parent.OverchargeDefinitions).Multipliers(frame==current and 0 or 1)
			label(frame,"ValueLabel",tostring(key=="Power" and power or cash)..(key=="Power" and "x Power" or "x Money"),.20,.08,.78,.84)
		end
		label(panel,key.."Arrow","▶",.465,y,.07,.11,Color3.fromRGB(178,239,255))
	end
	label(panel,"ResetLabel","Power, level, cash, weapons & upgrades reset",.04,.49,.92,.055,Color3.fromRGB(255,111,126))
	label(panel,"KeepLabel","Keep your cores, reactor, stabilizations & Index",.04,.55,.92,.04,Color3.fromRGB(162,255,157))
	for i,key in {"Level","Power","Cash"} do
		local x=.055+(i-1)*.305
		box(panel,key.."RequirementBar",x,.62,.28,.085,Color3.fromRGB(43,210,22),Color3.fromRGB(32,112,11))
		local requirement=label(panel,key.."Requirement",key..": 0 / 0",x+.005,.632,.27,.061)
		requirement.ZIndex=12
	end
	label(panel,"StatusLabel","Meet all requirements to rebirth",.05,.73,.9,.047)
	local confirm=panel.ConfirmButton
	confirm.Position,confirm.Size=UDim2.fromScale(.10,.81),UDim2.fromScale(.80,.13)
	confirm.Text=""
	surface(confirm,Color3.fromRGB(55,245,17),Color3.fromRGB(13,131,4),4)
	studs(confirm,20,3)
	label(confirm,"ButtonLabel","Rebirth",.04,.05,.92,.9).ZIndex=12
	Style.Button(gui)
	return gui
end
return Style
