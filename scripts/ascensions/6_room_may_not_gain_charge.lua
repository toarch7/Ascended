AscensionDesc = "Room may not gain you charge"

local mod = AscendedModref

mod.postSpawnCleanAward = false
mod.roomsCleared = 0

function mod:activeItemDischarge(p)
	if mod.postSpawnCleanAward then
		if Ascended.Current >= 6 and mod.roomsCleared % 3 == 0 then
			local slots = { ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY, ActiveSlot.SLOT_POCKET, ActiveSlot.SLOT_POCKET2 }
			
			for _, v in pairs(slots) do
				local item = p:GetActiveItem(v)
				
				if item ~= 0 then
					local cur = p:GetActiveCharge(v)
					local m = Isaac.GetItemConfig():GetCollectible(item).MaxCharges
					
					if cur > 0 and cur < m then
						p:SetActiveCharge(cur - 1, v)
					end
				end
			end
		end

		mod.postSpawnCleanAward = false
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.activeItemDischarge)

function mod:makePostSpawnCleanAward()
	mod.postSpawnCleanAward = true
	mod.roomsCleared = mod.roomsCleared + 1
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.makePostSpawnCleanAward)
