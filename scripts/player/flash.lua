---@class player_flash
local M = {}

local FLASH_DURATION = 0.25
local COLOR_FLASH = vmath.vector4(1, 0.3, 0.3, 1)

---Initialize per-instance flash state.
---@param self table script instance
---@param label_id string|hash the label component to tint
---@param normal_color vector4
function M.init(self, label_id, normal_color)
	self.flash_timer = 0
	self.flash_label = label_id
	self.flash_normal = normal_color
	self.flash_active = false
end

---Trigger a red flash on the label.
---@param self table script instance
function M.flash(self)
	self.flash_timer = FLASH_DURATION
	self.flash_active = true
	go.set(self.flash_label, "color", COLOR_FLASH)
end

---Decrement the flash timer and restore the normal color.
---@param self table script instance
---@param dt number
function M.update(self, dt)
	if not self.flash_active then
		return
	end
	self.flash_timer = self.flash_timer - dt
	if self.flash_timer <= 0 then
		self.flash_active = false
		go.set(self.flash_label, "color", self.flash_normal)
	end
end

return M
