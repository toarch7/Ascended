AscensionDesc = "Weaker soul hearts"

local mod = Ascended

function mod:weakerSoulhearts(ent, amount, flags)
	if Ascended.Ascension < 6 then return end
	
    local p = ent:ToPlayer()

	if not p then return end

	if p:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then return end

	if (flags & DamageFlag.DAMAGE_RED_HEARTS ~= DamageFlag.DAMAGE_RED_HEARTS) then
		if p and amount > 0 and amount <= 1 and p:GetSoulHearts() > 1 then
			p:AddSoulHearts(-1)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.weakerSoulhearts, EntityType.ENTITY_PLAYER)