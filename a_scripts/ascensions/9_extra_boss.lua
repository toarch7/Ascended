AscensionDesc = "Extra Boss Room each floor"

local mod = Ascended
local game = Game()
local level = game:GetLevel()
local sfx = SFXManager()

mod.SecondBossRoomLayout = "1010"
mod.InGenerationLoop = false

function mod:GenerateExtraBoss(dim)
	if dim == nil then dim = -1 end

	local hasmirrorworld = (level:GetStage() == 2 and level:GetStageType() >= 3)
	local hasrailplates = (level:GetStage() == 4 and level:GetStageType() >= 3)
	local hasmarkedskull = (level:GetStage() == 6 and level:GetStageType() <= 2)

	mod.SecondBossRoom = -1

	for i = 0, 168, 1 do
		local bossroom = mod.GetRoomByIdx(i, dim)
		
		if bossroom and bossroom.Data.Type == RoomType.ROOM_BOSS then
			local dirs = {13, 1, -13, -1}
			
			for _, v in ipairs(dirs) do
				local r = mod.GetRoomByIdx(i + v, dim)
				
				if r and r.Data.Type == RoomType.ROOM_DEFAULT and mod.RoomGetNeighbors(i + v, dim) == 2 then
					local newbossroomidx = i + v

					if newbossroomidx < 0 or newbossroomidx > 168 then return -1 end
					
					local newbossroom = mod.GetRoomByIdx(newbossroomidx, dim)

					if hasmirrorworld then
						local variant = newbossroom.Data.Variant
						
						if variant >= 5000 and variant <= 5018 then
							return -1
						end
					elseif hasrailplates then
						local variant = newbossroom.Data.Variant
						
						if variant >= 5000 and variant <= 5030 then
							return -1
						end
					elseif hasmarkedskull then
						local variant = newbossroom.Data.Variant
						
						if variant >= 10000 and variant <= 10040 then
							return -1
						end
					end
					
					if newbossroom and newbossroom.Data.Shape == RoomShape.ROOMSHAPE_1x1 then
						Isaac.ExecuteCommand("goto s.boss." .. mod.SecondBossRoomLayout)
						
						local newdata = mod.GetRoomByIdx(-3, 0)
						
						if newdata then
							newbossroom.Data = newdata.Data
						else return -1 end
						
						Isaac.ExecuteCommand("goto 6 6 0")
						
						return newbossroomidx
					end
					
					return -1
				end
			end
		end
	end
	
	return -1
end

function mod:TryGenerateSecondBoss(dim)
	if dim == nil then dim = -1 end
	
	local iter = 0
	
	mod.InGenerationLoop = true
	
	while iter <= 100 do
		local res = mod:GenerateExtraBoss(dim)

		if res ~= -1 then
			mod.SecondBossRoom = res
			break
		end
		
		iter = iter + 1
		
		Isaac.ExecuteCommand("reseed")
	end

	level:UpdateVisibility()

	mod.InGenerationLoop = false
end

AscensionInit = function()
	mod:AddAscensionCallback("PreRoomAward", function()
		if mod.SecondBossRoom == nil then
			mod.SecondBossRoom = -1
		end
		
		if level:GetCurrentRoomIndex() == mod.SecondBossRoom then
			local room = game:GetRoom()
			local any = false

			for i = 0, room:GetGridSize() do
				local grid = room:GetGridEntity(i)
				
				if grid and grid:ToPit() then
					grid:ToPit():MakeBridge(nil)
					Isaac.Spawn(1000, 15, 0, grid.Position, Vector.Zero, nil)
					any = true
				end
			end
			
			if any then
				sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
			end
			
			return true
		end
	end)

	mod:AddAscensionCallback("NewLevel", function()
		if game:IsGreedMode() then return end

		local stage = level:GetStage()

		mod.SecondBossRoomLayout = Ascended.DecideBoss()
		
		if stage ~= 9 and stage <= 11 and not level:IsAscent() and not mod.InGenerationLoop then
			mod:TryGenerateSecondBoss()

			if level:GetStage() == 2 and level:GetStageType() >= 3 then
				mod:TryGenerateSecondBoss(1)
			end
		end
	end)
end