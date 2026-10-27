--- Minimal test runner. A suite module returns `{ name = string, cases = { { name, fn } } }`,
--- each case receives the assertion table and fails by raising. Every event is also printed as a
--- `TEST {json}` line for CI.
---@class tests.runner
local M = {}

local EVENT_PREFIX = "TEST "
local STATUS_PASS = "pass"
local STATUS_FAIL = "fail"

local RUN_ID = string.format("%d-%x", os.time(), math.floor(os.clock() * 1000000) % 0xffffff)

local function elapsed_ms(started)
	return math.floor((os.clock() - started) * 1000 + 0.5)
end

local function repr(value)
	local value_type = type(value)

	if value_type == "string" then
		return string.format("%q", value)
	elseif value_type == "number" and value == math.floor(value) then
		return string.format("%d", value)
	elseif value_type == "number" then
		return string.format("%.6g", value)
	elseif value_type == "table" then
		local parts = {}
		for key, item in pairs(value) do
			parts[#parts + 1] = string.format("%s = %s", repr(key), repr(item))
		end
		table.sort(parts)
		return "{ " .. table.concat(parts, ", ") .. " }"
	end

	return tostring(value)
end

local function deep_equal(left, right)
	if left == right then
		return true
	end

	if type(left) ~= "table" or type(right) ~= "table" then
		return false
	end

	for key, item in pairs(left) do
		if not deep_equal(item, right[key]) then
			return false
		end
	end

	for key in pairs(right) do
		if left[key] == nil then
			return false
		end
	end

	return true
end

-- level 0: keep the runner internals out of the message.
local function assertion_error(message, description)
	error(message .. (description and (" - " .. description) or ""), 0)
end

local function new_assertions()
	return {
		--- Truthy check.
		ok = function(value, description)
			if not value then
				assertion_error(("expected a truthy value, got %s"):format(repr(value)), description)
			end
		end,

		--- Equality, deep for tables.
		eq = function(actual, expected, description)
			if not deep_equal(actual, expected) then
				assertion_error(("expected %s, got %s"):format(repr(expected), repr(actual)), description)
			end
		end,

		--- Numeric comparison within `epsilon` (default 0.000001).
		near = function(actual, expected, epsilon, description)
			local tolerance = epsilon or 0.000001
			if math.abs(actual - expected) > tolerance then
				assertion_error(
					("expected %s +/- %s, got %s"):format(repr(expected), repr(tolerance), repr(actual)),
					description
				)
			end
		end,

		--- Fails unless `fn` raises, optionally matching a Lua pattern against the message.
		fails = function(fn, pattern, description)
			local ok, err = pcall(fn)

			if ok then
				assertion_error("expected an error, but the function returned", description)
			end

			if pattern and not string.find(tostring(err), pattern) then
				assertion_error(
					("expected the error to match %q, got %s"):format(pattern, repr(tostring(err))),
					description
				)
			end
		end,
	}
end

local function split_traceback(err)
	local message, traceback = string.match(err, "^(.-)\nstack traceback:(.*)$")
	if message then
		return message, traceback
	end
	return err, nil
end

local function emit(event)
	event.run = RUN_ID
	print(EVENT_PREFIX .. json.encode(event))
end

local function run_suite(suite)
	local suite_name = suite.name or "unnamed"
	local cases = suite.cases or {}
	local passed, failed = 0, 0

	print(("\n%s (%d cases)"):format(suite_name, #cases))
	emit({ event = "suite_start", suite = suite_name, tests = #cases })

	for _, case in ipairs(cases) do
		local case_name, fn = case[1], case[2]
		local started = os.clock()
		local ok, err = xpcall(function()
			fn(new_assertions())
		end, debug.traceback)
		local duration = elapsed_ms(started)

		if ok then
			passed = passed + 1
			print(("  pass  %s (%d ms)"):format(case_name, duration))
			emit({ event = "case", suite = suite_name, name = case_name, status = STATUS_PASS, duration_ms = duration })
		else
			failed = failed + 1
			local message, traceback = split_traceback(tostring(err))
			print(("  FAIL  %s (%d ms)\n        %s%s"):format(case_name, duration, message, traceback or ""))
			emit({
				event = "case",
				suite = suite_name,
				name = case_name,
				status = STATUS_FAIL,
				duration_ms = duration,
				message = message,
			})
		end
	end

	emit({
		event = "suite_end",
		suite = suite_name,
		status = failed == 0 and STATUS_PASS or STATUS_FAIL,
		passed = passed,
		failed = failed,
	})

	return passed, failed
end

---@param suites table[] suite modules from `tests/suites.lua`
---@return integer failed
function M.run(suites)
	local started = os.clock()
	local passed_total, failed_total = 0, 0

	for _, suite in ipairs(suites) do
		local passed, failed = run_suite(suite)
		passed_total = passed_total + passed
		failed_total = failed_total + failed
	end

	local duration = elapsed_ms(started)
	local status = failed_total == 0 and STATUS_PASS or STATUS_FAIL

	print(("\n%s: %d passed, %d failed (%d ms)"):format(status:upper(), passed_total, failed_total, duration))
	emit({
		event = "run_end",
		status = status,
		passed = passed_total,
		failed = failed_total,
		duration_ms = duration,
	})

	return failed_total
end

return M
