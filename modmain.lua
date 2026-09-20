GLOBAL.continuous_mode = (GetModConfigData("music_mode")~="busy")

Assets = {
	Asset("SOUNDPACKAGE", "sound/music_mod.fev"),
    Asset("SOUND", "sound/music_mod.fsb"),
}
GLOBAL.FE_MUSIC = "music_mod/music/music_FE"

----------------------------------------------------
RemapSoundEvent( "dontstarve/music/music_danger",                                   "music_mod/music/music_danger" ) -- Fighting in Autumn
RemapSoundEvent( "dontstarve/music/music_danger_winter",                            "music_mod/music/music_danger_winter" ) -- Fighting in Winter
RemapSoundEvent( "dontstarve_DLC001/music/music_danger_spring",                     "music_mod/music/music_danger_spring" ) -- Fighting in Spring
RemapSoundEvent( "dontstarve_DLC001/music/music_danger_summer",                     "music_mod/music/music_danger_summer" ) -- Fighting in Summer
RemapSoundEvent( "dontstarve/music/music_danger_cave",                              "music_mod/music/music_danger_cave" ) -- Fighting in Caves
RemapSoundEvent( "dontstarve/music/music_danger_ruins",                             "music_mod/music/music_danger_ruins" ) -- Fighting in Ruins

RemapSoundEvent( "dontstarve/music/music_epicfight",                                "music_mod/music/music_epicfight" ) -- Bearger or "Boss" mob in autumn(*)
RemapSoundEvent( "dontstarve/music/music_epicfight_winter",                         "music_mod/music/music_epicfight_winter" ) -- Deerclops or "Boss" mob in winter(*)
RemapSoundEvent( "dontstarve_DLC001/music/music_epicfight_spring",                  "music_mod/music/music_epicfight_spring" ) -- Moose/Goose or "Boss" mob in spring(*)
RemapSoundEvent( "dontstarve_DLC001/music/music_epicfight_summer",                  "music_mod/music/music_epicfight_summer" ) -- "Boss" mob in summer(*)
RemapSoundEvent( "dontstarve/music/music_epicfight_cave",                           "music_mod/music/music_epicfight_cave" ) -- "Boss" mob in The Caves(*)
RemapSoundEvent( "dontstarve/music/music_epicfight_ruins",                          "music_mod/music/music_epicfight_ruins" ) -- Ancient Guardian or Shadow Pieces, default fallback Epic Fight Music

RemapSoundEvent( "dontstarve/music/music_epicfight_3",                              "music_mod/music/music_epicfight_3" ) -- Dragonfly
RemapSoundEvent( "dontstarve/music/music_epicfight_4",                              "music_mod/music/music_epicfight_4" ) -- Bee Queen
RemapSoundEvent( "dontstarve/music/music_epicfight_antlion",                        "music_mod/music/music_epicfight_antlion" ) -- Antlion
RemapSoundEvent( "dontstarve/music/music_epicfight_toadboss",                       "music_mod/music/music_epicfight_toadboss" ) -- Toadstool
RemapSoundEvent( "saltydog/music/malbatross",                                       "music_mod/music/malbatross" ) -- Malbatross (RoT:SD)
RemapSoundEvent( "dontstarve/music/music_epicfight_crabking",                       "music_mod/music/music_epicfight_crabking" ) -- Crab King (RoT:SSSS)
RemapSoundEvent( "dontstarve/music/music_epicfight_5a",                             "music_mod/music/music_epicfight_5a" ) -- Klaus P1
RemapSoundEvent( "dontstarve/music/music_epicfight_5b",                             "music_mod/music/music_epicfight_5b" ) -- Klaus P2
RemapSoundEvent( "dontstarve/music/music_epicfight_moonbase",                       "music_mod/music/music_epicfight_moonbase" ) -- MoonStone Raid P1
RemapSoundEvent( "dontstarve/music/music_epicfight_moonbase_b",                     "music_mod/music/music_epicfight_moonbase_b" ) -- MoonStone Raid P2
RemapSoundEvent( "dontstarve/music/music_epicfight_stalker",                        "music_mod/music/music_epicfight_stalker" ) -- A.FuelWeaver P1
RemapSoundEvent( "dontstarve/music/music_epicfight_stalker_b",                      "music_mod/music/music_epicfight_stalker_b" ) -- A.FuelWeaver P2
RemapSoundEvent( "moonstorm/creatures/boss/alterguardian1/music_epicfight",         "music_mod/music/music_epicfight_alterguardian1" ) -- Celestial Champion P1
RemapSoundEvent( "moonstorm/creatures/boss/alterguardian2/music_epicfight",         "music_mod/music/music_epicfight_alterguardian2" ) -- Celestial Champion P2
RemapSoundEvent( "moonstorm/creatures/boss/alterguardian3/music_epicfight",         "music_mod/music/music_epicfight_alterguardian3" ) -- Celestial Champion P3
RemapSoundEvent( "music_mod/music/music_pigking_minigame",							"music_mod/music/music_pigking_minigame" ) -- Pigking Minigame

