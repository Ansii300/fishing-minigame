local stats = require("../stats")
local suite = require("../../../test/suite")

suite.test("getProgressSpeedPercentage returns original value", function()
	for percentage = -1, 1, 0.1 do
		local speed = stats.getProgressSpeed(percentage)
		local computedPercentage = stats.getProgressSpeedPercentage(speed)

		assert(
			math.abs(computedPercentage - percentage) < 0.0001,
			`percentage: {percentage}, speed: {speed}, computedPercentage: {computedPercentage}`
		)
	end
end)

return {}
