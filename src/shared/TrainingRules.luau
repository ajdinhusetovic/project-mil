local Config = require(script.Parent.Config)
local Rules = {}
function Rules.InMine(position)
	local half = Config.Width * Config.BlockSize / 2
	-- Include characters standing on the top rock layer, not only those below ground.
	return math.abs(position.X) < half and math.abs(position.Z) < half and position.Y < 8
end
return Rules
