AscensionDesc = "Chased by Death"

local mod = Ascended

local game = Game()
local level = game:GetLevel()
local sfx = SFXManager()

EntityType.ENTITY_SPOOKSTER = 631

function mod:postSpooksterInit(entity)
	entity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	
	entity:AddEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_DONT_COUNT_BOSS_HP | EntityFlag.FLAG_NO_STATUS_EFFECTS |
		EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
	
	entity.GridCollisionClass = GridCollisionClass.COLLISION_NONE
	entity:GetSprite().Offset = Vector(0, -65)
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.postSpooksterInit, EntityType.ENTITY_SPOOKSTER)

function mod:CancelSpooksterCollision(_, ent)
	if ent.Type == EntityType.ENTITY_SPOOKSTER then return true end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.CancelSpooksterCollision)
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, mod.CancelSpooksterCollision)
mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, mod.CancelSpooksterCollision)
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.CancelSpooksterCollision)


function mod:SpooksterDamage(ent, amount)
	if ent.Type == EntityType.ENTITY_SPOOKSTER then
		if not ent:HasFullHealth() then
			ent:AddHealth(amount)
		end

		return false
	end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.SpooksterDamage)

local transparent = Color(1.0, 1.0, 1.0)
transparent:SetTint(1.0, 1.0, 1.0, 0.6)
local normalScale = Vector(1.0, 1.0)

function mod:preSpooksterUpdate(entity)
	local spr = entity:GetSprite()
	local target = game:GetNearestPlayer(entity.Position)

	if target == nil then return end

	spr.Color = transparent
	spr.Scale = normalScale
	
	entity:GetData().LastPosition = entity.Position

	if not spr:IsPlaying("Body") then
		spr:Play("Body", true)
	end

	entity.Velocity = (target.Position - entity.Position) * 0.02

	local d = (target.Position - entity.Position):Length()

	if d <= 52 then
		target:AddFear(EntityRef(entity), 3)
	end

	return true
end

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.preSpooksterUpdate, EntityType.ENTITY_SPOOKSTER)

function mod:postSpooksterRender(entity, offset)
	local screenpos = Isaac.WorldToScreen(entity.Position)
	local data = entity:GetData()

	if data.Mask == nil then
		data.Mask = Sprite()
		data.Mask:Load("gfx/spookster.anm2", true)
		data.Mask:SetAnimation(mod.rng:RandomInt(56), true)
		data.Mask:Play(data.Mask:GetAnimation(), true)
		data.Mask.PlaybackSpeed = 0.33
	end

	data.Mask.Color = transparent

	local n = data.Mask:GetAnimation()

	if data.Mask:IsFinished(n) then
		data.Mask:Play(n, true)
	end

	data.Mask:Render(screenpos + entity:GetSprite().Offset)
	
	if not game:IsPaused() then
		data.Mask:Update()
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.postSpooksterRender, EntityType.ENTITY_SPOOKSTER)

local spooksterlastroom = 84

function mod:keepSpookstersInPlace()
	local s = Isaac.FindByType(EntityType.ENTITY_SPOOKSTER, 0)
	local move = Vector(0, 0)
	local currentroom = level:GetCurrentRoomIndex()

	local pmY = math.floor(spooksterlastroom / 13)
	local mY = math.floor(currentroom / 13)

	move.Y = mY - pmY

	if move.Y == 0 then
		move.X = currentroom - spooksterlastroom

		if move.X > 1 then
			move.X = 1
		elseif move.X < -1 then
			move.X = -1
		end
	end

	if #s then
		for _, v in ipairs(s) do
			local p = game:GetNearestPlayer(v.Position)
			v.Position = p.Position - move * 240
		end
	end

	spooksterlastroom = currentroom
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.keepSpookstersInPlace)

function mod:removeSpooksters()
	local s = Isaac.FindByType(EntityType.ENTITY_SPOOKSTER, 0)

	if #s then
		for _, v in ipairs(s) do
			v:Remove()
		end
	end

	spooksterlastroom = 84

	mod.Data.Run.SpooksterTimer = 2200
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.removeSpooksters)


AscensionInit = function()
	mod:AddAscensionCallback("PlayerUpdate", function()
		local t = mod.Data.Run.SpooksterTimer
		
		if t > 0 then
			t = t - 1

			if t == 30 then
				sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1.0, 4)
				game:Darken(1, 75)
			end

			if t <= 0 then
				local p = game:GetRoom():GetCenterPos()

				Isaac.Spawn(EntityType.ENTITY_SPOOKSTER, 0, 0, p, Vector.Zero, nil)
				sfx:Play(SoundEffect.SOUND_LAZARUS_FLIP_DEAD, 0.5, 0, false, 0.75)
				local poof = Isaac.Spawn(1000, 16, 0, p - Vector(0, 24), Vector.Zero, nil)
				poof:GetSprite().Color = Color(0, 0, 0)
				poof:GetSprite().Scale = Vector(1.5, 1.5)
				game:ShakeScreen(15)
			end

			mod.Data.Run.SpooksterTimer = t
		end
	end)
end