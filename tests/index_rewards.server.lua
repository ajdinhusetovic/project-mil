-- Run as a temporary server Script in Studio Play; stop afterward.
local shared=game.ReplicatedStorage.Shared
assert(not require(shared.Config).Persistence.EnableInStudio,"Temporary Studio data only")
local rewards=require(shared.IndexRewards)
local cores=require(shared.StabilizerDefinitions)
local dataService=require(game.ServerScriptService.Server.Services.PlayerDataService)
local player=game.Players:GetPlayers()[1]
local data=assert(dataService.Get(player))
data.DiscoveredCores={}
data.Overcharges=0
assert(dataService.GetCashPayout(player,100)==100)
for i,key in cores.Order do
	assert(dataService.DiscoverCore(player,key))
	assert(dataService.DiscoverCore(player,key),"Duplicate discovery remains idempotent")
	assert(rewards.Count(data.DiscoveredCores)==i)
	assert(math.abs(dataService.GetCashMultiplier(player)-(1+.05*math.floor(i/2)))<.000001)
end
assert(dataService.GetCashPayout(player,100)==120)
assert(rewards.Next(8)==nil)
assert(not dataService.DiscoverCore(player,"Forged"))
data.Overcharges=1
assert(dataService.GetCashPayout(player,100)==144,"Rebirth and Index bonuses stack")
data.Reactor={Slots={},Stored=10.5,UpdatedAt=os.time()}
local ok,payout=dataService.CollectReactor(player)
assert(ok and payout==15)
assert(math.abs(data.Reactor.Stored-(10.5-15/1.44))<.000001,"Reactor retains unpaid fraction")
local requirements=require(shared.OverchargeDefinitions).Requirements(1)
data.Level,data.Power,data.Cash=requirements.Level,requirements.Power,requirements.Cash
assert(dataService.Overcharge(player,1))
assert(rewards.Count(data.DiscoveredCores)==8,"Rebirth keeps permanent discoveries")
assert(dataService.GetCashPayout(player,100)==168)
print("Index milestones, duplicate/forged discovery, cash payouts, reactor fractions and rebirth retention passed")
