-- Rebirth requirements and rewards can be tuned here without changing the stations.
local Definitions = {
	Interval = 1,
	Stations = {
		{ Id = "Starter", Rebirths = 0, Multiplier = 1, Color = Color3.fromRGB(83, 218, 255) },
		{ Id = "Charged", Rebirths = 2, Multiplier = 1.5, Color = Color3.fromRGB(184, 104, 255) },
		{ Id = "Supercharged", Rebirths = 4, Multiplier = 3, Color = Color3.fromRGB(255, 183, 42) },
		{ Id = "Overloaded", Rebirths = 7, Multiplier = 5, Color = Color3.fromRGB(255, 76, 126) },
		{ Id = "Nuclear", Rebirths = 10, Multiplier = 8, Color = Color3.fromRGB(102, 255, 62) },
	},
}

function Definitions.Get(id)
	for _, definition in Definitions.Stations do
		if definition.Id == id then return definition end
	end
end

function Definitions.Contains(zone, position)
	local point = zone.CFrame:PointToObjectSpace(position)
	local half = zone.Size / 2
	return math.abs(point.X) <= half.X and math.abs(point.Y) <= half.Y and math.abs(point.Z) <= half.Z
end

-- Uses the authored zone, so moving or rotating a station in Studio moves its trigger too.
function Definitions.At(position, rebirths)
	local folder = workspace:FindFirstChild("AFKTrainingStations")
	local best, bestModel
	if folder then
		for _, model in folder:GetChildren() do
			local definition = Definitions.Get(model:GetAttribute("StationId"))
			local zone = model:FindFirstChild("Zone")
			if definition and zone and zone:IsA("BasePart") and definition.Rebirths <= rebirths
				and Definitions.Contains(zone, position)
				and (not best or definition.Multiplier > best.Multiplier) then
				best, bestModel = definition, model
			end
		end
	end
	return best, bestModel
end

return Definitions
