local Config = require(script.Parent.Config)
local Progression = {}

function Progression.XPRequired(level)
	local steps = math.max(0, level - 1)
	local value = Config.LevelXPBase + steps * Config.LevelXPStep + steps ^ 2 * Config.LevelXPCurve
	local step = value >= 1000 and 50 or (value >= 100 and 10 or 5)
	return math.max(step, math.floor(value / step + 0.5) * step)
end

function Progression.MiningMultiplier(depth)
	for _, layer in Config.Layers do
		if depth <= layer.EndDepth then return Config.Mining.BreakTrainingMultiplier * layer.TrainingMultiplier end
	end
	return 0
end

return Progression
