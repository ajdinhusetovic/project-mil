-- Paste the entire file into Studio's Command Bar in EDIT mode after Rojo sync.
-- Preserve authored screens and add the controls previously created during Play.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before authoring UI")
local starter = game:GetService("StarterGui")
local fresh = game.ReplicatedStorage.Shared:Clone()
fresh.Name = "AuthoredUIBuildCache"
fresh.Parent = game.ReplicatedStorage
for _, name in {"SurfaceLoopHUD", "ProgressHUD", "FeedbackHUD", "ShopGui"} do
 assert(starter:FindFirstChild(name), "Missing StarterGui." .. name .. "; run its studio/build_* script first")
end
require(fresh.SurfacePowerHUD).Ensure(starter.SurfaceLoopHUD)
require(fresh.CoreIndexUIBuilder).Build(starter)
require(fresh.OverchargeUIBuilder).Build(starter)
require(fresh.IslandUIBuilder).Build(starter)
require(fresh.StabilizerOddsUIBuilder).Build(starter)
require(fresh.MobileMiningUIBuilder).Build(starter)
require(fresh.HotbarUIBuilder).Build(starter)
require(fresh.WorldUIBuilder).BuildTemplates()

local progress = starter.ProgressHUD
if not progress:FindFirstChild("DepthLabel") then
 local depth = progress.PowerLabel:Clone()
 depth.Name, depth.Text, depth.Visible = "DepthLabel", "DEPTH: 0 STUDS", false
 depth.Parent = progress
end
if not progress:FindFirstChild("ReturnButton") then
 local button = Instance.new("TextButton")
 button.Name, button.Text = "ReturnButton", "RETURN"
 button.AnchorPoint, button.Position = Vector2.new(.5,0), UDim2.new(.5,0,0,174)
 button.Size = UDim2.fromOffset(190,44)
 button.BackgroundColor3, button.TextColor3 = Color3.fromRGB(35,194,81), Color3.new(1,1,1)
 button.Font, button.TextSize, button.Visible = Enum.Font.FredokaOne, 25, false
 button.Parent = progress
 Instance.new("UICorner", button).CornerRadius = UDim.new(0,9)
 local stroke = Instance.new("UIStroke", button)
 stroke.Color, stroke.Thickness = Color3.new(0,0,0), 3
end
local mining = starter:FindFirstChild("MiningDemoHUD")
if not mining then
 mining = Instance.new("ScreenGui")
 mining.Name, mining.ResetOnSpawn = "MiningDemoHUD", false
 mining.Parent = starter
end
if not mining:FindFirstChild("Target") then
 local target = Instance.new("TextLabel")
 target.Name, target.Text = "Target", ""
 target.Size, target.Position = UDim2.fromOffset(280,28), UDim2.new(.5,-140,.72,0)
 target.BackgroundTransparency, target.TextColor3 = 1, Color3.fromRGB(229,241,255)
 target.Font, target.TextSize = Enum.Font.GothamBold, 16
 target.Parent = mining
end

-- Apply older style migrations only once, during authoring.
if not starter.CoreIndexGui:GetAttribute("DarkGridIndexStyle") then
 require(fresh.IndexMenuStyle).Apply(starter.CoreIndexGui)
else
 require(fresh.IndexMenuStyle).Fit(starter.CoreIndexGui)
end
if not starter.OverchargeGui:GetAttribute("ReferenceRebirthStyle") then
 require(fresh.RebirthMenuStyle).Apply(starter.OverchargeGui)
end
if not starter.ShopGui:GetAttribute("ReferenceWeaponStyle") then
 require(fresh.ShopTeleportMenuStyle).Weapons(starter.ShopGui)
end
require(fresh.PowerFeedbackStyle).Apply(starter.FeedbackHUD.PowerTemplate)
local layout = require(fresh.HUDMenuLayout)
local hud = layout.Build(starter)
layout.Arrange(hud)
for _, gui in starter:GetChildren() do
 if gui:IsA("ScreenGui") then
  gui.ResetOnSpawn = false
  local shade = gui:FindFirstChild("Shade")
  if shade then shade.Visible = false end
 end
end
for _, name in {"ReactorGui", "CoreHUD", "StabilizerGui", "MaterialsHUD"} do
 local retired = starter:FindFirstChild(name)
 if retired and retired:IsA("ScreenGui") then retired.Enabled = false end
end
fresh.Parent = nil
game.Selection:Set({hud})
print("AUTHORED UI READY: save/publish StarterGui; runtime now binds authored screens only")
