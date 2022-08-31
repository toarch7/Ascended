local mod = AscendedModref

local json = require("json")
local game = Game()

function mod.loadAscensionData()
	if mod:HasData() then
		Ascended.Data = json.decode(mod:LoadData())
	end

	mod.roomsCleared = Ascended.Data.roomsCleared
	
	Ascended.Active = not game:IsGreedMode() and game.Difficulty == Difficulty.DIFFICULTY_HARD
	
	local player = mod.GetCurrentChar()

	if Ascended.Active then
		Ascended.SetAscension(player, Ascended.GetCharacterAscension(player))
	else
		Ascended.SetAscension(player, 0)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.loadAscensionData)

function mod:saveAscensionData()
	if Ascended.Active then
		Ascended.Data.roomsCleared = mod.roomsCleared
		mod:SaveData(json.encode(Ascended.Data))
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveAscensionData)



function mod:postGameOver(death) -- ascension progress
	if not death and Ascended.Active then
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