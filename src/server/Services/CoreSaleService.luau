local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Definitions = require(ReplicatedStorage.Shared.StabilizerDefinitions)
local Data = require(script.Parent.PlayerDataService)
local Tools = require(script.Parent.CoreToolService)
local World = require(script.Parent.WorldService)
local Service = {}
local quotes, lastQuote = {}, {}
local remote

local function nearBuyer(player)
	local npc = World.GetSellNpc()
	local prompt = npc and npc:FindFirstChildOfClass("ProximityPrompt")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	return npc and prompt and root and humanoid and humanoid.Health > 0
		and (root.Position - npc:GetPivot().Position).Magnitude <= prompt.MaxActivationDistance + 3
end
local function reject(player, reason)
	quotes[player] = nil
	remote:FireClient(player, "CoreSaleFailed", reason)
end
function Service.Initialize(event) remote = event end
function Service.Handle(player, action, token)
	if not nearBuyer(player) then reject(player, "Move closer to the Ore Buyer.") return end
	if action == "QuoteHeldCoreSale" or action == "QuoteAllCoreSale" then
		local now = os.clock()
		if now - (lastQuote[player] or -math.huge) < 0.3 then return end
		lastQuote[player] = now
		if action == "QuoteAllCoreSale" then
			local summary, reason = Data.GetCoreSaleSummary(player)
			if not summary then reject(player, reason) return end
			local quote = {Token = HttpService:GenerateGUID(false), Mode = "All", Cores = summary.Cores, Expires = now + 45}
			quotes[player] = quote
			remote:FireClient(player, "CoreSaleQuote", {
				Token = quote.Token, Mode = "All", Count = summary.Count,
				SellValue = summary.SellValue, IncomePerSecond = summary.IncomePerSecond,
			})
			return
		end
		local core, reason = Data.GetHeldStabilizedCore(player)
		if not core then reject(player, reason) return end
		local quote = {Token = HttpService:GenerateGUID(false), Mode = "Held", CoreId = core.Id, CoreType = core.Type, Mutation = Definitions.MutationKey(core), Expires = now + 45}
		quotes[player] = quote
		remote:FireClient(player, "CoreSaleQuote", {
			Token = quote.Token, Name = Definitions.DisplayName(core), Rarity = Definitions.RarityText(core),
			SellValue = Data.GetCashPayout(player, Definitions.SaleValue(core)), IncomeText = Definitions.IncomeText(core),
		})
	elseif action == "ConfirmHeldCoreSale" or action == "ConfirmAllCoreSale" then
		local quote = quotes[player]
		local mode = action == "ConfirmAllCoreSale" and "All" or "Held"
		if not quote or quote.Mode ~= mode or typeof(token) ~= "string" or quote.Token ~= token or os.clock() > quote.Expires then
			reject(player, "This offer expired. Ask for a new price.") return
		end
		quotes[player] = nil
		if mode == "All" then
			local success, payout, count = Data.SellAllCores(player, quote.Cores)
			if not success then reject(player, payout) return end
			Tools.Sync(player)
			remote:FireClient(player, "CoresSold", payout, count)
			return
		end
		local success, payout, name = Data.SellHeldCore(player, quote.CoreId, quote.Mutation, quote.CoreType)
		if not success then reject(player, payout) return end
		Tools.Sync(player)
		remote:FireClient(player, "CoreSold", payout, name)
	end
end
function Service.Release(player)
	quotes[player] = nil
	lastQuote[player] = nil
end
return Service
