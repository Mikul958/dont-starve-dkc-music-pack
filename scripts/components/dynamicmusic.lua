--------------------------------------------------------------------------
--[[ DynamicMusic class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants and config ]]
--------------------------------------------------------------------------

local CONTINUOUS_MODE = DKC_MUSIC_REVISITED.CONFIG.MAIN.continuousMode
local MISC_EVENTS = DKC_MUSIC_REVISITED.CONFIG.MAIN.miscEvents  -- Currently always false, this is just preferable to commenting/removing event listeners
local TRACK_CONFIG = DKC_MUSIC_REVISITED.CONFIG.TRACK

local SEASON_BUSY_MUSIC = {
    autumn = {
        day = "music_mod/music/music_work",
        dusk = "music_mod/music/music_work_dusk",
        night = (TRACK_CONFIG.useNewAutumnNight and "music_mod/music/music_work_night_alt" or "music_mod/music/music_work_night")
    },
    winter = {
        day = "music_mod/music/music_work_winter",
        dusk = (TRACK_CONFIG.useNewWinterDusk and "music_mod/music/music_work_winter_dusk_alt" or "music_mod/music/music_work_winter_dusk"),
        night = "music_mod/music/music_work_winter_night"
    },
    spring = {
        day = "music_mod/music/music_work_spring",
        dusk = "music_mod/music/music_work_spring_dusk",
        night = "music_mod/music/music_work_spring_night"
    },
    summer = {
        day = "music_mod/music/music_work_summer",
        dusk = "music_mod/music/music_work_summer_dusk",
        night = "music_mod/music/music_work_summer_night"
    }
}

local SEASON_DANGER_MUSIC ={
    autumn = "music_mod/music/music_danger",
    winter = "music_mod/music/music_danger_winter",
    spring = (TRACK_CONFIG.useNewSpringFight and "music_mod/music/music_danger_spring_alt" or "music_mod/music/music_danger_spring"),
    summer = "music_mod/music/music_danger_summer",
}

local SEASON_EPICFIGHT_MUSIC ={
    autumn = "music_mod/music/music_epicfight",
    winter = "music_mod/music/music_epicfight_winter",
    spring = "music_mod/music/music_epicfight_spring",
    summer = "music_mod/music/music_epicfight_summer",
}

local BUSY_THEMES = {
    FOREST = 1,
    CAVE = 2,
    RUINS = 3,
    OCEAN = 4,
    LUNAR = 5,
    FEAST = 6,
    RACE = 7,
    TRAINING = 8,
    HERMIT = 9,
    FARMING = 10,
	CARNIVAL_AMBIENT = 11,
	CARNIVAL_MINIGAME = 12,
    NIGHTMARE = 13
}

local NIGHTMARE_PHASES = {
    CALM = "calm",
    WARNING = "warn",
    NIGHTMARE = "wild",
    DAWN = "dawn"
}

