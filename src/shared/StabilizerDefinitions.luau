local Definitions = {
	Order = { "Spark", "Copper", "Static", "Quartz", "Lightning", "Storm", "Ion", "Reactor" },
	Rarities = {
		Common = Color3.fromRGB(192, 205, 219), Uncommon = Color3.fromRGB(95, 255, 116),
		Rare = Color3.fromRGB(70, 174, 255), Epic = Color3.fromRGB(193, 89, 255),
		Legendary = Color3.fromRGB(255, 201, 49), Mythic = Color3.fromRGB(255, 78, 139),
	},
	Cores = {
		Spark = { IncomePerSecond = 2, Name = "Spark Core", Rarity = "Common", Color = Color3.fromRGB(255, 222, 88), Shape = "Ball" },
		Copper = { IncomePerSecond = 4, Name = "Copper Core", Rarity = "Common", Color = Color3.fromRGB(229, 125, 65), Shape = "Block" },
		Static = { IncomePerSecond = 10, Name = "Static Core", Rarity = "Uncommon", Color = Color3.fromRGB(108, 255, 145), Shape = "Cylinder" },
		Quartz = { IncomePerSecond = 25, Name = "Quartz Core", Rarity = "Rare", Color = Color3.fromRGB(133, 218, 255), Shape = "Diamond" },
		Lightning = { IncomePerSecond = 45, Name = "Lightning Core", Rarity = "Rare", Color = Color3.fromRGB(255, 250, 136), Shape = "Diamond" },
		Storm = { IncomePerSecond = 100, Name = "Storm Core", Rarity = "Epic", Color = Color3.fromRGB(184, 96, 255), Shape = "Ball" },
		Ion = { IncomePerSecond = 300, Name = "Ion Core", Rarity = "Legendary", Color = Color3.fromRGB(255, 185, 61), Shape = "Cylinder" },
		Reactor = { IncomePerSecond = 1000, Name = "Reactor Core", Rarity = "Mythic", Color = Color3.fromRGB(255, 64, 134), Shape = "Block" },
	},
	Grades = {
		Cracked = { Duration = 30, Weights = {450, 260, 150, 80, 35, 15, 8, 2} },
		Charged = { Duration = 120, Weights = {180, 200, 220, 170, 110, 65, 40, 15} },
	},
}
-- Base reactor rates; hotbar cores do not generate cash until installed.
function Definitions.IncomeText(key)
	local rate = Definitions.Cores[key].IncomePerSecond
	local amount = tostring(rate)
	while true do
		local formatted, count = amount:gsub("^(%d+)(%d%d%d)", "%1,%2")
		amount = formatted
		if count == 0 then break end
	end
	return "$" .. amount .. " / SEC"
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
