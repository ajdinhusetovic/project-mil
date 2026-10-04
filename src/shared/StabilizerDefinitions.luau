local Mutations = require(script.Parent.MutationDefinitions)
local Definitions = {
	Order = { "Spark", "Copper", "Static", "Quartz", "Lightning", "Storm", "Ion", "Reactor" },
	Rarities = {
		Common = Color3.fromRGB(192, 205, 219), Uncommon = Color3.fromRGB(95, 255, 116),
		Rare = Color3.fromRGB(70, 174, 255), Epic = Color3.fromRGB(193, 89, 255),
		Legendary = Color3.fromRGB(255, 201, 49), Mythic = Color3.fromRGB(255, 78, 139),
	},
	Cores = {
		Spark = { IncomePerSecond = 2, SellValue = 120, Name = "Spark Core", Rarity = "Common", Color = Color3.fromRGB(255, 222, 88), Shape = "Ball" },
		Copper = { IncomePerSecond = 4, SellValue = 240, Name = "Copper Core", Rarity = "Common", Color = Color3.fromRGB(229, 125, 65), Shape = "Block" },
		Static = { IncomePerSecond = 10, SellValue = 600, Name = "Static Core", Rarity = "Uncommon", Color = Color3.fromRGB(108, 255, 145), Shape = "Cylinder" },
		Quartz = { IncomePerSecond = 25, SellValue = 1500, Name = "Quartz Core", Rarity = "Rare", Color = Color3.fromRGB(133, 218, 255), Shape = "Diamond" },
		Lightning = { IncomePerSecond = 45, SellValue = 2700, Name = "Lightning Core", Rarity = "Rare", Color = Color3.fromRGB(255, 250, 136), Shape = "Diamond" },
		Storm = { IncomePerSecond = 100, SellValue = 6000, Name = "Storm Core", Rarity = "Epic", Color = Color3.fromRGB(184, 96, 255), Shape = "Ball" },
		Ion = { IncomePerSecond = 300, SellValue = 18000, Name = "Ion Core", Rarity = "Legendary", Color = Color3.fromRGB(255, 185, 61), Shape = "Cylinder" },
		Reactor = { IncomePerSecond = 1000, SellValue = 60000, Name = "Reactor Core", Rarity = "Mythic", Color = Color3.fromRGB(255, 64, 134), Shape = "Block" },
	},
	Grades = {
		Cracked = { Duration = 30, Weights = {450, 260, 150, 80, 35, 15, 8, 2} },
		Charged = { Duration = 120, Weights = {180, 200, 220, 170, 110, 65, 40, 15} },
	},
}
-- Helpers accept a saved core record, or a core key and optional mutation.
local function unpackCore(core, mutation)
	if type(core) == "table" then return core.Type, Mutations.Key(core.Mutation) end
	return core, Mutations.Key(mutation)
end
function Definitions.MutationKey(core)
	return Mutations.Key(core.Mutation)
end
function Definitions.DisplayName(core, mutation)
	local key, variant = unpackCore(core, mutation)
	local base = Definitions.Cores[key].Name
	return variant == "None" and base or Mutations.Variants[variant].Name .. " " .. base
end
function Definitions.Income(core, mutation)
	local key, variant = unpackCore(core, mutation)
	return Definitions.Cores[key].IncomePerSecond * Mutations.Variants[variant].Multiplier
end
function Definitions.SaleValue(core, mutation)
	local key, variant = unpackCore(core, mutation)
	return Definitions.Cores[key].SellValue * Mutations.Variants[variant].Multiplier
end
function Definitions.IncomeText(core, mutation)
	return "$" .. require(script.Parent.NumberFormat).Compact(Definitions.Income(core, mutation)) .. " / SEC"
end
function Definitions.MutationText(core)
	local variant = Definitions.MutationKey(core)
	if variant == "None" then return "" end
	return string.upper(variant) .. " (" .. require(script.Parent.NumberFormat).Compact(Mutations.Variants[variant].Multiplier) .. "x)"
end
function Definitions.RarityText(core)
	local key, variant = unpackCore(core)
	local rarity = string.upper(Definitions.Cores[key].Rarity)
	if variant == "None" then return rarity end
	return rarity .. " • " .. string.upper(variant) .. " " .. require(script.Parent.NumberFormat).Compact(Mutations.Variants[variant].Multiplier) .. "x"
end
function Definitions.Roll(grade, rng)
	local weights = Definitions.Grades[grade].Weights
	local total = 0
	for _, weight in weights do total += weight end
	local roll = rng:NextNumber(0, total)
	local cursor = 0
	for index, weight in weights do
		cursor += weight
		if roll < cursor then return Definitions.Order[index] end
	end
	return Definitions.Order[#Definitions.Order]
end
function Definitions.OddsText(grade)
	local weights = Definitions.Grades[grade].Weights
	local total = 0
	for _, weight in weights do total += weight end
	local rows = {}
	for index, weight in weights do
		local core = Definitions.Cores[Definitions.Order[index]]
		table.insert(rows, string.format("%s (%s): %g%%", core.Name, core.Rarity, weight / total * 100))
	end
	return table.concat(rows, "\n")
end
return Definitions