RemapSoundEvent( "dontstarve/music/music_hoedown",                                  "music_mod/music/music_hoedown" ) -- Woodie Beaver Form
RemapSoundEvent( "dontstarve/music/music_hoedown_goose",                            "music_mod/music/music_hoedown_goose" ) -- Woodie Goose Form
RemapSoundEvent( "dontstarve/music/music_hoedown_moose",                            "music_mod/music/music_hoedown_moose" ) -- Woodie Moose Form

RemapSoundEvent( "dontstarve/music/music_work_cave",                                "music_mod/music/music_work_cave" ) -- Caves Work
RemapSoundEvent( "dontstarve/music/music_work_ruins",                               "music_mod/music/music_work_ruins" ) -- Ruins Work
RemapSoundEvent( "turnoftides/music/working",                                       "music_mod/music/working" ) -- Lunar Work 

RemapSoundEvent( "dontstarve/music/music_work",                                     "music_mod/music/music_work" ) -- Autumn Day Work
RemapSoundEvent( "dontstarve/music/music_work_winter",                              "music_mod/music/music_work_winter" ) -- Winter Day Work
RemapSoundEvent( "dontstarve_DLC001/music/music_work_spring",                       "music_mod/music/music_work_spring" ) -- Spring Day Work
RemapSoundEvent( "dontstarve_DLC001/music/music_work_summer",                       "music_mod/music/music_work_summer" ) -- Summer Day Work
RemapSoundEvent( "dontstarve/music/music_dawn_stinger",								"music_mod/music/music_dawn_stinger") -- Dawn Stinger
RemapSoundEvent( "dontstarve/music/music_dusk_stinger",								"music_mod/music/music_dusk_stinger") -- Dusk Stinger

RemapSoundEvent( "hookline_2/characters/hermit/music_island",                       "music_mod/music/music_island" ) -- Hermit Work
RemapSoundEvent( "moonstorm/characters/wagstaff/music_wagstaff_experiment",         "music_mod/music/music_wagstaff_experiment" ) -- Wagstaff Experiment


RemapSoundEvent( "dontstarve/music/gramaphone_ragtime",                           	"music_mod/music/gramaphone_ragtime" ) -- Credits
RemapSoundEvent( "dontstarve/sanity/gonecrazy_stinger", 							"music_mod/music/gonecrazy_stinger" ) -- Insanity stinger
RemapSoundEvent( "dontstarve/sanity/sanity", 										"music_mod/music/sanity" ) -- Insanity ambience
RemapSoundEvent( "dontstarve/together_FE/DST_theme_portaled",                     	"music_mod/music/DST_theme_portaled" ) -- Character select
RemapSoundEvent( "dontstarve/HUD/Together_HUD/collectionscreen/music/jukebox",    	"music_mod/music/jukebox" ) -- Character customization
RemapSoundEvent( "turnoftides/music/sailing",                                     	"music_mod/music/sailing" ) -- Sailing

AddClassPostConstruct("screens/redux/pausescreen", function(self)
    local _Oldunpause = self.unpause
    if self.active then GLOBAL.TheFrontEnd:GetSound():PlaySound("music_mod/music/music_pause", "pausemenu") end

    function self:unpause()
        GLOBAL.TheFrontEnd:GetSound():KillSound("pausemenu")
        _Oldunpause(self)
    end
end)