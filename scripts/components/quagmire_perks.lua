local PerksData = require "gorge_perks"
local UserCommands = require "usercommands"

local Perks = Class(function(self, inst)
    self.inst = inst
	
	self.cache = {}
	
	inst:ListenForEvent("ms_clientdisconnected", function(w, data)
		if not data or not data.userid then
			return
		end
		
		self.cache[data.userid] = nil
	end, TheWorld)
	
	
	inst:ListenForEvent("ms_playerspawn", function(w, player)
		player:DoTaskInTime(0, function()
			self:PlayerSpawned(player)
		end)
	end)
end)

function Perks:SetPerk(userid, character, perk)
	perk = tonumber(perk)
	
	if perk == 1 then
		self.cache[userid] = nil
	else
		self.cache[userid] = perk
	end
	
	self:Sync()
end

-- Fox: Keep in mind that all changes will be called AFTER init.
function Perks:PlayerSpawned(inst)
	if not self.cache[inst.userid] or self.cache[inst.userid] <= 1 then
		return
	end
	
	local perk = self.cache[inst.userid]
	
	if PerksData[inst.prefab] and PerksData[inst.prefab][perk] then
		PerksData[inst.prefab][perk](inst)
	else
		print("ERROR: Tried to use not existing perk!", inst.prefab, perk)
	end
end

function Perks:Sync()
	if self.inst.net then
		self.inst.net:SyncPerks(self.cache)
	end
end

return Perks