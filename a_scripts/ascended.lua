local mod = Ascended
local game = Game()

local function choose(...)
	local options = {...}
	return options[mod.rng:RandomInt(#options) + 1]
end

function mod.GetCurrentChar()
	local p = Isaac.GetPlayer(0)

	if not p then return -1 end

	local t = p:GetPlayerType()

	if t == 11 then t = 8 end -- lazarus
	if t == 12 then t = 3 end -- judas
	if t == 17 then t = 16 end -- forgotten
	if t == 38 then t = 29 end -- tlaz
	if t == 39 then t = 37 end -- jacob
	if t == 40 then t = 35 end -- forgotten

	return p:GetName() .. t
end


local AscentionNumberName = {
	"I", "II", "III", "IV",
	"V", "VI", "VII", "VIII", "IX",
	"X", "XI", "XII", "XIII", "XIV",
	"XV", "XVI", "XVII", "XVIII", "XIX",
	"XX", "XXI", "XXII", "XXIII", "uh"
}

function Ascended.InitData()
	Ascended.Data = {
		Run = {},
	
		Freeplay = 2,
		DisplayIcon = 1,
	
		Ascensions = {},
		Deactivated = {}
	}

	Ascended.ResetRunData()
end

function Ascended.ResetRunData()
	Ascended.Data.Run = {
		WetBombs = 0,
		KeyPieces = { 0, 0 },
		SeenPickups = { },
		HadAtLeastOneKey = false,
		RoomsCleared = 0,

		SpooksterTimer = 2200
	}
end

Ascended.InitData()

Ascended.EffectDescriptions = {}

Ascended.Active = true
Ascended.Freeplay = false

Ascended.SecondBossRoomLayout = "1010"

function Ascended.PickupInd(pick)
	return pick.Type .. "." .. pick.Variant .. "." .. pick.SubType .. "_" .. pick.InitSeed
end

function Ascended.GetPickupData(pick)
	return Ascended.Data.Run.SeenPickups[Ascended.PickupInd(pick)]
end

function Ascended.SetPickupData(pick, val)
	Ascended.Data.Run.SeenPickups[Ascended.PickupInd(pick)] = val
end

Ascended.AscensionGetName = function(num)
	local n = AscentionNumberName[num]
	
	if n ~= nil then
		return n
	end
	
	return num
end

Ascended.GetCharacterAscension = function(character)
	local a = Ascended.Data.Ascensions["char" .. character]
	
	if a == nil then
		return 1
	end
	
	return a
end

Ascended.SetAscension = function(character, level)
	Ascended.Data.Ascensions["char" .. character] = level
	Ascended.Ascension = level
end


-- Ascension loading
mod.AscensionCallbacks = { }
mod.AscensionInitializers = { }

function mod:IncludeAscensions()
	local files = {
		"1_discharged_actives",
		"2_worse_pickups",
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

	mod.AscensionInitializers = {}
	
	for _, v in pairs(files) do
		AscensionInit = nil

		include("a_scripts.ascensions." .. v)

		if AscensionInit ~= nil then
			table.insert(mod.AscensionInitializers, { AscensionInit, AscensionDesc, v })
		end
	end
end

function mod:InitAscensions()
	local player = mod.GetCurrentChar()
	
	Ascended.Active = not game:IsGreedMode() and game.Difficulty == Difficulty.DIFFICULTY_HARD and game.Challenge == 0
	Ascended.Freeplay = Ascended.Data.Freeplay == 1

	mod.AscensionCallbacks = {}
	mod.EffectDescriptions = {}

	if Ascended.Active then
		Ascended.SetAscension(player, Ascended.GetCharacterAscension(player))

		local deact = Ascended.Data.Deactivated

		if deact == nil then
			deact = {}
		end

		local n = 1

		for _, v in pairs(mod.AscensionInitializers) do
			if not Ascended.Freeplay and n > Ascended.Ascension then
				break
			end

			if deact[v[3]] ~= 2 then
				v[1]()

				n = n + 1
				
				table.insert(mod.EffectDescriptions, v[2])
			end
		end
	else Ascended.SetAscension(player, 0) end
end

-- Callbacks
function mod:AddAscensionCallback(name, func, priority)
	if mod.AscensionCallbacks[name] == nil then
		mod.AscensionCallbacks[name] = {}
	end

	if priority then
		table.insert(mod.AscensionCallbacks[name], 1, func)

		return nil
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
	if game.TimeCounter == 0 then
		Ascended.ResetRunData()
		mod:InitAscensions()
	end

	mod:FireAscensionCallback("NewLevel")
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider, low)
	local r = mod:FireAscensionCallback("PrePickupCollision", pickup, collider, low)

	if r ~= nil then
		return r
	end
end)


Ascended.DecideBoss = function()
	local level = Game():GetLevel()
	
	local stg = level:GetStage()
	local typ = level:GetStageType()
	
	-- I have no idea how to get random boss room layouts more properly so here we go
	if stg <= 2 then
		if typ == 0 then
			return choose(
				"101" .. mod.Random(8), -- Monstro
				"205" .. mod.Random(3), -- Gemini
				"102" .. mod.Random(8), -- Larry Jr.
				"502" .. mod.Random(5), -- Dingle
				"514" .. mod.Random(4), -- Gurglings
				
				"516" .. mod.Random(5), -- Baby Plum
				"11"  .. (17 + mod.Random(4)), -- Dangle
				"51"  .. (46 + mod.Random(5)), -- Turdlings
				"207" .. mod.Random(3) -- Steven
			)
		elseif typ == 1 then
			return choose(
				"332" .. mod.Random(3), -- The Blighted Ovum
				"334" .. mod.Random(5), -- Widow
				"337" .. mod.Random(8), -- Pin
				"501" .. mod.Random(4), -- Haunt
				"516" .. mod.Random(5), -- Baby Plum
				choose("1019", "1029", "1035", "1036") -- Ragman
			)
		elseif typ == 2 then
			return choose(
				"101" .. mod.Random(8), -- Monstro
				"205" .. mod.Random(3), -- Gemini
				"102" .. mod.Random(8), -- Larry Jr.
				"502" .. mod.Random(5), -- Dingle
				"514" .. mod.Random(5), -- Gurglings
				"516" .. mod.Random(5), -- Baby Plum
				choose("1019", "1029", "1035", "1036"), -- Ragman
				
				"11"  .. (17 + mod.Random(4)), -- Dangle
				"51"  .. (46 + mod.Random(5)), -- Turdlings
				"207" .. mod.Random(3) -- Steven
			)
		elseif typ == 4 then
			return choose(
				"518" .. mod.Random(4), -- Wormwood
				"517" .. mod.Random(5), -- Beelzeblub
				
				"523" .. mod.Random(2), -- Rainmaker
				"523" .. mod.Random(3) -- Min Min
			)
		elseif typ == 5 then
			return choose(
				"518" .. mod.Random(4), -- Wormwood
				"517" .. mod.Random(5), -- Beelzeblub
				
				"519" .. mod.Random(4), -- Clog
				"532" .. mod.Random(2), -- Turdlet
				"5330" -- Colostomia
			)
		end
	elseif stg <= 4 then
		if typ == 0 then	
			return choose(
				"202" .. mod.Random(5), -- Peep
				"328" .. mod.Random(3), -- Gurdy Jr.
				"339" .. (4 + mod.Random(3)), -- Big Horn,
				"527" .. mod.Random(4), -- Bumbino
				choose("3398", "3399", "3404", "3405"), -- Rag Mega
				
				"103" .. mod.Random(2), -- Chub
				"104" .. mod.Random(4), -- Gurdy
				"503" .. mod.Random(5), -- Mega Maw
				"110" .. mod.Random(4), -- C.H.A.D.
				"110" .. (6 + mod.Random(3)), -- Stain
				choose("5050", "5051", "5052", "5054") -- Mega Fatty
			)
		elseif typ == 1 then
			return choose(
				"202" .. mod.Random(5), -- Peep
				"328" .. mod.Random(3), -- Gurdy Jr.
				"339" .. (4 + mod.Random(3)), -- Big Horn,
				"527" .. mod.Random(4), -- Bumbino
				choose("3398", "3399", "3404", "3405"), -- Rag Mega
				
				"237" .. mod.Random(3), -- Carrion Queen
				"329" .. mod.Random(5), -- The Husk
				"336" .. mod.Random(3), -- The Wrethced
				"510" .. mod.Random(6), -- Polycephalus
				"508" .. mod.Random(4), -- Dark One
				"338" .. (4 + mod.Random(5)), -- Frail
				choose("1079", "1085", "1086", "1087") -- Forsaken
			)
		elseif typ == 2 then
			return choose(
				"202" .. mod.Random(5), -- Peep
				"328" .. mod.Random(3), -- Gurdy Jr.
				"339" .. (4 + mod.Random(3)), -- Big Horn,
				"527" .. mod.Random(4), -- Bumbino
				choose("3398", "3399", "3404", "3405"), -- Rag Mega
				
				"103" .. mod.Random(2), -- Chub
				"104" .. mod.Random(4), -- Gurdy
				"503" .. mod.Random(5), -- Mega Maw
				"505" .. mod.Random(4), -- Mega Fatty
				"110" .. mod.Random(4), -- C.H.A.D.
				"110" .. (6 + mod.Random(3)), -- Stain
				"338" .. (4 + mod.Random(5)), -- Frail
				choose("1079", "1085", "1086", "1087") -- Forsaken
			)
		elseif typ == 4 then
			return choose(
				"525" .. mod.Random(6), -- Reap Creep
				"522" .. mod.Random(6), -- Hornfell
				"508" .. mod.Random(4) -- Dark One (because here's too few fitting bosses)
			)
		elseif typ == 5 then
			return choose(
				"524" .. mod.Random(4), -- The Pile
				"525" .. mod.Random(4), -- Singe
				"602" .. mod.Random(2), -- Singe
				"522" .. mod.Random(6) -- Hornfell
			)
		end
	elseif stg <= 6 then
		if typ == 0 or typ == 2 then	
			return choose(
				"203" .. mod.Random(3), -- Loki
				"340" .. (6 + mod.Random(3)), -- Sisters Vis
				"1116", -- Brownie
				
				"105" .. mod.Random(4), -- Monstro II
				"111" .. mod.Random(4), -- Gish
				"506" .. mod.Random(4), -- The Cage
				"504" .. mod.Random(5), -- The Gate
				"525" .. mod.Random(6) -- Reap Creep
			)
		elseif typ == 1 then
			return choose(
				"203" .. mod.Random(3), -- Loki
				"340" .. (6 + mod.Random(3)), -- Sisters Vis
				"1116", -- Brownie
				
				"330" .. mod.Random(3), -- The Bloat
				"335" .. mod.Random(3), -- Mask of Infamy
				"509" .. mod.Random(4), -- The Adversary
				"524" .. mod.Random(4) -- The Pile
			)
		elseif typ == 4 then
			return choose(
				"537" .. mod.Random(2), -- Siren
				"529" .. mod.Random(3), -- Heretic
				"509" .. mod.Random(4), -- The Adversary
				"330" .. mod.Random(3) -- The Bloat
			)
		elseif typ == 5 then
			return choose(
				"530" .. mod.Random(1), -- The Visage
				"601" .. mod.Random(2), -- Horny Boys
				"330" .. mod.Random(3), -- The Bloat
				"504" .. mod.Random(5) -- The Gate
			)
		end
	elseif stg <= 8 then
		if typ <= 2 then
			return choose(
				"331" .. mod.Random(3), -- Lokii
				"107" .. mod.Random(5), -- Scolex
				"204" .. mod.Random(3), -- Blastocyst
				"507" .. mod.Random(2), -- Mama Gurdy
				"330" .. mod.Random(3), -- The Bloat
				"340" .. mod.Random(3), -- Daddy Long Legs
				"341" .. mod.Random(3), -- Triachnid
				"5152" -- Matriarch
			)
		else	
			return choose(
				"536" .. mod.Random(2), -- Scourge
				"535" .. mod.Random(2), -- Chimera
				"535" .. mod.Random(2), -- Chimera
				"5340", -- Rotgut
				"5152" -- Matriarch
			)
		end
	else
		if stg == 10 then
			if typ == 0 then return "3600" end
			if typ == 1 then return "3380" end
		elseif stg == 11 then
			if typ == 0 then return "5130" end
			if typ == 1 then return "3390" end
		end
	end
	
	return "1010"
end