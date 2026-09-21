--------------------------------------------------------------------------
--[[ DynamicMusic class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MOD_CONFIG = DKC_MUSIC_REVISITED.TRACK_CONFIG

local SEASON_BUSY_MUSIC =
{
    day =
    {
        autumn = "music_mod/music/music_work",
        winter = "music_mod/music/music_work_winter",
        spring = "music_mod/music/music_work_spring",
        summer = "music_mod/music/music_work_summer",
    },
    dusk =
    {
        autumn = "music_mod/music/music_work_dusk",
        winter = (MOD_CONFIG.USE_NEW_WINTER_DUSK and "music_mod/music/music_work_winter_dusk_alt" or "music_mod/music/music_work_winter_dusk"),
        spring = "music_mod/music/music_work_spring_dusk",
        summer = "music_mod/music/music_work_summer_dusk",
    },
    night = 
    {
        autumn = (MOD_CONFIG.USE_NEW_AUTUMN_NIGHT and "music_mod/music/music_work_night_alt" or "music_mod/music/music_work_night"),
        winter = "music_mod/music/music_work_winter_night",
        spring = "music_mod/music/music_work_spring_night",
        summer = "music_mod/music/music_work_summer_night",
    },
}

local SEASON_DANGER_MUSIC =
{
    autumn = "music_mod/music/music_danger",
    winter = "music_mod/music/music_danger_winter",
    spring = (MOD_CONFIG.USE_NEW_SPRING_FIGHT and "music_mod/music/music_danger_spring_alt" or "music_mod/music/music_danger_spring"),
    summer = "music_mod/music/music_danger_summer",
}

local SEASON_EPICFIGHT_MUSIC =
{
    autumn = "music_mod/music/music_epicfight",
    winter = "music_mod/music/music_epicfight_winter",
    spring = "music_mod/music/music_epicfight_spring",
    summer = "music_mod/music/music_epicfight_summer",
}

local RUINS_BUSY_MUSIC = {
    normal = "music_mod/music/music_work_ruins",
    nightmare = "music_mod/music/music_work_ruins_alt"
}

local TRIGGERED_DANGER_MUSIC =
{

    wagstaff_experiment =
    {
        "music_mod/music/music_wagstaff_experiment",
    },

    crabking =
    {
        "music_mod/music/music_epicfight_crabking",
    },

    malbatross =
    {
        "music_mod/music/malbatross",
    },

    moonbase =
    {
        "music_mod/music/music_epicfight_moonbase",
        "music_mod/music/music_epicfight_moonbase_b",
    },

    toadstool =
    {
        "music_mod/music/music_epicfight_toadboss",
    },

    beequeen =
    {
        "music_mod/music/music_epicfight_4",
    },

    dragonfly =
    {
        "music_mod/music/music_epicfight_3",
    },

    shadowchess =
    {
        "music_mod/music/music_epicfight_ruins",
    },

    klaus =
    {
        "music_mod/music/music_epicfight_5a",
        "",
        "music_mod/music/music_epicfight_5b",
    },

    antlion =
    {
        "music_mod/music/music_epicfight_antlion",
    },

    stalker =
    {
        "music_mod/music/music_epicfight_stalker",
        "music_mod/music/music_epicfight_stalker_b",
        "",
    },

    pigking =
    {
        "dontstarve/music/music_pigking_minigame",
    },

    alterguardian_phase1 =
    {
        "music_mod/music/music_epicfight_alterguardian1",
    },
    alterguardian_phase2 =
    {
        "music_mod/music/music_epicfight_alterguardian2",
    },
    alterguardian_phase3 =
    {
        "music_mod/music/music_epicfight_alterguardian3",
    },

    default =
    {
        "music_mod/music/music_epicfight_ruins",
    },
}

local BUSYTHEMES = {
    FOREST = 1,
    CAVE = 2,
    RUINS = 3,
    OCEAN = 4,
    LUNARISLAND = 5,
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

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _iscave = inst:HasTag("cave")
local _isenabled = true
local _busytask = nil
local _dangertask = nil
local _triggeredlevel = nil
local _isday = nil
local _isbusydirty = nil
local _busytheme = nil
local _extendtime = nil
local _soundemitter = nil
local _activatedplayer = nil --cached for activation/deactivation only, NOT for logic use
local _stingeractive = false -- Used to prevent music overlapping with stinger
local _inruins = false -- When in ruins
local _nightmarephase = NIGHTMARE_PHASES.CALM  -- Current nightmare cycle phase; defaults to calm and stays there if "Nightmare Phase Music" is disabled
local _inlunar = false -- When on lunar island
local _hasinspirationbuff = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function IsInRuins(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("Nightmare")
end

local function IsOnLunarIsland(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("lunacyarea")
end

local function StopContinuous()
	if _busytask ~= nil then
        _busytask:Cancel()
	end
	_busytask = nil
	_extendtime = 0
	_soundemitter:SetParameter("busy", "intensity", 0)
end

local function StopBusy(inst, istimeout)
    if not continuous_mode and _busytask ~= nil then
        if not istimeout then
            _busytask:Cancel()
        elseif _extendtime > 0 then
            local time = GetTime()
            if time < _extendtime then
                _busytask = inst:DoTaskInTime(_extendtime - time, StopBusy, true)
                _extendtime = 0
                return
            end
        end
        _busytask = nil
        _extendtime = 0
        _soundemitter:SetParameter("busy", "intensity", 0)
    end
end

local function StartBusy(player)
    if _busytask ~= nil and not _isbusydirty then
        _extendtime = GetTime() + 15
    elseif _dangertask == nil and not _stingeractive and (continuous_mode or _extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _iscave then
            if IsInRuins(player) then
                -- TODO make this use array/index logic instead of if-chain if possible
                if _nightmarephase ~= NIGHTMARE_PHASES.NIGHTMARE and _busytheme ~= BUSYTHEMES.RUINS then
                    _soundemitter:KillSound("busy")
                    _soundemitter:PlaySound(RUINS_BUSY_MUSIC["normal"], "busy")
                    _busytheme = BUSYTHEMES.RUINS
                elseif _nightmarephase == NIGHTMARE_PHASES.NIGHTMARE and _busytheme ~= BUSYTHEMES.NIGHTMARE then
                    _soundemitter:KillSound("busy")
                    _soundemitter:PlaySound(RUINS_BUSY_MUSIC["nightmare"], "busy")
                    _busytheme = BUSYTHEMES.NIGHTMARE
                end
            else
                if _busytheme ~= BUSYTHEMES.CAVE then
                    _soundemitter:KillSound("busy")
                    _soundemitter:PlaySound("dontstarve/music/music_work_cave", "busy")
                end
                _busytheme = BUSYTHEMES.CAVE
            end
        else
            if IsOnLunarIsland(player) then
                if _busytheme ~= BUSYTHEMES.LUNARISLAND then
                    _soundemitter:KillSound("busy")
                    _soundemitter:PlaySound("turnoftides/music/working", "busy")
                end
                _busytheme = BUSYTHEMES.LUNARISLAND
            else
                if _busytheme ~= BUSYTHEMES.FOREST or _isbusydirty then
                    _isbusydirty = false
                    _soundemitter:KillSound("busy")
                    -- Check if music for phase and season exist
                    local season = inst.state.season
                    local phase = inst.state.phase
                    if SEASON_BUSY_MUSIC[phase] == nil then
                        phase = "day"
                    end
                    if SEASON_BUSY_MUSIC[phase][season] == nil then
                        season = "autumn"
                    end
                    _soundemitter:PlaySound(
                        (_inruins and "dontstarve/music/music_work_ruins") or  -- TODO replace this with same array once index logic implemented
                        (_iscave and "dontstarve/music/music_work_cave") or
                        (SEASON_BUSY_MUSIC[phase][season]),
                        "busy")
                end
                _busytheme = BUSYTHEMES.FOREST
            end
        end

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(15, StopBusy, true)
        _extendtime = 0
    end
end

local function StartOcean(player)
    local function StopOcean(...)
        StopBusy(...)
        if continuous_mode then
            StopContinuous()
            StartBusy(player)
        end
    end
    if _busytask ~= nil and not _isbusydirty then
        _extendtime = GetTime() + 15
    elseif _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _busytheme ~= BUSYTHEMES.OCEAN or _isbusydirty then
            _isbusydirty = false
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("turnoftides/music/sailing", "busy")
        end
        _busytheme = BUSYTHEMES.OCEAN

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(30, StopOcean, true)
        _extendtime = 0
    end
end

local function StartFeasting(player)
    if _busytask ~= nil then
        _extendtime = 0
        _busytask:Cancel()
        _busytask = nil
        _busytask = inst:DoTaskInTime(5, StopBusy, true)
    elseif _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then

        if _busytheme ~= BUSYTHEMES.FEAST then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("wintersfeast2019/music/feast", "busy")
        end
        _busytheme = BUSYTHEMES.FEAST

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(5, StopBusy, true)
        _extendtime = 0
    end
end

local function StartRacing(player)
    if _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _busytask then
            _busytask:Cancel()
            _busytask = nil
        end
        if _busytheme ~= BUSYTHEMES.RACE then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("yotc_2020/music/race", "busy")
        end
        _busytheme = BUSYTHEMES.RACE

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(5, StopBusy, true)
        _extendtime = 0
    end
end

local function StartHermit(player)
    if _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _busytask then
            _busytask:Cancel()
            _busytask = nil
        end
        if _busytheme ~= BUSYTHEMES.HERMIT then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("hookline_2/characters/hermit/music_work", "busy")
        end
        _busytheme = BUSYTHEMES.HERMIT

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(30, StopBusy, true)
        _extendtime = 0
    end
end

local function StartTraining(player)
    if _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled and _busytheme ~= BUSYTHEMES.RACE then
        if _busytask then
            _busytask:Cancel()
            _busytask = nil
        end
        if _busytheme ~= BUSYTHEMES.TRAINING then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("yotc_2020/music/training", "busy")
        end
        _busytheme = BUSYTHEMES.TRAINING

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(5, StopBusy, true)
        _extendtime = 0
    end
end

local function StartBusyTheme(player, theme, sound, duration, extendtime)
    if _dangertask == nil and (_busytheme ~= theme or _extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _busytask then
            _busytask:Cancel()
            _busytask = nil
        end
        if _busytheme ~= theme then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound(sound, "busy")
	        _busytheme = theme
        end

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(duration, StopBusy, true)
        _extendtime = extendtime or 0
    end
end

local function StartFarming(player)
	StartBusyTheme(player, BUSYTHEMES.FARMING, "farming/music/farming", 15)
end

local function StartCarnivalMustic(player, is_game_active)
	if _dangertask ~= nil or (_busytask ~= nil and _busytheme == BUSYTHEMES.CARNIVAL_MINIGAME and not is_game_active) then
		return
	end

	local theme = is_game_active and BUSYTHEMES.CARNIVAL_MINIGAME or BUSYTHEMES.CARNIVAL_AMBIENT
	StartBusyTheme(player, theme, theme == BUSYTHEMES.CARNIVAL_MINIGAME and "summerevent/music/2" or "summerevent/music/1", 2)
end

local function ExtendBusy()
    if _busytask ~= nil then
        _extendtime = math.max(_extendtime, GetTime() + 10)
    end
end

local function StopDanger(inst, istimeout)
    if _dangertask ~= nil then
        if not istimeout then
            _dangertask:Cancel()
        elseif _extendtime > 0 then
            local time = GetTime()
            if time < _extendtime then
                _dangertask = inst:DoTaskInTime(_extendtime - time, StopDanger, true)
                _extendtime = 0
                return
            end
        end
        _dangertask = nil
        _triggeredlevel = nil
        _extendtime = 0
        _soundemitter:KillSound("danger")
		if continuous_mode then
			StartBusy(_activatedplayer)
		end
    end
end

local EPIC_TAGS = { "epic" }
local NO_EPIC_TAGS = { "noepicmusic" }
local function StartDanger(player)
    if _dangertask ~= nil then
        _extendtime = GetTime() + 10
    elseif _isenabled then
        StopContinuous()
        local x, y, z = player.Transform:GetWorldPosition()
        _soundemitter:PlaySound(
            #TheSim:FindEntities(x, y, z, 30, EPIC_TAGS, NO_EPIC_TAGS) > 0
            and ((IsInRuins(player) and "dontstarve/music/music_epicfight_ruins") or
                (_iscave and "dontstarve/music/music_epicfight_cave") or
                (SEASON_EPICFIGHT_MUSIC[inst.state.season]))
            or ((IsInRuins(player) and "dontstarve/music/music_danger_ruins") or
                (_iscave and "dontstarve/music/music_danger_cave") or
                (SEASON_DANGER_MUSIC[inst.state.season])),
            "danger")
        _dangertask = inst:DoTaskInTime(10, StopDanger, true)
        _triggeredlevel = nil
        _extendtime = 0

		if _hasinspirationbuff then
			_soundemitter:SetParameter("danger", "wathgrithr_intensity", _hasinspirationbuff)
		end
    end
end

local function StartTriggeredDanger(player, data)
    local level = math.max(1, math.floor(data ~= nil and data.level or 1))
    if _triggeredlevel == level then
        _extendtime = math.max(_extendtime, GetTime() + (data.duration or 10))
    elseif _isenabled then
        StopContinuous()
        StopDanger()
        local music = data ~= nil and TRIGGERED_DANGER_MUSIC[data.name or "default"] or TRIGGERED_DANGER_MUSIC.default
        music = music[level] or music[1]
        if #music > 0 then
            _soundemitter:PlaySound(music, "danger")
            if _hasinspirationbuff then
                _soundemitter:SetParameter("danger", "wathgrithr_intensity", _hasinspirationbuff)
            end
        end
        _dangertask = inst:DoTaskInTime(data.duration or 10, StopDanger, true)
        _triggeredlevel = level
        _extendtime = 0
    end
end

local function StartTriggeredWater(player, data)
    if player:GetCurrentPlatform() then
        _isbusydirty = true
        StopContinuous()
        StartOcean(player)
    end
end

local function StartTriggeredFeasting(player, data)
    if player and player.sg and player.sg:HasStateTag("feasting") then
        StartFeasting(player)
    end
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

local function OnHasInspirationBuff(player, data)
	_hasinspirationbuff = (data ~= nil and data.on) and 1 or 0
	_soundemitter:SetParameter("danger", "wathgrithr_intensity", _hasinspirationbuff)
end

local function OnInsane()
    if _dangertask == nil and _isenabled then
        _soundemitter:PlaySound("dontstarve/sanity/gonecrazy_stinger")
        StopContinuous()
        --Repurpose this as a delay before stingers or busy can start again
        _extendtime = GetTime() + 15
		if continuous_mode then
			_activatedplayer:DoTaskInTime(8, function(player) -- Give the stinger time to play before playing music
				StartBusy(player)
			end)
		end
    end
end

local function OnChangeArea(player)
	if player.components.areaaware then
		local ruins = player.components.areaaware:CurrentlyInTag("Nightmare") or false
        local lunar = player.components.areaaware:CurrentlyInTag("lunacyarea") or false
		if ruins ~= _inruins then
			_inruins = ruins
			_isbusydirty = true
		end
        if lunar ~= _inlunar then
			_inlunar = lunar
			_isbusydirty = true
		end
        if _isbusydirty and continuous_mode then
            StartBusy(_activatedplayer)
        end
	end
end

local function OnEnlightened()
	-- TEMP
    if _dangertask == nil and _isenabled then
        _soundemitter:PlaySound("dontstarve/sanity/gonecrazy_stinger")
        StopContinuous()
        --Repurpose this as a delay before stingers or busy can start again
        _extendtime = GetTime() + 15
		if continuous_mode then
			_activatedplayer:DoTaskInTime(8, function(player) -- Give the stinger time to play before playing music
				StartBusy(player)
			end)
		end
    end
end

local function StartPlayerListeners(player)
    inst:ListenForEvent("buildsuccess", StartBusy, player)
    inst:ListenForEvent("gotnewitem", ExtendBusy, player)
    inst:ListenForEvent("performaction", CheckAction, player)
    inst:ListenForEvent("attacked", OnAttacked, player)
    inst:ListenForEvent("goinsane", OnInsane, player)
    inst:ListenForEvent("goenlightened", OnEnlightened, player)
    inst:ListenForEvent("triggeredevent", StartTriggeredDanger, player)
    inst:ListenForEvent("boatspedup", StartTriggeredWater, player)
    inst:ListenForEvent("isfeasting", StartTriggeredFeasting, player)
    inst:ListenForEvent("playracemusic", StartRacing, player)
    inst:ListenForEvent("playhermitmusic", StartHermit, player)
    inst:ListenForEvent("playtrainingmusic", StartTraining, player)
    inst:ListenForEvent("playfarmingmusic", StartFarming, player)
    inst:ListenForEvent("hasinspirationbuff", OnHasInspirationBuff, player)
    inst:ListenForEvent("changearea", OnChangeArea, player)
    inst:ListenForEvent("playcarnivalmusic", StartCarnivalMustic, player)
end

local function StopPlayerListeners(player)
    inst:RemoveEventCallback("buildsuccess", StartBusy, player)
    inst:RemoveEventCallback("gotnewitem", ExtendBusy, player)
    inst:RemoveEventCallback("performaction", CheckAction, player)
    inst:RemoveEventCallback("attacked", OnAttacked, player)
    inst:RemoveEventCallback("goinsane", OnInsane, player)
    inst:RemoveEventCallback("goenlightened", OnEnlightened, player)
    inst:RemoveEventCallback("triggeredevent", StartTriggeredDanger, player)
    inst:RemoveEventCallback("boatspedup", StartTriggeredWater, player)
    inst:RemoveEventCallback("isfeasting", StartTriggeredFeasting, player)
    inst:RemoveEventCallback("playracemusic", StartRacing, player)
    inst:RemoveEventCallback("playhermitmusic", StartHermit, player)
    inst:RemoveEventCallback("playtrainingmusic", StartTraining, player)
    inst:RemoveEventCallback("playfarmingmusic", StartFarming, player)
    inst:RemoveEventCallback("hasinspirationbuff", OnHasInspirationBuff, player)
    inst:RemoveEventCallback("changearea", OnChangeArea, player)
    inst:RemoveEventCallback("playcarnivalmusic", StartCarnivalMustic, player)
end

local function OnPhase(inst, phase)
    _isday = phase == "day"
    if _dangertask ~= nil or not _isenabled then
        _isbusydirty = true
        return
    end

    -- Play stingers if not busy and not in danger
    local time
    if _busytask == nil and _extendtime ~= 0 then
        time = GetTime()
        if time < _extendtime then
            return
        end
    end
    if _isday then
        _soundemitter:PlaySound("dontstarve/music/music_dawn_stinger")
		if continuous_mode then
			_stingeractive = true
		end
    elseif phase == "dusk" then
        _soundemitter:PlaySound("dontstarve/music/music_dusk_stinger")
		if continuous_mode then
			_stingeractive = true
		end
    end

    -- Queue busy music to start after a delay to let stinger play for day and dusk (night has no stinger)
	if phase ~= "night" then 
		_activatedplayer:DoTaskInTime(8, function(player)
            _isbusydirty = true
            if continuous_mode then
                _stingeractive = false
                StartBusy(player)
            end
		end)
	else
		_activatedplayer:DoTaskInTime(2, function(player)
            _isbusydirty = true
            if continuous_mode then
                StartBusy(player)
            end
		end)
	end
	StopContinuous()

    --Repurpose this as a delay before stingers or busy can start again
    _extendtime = (time or GetTime()) + 15
end

local function OnNightmarePhase(inst, phase)
    _nightmarephase = phase
    local ruins_music_dirty = _inruins and (_nightmarephase == NIGHTMARE_PHASES.NIGHTMARE or _nightmarephase == NIGHTMARE_PHASES.DAWN)

    -- If we aren't in ruins or didn't just transition to/from nightmare phase, don't trigger music change
    if not ruins_music_dirty then
        return
    end

    -- If we're in a fight, dirty busy music so it updates after danger music finishes. Otherwise, update music immediately.
    if _dangertask ~= nil or not _isenabled then
        _isbusydirty = true
    else
        _activatedplayer:DoTaskInTime(2, function(player)
            _isbusydirty = true
            if continuous_mode then
                StartBusy(player)
            end
        end)
    end

    -- Prompt immediate update if we are in ruins busy and just transitioned into or out of nightmare phase
end

local function OnSeason()
    _isbusydirty = true
end

local function StartSoundEmitter()
    if _soundemitter == nil then
        _soundemitter = TheFocalPoint.SoundEmitter
        _extendtime = 0
        _isbusydirty = true
        if not _iscave then
            _isday = inst.state.isday
            inst:WatchWorldState("phase", OnPhase)
            inst:WatchWorldState("season", OnSeason)
        elseif MOD_CONFIG.USE_NIGHTMARE_ALT then
            _nightmarephase = inst.state.nightmarephase  -- TODO make sure this works
            inst:WatchWorldState("nightmarephase", OnNightmarePhase)
        end
    end
end

local function StopSoundEmitter()
    if _soundemitter ~= nil then
        StopDanger()
        StopContinuous()
        _soundemitter:KillSound("busy")
        inst:StopWatchingWorldState("phase", OnPhase)
        inst:StopWatchingWorldState("season", OnSeason)
        inst:StopWatchingWorldState("nightmarephase", OnNightmarePhase)
        _isday = nil
		_busytheme = nil
        _isbusydirty = nil
        _extendtime = nil
        _soundemitter = nil
		_hasinspirationbuff = nil
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerActivated(inst, player)
    if _activatedplayer == player then
        return
    elseif _activatedplayer ~= nil and _activatedplayer.entity:IsValid() then
        StopPlayerListeners(_activatedplayer)
    end
    _activatedplayer = player
    StopSoundEmitter()
    StartSoundEmitter()
    StartPlayerListeners(player)
	if continuous_mode then
		StartBusy(player)
	end
end

local function OnPlayerDeactivated(inst, player)
    StopPlayerListeners(player)
    if player == _activatedplayer then
        _activatedplayer = nil
        StopSoundEmitter()
    end
end

local function OnEnableDynamicMusic(inst, enable)
    if _isenabled ~= enable then
        if not enable and _soundemitter ~= nil then
            StopDanger()
            StopContinuous()
            _soundemitter:KillSound("busy")
            _isbusydirty = true
        end
		if enable and continuous_mode then
			_activatedplayer:DoTaskInTime(6, function(player)
				StartBusy(player)
			end)
		end
        _isenabled = enable
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("playeractivated", OnPlayerActivated)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
inst:ListenForEvent("enabledynamicmusic", OnEnableDynamicMusic)

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)