AscensionDesc = "Less room rewards"

local mod = AscendedModref
local game = Game()
local level = game:GetLevel()

function mod:preRoomCleanAward(rng)
	if Ascended.Current >= 2 and rng:RandomFloat() <= 0.25 then
		local r = mod.GetRoomByIdx(level:GetCurrentRoomIndex())
		
		if r and r.Data.Type == RoomType.ROOM_DEFAULT then
			local pos = Isaac.GetFreeNearPosition(game:GetRoom():GetCenterPos(), 1)
			local p = Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
			p:GetSprite().Color = Color(1.0, 0.5, 0.5)
			return true
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, mod.preRoomCleanAward)