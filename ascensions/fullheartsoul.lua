AscensionDesc = "Weaker soul hearts"

local mod = Ascended

AscensionInit = function()
    mod:AddAscensionCallback("PlayerDamaged", function(p, amount, flags)
		if p:HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then return end

		if (flags & DamageFlag.DAMAGE_RED_HEARTS ~= DamageFlag.DAMAGE_RED_HEARTS) then
			if amount > 0 and amount <= 1 and p:GetSoulHearts() > 1 then
				p:AddSoulHearts(-1)
			end
		end
	end)
end