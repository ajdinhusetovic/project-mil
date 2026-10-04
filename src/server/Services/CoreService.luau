local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Config = require(ReplicatedStorage.Shared.Config)
local Grid = require(ReplicatedStorage.Shared.MineGrid)
local PlayerDataService = require(script.Parent.PlayerDataService)
local MineService = require(script.Parent.MineService)
local CoreToolService = require(script.Parent.CoreToolService)

local CoreService = {}
local sessions = {}
local remote
local rng = Random.new()

function CoreService.Initialize(event)
	remote = event
end

function CoreService.Create(player)
	sessions[player] = { Drops = {}, Broken = 0, LastCollect = -math.huge }
end

function CoreService.SendInventory(player)
	CoreToolService.Sync(player)
	local data = PlayerDataService.Get(player)
	if data then remote:FireClient(player, "CoreInventory", data.UnknownCores) end
end

function CoreService.TryDiscover(player, blockId)
	local session = sessions[player]
	local data = PlayerDataService.Get(player)
	if not session or not data then return end
	session.Broken += 1
	local pending = 0
	for _ in session.Drops do pending += 1 end
	if pending >= Config.Cores.MaxPending then return end
	local x, depth, z = Grid.Coordinates(blockId)
	local layer = Grid.Layer(depth)
	local guaranteed = not data.HasCollectedCore and pending == 0 and session.Broken >= Config.Cores.FirstDiscoveryAfter
	if not guaranteed and rng:NextNumber() >= layer.CoreChance then return end
	local grade = rng:NextNumber() < layer.ChargedChance and "Charged" or "Cracked"
	local id = HttpService:GenerateGUID(false)
	local position = Grid.Position(x, depth, z)
	local drop = { Position = position, Grade = grade, Depth = depth * Config.BlockSize, Expires = os.clock() + Config.Cores.DropLifetime }
	session.Drops[id] = drop
	remote:FireClient(player, "CoreDiscovered", id, position, grade)
	task.delay(Config.Cores.DropLifetime, function()
		if sessions[player] ~= session or session.Drops[id] ~= drop then return end
		session.Drops[id] = nil
		remote:FireClient(player, "CoreRemoved", id)
		remote:FireClient(player, "CoreNotice", "An unclaimed core expired. Pick up discoveries before 3 minutes pass.")
	end)
end

function CoreService.Collect(player, id)
	if typeof(id) ~= "string" then return end
	local session = sessions[player]
	if not session or os.clock() - session.LastCollect < 0.25 then return end
	session.LastCollect = os.clock()
	local drop = session.Drops[id]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not drop or not root or not humanoid or humanoid.Health <= 0 or os.clock() > drop.Expires then return end
	if (root.Position - drop.Position).Magnitude > Config.Cores.PickupRange + 1 then return end
	local origin = character:FindFirstChild("Head") or root
	local direction = drop.Position - origin.Position
	-- Personal blocks only exist on the client: check the server's mine grid as well.
	for step = 0, math.ceil(direction.Magnitude / 0.5) do
		local point = origin.Position:Lerp(drop.Position, math.min(1, step * 0.5 / math.max(direction.Magnitude, 0.01)))
		local blockId = Grid.IdAt(point)
		if blockId and MineService.GetHealth(player, blockId) then return end
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	if direction.Magnitude > 0.01 and workspace:Raycast(origin.Position, direction, params) then return end
	local added, message = PlayerDataService.AddUnknownCore(player, {
		Id = id, Grade = drop.Grade, Depth = drop.Depth, FoundAt = os.time(),
	})
	if not added then remote:FireClient(player, "CoreNotice", message) return end
	session.Drops[id] = nil
	remote:FireClient(player, "CoreRemoved", id)
	CoreService.SendInventory(player)
	remote:FireClient(player, "CoreCollected", drop.Grade)
end

function CoreService.Reset(player)
	local session = sessions[player]
	if not session then return end
	local hadDrops = next(session.Drops) ~= nil
	table.clear(session.Drops)
	remote:FireClient(player, "ClearCoreDrops")
	if hadDrops then remote:FireClient(player, "CoreNotice", "Mine reset: unclaimed cores cleared. Stored cores are safe.") end
end

function CoreService.Release(player)
	sessions[player] = nil
end

return CoreService
