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
		AscensionDesc = nil

		include("scripts.ascensions." .. v)
		
		if AscensionInit ~= nil then
			AscensionInit()
			
			if AscensionDesc ~= nil then
				table.insert(Ascended.EffectDescriptions, AscensionDesc)
			end
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

-- Callbacks
function mod:AddAscensionCallback(name, func)
	if mod.AscensionCallbacks[name] == nil then
		mod.AscensionCallbacks[name] = {}
	end

	table.insert(mod.AscensionCallbacks[name], func)
end

function mod:FireAscensionCallback(name, ...)
	local list = mod.AscensionCallbacks[name]

	if list == nil then return end

	for _, v in pairs(list) do
		local r = v(...)

		if r ~= nil then
			return r
		end
	end
end

---

mod.PostCleanAward = false

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function (_, player)
	if game.TimeCounter > 0 then return end

	mod.rng:SetSeed(game:GetSeeds():GetStartSeed(), 16)
	
	mod.UI.leftstartroom = false
	mod.SecondBossRoom = -1

	mod:InitAscensions()

	mod:FireAscensionCallback("PlayerInit", player)
end)

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

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	mod:FireAscensionCallback("PickupInit", pickup)
end)

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_, rng)
	local r = mod:FireAscensionCallback("PreRoomAward", rng)

	mod.PostCleanAward = true

	if r ~= nil then
		return r
	end
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flags, src, frames)
	mod:FireAscensionCallback("EntityDamaged", ent, amount, flags, src, frames)
end)

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, amount, flags, src, frames)
	local p = ent:ToPlayer()

	if p ~= nil then
		mod:FireAscensionCallback("PlayerDamaged", p, amount, flags, src, frames)
	end
end, EntityType.ENTITY_PLAYER)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	mod:FireAscensionCallback("NewLevel")
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider, low)
	local r = mod:FireAscensionCallback("PrePickupCollision", pickup, collider, low)

	if r ~= nil then
		return r
	end
end)


-- includes

include("scripts.load")
include("scripts.ui")
include("scripts.dss.ascendedmenu")
include("scripts.test")