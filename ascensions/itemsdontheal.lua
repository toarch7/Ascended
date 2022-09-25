AscensionDesc = "Items don't heal you on pickup"

local mod = Ascended

mod.HealRemovalData = {}

AscensionInit = function()
	mod:AddAscensionCallback("PlayerUpdate", function(player)
		local h = GetPtrHash(player)

		local queue = player.QueuedItem
		
		if not player:IsItemQueueEmpty() and queue.Item:IsCollectible() then
			mod.HealRemovalData[h] = player:GetHearts()
		end
		
		if mod.HealRemovalData[h] ~= nil and player:IsItemQueueEmpty() then
			local oldhealth = mod.HealRemovalData[h]

			if player:GetHearts() > oldhealth then
				player:AddHearts(oldhealth - player:GetHearts())
			end

			mod.HealRemovalData[h] = nil
		end
	end)
end