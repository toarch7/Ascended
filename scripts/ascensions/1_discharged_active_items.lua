AscensionDesc = "Discharged active items"

local mod = AscendedModref
local game = Game()
local sfx = SFXManager()

mod.PedestalData = {}

function mod:startActiveItemDischarge(p)
	if Ascended.Current >= 1 then
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
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.startActiveItemDischarge)

function mod:postPickupUpdate(p)
	if p.Variant == 100 or p.Variant == 150 then
		local seed = p:GetDropRNG():GetSeed()
		
		if mod.PedestalData[seed] == nil then
			mod.PedestalData[seed] = true
			
			p.Charge = 0

			print(seed)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.postPickupUpdate)

function mod:resetPedestalData()
	mod.PedestalData = {}
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.resetPedestalData)