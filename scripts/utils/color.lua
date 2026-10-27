--- Color conversion helpers.
--- @module color
local M = {}

local OPAQUE = 1
local BYTE_MAX = 255

local function to_channel(hex, from, to)
	return tonumber(string.sub(hex, from, to), 16) / BYTE_MAX
end

--- Converts a hex color string to a vector4.
--- Accepts "RRGGBBAA", "RRGGBB", "#RRGGBBAA" and "#RRGGBB".
--- The string is case insensitive. When the alpha channel is omitted it defaults to fully opaque.
--- @param hex string Hex color, e.g. "292929FF".
--- @return vector4 rgba Color with channels in the 0..1 range.
function M.hex_to_rgba(hex)
	local value = string.gsub(hex, "#", "")
	local length = #value

	if not (length == 6 or length == 8) or string.match(value, "%X") then
		error(('invalid hex color "%s": expected RRGGBB or RRGGBBAA'):format(hex))
	end

	local r = to_channel(value, 1, 2)
	local g = to_channel(value, 3, 4)
	local b = to_channel(value, 5, 6)
	local a = length == 8 and to_channel(value, 7, 8) or OPAQUE

	return vmath.vector4(r, g, b, a)
end

return M
