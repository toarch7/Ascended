
local mod = AscendedModref

mod.menusavedata = nil

local DSSModName = "Ascended"
local DSSCoreVersion = 5
local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod.StoreSaveData()
end

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

local DSSInitializerFunction = include("scripts.dss.dssmenucore")

local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)

local ascendeddirectory = {
    main = {
        title = "ascended",

        buttons = {
            {str = "resume game", action = "resume"},
            {str = "settings", dest = "settings"},
            
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
                choices = {"while holding map button", "only in start room"},
                
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
                    return mod.GetSaveData().freeplay or 1
                end,

                store = function(var)
                    mod.GetSaveData().freeplay = var

                    if not mod.UI.leftstartroom then
                        mod.UpdateAscendedStatus()
                        Isaac.ExecuteCommand("restart")
                    end
                end
            }
        }
    }
}

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