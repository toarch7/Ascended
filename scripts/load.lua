local mod = AscendedModref

local json = require("json")
local game = Game()

function mod:saveAscensionData()
	if Ascended.Active then
		if mod.roomsCleared == nil then
			mod.roomsCleared = 0
		end

		Ascended.Data.roomsCleared = mod.roomsCleared

		mod:SaveData(json.encode(Ascended.Data))
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveAscensionData)

function mod.loadAscensionData()
	if mod:HasData() then
		Ascended.Data = json.decode(mod:LoadData())
	end

	mod.roomsCleared = Ascended.Data.roomsCleared

	mod.UpdateAscendedStatus()
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.loadAscensionData)



function mod:postGameOver(death)
	-- ascension progress
	if not death and Ascended.Active and not Ascended.Freeplay then
		if game:GetLevel():GetStage() ~= 10 then
			local player = mod.GetCurrentChar()
			local asc = math.min(#Ascended.EffectDescriptions, Ascended.Current + 1)
			Ascended.SetAscension(player, asc)
			mod:saveAscendedData()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_END, mod.postGameOver)



-- load saved data upon reloading the mod
if Isaac.GetPlayer(0) ~= nil then
	mod.loadAscensionData()
end