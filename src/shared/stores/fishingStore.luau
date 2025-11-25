local Charm = require("../../../submodules/Charm")
local immutable = require("../utils/immutable")

export type Fisher = {
	seed: number,
	rodId: string,
	castPower: number,
	poolId: string?,
	fishId: string?,
}

export type FisherLuring = Fisher & {
	poolId: string,
}

export type FisherReeling = Fisher & {
	poolId: string,
	fishId: string,
}

local state = Charm.reactive({
	fishing = {} :: { [string]: Fisher },
})

local function getFishers()
	return state.fishing
end

local getFishersLuring = Charm.computed(function()
	return immutable.filter(state.fishing, function(entry: Fisher)
		return entry.poolId ~= nil and entry.fishId == nil
	end) :: { [string]: FisherLuring }
end)

local getFishersReeling = Charm.computed(function()
	return immutable.filter(state.fishing, function(entry: Fisher)
		return entry.fishId ~= nil
	end) :: { [string]: FisherReeling }
end)

local function getReelingState(username: string): FisherReeling?
	local entry = state.fishing[username]
	return if entry and entry.fishId ~= nil then entry :: FisherReeling else nil
end

local function isFishing(username: string): boolean
	return state.fishing[username] ~= nil
end

local function isLuring(username: string): boolean
	local entry = state.fishing[username]
	return entry ~= nil and entry.poolId ~= nil and entry.fishId == nil
end

local function isReeling(username: string): boolean
	local entry = state.fishing[username]
	return entry ~= nil and entry.poolId ~= nil and entry.fishId ~= nil
end

local function castRod(username: string, rodId: string, power: number, seed: number)
	state.fishing[username] = state.fishing[username] or {
		rodId = rodId,
		castPower = power,
		seed = seed,
	}
end

local function setLuringPool(username: string, poolId: string)
	local entry = state.fishing[username]
	if entry then
		entry.poolId = poolId
	end
end

local function setReelingFish(username: string, fishId: string)
	local entry = state.fishing[username]
	if entry then
		entry.fishId = fishId
	end
end

local function stopFishing(username: string)
	state.fishing[username] = nil
end

return {
	state = state,
	getFishers = getFishers,
	getFishersLuring = getFishersLuring,
	getFishersReeling = getFishersReeling,
	getReelingState = getReelingState,
	isFishing = isFishing,
	isLuring = isLuring,
	isReeling = isReeling,
	castRod = castRod,
	setLuringPool = setLuringPool,
	setReelingFish = setReelingFish,
	stopFishing = stopFishing,
}
