AscensionDesc = "Broken destiny"

local mod = Ascended

function AscensionInit()
    mod:AddAscensionCallback("PlayerInit", function(player)
        if player:GetPlayerType() == 33 then return end
        
        if player:GetPlayerType() == 14 then
            player:AddBrokenHearts(1)
        elseif player:GetPlayerType() == 16 then
            player:AddBrokenHearts(2)
        elseif player:GetPlayerType() == 17 then
            player:AddBrokenHearts(1)
        else
            player:AddBrokenHearts(3)
        end
    end)
end