AscensionDesc = "Enemies act faster"

local mod = AscendedModref
local game = Game()

function mod:makeEveryoneFaster()
    if Ascended.Current >= 13 and not game:IsPaused() and game.TimeCounter % 10 == 0 then
        local e = Isaac.FindInRadius(Isaac.GetPlayer().Position, 12800, EntityPartition.ENEMY)
        
        if #e then
            for _, v in pairs(e) do
				if not v:IsDead() and v:IsVulnerableEnemy() and v:IsActiveEnemy(false) and not (v.Type == 950 and v.Variant == 0) then
					local frame = v:GetSprite():GetFrame()
					local px = v.Position.X
					local py = v.Position.Y

					v:Update()

					v.Position.X = px
					v.Position.Y = py
					v:GetSprite():SetFrame(frame)
				end
			end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.makeEveryoneFaster)