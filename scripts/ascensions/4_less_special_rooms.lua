AscensionDesc = "Emptier floors"

local mod = Ascended
local game = Game()
local level = game:GetLevel()

function mod:RemoveSpecialRooms()
    if game:IsGreedMode() then return end

    local sidx = level:GetStartingRoomIndex()

    for i = 0, 168 do
        local room = mod.GetRoomByIdx(i)

        if room then
            local type = room.Data.Type

            if type ~= RoomType.ROOM_DEFAULT and room.Data.Shape == RoomShape.ROOMSHAPE_1x1 and mod.rng:RandomFloat() <= 0.25 then
                if type == RoomType.ROOM_ARCADE or type == RoomType.ROOM_SACRIFICE or type == RoomType.ROOM_CURSE or
                    type == RoomType.ROOM_DICE or type == RoomType.ROOM_CHEST or type == RoomType.ROOM_CHALLENGE or
                    type == RoomType.ROOM_ISAACS or type == RoomType.ROOM_BARREN or type == RoomType.ROOM_LIBRARY
                then
                    if i - 1 ~= sidx and i - 13 ~= sidx and i + 1 ~= sidx and i + 13 ~= sidx then -- don't remove rooms next to start
                        Isaac.ExecuteCommand("goto s.default.2")
                        local newroom = mod.GetRoomByIdx(-3, 0)

                        if newroom == nil then return end

                        room.Data = newroom.Data

                        Isaac.ExecuteCommand("goto 6 6 0")
                    end
                end
            end
        end
	end
end

function AscensionInit()
    mod:AddAscensionCallback("NewLevel", function ()
        if level:GetStage() <= 8 then
            mod:RemoveSpecialRooms()
        end
    end)
end