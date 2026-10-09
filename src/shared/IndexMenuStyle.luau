local Style = {}
local Theme = require(script.Parent.UpgradeMenuStyle)
local get, label, surface = Theme.Get, Theme.Label, Theme.Surface
local Cores = require(script.Parent.StabilizerDefinitions)
local bound = setmetatable({}, {__mode="k"})
function Style.Fit(gui)
 local launchers = gui.Parent:FindFirstChild("CoreIndexButtonsGui")
 if not launchers then
  launchers = Instance.new("ScreenGui")
  launchers.Name, launchers.ResetOnSpawn, launchers.DisplayOrder = "CoreIndexButtonsGui", false, 10
  launchers.Parent = gui.Parent
 end
 launchers.IgnoreGuiInset, launchers.ScreenInsets = true, Enum.ScreenInsets.None
 local button = gui:FindFirstChild("IndexButton", true)
 if button and not button:GetAttribute("ManagedHUDButton") then button.Parent = launchers end
 gui.IgnoreGuiInset, gui.ScreenInsets = true, Enum.ScreenInsets.None
 gui.Shade.AnchorPoint=Vector2.zero
 gui.Shade.Position=UDim2.fromScale(0,0)
 gui.Shade.SizeConstraint=Enum.SizeConstraint.RelativeXY
 gui.Shade.Size=UDim2.fromScale(1,1)
 Style.Resize(gui)
 if not bound[gui] then
  bound[gui]=true
  gui.Shade:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() Style.Resize(gui) end)
 end
