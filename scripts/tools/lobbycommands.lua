-- (c) CunningFox.
local prefix = "/"
local cd = 0

local cache = {}

function LobbyCommand(command, fn)
	if not command then
		print("ERROR: Command name can't be nil!", CalledFrom())
		return
	end
    cache[command] = fn
end

local _Networking_Say = Networking_Say
Networking_Say = function (guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if string.sub(message, 1, #prefix) == prefix then
		if TheNet:GetIsServer() then
			local command = string.sub(message, #prefix + 1)
			if cache[command] then
				cache[command](userid)
			end
		end
		return true
	end
	return _Networking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
end
