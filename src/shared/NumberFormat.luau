-- Presentation only: never replace the original numeric stats with formatted strings.
local NumberFormat = {}
local suffixes = {"", "k", "m", "b", "t", "qa", "qi", "sx", "sp", "oc", "no", "dc"}
local function trim(value)
	return (value:gsub("0+$", ""):gsub("%.$", ""))
end
function NumberFormat.Compact(value)
	if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return "0" end
	local sign = value < 0 and "-" or ""
	local amount = math.abs(value)
	local tier = 1
	while amount >= 1000 and tier < #suffixes do
		amount /= 1000
		tier += 1
	end
	if tier == 1 then
		local rounded = math.floor(amount * 100 + 0.5) / 100
		if rounded == 0 then return "0" end
		if rounded < 1000 then return sign .. trim(string.format("%.2f", rounded)) end
		amount, tier = 1, 2
	end
	amount = math.floor(amount * 10 + 0.5) / 10
	-- Rounding 999.99k promotes to 1m, rather than displaying 1000k.
	if amount >= 1000 and tier < #suffixes then amount /= 1000; tier += 1 end
	if amount >= 1000 then return string.format("%.1e", value) end
	return sign .. trim(string.format("%.1f", amount)) .. suffixes[tier]
end
return NumberFormat
