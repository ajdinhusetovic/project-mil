local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Definitions = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Unknown = require(ReplicatedStorage.Shared.CoreDefinitions)
local Visuals = require(ReplicatedStorage.Shared.CoreVisuals)
local Builder = require(ReplicatedStorage.Shared.StabilizerOddsUIBuilder)
local WorldUI = require(ReplicatedStorage.Shared.WorldUIBuilder)
local Reveal = require(script.Parent.StabilizerWorldReveal)
local Feedback = require(script.Parent.FeedbackEffects)
local templates = WorldUI.BuildTemplates()
local remote = ReplicatedStorage:WaitForChild("MiningDemo")
local legacy = player.PlayerGui:FindFirstChild("StabilizerGui")
if legacy then legacy.Enabled = false end
local gui = Builder.Build(player.PlayerGui)
local shade = gui.Shade
local panel = shade.Panel
local nearbyButton = gui.NearbyOddsButton
local mounts, displays = {}, {}
local nearest, stationId, rollingMount
local selectedGrade = "Cracked"
local queue = {}
local processing = false
local folder = Instance.new("Folder")
folder.Name = "PersonalStabilizerDisplays"
folder.Parent = workspace
local function accessible(mount)
	local node = mount
	while node and node ~= workspace do
		local owner = node:GetAttribute("OwnerUserId")
		if owner and owner ~= player.UserId then return false end
		node = node.Parent
	end
	return true
end
local function watch(item)
	if item:IsA("BasePart") and item.Name == "CoreMount" then mounts[item] = true end
end
for _, item in workspace:GetDescendants() do watch(item) end
workspace.DescendantAdded:Connect(watch)
local function state()
	local kind = player:GetAttribute("StabilizerState") or "Empty"
	local finish = player:GetAttribute("StabilizerFinishAt") or 0
	if finish > 0 and finish <= workspace:GetServerTimeNow() then kind = "Ready" end
	return kind, math.max(0, math.ceil(finish - workspace:GetServerTimeNow()))
end
local function refreshOdds()
	local weights = Definitions.Grades[selectedGrade].Weights
	local total = 0
	for _, weight in weights do total += weight end
	panel.GradeLabel.Text = string.upper(selectedGrade) .. " OUTCOMES"
	for index, key in Definitions.Order do
		panel.Rows[key].ChanceLabel.Text = string.format("%g%%", weights[index] / total * 100)
	end
end
panel.CloseButton.Activated:Connect(function() shade.Visible = false end)
panel.CrackedButton.Activated:Connect(function() selectedGrade = "Cracked"; refreshOdds() end)
panel.ChargedButton.Activated:Connect(function() selectedGrade = "Charged"; refreshOdds() end)
nearbyButton.Activated:Connect(function()
	if not nearest or rollingMount then return end
	local held = player.Character and player.Character:FindFirstChildWhichIsA("Tool")
	local grade = player:GetAttribute("StabilizerGrade")
	if not Definitions.Grades[grade] then grade = held and held:GetAttribute("CoreGrade") end
	selectedGrade = Definitions.Grades[grade] and grade or "Cracked"
	refreshOdds()
	shade.Visible = true
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Escape then shade.Visible = false end
end)
local function findStation(id)
	for mount in mounts do
		if mount:GetAttribute("StabilizerId") == id and mount:IsDescendantOf(workspace) and accessible(mount) then return mount end
	end
