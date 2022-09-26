AscensionDesc = "Worse pickups"

local mod = Ascended
local game = Game()
local level = game:GetLevel()
local sfx = SFXManager()

mod:AddAscensionCallback("PrePickupCollision", function(pick, collider)
	if collider.Type ~= EntityType.ENTITY_PLAYER then return false end

	if pick.Variant == 20 and pick.SubType == 42 then
		local spr = pick:GetSprite()

		if spr:GetAnimation() == "Idle" or spr:WasEventTriggered("DropSound") then
			if pick:GetData().Give then
				collider:ToPlayer():AddCoins(1)

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
	end
end)

mod:AddAscensionCallback("PickupUpdate", function(pick)
	if pick.Variant == 20 and pick.SubType == 42 then
		local spr = pick:GetSprite()
		local data = pick:GetData()

		if spr:IsEventTriggered("DropSound") then
			sfx:Play(SoundEffect.SOUND_PENNYDROP)
		end

		if data.Give == nil then
			data.Give = pick:GetDropRNG():RandomFloat() < 0.5

			if not data.Give and mod.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_GUPPYS_EYE) then
				local c = Color(0.5, 0.5, 0.5, 1, 0, 0, 0)
				c:SetColorize(1, 1, 1, 0.5)

				spr.Color = c
			end
		end

		if spr:IsFinished("Collect") then
			pick:Remove()
		end
	end
end)

AscensionInit = function()
	mod:AddAscensionCallback("PickupInit", function(pick)
		local rng = pick:GetDropRNG()

		if pick.Variant == 20 then
			if rng:RandomFloat() <= 0.25 then
				pick:Morph(pick.Type, pick.Variant, 42)
			end
		end
	end)
end