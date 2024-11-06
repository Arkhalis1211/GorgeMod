local function CalculateVoteAmound(mode)
	local num = #TheNet:GetClientTable() - (TheNet:IsDedicated() and 1 or 0)
	--[[
	if CHEATS_ENABLED then
		return 1
	elseif num <= 2 then
		return 0
	end
	return num - (mode and 0 or 1)]]
	return math.floor(num * 0.5 + 0.5)
end

local Voter = Class(function(self, inst)
    self.inst = inst
	
	self.canvote = true
	self.kicks_pending = {}
	self.modes_pending = {}
	self.last_anounced = 0
	
	local function ClearAllVotes()
		if not self.canvote or not next(self.modes_pending) or not next(self.kicks_pending) then
			return
		end
		
		self.modes_pending = {}
		self.kicks_pending = {}
		
		-- Fox: There's something strange with networking...
		self.inst:DoTaskInTime(0, function()
			TheNet:SystemMessage(STRINGS.GORGE.VOTE.CLEARED)
		end)
	end
	
	local function ClearListeners(src, data)
		if not data.active then
			return
		end
		
		inst:RemoveEventCallback("ms_clientloaded", ClearAllVotes, TheWorld)
		inst:RemoveEventCallback("ms_clientdisconnected", ClearAllVotes, TheWorld)
		
		self.canvote = false
	end
	
    inst:ListenForEvent("ms_clientloaded", ClearAllVotes, TheWorld)
    inst:ListenForEvent("ms_clientdisconnected", ClearAllVotes, TheWorld)
	
	inst:ListenForEvent("lobbyplayerspawndelay", ClearListeners, TheWorld)
end)

function Voter:VoteKick(doer, target)
	if not self.canvote or not doer or not target then
		return
	end
	
	local data = {
		doer = TheNet:GetClientTableForUser(doer),
		target = TheNet:GetClientTableForUser(target),
	}
	
	if not self.kicks_pending[target] then
		self.kicks_pending[target] = {}
	elseif self.kicks_pending[target][doer] then
		return
	end
	
	self.kicks_pending[target][doer] = true
	
	local voted = GetTableSize(self.kicks_pending[target])
	local needed = CalculateVoteAmound()
	
	--[[if needed == 0 then
		if GetTime() - self.last_anounced > 5 then
			TheNet:SystemMessage(STRINGS.GORGE.VOTE.NO_PLAYERS)
			self.last_anounced = GetTime()
		end
	else]]if voted >= needed then
		TheNet:SystemMessage(STRINGS.GORGE.VOTE.PASSED)
		TheNet:Kick(target)
		self.kicks_pending[target] = nil
	else
		TheNet:SystemMessage(string.format(STRINGS.GORGE.VOTE.VOTED, data.doer.name, data.target.name, voted, needed))
	end
end

function Voter:VoteForMode(doer, id)
	if not self.canvote or not doer or not id then
		return
	end
	
	if doer.admin then
		self.modes_pending = {
			[doer.userid] = id,
		}
		self:CalculateNewMode()
	else
		if self.modes_pending[doer.userid] then
			return
		end
	
		self.modes_pending[doer.userid] = id
		
		local voted = GetTableSize(self.modes_pending)
		local needed = CalculateVoteAmound()
		if needed == 0 then
			if GetTime() - self.last_anounced > 5 then
				TheNet:SystemMessage(STRINGS.GORGE.VOTE.NO_PLAYERS)
				self.last_anounced = GetTime()
			end
			return
		else
			TheNet:SystemMessage(string.format(STRINGS.GORGE.VOTE.MODE_VOTED, doer.name, STRINGS.GORGE.GAMEMODES.NAMES[id] or "ERROR", voted, needed))
		end
		
		if voted >= needed then
			self:CalculateNewMode()
		end
	end
end

function Voter:CalculateNewMode()
	if not self.canvote then
		return
	end
	
	local voted = {}
	for _, id in pairs(self.modes_pending) do
		voted[id] = (voted[id] or 0) + 1
	end
	
	local saved = 0
	local mode
	for id, n in pairs(voted) do
		if n > saved then
			saved = n
			mode = id
		end
	end
	
	if not mode then
		return
	end
	
	TheNet:SystemMessage(string.format(STRINGS.GORGE.VOTE.MODE_CHANGED, STRINGS.GORGE.GAMEMODES.NAMES[mode or "default"] or "ERROR"))
	
	self.modes_pending = {}
	self.canvote = false
	
	self.inst:DoStaticTaskInTime(5, function()
		TheWorld.components.quagmire:ChangeMode(mode)
	end)
end

return Voter