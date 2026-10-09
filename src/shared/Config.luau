-- Feel-test tuning. One cell is wide enough for a character to fall through.
return {
	Persistence = {
		StoreName = "EnergyCore_PlayerData_v1",
		-- Leave false while testing locally unless Studio API access is enabled.
		EnableInStudio = false,
	},
	Width = 12,
	Depth = 120,
	BlockSize = 6,
	Range = 45,
	Tick = 0.12, -- Electrical visual cadence; damage pulses have their own limit.
	Mining = {
		HitInterval = 0.4,
		ChainDamageMultiplier = 0.75,
		ChainTrainingMultiplier = 0.15, -- Secondary breaks earn a fraction of primary training.
		BreakTrainingMultiplier = 2, -- Weapon-scaled power AND XP for a confirmed block break.
	},
	Training = { ClicksPerSecond = 25, Burst = 4, CombatCooldown = 0.45 },
	LevelXPBase = 25,
	LevelXPStep = 15,
	LevelXPCurve = 2,
	BlastBlocks = 1,
	BlastRadius = 8.5,
	CollectionRange = 18,
	ChainUpgrade = { BasePrice = 75, PriceMultiplier = 3.2, MaxLevel = 8 },
	MagnetUpgrade = { BasePrice = 100, PriceMultiplier = 2.7, MaxLevel = 10, RangePerLevel = 4 },
	WeaponOrder = { "Scrap Zapper", "Arc Pistol", "Tesla Rifle", "Storm Blaster", "Nuclear Conductor", "Plasma Cannon", "Fusion Launcher", "Photon Accelerator", "Gravity Breaker", "Antimatter Driver", "Quantum Disruptor", "Singularity Cannon", "Nova Annihilator", "Void Conductor", "Omega Core" },
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
		PriceMultiplier = 2.6,
		CapacityPerLevel = 50,
		MaxLevel = 16,
	},
	MaterialOrder = { "Stone Ore", "Copper Ore", "Charged Quartz", "Quartz Ore", "Ion Crystal", "Plasma Ore", "Reactor Shard", "Fusion Ore", "Antimatter Ore", "Singularity Ore", "Omega Ore" },
	Layers = {
		{
			EndDepth = 6, TrainingMultiplier = 1, CoreChance = 0.015, ChargedChance = 0,
			Name = "STONE CIRCUIT", Color = Color3.fromRGB(110, 135, 151), Health = 80,
			Materials = {
				{ Name = "Stone Ore", Color = Color3.fromRGB(154, 170, 181), Chance = 70 },
				{ Name = "Copper Ore", Color = Color3.fromRGB(224, 119, 74), Chance = 30 },
			},
		},
		{
			EndDepth = 16, TrainingMultiplier = 1.5, CoreChance = 0.025, ChargedChance = 0.35,
			Name = "CHARGED CAVERN", Color = Color3.fromRGB(49, 166, 176), Health = 800,
			Materials = {
				{ Name = "Copper Ore", Color = Color3.fromRGB(224, 119, 74), Chance = 55 },
				{ Name = "Charged Quartz", Color = Color3.fromRGB(84, 241, 255), Chance = 45 },
			},
		},
		{
			EndDepth = 28, TrainingMultiplier = 2, CoreChance = 0.035, ChargedChance = 0.6,
			Name = "CRYSTAL GRID", Color = Color3.fromRGB(147, 97, 199), Health = 8000,
			Materials = {
				{ Name = "Quartz Ore", Color = Color3.fromRGB(220, 198, 255), Chance = 60 },
				{ Name = "Ion Crystal", Color = Color3.fromRGB(195, 79, 255), Chance = 40 },
			},
		},
		{
			EndDepth = 42, TrainingMultiplier = 2.5, CoreChance = 0.045, ChargedChance = 0.8,
			Name = "PLASMA VEINS", Color = Color3.fromRGB(229, 102, 48), Health = 100000,
			Materials = {
				{ Name = "Ion Crystal", Color = Color3.fromRGB(195, 79, 255), Chance = 35 },
				{ Name = "Plasma Ore", Color = Color3.fromRGB(255, 139, 54), Chance = 65 },
			},
		},
		{
			EndDepth = 60, TrainingMultiplier = 3, CoreChance = 0.055, ChargedChance = 0.95,
			Name = "REACTOR DEPTHS", Color = Color3.fromRGB(46, 145, 89), Health = 1000000,
			Materials = {
				{ Name = "Plasma Ore", Color = Color3.fromRGB(255, 139, 54), Chance = 40 },
				{ Name = "Reactor Shard", Color = Color3.fromRGB(128, 255, 98), Chance = 60 },
			},
		},
		{EndDepth = 76, TrainingMultiplier = 3.25, CoreChance = 0.06, ChargedChance = 1,
			Name = "FUSION CHAMBER", Color = Color3.fromRGB(224, 151, 40), Health = 15000000,
			Materials = {{Name = "Fusion Ore", Color = Color3.fromRGB(255, 190, 60), Chance = 100}}},
		{EndDepth = 92, TrainingMultiplier = 3.5, CoreChance = 0.065, ChargedChance = 1,
			Name = "ANTIMATTER FAULT", Color = Color3.fromRGB(197, 65, 144), Health = 250000000,
			Materials = {{Name = "Antimatter Ore", Color = Color3.fromRGB(255, 85, 178), Chance = 100}}},
		{EndDepth = 108, TrainingMultiplier = 3.75, CoreChance = 0.07, ChargedChance = 1,
			Name = "SINGULARITY", Color = Color3.fromRGB(81, 63, 163), Health = 4000000000,
			Materials = {{Name = "Singularity Ore", Color = Color3.fromRGB(140, 100, 255), Chance = 100}}},
		{EndDepth = 120, TrainingMultiplier = 4, CoreChance = 0.075, ChargedChance = 1,
			Name = "OMEGA HEART", Color = Color3.fromRGB(173, 40, 74), Health = 60000000000,
			Materials = {{Name = "Omega Ore", Color = Color3.fromRGB(255, 75, 110), Chance = 100}}},
	},
}
