local Cores=require(script.Parent.StabilizerDefinitions)
local Rewards={Milestones={2,4,6,8},CashPerMilestone=.05}
function Rewards.Count(discovered)
	local count=0
	for _,key in Cores.Order do if discovered[key]==true then count+=1 end end
	return count
end
function Rewards.Bonus(count)
	local bonus=0
	for _,target in Rewards.Milestones do if count>=target then bonus+=Rewards.CashPerMilestone end end
	return bonus
end
function Rewards.Next(count)
	for _,target in Rewards.Milestones do if count<target then return target end end
	return nil
end
return Rewards
