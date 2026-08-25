---@class board
local M = {}

---@type number
M.SCALING = 100

---@type string[]
M.CORNER_KEYS = { "nw", "ne", "sw", "se" }

---@type table<string, {x: number, y: number}>
M.OFFSETS = {
	nw = { x = -1, y = 1 },
	ne = { x = 1, y = 1 },
	sw = { x = -1, y = -1 },
	se = { x = 1, y = -1 },
}

---Compute the world position of a square corner node.
---@param origin vector3 the center of the square
---@param corner string one of "nw", "ne", "sw", "se"
---@return vector3
function M.position(origin, corner)
	local offset = M.OFFSETS[corner]
	return vmath.vector3(origin.x + offset.x * M.SCALING, origin.y + offset.y * M.SCALING, origin.z)
end

---@type table<number, string>
M.SERVER_POSITION_TO_CORNER = {
	[1] = "nw",
	[2] = "ne",
	[3] = "sw",
	[4] = "se",
}

---@type table<string, number>
M.CORNER_TO_SERVER_POSITION = {
	nw = 1,
	ne = 2,
	sw = 3,
	se = 4,
}

return M
