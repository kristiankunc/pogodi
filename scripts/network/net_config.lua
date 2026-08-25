---@class net_config
local M = {}

M.SERVER_HOST = sys.get_config_string("network.host", "localhost")
M.SERVER_PORT = sys.get_config_int("network.port", 8765)

return M
