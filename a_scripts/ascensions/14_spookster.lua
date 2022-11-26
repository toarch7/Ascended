AscensionDesc = "Chased by Death"

local mod = Ascended

local game = Game()
local level = game:GetLevel()
local sfx = SFXManager()

function mod:postSpooksterInit(entity)
	entity:AddEntityFlags(EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_DONT_COUNT_BOSS_HP |
		EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
	
	entity.GridCollisionClass = GridCollisionClass.COLLISION_NONE
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, mod.postSpooksterInit, 631)

function mod:CancelSpooksterCollision(_, ent)
	if ent.Type == 631 then return true end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, mod.CancelSpooksterCollision)
mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, mod.CancelSpooksterCollision)
mod:AddCallback(ModCallbacks.MC_PRE_BOMB_COLLISION, mod.CancelSpooksterCollision)
mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, mod.CancelSpooksterCollision)

local transparent = Color(1.0, 1.0, 1.0)
transparent:SetTint(1.0, 1.0, 1.0, 0.6)
local normalScale = Vector(1.0, 1.0)

function mod:preSpooksterUpdate(entity)
	local spr = entity:GetSprite()
	local target = game:GetNearestPlayer(entity.Position)

	if target == nil then return end

	spr.Offset = Vector(0, -65)
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

mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, mod.preSpooksterUpdate, 631)

function mod:postSpooksterRender(entity, offset)
	local screenpos = Isaac.WorldToScreen(entity.Position)
	local data = entity:GetData()

	if data.Mask == nil then
		data.Mask = Sprite()
		data.Mask:Load("gfx/spookster.anm2", true)
		data.Mask:SetAnimation(mod.rng:RandomInt(56), true)
		data.Mask:Play(data.Mask:GetAnimation(), true)
	end

	data.Mask.Color = transparent

	local n = data.Mask:GetAnimation()

	if data.Mask:IsFinished(n) then
		data.Mask:Play(n, true)
	end

	data.Mask:Render(screenpos + entity:GetSprite().Offset)

	if not game:IsPaused() and game.TimeCounter % 2 == 0 then
		data.Mask:Update()
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.postSpooksterRender, 631)

local spooksterlastroom = 84

function mod:keepSpookstersInPlace()
	local s = Isaac.FindByType(631, 0)
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
			v.Position = v.Position - move * 240
		end
	end

	spooksterlastroom = currentroom
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.keepSpookstersInPlace)

function mod:removeSpooksters()
	local s = Isaac.FindByType(631, 0)

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

			if t <= 0 then
				local rng = mod.rng

				local room = game:GetRoom()
				local w = room:GetGridWidth()
				local h = room:GetGridHeight()

				local spawnpos = Vector(rng:RandomInt(w), rng:RandomInt(h))

				if spawnpos.X > w / 2 then
					spawnpos.X = spawnpos.X + 96
				else
					spawnpos.X = spawnpos.X - 96
				end
				
				if spawnpos.Y > w / 2 then
					spawnpos.Y = spawnpos.Y + 96
				else
					spawnpos.Y = spawnpos.Y - 96
				end

				Isaac.Spawn(EntityType.ENTITY_FAMILIAR, 631, 0, spawnpos, Vector.Zero, nil)

				sfx:Play(SoundEffect.SOUND_LAZARUS_FLIP_DEAD, 0.5, 0, false, 0.75)
			end

			mod.Data.Run.SpooksterTimer = t
		end
	end)
end