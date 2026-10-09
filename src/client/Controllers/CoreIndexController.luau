local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Input=game:GetService("UserInputService")
local Cores=require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Rewards=require(ReplicatedStorage.Shared.IndexRewards)
local Format=require(ReplicatedStorage.Shared.NumberFormat)
local Visuals=require(ReplicatedStorage.Shared.CoreVisuals)
local Builder=require(ReplicatedStorage.Shared.CoreIndexUIBuilder)
local player=Players.LocalPlayer
local gui=player.PlayerGui:FindFirstChild("CoreIndexGui") or Builder.Build(player.PlayerGui)
-- Migrate older authored Index GUIs once; styled instances remain editable.
if not gui:GetAttribute("DarkGridIndexStyle") then require(ReplicatedStorage.Shared.IndexMenuStyle).Apply(gui) end
require(ReplicatedStorage.Shared.IndexMenuStyle).Fit(gui)
local indexButton=require(ReplicatedStorage.Shared.HUDMenuLayout).Find(player.PlayerGui,"IndexButton")
local shade,panel=gui.Shade,gui.Shade.Panel
local updateMenuButtons=require(ReplicatedStorage.Shared.MenuLayers).Bind(player.PlayerGui)
local items=panel.Cards.Items
local displayed={}
local function refresh()
    local count=0
    for _,key in Cores.Order do
        local known=player:GetAttribute("DiscoveredCore_"..key)==true
        if known then count+=1 end
        local card=items[key]
        local definition=Cores.Cores[key]
        card.NameLabel.Text=known and definition.Name or "???"
        card.IncomeLabel.Text=known and Cores.SaleText(key) or "UNDISCOVERED"
        card.Preview.Visible=known
        card.UnknownLabel.Visible=not known
        if displayed[key]~=known then
            displayed[key]=known
            if known then Visuals.Show(card.Preview,key,false) end
        end
    end
    local target=Rewards.Next(count)
    local bonus=Rewards.Bonus(count)
    panel.Rewards.RewardLabel.Text=target and "Every 2 discovered cores grants +5% cash" or "INDEX COMPLETE! All rewards unlocked"
    panel.Rewards.BonusLabel.Text="Current Bonus: +"..Format.Compact(bonus*100).."% cash"
end
local function responsive()
    require(ReplicatedStorage.Shared.IndexMenuStyle).Resize(gui)
end
for _,key in Cores.Order do
    player:GetAttributeChangedSignal("DiscoveredCore_"..key):Connect(refresh)
end
indexButton.Activated:Connect(function()
    shade.Visible=not shade.Visible
    updateMenuButtons()
    if not shade.Visible then return end
    refresh(); responsive(); panel.Cards.CanvasPosition=Vector2.zero
end)
local function close()
    shade.Visible=false
    updateMenuButtons()
end
panel.Header.CloseButton.Activated:Connect(close)
Input.InputBegan:Connect(function(input) if input.KeyCode==Enum.KeyCode.Escape then close() end end)
shade.Visible=false
refresh(); responsive()
return true
