Ascended = RegisterMod("Ascended", 1)

local mod = Ascended

local game = Game()
local level = game:GetLevel()

include("a_scripts.ascended")

mod.rng = RNG()

-- various functions
function mod.Random(n)
	return mod.rng:RandomInt(n + 1)
end

function mod.AnyoneHasCollectible(collectible)
	local n = game:GetNumPlayers()

	for i = 0, n - 1 do
		if Isaac.GetPlayer(i):HasCollectible(collectible) then
			return true
		end
	end

	return false
end

function mod.AnyCharacterByName(name)
	local n = game:GetNumPlayers()

	for i = 0, n - 1 do
		if Isaac.GetPlayer(i):GetName() == name then
			return true
		end
	end

	return false
end

function mod.AnyCharacterByType(type)
	local n = game:GetNumPlayers()

	for i = 0, n - 1 do
		if Isaac.GetPlayer(i):GetPlayerType() == type then
			return true
		end
	end

	return false
end

-- floorgen stuff
function mod.GetRoomByIdx(index, dim)
	if dim == nil then dim = -1 end

	local r = level:GetRoomByIdx(index, dim)
	
	if r and r.Data then
		return r
	end
end

function mod.RoomGetNeighbors(index, dim)
	if dim == nil then dim = -1 end
	local count = 0
	
	if mod.GetRoomByIdx(index - 1, dim) then count = count + 1 end
	if mod.GetRoomByIdx(index + 1, dim) then count = count + 1 end
	if mod.GetRoomByIdx(index - 13, dim) then count = count + 1 end
	if mod.GetRoomByIdx(index + 13, dim) then count = count + 1 end
	
	return count
end

-- includes
include("a_scripts.load")
include("a_scripts.ui")
include("a_scripts.dss.ascendedmenu")

include("a_scripts.test")

mod:IncludeAscensions()

-- etc
function mod:HandleConsoleCommand(cmd, params)
	if cmd == "ascent" or cmd == "ascend" then
		local player = mod.GetCurrentChar()

		Ascended.SetAscension(player, tonumber(params))

		print("Set ascension for " .. player .. " to " .. tonumber(params))
		
		mod:SaveAscensionData()

		mod:InitAscensions()
	end
end

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.HandleConsoleCommand)
