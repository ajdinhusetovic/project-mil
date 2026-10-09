-- Client bootstrap. Controllers execute once when required.
if not game:IsLoaded() then game.Loaded:Wait() end
require(script.Controllers.HotbarController)
require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("MenuLayers")).Bind(game.Players.LocalPlayer:WaitForChild("PlayerGui"))
require(script.Controllers.SurfaceUIController)
require(game.ReplicatedStorage.Shared.HUDMenuLayout).Bind(game.Players.LocalPlayer.PlayerGui)
require(script.Controllers.ProgressUIController)
require(script.Controllers.ShopUIController)
require(script.Controllers.MiningController)
require(script.Controllers.AFKTrainingController)
require(script.Controllers.CoreController)
require(script.Controllers.CoreIndexController)
require(script.Controllers.OverchargeController)
require(script.Controllers.StabilizerController)
require(script.Controllers.NPCSellController)

require(script.Controllers.IslandController)
require(script.Controllers.HUDMenuController)
require(game.ReplicatedStorage.Shared.MenuLayers).Bind(game.Players.LocalPlayer.PlayerGui)
