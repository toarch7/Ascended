AscensionDesc = "Items don't heal you on pickup"

local mod = Ascended

mod.healRemovalData = {}

function mod:healthUpItemHandling(player, a)
	local h = GetPtrHash(player)

    local queue = player.QueuedItem
    
	if not player:IsItemQueueEmpty() and queue.Item:IsCollectible() then
		mod.healRemovalData[h] = player:GetHearts()
	end
	
    if mod.healRemovalData[h] ~= nil and player:IsItemQueueEmpty() then
		local oldhealth = mod.healRemovalData[h]

		if Ascended.Ascension >= 8 and player:GetHearts() > oldhealth then
			player:AddHearts(oldhealth - player:GetHearts())
		end

		mod.healRemovalData[h] = nil
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.healthUpItemHandling)