AscensionDesc = "Full heart damage since ch. 3"

local mod = AscendedModref
local game = Game()
local level = game:GetLevel()

function mod:weakerSoulhearts(ent, amount, flags)
    if Ascended.Current < 9 then return end
	
    local p = ent:ToPlayer()

    if not p then return end

    if p:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then return end

	if level:GetStage() >= 5 and amount <= 1 and p:GetSoulHearts() <= 0 and p:GetHearts() > 1 then
        p:AddHearts(-1)
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.weakerSoulhearts, EntityType.ENTITY_PLAYER)