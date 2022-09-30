AscensionDesc = "Room may not gain you charge"

local mod = Ascended

AscensionInit = function()
	mod:AddAscensionCallback("PostRoomAward", function(p)
		local c = mod.Data.run.roomsCleared

		if c == nil then
			c = 0
		end
		
		if c % 3 == 0 then
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

		mod.Data.run.roomsCleared = c + 1
	end)
end