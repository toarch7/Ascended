AscensionDesc = "Discharged active items"

local mod = Ascended
local game = Game()
local sfx = SFXManager()

AscensionInit = function()
	mod:AddAscensionCallback("PlayerUpdate", function(p)
		if game.TimeCounter == 10 then
			local slots = { ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY, ActiveSlot.SLOT_POCKET, ActiveSlot.SLOT_POCKET2 }
			local any = false

			for _, v in pairs(slots) do
				local item = p:GetActiveItem(v)
				
				if item ~= 0 and p:GetActiveCharge(v) > 0 then
					p:SetActiveCharge(0, v)
					any = true
				end
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