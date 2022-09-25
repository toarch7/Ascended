local mod = Ascended

local json = require("json")
local game = Game()

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

function mod:SaveAscensionData()
	if Ascended.Active then
		if mod.RoomsCleared == nil then
			mod.RoomsCleared = 0
		end

		Ascended.Data.RoomsCleared = mod.RoomsCleared

		mod:SaveData(json.encode(Ascended.Data))
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.SaveAscensionData)

function mod:LoadAscensionData(continued)
	if mod:HasData() then
		Ascended.Data = json.decode(mod:LoadData())
	end

	mod.RoomsCleared = Ascended.Data.RoomsCleared

	if game.TimeCounter > 0 then
		mod:InitAscensions()
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.LoadAscensionData)



function mod:PostGameOver(death)
	-- ascension progress
	if not death and Ascended.Active and not Ascended.Freeplay then
		if game:GetLevel():GetStage() ~= 10 then
			local player = mod.GetCurrentChar()
			local asc = math.min(#Ascended.EffectDescriptions, Ascended.Ascension + 1)
			Ascended.SetAscension(player, asc)
			mod:saveAscendedData()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.PostGameOver)


-- init once again upon a restart
if Isaac.GetPlayer(0) ~= nil then
	mod:LoadAscensionData()
end