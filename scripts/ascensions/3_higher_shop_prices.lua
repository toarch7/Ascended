AscensionDesc = "Higher shop prices"

local mod = Ascended

function AscensionInit()
	mod:AddAscensionCallback("PickupUpdate", function(p)
		if p.Price > 0 and p.AutoUpdatePrice then
			p.Price = math.floor(p.Price * 1.35)

			if p.Price == 9 then
				p.Price = 10
			elseif p.Price == 13 then
				p.Price = 15
			end

			if p.SubType == CollectibleType.COLLECTIBLE_BOOM then
				p.Price = 50
			end
		end
	end)
end