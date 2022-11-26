AscensionDesc = "Room may not gain you charge"

local mod = Ascended

AscensionInit = function()
	mod:AddAscensionCallback("PostRoomAward", function(p)
		local c = mod.Data.Run.RoomsCleared or 1

		if c % 3 == 0 then
			local slots = { ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY, ActiveSlot.SLOT_POCKET, ActiveSlot.SLOT_POCKET2 }
			
			for _, v in pairs(slots) do
				local item = p:GetActiveItem(v)
				local cur = p:GetActiveCharge(v)
				local m = Isaac.GetItemConfig():GetCollectible(item).MaxCharges
					
				if item ~= 0 and cur > 0 and cur < m then
					p:SetActiveCharge(cur - 1, v)
				end
			end
		end

		mod.Data.Run.RoomsCleared = c + 1
	end)
end