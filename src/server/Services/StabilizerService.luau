local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Definitions = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Mutations = require(ReplicatedStorage.Shared.MutationDefinitions)
local Data = require(script.Parent.PlayerDataService)
local Tools = require(script.Parent.CoreToolService)
local Service = {}
local stations = {}
local remote
local rng = Random.new()
local cooldown = {}

-- Also starts waiting jobs saved before automatic stabilization was introduced.
local function start(job)
	if not job.Core then return end
	-- Existing timed jobs keep their original normal result; no reroll on load.
	if job.FinishAt then job.Mutation = Mutations.Key(job.Mutation); return end
	local definition = Definitions.Grades[job.Core.Grade]
	if not definition then return end
	if not Definitions.Cores[job.Result] then job.Result = Definitions.Roll(job.Core.Grade, rng) end
	if job.Mutation == nil then job.Mutation = Mutations.Roll(rng) end
	job.Mutation = Mutations.Key(job.Mutation)
	job.StartedAt = os.time()
	job.FinishAt = job.StartedAt + definition.Duration
end
local function publish(player)
	local data = Data.Get(player)
	if not data then return end
	local job = data.Stabilizer
	start(job)
	player:SetAttribute("StabilizerStationId", job.StationId or "")
	player:SetAttribute("StabilizerGrade", job.Core and job.Core.Grade or "")
	player:SetAttribute("StabilizerFinishAt", job.FinishAt or 0)
	player:SetAttribute("StabilizerState", not job.Core and "Empty" or not job.FinishAt and "Waiting" or job.FinishAt <= os.time() and "Ready" or "Running")
	player:SetAttribute("UnknownCoreCount", #data.UnknownCores)
	player:SetAttribute("StabilizedCoreCount", #data.StabilizedCores)
end
function Service.Publish(player) publish(player) end
local function allowed(player, id)
	local mount = stations[id]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not mount or not mount:IsDescendantOf(workspace) or not root or not humanoid or humanoid.Health <= 0 then return nil end
	local node = mount
	while node and node ~= workspace do
		local owner = node:GetAttribute("OwnerUserId")
		if owner and owner ~= player.UserId then return nil end
		node = node.Parent
	end
	if (root.Position - mount.Position).Magnitude > 13 then return nil end
	return mount
end
local function message(player, text) remote:FireClient(player, "CoreNotice", text) end
function Service.Handle(player, action, id)
	if typeof(id) ~= "string" then return end
	local now = os.clock()
	if now - (cooldown[player] or -math.huge) < 0.2 then return end
	cooldown[player] = now
	local mount = allowed(player, id)
	local data = Data.Get(player)
	if not mount or not data then return end
	local job = data.Stabilizer
	if action == "PlaceCore" then
		if job.Core then message(player, "Your stabilizer already has a core.") return end
		local tool = player.Character:FindFirstChildWhichIsA("Tool")
		if not tool or not tool:GetAttribute("IsUnknownCore") then message(player, "Hold an Unknown Core from your hotbar first.") return end
		local coreId = tool:GetAttribute("CoreId")
		local index
		for i, core in data.UnknownCores do if core.Id == coreId then index = i; break end end
		if not index or not Definitions.Grades[data.UnknownCores[index].Grade] then return end
		data.Stabilizer = { Core = table.remove(data.UnknownCores, index), StationId = id }
		start(data.Stabilizer)
		Tools.Sync(player)
		publish(player)
		remote:FireClient(player, "StabilizerPlaced")
		message(player, "CORE PLACED — STABILIZATION STARTED!")
	elseif action == "ClaimCore" then
		if not job.Core or not job.FinishAt or job.FinishAt > os.time() then message(player, "This core is not ready yet.") return end
		if not Definitions.Cores[job.Result] then return end
		local result = { Id = HttpService:GenerateGUID(false), Type = job.Result, Mutation = Mutations.Key(job.Mutation), Grade = job.Core.Grade, FoundAt = os.time(), Depth = job.Core.Depth }
		table.insert(data.StabilizedCores, result)
		Data.DiscoverCore(player, result.Type)
		data.Stabilizer = {}
		Tools.Sync(player)
		publish(player)
		remote:FireClient(player, "CoreReveal", result, id)
	end
end
local function register(mount)
	if not mount:IsA("BasePart") or mount.Name ~= "CoreMount" then return end
	local model = mount:FindFirstAncestorWhichIsA("Model")
	if not model or (model.Name ~= "Stabilizer" and not model:GetAttribute("IsStabilizer")) then return end
	-- Odds are opened by the nearby GUI; suppress old authored odds prompts.
	for _, item in model:GetDescendants() do
		if item:IsA("ProximityPrompt") and (item.Name:lower():find("odds", 1, true) or item.ActionText:lower():find("odds", 1, true) or item.Name == "ReturnCorePrompt") then
			item.Enabled = false
		end
	end
	local id = HttpService:GenerateGUID(false)
	stations[id] = mount
	mount:SetAttribute("StabilizerId", id)
	local prompt = mount:FindFirstChild("StabilizerPrompt") or Instance.new("ProximityPrompt")
	prompt.Name = "StabilizerPrompt"
	prompt.ActionText = "Use stabilizer"
	prompt.ObjectText = "CORE STABILIZER"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = mount
	prompt.Triggered:Connect(function(player)
		if allowed(player, id) then publish(player); remote:FireClient(player, "StabilizerOpen", id) end
	end)
	mount.Destroying:Once(function() stations[id] = nil end)
end
function Service.Initialize(event)
	remote = event
	local any = false
	for _, item in workspace:GetDescendants() do
		if item.Name == "CoreMount" then register(item); any = any or item:GetAttribute("StabilizerId") ~= nil end
	end
	workspace.DescendantAdded:Connect(register)
	if not any then
		-- Replace this test station with your friend's Stabilizer model and CoreMount.
		local model = Instance.new("Model")
		model.Name = "Stabilizer"
		model:SetAttribute("IsStabilizer", true)
		local mount = Instance.new("Part")
		mount.Name = "CoreMount"
		mount.Anchored = true
		mount.Size = Vector3.new(6, 2, 6)
		mount.Position = Vector3.new(20, 1, 145)
		mount.Color = Color3.fromRGB(101, 48, 170)
		mount.Parent = model
		model.Parent = workspace
	end
end
function Service.Release(player) cooldown[player] = nil end
return Service
