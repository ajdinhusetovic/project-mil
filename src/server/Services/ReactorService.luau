-- Compatibility shim for old authored prompts and stale clients.
local Service = {}
local remote
function Service.Initialize(event) remote = event end
function Service.Create(player, plot)
	if not plot.Reactor then return end
	for _, item in plot.Reactor:GetDescendants() do
		if item:IsA("ProximityPrompt") then item.Enabled = false end
	end
end
function Service.Handle(player, action)
	if action ~= "ReactorClose" then
		remote:FireClient(player, "ReactorResult", false, "Sell stabilized cores at the Ore Buyer.")
	end
	remote:FireClient(player, "ReactorClosed")
end
function Service.Release(player) end
return Service
