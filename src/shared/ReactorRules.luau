local Cores = require(script.Parent.StabilizerDefinitions)
local Rules = {Capacity = 5, OfflineCap = 4 * 60 * 60}
local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
function Rules.Prepare(reactor, now)
	if type(reactor.Slots) ~= "table" then reactor.Slots = {} end
	if not finite(reactor.Stored) or reactor.Stored < 0 then reactor.Stored = 0 end
	if not finite(reactor.UpdatedAt) then reactor.UpdatedAt = now end
end
function Rules.Rate(reactor)
	local rate = 0
	for _, core in reactor.Slots do
		if Cores.Cores[core.Type] then rate += Cores.Income(core) end
	end
	return rate
end
function Rules.Accrue(reactor, now, offline)
	Rules.Prepare(reactor, now)
	local elapsed = math.max(0, now - reactor.UpdatedAt)
	if offline then elapsed = math.min(elapsed, Rules.OfflineCap) end
	reactor.Stored += Rules.Rate(reactor) * elapsed
	reactor.UpdatedAt = now
end
return Rules
