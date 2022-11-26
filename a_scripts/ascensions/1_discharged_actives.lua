AscensionDesc = "Discharged active items"

local mod = Ascended
local game = Game()
local sfx = SFXManager()

AscensionInit = function()
	mod:AddAscensionCallback("PlayerUpdate", function(p)
		if game.TimeCounter == 10 then
			local any = false
			
			if p:GetActiveCharge(ActiveSlot.SLOT_PRIMARY) > 0 then
				p:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
				any = true
			end

			if p:GetActiveCharge(ActiveSlot.SLOT_SECONDARY) ~= 0 then
				p:DischargeActiveItem(ActiveSlot.SLOT_POCKET)
				any = true
			end
			
			if any then
				Isaac.Spawn(1000, 49, 3, p.Position + Vector(0, -64), Vector.Zero, p)
				
				p:AnimateSad()
				
				sfx:Play(SoundEffect.SOUND_BATTERYDISCHARGE)
			end
		end
	end)

	mod:AddAscensionCallback("PrePickupCollision", function(p)
		if p.Variant == 100 or p.Variant == 150 then
			local data = mod.Data.Run.SeenPickups
			local ind = "p" .. tostring(p.InitSeed)
			
			if data[ind] == nil then
				data[ind] = 1
				p.Charge = 0
			end
		end
	end)
end