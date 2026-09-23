--------------------------------------------------------------------------
--[[ DynamicMusic class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local CONTINUOUS_MODE = DKC_MUSIC_REVISITED.CONFIG.MAIN.continuousMode
local TRACK_CONFIG = DKC_MUSIC_REVISITED.CONFIG.TRACK

local SEASON_BUSY_MUSIC = {
    day = {
        autumn = "music_mod/music/music_work",
        winter = "music_mod/music/music_work_winter",
        spring = "music_mod/music/music_work_spring",
        summer = "music_mod/music/music_work_summer",
    },
    dusk = {
        autumn = "music_mod/music/music_work_dusk",
        winter = (TRACK_CONFIG.useNewWinterDusk and "music_mod/music/music_work_winter_dusk_alt" or "music_mod/music/music_work_winter_dusk"),
        spring = "music_mod/music/music_work_spring_dusk",
        summer = "music_mod/music/music_work_summer_dusk",
    },
    night = {
        autumn = (TRACK_CONFIG.useNewAutumnNight and "music_mod/music/music_work_night_alt" or "music_mod/music/music_work_night"),
        winter = "music_mod/music/music_work_winter_night",
        spring = "music_mod/music/music_work_spring_night",
        summer = "music_mod/music/music_work_summer_night",
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

-- Collection of boss music. Keys are danger tags reported in event as they appear in-game, while indices inside tables correspond to reported danger level.
-- musicPhase is used to track which phase tracks are played; keep the same as the last entry to continue playing the same music as before.
-- musicPhase of 0 (or entry missing entirely) will result in generic boss music. musicPhase of -1 will skip boss music entirely
local TRIGGERED_DANGER_MUSIC = {
    dragonfly = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_3",
        }
    },
    beequeen = {
        {
            musicPhase = 0,
            path = "music_mod/music/music_epicfight_4"
        }
    },
    toadstool = {
        {
            musicPhase = 0,
            path =  "music_mod/music/music_epicfight_toadboss",
        }
    },
    antlion = {
        {
            musicPhase = 0,
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
            path = ""
        },
        {
            musicPhase = 3,
            path = "music_mod/music/music_epicfight_5b",  -- TODO implement Northern Hemispheres climax in FMOD if possible, otherwise remove
        }
    },
    shadowchess = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_ruins",
        }
    },
    stalker = {
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_stalker"
        },
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_stalker_b"
        },
        {
            musicPhase = 1,
            path = ""
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
    daywalker = {
        {
            musicPhase = 0,
            path = ""  -- TODO can't find path
        }
    },
    eyeofterror = {  -- TODO is this broken?
        {
            musicPhase = 1,
            path = "music_mod/music/music_epicfight_eyeofterror"  -- TODO couldn't find the actual in-game path, just created this in my fdp
        }
    },
    wagboss_robot = {
        {
            musicPhase = 0,
            path = ""  -- TODO can't find path, also unsure if W.A.R.B.O.T. tag is correct
        },
    },

    -- Celestial champion phases are reported as 3 separate entities instead of using level for some reason
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
    pigking = {
        {
            musicPhase = -1,
            path = "dontstarve/music/music_pigking_minigame"
        }
    },
    wagstaff_experiment = {
        {
            musicPhase = -1,
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
local _soundEmitter = nil     -- SoundEmitter component used to update music track/intensity
local _activatedPlayer = nil  -- Player that activated this component, used for changing music

local _isDay = nil
local _busyTask = nil
local _busyTheme = nil
local _isBusyDirty = nil
local _extendTime = nil
local _dangerTask = nil
local _triggeredLevel = nil                    -- Used to track the danger level of a triggered danger encounter
local _triggeredMusicPhase = nil               -- Used to track whether we should switch music on a new danger level
local _inCaves = false                         -- When in the cave layer
local _inRuins = false                         -- When in ruins
local _nightmarePhase = NIGHTMARE_PHASES.CALM  -- Current nightmare cycle phase; only updated if "Nightmare Phase Music" is enabled
local _inLunar = false                         -- When on lunar island or in lunar grotto

local _stingerActive = false     -- Used to prevent music overlapping with stinger
local _hasInspirationBuff = nil

--------------------------------------------------------------------------
--[[ Reusable music constrols and helper functions ]]
--------------------------------------------------------------------------

-- TODO change music paths to use music mod path instead of vanilla, then remove remaps from modmain when done. Not sure why original script uses this arbitrary mix

local function StopContinuous()
	if _busyTask ~= nil then
        _busyTask:Cancel()
	end
	_busyTask = nil
	_extendTime = 0
	_soundEmitter:SetParameter("busy", "intensity", 0)  -- Mute music, do not restart; sound in FMOD should cover intensity 0 for this to work correctly
end

local function StopBusy(inst, isTimeout)
    if not CONTINUOUS_MODE and _busyTask ~= nil then
        if not isTimeout then
            _busyTask:Cancel()
        elseif _extendTime > 0 then
            local time = GetTime()
            if time < _extendTime then
                _busyTask = inst:DoTaskInTime(_extendTime - time, StopBusy, true)
                _extendTime = 0
                return
            end
        end
        _busyTask = nil
        _extendTime = 0
        _soundEmitter:SetParameter("busy", "intensity", 0)
    end
end

local function StartBusy(player)
    if _busyTask ~= nil and not _isBusyDirty then
        _extendTime = GetTime() + 15
    elseif _dangerTask == nil and not _stingerActive and (CONTINUOUS_MODE or _extendTime == 0 or GetTime() >= _extendTime) and _isEnabled then

        -- Check if player is in a lunar biome and assign lunar music
        if _inLunar then
            if _busyTheme ~= BUSY_THEMES.LUNAR then
                _soundEmitter:KillSound("busy")
                _soundEmitter:PlaySound("music_mod/music/working", "busy")
            end
            _busyTheme = BUSY_THEMES.LUNAR
        
        -- Else check if player is in cave layer and assign ruins or cave music
        elseif _inCaves then
            if _inRuins then
                -- TODO make this use array/index logic instead of if-chain if possible this is ugly
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
                if SEASON_BUSY_MUSIC[phase] == nil then
                    phase = "day"
                end
                if SEASON_BUSY_MUSIC[phase][season] == nil then
                    season = "autumn"
                end
                _soundEmitter:PlaySound(SEASON_BUSY_MUSIC[phase][season], "busy")
            end
            _busyTheme = BUSY_THEMES.FOREST
        end

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(15, StopBusy, true)
        _extendTime = 0
    end
end

local function StartOcean(player)
    local function StopOcean(...)
        StopBusy(...)
        if CONTINUOUS_MODE then
            StopContinuous()
            StartBusy(player)
        end
    end
    if _busyTask ~= nil and not _isBusyDirty then
        _extendTime = GetTime() + 15
    elseif _dangerTask == nil and (_extendTime == 0 or GetTime() >= _extendTime) and _isEnabled then
        if _busyTheme ~= BUSY_THEMES.OCEAN or _isBusyDirty then
            _isBusyDirty = false
            _soundEmitter:KillSound("busy")
            _soundEmitter:PlaySound("music_mod/music/sailing", "busy")
        end
        _busyTheme = BUSY_THEMES.OCEAN

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(30, StopOcean, true)
        _extendTime = 0
    end
end

local function StartBusyTheme(player, theme, sound, duration, extendtime)
    if _dangerTask == nil and (_busyTheme ~= theme or _extendTime == 0 or GetTime() >= _extendTime) and _isEnabled then
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
        _extendTime = extendtime or 0
    end
end

local function StartFeasting(player)
    if _busyTask ~= nil then
        _extendTime = 0
        _busyTask:Cancel()
        _busyTask = nil
        _busyTask = inst:DoTaskInTime(5, StopBusy, true)
    elseif _dangerTask == nil and (_extendTime == 0 or GetTime() >= _extendTime) and _isEnabled then

        if _busyTheme ~= BUSY_THEMES.FEAST then
            _soundEmitter:KillSound("busy")
            _soundEmitter:PlaySound("wintersfeast2019/music/feast", "busy")
        end
        _busyTheme = BUSY_THEMES.FEAST

        _soundEmitter:SetParameter("busy", "intensity", 1)
        _busyTask = inst:DoTaskInTime(5, StopBusy, true)
        _extendTime = 0
    end
end

local function ExtendBusy()
    if _busyTask ~= nil then
        _extendTime = math.max(_extendTime, GetTime() + 10)
    end
end

local function StopDanger(inst, istimeout)
    if _dangerTask ~= nil then
        if not istimeout then
            _dangerTask:Cancel()
        elseif _extendTime > 0 then
            local time = GetTime()
            if time < _extendTime then
                _dangerTask = inst:DoTaskInTime(_extendTime - time, StopDanger, true)
                _extendTime = 0
                return
            end
        end
        _dangerTask = nil
        _triggeredLevel = nil
        _triggeredMusicPhase = nil
        _extendTime = 0
        _soundEmitter:KillSound("danger")
		if CONTINUOUS_MODE then
			StartBusy(_activatedPlayer)
		end
    end
end

local EPIC_TAGS = { "epic" }
local NO_EPIC_TAGS = { "noepicmusic" }
local function StartDanger(player)
    if _dangerTask ~= nil then
        _extendTime = GetTime() + 10
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
        _triggeredLevel = nil
        _triggeredMusicPhase = nil
        _extendTime = 0

		if _hasInspirationBuff then
			_soundEmitter:SetParameter("danger", "wathgrithr_intensity", _hasInspirationBuff)
		end
    end
end

-- Helper function, checks whether player is currently in the ruins
local function IsInRuins(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("Nightmare")
end

-- Helper function, checks whether player is currently on the lunar island or in the lunar grotto
local function IsInLunar(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("lunacyarea")
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function StartTriggeredDanger(player, data)
    print("StartTriggeredDanger() - name: " .. data.name .. ", level: " .. (data.level or "none") .. ", duration: " .. (data.duration or "none"))  -- TODO to learn how this shite works
    print("Current _triggeredLevel is: " .. (_triggeredLevel or "none"))
    if (data == nil) then
        print("WARN: StartTriggeredDanger() - data was nil")  -- TODO testing and shite
        return
    end
    local level = math.max(1, math.floor(data.level or 1))
    if _triggeredLevel == level then
        _extendTime = math.max(_extendTime, GetTime() + (data.duration or 10))
    elseif _isEnabled then
        print("StartTriggeredDanger() - level different, cutting music and playing new track")  -- TODO testing and shite
        StopDanger()
        StopContinuous()
        local musicTable = TRIGGERED_DANGER_MUSIC[data.name]
        local musicPhase = 0
        local musicPath = ""
        if musicTable ~= nil and #musicTable > 0 then
            musicPhase = musicTable[level].musicPhase
            musicPath = musicTable[level].path
        end

        -- Don't update music if the configured musicPhase is -1 or the same as the last
        if (musicPhase < 0 or musicPhase == _triggeredMusicPhase) then
            _extendTime = math.max(_extendTime, GetTime() + (data.duration or 10))
            return
        end

        -- Play default epicfight music if configured phase is 0 (or danger source wasn't found in table), else play specific danger music
        if (musicPhase == 0) then
            _soundEmitter:PlaySound(
                _inRuins and "music_mod/music/music_epicfight_ruins" or
                _inCaves and "music_mod/music/music_epicfight_cave" or
                SEASON_EPICFIGHT_MUSIC[inst.state.season],
                "danger")
        else
            _soundEmitter:PlaySound(musicPath, "danger")  -- TODO something is very wrong here suddenly?
            if _hasInspirationBuff then
                _soundEmitter:SetParameter("danger", "wathgrithr_intensity", _hasInspirationBuff)
            end
        end
        _dangerTask = inst:DoTaskInTime(data.duration or 10, StopDanger, true)
        _triggeredLevel = level
        _triggeredMusicPhase = musicPhase
        _extendTime = 0
    end
end

local function StartTriggeredWater(player, data)
    if player:GetCurrentPlatform() then
        _isBusyDirty = true
        StopContinuous()
        StartOcean(player)
    end
end

-- **Currently disabled, event listener removed
local function StartTriggeredFeasting(player, data)
    if player and player.sg and player.sg:HasStateTag("feasting") then
        StartFeasting(player)
    end
end

-- **Currently disabled, event listener removed
local function StartTraining(player)
    if _dangerTask == nil and (_extendTime == 0 or GetTime() >= _extendTime) and _isEnabled and _busyTheme ~= BUSY_THEMES.RACE then
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
        _extendTime = 0
    end
end

-- **Currently disabled, event listener removed
local function StartRacing(player)
    if _dangerTask == nil and (_extendTime == 0 or GetTime() >= _extendTime) and _isEnabled then
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
        _extendTime = 0
    end
end

-- **Currently disabled, event listener removed
local function StartHermit(player)
    if _dangerTask == nil and (_extendTime == 0 or GetTime() >= _extendTime) and _isEnabled then
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
        _extendTime = 0
    end
end

-- **Currently disabled, event listener removed
local function StartFarming(player)
	StartBusyTheme(player, BUSY_THEMES.FARMING, "farming/music/farming", 15)
end

-- ** Currently disabled, event listener removed
local function StartCarnivalMusic(player, is_game_active)
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
        _soundEmitter:PlaySound("music_mod/music/gonecrazy_stinger")
        StopContinuous()
        --Repurpose this as a delay before stingers or busy can start again
        _extendTime = GetTime() + 15
		if CONTINUOUS_MODE then
			_activatedPlayer:DoTaskInTime(8, function(player) -- Give the stinger time to play before playing music
				StartBusy(player)
			end)
		end
    end
end

local function OnChangeArea(player)
	if player.components.areaaware then
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
            StartBusy(_activatedPlayer)
        end
	end
end

local function OnPhase(inst, phase)
    _isDay = phase == "day"
    if _dangerTask ~= nil or not _isEnabled then
        _isBusyDirty = true
        return
    end

    -- Play stingers if not busy and not in danger
    local time
    if _busyTask == nil and _extendTime ~= 0 then
        time = GetTime()
        if time < _extendTime then
            return
        end
    end
    if _isDay then
        _soundEmitter:PlaySound("music_mod/music/music_dawn_stinger")
		if CONTINUOUS_MODE then
			_stingerActive = true
		end
    elseif phase == "dusk" then
        _soundEmitter:PlaySound("music_mod/music/music_dusk_stinger")
		if CONTINUOUS_MODE then
			_stingerActive = true
		end
    end

    -- Queue busy music to start after a delay to let stinger play for day and dusk (night has no stinger)
	if phase ~= "night" then 
		_activatedPlayer:DoTaskInTime(8, function(player)
            _isBusyDirty = true
            if CONTINUOUS_MODE then
                _stingerActive = false
                StartBusy(player)
            end
		end)
	else
		_activatedPlayer:DoTaskInTime(2, function(player)
            _isBusyDirty = true
            if CONTINUOUS_MODE then
                StartBusy(player)
            end
		end)
	end
	StopContinuous()

    --Repurpose this as a delay before stingers or busy can start again
    _extendTime = (time or GetTime()) + 15
end

local function OnNightmarePhase(inst, phase)
    _nightmarePhase = phase
    local isRuinsBusyDirty = _inRuins and (_nightmarePhase == NIGHTMARE_PHASES.NIGHTMARE or _nightmarePhase == NIGHTMARE_PHASES.DAWN)

    -- If we aren't in ruins or didn't just transition to/from nightmare phase, don't trigger music change
    if not isRuinsBusyDirty then
        return
    end

    -- If we're in a fight, dirty busy music so it updates after danger music finishes. Otherwise, update music immediately.
    if _dangerTask ~= nil or not _isEnabled then
        _isBusyDirty = true
    else
        _activatedPlayer:DoTaskInTime(2, function(player)
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
    inst:ListenForEvent("goinsane", OnInsane, player)
    inst:ListenForEvent("goenlightened", OnInsane, player)
    inst:ListenForEvent("triggeredevent", StartTriggeredDanger, player)
    inst:ListenForEvent("boatspedup", StartTriggeredWater, player)
    -- inst:ListenForEvent("isfeasting", StartTriggeredFeasting, player)
    -- inst:ListenForEvent("playtrainingmusic", StartTraining, player)
    -- inst:ListenForEvent("playracemusic", StartRacing, player)
    -- inst:ListenForEvent("playhermitmusic", StartHermit, player)
    -- inst:ListenForEvent("playfarmingmusic", StartFarming, player)
    -- inst:ListenForEvent("playcarnivalmusic", StartCarnivalMusic, player)
    -- inst:ListenForEvent("hasinspirationbuff", OnHasInspirationBuff, player)
    inst:ListenForEvent("changearea", OnChangeArea, player)
end

local function StopPlayerListeners(player)
    inst:RemoveEventCallback("buildsuccess", StartBusy, player)
    inst:RemoveEventCallback("gotnewitem", ExtendBusy, player)
    inst:RemoveEventCallback("performaction", CheckAction, player)
    inst:RemoveEventCallback("attacked", OnAttacked, player)
    inst:RemoveEventCallback("goinsane", OnInsane, player)
    inst:RemoveEventCallback("goenlightened", OnInsane, player)
    inst:RemoveEventCallback("triggeredevent", StartTriggeredDanger, player)
    inst:RemoveEventCallback("boatspedup", StartTriggeredWater, player)
    -- inst:RemoveEventCallback("isfeasting", StartTriggeredFeasting, player)
    -- inst:RemoveEventCallback("playtrainingmusic", StartTraining, player)
    -- inst:RemoveEventCallback("playracemusic", StartRacing, player)
    -- inst:RemoveEventCallback("playhermitmusic", StartHermit, player)
    -- inst:RemoveEventCallback("playfarmingmusic", StartFarming, player)
    -- inst:RemoveEventCallback("playcarnivalmusic", StartCarnivalMusic, player)
    -- inst:RemoveEventCallback("hasinspirationbuff", OnHasInspirationBuff, player)
    inst:RemoveEventCallback("changearea", OnChangeArea, player)
end

local function StartSoundEmitter()
    if _soundEmitter == nil then
        _soundEmitter = TheFocalPoint.SoundEmitter
        _extendTime = 0
        _isBusyDirty = true
        if not _inCaves then
            _isDay = inst.state.isday
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
        _isDay = nil
        _nightmarePhase = NIGHTMARE_PHASES.CALM
		_busyTheme = nil
        _isBusyDirty = nil
        _extendTime = nil
        _soundEmitter = nil
		_hasInspirationBuff = nil
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
    _inRuins = IsInRuins(player)
    _inLunar = IsInLunar(player)
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
			_activatedPlayer:DoTaskInTime(6, function(player)
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