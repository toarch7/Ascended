
local mod = Ascended

mod.menusavedata = nil

local DSSModName = "Ascended"
local DSSCoreVersion = 5
local MenuProvider = {}

MenuProvider.SaveSaveData = mod.SaveAscensionData

function MenuProvider.GetPaletteSetting()
    return mod.GetSaveData().MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    mod.GetSaveData().MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    if not REPENTANCE then
        return mod.GetSaveData().HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
        mod.GetSaveData().HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    return mod.GetSaveData().GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
    mod.GetSaveData().GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return mod.GetSaveData().MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
    mod.GetSaveData().MenuKeybind = var
end

function MenuProvider.GetMenusNotified()
    return mod.GetSaveData().MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
    mod.GetSaveData().MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return mod.GetSaveData().MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    mod.GetSaveData().MenusPoppedUp = var
end

local DSSInitializerFunction = include("a_scripts.dss.dssmenucore")

local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local ascendeddirectory = {
    main = {
        title = "ascended",

        buttons = {
            {str = "resume game", action = "resume"},
            {str = "settings", dest = "settings"},
            {str = "ascensions", dest = "ascensiontoggles"},
            
            dssmod.changelogsButton,

            {str = "", nosel = true}
        },

    },

    settings = {
        title = "settings",

        buttons = {
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            
            {str = "", nosel = true},

            {
                str = "show ascensions",
                choices = {"when holding map button", "only in start room"},
                
                setting = 1,

                variable = "ascendedShowEffects",
                
                load = function()
                    return mod.GetSaveData().displayAscensions or 1
                end,

                store = function(var)
                    mod.GetSaveData().displayAscensions = var
                end
            },
            
            {
                str = "ascension icon",
                choices = {"on", "off"},
                
                setting = 1,

                variable = "ascendedShowIcon",
                
                load = function()
                    return mod.GetSaveData().displayIcon or 1
                end,

                store = function(var)
                    mod.GetSaveData().displayIcon = var
                end
            },
            
            {
                str = "freeplay",
                choices = {"on", "off"},
                
                setting = 2,

                tooltip = { strset = { 'disable or', 'enable', 'ascension', 'progress.', 'enabling it', 'will set the', 'highest level', 'available' } },

                variable = "ascendedFreeplayOption",
                
                load = function()
                    return mod.GetSaveData().freeplay or 2
                end,

                store = function(var)
                    local p = mod.GetSaveData().freeplay

                    mod.GetSaveData().freeplay = var
                    
                    if p ~= var and not mod.UI.leftstartroom then
                        Ascended.Freeplay = var
                        Isaac.ExecuteCommand("restart")
                    end
                end
            },

            ascensiontoggles = {}
        }
    }
}

local function MakeAscensionTogglers()
    local t = {
        title = "ascensions",

        buttons = {
            --[[{
                str = "disable all",
                fsize = 2,
                
                func = function(button, item, menuObj)
                    local t = menuObj.Directory.ascensiontoggles.buttons
                    
                    for _, v in pairs(t) do
                        if v.setting ~= nil then
                            mod.Data.Deactivated[v.ascensionid] = 2

                            v.setting = 2
                        end
                    end
                end
            },

            {
                str = "enable all",
                fsize = 2,
                
                func = function(button, item, menuObj)
                    local t = menuObj.Directory.ascensiontoggles.buttons
                    
                    for _, v in pairs(t) do
                        if v.setting ~= nil then
                            mod.Data.Deactivated[v.ascensionid] = 1

                            v.setting = 1
                        end
                    end
                end
            },

            {str = "", nosel = true},]]--
        }
    }

    ascendeddirectory.ascensiontoggles = t
    
    for n, v in pairs(mod.AscensionInitializers) do
        local name = Ascended.AscensionGetName(n) .. " - " .. v[2]
        
        local a =
        {
            str = name:lower(),
            choices = { "on", "off" },

            fsize = 1,

            variable = "AT_" .. v[3],
            
            setting = 1,

            tooltip = { strset = { "reset the run", "to apply", "changes" } },
            
            ascensionid = v[3],

            load = function()
                return mod.Data.Deactivated[v[3]] or 1
            end,

            store = function(var)
                mod.Data.Deactivated[v[3]] = var
            end
        }

        table.insert(t.buttons, a)
        table.insert(t.buttons, {str = "", nosel = true})
    end
end

MakeAscensionTogglers()

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    MakeAscensionTogglers()
end)

local ascendeddirectorykey = {
    Item = ascendeddirectory.main,
    Main = "main",
    
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

DeadSeaScrollsMenu.AddMenu("Ascended", {
    Run = dssmod.runMenu,
    Open = dssmod.openMenu,
    Close = dssmod.closeMenu,

    Directory = ascendeddirectory,
    DirectoryKey = ascendeddirectorykey
})