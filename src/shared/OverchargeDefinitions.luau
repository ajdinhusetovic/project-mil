-- Total permanent multipliers, never compounded with the previous reward.
local Definitions = {
	Milestones = {
		{Count = 0, Power = 1, Cash = 1, Level = 15},
		{Count = 1, Power = 1.5, Cash = 1.2, Level = 22},
		{Count = 2, Power = 2, Cash = 1.5, Level = 30},
		{Count = 3, Power = 3, Cash = 2, Level = 40},
		{Count = 5, Power = 5, Cash = 3, Level = 75},
		{Count = 10, Power = 12, Cash = 6, Level = 220},
		{Count = 20, Power = 35, Cash = 15, Level = 750},
		{Count = 35, Power = 90, Cash = 35, Level = 2000},
	},
}
local function values(count)
	count = math.max(0, math.floor(count))
	for index = 2, #Definitions.Milestones do
		local first, last = Definitions.Milestones[index - 1], Definitions.Milestones[index]
		if count <= last.Count then
			local alpha = (count - first.Count) / (last.Count - first.Count)
			return first.Power + (last.Power - first.Power) * alpha,
				first.Cash + (last.Cash - first.Cash) * alpha,
				math.floor(first.Level + (last.Level - first.Level) * alpha + 0.5)
		end
	end
	local extra = count - 35
	return 90 + extra * 5, 35 + extra * 2, 2000 + extra * 125
end
function Definitions.Multipliers(count)
	local power, cash = values(count)
	return power, cash
end
function Definitions.Requirements(count)
	local _, _, level = values(count)
	return {Level = level}
end
function Definitions.Number(value)
	return require(script.Parent.NumberFormat).Compact(value)
end
return Definitions
