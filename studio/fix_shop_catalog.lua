-- Paste in the Studio Command Bar in Edit mode after Rojo sync.
local layout = require(game.ReplicatedStorage.Shared.ShopCatalogLayout)
local content = game.StarterGui.ShopGui.Shade.Window.Content
for _, page in {content.UpgradesPage, content.WeaponsPage} do
	local catalog = page:FindFirstChild("Catalog")
	if catalog then layout.Bind(catalog); catalog.CanvasPosition = Vector2.zero end
end
print("Shop scrolling fixed. Edit cards, UIListLayout and UIPadding inside Catalog.Items.")
