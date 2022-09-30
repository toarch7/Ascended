AscensionDesc = "Less room for consumables"

local mod = Ascended

local Properties = {
    CoinCap = 30,
    KeyCap = 10,
    BombCap = 10
}

AscensionInit = function()
    mod:AddAscensionCallback("PrePickupCollision", function(pick, colllider)
        local player = colllider:ToPlayer()

        if player then
            local value = 1

            if pick.Variant == 20 then
                if pick.SubType == 42 then
                    value = 0

                    if pick:GetData().Give then
                        value = 1
                    end
                elseif pick.SubType > 7 then
                    value = 1
                else value = pick:GetCoinValue() end

                local cap = Properties.CoinCap

                if player:GetName() == "Keeper" or player:HasCollectible(CollectibleType.COLLECTIBLE_STAIRWAY) or 
                    player:HasCollectible(CollectibleType.COLLECTIBLE_POUND_OF_FLESH) or player:HasTrinket(TrinketType.TRINKET_KEEPERS_BARGAIN) then
                    cap = cap + 10
                end

                if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
                    cap = 100
                end

                if player:GetNumCoins() + math.max(1, value) > cap then
                    if pick.SubType == 5 then
                        Isaac.Spawn(pick.Type, pick.Variant, 1, player.Position, player.Velocity, pick.Spawner)
                        player:AddCoins(-1)

                        if player:GetName() == "Keeper" and player:GetHearts() < player:GetMaxHearts() then
                            player:AddHearts(1)
                        end

                        return nil
                    elseif (value > 1 and player:GetNumCoins() < cap) or (player:GetName() == "Keeper" and player:GetHearts() < player:GetMaxHearts()) then
                        local excess = (player:GetNumCoins() + value) - cap

                        if player:GetName() == "Keeper" and player:GetHearts() < player:GetMaxHearts() then
                            excess = excess - (player:GetMaxHearts() - player:GetHearts())
                        end

                        if excess > 0 then
                            for _ = 1, excess, 1 do
                                Isaac.Spawn(pick.Type, pick.Variant, 1, pick.Position, RandomVector() * 2, pick.Spawner)
                            end

                            player:AddCoins(-excess)
                        end

                        return nil
                    end
                    
                    return true
                end
            elseif pick.Variant == 30 then
                value = 1

                if pick.SubType == 3 or pick.SubType == 179 then -- double & ff spicy double
                    value = 2
                elseif pick.SubType == 180 then -- ff super spicy key
                    value = 3
                end

                -- print(value, pick.SubType)
                -- apparently fiendfolio keys don't trigger this callback?
                -- leaving compat for the sake of anything

                if player:GetNumKeys() + value > Properties.KeyCap then
                    if pick.SubType == 2 then return nil end

                    if pick.SubType == 4 then
                        Isaac.Spawn(pick.Type, pick.Variant, 1, player.Position, player.Velocity, pick.Spawner)
                        player:AddKeys(-1)
                        return nil
                    end
                    
                    return false
                end
            elseif pick.Variant == 40 then
                local count = player:GetNumBombs() + (mod.Data.run.WetBombs or 0)
                
                value = 1

                if pick.SubType == 2 then
                    value = 2
                end

                if count + value > Properties.BombCap then
                    if pick.SubType == 4 then return nil end
                    
                    return false
                end
            end
        end
    end, true)
end