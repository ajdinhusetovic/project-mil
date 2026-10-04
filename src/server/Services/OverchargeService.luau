local Data = require(script.Parent.PlayerDataService)
local Service = {}
local lastRequest = {}
local remote, resetRun
function Service.Initialize(event, resetCallback)
	remote, resetRun = event, resetCallback
end
function Service.Handle(player, expectedCount)
	local now = os.clock()
	if now - (lastRequest[player] or -math.huge) < 1 then return end
	lastRequest[player] = now
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		remote:FireClient(player, "OverchargeResult", false, "Respawn before Overcharging.")
		return
	end
	local success, result = Data.Overcharge(player, expectedCount)
	if success then resetRun(player) end
	remote:FireClient(player, "OverchargeResult", success, result)
end
function Service.Release(player) lastRequest[player] = nil end
return Service
