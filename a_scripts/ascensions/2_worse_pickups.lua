AscensionDesc = "Worse pickups"

local mod = Ascended
local game = Game()
local level = game:GetLevel()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pick, collider)
	if collider.Type ~= EntityType.ENTITY_PLAYER and collider:ToFamiliar() == nil then
		return nil
	end

	if pick.SubType == 42 then
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
				local data = mod.Data.run
				local type = 1

				if pick:GetSprite():GetFilename() == "gfx/broken_key2.anm2" then
					type = 2
				end

				if collider:ToFamiliar() ~= nil then
					if mod.rng():RandomFloat() <= 0.5 then
						collider:ToFamiliar():AddKeys(1)
					end
				else
					if type == nil then type = 1 + pick:GetDropRNG():RandomInt(2) end
					
					if data.KeyPieces1 == nil then data.KeyPieces1 = 0 end
					if data.KeyPieces2 == nil then data.KeyPieces2 = 0 end
					
					if type == 1 then
						if data.KeyPieces1 > 5 then
							return true
						end

						data.KeyPieces1 = data.KeyPieces1 + 1
					elseif type == 2 then
						if data.KeyPieces2 > 5 then
							return true
						end

						data.KeyPieces2 = data.KeyPieces2 + 1
					end

					if data.KeyPieces1 > 0 and data.KeyPieces2 > 0 then
						data.KeyPieces1 = data.KeyPieces1 - 1
						data.KeyPieces2 = data.KeyPieces2 - 1

						local k = Isaac.Spawn(5, 30, 1, pick.Position, collider.Velocity, pick.Spawner)
						mod.SeenPickups[k.InitSeed] = true
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

			if spr:GetAnimation() == "Idle" or spr:WasEventTriggered("DropSound") then
				local data = mod.Data.run

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
	if pick.SubType == 42 then
		if pick.Variant == 20 then
			local spr = pick:GetSprite()
			local data = pick:GetData()

			if spr:IsEventTriggered("DropSound") then
				sfx:Play(SoundEffect.SOUND_PENNYDROP)
			end

			if data.Give == nil then
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
			local spr = pick:GetSprite()
			local data = mod.SeenPickups[pick.InitSeed]

			if spr:IsEventTriggered("DropSound") then
				sfx:Play(SoundEffect.SOUND_KEY_DROP0)
			end

			if data == 0 or data == nil then
				local s = 1 + pick:GetDropRNG():RandomInt(2)

				spr:Load("gfx/broken_key" .. s .. ".anm2", true)
				spr:Play("Appear")

				mod.SeenPickups[pick.InitSeed] = s
			end

			if spr:IsFinished("Collect") then
				pick:Remove()
			end
		elseif pick.Variant == 40 then
			local spr = pick:GetSprite()

			if spr:IsEventTriggered("DropSound") then
				sfx:Play(SoundEffect.SOUND_FETUS_LAND, 1, 2, false, 1.5)
				sfx:Play(SoundEffect.SOUND_WET_FEET, 2)
			end

			if spr:IsFinished("Collect") then
				pick:Remove()
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function(_)
	if game.TimeCounter <= 0 then
		mod.Data.run.HadAtLeastOneKey = false
		mod.SeenPickups = {}
	end

	local wets = mod.Data.run.WetBombs

	if wets == nil then return end

	Isaac.GetPlayer():AddBombs(wets)
	
	mod.Data.run.WetBombs = 0
end)

AscensionInit = function()
	mod:AddAscensionCallback("PickupInit", function(pick)
		local rng = pick:GetDropRNG()

		if pick.Variant == 20 then
			if rng:RandomFloat() <= 0.25 then
				pick:Morph(pick.Type, pick.Variant, 42)
			end
		elseif pick.Variant == 30 and pick.SubType == 42 then
			local data = mod.SeenPickups[pick.InitSeed]

			if data and data ~= 0 then
				local spr = pick:GetSprite()
				spr:Load("gfx/broken_key" .. data .. ".anm2", true)
				spr:Play("Appear")
			end
		end
	end)

	mod:AddAscensionCallback("PickupUpdate", function(pick)
		local s = mod.SeenPickups

		if s == nil then mod.SeenPickups = {} end
		
		local ind = pick.InitSeed

		if s and pick.SubType == 1 and pick.Price <= 0 and s[ind] == nil then
			if pick.Variant == 30 then
				if not mod.Data.run.HadAtLeastOneKey then
					if pick:GetDropRNG():RandomFloat() <= 0.33 then
						pick:Morph(pick.Type, pick.Variant, 42)
					end
				else mod.Data.run.HadAtLeastOneKey = true end

				s[ind] = 0
			elseif pick.Variant == 40 then
				if pick:GetDropRNG():RandomFloat() <= 0.15 then
					pick:Morph(pick.Type, pick.Variant, 42)
				end

				s[ind] = true
			end
		end
	end)
end