local Layout = {}
local Theme = require(script.Parent.UpgradeMenuStyle)
local Definitions = require(script.Parent.OverchargeDefinitions)
local bound = setmetatable({}, {__mode="k"})
local managedHUDs = setmetatable({}, {__mode="k"})
local entries = {
	{"ShopButton", "Shop", Color3.fromRGB(255,208,76), Color3.fromRGB(239,130,31)},
	{"OverchargeButton", "Rebirth", Color3.fromRGB(154,245,112), Color3.fromRGB(52,160,64)},
	{"IndexButton", "Index", Color3.fromRGB(211,126,255), Color3.fromRGB(139,51,210)},
	{"TeleportButton", "Teleport", Color3.fromRGB(91,222,255), Color3.fromRGB(39,119,223)},
}
function Layout.Find(parent, name)
	local hud = managedHUDs[parent] or parent:FindFirstChild("HUDMenuGui")
	local group = hud and hud:FindFirstChild("SafeArea") and hud.SafeArea:FindFirstChild("Buttons")
	local managed = group and group:FindFirstChild(name)
	if managed then return managed end
	for _, gui in parent:GetChildren() do
		if gui:IsA("ScreenGui") then
			local button = gui:FindFirstChild(name, true)
			if button then return button end
		end
	end
end
function Layout.Build(parent)
 assert(not game:GetService("RunService"):IsRunning(), "Create HUDMenuGui through Studio Command Bar in Edit mode")
	Layout.CleanupLegacy(parent)
	local gui = managedHUDs[parent] or parent:FindFirstChild("HUDMenuGui") or Instance.new("ScreenGui")
	managedHUDs[parent] = gui
	gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "HUDMenuGui", false, 10
	gui.IgnoreGuiInset, gui.ScreenInsets = false, Enum.ScreenInsets.CoreUISafeInsets
	gui.Parent = parent
	local host = Theme.Get(gui,"Frame","SafeArea")
	host.Size, host.BackgroundTransparency = UDim2.fromScale(1,1), 1
	local group = Theme.Get(host,"Frame","Buttons")
	group.BackgroundTransparency = 1
	local grid = Theme.Get(group,"UIGridLayout","ButtonGrid")
	grid.SortOrder, grid.FillDirectionMaxCells = Enum.SortOrder.LayoutOrder, 2
	grid.CellPadding, grid.CellSize = UDim2.fromOffset(8,12), UDim2.fromOffset(76,76)
	group.Position, group.Size = UDim2.fromOffset(14,150), UDim2.fromOffset(160,164)
	for order, entry in entries do
		local name,title,top,bottom = table.unpack(entry)
		local button = Layout.Find(parent,name)
		if not button then
			button = Instance.new("ImageButton")
			button.Name = name
		end
		button.Parent = group
		button.LayoutOrder = order
		button:SetAttribute("ManagedHUDButton",true)
		if not button:GetAttribute("PolishedHUDStyle") then
			local image = button:IsA("ImageButton") and button.Image or ""
			for _, child in button:GetChildren() do
				if child:IsA("GuiObject") then child.Visible = false end
				if child:IsA("UIAspectRatioConstraint") or child:IsA("UISizeConstraint") then child.Parent=nil end
			end
			if button:IsA("ImageButton") then button.Image="" else button.Text="" end
			Theme.Surface(button,top,bottom,3)
			Theme.Studs(button,3,3)
			local corner=button:FindFirstChildOfClass("UICorner") or Instance.new("UICorner",button)
			corner.CornerRadius=UDim.new(.1,0)
			local icon=Theme.Get(button,"ImageLabel","MenuIcon")
			icon.BackgroundTransparency,icon.ScaleType,icon.ZIndex=1,Enum.ScaleType.Fit,3
			icon.Position,icon.Size=UDim2.fromScale(.14,.05),UDim2.fromScale(.72,.62)
			icon.Image=image
			if name=="ShopButton" then
				local basket=Theme.Get(icon,"Frame","Basket")
				basket.Position,basket.Size=UDim2.fromScale(.12,.35),UDim2.fromScale(.76,.58)
				Theme.Surface(basket,Color3.fromRGB(255,94,75),Color3.fromRGB(184,38,35),2)
				for index=1,3 do
					local slat=Theme.Get(basket,"Frame","Slat"..index)
					slat.Position,slat.Size=UDim2.fromScale(.15+(index-1)*.27,.18),UDim2.fromScale(.12,.62)
					slat.BackgroundColor3,slat.BorderSizePixel=Color3.fromRGB(94,27,23),0
				end
				for index,rotation in {-35,35} do
					local handle=Theme.Get(icon,"Frame","Handle"..index)
					handle.Position,handle.Size=UDim2.fromScale(index==1 and .28 or .57,.08),UDim2.fromScale(.12,.48)
					handle.Rotation,handle.BackgroundColor3,handle.BorderSizePixel=rotation,Color3.fromRGB(255,239,146),0
				end
			end
			local titleLabel=Theme.Label(button,"TitleLabel",title,.02,.68,.96,.27)
			titleLabel.Visible=true
			titleLabel.TextXAlignment=Enum.TextXAlignment.Center
			local limit=Instance.new("UITextSizeConstraint",titleLabel)
			limit.MinTextSize,limit.MaxTextSize=10,21
			button:SetAttribute("PolishedHUDStyle",true)
		end
	end
	local rebirth=group.OverchargeButton
	if not rebirth:FindFirstChild("ProgressLabel") then
		local badge=Theme.Label(rebirth,"ProgressLabel","0%",.58,-.08,.48,.26,Color3.fromRGB(255,216,77))
		badge.ZIndex=12
		local track=Theme.Get(rebirth,"Frame","ProgressTrack")
		track.Position,track.Size=UDim2.fromScale(.08,.94),UDim2.fromScale(.84,.045)
		track.BackgroundColor3,track.BorderSizePixel=Color3.fromRGB(27,69,31),0
		local fill=Theme.Get(track,"Frame","Fill")
		fill.Size,fill.BackgroundColor3,fill.BorderSizePixel=UDim2.fromScale(0,1),Color3.fromRGB(255,233,96),0
	end
	Layout.HideLegacyButtons(parent, group)
	return gui
