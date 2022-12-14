local mod = Ascended

local game = Game()
local level = game:GetLevel()

mod.UI = {
	textoffset = 0,
	texttime = 0,
	alpha = 1,

	leftstartroom = false
}

mod.UI.Icon = Sprite()
mod.UI.Icon:Load("gfx/ui/ascension_icon.anm2", true)
mod.UI.Icon:Play("Icon", true)

mod.font = Font()
mod.font:Load("font/luaminioutlined.fnt")

mod.font2 = Font()
mod.font2:Load("font/pftempestasevencondensed.fnt")

local function Lerp(val1, val2, percent)
	return val1 + (val2 - val1) * percent
end

function mod:OnRender()
	local textoffset = mod.UI.textoffset
	local texttime = mod.UI.texttime

	local showmode = mod:GetSaveData().displayAscensions

	if textoffset > 0 then
		local current = mod.Ascension
		local effects = Ascended.EffectDescriptions
		local f = mod.font

		local c = "Ascension " .. Ascended.AscensionGetName(current)

		if Ascended.Freeplay then
			c = "Ascensions"
		end
		
		f:DrawString(c, textoffset, 30, KColor(1, 1, 1, mod.UI.alpha), 0, true)
		
		for i, n in pairs(effects) do
			if not Ascended.Freeplay and i > current then
				break
			end
			
			f:DrawString(" - " .. effects[i], textoffset, 30 + i * 10, KColor(1, 1, 1, mod.UI.alpha), 0, true)
		end
	end
	
	if texttime >= 20 then
		textoffset = Lerp(textoffset, 50, 0.4)
	else
		textoffset = Lerp(textoffset, -100, 0.1)
	end

	local startroom = level:GetCurrentRoomIndex() == level:GetStartingRoomIndex()

	if startroom then
		mod.UI.alpha = Lerp(mod.UI.alpha, 1, 0.4)
	else
		mod.UI.alpha = Lerp(mod.UI.alpha, 0.2, 0.1)
	end
	
	if (showmode == 1 and Input.IsActionPressed(ButtonAction.ACTION_MAP, 0)) or ((showmode == 2 or not mod.UI.leftstartroom) and startroom) then
		if texttime < 30 then
			texttime = texttime + 1
		end
	elseif texttime > 0 then
		texttime = texttime - 1
		mod.UI.leftstartroom = true
	end

	mod.UI.textoffset = textoffset
	mod.UI.texttime = texttime

	local wets = mod.Data.Run.WetBombs

	if wets ~= nil and wets > 0 then
		local offsetraw = Options.HUDOffset * 10
		local offset = Vector(32, 45) + Vector(offsetraw * 2, offsetraw * 1.2)
		mod.font2:DrawString(tostring(wets), offset.X, offset.Y, KColor(0.7, 0.8, 1, 1), 10, true)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.OnRender)

function mod:DrawAscensionIcon()
	local f = mod.font
	
	if mod:GetSaveData().DisplayIcon ~= 2 and mod.Active then
		local offsetraw = Options.HUDOffset
		local offset = offsetraw * 24
		
		local p = Vector(5 + offset, 75 + offset - offsetraw * 11)

		if mod.AnyCharacterByName("Bethany") then
			p.Y = p.Y + 8
		end
		
		mod.UI.Icon:Render(p)
		
		if mod.Ascension == 1 or mod.Ascension > 9 then
			p.X = p.X - 0.5
		end

		local n = mod.Ascension

		if mod.Freeplay then
			n = "A"
			p.X = p.X + 0.5
			p.Y = p.Y - 0.5
		end

		
		f:DrawString(n, p.X + 0.5, p.Y - 2.5, KColor(1, 1, 0, 1), 10, true)
	end
end

mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.DrawAscensionIcon)