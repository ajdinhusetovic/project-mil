-- Retire passive reactors without losing the cores installed in old saves.
local Migration = {}
function Migration.Apply(data)
	local seen = {}
	for _, core in data.StabilizedCores do seen[core.Id] = true end
	local reactor = data.Reactor or {}
	for _, core in reactor.Slots or {} do
		if core.Id and not seen[core.Id] then
			table.insert(data.StabilizedCores, core)
			seen[core.Id] = true
		end
	end
	-- Uncollected reactor cash is retired; it cannot fund the new economy.
	data.Reactor = {}
	data.SchemaVersion = 2
end
return Migration
