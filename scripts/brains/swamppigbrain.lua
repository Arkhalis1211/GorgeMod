require "behaviours/wander"
require "behaviours/faceentity"

local MAX_WANDER_DIST = 15

local function GetHome(inst)
    return inst.components.knownlocations:GetLocation("home") or nil
end

local function KeepFaceTarget(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, 4)
end

local function GetFaceTarget(inst)
	local target = FindClosestPlayerToInst(inst, 4, true)
	return target ~= nil and not target:HasTag("notarget") and target or nil
end

local SwampPigBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function SwampPigBrain:OnStart()
	local root =

	PriorityNode(
	{
        FaceEntity(self.inst, GetFaceTarget, KeepFaceTarget),
		Wander(self.inst, GetHome, MAX_WANDER_DIST)
	}, 0.5)
	self.bt = BT(self.inst, root)
end

return SwampPigBrain
