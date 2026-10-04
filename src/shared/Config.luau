-- Feel-test tuning. One cell is wide enough for a character to fall through.
return {
	Persistence = {
		StoreName = "EnergyCore_PlayerData_v1",
		-- Leave false while testing locally unless Studio API access is enabled.
		EnableInStudio = false,
	},
	Width = 12,
	Depth = 60,
	BlockSize = 6,
	Range = 45,
	Tick = 0.12, -- Electrical visual cadence; damage pulses have their own limit.
	Mining = {
		HitInterval = 0.4,
		ChainDamageMultiplier = 0.75,
	},
	Training = { ClicksPerSecond = 25, Burst = 4, CombatCooldown = 0.45 },
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
		-- Discovery and grade chances are configured on each layer below.
	},
	StorageUpgrade = {
		BasePrice = 50,
		PriceMultiplier = 2,
		CapacityPerLevel = 25,
		MaxLevel = 8,
	},
	MaterialOrder = { "Stone Ore", "Copper Ore", "Charged Quartz", "Quartz Ore", "Ion Crystal", "Plasma Ore", "Reactor Shard" },
	Layers = {
		{
			EndDepth = 6, CoreChance = 0.015, ChargedChance = 0,
			Name = "STONE CIRCUIT", Color = Color3.fromRGB(110, 135, 151), Health = 150,
			Materials = {
				{ Name = "Stone Ore", Color = Color3.fromRGB(154, 170, 181), Chance = 70 },
				{ Name = "Copper Ore", Color = Color3.fromRGB(224, 119, 74), Chance = 30 },
			},
		},
		{
			EndDepth = 16, CoreChance = 0.025, ChargedChance = 0.35,
			Name = "CHARGED CAVERN", Color = Color3.fromRGB(49, 166, 176), Health = 750,
			Materials = {
				{ Name = "Copper Ore", Color = Color3.fromRGB(224, 119, 74), Chance = 55 },
				{ Name = "Charged Quartz", Color = Color3.fromRGB(84, 241, 255), Chance = 45 },
			},
		},
		{
			EndDepth = 28, CoreChance = 0.035, ChargedChance = 0.6,
			Name = "CRYSTAL GRID", Color = Color3.fromRGB(147, 97, 199), Health = 3500,
			Materials = {
				{ Name = "Quartz Ore", Color = Color3.fromRGB(220, 198, 255), Chance = 60 },
				{ Name = "Ion Crystal", Color = Color3.fromRGB(195, 79, 255), Chance = 40 },
			},
		},
		{
			EndDepth = 42, CoreChance = 0.045, ChargedChance = 0.8,
			Name = "PLASMA VEINS", Color = Color3.fromRGB(229, 102, 48), Health = 15000,
			Materials = {
				{ Name = "Ion Crystal", Color = Color3.fromRGB(195, 79, 255), Chance = 35 },
				{ Name = "Plasma Ore", Color = Color3.fromRGB(255, 139, 54), Chance = 65 },
			},
		},
		{
			EndDepth = 60, CoreChance = 0.055, ChargedChance = 0.95,
			Name = "REACTOR DEPTHS", Color = Color3.fromRGB(46, 145, 89), Health = 60000,
			Materials = {
				{ Name = "Plasma Ore", Color = Color3.fromRGB(255, 139, 54), Chance = 40 },
				{ Name = "Reactor Shard", Color = Color3.fromRGB(128, 255, 98), Chance = 60 },
			},
		},
	},
}
