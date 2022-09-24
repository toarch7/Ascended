AscensionDesc = "Less invulnerability"

local mod = AscendedModref

function mod:lessInvulnerability(p)
	if Ascended.Current >= 13 and p:GetDamageCooldown() > 0 then
		if p:GetDamageCooldown() > 60 and p:GetDamageCooldown() <= 90 then
            p:ResetDamageCooldown()
        elseif p:GetDamageCooldown() <= 40 then
            p:ResetDamageCooldown()
        end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.lessInvulnerability)