-- Collection of event music. Keys are event tags as they are reported from the game, while indices inside tables correspond to reported event level.
-- musicPhase is used to track which music is played; keep the same as the last entry to continue playing the same music as previous phase.
-- musicPhase of -1 (default if entry missing) will result in generic boss music. musicPhase of 0 will skip music start entirely.
local TRIGGERED_EVENT_MUSIC = {
    dragonfly = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_3",
        }
    },
    beequeen = {
        {
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_4"
        }
    },
    toadstool = {
        {
            musicPhase = -1,
            path =  "music_mod/music/music_epicfight_toadboss",
        }
    },
    antlion = {
        {
            musicPhase = -1,
            "music_mod/music/music_epicfight_antlion",
        }
    },
    klaus = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_5a"
        },
        {
            musicPhase = 2,
            path = ""  -- silence  TODO not handled in current script, need to re-add length check. Check how vanilla script does it, also maybe move second track here for song alignment?
        },
        {
            musicPhase = 3,
            path = "music_mod/music/music_epicfight_5b",  -- TODO implement Northern Hemispheres climax in FMOD if possible, otherwise remove
        }
    },
    shadowchess = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_ruins",  -- Shadow Pieces
        }
    },
    stalker = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_stalker"  -- Ancient fuelweaver
        },
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_stalker_b"
        },
        {
            musicPhase = 2,
            path = ""  -- Silence
        }
    },
    crabking = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_crabking"
        }
    },
    malbatross = {
        {
            musicPhase = 1,
            path = "music_mod/music/malbatross"
        }
    },
    eyeofterror = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_eot"
        }
    },

    -- Celestial champion; phases are reported as 3 separate entities instead of using level for some reason
    alterguardian_phase1 = {
        {
            musicPhase = 1,
            "music_mod/music/music_epicfight_alterguardian1"
        }
    },
    alterguardian_phase2 = {
        {
            musicPhase = 1,
            "music_mod/music/music_epicfight_alterguardian2"
        }
    },
    alterguardian_phase3 = {
        {
            musicPhase = 1,
            "music_mod/music/music_epicfight_alterguardian3"
        }
    },

    daywalker = {
        {
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_daywalker"  -- Nightmare Werepig
        }
    },
    daywalker2 = {
		{
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_junkyardhog"  -- Scrappy Werepig
        },
	},
    gestaltmutant = {
		{
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_gestalt_mutants"  -- Mutated Deerclops/Bearger/Varg
        },
	},
	sharkboi = {
		{
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_sharkboy"  -- Frostjaw
        },
	},
    worm_boss = {
        {
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_worm",  -- Great Depths Worm
        }
    },
	wagboss = {
        {
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_wagboss_1",  -- W.A.R.B.O.T.
        },
        {
            musicPhase = -1,
            path = ""  -- silence
        },
        {
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_wagboss_2"
        }
	},

    -- Non-boss events
    moonbase = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_moonbase"
        },
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_moonbase_b"
        }
    },
	vault = {
        {
            musicPhase = 0,
            path = "music_mod/music/music_cavepuzzle"
        },
        {
            musicPhase = 1,
            path = ""  -- silence
        },
        {
            musicPhase = 2,
            path = "music_mod/music/music_epicfight_pillarguard"
        }
	},
    knight_yoth = {
        {
            musicPhase = -1,
            path = "music_mod/music/music_epicfight_yothknights"
        },
    },
    piratemonkeyraid = {
        {
            musicPhase = -1,
            path = "music_mod/musicmusic/warning_combo"
        },
    },
    pigking = {
        {
            musicPhase = 0,
            path = "music_mod/music/music_pigking_minigame"
        }
    },
    wagstaff_experiment = {
        {
            musicPhase = 0,
            path = "music_mod/music/music_wagstaff_experiment"
        }
    },
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _isEnabled = true
local _soundEmitter = nil     -- SoundEmitter component, used to update music track/intensity
local _activatedPlayer = nil  -- Player that activated this component, used for caching only, no logic

