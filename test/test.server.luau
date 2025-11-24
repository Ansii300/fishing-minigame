local suite = require("./suite")

if game and not game:GetService("RunService"):IsRunMode() then
	return
end

suite.describe("replay", function()
	require("../src/shared/test/replay.test")
end)

suite.describe("stats", function()
	require("../src/shared/test/stats.test")
end)

suite.finish()
