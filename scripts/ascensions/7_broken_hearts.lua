AscensionDesc = "Broken destiny"

local mod = AscendedModref
local game = Game()

function mod:brokenHeartStart(player)
	if game.TimeCounter > 0 then return end
	
    if Ascended.Current >= 11 then
        local name = player:GetName()

        local conf = mod:GetSaveData().keeperBrokenheart
        
        if name == "Keeper" then
            if player:GetPlayerType() ~= 33 or (conf == 2 and player:GetPlayerType() ~= 33) then
                player:AddBrokenHearts(1)
            end
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