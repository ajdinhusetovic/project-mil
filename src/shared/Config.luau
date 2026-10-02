-- Feel-test tuning. One cell is wide enough for a character to fall through.
return {
	Persistence = {
		StoreName = "EnergyCore_PlayerData_v1",
		-- Leave false while testing locally unless Studio API access is enabled.
		EnableInStudio = false,
	},
	Width = 12,
	Depth = 18,
	BlockSize = 6,
	Range = 45,
	Tick = 0.12,
	Training = { ClicksPerSecond = 25, Burst = 4, CombatCooldown = 0.45 },
	Damage = 9,
	LevelXPBase = 15,
	LevelXPExponent = 0.8,
	BlastBlocks = 1,
	BlastRadius = 8.5,
	CollectionRange = 18,
	ChainUpgrade = { BasePrice = 75, PriceMultiplier = 2.25, MaxLevel = 5 },
	MagnetUpgrade = { BasePrice = 100, PriceMultiplier = 2.1, MaxLevel = 5, RangePerLevel = 6 },
	WeaponOrder = { "Scrap Zapper", "Arc Pistol", "Tesla Rifle", "Storm Blaster", "Nuclear Conductor", "Plasma Cannon" },
	DropLifetime = 45,
	Cores = {
		Capacity = 3,
		FirstDiscoveryAfter = 12,
		PickupRange = 10,
		DropLifetime = 180,
		MaxPending = 6,
		-- Provisional odds per broken block for the current three layers.
		LayerChances = { 0.015, 0.025, 0.04 },
	},
	StorageUpgrade = {
		BasePrice = 50,
		PriceMultiplier = 2,
		CapacityPerLevel = 25,
		MaxLevel = 8,
	},
	MaterialOrder = { "Stone Ore", "Copper Ore", "Charged Quartz", "Quartz Ore", "Ion Crystal" },
	Layers = {
		{
			Name = "STONE CIRCUIT", Color = Color3.fromRGB(110, 135, 151), Health = 36,
			Materials = {
				{ Name = "Stone Ore", Color = Color3.fromRGB(154, 170, 181), Chance = 70 },
				{ Name = "Copper Ore", Color = Color3.fromRGB(224, 119, 74), Chance = 30 },
			},
		},
		{
			Name = "CHARGED CAVERN", Color = Color3.fromRGB(49, 166, 176), Health = 45,
			Materials = {
				{ Name = "Copper Ore", Color = Color3.fromRGB(224, 119, 74), Chance = 55 },
				{ Name = "Charged Quartz", Color = Color3.fromRGB(84, 241, 255), Chance = 45 },
			},
		},
		{
			Name = "CRYSTAL GRID", Color = Color3.fromRGB(147, 97, 199), Health = 54,
			Materials = {
				{ Name = "Quartz Ore", Color = Color3.fromRGB(220, 198, 255), Chance = 60 },
				{ Name = "Ion Crystal", Color = Color3.fromRGB(195, 79, 255), Chance = 40 },
			},
		},
	},
}
