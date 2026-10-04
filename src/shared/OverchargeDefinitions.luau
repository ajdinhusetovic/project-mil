-- Permanent bonuses are additive, so repeated runs do not grow exponentially.
local Definitions = {
	PowerBonus = 0.5,
	CashBonus = 0.2,
	BaseLevel = 25,
	LevelPerOvercharge = 5,
	BasePower = 10000,
	BaseCash = 10000,
	RequirementGrowth = 1.6,
}
function Definitions.Multipliers(count)
	return 1 + count * Definitions.PowerBonus, 1 + count * Definitions.CashBonus
end
function Definitions.Requirements(count)
	return {
		Level = Definitions.BaseLevel + count * Definitions.LevelPerOvercharge,
		Power = math.floor(Definitions.BasePower * Definitions.RequirementGrowth ^ count),
		Cash = math.floor(Definitions.BaseCash * Definitions.RequirementGrowth ^ count),
	}
end
function Definitions.Number(value)
	return require(script.Parent.NumberFormat).Compact(value)
end
return Definitions