end
-- Menu builders and StarterGui replication can introduce old launch buttons
-- after the managed HUD exists. Keep exactly one launcher for each menu.
function Layout.HideLegacyButtons(parent, group)
	for _, gui in parent:GetChildren() do
		if gui:IsA("ScreenGui") and gui.Name == "HUDMenuGui" and gui ~= managedHUDs[parent] then
			-- Retain the HUD instance whose buttons the controllers are bound to.
			gui.Enabled = false
		end
	end
	for _, item in parent:GetDescendants() do
		if not item:IsA("GuiButton") then continue end
		for _, entry in entries do
			if item.Name == entry[1] and item ~= group:FindFirstChild(entry[1]) then
				item:SetAttribute("ManagedHUDButton", nil)
				item.Visible = false
				item.Active = false
				item.Interactable = false
			end
		end
	end
end
function Layout.Progress(stats, count)
	local required = Definitions.Requirements(count).Level
	return math.clamp(math.floor(((stats.Level or 1) - 1) / (required - 1) * 100), 0, 100)
end
function Layout.Arrange(gui)
	local size=gui.SafeArea.AbsoluteSize
	if size.X<=0 or size.Y<=0 then return end
	local mobile=size.X<900 or size.Y<500
	local cell=mobile and 54 or 76
	local group=gui.SafeArea.Buttons
	group.ButtonGrid.CellSize=UDim2.fromOffset(cell,cell)
	group.Size=UDim2.fromOffset(cell*2+8,cell*2+12)
	group.Position=UDim2.fromOffset(mobile and 10 or 16,math.floor(math.clamp(size.Y*.23,52,210)))
	local surface=gui.Parent:FindFirstChild("SurfaceLoopHUD")
	local counters=surface and surface:FindFirstChild("Counters")
	if counters then
		counters.AnchorPoint=Vector2.new(0,1)
		counters.Position=UDim2.new(0,20,1,-25)
		local scale=counters:FindFirstChild("ResponsiveScale")
		if scale then scale.Scale=mobile and .65 or 1 end
	end
end
function Layout.Bind(parent)
	local gui=parent:WaitForChild("HUDMenuGui")
	managedHUDs[parent] = gui
	gui:WaitForChild("SafeArea"):WaitForChild("Buttons")
	Layout.HideLegacyButtons(parent, gui.SafeArea.Buttons)
	if bound[gui] then Layout.Arrange(gui); return gui end
	bound[gui]=true
	local queued = false
	local function clean()
		queued = false
		Layout.HideLegacyButtons(parent, gui.SafeArea.Buttons)
	end
	parent.DescendantAdded:Connect(function(item)
		if not item:IsA("GuiButton") and not item:IsA("ScreenGui") then return end
		if queued then return end
		queued = true
		task.defer(clean)
	end)
	gui.SafeArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() task.defer(Layout.Arrange,gui) end)
	Layout.Arrange(gui)
	return gui
end
-- Remove the earlier shop tabs and restore authored HUD positions once.
function Layout.CleanupLegacy(parent)
	for _, gui in parent:GetChildren() do
		if gui:IsA("ScreenGui") and table.find({"HUDMenuGui", "CoreIndexGui", "CoreIndexButtonsGui", "OverchargeGui", "TeleportGui"}, gui.Name) then
			gui.ResetOnSpawn = false
		end
	end
	local shop=parent:FindFirstChild("ShopGui")
	local content=shop and shop.Shade.Window.Content
	local tabs=content and content:FindFirstChild("ShopTabs")
	if tabs then
		tabs.Parent=nil
		for _,name in {"UpgradesPage","WeaponsPage"} do
			content[name].Position=UDim2.fromScale(0,0)
			content[name].Size=UDim2.fromScale(1,1)
		end
	end
	local surface=parent:FindFirstChild("SurfaceLoopHUD")
	local progress=parent:FindFirstChild("ProgressHUD")
	local items={}
	if surface and surface:FindFirstChild("Counters") then table.insert(items,surface.Counters) end
	if progress then
		for _,name in {"LevelBar","PowerLabel"} do
			local item=progress:FindFirstChild(name)
			if item then table.insert(items,item) end
		end
	end
	for _,item in items do
		for _,property in {"Position","Size","AnchorPoint"} do
			local attribute=property=="AnchorPoint" and "DesktopAnchor" or "Desktop"..property
			local value=item:GetAttribute(attribute)
			if value~=nil then item[property]=value; item:SetAttribute(attribute,nil) end
		end
	end
end
return Layout
