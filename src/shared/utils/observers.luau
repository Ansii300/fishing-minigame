local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

type Cleanup = () -> ()

export type Observer<Key> = {
	add: <Args...>(instance: Key, factory: (Args...) -> Cleanup?, Args...) -> (),
	remove: (instance: Key) -> (),
	clear: () -> (),
}

local function noop() end

local function createObserver<Key>(setup: (Observer<Key>) -> Cleanup): Cleanup
	local cleanups: { [Key]: Cleanup } = {}

	local function remove(key: Key)
		local cleanup = cleanups[key]
		if cleanup then
			cleanups[key] = nil
			cleanup()
		end
	end

	local function add<Args...>(key: Key, factory: (Args...) -> Cleanup?, ...: Args...)
		remove(key)
		cleanups[key] = factory(...) or noop
	end

	local function clear()
		for key, cleanup in cleanups do
			cleanup()
			cleanups[key] = nil
		end
	end

	local stop = setup({
		add = add,
		remove = remove,
		clear = clear,
	})

	return function()
		stop()
		clear()
	end
end

local function observeTag<T>(tag: string, callback: (T) -> Cleanup?): Cleanup
	return createObserver(function(observer: Observer<T>)
		local instanceAdded = CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance: any)
			observer.add(instance, callback, instance)
		end)

		local instanceRemoved = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance: any)
			observer.remove(instance)
		end)

		for _, instance: any in CollectionService:GetTagged(tag) do
			observer.add(instance, callback, instance)
		end

		return function()
			instanceAdded:Disconnect()
			instanceRemoved:Disconnect()
		end
	end)
end

local function observePlayers(callback: (Player) -> Cleanup?): Cleanup
	return createObserver(function(observer: Observer<Player>)
		local playerAdded = Players.PlayerAdded:Connect(function(player)
			observer.add(player, callback, player)
		end)

		local playerRemoving = Players.PlayerRemoving:Connect(function(player)
			observer.remove(player)
		end)

		for _, player in Players:GetPlayers() do
			observer.add(player, callback, player)
		end

		return function()
			playerAdded:Disconnect()
			playerRemoving:Disconnect()
		end
	end)
end

local function observeCharacter(player: Player, callback: (Model) -> Cleanup?): Cleanup
	return createObserver(function(observer: Observer<"character">)
		local characterAdded = player.CharacterAdded:Connect(function(character)
			observer.add("character", callback, character)
		end)

		local characterRemoving = player.CharacterRemoving:Connect(function()
			observer.remove("character")
		end)

		if player.Character then
			observer.add("character", callback, player.Character)
		end

		return function()
			characterAdded:Disconnect()
			characterRemoving:Disconnect()
		end
	end)
end

local function observeChildWhichIsA<T>(parent: Instance, className: string, callback: (T) -> Cleanup?): Cleanup
	return createObserver(function(observer: Observer<T>)
		local childAdded = parent.ChildAdded:Connect(function(child)
			if child:IsA(className) then
				observer.add(child, callback, child)
			end
		end)

		local childRemoving = parent.ChildRemoved:Connect(function(child)
			if child:IsA(className) then
				observer.remove(child)
			end
		end)

		for _, child in parent:GetChildren() do
			if child:IsA(className) then
				observer.add(child, callback, child)
			end
		end

		return function()
			childAdded:Disconnect()
			childRemoving:Disconnect()
		end
	end)
end

return {
	createObserver = createObserver,
	observeTag = observeTag,
	observeCharacter = observeCharacter,
	observePlayers = observePlayers,
	observeChildWhichIsA = observeChildWhichIsA,
}
