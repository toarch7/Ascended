AscensionDesc = "Less invulnerability"

local mod = Ascended

function AscensionInit()
    mod:AddAscensionCallback("PlayerUpdate", function (p)
        if p:GetDamageCooldown() > 0 then
            if p:GetDamageCooldown() > 60 and p:GetDamageCooldown() <= 90 then
                p:ResetDamageCooldown()
            elseif p:GetDamageCooldown() <= 40 then
                p:ResetDamageCooldown()
            end
        end
    end)
end