end
remote.OnClientEvent:Connect(function(action, first, id)
	if action == "StabilizerOpen" then
		local mount = findStation(first)
		if not mount or rollingMount then return end
		stationId = first
		local kind, remaining = state()
		if kind == "Empty" then remote:FireServer("PlaceCore", first)
		elseif kind == "Ready" then remote:FireServer("ClaimCore", first)
		else Feedback.ShowCore(string.format("STABILIZING  %d:%02d", math.floor(remaining / 60), remaining % 60)) end
	elseif action == "CoreReveal" then
		table.insert(queue, {Result = first, Mount = findStation(id or stationId) or nearest})
		if processing then return end
		processing = true
		task.spawn(function()
			while #queue > 0 do
				local job = table.remove(queue, 1)
				rollingMount = job.Mount
				shade.Visible = false
				if not job.Mount or not job.Mount:IsDescendantOf(workspace) then
					Feedback.ShowCore(Definitions.Cores[job.Result.Type].Name .. " • " .. Definitions.IncomeText(job.Result.Type) .. " • Added to hotbar")
				end
				local ok, err = pcall(Reveal.Play, job.Mount, job.Result, folder, templates.CoreBillboard)
				if not ok then warn("Stabilizer reveal: " .. tostring(err)) end
				rollingMount = nil
			end
			processing = false
		end)
	end
end)
local elapsed = 0
RunService.RenderStepped:Connect(function(dt)
	elapsed += dt
	if elapsed < 0.1 then return end
	elapsed = 0
	local kind, remaining = state()
	local grade = player:GetAttribute("StabilizerGrade") or ""
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local held = character and character:FindFirstChildWhichIsA("Tool")
	local heldKnown = held and held:GetAttribute("IsStabilizedCore")
	local heldBoard = heldKnown and held:FindFirstChild("Handle") and held.Handle:FindFirstChild("CoreBillboard")
	if heldBoard then heldBoard.Enabled = not shade.Visible and not player:GetAttribute("NpcDialogueOpen") end
	nearest = nil
	local distance = math.huge
	for mount in mounts do
		if not mount:IsDescendantOf(workspace) or not accessible(mount) then
			if displays[mount] then displays[mount]:Destroy(); displays[mount] = nil end
			if not mount:IsDescendantOf(workspace) then mounts[mount] = nil end
		elseif mount:GetAttribute("StabilizerId") and root then
			local away = (root.Position - mount.Position).Magnitude
			if away < distance then nearest = mount; distance = away end
		end
	end
	-- A saved job may refer to a previous session's station ID. Use the owned station nearby in that case.
	local jobMount = findStation(player:GetAttribute("StabilizerStationId")) or findStation(stationId) or nearest
	for mount in mounts do
		local id = mount:GetAttribute("StabilizerId")
		if not id or not root or not accessible(mount) then continue end
		if not displays[mount] then
			local part = Instance.new("Part")
			part.Name = "PlacedUnknownCore"
			part.Shape = Enum.PartType.Ball
			part.Size = Vector3.one * 1.8
			part.Anchored = true
			part.CanCollide = false
			part.CanTouch = false
			part.Material = Enum.Material.Neon
			part.CanQuery = false
			part.Parent = folder
			local visual = Visuals.BuildUnknown(grade)
			visual.Name = "UnknownVisual"
			visual.Parent = part
			local board = templates.StabilizerStatusBillboard:Clone()
			board.Name = "Status"
			board.Parent = part
			displays[mount] = part
		end
		local part = displays[mount]
		local localKind = mount == jobMount and kind or "Empty"
		local rolling = mount == rollingMount
		part.Status.Enabled = not shade.Visible and not rolling and not (localKind == "Empty" and heldKnown)
		part.Transparency = 1
		local visual = part.UnknownVisual
		for _, mesh in visual:GetDescendants() do
			if mesh:IsA("BasePart") then
				if mesh:GetAttribute("AuthoredTransparency") == nil then mesh:SetAttribute("AuthoredTransparency", mesh.Transparency) end
				mesh.Transparency = (localKind == "Empty" or rolling) and 1 or mesh:GetAttribute("AuthoredTransparency")
			end
		end
		part.CanQuery = false
		part.Position = mount.Position + Vector3.new(0, 1.5 + math.sin(os.clock() * 3) * 0.12, 0)
		visual:PivotTo(CFrame.new(part.Position) * CFrame.Angles(0, os.clock() * 0.5, 0))
		part.Color = Unknown[grade] and Unknown[grade].Color or Color3.fromRGB(174, 98, 255)
		part.Status.TextLabel.Text = "CORE STABILIZER\n" .. (localKind == "Empty" and "Hold a core and press E" or localKind == "Ready" and "READY! Press E to reveal" or string.format("STABILIZING  %d:%02d", math.floor(remaining / 60), remaining % 60))
		local prompt = mount:FindFirstChild("StabilizerPrompt")
		if prompt then
			prompt.Enabled = not rolling and not shade.Visible
			prompt.ActionText = localKind == "Ready" and "Reveal core" or localKind == "Empty" and "Place held core" or "Check stabilizer"
		end
	end
	nearbyButton.Visible = nearest ~= nil and distance <= 13 and not shade.Visible and not rollingMount
	if not nearest or distance > 13 then shade.Visible = false end
end)
shade.Visible = false
return true
