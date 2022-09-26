AscensionDesc = "Discharged active items"

local mod = Ascended
local game = Game()
local sfx = SFXManager()

mod.PedestalData = {}

AscensionInit = function()
	mod:AddAscensionCallback("PlayerUpdate", function(p)
		if game.TimeCounter == 10 then
			local any = false
			
			if p:GetActiveItem(ActiveSlot.SLOT_PRIMARY) ~= 0 then
				p:DischargeActiveItem(ActiveSlot.SLOT_PRIMARY)
				any = true
			end

			if p:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= 0 then
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
			local seed = p:GetDropRNG():GetSeed()

			local roll = false
			
			if mod.PedestalData[seed] == nil then roll = true mod.PedestalData[seed] = true end
			if mod.PedestalData[p.SubType] == nil then roll = true mod.PedestalData[p.SubType] = true end
			
			if roll then
				p.Charge = 0
			end
		end
	end)

	mod:AddAscensionCallback("NewLevel", function()
		mod.PedestalData = {}
	end)
end