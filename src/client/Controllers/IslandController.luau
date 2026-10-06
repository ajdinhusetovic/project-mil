local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Input=game:GetService("UserInputService")
local Prompts=game:GetService("ProximityPromptService")
local Builder=require(ReplicatedStorage.Shared.IslandUIBuilder)
local Format=require(ReplicatedStorage.Shared.NumberFormat)
local Cores=require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Visuals=require(ReplicatedStorage.Shared.CoreVisuals)
local player=Players.LocalPlayer
local remote=ReplicatedStorage:WaitForChild("MiningDemo")
local teleport,reactor=Builder.Build(player:WaitForChild("PlayerGui"))
local tp,rp=teleport.Shade.Panel,reactor.Shade.Panel
local snapshot
local teleportPending=false
local reactorPending=false
local installedCards,inventoryCards={},{}
for _,button in {tp.WorldButton,tp.PlotButton} do
	local icon=button:FindFirstChild("DestinationIcon")
	if icon and icon:FindFirstChild("FallbackIcon") then
		local function updateIcon() icon.FallbackIcon.Visible=icon.Image=="" end
		icon:GetPropertyChangedSignal("Image"):Connect(updateIcon)
		updateIcon()
	end
end
local function pop(panel)
	local scale=panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",panel)
	scale.Scale=0.88
	TweenService:Create(scale,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
end
local function closeReactor()
	reactor.Shade.Visible=false
	reactorPending=false
	remote:FireServer("ReactorClose")
end
local function request(action,id)
	if reactorPending or not reactor.Shade.Visible then return end
	reactorPending=true
	rp.StatusLabel.Text="Updating..."
	remote:FireServer(action,id)
end
local function layout(area,count)
	local columns=area.AbsoluteSize.X < 600 and 2 or 5
	local rows=math.max(1,math.ceil(count/columns))
	area.CardGrid.FillDirectionMaxCells=columns
	area.CardGrid.CellSize=UDim2.fromScale(columns==2 and 0.48 or 0.18,0.96/rows)
	area.CardGrid.CellPadding=UDim2.fromScale(0.02,0.025/rows)
	-- Canvas scale uses the scrolling frame's parent, rather than its window.
	area.CanvasSize=UDim2.fromScale(0,rows*area.Size.Y.Scale)
end
local function card(area,cache,key,record,index,installed)
	local item=cache[key]
	if not item then
		item=reactor.CoreCardTemplate:Clone()
		item.Name=key
		item.Visible=true
		item.Parent=area
		cache[key]=item
		item.Activated:Connect(function()
			local id=item:GetAttribute("CoreId")
			if id then request(installed and "ReactorRemove" or "ReactorInstall",id) end
		end)
	end
	item.LayoutOrder=index
	item:SetAttribute("CoreId",record and record.Id or nil)
	item.Active=record~=nil
	item.AutoButtonColor=record~=nil
	item.NameLabel.Text=record and string.upper(record.Name) or "EMPTY SLOT"
	item.MutationLabel.Text=record and Cores.MutationText(record) or ""
	item.MutationLabel.Visible=item.MutationLabel.Text~=""
	item.IncomeLabel.Text=record and Cores.IncomeText(record) or ""
	item.ActionLabel.Text=record and (installed and "CLICK TO REMOVE" or "CLICK TO INSTALL") or "INSTALL A CORE"
	local signature=record and record.Type..":"..record.Mutation or "Empty"
	if item:GetAttribute("PreviewSignature")~=signature then
		item:SetAttribute("PreviewSignature",signature)
		if record then Visuals.Show(item.Preview,record.Type,false,record.Mutation)
		else item.Preview:ClearAllChildren() end
	end
end
local function refresh()
	if not snapshot then return end
	rp.RateLabel.Text="$"..Format.Compact(snapshot.CashRate).." / SEC"
	rp.BonusLabel.Text="CASH BONUS "..Format.Compact(snapshot.CashMultiplier).."x"
	rp.SlotCountLabel.Text=Format.Compact(#snapshot.Installed).." / "..Format.Compact(snapshot.Capacity).." INSTALLED"
	rp.CollectButton.Text="COLLECT $"..Format.Compact(snapshot.Stored)
	for index=1,snapshot.Capacity do card(rp.Slots,installedCards,"Slot"..index,snapshot.Installed[index],index,true) end
	local current={}
	for index,record in snapshot.Inventory do
		current[record.Id]=true
		card(rp.Inventory,inventoryCards,record.Id,record,index,false)
	end
	for id,item in inventoryCards do
		if not current[id] then item:Destroy(); inventoryCards[id]=nil end
	end
	rp.EmptyLabel.Visible=#snapshot.Inventory==0
	layout(rp.Slots,snapshot.Capacity)
	layout(rp.Inventory,#snapshot.Inventory)
end
rp.Slots:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
rp.Inventory:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
teleport.TeleportButton.Activated:Connect(function()
	closeReactor()
	teleport.Shade.Visible=not teleport.Shade.Visible
	tp.StatusLabel.Text="Choose a destination"
	if teleport.Shade.Visible then pop(tp) end
end)
local function travel(destination)
	if teleportPending then return end
	teleportPending=true
	tp.StatusLabel.Text="Teleporting..."
	remote:FireServer("Teleport",destination)
end
tp.WorldButton.Activated:Connect(function() travel("World") end)
tp.PlotButton.Activated:Connect(function() travel("Plot") end)
tp.Header.CloseButton.Activated:Connect(function() teleport.Shade.Visible=false end)
rp.Header.CloseButton.Activated:Connect(closeReactor)
rp.EquipBestButton.Activated:Connect(function() request("ReactorEquipBest") end)
rp.CollectButton.Activated:Connect(function() request("ReactorCollect") end)
Prompts.PromptShown:Connect(function(prompt)
	if prompt.Name=="ReactorPrompt" and prompt:GetAttribute("OwnerUserId")~=player.UserId then prompt.Enabled=false end
end)
Input.InputBegan:Connect(function(input)
	if input.KeyCode==Enum.KeyCode.Escape then teleport.Shade.Visible=false; closeReactor() end
end)
remote.OnClientEvent:Connect(function(action,first,second)
	if action=="TeleportResult" then
		teleportPending=false
		if first then teleport.Shade.Visible=false; closeReactor()
		else tp.StatusLabel.Text=second or "Could not teleport." end
	elseif action=="ReactorSnapshot" then snapshot=first; refresh()
	elseif action=="ReactorOpen" then
		teleport.Shade.Visible=false
		reactor.Shade.Visible=true
		reactorPending=false
		rp.StatusLabel.Text="Click installed cores to remove; stored cores to install"
		refresh(); pop(rp)
	elseif action=="ReactorClosed" then reactor.Shade.Visible=false; reactorPending=false
	elseif action=="ReactorResult" then
		reactorPending=false
		rp.StatusLabel.Text=first and "Reactor updated!" or second
	end
end)
teleport.Shade.Visible=false
reactor.Shade.Visible=false
return true
