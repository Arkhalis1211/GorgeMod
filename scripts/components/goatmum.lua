local FNS = require "goatmum_state_fns"

local function shop_changed(self, val)
	self.inst:PushEvent("shop_changed", val)
end

local function GetStateName(state)
	for name, val in pairs(GOATMUM_STATES) do
		if val == state then
			return name
		end
	end
	return "INVALID"
end

local GoatMum = Class(function(self, inst)
    self.inst = inst
	
	self.state = GOATMUM_STATES.IDLE
	
	self.talker = inst.components.talker
	
	self.portal = nil
	self.gameresult = nil
	self.firstpurchase = true
	self.intro_speech = true
	self.scared = nil
	self.badending = false
	
	self.shop_active = false
	
	self.updatefn = nil
	
	self.inst:ListenForEvent("ms_portalactivate", function()
		inst:StartUpdatingComponent(self)
	end, TheWorld)
	
	self.inst:ListenForEvent("ms_cravingchanged", function(src, data)
		self.inst:PushEvent("cravingchanged", data)
	end, TheWorld)
	
	self.inst:ListenForEvent("ms_gameend", function(w, result)
		self.gameresult = result
	end, TheWorld)
	
	self.inst:ListenForEvent("ms_quagmirerecipeappraised", function(w, data)
		local craving = TheWorld.components.quagmire:GetCraving()
		if craving then
			self.inst:PushEvent("snackrificed", {satisfied = data.matched, craving = string.upper(craving)})
		end
	end, TheWorld)
	
	if CHEATS_ENABLED then
		rawset(_G, "mumsystate", function(state) --mumsystate(4)
			if self.task then
				self.task:Cancel()
				self.task = nil
			end
			self.debugstate = state
		end)
	end
end,
nil,
{
	shop_active = shop_changed,
})

function GoatMum:WelcomeSpeech()
	local i = 0
	local function speechfn()
		i = i + 1
		
		self.talker:Chatter("GOATMUM_WELCOME_INTRO", i, 2.5)
		
		if i >= #STRINGS.GOATMUM_WELCOME_INTRO then
			if self.task then
				self.task:Cancel()
				self.task = nil
			end
			
			self.inst:DoTaskInTime(2.5, function()
				self.intro_speech = nil
			end)
		else
			self.task = self.inst:DoTaskInTime(2.5, speechfn)
		end
	end
	
	speechfn()
end

function GoatMum:GetState()
	return self.state
end

-- Fox: so... if we concat string we can't use Chatter, so we'll use Say instead.
-- Localization mods should do translation on their side
function GoatMum:SayTip()
	if TheWorld.altar.sg:HasStateTag("full") or self.inst.sg:HasStateTag("talk") or
	self.inst.sg:HasStateTag("busy") or self.inst.sg:HasStateTag("running") or
	self:GetState() ~= GOATMUM_STATES.IDLE then
		return
	end
	
	if self.craving_task then
		self.craving_task:Cancel()
	end
	
	self:AnnounceTip()
	self.craving_task = self.inst:DoTaskInTime(5, function()
		self:AnnounceCraving()
	end)
end

function GoatMum:AnnounceTip()
	local str = self.scared and "GOATMUM_TALK_GREETING_URGENT" or "GOATMUM_TALK_GREETING"
	self.talker:Chatter(str, math.random(1, #STRINGS[str]))
end

function GoatMum:AnnounceCraving()
	local craving = TheWorld.components.quagmire:GetCraving()
	if not craving then
		return
	end
	local p2str = "GOATMUM_CRAVING_HINTS_PART2" .. (self.scared and "_IMPATIENT" or "")
	self.talker:Say(subfmt(STRINGS.GOATMUM_CRAVING_HINTS[math.random(#STRINGS.GOATMUM_CRAVING_HINTS)],
	{
		craving = STRINGS.GOATMUM_CRAVING_MAP[string.upper(craving)],
		part2 = STRINGS[p2str][math.random(#STRINGS[p2str])],
	}))
	
	self.craving_task= nil
end

function GoatMum:OnUpdate(dt)
	local _state = self.state
	local state = GOATMUM_STATES.IDLE
	
	if self.debugstate then
		state = self.debugstate
	elseif self.gameresult then
		if self.gameresult == 1 then
			state = GOATMUM_STATES.GAMEWON
		else
			state = GOATMUM_STATES.GAMELOST
		end
	elseif self.portal then
		state = GOATMUM_STATES.START
	elseif self.intro_speech then
		state = GOATMUM_STATES.WELCOME
	elseif self.firstpurchase then
		state = GOATMUM_STATES.WAIT_FOR_PURCHASE
	elseif TheWorld.altar.sg:HasStateTag("full") then
		state = GOATMUM_STATES.SNACKRIFICE
	end
	
	self.scared = TheWorld.net.components.quagmire_hangriness:GetLevel() > 2
	
	if state ~= _state then
		self.state = state
		
		if FNS[_state] and FNS[_state].stop then
			FNS[_state].stop(self)
		end
		
		if FNS[self.state] and FNS[self.state].start then
			FNS[self.state].start(self)
		end
		
		self.inst:PushEvent("mum_state_changed", {mumstate = state})
	end
	
	if self.updatefn then
		self.updatefn(dt)
	end
end

function GoatMum:GetDebugString()
	return string.format("state: %s", GetStateName(self.state))
end

return GoatMum