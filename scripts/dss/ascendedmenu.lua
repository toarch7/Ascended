
local mod = AscendedModref

mod.menusavedata = nil

local json = require("json")

function mod.GetSaveData()
    if not mod.menusavedata then
        if Isaac.HasModData(mod) then
            mod.menusavedata = json.decode(Isaac.LoadModData(mod))
        else
            mod.menusavedata = {}
        end
    end

    return mod.menusavedata
end

function mod.StoreSaveData()
    Isaac.SaveModData(mod, json.encode(mod.menusavedata))
end

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
            
            {str = "", nosel = true},
            {str = "gameplay", fsize = 1, nosel = true},
            
            {
                str = "freeplay",
                choices = {"on", "off"},
                
                setting = 1,

                tooltip = { strset = { 'disable or', 'enable', 'ascension', 'progress.', 'enabling it', 'will set the', 'highest level', 'available' } },

                variable = "ascendedFreeplayOption",
                
                load = function()
                    return mod.GetSaveData().freeplay or 1
                end,

                store = function(var)
                    mod.GetSaveData().freeplay = var
                end
            },
            
            {
                str = "keeper and a11",
                choices = {"default", "disable on tainted"},
                
                setting = 1,

                variable = "ascendedBrokenHeartOption",
                
                load = function()
                    return mod.GetSaveData().keeperBrokenheart or 1
                end,

                store = function(var)
                    mod.GetSaveData().keeperBrokenheart = var
                end
            },
            
            {str = "", nosel = true},
            {str = "", nosel = true},
            {str = "", nosel = true},
            {str = "no more tweaks for ya :^)", fsize = 1, nosel = true}
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