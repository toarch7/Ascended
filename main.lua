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
mod.AscensionInitializers = { }

function mod:LoadAscensions()
	local files = {
		"1_discharged_actives",
		"2_less_rewards",
		"3_higher_shop_prices",
		"4_emptier_floors",
		"5_fullheart_ch3",
		"6_fullheart_soul",
		"7_broken_destiny",
		"8_items_dont_heal",
		"9_extra_boss",
		"10_rare_room_charge",
		"11_worse_beggars",
		"12_consumable_cap",
		"13_less_iframes",
		"14_spookster"
	}

	mod.AscensionCallbacks = { }

	for _, v in pairs(files) do
		include("a_scripts.ascensions." .. v)
		
		if AscensionInit ~= nil then
			table.insert(mod.AscensionInitializers, { AscensionInit, AscensionDesc })
		end
	end
end

mod:LoadAscensions()


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

		mod.EffectDescriptions = {}

		for n, v in pairs(mod.AscensionInitializers) do
			if n > Ascended.Ascension then
				break
			end

			v[1]()

			table.insert(mod.EffectDescriptions, v[2])
		end
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

include("a_scripts.load")
include("a_scripts.ui")
include("a_scripts.dss.ascendedmenu")
include("a_scripts.test")
