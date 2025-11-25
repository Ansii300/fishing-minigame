export type Pool = {
	name: string,
	fishes: { string },
}

local pools: { [string]: Pool } = {
	pond = {
		name = "Tranquil Pond",
		fishes = { "salmon", "tuna", "trout", "shark" },
	},
}

local function getPoolIdFromInstance(instance: Instance): string?
	local poolId = instance:GetAttribute("PoolId")
	return if type(poolId) == "string" and pools[poolId] then poolId else nil
end

return {
	byId = pools,
	getPoolIdFromInstance = getPoolIdFromInstance,
}
