-- One independent mutation roll per stabilization. Weights total 100.
local Mutations = {
	Order = {"None", "Charged", "Radiant", "Overloaded"},
	Variants = {
		None = {Name = "Normal", Multiplier = 1, Weight = 85},
		Charged = {Name = "Charged", Multiplier = 1.25, Weight = 10, Color = Color3.fromRGB(70, 210, 255), ParticleRate = 5},
		Radiant = {Name = "Radiant", Multiplier = 1.5, Weight = 4, Color = Color3.fromRGB(255, 220, 80), ParticleRate = 8},
		Overloaded = {Name = "Overloaded", Multiplier = 2, Weight = 1, Color = Color3.fromRGB(255, 80, 220), ParticleRate = 12},
	},
}
function Mutations.Key(value)
	return Mutations.Variants[value] and value or "None"
end
function Mutations.Roll(rng)
	local total = 0
	for _, key in Mutations.Order do total += Mutations.Variants[key].Weight end
	local roll = rng:NextNumber(0, total)
	local cursor = 0
	for _, key in Mutations.Order do
		cursor += Mutations.Variants[key].Weight
		if roll < cursor then return key end
	end
	return Mutations.Order[#Mutations.Order]
end
return Mutations
