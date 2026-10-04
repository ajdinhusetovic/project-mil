local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Definitions = require(ReplicatedStorage.Shared.CoreDefinitions)
local Stabilized = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Mutations = require(ReplicatedStorage.Shared.MutationDefinitions)
local WorldUI = require(ReplicatedStorage.Shared.WorldUIBuilder)
local Visuals = require(ReplicatedStorage.Shared.CoreVisuals)
local PlayerDataService = require(script.Parent.PlayerDataService)

local CoreToolService = {}

-- The saved core record is authoritative; Tools are its hotbar representation.
-- Keep existing Tools so syncing inventory never interrupts an equipped core.
function CoreToolService.Sync(player)
	local data = PlayerDataService.Get(player)
	local backpack = player:FindFirstChild("Backpack")
	if not data or not backpack then return end
	local records = {}
	for _, core in data.UnknownCores do records[core.Id] = core end
	for _, core in data.StabilizedCores do records[core.Id] = core end
	local found = {}
	local containers = { backpack }
	if player.Character then table.insert(containers, player.Character) end
	for _, container in containers do
		for _, tool in container:GetChildren() do
			if tool:IsA("Tool") and (tool:GetAttribute("IsUnknownCore") or tool:GetAttribute("IsStabilizedCore")) then
				local id = tool:GetAttribute("CoreId")
				if not records[id] or found[id] or (records[id].Type and (tool:GetAttribute("Mutation") or "None") ~= Stabilized.MutationKey(records[id])) then
					tool:Destroy()
				else
					found[id] = true
				end
			end
		end
	end
	for id, core in records do
		if found[id] then continue end
		local definition = core.Type and Stabilized.Cores[core.Type] or Definitions[core.Grade]
		if not definition then continue end
		local tool = Instance.new("Tool")
		tool.Name = core.Type and Stabilized.DisplayName(core) or core.Grade .. " Unknown Core"
		tool.ToolTip = core.Type and (definition.Rarity .. " — " .. Stabilized.IncomeText(core) .. " in your reactor") or core.Grade .. " Unknown Core — take it to a stabilizer"
		tool.CanBeDropped = false
		tool.RequiresHandle = true
		tool.Enabled = false
		tool.Grip = CFrame.new(0, -0.15, 0)
		tool:SetAttribute(core.Type and "IsStabilizedCore" or "IsUnknownCore", true)
		tool:SetAttribute("CoreId", id)
		tool:SetAttribute("CoreGrade", core.Grade)
		tool:SetAttribute("CoreType", core.Type)
		tool:SetAttribute("Mutation", core.Type and Stabilized.MutationKey(core) or nil)
		tool:SetAttribute("IncomePerSecond", core.Type and Stabilized.Income(core) or nil)
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Shape = Enum.PartType.Ball
		handle.Size = Vector3.one * 1.7
		handle.Color = definition.Color
		handle.Material = Enum.Material.Neon
		handle.CanCollide = false
		handle.CanTouch = false
		handle.CanQuery = false
		handle.Massless = true
		handle.Parent = tool
		if core.Type then
			local board = WorldUI.BuildTemplates().CoreBillboard:Clone()
			board.NameLabel.Text = string.upper(definition.Name)
			board.RarityLabel.Text = Stabilized.MutationText(core)
			board.RarityLabel.Visible = board.RarityLabel.Text ~= ""
			board.RarityLabel.TextColor3 = Mutations.Variants[Stabilized.MutationKey(core)].Color or Stabilized.Rarities[definition.Rarity]
			board.IncomeLabel.Text = Stabilized.IncomeText(core)
			board.Parent = handle
			handle.Transparency = 1
			local model = Visuals.Build(core.Type, false, core.Mutation)
			for _, part in model:GetDescendants() do
				if not part:IsA("BasePart") then continue end
				part.Anchored = false
				part.Name = "CoreVisual"
				part.Massless = true
				part.Parent = tool
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = handle
				weld.Part1 = part
				weld.Parent = part
			end
			model:Destroy()
		end
		local light = Instance.new("PointLight")
		light.Color = definition.Color
		light.Brightness = 0.7
		light.Range = 6
		light.Parent = handle
		tool.Parent = backpack
	end
end

return CoreToolService
