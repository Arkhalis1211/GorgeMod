--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ MurderMysteryManager class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Private constants ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------
local _activeplayers = {}
local _murderplayer = nil
local canvote = true
local playersvoted = 0
--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------
local function CalculateVoteAmount()
	local num = #_activeplayers
	return math.floor(num * 0.5 + 0.5)
end

local function GetPlayerFromClientTable(c)
    for _, v in ipairs(AllPlayers) do
        if v.userid == c.userid then
            return v
        end
    end
end

local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
	if not player.components.health and player.components.health:IsDead() then
		table.insert(_activeplayers, player)
	end
    local light = SpawnPrefab("quagmire_playerlight")

    if light then
        light:SetTarget(player)
    end

    if player == TheWorld.net._murder:value() then        
		TheWorld.net._murder:set(_murderplayer)
		if not player.components.quagmire_cd then
			player:AddComponent("quagmire_cd")
			player.components.quagmire_cd:StartCD(TUNING.GORGE.MURDERER_CD)
		end
        player:AddTag("quagmire_murderplayer")
        if player._mmlight then player._mmlight:SetType("murder") end
    else
        player:AddTag("quagmire_innocentplayer")
        if player._mmlight then player._mmlight:SetType("innocent") end
    end   
	if TheWorld.net._mmvotetime:value() > 0  then
		local pos = TheWorld.spawnportal:GetPosition()
		local angle = math.pi * math.random()
		local range = 1.5
		if player.Physics then
			player.Physics:Teleport(pos.x + math.cos(angle) * range, 0, pos.z - math.sin(angle) * range)
		else
			player.Transform:SetPosition(pos.x + math.cos(angle) * range, 0, pos.z - math.sin(angle) * range)
		end
		player:ForceFacePoint(pos.x, 0, pos.z)	
	end
end

local function DropCoins(inst, pos)
	for i = 1, 2 do
		inst:DoTaskInTime(i * 4/10, function()
			local coin = SpawnPrefab("quagmire_coin4")

			local angle = math.pi * 2 * math.random()
			local range = math.max(2.5 * math.random(), 1)
			coin.Transform:SetPosition(pos.x + math.cos(angle) * range, 0, pos.z + math.sin(angle) * range)

			coin:Fall()
		end)
	end
end

local function OnPlayerLeft(src, player)
	for i, v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            if player == self:GetMurder() then
				local pos = TheWorld.altar:GetPosition()
				self.inst:DoTaskInTime(0.2, function()
					DropCoins(self.inst, pos)
				end)				
            end
        end
	end

	if #_activeplayers < 3 then
		for i, v in ipairs(_activeplayers) do
			if v.player_classified._votebutton:value() then
				v.player_classified._votebutton:set(false)
			end
		end
		TheWorld.spawnportal._camerafocus:set(false)
		self.inst:DoTaskInTime(1, function()
			TheWorld.components.quagmire:BadEnding()
		end)
	end
end

