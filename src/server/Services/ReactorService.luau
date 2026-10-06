local Players = game:GetService("Players")
local Data = require(script.Parent.PlayerDataService)
local Plots = require(script.Parent.PlotService)
local Tools = require(script.Parent.CoreToolService)
local Service = {}
local remote
local viewing, lastAction = {}, {}
local function send(player)
	local snapshot = Data.GetReactorSnapshot(player)
	if snapshot then remote:FireClient(player, "ReactorSnapshot", snapshot) end
end
function Service.Initialize(event)
	remote = event
	task.spawn(function()
		while true do
			task.wait(1)
			for player in viewing do
				if Plots.NearReactor(player) then send(player)
				else viewing[player] = nil; remote:FireClient(player, "ReactorClosed") end
			end
		end
	end)
end
function Service.Create(player, plot)
	if not plot.Reactor then return end
	local prompt = plot.Reactor:FindFirstChild("ReactorPrompt") or Instance.new("ProximityPrompt")
	prompt.Name = "ReactorPrompt"
	prompt:SetAttribute("OwnerUserId", player.UserId)
	prompt.ActionText = "Manage cores"
	prompt.ObjectText = "YOUR REACTOR"
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0
	prompt.Parent = plot.Reactor
	prompt.Triggered:Connect(function(visitor)
		if visitor ~= player or not Plots.NearReactor(player) then return end
		viewing[player] = true
		send(player)
		remote:FireClient(player, "ReactorOpen")
	end)
end
function Service.Handle(player, action, target)
	if action == "ReactorClose" then viewing[player] = nil return end
	if not Plots.NearReactor(player) then remote:FireClient(player, "ReactorClosed") return end
	local now = os.clock()
	if now - (lastAction[player] or -math.huge) < 0.2 then
		remote:FireClient(player, "ReactorResult", false, "Please wait a moment.")
		return
	end
	lastAction[player] = now
	local success, result
	if action == "ReactorCollect" then
		success, result = Data.CollectReactor(player)
		if success then remote:FireClient(player, "ReactorCollected", result) end
	else
		success, result = Data.ChangeReactor(player, action, target)
		if success then Tools.Sync(player) end
	end
	send(player)
	remote:FireClient(player, "ReactorResult", success, result or "Reactor updated!")
end
function Service.Release(player) viewing[player], lastAction[player] = nil, nil end
return Service
