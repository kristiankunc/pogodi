---@class net
local M = {}

local socket = require("builtins.scripts.socket")
local config = require("scripts.network.net_config")

local SOCKET_TIMEOUT = 0
local NET_EVENT = hash("net_event")

local client = nil
local connected = false
---@type table<string, {url: url, url_key: string, handler: fun(data: table)}>
local handlers = {}

local function dispatch(data)
	local event = data.event
	local payload = data.data or {}
	local entry = handlers[event]
	if entry ~= nil then
		msg.post(entry.url, NET_EVENT, { event = event, payload = payload })
	else
		print("net: unhandled event: " .. tostring(event))
	end
end

local function receive_all()
	while true do
		local line, err = client:receive("*l")
		if line == nil then
			if err == "timeout" then
				return
			end
			M.disconnect()
			return
		end
		if line ~= "" then
			local ok, decoded = pcall(json.decode, line)
			if ok then
				dispatch(decoded)
			else
				print("net: invalid json: " .. line)
			end
		end
	end
end

function M.connect(host, port)
	host = host or config.SERVER_HOST
	port = port or config.SERVER_PORT
	if connected then
		print("net: already connected")
		return true
	end

	client = socket.connect(host, port)
	if client == nil then
		print("net: connect failed to " .. host .. ":" .. tostring(port))
		return false
	end

	client:settimeout(SOCKET_TIMEOUT)
	connected = true
	print("net: connected to " .. host .. ":" .. tostring(port))
	return true
end

function M.disconnect()
	if client ~= nil then
		client:close()
		client = nil
	end
	connected = false
	print("net: disconnected")
end

function M.is_connected()
	return connected
end

function M.send(event, data)
	if not connected or client == nil then
		print("net: cannot send " .. tostring(event) .. " - not connected")
		return false
	end

	local message = json.encode({ event = event, data = data })
	local ok, err = client:send(message .. "\n")
	if ok == nil then
		print("net: send failed for " .. tostring(event) .. ": " .. tostring(err))
		return false
	end
	return true
end

---Register a handler for an event, delivered to this component via on_message.
---@param event string
---@param handler fun(data: table)
function M.on(event, handler)
	handlers[event] = { url = msg.url(), url_key = tostring(msg.url()), handler = handler }
end

---Handle a delivered net_event message; call from on_message when
---message_id == hash("net_event").
---@param event string
---@param payload table
function M.handle(event, payload)
	local entry = handlers[event]
	if entry ~= nil then
		entry.handler(payload)
	end
end

---Remove this component's registered handlers; call from final().
function M.clear()
	local key = tostring(msg.url())
	for event, entry in pairs(handlers) do
		if entry.url_key == key then
			handlers[event] = nil
		end
	end
end

function M.poll()
	if not connected or client == nil then
		return
	end
	receive_all()
end

return M
