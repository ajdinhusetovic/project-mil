-- Client bootstrap. Controllers execute once when required.
require(script.Controllers.SurfaceUIController)
require(script.Controllers.ProgressUIController)
require(script.Controllers.ShopUIController)
require(script.Controllers.MiningController)
require(script.Controllers.CoreController)
require(script.Controllers.CoreIndexController)
require(script.Controllers.OverchargeController)
require(script.Controllers.StabilizerController)
require(script.Controllers.NPCSellController)

require(script.Controllers.IslandController)
require(game.ReplicatedStorage.Shared.MenuLayers).Bind(game.Players.LocalPlayer.PlayerGui)
