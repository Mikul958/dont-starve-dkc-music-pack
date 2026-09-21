-- Set music mode and assign main menu music to custom FE track
Assets = {
	Asset("SOUNDPACKAGE", "sound/music_mod.fev"),
    Asset("SOUND", "sound/music_mod.fsb"),
}
GLOBAL.FE_MUSIC = "music_mod/music/music_FE"
GLOBAL.continuous_mode = (GetModConfigData("music_mode") ~= "busy")

---------------------------------------------------------------------

-- Remap music to custom tracks

-- Busy
RemapSoundEvent( "dontstarve/music/music_work",                                     "music_mod/music/music_work" )
RemapSoundEvent( "dontstarve/music/music_work_winter",                              "music_mod/music/music_work_winter" )
RemapSoundEvent( "dontstarve_DLC001/music/music_work_spring",                       "music_mod/music/music_work_spring" )
RemapSoundEvent( "dontstarve_DLC001/music/music_work_summer",                       "music_mod/music/music_work_summer" )
RemapSoundEvent( "dontstarve/music/music_work_cave",                                "music_mod/music/music_work_cave" )
RemapSoundEvent( "dontstarve/music/music_work_ruins",                               "music_mod/music/music_work_ruins" )
RemapSoundEvent( "turnoftides/music/sailing",                                     	"music_mod/music/sailing" )
RemapSoundEvent( "turnoftides/music/working",                                       "music_mod/music/working" )  -- Lunar Work
RemapSoundEvent( "hookline_2/characters/hermit/music_island",                       "music_mod/music/music_island" ) -- Hermit Work

-- Danger
RemapSoundEvent( "dontstarve/music/music_danger",                                   "music_mod/music/music_danger" )
RemapSoundEvent( "dontstarve/music/music_danger_winter",                            "music_mod/music/music_danger_winter" )
RemapSoundEvent( "dontstarve_DLC001/music/music_danger_spring",                     "music_mod/music/music_danger_spring" )
RemapSoundEvent( "dontstarve_DLC001/music/music_danger_summer",                     "music_mod/music/music_danger_summer" )
RemapSoundEvent( "dontstarve/music/music_danger_cave",                              "music_mod/music/music_danger_cave" )
RemapSoundEvent( "dontstarve/music/music_danger_ruins",                             "music_mod/music/music_danger_ruins" )

-- Epic Fight
RemapSoundEvent( "dontstarve/music/music_epicfight",                                "music_mod/music/music_epicfight" )
RemapSoundEvent( "dontstarve/music/music_epicfight_winter",                         "music_mod/music/music_epicfight_winter" )
RemapSoundEvent( "dontstarve_DLC001/music/music_epicfight_spring",                  "music_mod/music/music_epicfight_spring" )
RemapSoundEvent( "dontstarve_DLC001/music/music_epicfight_summer",                  "music_mod/music/music_epicfight_summer" )
RemapSoundEvent( "dontstarve/music/music_epicfight_cave",                           "music_mod/music/music_epicfight_cave" )
RemapSoundEvent( "dontstarve/music/music_epicfight_ruins",                          "music_mod/music/music_epicfight_ruins" ) -- Default fallback Epic Fight Music

