AscensionDesc = "Less room rewards"

local mod = Ascended
local game = Game()
local level = game:GetLevel()

AscensionInit = function()
	mod:AddAscensionCallback("PreRoomAward", function(rng)
		if rng:RandomFloat() <= 0.25 then
			local r = mod.GetRoomByIdx(level:GetCurrentRoomIndex())
			
			if r and r.Data.Type == RoomType.ROOM_DEFAULT then
				local pos = Isaac.GetFreeNearPosition(game:GetRoom():GetCenterPos(), 1)
				local p = Isaac.Spawn(1000, 15, 0, pos, Vector.Zero, nil)
				p:GetSprite().Color = Color(1.0, 0.5, 0.5)

				return true
			end
		end
	end)
end