-- Read in mod config and push to global
Assets = {
	Asset("SOUNDPACKAGE", "sound/music_mod.fev"),
    Asset("SOUND", "sound/music_mod.fsb"),
}
TITLE_MUSIC = {
    "music_mod/music/music_FE",
    "music_mod/music/music_FE_alt"
}
local musicIndex = math.random(1, #TITLE_MUSIC)
local updateFE = true  -- Ensure music only updates once per scene load; hacky solution for OnBecomeActive being called on init and only one more time after changing music. TODO erm

GLOBAL.DKC_MUSIC_REVISITED = {
    CONFIG = {
        MAIN = {
            continuousMode = (GetModConfigData("music_mode") == "continuous"),
            replaceTitleMusic = (GetModConfigData("title_music") == "yes"),
            miscEvents = false
        },
        TRACK = {
            useNewAutumnNight = (GetModConfigData("autumn_night_music") == "refresh"),
            useNewWinterDusk = (GetModConfigData("winter_dusk_music") == "refresh"),
            useNewSpringFight = (GetModConfigData("spring_fight_music") == "refresh"),
            useNightmareAlt = (GetModConfigData("nightmare_music") == "yes")
        }
    }
}

-- Front end themes
if GLOBAL.DKC_MUSIC_REVISITED.CONFIG.MAIN.replaceTitleMusic then
    GLOBAL.FE_MUSIC = TITLE_MUSIC[musicIndex]

    RemapSoundEvent( "dontstarve/together_FE/DST_theme_portaled",                     	"music_mod/music/DST_theme_portaled" )  -- Character select
    RemapSoundEvent( "dontstarve/HUD/Together_HUD/collectionscreen/music/jukebox",    	"music_mod/music/jukebox" )             -- Item collection
    RemapSoundEvent( "dontstarve/music/gramaphone_ragtime",                           	"music_mod/music/gramaphone_ragtime" )  -- Credits
end

-- Insanity Ambience (No track in sound bank, results in no insanity ambience)
RemapSoundEvent( "dontstarve/sanity/sanity", 										"music_mod/music/sanity" )

-- Woodie Wereforms (Handled by the engine? Don't appear in vanilla dynamicmusic)
RemapSoundEvent( "dontstarve/music/music_hoedown",                                  "music_mod/music/music_hoedown" )
RemapSoundEvent( "dontstarve/music/music_hoedown_goose",                            "music_mod/music/music_hoedown_goose" )
RemapSoundEvent( "dontstarve/music/music_hoedown_moose",                            "music_mod/music/music_hoedown_moose" )


-- Swap FE music on main menu scene load
AddClassPostConstruct("screens/redux/mainscreen", function(self)
    local _OnBecomeActive = self.OnBecomeActive

    function self:OnBecomeActive()
        _OnBecomeActive(self)
        print("OnBecomeActive called, music index is " .. musicIndex)

        if GLOBAL.DKC_MUSIC_REVISITED.CONFIG.MAIN.replaceTitleMusic and updateFE then
            musicIndex = (musicIndex % #TITLE_MUSIC) + 1
            GLOBAL.FE_MUSIC = TITLE_MUSIC[musicIndex]

            print("music index is now " .. musicIndex)
            print("changed GLOBAL.FE_MUSIC to " .. GLOBAL.FE_MUSIC)
        end
        updateFE = not updateFE
    end
end)

-- Pause menu music
AddClassPostConstruct("screens/redux/pausescreen", function(self)
    local _Oldunpause = self.Unpause
    if self.active then GLOBAL.TheFrontEnd:GetSound():PlaySound("music_mod/music/music_pause", "pausemenu") end

    function self:Unpause()
        GLOBAL.TheFrontEnd:GetSound():KillSound("pausemenu")
        _Oldunpause(self)
    end
end)