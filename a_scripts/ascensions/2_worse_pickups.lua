AscensionDesc = "Worse pickups"

local mod = Ascended
local game = Game()
local level = game:GetLevel()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pick, collider)
	if collider:ToFamiliar() == nil               and
	   collider.Type ~= EntityType.ENTITY_PLAYER  and
	   collider.Type ~= EntityType.ENTITY_BUMBINO and
	   collider.Type ~= EntityType.ENTITY_ULTRA_GREED
	then return nil end
	
	if pick.SubType == 42 then -- is worse pickup
		if pick.Variant == 20 then -- counterfeit pennies
			local spr = pick:GetSprite()

			if spr:GetAnimation() == "Idle" or spr:WasEventTriggered("DropSound") then
				if pick:GetData().Give then
					local c = collider:ToPlayer()
					
					if c == nil then c = collider:ToFamiliar() end

					c:AddCoins(1)

					sfx:Play(SoundEffect.SOUND_PENNYPICKUP, 1.0, 2, false, 1.2)
					spr:Play("Collect")

					pick.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
					pick:Die()
				else
					sfx:Play(SoundEffect.SOUND_PENNYPICKUP, 1.0, 5.0, false, 0.9)

					Isaac.Spawn(EntityType.ENTITY_EFFECT, 15, 1, pick.Position, Vector.Zero, nil)
					
					pick:Remove()
				end

				return true
			end

			return true
		elseif pick.Variant == 30 then -- broken keys
			local spr = pick:GetSprite()

			if spr:GetAnimation() == "Idle" or spr:WasEventTriggered("DropSound") then
				local data = Ascended.Data.Run
				local type = 1
				
				if pick:GetSprite():GetFilename() == "gfx/broken_key2.anm2" then
					type = 2
				end

				if collider:ToFamiliar() ~= nil then
					if mod.rng():RandomFloat() <= 0.5 then
						collider:ToFamiliar():AddKeys(1)
					end
				else
					if data.KeyPieces[type] > 5 then
						return true
					end

					data.KeyPieces[type] = data.KeyPieces[type] + 1

					if data.KeyPieces[1] > 0 and data.KeyPieces[2] > 0 then
						data.KeyPieces[1] = data.KeyPieces[1] - 1
						data.KeyPieces[2] = data.KeyPieces[2] - 1

						local k = Isaac.Spawn(5, 30, 1, pick.Position, collider.Velocity, pick.Spawner)
						mod.SetPickupData(k, true)
					end
				end
				
				sfx:Play(SoundEffect.SOUND_FETUS_FEET, 0.5, 2, false, 1.5)
				
				spr:Play("Collect")

				pick.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pick:Die()

				return true
			end
		elseif pick.Variant == 40 then -- wet bombs
			local spr = pick:GetSprite()
			local data = Ascended.Data.Run

			if spr:GetAnimation() == "Idle" or spr:WasEventTriggered("DropSound") then
				if data.WetBombs == nil then
					data.WetBombs = 0
				end

				data.WetBombs = data.WetBombs + 1
				
				sfx:Play(SoundEffect.SOUND_FETUS_FEET, 1, 2, false, 1.5)
				sfx:Play(SoundEffect.SOUND_WET_FEET, 1)
				
				spr:Play("Collect")

				pick.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				pick:Die()

				return true
			end
		end

		return true
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pick)
	if pick.SubType ~= 42 then return end
	
	local spr = pick:GetSprite()

	if pick.Variant == 20 then
		local data = pick:GetData()

		if spr:IsEventTriggered("DropSound") then
			sfx:Play(SoundEffect.SOUND_PENNYDROP)
		end

		if data.Give == nil then
			pick:GetDropRNG():SetSeed(pick.InitSeed, 1)

			data.Give = pick:GetDropRNG():RandomFloat() < 0.5

			if not data.Give and (mod.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_EYE) or mod.AnyCharacterByName("Cain")) then
				local c = Color(0.5, 0.5, 0.5, 1, 0, 0, 0)
				c:SetColorize(1, 1, 1, 0.5)

				spr.Color = c
			end
		end

		if spr:IsFinished("Collect") then
			pick:Remove()
		end
	elseif pick.Variant == 30 then
		local data = mod.GetPickupData(pick)

		if spr:IsEventTriggered("DropSound") then
			sfx:Play(SoundEffect.SOUND_KEY_DROP0)
		end

		if data == 0 or data == nil then
			local s = 1 + pick:GetDropRNG():RandomInt(2)

			spr:Load("gfx/broken_key" .. s .. ".anm2", true)
			spr:Play("Appear")

			mod.SetPickupData(pick, s)
		end

		if spr:IsFinished("Collect") then
			pick:Remove()
		end
	elseif pick.Variant == 40 then
		if spr:IsEventTriggered("DropSound") then
			sfx:Play(SoundEffect.SOUND_FETUS_LAND, 1, 2, false, 1.5)
			sfx:Play(SoundEffect.SOUND_WET_FEET, 2)
		end

		if spr:IsFinished("Collect") then
			pick:Remove()
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function(_)
	local wets = mod.Data.Run.WetBombs

	if wets == nil or wets <= 0 then return end

	Isaac.GetPlayer():AddBombs(wets)
	
	mod.Data.Run.WetBombs = 0
end)

AscensionInit = function()
	mod:AddAscensionCallback("PickupInit", function(pick) -- replace pennies and update key piece sprites
		if pick.Variant == 30 and pick.SubType == 42 then
			local data = mod.GetPickupData(pick)

			if data and data ~= 0 then
				local spr = pick:GetSprite()
				spr:Load("gfx/broken_key" .. data .. ".anm2", true)
				spr:Play("Idle")
			end
		elseif pick.Variant == 20 and pick.SubType == 1 then
			local rng = pick:GetDropRNG()

			if rng:RandomFloat() <= 0.25 then
				pick:Morph(pick.Type, pick.Variant, 42)
			end
		end
	end)

	mod:AddAscensionCallback("PickupUpdate", function(pick)
		if pick.SubType == 1 and pick.Price <= 0 then
			local s = mod.GetPickupData(pick)
			
			if s == nil then
				if pick.Variant == 30 then -- make broken key
					if not mod.Data.Run.HadAtLeastOneKey then
						if pick:GetDropRNG():RandomFloat() <= 0.35 then
							pick:Morph(pick.Type, pick.Variant, 42)
						end
					else mod.Data.Run.HadAtLeastOneKey = true end

					mod.SetPickupData(pick, 0)
				elseif pick.Variant == 40 then -- make wet bomb
					if pick:GetDropRNG():RandomFloat() <= 0.25 then
						pick:Morph(pick.Type, pick.Variant, 42)
					end

					mod.SetPickupData(pick, 0)
				end
			end
		end
	end)
end