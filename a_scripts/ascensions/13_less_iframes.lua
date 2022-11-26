AscensionDesc = "Less invulnerability"

local mod = Ascended

AscensionInit = function()
    mod:AddAscensionCallback("PlayerUpdate", function (p)
        if p:GetPlayerType() == 37 then return end -- tjacob inframes fix

        if p:GetDamageCooldown() > 0 then
            if p:GetDamageCooldown() > 60 and p:GetDamageCooldown() <= 90 then
                p:ResetDamageCooldown()
            elseif p:GetDamageCooldown() <= 40 then
                p:ResetDamageCooldown()
            end
        end
    end)
end