end
function Style.Resize(gui)
 local panel=gui.Shade.Panel
 local available=gui.Shade.AbsoluteSize
 if available.X<=0 or available.Y<=0 then return end
 -- Scale one desktop composition instead of reflowing cards on phones.
 panel.AnchorPoint=Vector2.new(.5,.5)
 panel.Position=UDim2.fromScale(.5,.5)
 panel.SizeConstraint=Enum.SizeConstraint.RelativeXY
 panel.Size=UDim2.fromOffset(800,473)
 for _,child in panel:GetChildren() do
  if child:IsA("UIAspectRatioConstraint") or child:IsA("UISizeConstraint") then child.Parent=nil end
 end
 local scale=panel:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",panel)
 scale.Name="IndexResponsiveScale"
 scale.Scale=math.min(1,available.X*.9/800,available.Y*.86/473)
 local cards=panel.Cards
 cards.Position,cards.Size=UDim2.fromScale(.025,.16),UDim2.fromScale(.95,.64)
 cards.AutomaticCanvasSize=Enum.AutomaticSize.None
 local items=cards.Items
 local width,height=800*.95,473*.64
 items.Position,items.Size=UDim2.fromOffset(4,4),UDim2.new(1,-14,0,height-8)
 local grid=items.CardGrid
 local rows=math.ceil(#Cores.Order/4)
 local cellWidth=math.floor((width-14-9)/4)
 local cellHeight=math.floor((height-8-(rows-1)*3)/rows)
 grid.FillDirectionMaxCells=4
 grid.CellSize,grid.CellPadding=UDim2.fromOffset(cellWidth,cellHeight),UDim2.fromOffset(3,3)
 local aspect=grid:FindFirstChildOfClass("UIAspectRatioConstraint")
 if aspect then aspect.AspectRatio=cellWidth/cellHeight end
 cards.CanvasSize=UDim2.fromOffset(0,rows*cellHeight+(rows-1)*3+8)
end
function Style.Apply(gui)
 gui:SetAttribute("ReferenceIndexStyle", true)
 gui:SetAttribute("DarkGridIndexStyle", true)
 local panel = gui.Shade.Panel
 panel.Position = UDim2.fromScale(.5,.5)
 panel.SizeConstraint = Enum.SizeConstraint.RelativeXY
 panel.Size = UDim2.fromScale(.90, .90)
 surface(panel, Color3.fromRGB(24,26,33), Color3.fromRGB(14,16,22), 5)
 panel.BackgroundTransparency = .08
 local limit = panel:FindFirstChildOfClass("UISizeConstraint") or Instance.new("UISizeConstraint", panel)
 limit.MinSize, limit.MaxSize = Vector2.zero, Vector2.new(800,760)
 local header = panel.Header
 header.Position, header.Size = UDim2.fromScale(.015,.015), UDim2.fromScale(.97,.12)
 surface(header, Color3.fromRGB(169,70,219), Color3.fromRGB(103,36,156), 3)
 Theme.Studs(header,16,2)
 local title = label(header,"TitleLabel","Index",.18,.08,.64,.84)
 title.TextXAlignment = Enum.TextXAlignment.Center
 local book = get(header,"ImageLabel","IndexIcon")
 book.Position, book.Size = UDim2.fromScale(.025,.1), UDim2.fromScale(.13,.8)
 book.BackgroundTransparency, book.ScaleType, book.ZIndex = 1, Enum.ScaleType.Fit, 9
 book.Image = "rbxassetid://97629410614205"
 local close = header.CloseButton
 close.AnchorPoint = Vector2.new(1,.5)
 close.Position, close.Size = UDim2.fromScale(.98,.5), UDim2.fromScale(.12,.8)
 close.Text = ""
 surface(close, Color3.fromRGB(249,76,116), Color3.fromRGB(166,27,62), 3)
 local aspect = close:FindFirstChildOfClass("UIAspectRatioConstraint") or Instance.new("UIAspectRatioConstraint",close)
 aspect.AspectRatio = 1
 local touch = close:FindFirstChildOfClass("UISizeConstraint") or Instance.new("UISizeConstraint",close)
 touch.MinSize = Vector2.new(32,32)
 label(close,"CloseGlyph","X",.08,.03,.84,.94).ZIndex = 12
 panel.CountLabel.Visible, panel.HintLabel.Visible = false, false
 local detail = panel:FindFirstChild("Details")
 if detail then detail.Visible = false end
 local cards = panel.Cards
 cards.Position, cards.Size = UDim2.fromScale(.025,.16), UDim2.fromScale(.95,.64)
 cards.BackgroundTransparency, cards.BorderSizePixel = 1, 0
 cards.AutomaticCanvasSize, cards.CanvasSize = Enum.AutomaticSize.None, UDim2.fromScale(0,0)
 cards.ScrollBarThickness, cards.ScrollBarImageColor3 = 5, Color3.fromRGB(115,119,133)
 local items = get(cards,"Frame","Items")
 items.SizeConstraint = Enum.SizeConstraint.RelativeXY
 items.BackgroundTransparency = 1
 items.Position, items.Size = UDim2.fromOffset(4,4), UDim2.new(1,-14,1,-8)
 local grid = cards:FindFirstChild("CardGrid") or items:FindFirstChild("CardGrid")
 grid.Parent = items
 local cellWidth = items.AbsoluteSize.X > 0 and math.floor((items.AbsoluteSize.X-9)/4) or 180
 grid.CellSize, grid.CellPadding = UDim2.fromOffset(cellWidth,cellWidth*1.12), UDim2.fromOffset(3,3)
 grid.FillDirectionMaxCells = 4
 grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
 for _, key in Cores.Order do
  local card = cards:FindFirstChild(key) or items:FindFirstChild(key)
  card.Parent = items
  local definition = Cores.Cores[key]
  local color = Cores.Rarities[definition.Rarity]
  surface(card,Color3.fromRGB(15,17,24),Color3.fromRGB(8,10,15),2)
  local corner = card:FindFirstChildOfClass("UICorner")
  if corner then corner.CornerRadius = UDim.new(0,0) end
  label(card,"RarityLabel",definition.Rarity,.025,.035,.95,.14,color)
  card.Preview.Position, card.Preview.Size = UDim2.fromScale(.09,.21), UDim2.fromScale(.82,.51)
  card.Preview.ZIndex = 6
  card.Preview.Visible = false
  label(card,"UnknownLabel","?",.18,.21,.64,.51,Color3.fromRGB(244,67,133)).Visible = true
  label(card,"NameLabel","???",.025,.76,.95,.16)
  card.IncomeLabel.Visible = false
  local select = card:FindFirstChild("SelectButton")
  if select then select.Visible = false end
 end
 local rewards = get(panel,"Frame","Rewards")
 rewards.Position, rewards.Size = UDim2.fromScale(.025,.83), UDim2.fromScale(.95,.145)
 rewards.BackgroundTransparency, rewards.BorderSizePixel = 1, 0
 local edge = rewards:FindFirstChildOfClass("UIStroke")
 if edge then edge.Transparency = 1 end
 label(rewards,"RewardLabel","Every 2 discovered cores grants +5% cash",.015,.02,.97,.38)
 label(rewards,"BonusLabel","Current Bonus: +0% cash",.015,.52,.97,.38,Color3.fromRGB(120,245,112))
 local progress = panel:FindFirstChild("ProgressBar") or rewards:FindFirstChild("ProgressBar")
 if progress then progress.Parent = rewards; progress.Visible = false end
 require(script.Parent.MenuLayers).Bind(gui.Parent)
 Style.Fit(gui)
 return gui
end
return Style
