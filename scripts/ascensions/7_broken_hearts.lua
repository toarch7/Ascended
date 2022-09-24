AscensionDesc = "Broken destiny"

local mod = Ascended
local game = Game()

function mod:brokenHeartStart(player)
	if game.TimeCounter > 0 then return end
	
    if Ascended.Ascension >= 7 then
        local name = player:GetName()

        if player:GetPlayerType() == 33 then return end
        
        if name == "Keeper" then
            player:AddBrokenHearts(1)
        elseif player:GetPlayerType() == 16 then
            player:AddBrokenHearts(2)
        elseif player:GetPlayerType() == 17 then
            player:AddBrokenHearts(1)
        else
            player:AddBrokenHearts(3)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.brokenHeartStart)