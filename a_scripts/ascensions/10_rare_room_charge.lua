AscensionDesc = "Room may not gain you charge"

local mod = Ascended

AscensionInit = function()
	mod:AddAscensionCallback("PostRoomAward", function(p)
		local c = mod.Data.Run.RoomsCleared or 1

		mod.Data.Run.RoomsCleared = c + 1

		if c % 3 == 0 then
			local slots = { ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY, ActiveSlot.SLOT_POCKET, ActiveSlot.SLOT_POCKET2 }
			local any = false

			for _, v in pairs(slots) do
				local item = p:GetActiveItem(v)
				
				if item ~= 0 then 
					local m = Isaac.GetItemConfig():GetCollectible(item).MaxCharges
					local cur = p:GetActiveCharge(v)

					if cur > 0 and cur < m then
						p:SetActiveCharge(cur - 1, v)
						any = true
					end
				end
			end

			if any then
				Isaac.Spawn(1000, 49, 3, p.Position + Vector(0, -64), Vector.Zero, p)
				SFXManager():Play(SoundEffect.SOUND_THUMBS_DOWN)
			end
		end
	end)
end