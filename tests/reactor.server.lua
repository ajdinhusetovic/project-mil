-- Run as a temporary server Script in Studio Play; stop afterward.
local Shared = game.ReplicatedStorage.Shared
local Services = game.ServerScriptService.Server.Services
assert(not require(Shared.Config).Persistence.EnableInStudio, "Temporary Studio data only")
local Rules = require(Shared.ReactorRules)
local Data = require(Services.PlayerDataService)
local Tools = require(Services.CoreToolService)
local Plots = require(Services.PlotService)
local Reactor = require(Services.ReactorService)
local player = game.Players:GetPlayers()[1]
local data = assert(Data.Get(player))
local offline = {Slots={{Id="offline", Type="Spark", Mutation="Overloaded"}}, UpdatedAt=0}
Rules.Accrue(offline, 100000, true)
assert(offline.Stored == 4 * Rules.OfflineCap)
Rules.Accrue(offline, 100010, false)
assert(offline.Stored == 4 * Rules.OfflineCap + 40)
data.Reactor = {Slots={{Id="old", Type="Spark"}}, Stored=0, UpdatedAt=os.time()-10}
data.StabilizedCores = {
	{Id="a",Type="Reactor"}, {Id="b",Type="Ion",Mutation="Overloaded"},
	{Id="c",Type="Storm",Mutation="Radiant"}, {Id="d",Type="Storm"},
	{Id="e",Type="Lightning"}, {Id="f",Type="Quartz"},
}
assert(Data.ChangeReactor(player, "ReactorEquipBest"))
assert(data.Reactor.Stored >= 20, "Old rate accrued before swapping")
assert(#data.Reactor.Slots == 5 and #data.StabilizedCores == 2)
for i,id in {"a","b","c","d","e"} do assert(data.Reactor.Slots[i].Id == id) end
assert(Rules.Rate(data.Reactor) == 1895)
local function conserved()
	local ids, count = {}, 0
	for _,list in {data.Reactor.Slots,data.StabilizedCores} do
		for _,core in list do assert(not ids[core.Id], "Duplicate core"); ids[core.Id]=true; count+=1 end
	end
	assert(count==7)
end
conserved()
assert(not Data.ChangeReactor(player,"ReactorInstall","f"), "Full reactor rejects install")
assert(not Data.ChangeReactor(player,"ReactorRemove","forged"))
assert(Data.ChangeReactor(player,"ReactorRemove","b"))
assert(not Data.ChangeReactor(player,"ReactorRemove","b"), "Replay rejected")
Tools.Sync(player)
local function hasTool(id)
	for _,container in {player.Backpack,player.Character} do
		for _,tool in container:GetChildren() do if tool:GetAttribute("CoreId")==id then return true end end
	end
	return false
end
assert(hasTool("b") and not hasTool("a"))
assert(Data.ChangeReactor(player,"ReactorInstall","b"))
assert(not Data.ChangeReactor(player,"ReactorInstall","b"))
Tools.Sync(player)
assert(not hasTool("b"))
conserved()
data.Overcharges = 1
data.Reactor.Stored, data.Reactor.UpdatedAt = 10.5, os.time()
local before = data.Cash
local ok, payout = Data.CollectReactor(player)
assert(ok and payout==12 and data.Cash==before+12)
assert(math.abs(data.Reactor.Stored-0.5)<0.00001, "Fractional cash retained")
assert(not Data.CollectReactor(player), "Double collect gives no cash")
local snapshot = Data.GetReactorSnapshot(player)
assert(snapshot.CashRate==2274 and snapshot.CashMultiplier==1.2)
assert(not Plots.NearReactor(player))
Reactor.Handle(player,"ReactorRemove","a")
assert(#data.Reactor.Slots==5, "Remote interaction rejected away from reactor")
assert(not Plots.Teleport(player,"forged"))
assert(Plots.Teleport(player,"Plot"))
local plot = Plots.Get(player)
player.Character:PivotTo(CFrame.new(plot.Reactor.Position+Vector3.new(0,3,7)))
assert(Plots.NearReactor(player))
plot.Model:SetAttribute("OwnerUserId", -999)
assert(not Plots.NearReactor(player), "Wrong owner rejected")
plot.Model:SetAttribute("OwnerUserId", player.UserId)
data.Level,data.Power,data.Cash=30,16000,16000
local slots = data.Reactor.Slots
assert(Data.Overcharge(player,1) and data.Reactor.Slots==slots)
assert(data.Reactor.Stored>=0.5 and #data.Reactor.Slots==5)
Tools.Sync(player)
-- Leave inventory fixtures for interactive GUI testing in this Play session.
game.ReplicatedStorage.MiningDemo:FireClient(player,"ReactorSnapshot",Data.GetReactorSnapshot(player))
game.ReplicatedStorage.MiningDemo:FireClient(player,"ReactorOpen")
print("PASS: reactor sorting/mutations, core conservation, transfers/hotbar, replay/full-slot rejection, accrual, bonus/fraction collection, offline cap, teleport/ownership/proximity, Overcharge retention")
