--- Test suites executed by the test bootstrap, in order.
--- Add a statically required module here whenever you create a new test file: Defold only
--- builds resources reachable from the bootstrap, so a module referenced by a string would
--- not be compiled into the build.
--- @module tests.suites
return {
	require("tests.example_test"),
}
