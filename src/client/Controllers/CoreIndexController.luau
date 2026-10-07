local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Input=game:GetService("UserInputService")
local Cores=require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Rewards=require(ReplicatedStorage.Shared.IndexRewards)
local Format=require(ReplicatedStorage.Shared.NumberFormat)
local Visuals=require(ReplicatedStorage.Shared.CoreVisuals)
local Builder=require(ReplicatedStorage.Shared.CoreIndexUIBuilder)
local player=Players.LocalPlayer
local gui=player.PlayerGui:FindFirstChild("CoreIndexGui") or Builder.Build(player.PlayerGui)
-- Migrate older authored Index GUIs once; styled instances remain editable.
if not gui:GetAttribute("ReferenceIndexStyle") then require(ReplicatedStorage.Shared.IndexMenuStyle).Apply(gui) end
require(ReplicatedStorage.Shared.IndexMenuStyle).Fit(gui)
local indexButton=player.PlayerGui.CoreIndexButtonsGui.IndexButton
local shade,panel=gui.Shade,gui.Shade.Panel
local updateMenuButtons=require(ReplicatedStorage.Shared.MenuLayers).Bind(player.PlayerGui)
local items=panel.Cards.Items
local selected=Cores.Order[1]
local displayed={}
local previewSignature
local scale=panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",panel)
local pop,progressTween
local function odds(grade,key)
    local weights=Cores.Grades[grade].Weights
    local total=0
    for _,weight in weights do total+=weight end
    for index,name in Cores.Order do if name==key then return string.format("%g%%",weights[index]/total*100) end end
end
local function refresh()
    local count=0
    for _,key in Cores.Order do
        local known=player:GetAttribute("DiscoveredCore_"..key)==true
        if known then count+=1 end
        local card=items[key]
        local definition=Cores.Cores[key]
        card.NameLabel.Text=known and definition.Name or "???"
        card.IncomeLabel.Text=known and Cores.IncomeText(key) or "UNDISCOVERED"
        local edge=card:FindFirstChildOfClass("UIStroke")
        edge.Color=key==selected and Color3.new(1,1,1) or Cores.Rarities[definition.Rarity]
        edge.Thickness=key==selected and 5 or 3
        if displayed[key]~=known then displayed[key]=known; Visuals.Show(card.Preview,key,not known) end
    end
    local detail=panel.Details
    local definition=Cores.Cores[selected]
    local known=player:GetAttribute("DiscoveredCore_"..selected)==true
    detail.NameLabel.Text=known and definition.Name or "???"
    detail.RarityLabel.Text=definition.Rarity
    detail.RarityLabel.TextColor3=Cores.Rarities[definition.Rarity]
    detail.DiscoveryLabel.Text=known and "DISCOVERED" or "STABILIZE TO DISCOVER"
    detail.DiscoveryLabel.TextColor3=known and Color3.fromRGB(148,255,146) or Color3.fromRGB(244,210,110)
    detail.IncomeLabel.Text=Cores.IncomeText(selected)
    detail.OddsLabel.Text="Cracked: "..odds("Cracked",selected).."\nCharged: "..odds("Charged",selected)
    local signature=selected..tostring(known)
    if previewSignature~=signature then previewSignature=signature; Visuals.Show(detail.Preview,selected,not known) end
    local target=Rewards.Next(count)
    local bonus=Rewards.Bonus(count)
    panel.Rewards.RewardLabel.Text=target and "Discover "..target.." cores for +"..Format.Compact(Rewards.Bonus(target)*100).."% cash" or "INDEX COMPLETE! All rewards unlocked"
    panel.Rewards.BonusLabel.Text="PERMANENT CASH BONUS: +"..Format.Compact(bonus*100).."%"
    local progress=panel.Rewards.ProgressBar
    progress.CountLabel.Text=count.." / "..(target or #Cores.Order)
    if progressTween then progressTween:Cancel() end
    progressTween=TweenService:Create(progress.Fill,TweenInfo.new(.3),{Size=UDim2.fromScale(math.min(1,count/(target or #Cores.Order)),1)})
    progressTween:Play()
end
local function responsive()
    local cards=panel.Cards
    local width,height=cards.AbsoluteWindowSize.X,cards.AbsoluteWindowSize.Y
    if width<=0 or height<=0 then return end
    local columns=width<380 and 2 or width<650 and 3 or 4
    items.Size=UDim2.new(1,-16,0,math.max(1,height-16))
    local grid=items.CardGrid
    grid.FillDirectionMaxCells=columns
    grid.CellSize=UDim2.fromScale(1/columns-.025,.45)
    grid.CellPadding=UDim2.fromScale(.025,.035)
end
local function updateCanvas()
    panel.Cards.CanvasSize=UDim2.fromOffset(0,math.ceil(items.CardGrid.AbsoluteContentSize.Y+16))
end
items.CardGrid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
panel.Cards:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(responsive)
for _,key in Cores.Order do
    items[key].SelectButton.Activated:Connect(function() selected=key; refresh() end)
    player:GetAttributeChangedSignal("DiscoveredCore_"..key):Connect(refresh)
end
indexButton.Activated:Connect(function()
    shade.Visible=not shade.Visible
    updateMenuButtons()
    if not shade.Visible then return end
    refresh(); responsive(); panel.Cards.CanvasPosition=Vector2.zero
    if pop then pop:Cancel() end
    scale.Scale=.85
    pop=TweenService:Create(scale,TweenInfo.new(.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1})
    pop:Play()
end)
local function close()
    shade.Visible=false
    updateMenuButtons()
end
panel.Header.CloseButton.Activated:Connect(close)
Input.InputBegan:Connect(function(input) if input.KeyCode==Enum.KeyCode.Escape then close() end end)
shade.Visible=false
refresh(); responsive(); updateCanvas()
return true
