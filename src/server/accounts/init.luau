local HttpService = game:GetService("HttpService")

local Charm = require("../../modules/Charm")
local fishes = require("../shared/fishes")
local fishingStore = require("../shared/stores/fishingStore")
local objects = require("../shared/utils/objects")
local store = require("@self/store")
local types = require("../shared/types")

type Account = types.Account

local function sellFish(player: Player, uniqueId: string)
	return store:update(player, function(account: Account)
		local fish = account.fishes[uniqueId]

		if not fish then
			return false
		end

		account.fishes[uniqueId] = nil
		account.gold += fishes.getFishValue(fish)

		return true
	end)
end

local function addReeledFish(player: Player)
	return store:update(player, function(account: Account)
		local mutableData = Charm.toRaw(fishingStore.getFisher(player.Name))

		if not mutableData or not mutableData.fish then
			return false
		end

		local id = HttpService:GenerateGUID(false)
		local fish = objects.deepCopy(mutableData.fish)

		account.fishes[id] = fish

		return true
	end)
end

return {
	sellFish = sellFish,
	addReeledFish = addReeledFish,
}
