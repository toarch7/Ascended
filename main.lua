AscendedModref = RegisterMod("Ascended", 1)

local mod = AscendedModref

local game = Game()
local level = game:GetLevel()

mod.rng = RNG()
mod.targetAccomplished = false

local function choose(...)
	local options = {...}
	return options[mod.rng:RandomInt(#options) + 1]
end

local json = require("json")

function mod.GetSaveData()
    if not mod.menusavedata then
        if Isaac.HasModData(mod) then
            mod.menusavedata = json.decode(Isaac.LoadModData(mod))
        else
            mod.menusavedata = {}
        end
    end

    return mod.menusavedata
end

function mod.StoreSaveData()
    Isaac.SaveModData(mod, json.encode(mod.menusavedata))
end

function mod.GetCurrentChar()
	local p = Isaac.GetPlayer(0)

	if not p then return -1 end

	local t = p:GetPlayerType()

	if t == 11 then t = 8 end
	if t == 12 then t = 3 end
	if t == 17 then t = 16 end
	if t == 38 then t = 29 end
	if t == 39 then t = 37 end
	if t == 40 then t = 35 end

	return t
end

function mod.Random(n)
	return mod.rng:RandomInt(n + 1)
end

Ascended = {
	Data = {
		Ascensions = {}
	},
	
	Current = 1,

	Active = true,
	Freeplay = false,
	
	EffectDescriptions = {},
	
	AscentionNumberName = {
		"I", "II", "III", "IV",
		"V", "VI", "VII", "VIII", "IX",
		"X", "XI", "XII", "XIII", "XIV",
		"XV", "XVI", "XVII", "XVIII", "XIX",
		"XX", "XXI", "XXII", "XXIII", "uh"
	},
	
	AscensionGetName = function(num)
		local n = Ascended.AscentionNumberName[num]
		
		if n ~= nil then
			return n
		end
		
		return num
	end,
	
	GetCharacterAscension = function(character)
		local a = Ascended.Data.Ascensions["char" .. character]
		
		if a == nil then
			return 1
		end
		
		return a
	end,
	
	SetAscension = function(character, level)
		Ascended.Data.Ascensions["char" .. character] = level
		Ascended.Current = level
	end,
	
	GetTarget = function(character)
		local a = Ascended.Data.Ascensions["target" .. character]
		
		if a == nil then
			return math.random(1, #Ascended.TargetNames)
		end
		
		return a
	end,
	
	SetTarget = function(character, target)
		Ascended.Data.Ascensions["target" .. character] = target
		Ascended.CurrentTarget = target
	end,
	
	DecideBoss = function()
		local stg = level:GetStage()
		local typ = level:GetStageType()
		
		-- I have no idea how to get random boss room layouts more properly so here we go
		if stg <= 2 then
			if typ == 0 then
				return choose(
					"101" .. mod.Random(8), -- Monstro
					"205" .. mod.Random(3), -- Gemini
					"102" .. mod.Random(8), -- Larry Jr.
					"502" .. mod.Random(6), -- Dingle
					"514" .. mod.Random(5), -- Gurglings
					
					"516" .. mod.Random(5), -- Baby Plum
					"11"  .. (17 + mod.Random(4)), -- Dangle
					"51"  .. (46 + mod.Random(5)), -- Turdlings
					"207" .. mod.Random(3) -- Steven
				)
			elseif typ == 1 then
				return choose(
					"332" .. mod.Random(3), -- The Blighted Ovum
					"334" .. mod.Random(5), -- Widow
					"337" .. mod.Random(9), -- Pin
					"501" .. mod.Random(4), -- Haunt
					"516" .. mod.Random(5), -- Baby Plum
					choose("1019", "1029", "1035", "1036") -- Ragman
				)
			elseif typ == 2 then
				return choose(
					"101" .. mod.Random(8), -- Monstro
					"205" .. mod.Random(3), -- Gemini
					"102" .. mod.Random(8), -- Larry Jr.
					"502" .. mod.Random(6), -- Dingle
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
					"505" .. mod.Random(4), -- Mega Fatty
					"110" .. mod.Random(4), -- C.H.A.D.
					"110" .. (6 + mod.Random(3)) -- Stain
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
}


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

function mod.UpdateAscendedStatus()
	local player = mod.GetCurrentChar()
	
	Ascended.Active = not game:IsGreedMode() and game.Difficulty == Difficulty.DIFFICULTY_HARD and game.Challenge == 0
	Ascended.Freeplay = mod.GetSaveData().freeplay == 1

	if Ascended.Active then
		Ascended.SetAscension(player, Ascended.GetCharacterAscension(player))

		if Ascended.Freeplay then
			Ascended.SetAscension(player, 15)
		end
	else
		Ascended.SetAscension(player, 0)
	end
end

function mod:postPlayerInit()
	if game.TimeCounter > 0 then return end

	mod.rng:SetSeed(game:GetSeeds():GetStartSeed(), 16)
	mod.targetAccomplished = false
	mod.UI.leftstartroom = false
	mod.SecondBossRoom = -1

	mod.UpdateAscendedStatus()
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.postPlayerInit)

function mod.newLevel()
	if game:IsGreedMode() then return end

	local stage = level:GetStage()

	mod.SecondBossRoomLayout = Ascended.DecideBoss()
	
	if Ascended.Current >= 10 and stage ~= 9 and stage <= 11 and not level:IsAscent() and not mod.InGenerationLoop then
		mod:TryGenerateSecondBoss()

		if level:GetStage() == 2 and level:GetStageType() >= 3 then
			mod:TryGenerateSecondBoss(1)
		end
	end

	if Ascended.Current >= 3 and level:GetStage() <= 8 then
		mod:removeSpecialRooms()
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.newLevel)

function mod.handleCommand(_, cmd, params)
	if cmd == "ascent" or cmd == "ascend" then
		local player = mod.GetCurrentChar()
		Ascended.SetAscension(player, tonumber(params))
		print("Set ascension for " .. player .. " to " .. tonumber(params))
		mod:saveAscendedData()
	end
end

mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, mod.handleCommand)



-- Include other scripts
local includes = {
	"scripts.load",
	"scripts.ui",

	"scripts.ascensions.1_discharged_active_items",
	"scripts.ascensions.2_less_room_rewards",
	"scripts.ascensions.3_higher_shop_prices",
	"scripts.ascensions.4_less_special_rooms",
	"scripts.ascensions.5_full_heart_damage_ch3",
	"scripts.ascensions.6_weaker_soul_hearts",
	"scripts.ascensions.7_broken_hearts",
	"scripts.ascensions.8_items_dont_grant_health",
	"scripts.ascensions.9_extra_boss_room",
	"scripts.ascensions.10_room_may_not_gain_charge",
	"scripts.ascensions.11_worse_beggars",
	"scripts.ascensions.12_consumable_cap",
	"scripts.ascensions.13_faster_enemies",
	"scripts.ascensions.14_less_iframes",
	"scripts.ascensions.15_spookster",

	"scripts.dss.ascendedmenu",

	"scripts.test"
}

for _, v in ipairs(includes) do
	AscensionDesc = nil
	
	include(v)
	
	if AscensionDesc ~= nil then
		table.insert(Ascended.EffectDescriptions, AscensionDesc)
	end
end