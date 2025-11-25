local TextChatService = game:GetService("TextChatService")

local fishes = require("../../shared/constants/fishes")
local remotes = require("../../shared/remotes")

local CATCH_SUCCESS = "<font color='#63d6b2'>%s caught a %s!</font>"
local CATCH_FAILURE = "<font color='#ed4e6b'>%s failed to catch a %s</font>"

local function getChannel(name: string): TextChannel?
	local textChannels = TextChatService:FindFirstChild("TextChannels")
	return textChannels and textChannels:FindFirstChild(name) :: TextChannel?
end

local function displaySystemMessage(message: string)
	local channel = getChannel("RBXSystem")
	if channel then
		channel:DisplaySystemMessage(message)
	end
end

remotes.caughtFish.OnClientEvent:Connect(function(player: Player, fishId: string, success: boolean)
	local format = if success then CATCH_SUCCESS else CATCH_FAILURE
	local fish = fishes.byId[fishId]
	displaySystemMessage(string.format(format, player.DisplayName, fish.name))
end)