local function OnAllPlayersSpawned(src)
    local murderindex = math.random(1, #AllPlayers)
    _murderplayer = AllPlayers[murderindex]
	TheWorld.net._murder:set(_murderplayer)
	TheWorld:DoTaskInTime(0.1, function()
		for i, v in ipairs(AllPlayers) do
			table.insert(_activeplayers, v)
		end
	end)
end

function self:GetVotesCount(target)
	return GetPlayerFromClientTable(TheNet:GetClientTableForUser(target))._votecount:value() or 0
end

function self:SkipVote(doer)
	if not canvote or not doer then
		return
	end
	if not self:IsVoted(doer) and not self:IsSkipped(doer) then
		GetPlayerFromClientTable(TheNet:GetClientTableForUser(doer))._isskippedvote:set(true)
		TheWorld.net._skippedvotes:set(TheWorld.net._skippedvotes:value()+1)
	else
		return
	end
	playersvoted = playersvoted + 1
	if playersvoted == #_activeplayers then
		self:EndVoting()
	end
end

function self:VoteKick(doer, target)
	if not canvote or not doer or not target then
		return
	end
	
	local data = {
		doer = TheNet:GetClientTableForUser(doer),
		target = TheNet:GetClientTableForUser(target),
	}
	
	if GetPlayerFromClientTable(data.doer) and GetPlayerFromClientTable(data.target) 
		and not self:IsVoted(doer) and not self:IsSkipped(doer) then
		GetPlayerFromClientTable(data.doer)._isvoted:set(true)
		GetPlayerFromClientTable(data.target)._votecount:set(GetPlayerFromClientTable(data.target)._votecount:value()+1)
		playersvoted = playersvoted + 1
		if playersvoted == #_activeplayers then
			self:EndVoting()
		end
	else
		return
	end

	local voted = self:GetVotesCount(target)
	local needed = CalculateVoteAmount()
	if voted >= needed then 
		local player = GetPlayerFromClientTable(data.target)
		player.components.health.invincible = false
		player.components.health:Kill()
		if player.player_classified._votebutton:value() then
			player.player_classified._votebutton:set(false)
		end
		OnPlayerLeft(self.inst, player)
		self:EndVoting()
	end

	if playersvoted == #_activeplayers then
		self:EndVoting()
	end
end

function self:StartVoting(vtime)
	TheWorld.net._mmvotetime:set(vtime)
	if self:GetMurder() then
		if self:GetMurder().components.quagmire_cd then
			self:GetMurder().components.quagmire_cd:StopCD()
		end
	end
	self.inst.votetask = self.inst:DoPeriodicTask(1, function()
		TheWorld.net._mmvotetime:set(TheWorld.net._mmvotetime:value() - 1)
		if TheWorld.net._mmvotetime:value() <= 0 then
			if self.inst.votetask then
				self.inst.votetask:Cancel()
				self:EndVoting()
			end
		end
	end)
end

function self:EndVoting()
	playersvoted = 0
	if self.inst.votetask then
		self.inst.votetask:Cancel()
	end
	if self:GetMurder() then
		if self:GetMurder().components.quagmire_cd then
			self:GetMurder().components.quagmire_cd:ResumeCD()
		end
	end
	for i, v in ipairs(_activeplayers) do
		v:SetCameraDistance(15)
		if v.components.playercontroller ~= nil then
			v.components.playercontroller:EnableMapControls(true)
			v.components.playercontroller:Enable(true)
		end
		v:ShowActions(true)
		if v.player_classified._votebutton:value() then
			v.player_classified._votebutton:set(false)
		end
		v._isskippedvote:set(false)
		v._isvoted:set(false)
		v._votecount:set(0)
	end
	TheWorld.spawnportal._camerafocus:set(false)
	TheWorld.net.components.quagmire_hangriness:Start(1)
	TheWorld.net._mmvotetime:set(0)
	TheWorld.net._skippedvotes:set(0)
end

function self:Report(reporter)
	local count = #_activeplayers
	local pos = TheWorld.spawnportal:GetPosition()
	for i, v in ipairs(_activeplayers) do
		local player = GetPlayerFromClientTable(v)
		player:ScreenFade(false, 1)
		player:DoTaskInTime(1, function()
			player:ScreenFade(true, 1)
			player.player_classified._votebutton:set(true)
			player:SetCameraDistance(11)
			if player.components.playercontroller ~= nil then
				player.components.playercontroller:EnableMapControls(false)
				player.components.playercontroller:Enable(false)
			end
			player:ShowActions(false)	

			local angle = math.pi * 1.5 * i / count
			local range = 3

			if player.Physics then
				player.Physics:Teleport(pos.x + math.cos(angle) * range, 0, pos.z - math.sin(angle) * range)
			else
				player.Transform:SetPosition(pos.x + math.cos(angle) * range, 0, pos.z - math.sin(angle) * range)
			end
			player:ForceFacePoint(pos.x, 0, pos.z)
		end)
	end
	self:StartVoting(60)
	self.inst:DoTaskInTime(1, function()
		TheWorld.spawnportal._camerafocus:set(true)
	end)
	TheWorld.net.components.quagmire_hangriness:Start(0)
end

function self:GetMurder()
	return _murderplayer or TheWorld.net._murder:value()
end

function self:GetTimeVoteInfo()
	return TheWorld.net._mmvotetime:value()
end

function self:IsVoted(doer)
	return GetPlayerFromClientTable(TheNet:GetClientTableForUser(doer))._isvoted:value() == true
end

function self:IsSkipped(doer)
	return GetPlayerFromClientTable(TheNet:GetClientTableForUser(doer))._isskippedvote:value() == true
end

function self:GetSkippedCount()
	return TheWorld.net._skippedvotes:value()
end

function self:CountPlayers()
	return #_activeplayers
end

function self:GetCDInfo()
	local str = STRINGS.GORGE.MMMURDER
	local murder = self:GetMurder()
	if murder and murder.components.quagmire_cd then
		local cd = murder.components.quagmire_cd:GetCD()
		if cd > 0 then
			str = str .. string.format("\n"..STRINGS.GORGE.COOLDOWN, str_seconds(cd))
		end
		return str
	end
	return str
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

self.inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
self.inst:ListenForEvent("quagmire_playerkilled", OnPlayerLeft, TheWorld)
self.inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)
self.inst:ListenForEvent("quagmire_allplayersspawned", OnAllPlayersSpawned, TheWorld)

end)
