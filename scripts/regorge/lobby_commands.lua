local menv = env
GLOBAL.setfenv(1, GLOBAL)

local UpvalueHacker = require("tools/upvaluehacker")
local UserCommands = require("usercommands")

require("tools/lobbycommands")

menv.AddComponentPostInit("worldcharacterselectlobby", function(self)
	self.emotedata = net_string(self.inst.GUID, "worldcharacterselectlobby._emote", "emotedirty")
	
	if TheNet:GetIsServer() then
		-- Fox: Well, we're in lobby, so performance doesn't really matter, right?
		self.emotes = {}
		local emoteid = 0
		function self:DoEmote(id, name, data)
			-- print("******************DoEmote", CalledFrom())
			if not self:CanPlayersSpawn() then
				emoteid = emoteid + 1
				
				self.emotes[id] = {
					name = name,
					id = emoteid,
				
					emote = data.emote,
					loop = data.loop,
					randomanim = data.randomanim,
					sounddelay = data.sounddelay,
					soundoverride = data.soundoverride,
					soundlooped = data.soundlooped,
				}
				
				-- print("SENDING EMOTE")
				for k, v in pairs(self.emotes) do
					printwrap(k, v)
				end
				
				local _data = DataDumper(self.emotes)
				SetDirty(self.emotedata, _data)
			end
		end
		
		self.inst:ListenForNextEvent("lobbyplayerspawndelay", function()
			self.emotes = {}
			self.emotedata:set("")
		end, TheWorld)
	end
	
	if not TheNet:IsDedicated() then
		self._cachedemotes = {}
		
		local function SyncEmotes()
			local val = self.emotedata:value()
			if #val > 0 then
				local new = loadstring(val)()
				if new and new ~= self._cachedemotes then
					for userid, data in pairs(new) do
						if data ~= self._cachedemotes[userid] then
							data.t = GetTime()
						end
					end
				end
				self._cachedemotes = new or {}
				TheWorld:PushEvent("player_emote")
				-- print("PUSHING player_emote")
				-- for k, v in pairs(self._cachedemotes) do
					-- printwrap("k", v)
				-- end
			else
				self._cachedemotes = {}
			end
		end
		
		self.inst:ListenForEvent("emotedirty", SyncEmotes)
		
		function self:GetEmote(id)
			return self._cachedemotes and self._cachedemotes[id]
		end
		
		self.inst:DoStaticTaskInTime(0, SyncEmotes)
	end
end)
	
AddUserCommand("gorge_power", {
	permission = COMMAND_PERMISSION.USER,
	slash = false,
	usermenu = false,
	servermenu = false,
	params = {"char", "power"},
	vote = false,
	serverfn = function(params, caller)
		if GORGE_SETTINGS.PERKS_ENABLED and not TheWorld and not params.char or not params.power then
			return
		end
		TheWorld.components.quagmire_perks:SetPerk(caller.userid, params.char, params.power)
	end,
})

AddUserCommand("endmatch", {
    aliases = {"defeat","finishmatch","fm","fem","forcend","forcematchend"},
    permission = COMMAND_PERMISSION.ADMIN,
    slash = false,
    usermenu = false,
    servermenu = false,
    params = {},
    vote = false,
	serverfn = function(params, caller)
		if GORGE_SETTINGS.FEM_ENABLED and not TheWorld then
			return
		end
		TheWorld.components.quagmire:BadEnding()
	end,
})

AddUserCommand("lobbyvote", {
    permission = COMMAND_PERMISSION.USER,
    slash = false,
    usermenu = false,
    servermenu = false,
    params = {"cmd", "data"},
    vote = false,
    serverfn = function(params, caller)
		if not TheWorld then
			return
		end
	
		if params.cmd == "kick" then
			TheWorld.net.components.gorge_voter:VoteKick(caller.userid, params.data)
		elseif params.cmd == "mode" then
			TheWorld.net.components.gorge_voter:VoteForMode(caller, params.data)
		end
    end,
})

AddUserCommand("mmkick", {
    permission = COMMAND_PERMISSION.USER,
    slash = false,
    usermenu = false, -- automatically supplies the username as a param called "user"
    servermenu = false,
    params = {"user", "cmd"},
    vote = false,
    serverfn = function(params, caller)
		if not TheWorld and not TheWorld.net then
			return
		end
		if params.cmd == "vote" then
			TheWorld.net.components.quagmire_murdermysterymanager:VoteKick(caller.userid, params.user)
		elseif params.cmd == "skip" then
			TheWorld.net.components.quagmire_murdermysterymanager:SkipVote(caller.userid)		
		end
    end,
})

if not TheNet:GetIsServer() then
	return
end

function MakeLobbyEmote(name, data, item_type)
	LobbyCommand(name, function(id)
		if TheWorld ~= nil and TheWorld.net ~= nil and TheWorld.net.components.worldcharacterselectlobby ~= nil
		and not TheWorld.net.components.worldcharacterselectlobby:CanPlayersSpawn() then
			if not item_type or TheInventory:CheckClientOwnership(id, item_type) then -- Fox: So Klei won't ban our mod
				TheWorld.net.components.worldcharacterselectlobby:DoEmote(id, name, data)
			end
		end
	end)
end

-- Fox: Well, they left no other choice... This is going to be ugly as hell
local _AddUserCommand = AddUserCommand
function AddUserCommand(name, data, ...)
	if data.emote then
		local emotedef = UpvalueHacker.GetUpvalue(data.serverfn, "emotedef")
		if emotedef then
			local def_data = emotedef.data or {}
			local emote_data = {
				emote = def_data.anim,
				loop = def_data.loop,
				randomanim = def_data.randomanim,
				sounddelay = def_data.sounddelay,
				soundoverride = def_data.soundoverride,
				soundlooped = def_data.soundlooped,
			}
			
			if emotedef.aliases then
				for i, alias in ipairs(emotedef.aliases) do
					MakeLobbyEmote(alias, emote_data, def_data.item_type)
				end
			end
			MakeLobbyEmote(emotedef.cmd_name or name, emote_data, def_data.item_type)
		end
	end
	return _AddUserCommand(name, data, ...)
end

MakeLobbyEmote("idle", {emote = "idle"})

if KnownModIndex:IsModEnabled("workshop-727057103") then
	MakeLobbyEmote("dab", {emote = "emote_dab_pre"})
end

if KnownModIndex:IsModEnabled("workshop-1637709131") then
	MakeLobbyEmote("default", {emote = "defaultdance"})
end