local _busyTask = nil
local _busyTheme = nil
local _isBusyDirty = false  -- Tracks whether the currently-selected busy music is outdated (important when we shouldn't play the new track immediately)
local _stopTime = 0         -- Tracks the time when triggered music should be stopped (not itself a timer)
local _dangerTask = nil
local _triggeredLevel = 0       -- Tracks the level of current triggered event encounter
local _triggeredMusicPhase = 0  -- Used to determine whether we should switch music on a new event level (e.g. boss phase change)
local _inCaves = false          -- When in the cave layer
local _inRuins = false          -- When in ruins
local _nightmarePhase = nil     -- Current nightmare cycle phase
local _inLunar = false          -- When on lunar island or in lunar grotto
local _isSailing = false        -- Used to determine whether we are still sailing for sailing music deactivation
local _sailingTask = nil
local _delayActive = false         -- Tracks if a forced delay (e.g. from a stinger) is active
local _hasInspirationBuff = false  -- Wigfrid inspiration buff

--------------------------------------------------------------------------
--[[ Reusable music constrols and helper functions ]]
--------------------------------------------------------------------------

local function StopContinuous()
	if _busyTask ~= nil then
        _busyTask:Cancel()
	end
	_busyTask = nil
	_stopTime = 0
	_soundEmitter:SetParameter("busy", "intensity", 0)  -- Mute music, do not restart; sound in FMOD should cover intensity 0 for this to work correctly
end

local function StopBusy(inst, isTimeout)
    if CONTINUOUS_MODE or _busyTask == nil then
        return
    end

    if not isTimeout then
        _busyTask:Cancel()
    elseif _stopTime > 0 then
        local time = GetTime()
        if time < _stopTime then
            _busyTask = inst:DoTaskInTime(_stopTime - time, StopBusy, true)
            _stopTime = 0
            return
        end
    end
    _busyTask = nil
    _stopTime = 0
    _soundEmitter:SetParameter("busy", "intensity", 0)
end

-- TODO maybe if I'm not lazy restructure some constants and pass in music as param instead?
local function StartBusy(player)
    if _busyTask ~= nil and not _isBusyDirty then
        _stopTime = GetTime() + 15
    elseif _dangerTask == nil and not _delayActive and (CONTINUOUS_MODE or _stopTime == 0 or GetTime() >= _stopTime) and _isEnabled then

        -- Check if player is sailing and assign sailing music
        if _isSailing then
            if _busyTheme ~= BUSY_THEMES.OCEAN then
                _soundEmitter:KillSound("busy")
                _soundEmitter:PlaySound("music_mod/music/sailing", "busy")
            end
            _busyTheme = BUSY_THEMES.OCEAN

        -- Else check if player is in a lunar biome and assign lunar music
        elseif _inLunar then
            if _busyTheme ~= BUSY_THEMES.LUNAR then
                _soundEmitter:KillSound("busy")
                _soundEmitter:PlaySound("music_mod/music/working", "busy")
            end
            _busyTheme = BUSY_THEMES.LUNAR
        
        -- Else check if player is in cave layer and assign ruins or cave music
        elseif _inCaves then
            if _inRuins then
                if _nightmarePhase ~= NIGHTMARE_PHASES.NIGHTMARE and _busyTheme ~= BUSY_THEMES.RUINS then
                    _soundEmitter:KillSound("busy")
                    _soundEmitter:PlaySound("music_mod/music/music_work_ruins", "busy")
                    _busyTheme = BUSY_THEMES.RUINS
                elseif _nightmarePhase == NIGHTMARE_PHASES.NIGHTMARE and _busyTheme ~= BUSY_THEMES.NIGHTMARE then
                    _soundEmitter:KillSound("busy")
                    _soundEmitter:PlaySound("music_mod/music/music_work_ruins_alt", "busy")
                    _busyTheme = BUSY_THEMES.NIGHTMARE
                end
            else
                if _busyTheme ~= BUSY_THEMES.CAVE then
                    _soundEmitter:KillSound("busy")
                    _soundEmitter:PlaySound("music_mod/music/music_work_cave", "busy")
                end
                _busyTheme = BUSY_THEMES.CAVE
            end
        
        -- Else assign appropriate forest music
        else
            if _busyTheme ~= BUSY_THEMES.FOREST or _isBusyDirty then
                _isBusyDirty = false
                _soundEmitter:KillSound("busy")
                
                -- Default to autumn day if music does not exist for this season/phase
                local season = inst.state.season
                local phase = inst.state.phase
                if SEASON_BUSY_MUSIC[season] == nil then
                    season = "autumn"
                end
                if SEASON_BUSY_MUSIC[season][phase] == nil then
                    phase = "day"
                end
                _soundEmitter:PlaySound(SEASON_BUSY_MUSIC[season][phase], "busy")
            end
            _busyTheme = BUSY_THEMES.FOREST
        end

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(15, StopBusy, true)
        _stopTime = 0
    end
end

local function StopOcean(player)
    _isSailing = false
    _isBusyDirty = true  -- TODO necessary?
    StopBusy(player)
    if CONTINUOUS_MODE then
        StopContinuous()
        StartBusy(player)
    end
end

local function StartOcean(player)
    _isSailing = true
    _isBusyDirty = true
    if _dangerTask == nil and (_stopTime == 0 or GetTime() >= _stopTime) and _isEnabled then  -- TODO all these conditions may not be necessary anymore
        StartBusy(player)
    end
end

local function CheckOceanStop(inst, player)
    if player.components.walkableplatformplayer == nil then
        if _sailingTask ~= nil then
            _sailingTask:Cancel()
            _sailingTask = nil
        end
        return
    end

    local boatspeed = player.components.walkableplatformplayer.boatspeed
    if boatspeed == nil or boatspeed < 0.2 then
        if _sailingTask ~= nil then
            _sailingTask:Cancel()
            _sailingTask = nil
        end
        _sailingTask = inst:DoTaskInTime(8, StopOcean, true)
    end
end

local function StartBusyTheme(player, theme, sound, duration, extendtime)
    if _dangerTask == nil and (_busyTheme ~= theme or _stopTime == 0 or GetTime() >= _stopTime) and _isEnabled then
        if _busyTask then
            _busyTask:Cancel()
            _busyTask = nil
        end
        if _busyTheme ~= theme then
            _soundEmitter:KillSound("busy")
            _soundEmitter:PlaySound(sound, "busy")
	        _busyTheme = theme
        end

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(duration, StopBusy, true)
        _stopTime = extendtime or 0
    end
end

local function StartFeasting(player)
    if _busyTask ~= nil then
        _stopTime = 0
        _busyTask:Cancel()
        _busyTask = nil
        _busyTask = inst:DoTaskInTime(5, StopBusy, true)
    elseif _dangerTask == nil and (_stopTime == 0 or GetTime() >= _stopTime) and _isEnabled then

        if _busyTheme ~= BUSY_THEMES.FEAST then
            _soundEmitter:KillSound("busy")
            _soundEmitter:PlaySound("wintersfeast2019/music/feast", "busy")
        end
        _busyTheme = BUSY_THEMES.FEAST

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(5, StopBusy, true)
        _stopTime = 0
    end
end

local function ExtendBusy()
    if _busyTask ~= nil then
        _stopTime = math.max(_stopTime, GetTime() + 10)
    end
end

local function StopDanger(inst, istimeout)
    if _dangerTask == nil then
        return
    end
    
    if not istimeout then
        _dangerTask:Cancel()
    elseif _stopTime > 0 then
        local time = GetTime()
        if time < _stopTime then
            _dangerTask = inst:DoTaskInTime(_stopTime - time, StopDanger, true)
            _stopTime = 0
            return
        end
    end
    _dangerTask = nil
    _triggeredLevel = 0
    _triggeredMusicPhase = 0
    _stopTime = 0
    _soundEmitter:KillSound("danger")
    if CONTINUOUS_MODE then
        StartBusy(inst)
    end
end

local EPIC_TAGS = { "epic" }
local NO_EPIC_TAGS = { "noepicmusic" }
local function StartDanger(player)
    if _dangerTask ~= nil then
        _stopTime = GetTime() + 10
    elseif _isEnabled then
        StopContinuous()
        local x, y, z = player.Transform:GetWorldPosition()
        local epicfightEncounters = #TheSim:FindEntities(x, y, z, 30, EPIC_TAGS, NO_EPIC_TAGS)  -- Last 2 params = must have tags, can't have tags
        if epicfightEncounters > 0 then
            _soundEmitter:PlaySound(
                _inRuins and "music_mod/music/music_epicfight_ruins" or
                _inCaves and "music_mod/music/music_epicfight_cave" or
                SEASON_EPICFIGHT_MUSIC[inst.state.season],
                "danger")
        else
            _soundEmitter:PlaySound(
                _inRuins and "music_mod/music/music_danger_ruins" or
                _inCaves and "music_mod/music/music_danger_cave" or
                SEASON_DANGER_MUSIC[inst.state.season],
                "danger")
        end
        _dangerTask = inst:DoTaskInTime(10, StopDanger, true)
        _triggeredLevel = 0
        _triggeredMusicPhase = 0
        _stopTime = 0

		if _hasInspirationBuff then
			_soundEmitter:SetParameter("danger", "wathgrithr_intensity", _hasInspirationBuff)
		end
    end
end

local function IsInRuins(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("Nightmare")
        or false  -- Fallback, CurrentlyInTag can return nil if not considered in any area (e.g. in the ocean)
end

local function IsInLunar(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("lunacyarea")  -- Includes Lunar Island and Lunar Grotto
        or false
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnTriggeredEvent(player, data)
    if data == nil then
        return
    end

    local level = math.max(1, math.floor(data.level or 1))
    if level == _triggeredLevel then
        _stopTime = math.max(_stopTime, GetTime() + (data.duration or 10))
        return
    elseif not _isEnabled then
        return
    end

    -- Don't update music if the configured musicPhase is -1 or the same as the last
    local eventTable = TRIGGERED_EVENT_MUSIC[data.name]
    local musicPhase = -1
    local musicPath = ""
    if eventTable ~= nil and #eventTable > 0 then
        musicPhase = eventTable[level].musicPhase or eventTable[1].musicPhase
        musicPath = eventTable[level].path or eventTable[1].path
    end
    if musicPhase == 0 or musicPhase == _triggeredMusicPhase then
        _stopTime = math.max(_stopTime, GetTime() + (data.duration or 10))
        return
    end

    -- Play default epicfight music if configured phase is 0 (or danger source wasn't found in table), else play specific danger music
    StopDanger()
    StopContinuous()
    if musicPhase < 0 then
        _soundEmitter:PlaySound(
            _inRuins and "music_mod/music/music_epicfight_ruins" or
            _inCaves and "music_mod/music/music_epicfight_cave" or
            SEASON_EPICFIGHT_MUSIC[inst.state.season],
            "danger")
    else
        _soundEmitter:PlaySound(musicPath, "danger")
        if _hasInspirationBuff then
            _soundEmitter:SetParameter("danger", "wathgrithr_intensity", _hasInspirationBuff)
        end
    end
    _dangerTask = inst:DoTaskInTime(data.duration or 10, StopDanger, true)
    _triggeredLevel = level
    _triggeredMusicPhase = musicPhase
    _stopTime = 0
end

local function OnPlayBoatMusic(player)
    if player:GetCurrentPlatform() then
        if not _isSailing then
            StopContinuous()
            StartOcean(player)
        elseif _sailingTask ~= nil then
            _sailingTask:Cancel()
            _sailingTask = nil
        end
        _sailingTask = inst:DoPeriodicTask(2, CheckOceanStop, 2, player)  -- Start periodic velocity check to see if we should stop music
    end
end

local function OnGotOffPlatform(player)
    if _sailingTask ~= nil then
        _sailingTask:Cancel()
        _sailingTask = nil
    end
    if _isSailing then
        _sailingTask = inst:DoTaskInTime(8, StopOcean, true)
    end

    -- Reset boatspeed in walkableplatformplayer (it does not do this itself); this allows playboatmusic to fire again when player hops back onto a boat already moving fast enough
    if (player.components.walkableplatformplayer) then
        player.components.walkableplatformplayer.boatspeed = nil
    end
end

-- **Currently disabled, event listener removed
local function OnFeasting(player, data)
    if player and player.sg and player.sg:HasStateTag("feasting") then
        StartFeasting(player)
    end
end

-- **Currently disabled, event listener removed
local function OnPlayTrainingMusic(player)
    if _dangerTask == nil and (_stopTime == 0 or GetTime() >= _stopTime) and _isEnabled and _busyTheme ~= BUSY_THEMES.RACE then
        if _busyTask then
            _busyTask:Cancel()
            _busyTask = nil
        end
        if _busyTheme ~= BUSY_THEMES.TRAINING then
            _soundEmitter:KillSound("busy")
            _soundEmitter:PlaySound("yotc_2020/music/training", "busy")
        end
        _busyTheme = BUSY_THEMES.TRAINING

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(5, StopBusy, true)
        _stopTime = 0
    end
end

-- **Currently disabled, event listener removed
local function OnPlayRaceMusic(player)
    if _dangerTask == nil and (_stopTime == 0 or GetTime() >= _stopTime) and _isEnabled then
        if _busyTask then
            _busyTask:Cancel()
            _busyTask = nil
        end
        if _busyTheme ~= BUSY_THEMES.RACE then
            _soundEmitter:KillSound("busy")
            _soundEmitter:PlaySound("yotc_2020/music/race", "busy")
        end
        _busyTheme = BUSY_THEMES.RACE

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(5, StopBusy, true)
        _stopTime = 0
    end
end

-- **Currently disabled, event listener removed
local function OnPlayHermitMusic(player)
    if _dangerTask == nil and (_stopTime == 0 or GetTime() >= _stopTime) and _isEnabled then
        if _busyTask then
            _busyTask:Cancel()
            _busyTask = nil
        end
        if _busyTheme ~= BUSY_THEMES.HERMIT then
            _soundEmitter:KillSound("busy")
            _soundEmitter:PlaySound("music_mod/music/music_island", "busy")
        end
        _busyTheme = BUSY_THEMES.HERMIT

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(30, StopBusy, true)
        _stopTime = 0
    end
end

-- **Currently disabled, event listener removed
local function OnPlayFarmingMusic(player)
	StartBusyTheme(player, BUSY_THEMES.FARMING, "farming/music/farming", 15)
end

-- ** Currently disabled, event listener removed
local function OnPlayCarnivalMusic(player, is_game_active)
	if _dangerTask ~= nil or (_busyTask ~= nil and _busyTheme == BUSY_THEMES.CARNIVAL_MINIGAME and not is_game_active) then
	    return
	end
	local theme = is_game_active and BUSY_THEMES.CARNIVAL_MINIGAME or BUSY_THEMES.CARNIVAL_AMBIENT
    StartBusyTheme(player, theme, theme == BUSY_THEMES.CARNIVAL_MINIGAME and "summerevent/music/2" or "summerevent/music/1", 2)
end

local function CheckAction(player)
    if player:HasTag("attack") then
        local target = player.replica.combat:GetTarget()
        if target ~= nil and
            target:HasTag("_combat") and
            not ((target:HasTag("prey") and not target:HasTag("hostile")) or
                target:HasTag("bird") or
                target:HasTag("butterfly") or
                target:HasTag("shadow") or
                target:HasTag("shadowchesspiece") or
                target:HasTag("noepicmusic") or
                target:HasTag("thorny") or
                target:HasTag("smashable") or
                target:HasTag("wall") or
                target:HasTag("engineering") or
                target:HasTag("smoldering") or
                target:HasTag("veggie")) then
            if target:HasTag("shadowminion") or target:HasTag("abigail") then
                local follower = target.replica.follower
                if not (follower ~= nil and follower:GetLeader() == player) then
                    StartDanger(player)
                    return
                end
            else
                StartDanger(player)
                return
            end
        end
    end
    if player:HasTag("working") then
        StartBusy(player)
    end
end

local function OnAttacked(player, data)
    if data ~= nil and
        --For a valid client side check, shadowattacker must be
        --false and not nil, pushed from player_classified
        (data.isattackedbydanger == true or
        --For a valid server side check, attacker must be non-nil
        (data.attacker ~= nil and
        not (data.attacker:HasTag("shadow") or
            data.attacker:HasTag("shadowchesspiece") or
            data.attacker:HasTag("noepicmusic") or
            data.attacker:HasTag("thorny") or
            data.attacker:HasTag("smolder")))) then

        StartDanger(player)
    end
end

-- ** Currently disabled, event listener removed
local function OnHasInspirationBuff(player, data)
	_hasInspirationBuff = (data ~= nil and data.on) and 1 or 0
	_soundEmitter:SetParameter("danger", "wathgrithr_intensity", _hasInspirationBuff)
end

local function OnInsane()
    if _dangerTask == nil and _isEnabled then
        _soundEmitter:PlaySound("dontstarve/sanity/gonecrazy_stinger")
        StopContinuous()
        --Repurpose this as a delay before stingers or busy can start again
        _stopTime = GetTime() + 15
		if CONTINUOUS_MODE then
			inst:DoTaskInTime(12, function(player)
				StartBusy(player)
			end)
		end
    end
end

local function OnEnlightened()
    if _dangerTask == nil and _isEnabled then
        _soundEmitter:PlaySound("dontstarve/sanity/lunacy_stinger")
        StopContinuous()
        --Repurpose this as a delay before stingers or busy can start again
        _stopTime = GetTime() + 15
		if CONTINUOUS_MODE then
			inst:DoTaskInTime(12, function(player)
				StartBusy(player)
			end)
		end
    end
end

local function OnChangeArea(player)
    local ruins = IsInRuins(player)
    local lunar = IsInLunar(player)
    if ruins ~= _inRuins then
        _inRuins = ruins
        _isBusyDirty = true
    end
    if lunar ~= _inLunar then
        _inLunar = lunar
        _isBusyDirty = true
    end
    if _isBusyDirty and CONTINUOUS_MODE then
        StartBusy(player)
    end
end

local function OnPhase(inst, phase)
    if _dangerTask ~= nil or not _isEnabled then
        _isBusyDirty = true
        return
    end

    -- Exit early if currently busy or in danger
    local time
    if _busyTask == nil and _stopTime ~= 0 then
        time = GetTime()
        if time < _stopTime then
            return
        end
    end

    -- Play stingers if dawn or dusk. Disabled with continuous mode as it just sounds really bad.
    local musicDelay = 2
    if not CONTINUOUS_MODE then
        if phase == "day" then
            _soundEmitter:PlaySound("dontstarve/music/music_dawn_stinger")
            musicDelay = 10
        elseif phase == "dusk" then
            _soundEmitter:PlaySound("dontstarve/music/music_dusk_stinger")
            musicDelay = 8
        end
    else
        if phase == "day" then
            musicDelay = 6
        elseif phase == "dusk" then
            musicDelay = 4
        end
    end

    -- Queue music update after delay and start playing if continuous mode
    inst:DoTaskInTime(musicDelay, function(player)
        _isBusyDirty = true
        if CONTINUOUS_MODE then
            _delayActive = false
            StartBusy(player)
        end
    end)
    _delayActive = true
	StopContinuous()

    --Repurpose this as a delay before stingers or busy can start again
    _stopTime = (time or GetTime()) + 15
end

local function OnNightmarePhase(inst, phase)
    _nightmarePhase = phase
    local isRuinsBusyDirty = _inRuins and (_nightmarePhase == NIGHTMARE_PHASES.NIGHTMARE or _nightmarePhase == NIGHTMARE_PHASES.DAWN)

    -- If we aren't in ruins or didn't just transition to/from nightmare phase, don't trigger music change
    if not isRuinsBusyDirty then
        return
    end

    if _dangerTask ~= nil or not _isEnabled then
        _isBusyDirty = true
    else
        inst:DoTaskInTime(2, function(player)
            _isBusyDirty = true
            if CONTINUOUS_MODE then
                StartBusy(player)
            end
        end)
    end
end

local function OnSeason()
    _isBusyDirty = true
end

--------------------------------------------------------------------------
--[[ Player activation; set up primary event handlers ]]
--------------------------------------------------------------------------

local function StartPlayerListeners(player)
    inst:ListenForEvent("buildsuccess", StartBusy, player)
    inst:ListenForEvent("gotnewitem", ExtendBusy, player)
    inst:ListenForEvent("performaction", CheckAction, player)
    inst:ListenForEvent("attacked", OnAttacked, player)
    if not CONTINUOUS_MODE then
        inst:ListenForEvent("goinsane", OnInsane, player)
        inst:ListenForEvent("goenlightened", OnEnlightened, player)
    end
    inst:ListenForEvent("triggeredevent", OnTriggeredEvent, player)
    inst:ListenForEvent("playboatmusic", OnPlayBoatMusic, player)
    inst:ListenForEvent("got_off_platform", OnGotOffPlatform, player)  -- Note: Pushed when boat sinks too
    if MISC_EVENTS then
        inst:ListenForEvent("isfeasting", OnFeasting, player)
        inst:ListenForEvent("playtrainingmusic", OnPlayTrainingMusic, player)
        inst:ListenForEvent("playracemusic", OnPlayRaceMusic, player)
        inst:ListenForEvent("playhermitmusic", OnPlayHermitMusic, player)
        inst:ListenForEvent("playfarmingmusic", OnPlayFarmingMusic, player)
        inst:ListenForEvent("playcarnivalmusic", OnPlayCarnivalMusic, player)
        inst:ListenForEvent("hasinspirationbuff", OnHasInspirationBuff, player)
    end
    inst:ListenForEvent("changearea", OnChangeArea, player)  -- Note: Pushed on initialization too
end

local function StopPlayerListeners(player)
    inst:RemoveEventCallback("buildsuccess", StartBusy, player)
    inst:RemoveEventCallback("gotnewitem", ExtendBusy, player)
    inst:RemoveEventCallback("performaction", CheckAction, player)
    inst:RemoveEventCallback("attacked", OnAttacked, player)
    inst:RemoveEventCallback("goinsane", OnInsane, player)
    inst:RemoveEventCallback("goenlightened", OnEnlightened, player)
    inst:RemoveEventCallback("triggeredevent", OnTriggeredEvent, player)
    inst:RemoveEventCallback("playboatmusic", OnPlayBoatMusic, player)
    inst:RemoveEventCallback("got_off_platform", OnGotOffPlatform, player)
    inst:RemoveEventCallback("isfeasting", OnFeasting, player)
    inst:RemoveEventCallback("playtrainingmusic", OnPlayTrainingMusic, player)
    inst:RemoveEventCallback("playracemusic", OnPlayRaceMusic, player)
    inst:RemoveEventCallback("playhermitmusic", OnPlayHermitMusic, player)
    inst:RemoveEventCallback("playfarmingmusic", OnPlayFarmingMusic, player)
    inst:RemoveEventCallback("playcarnivalmusic", OnPlayCarnivalMusic, player)
    inst:RemoveEventCallback("hasinspirationbuff", OnHasInspirationBuff, player)
    inst:RemoveEventCallback("changearea", OnChangeArea, player)
end

local function StartSoundEmitter()
    if _soundEmitter == nil then
        _soundEmitter = TheFocalPoint.SoundEmitter
        _isBusyDirty = true
        if not _inCaves then
            inst:WatchWorldState("phase", OnPhase)
            inst:WatchWorldState("season", OnSeason)
        elseif TRACK_CONFIG.useNightmareAlt then
            _nightmarePhase = inst.state.nightmarephase
            inst:WatchWorldState("nightmarephase", OnNightmarePhase)
        end
    end
end

local function StopSoundEmitter()
    if _soundEmitter ~= nil then
        StopDanger()
        StopContinuous()
        _soundEmitter:KillSound("busy")
        inst:StopWatchingWorldState("phase", OnPhase)
        inst:StopWatchingWorldState("season", OnSeason)
        inst:StopWatchingWorldState("nightmarephase", OnNightmarePhase)
        _nightmarePhase = NIGHTMARE_PHASES.CALM
		_busyTheme = nil
        _isBusyDirty = false
        _stopTime = 0
        _soundEmitter = nil
		_hasInspirationBuff = false
    end
end

local function OnPlayerActivated(inst, player)
    if _activatedPlayer == player then
        return
    elseif _activatedPlayer ~= nil and _activatedPlayer.entity:IsValid() then
        StopPlayerListeners(_activatedPlayer)
    end
    _activatedPlayer = player
    _inCaves = inst:HasTag("cave")
    StopSoundEmitter()
    StartSoundEmitter()
    StartPlayerListeners(player)
	if CONTINUOUS_MODE then
		StartBusy(player)
	end
end

local function OnPlayerDeactivated(inst, player)
    StopPlayerListeners(player)
    if player == _activatedPlayer then
        _activatedPlayer = nil
        StopSoundEmitter()
    end
end

local function OnEnableDynamicMusic(inst, enable)
    if _isEnabled ~= enable then
        if not enable and _soundEmitter ~= nil then
            StopDanger()
            StopContinuous()
            _soundEmitter:KillSound("busy")
            _isBusyDirty = true
        end
		if enable and CONTINUOUS_MODE then
			inst:DoTaskInTime(6, function(player)
				StartBusy(player)
			end)
		end
        _isEnabled = enable
    end
end

--------------------------------------------------------------------------
--[[ Initialization; set up activation/deactivation handlers ]]
--------------------------------------------------------------------------

inst:ListenForEvent("playeractivated", OnPlayerActivated)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
inst:ListenForEvent("enabledynamicmusic", OnEnableDynamicMusic)

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)