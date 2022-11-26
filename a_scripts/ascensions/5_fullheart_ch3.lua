AscensionDesc = "Full heart damage since ch. 3"

local mod = Ascended
local game = Game()
local level = game:GetLevel()

AscensionInit = function()
    mod:AddAscensionCallback("PlayerDamaged", function(p, amount)
        if p:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then return end

        if level:GetStage() >= 5 and amount == 1 and p:GetSoulHearts() <= 0 and p:GetHearts() > 1 then
            p:AddHearts(-1)
        end
    end)
end