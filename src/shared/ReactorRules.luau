-- Legacy compatibility: passive cash is disabled, including offline accrual.
local Rules = {Capacity = 0, OfflineCap = 0}
function Rules.Prepare(reactor, now)
	reactor.Slots = reactor.Slots or {}
	reactor.Stored = 0
	reactor.UpdatedAt = now
end
function Rules.Rate(reactor) return 0 end
function Rules.Accrue(reactor, now, offline) Rules.Prepare(reactor, now) end
return Rules
