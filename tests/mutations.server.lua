-- Execute inside a temporary server Script in Studio Play. Stop afterward.
local S = game.ReplicatedStorage.Shared
local Services = game.ServerScriptService.Server.Services
assert(not require(S.Config).Persistence.EnableInStudio, "Temporary Studio data only")
local M, D = require(S.MutationDefinitions), require(S.StabilizerDefinitions)
for _, case in {{0,"None"},{84.99,"None"},{85,"Charged"},{94.99,"Charged"},{95,"Radiant"},{98.99,"Radiant"},{99,"Overloaded"},{99.99,"Overloaded"}} do
	assert(M.Roll({NextNumber=function() return case[1] end}) == case[2])
end
assert(D.Income({Type="Reactor"}) == 1000 and D.Income({Type="Reactor",Mutation="invalid"}) == 1000)
for _, key in {"Charged","Radiant","Overloaded"} do
	local core={Type="Reactor",Mutation=key}
	assert(D.Income(core)==1000*M.Variants[key].Multiplier)
	assert(D.SaleValue(core)==60000*M.Variants[key].Multiplier)
	assert(D.DisplayName(core)==key.." Reactor Core")
end
local Data, Tools, Stab = require(Services.PlayerDataService), require(Services.CoreToolService), require(Services.StabilizerService)
local p=game.Players:GetPlayers()[1]
local d=Data.Get(p)
local mount=workspace:FindFirstChild("CoreMount",true)
local station=mount:GetAttribute("StabilizerId")
p.Character:PivotTo(CFrame.new(mount.Position+Vector3.new(0,3,5)))
local finish=os.time()+1000
d.Stabilizer={Core={Id="legacy",Grade="Cracked"},Result="Storm",FinishAt=finish}
Stab.Publish(p)
assert(d.Stabilizer.Mutation=="None" and d.Stabilizer.Result=="Storm" and d.Stabilizer.FinishAt==finish)
d.Stabilizer={}
d.UnknownCores={{Id="mutation-unknown",Grade="Cracked",Depth=3}}
Tools.Sync(p)
for _,t in p.Backpack:GetChildren() do if t:GetAttribute("IsUnknownCore") then p.Character.Humanoid:EquipTool(t); break end end
Stab.Handle(p,"PlaceCore",station)
local job=d.Stabilizer
assert(job.Core and job.FinishAt and M.Variants[job.Mutation] and #d.UnknownCores==0)
local mutation, timestamp=job.Mutation,job.FinishAt
Stab.Publish(p); Stab.Publish(p)
assert(job.Mutation==mutation and job.FinishAt==timestamp)
assert(game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):JSONEncode(job)).Mutation==mutation)
job.Result,job.Mutation,job.FinishAt="Storm","Overloaded",os.time()-1
task.wait(0.25)
Stab.Handle(p,"ClaimCore",station)
assert(#d.StabilizedCores==1 and d.StabilizedCores[1].Mutation=="Overloaded" and not d.Stabilizer.Core)
local won=d.StabilizedCores[1]
task.wait(0.25); Stab.Handle(p,"ClaimCore",station)
assert(#d.StabilizedCores==1)
local tool
for _,t in p.Backpack:GetChildren() do if t:GetAttribute("CoreId")==won.Id then tool=t end end
assert(tool and tool.Name=="Overloaded Storm Core" and tool:GetAttribute("IncomePerSecond")==200)
assert(tool.Handle.CoreBillboard.IncomeLabel.Text=="$200 / SEC")
assert(tool:FindFirstChild("MutationSparks",true) and tool:FindFirstChild("MutationArc2",true))
d.Overcharges=1
p.Character.Humanoid:EquipTool(tool)
assert(not Data.SellHeldCore(p,won.Id,"None","Storm"))
local ok, payout, name=Data.SellHeldCore(p,won.Id,"Overloaded","Storm")
assert(ok and payout==14400 and name=="Overloaded Storm Core")
d.StabilizedCores={{Id="bulk-normal",Type="Spark"},{Id="bulk-radiant",Type="Storm",Mutation="Radiant"}}
local quote=Data.GetCoreSaleSummary(p)
assert(quote.SellValue==10944 and quote.IncomePerSecond==152)
d.StabilizedCores[2].Mutation="Charged"
assert(not Data.SellAllCores(p,quote.Cores), "Mutation changes invalidate the quote")
d.StabilizedCores[2].Mutation="Radiant"
local sold,total=Data.SellAllCores(p,quote.Cores)
assert(sold and total==10944)
d.StabilizedCores={won}
d.Level,d.Power,d.Cash=30,16000,16000
assert(Data.Overcharge(p,1) and d.StabilizedCores[1].Mutation=="Overloaded")
Tools.Sync(p)
print("PASS: mutation boundaries, legacy jobs, one-time start/claim, saved mutation, Tool visuals/income, sale bonuses, changed quotes and Overcharge retention")
