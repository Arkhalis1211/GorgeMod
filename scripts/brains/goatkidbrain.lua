require "behaviours/wander"
require "behaviours/faceentity"

local MAX_WANDER_DIST = 25

local function GetLeashPos(inst)
    return inst.components.knownlocations:GetLocation("home") or nil
end

local function KeepFaceTarget(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, 4)
end

local function GetFaceTarget(inst)
	local target = FindClosestPlayerToInst(inst, 4, true)
	return target ~= nil and not target:HasTag("notarget") and target or nil
end

local GoatKidBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function GoatKidBrain:OnStart()
	local root =

	PriorityNode(
	{
		WhileNode(function() return self.inst.sg.mem.ending end, "Standing", StandStill(self.inst)),
        FaceEntity(self.inst, GetFaceTarget, KeepFaceTarget),
		Wander(self.inst, GetLeashPos, MAX_WANDER_DIST, {
			minwalktime = 2,
			randwalktime = 2.5,
			minwaittime = 2,
			randwaittime = 3,
		},
		nil, nil, function(pos)
			-- local tile = 
			return true
		end)
	}, 0.5)
	self.bt = BT(self.inst, root)
end

return GoatKidBrain
