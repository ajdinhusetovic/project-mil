local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Grid = require(ReplicatedStorage.Shared.MineGrid)

local MineService = {}
local mines = {}
local total = Config.Width * Config.Width * Config.Depth

function MineService.Create(player)
	mines[player] = {}
end

function MineService.Release(player)
	mines[player] = nil
end

function MineService.Reset(player)
	mines[player] = {}
end

function MineService.GetHealth(player, id)
	local mine = mines[player]
	if not mine or typeof(id) ~= "number" or id % 1 ~= 0 or id < 1 or id > total then return nil end
	local health = mine[id]
	if health == 0 then return nil end
	if health then return health end
	local _, depth = Grid.Coordinates(id)
	return Grid.Layer(depth).Health
end

-- A client-only block cannot be hit by a server raycast. March through the
-- authoritative grid and reject shots that pass through another live block.
function MineService.IsAccessible(player, id, origin)
	local x, depth, z = Grid.Coordinates(id)
	local center = Grid.Position(x, depth, z)
	local direction = center - origin
	local distance = direction.Magnitude
	if distance > Config.Range + Config.BlockSize or distance < 0.01 then return false end
	local unit = direction.Unit
	local previousId
	for step = 0, math.ceil(distance / 0.5) do
		local sampleId = Grid.IdAt(origin + unit * math.min(step * 0.5, distance))
		if sampleId and sampleId ~= previousId then
			if MineService.GetHealth(player, sampleId) then
				return sampleId == id
			end
			previousId = sampleId
		end
	end
	return false
end

function MineService.Damage(player, id, amount)
	local current = MineService.GetHealth(player, id)
	if not current then return nil end
	local remaining = math.max(0, current - amount)
	mines[player][id] = remaining
	return remaining
end

function MineService.Blast(player, id, count, radius)
	local x, depth, z = Grid.Coordinates(id)
	local center = Grid.Position(x, depth, z)
	local candidates = {}
	for dz = -1, 1 do
		for dy = -1, 1 do
			for dx = -1, 1 do
				local nx, nd, nz = x + dx, depth + dy, z + dz
				if nx >= 1 and nx <= Config.Width and nz >= 1 and nz <= Config.Width and nd >= 1 and nd <= Config.Depth then
					local candidateId = Grid.Id(nx, nd, nz)
					local distance = (Grid.Position(nx, nd, nz) - center).Magnitude
					if candidateId ~= id and distance <= radius and MineService.GetHealth(player, candidateId) then
						table.insert(candidates, { Id = candidateId, Distance = distance })
					end
				end
			end
		end
	end
	table.sort(candidates, function(a, b)
		if a.Distance == b.Distance then return a.Id < b.Id end
		return a.Distance < b.Distance
	end)
	local victims = { id }
	for _, candidate in candidates do
		if #victims >= count then break end
		table.insert(victims, candidate.Id)
	end
	for _, victimId in victims do mines[player][victimId] = 0 end
	return victims
end

return MineService
