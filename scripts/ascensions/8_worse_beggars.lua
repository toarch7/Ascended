AscensionDesc = "Worse beggars and blood donation"

local mod = AscendedModref
local game = Game()
local sfx = SFXManager()

local beggarvariantlist = {
    2, 4, 5, 6, 7, 9, 18
}

mod.ReplaceBeggarPrize = false
mod.ReplaceBeggarEntity = nil

function mod:greedierBeggars()
    if Ascended.Current >= 8 then
		for _, vari in ipairs(beggarvariantlist) do
            local beggars = Isaac.FindByType(6, vari)
            
            if #beggars then
                for _, b in ipairs(beggars) do
                    local spr = b:GetSprite()

                    if spr:IsPlaying("Prize") then
						if spr:IsEventTriggered("Prize") then
							mod.ReplaceBeggarEntity = b
							mod.ReplaceBeggarPrize = true
						end

						if spr:GetFrame() == 0 then
							b:GetData().Player = game:GetNearestPlayer(b.Position)
						end
					elseif mod.ReplaceBeggarEntity ~= nil and GetPtrHash(mod.ReplaceBeggarEntity) == GetPtrHash(b) then
						mod.ReplaceBeggarEntity = nil
						mod.ReplaceBeggarPrize = false
					end
				end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.greedierBeggars)

function mod:replaceBeggarPrize(pick)
    if mod.ReplaceBeggarPrize then
		local beggar = mod.ReplaceBeggarEntity
		local player = beggar:GetData().Player

		if player == nil then
			player = Isaac.GetPlayer()
		end
		
        mod.ReplaceBeggarPrize = false

		if beggar.Variant == 2 then -- Blood donation machine
			if pick.Variant == 20 and ((mod.rng:RandomFloat() <= 0.5 or player:GetName() == "Keeper") or player:HasCollectible(CollectibleType.COLLECTIBLE_PHD)) then
				pick:Remove()
				return nil
			end
		end

        if pick.Variant ~= 100 and mod.rng:RandomFloat() <= 0.5 then
			if beggar.Variant == 4 or beggar.Variant == 9 then -- Default and Bomb beggars
				Isaac.Spawn(1000, 43, 0, pick.Position, Vector.Zero, nil)
				Isaac.Spawn(5, 42, 0, pick.Position, pick.Velocity, nil)

				sfx:Play(SoundEffect.SOUND_FART, 1, 0, false, 1.2 + (mod.rng:RandomFloat() * 0.4))
				
				pick:Remove()
			elseif beggar.Variant == 5 then -- Devil beggar
				local spider = Isaac.Spawn(85, 0, 0, beggar.Position, pick.Velocity * 2, Isaac.GetPlayer())

				spider:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)

				spider:GetSprite():Load("gfx/085.000_spider_inert.anm2", true)

				sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1.1 + (mod.rng:RandomFloat() * 0.2))
				
				pick:Remove()
			elseif beggar.Variant == 7 then -- Key master
				Isaac.Spawn(EntityType.ENTITY_PICKUP, 30, 0, beggar.Position, pick.Velocity / 4, nil)

				sfx:Play(SoundEffect.SOUND_KEY_DROP0, 1, 0, false, 1.1 + (mod.rng:RandomFloat() * 0.2))
				
				pick:Remove()
			elseif beggar.Variant == 18 then -- Rotten beggar
				game:Fart(beggar.Position)
				pick:Remove()
			end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.replaceBeggarPrize)


--[[
function mod:testcallback(ent, inputhook, button)
	if ent ~= nil and ent:ToPlayer() then
		if inputhook == InputHook.IS_ACTION_PRESSED and button == 4 then
			return false
		end
	end
end

mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, mod.testcallback)]]--