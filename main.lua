Ascended = RegisterMod("Ascended", 1)

local mod = Ascended

local game = Game()
local level = game:GetLevel()

include("ascended")

mod.rng = RNG()

function mod.Random(n)
	return mod.rng:RandomInt(n + 1)
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

-- ascension loading
mod.AscensionCallbacks = { }

mod.AscensionIncludes = {
	"1_discharged_active_items",
	"2_less_room_rewards",
	"3_higher_shop_prices",
	"4_less_special_rooms",
	"5_full_heart_damage_ch3",
	"6_weaker_soul_hearts",
	"7_broken_hearts",
	"8_items_dont_grant_health",
	"9_extra_boss_room",
	"10_room_may_not_gain_charge",
	"11_worse_beggars",
	"12_consumable_cap",
	"13_less_iframes",
	"14_spookster"
}

function mod:LoadAscensions()
	local files = mod.AscensionIncludes

	mod.AscensionCallbacks = { }

	for n, v in pairs(files) do
		if n > Ascended.Ascension then
			break
		end
		
		AscensionInit = nil
		
		include("scripts.ascensions." .. v)
		
		if AscensionDesc ~= nil then
			table.insert(Ascended.EffectDescriptions, AscensionDesc)
		end
	end
end

function mod:InitAscensions()
	local player = mod.GetCurrentChar()
	
	Ascended.Active = not game:IsGreedMode() and game.Difficulty == Difficulty.DIFFICULTY_HARD and game.Challenge == 0
	Ascended.Freeplay = mod.GetSaveData().freeplay == 1

	if Ascended.Active then
		Ascended.SetAscension(player, Ascended.GetCharacterAscension(player))

		if Ascended.Freeplay then
			local m = #mod.AscensionIncludes
			Ascended.SetAscension(player, m)
		end

		mod:LoadAscensions()
	else Ascended.SetAscension(player, 0) end
end

-- callbacks 
function mod:AddAscensionCallback(name, ascension, func, ...)
	if mod.AscensionCallbacks[name] == nil then
		mod.AscensionCallbacks[name] = {}
	end

	if Ascended.Ascension >= ascension then
		table.insert(mod.AscensionCallbacks[name], {ascension, func})
	end
end

function mod:FireAscensionCallback(name, ...)
	local list = mod.AscensionCallbacks[name]

	if list == nil then return end

	for _, v in pairs(list) do
		if Ascended.Ascension >= v[1] then
			local r = v[2](...)

			if r ~= nil then
				return r
			end
		end
	end
end

-- rest
function mod:NewLevel()
	if game:IsGreedMode() then return end

	--[[
	local stage = level:GetStage()

	
	mod.SecondBossRoomLayout = Ascended.DecideBoss()
	
	if Ascended.Ascension >= 9 and stage ~= 9 and stage <= 11 and not level:IsAscent() and not mod.InGenerationLoop then
		mod:TryGenerateSecondBoss()

		if level:GetStage() == 2 and level:GetStageType() >= 3 then
			mod:TryGenerateSecondBoss(1)
		end
	end]]
	
	mod:FireAscensionCallback("NewLevel")

	--[[if Ascended.Ascension >= 4 and level:GetStage() <= 8 then
		mod:removeSpecialRooms()
	end]]
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.NewLevel)

mod.PostCleanAward = false

function mod:PostPlayerInit(player)
	if game.TimeCounter > 0 then return end

	mod.rng:SetSeed(game:GetSeeds():GetStartSeed(), 16)

	mod.UI.leftstartroom = false
	mod.SecondBossRoom = -1
	
	mod:InitAscensions()

	mod:FireAscensionCallback("NewRun", player)
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.PostPlayerInit)

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if mod.PostCleanAward then
		mod:FireAscensionCallback("PostRoomAward", player)
		mod.PostCleanAward = false
	end

	mod:FireAscensionCallback("PlayerUpdate", player)
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	mod:FireAscensionCallback("PickupUpdate", pickup)
end)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng)
	local r = mod:FireAscensionCallback("PreRoomAward", rng)

	if r ~= nil then
		return r
	end
end)


include("scripts.load")
include("scripts.ui")
include("scripts.dss.ascendedmenu")
include("scripts.test")