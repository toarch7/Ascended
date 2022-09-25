AscensionDesc = "Room may not gain you charge"

local mod = Ascended

mod.RoomsCleared = 0

function AscensionInit()
	mod:AddAscensionCallback("PostRoomAward", function()
		if mod.postSpawnCleanAward then
			if mod.roomsCleared == nil then
				mod.roomsCleared = 0
			end
			
			if mod.roomsCleared % 3 == 0 then
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
	end)
end