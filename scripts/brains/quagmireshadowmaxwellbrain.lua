require "behaviours/leash"
require "behaviours/findandstay"

local LEASH_RETURN_DIST = 5
local LEASH_MAX_DIST = 12
local UPDATE_PERIOD = 0.25

local ShadowMaxwellBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetHomePos(inst)
    return inst.book and inst.book:GetPosition()
end

local function FindEntityToWorkAction(inst)
	if inst.book and not inst.sg:HasStateTag("jumping") then
		local tree = FindEntity(inst.book, TUNING.GORGE.CHARACTERS.MAXWELL_TREES_DIST, nil, {"CHOP_workable"}, {"stump"})
		
		if not tree and inst:IsNear(inst.book, 2) then
			inst.despawn_time = (inst.despawn_time or 0) + UPDATE_PERIOD
		end
		
		if inst.despawn_time and inst.despawn_time >= 3 then
			inst:Kill()
		end
		
		return tree ~= nil and BufferedAction(inst, tree, ACTIONS.CHOP) or nil
	end
end


function ShadowMaxwellBrain:OnStart()
    local root = PriorityNode(
    {
        -- Leash(self.inst, GetHomePos, LEASH_MAX_DIST, LEASH_RETURN_DIST),
		DoAction(self.inst, function() return FindEntityToWorkAction(self.inst) end),
		WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "StayNearBook", 
			FindAndStay(self.inst, 1, function() return self.inst.book end, true)),
    }, UPDATE_PERIOD)

    self.bt = BT(self.inst, root)
end

return ShadowMaxwellBrain
