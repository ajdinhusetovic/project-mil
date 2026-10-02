local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Definitions = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Weapons = require(ReplicatedStorage.Shared.WeaponDefinitions)
local Data = require(script.Parent.PlayerDataService)
local Tools = require(script.Parent.CoreToolService)
local Service = {}
local stations = {}
local remote
local rng = Random.new()
local cooldown = {}

local function publish(player)
	local data = Data.Get(player)
	if not data then return end
	local job = data.Stabilizer
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
		if not index then return end
		data.Stabilizer = { Core = table.remove(data.UnknownCores, index) }
		Tools.Sync(player)
		publish(player)
		remote:FireClient(player, "StabilizerPlaced")
		message(player, "Core placed! Equip your weapon and zap it to start.")
	elseif action == "ChargeStabilizer" then
		if not job.Core or job.FinishAt then return end
		local tool = player.Character:FindFirstChildWhichIsA("Tool")
		if not tool or not Weapons[tool.Name] or tool.Name ~= data.EquippedWeapon then return end
		local head = player.Character:FindFirstChild("Head") or player.Character.HumanoidRootPart
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { player.Character, mount.Parent }
		if workspace:Raycast(head.Position, mount.Position + Vector3.new(0, 1.5, 0) - head.Position, params) then return end
		local definition = Definitions.Grades[job.Core.Grade]
		if not definition then return end
		job.Result = Definitions.Roll(job.Core.Grade, rng)
		job.StartedAt = os.time()
		job.FinishAt = job.StartedAt + definition.Duration
		publish(player)
		message(player, "STABILIZATION STARTED!")
	elseif action == "ClaimCore" then
		if not job.Core or not job.FinishAt or job.FinishAt > os.time() then message(player, "This core is not ready yet.") return end
		if not Definitions.Cores[job.Result] then return end
		local result = { Id = HttpService:GenerateGUID(false), Type = job.Result, Grade = job.Core.Grade, FoundAt = os.time(), Depth = job.Core.Depth }
		table.insert(data.StabilizedCores, result)
		data.Stabilizer = {}
		Tools.Sync(player)
		publish(player)
		remote:FireClient(player, "CoreReveal", result)
	elseif action == "CancelStabilizer" then
		if not job.Core or job.FinishAt then return end
		if #data.UnknownCores >= data.UnknownCoreCapacity then message(player, "Free an Unknown Core slot before returning this core.") return end
		table.insert(data.UnknownCores, job.Core)
		data.Stabilizer = {}
		Tools.Sync(player)
		publish(player)
	end
end
local function register(mount)
	if not mount:IsA("BasePart") or mount.Name ~= "CoreMount" then return end
	local model = mount:FindFirstAncestorWhichIsA("Model")
	if not model or (model.Name ~= "Stabilizer" and not model:GetAttribute("IsStabilizer")) then return end
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
