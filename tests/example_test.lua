--- Template test module - replace it with your own suites.
--- @module tests.example_test
local color = require("scripts.utils.color")

return {
	name = "example",
	cases = {
		{
			"hex_to_rgba converts an 8 character hex string",
			function(t)
				local rgba = color.hex_to_rgba("00FF0080")

				t.near(rgba.x, 0)
				t.near(rgba.y, 1)
				t.near(rgba.z, 0)
				t.near(rgba.w, 128 / 255)
			end,
		},
		{
			"hex_to_rgba defaults to a fully opaque alpha channel",
			function(t)
				t.eq(color.hex_to_rgba("292929").w, 1)
			end,
		},
		{
			"hex_to_rgba rejects malformed input",
			function(t)
				t.fails(function()
					color.hex_to_rgba("12345")
				end, "invalid hex color")
			end,
		},
	},
}
