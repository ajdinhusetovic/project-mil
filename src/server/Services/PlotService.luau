local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Builder = require(ReplicatedStorage.Shared.PlotBuilder)
local World = require(script.Parent.WorldService)
local Data = require(script.Parent.PlayerDataService)
local Service = {}
local plots, occupied, lastTeleport = {}, {}, {}
local folder
function Service.Initialize()
	folder = Instance.new("Folder")
	folder.Name = "PlayerPlots"
	folder.Parent = workspace
	Builder.Build(ServerStorage)
end
function Service.Create(player)
	local index = 1
	while occupied[index] do index += 1 end
	occupied[index] = player
	local model = ServerStorage.PlotTemplate:Clone()
	model.Name = player.Name .. "Plot"
	model:SetAttribute("OwnerUserId", player.UserId)
	model:PivotTo(CFrame.new(350 + ((index - 1) % 6) * 120, 0, 250 + math.floor((index - 1) / 6) * 120))
	model.Parent = folder
	local reactor = model:FindFirstChild("Reactor", true)
	local interact = reactor and (reactor:IsA("BasePart") and reactor or reactor:FindFirstChild("Interact", true) or reactor.PrimaryPart)
	if not interact or not interact:IsA("BasePart") then warn("PlotTemplate needs Reactor part, or Reactor Model with Interact part") end
	plots[player] = {Model = model, Index = index, Reactor = interact, Spawn = model:FindFirstChild("PlotSpawn", true)}
	return plots[player]
end
function Service.Get(player) return plots[player] end
function Service.NearReactor(player)
	local plot = plots[player]
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return plot and plot.Model:GetAttribute("OwnerUserId") == player.UserId and plot.Reactor and plot.Reactor:IsDescendantOf(workspace)
		and root and humanoid and humanoid.Health > 0 and (root.Position - plot.Reactor.Position).Magnitude <= 14
end
function Service.Teleport(player, destination)
	if destination ~= "World" and destination ~= "Plot" then return false, "Unknown destination." end
	local now = os.clock()
	if now - (lastTeleport[player] or -math.huge) < 1 then return false, "Please wait a moment." end
	lastTeleport[player] = now
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not Data.Get(player) then return false, "Wait for your character to spawn." end
	if destination == "World" then World.Surface(player) else
		local plot = plots[player]
		if not plot or not plot.Spawn or not plot.Spawn:IsA("BasePart") then return false, "Your plot is not ready." end
		local target = plot.Reactor and plot.Reactor.Position or plot.Model:GetPivot().Position
		character:PivotTo(CFrame.lookAt(plot.Spawn.Position, Vector3.new(target.X, plot.Spawn.Position.Y, target.Z)))
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		player:SetAttribute("CurrentDestination", "Plot")
	end
	return true
end
function Service.Release(player)
	local plot = plots[player]
	if plot then occupied[plot.Index] = nil; plot.Model:Destroy() end
	plots[player], lastTeleport[player] = nil, nil
end
return Service
