require("entityscript")

-- Use this is you want to handle event only 1 time
function EntityScript:ListenForNextEvent(event, fn, source)
	local function cached(...)
		self:RemoveEventCallback(event, cached, source)
		return fn(...)
	end
	self:ListenForEvent(event, cached, source)
end

local _requireeventfile = requireeventfile
requireeventfile = function(path)
	local s, e = path:find("_event_server")
	if e then
		local fixedpath = "gorge_data".. path:sub(e + 1)
		if softresolvefilepath("scripts/"..fixedpath..".lua") ~= nil then
			return require(fixedpath)
		end
	end
	return _requireeventfile(path)
end

function HasEventData(prefab)
	return softresolvefilepath("scripts/gorge_data/prefabs/"..prefab..".lua")
end

function GetListener(inst, event, source, offset)
	return inst.event_listeners[event][source or inst][offset or 1]
end

function GetGorgeGameMode()
	return Settings.gorge_game_mode or (TheWorld and TheWorld.net and #TheWorld.net._gamemode:value() > 0) and TheWorld.net._gamemode:value() or "default"
end

function GetGorgeGameModeProperty(property)
	if TUNING.GORGE.GAME_MODES[GetGorgeGameMode()] then
		return TUNING.GORGE.GAME_MODES[GetGorgeGameMode()][property]
	end
	print("[Gorge] Critical error: corrupt game mode:", GetGorgeGameMode(), CalledFrom())
end

GetActiveFestivalEventStatsFilePrefix = function()
	return "regorge"
end

math.round = function(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function SetDirty(netvar, val)
	netvar:set_local(val)
	netvar:set(val)
end

if not TheNet:GetIsServer() then
	return
end

--Fox: Well, we can't find out when client loaded, I believe
local _Networking_JoinAnnouncement = Networking_JoinAnnouncement
function Networking_JoinAnnouncement(...)
	if TheWorld and TheWorld:IsValid() then
		TheWorld:PushEvent("ms_clientloaded")
	end
	return _Networking_JoinAnnouncement(...)
end

-- Fox: Save our game mode
local _SimReset = SimReset
SimReset = function(data, ...)
	if not data then
		data = {}
	end
	if not data.gorge_game_mode then
		data.gorge_game_mode = GetGorgeGameMode()
	end
	return _SimReset(data, ...)
end
