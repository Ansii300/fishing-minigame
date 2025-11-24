local Random = Random

if not Random then
	local function createRandom()
		local self = {}

		function self:NextNumber(min: number?, max: number?): number
			return math.lerp(min or 0, max or 1, math.random())
		end

		function self:NextInteger(min: number, max: number): number
			return math.random(min, max)
		end

		return self
	end

	Random = { new = createRandom } :: any
end

return {
	Random = Random,
}