-- Specific Boss Music
RemapSoundEvent( "dontstarve/music/music_epicfight_3",                              "music_mod/music/music_epicfight_3" ) -- Dragonfly
RemapSoundEvent( "dontstarve/music/music_epicfight_4",                              "music_mod/music/music_epicfight_4" ) -- Bee Queen
RemapSoundEvent( "dontstarve/music/music_epicfight_antlion",                        "music_mod/music/music_epicfight_antlion" )
RemapSoundEvent( "dontstarve/music/music_epicfight_toadboss",                       "music_mod/music/music_epicfight_toadboss" )
RemapSoundEvent( "saltydog/music/malbatross",                                       "music_mod/music/malbatross" )
RemapSoundEvent( "dontstarve/music/music_epicfight_crabking",                       "music_mod/music/music_epicfight_crabking" )
RemapSoundEvent( "dontstarve/music/music_epicfight_5a",                             "music_mod/music/music_epicfight_5a" ) -- Klaus Phase 1
RemapSoundEvent( "dontstarve/music/music_epicfight_5b",                             "music_mod/music/music_epicfight_5b" ) -- Klaus Phase 2
RemapSoundEvent( "dontstarve/music/music_epicfight_moonbase",                       "music_mod/music/music_epicfight_moonbase" ) -- Moon Stone Raid Phase 1
RemapSoundEvent( "dontstarve/music/music_epicfight_moonbase_b",                     "music_mod/music/music_epicfight_moonbase_b" ) -- Moon Stone Raid Phase 2
RemapSoundEvent( "dontstarve/music/music_epicfight_stalker",                        "music_mod/music/music_epicfight_stalker" ) -- Ancient FuelWeaver Phase 1
RemapSoundEvent( "dontstarve/music/music_epicfight_stalker_b",                      "music_mod/music/music_epicfight_stalker_b" ) -- Ancient FuelWeaver Phase 2
RemapSoundEvent( "moonstorm/creatures/boss/alterguardian1/music_epicfight",         "music_mod/music/music_epicfight_alterguardian1" ) -- Celestial Champion Phase 1
RemapSoundEvent( "moonstorm/creatures/boss/alterguardian2/music_epicfight",         "music_mod/music/music_epicfight_alterguardian2" ) -- Celestial Champion Phase 2
RemapSoundEvent( "moonstorm/creatures/boss/alterguardian3/music_epicfight",         "music_mod/music/music_epicfight_alterguardian3" ) -- Celestial Champion Phase 3

-- Woodie Wereforms
RemapSoundEvent( "dontstarve/music/music_hoedown",                                  "music_mod/music/music_hoedown" )
RemapSoundEvent( "dontstarve/music/music_hoedown_goose",                            "music_mod/music/music_hoedown_goose" )
RemapSoundEvent( "dontstarve/music/music_hoedown_moose",                            "music_mod/music/music_hoedown_moose" )

-- Stingers and Insanity Ambience
RemapSoundEvent( "dontstarve/music/music_dawn_stinger",								"music_mod/music/music_dawn_stinger")
RemapSoundEvent( "dontstarve/music/music_dusk_stinger",								"music_mod/music/music_dusk_stinger")
RemapSoundEvent( "dontstarve/sanity/gonecrazy_stinger", 							"music_mod/music/gonecrazy_stinger" )
RemapSoundEvent( "dontstarve/sanity/sanity", 										"music_mod/music/sanity" )

-- Miscellaneous
RemapSoundEvent( "dontstarve/together_FE/DST_theme_portaled",                     	"music_mod/music/DST_theme_portaled" ) -- Character select
RemapSoundEvent( "dontstarve/HUD/Together_HUD/collectionscreen/music/jukebox",    	"music_mod/music/jukebox" ) -- Character customization
RemapSoundEvent( "dontstarve/music/gramaphone_ragtime",                           	"music_mod/music/gramaphone_ragtime" ) -- Credits
RemapSoundEvent( "music_mod/music/music_pigking_minigame",							"music_mod/music/music_pigking_minigame" )
RemapSoundEvent( "moonstorm/characters/wagstaff/music_wagstaff_experiment",         "music_mod/music/music_wagstaff_experiment" ) -- Wagstaff Experiment


AddClassPostConstruct("screens/redux/pausescreen", function(self)
    local _Oldunpause = self.unpause
    if self.active then GLOBAL.TheFrontEnd:GetSound():PlaySound("music_mod/music/music_pause", "pausemenu") end

    function self:unpause()
        GLOBAL.TheFrontEnd:GetSound():KillSound("pausemenu")
        _Oldunpause(self)
    end
end)