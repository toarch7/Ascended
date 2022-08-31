local mod = AscendedModref

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

local function Lerp(val1, val2, percent)
	return val1 + (val2 - val1) * percent
end

function mod.onRender()
	local textoffset = mod.UI.textoffset
	local texttime = mod.UI.texttime

	local showmode = mod:GetSaveData().displayAscensions

	if textoffset > 0 then
		local current = Ascended.Current
		local effects = Ascended.EffectDescriptions
		local f = mod.font
		
		f:DrawString("Ascension " .. Ascended.AscensionGetName(current), textoffset, 30, KColor(1, 1, 1, mod.UI.alpha), 0, true)
		
		for i, n in pairs(effects) do
			if i > current then
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
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)

function mod:drawAscensionIcon()
	if mod:GetSaveData().displayIcon ~= 2 then
		local offsetraw = Options.HUDOffset
		local offset = offsetraw * 24
		
		local f = mod.font
		
		local p = Vector(5 + offset, 75 + offset - offsetraw * 11)
		
		mod.UI.Icon:Render(p)
		
		if Ascended.Current == 1 or Ascended.Current > 9 then
			p.X = p.X - 0.5
		end
		
		f:DrawString(Ascended.Current, p.X + 0.5, p.Y - 2.5, KColor(1, 1, 0, 1), 10, true)
	end
end

mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, mod.drawAscensionIcon)