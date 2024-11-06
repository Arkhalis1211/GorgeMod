require "behaviours/wander"
require "behaviours/faceentity"

local AVOID_PLAYER_DIST = 8
local AVOID_PLAYER_STOP = 16

local MAX_WANDER_DIST = 8
local LEASH_RETURN_DIST = 6

local SOLO_START_FACE_DIST = 2
local SOLO_KEEP_FACE_DIST = 4

local function GetLeashPos(inst)
	return inst.components.knownlocations:GetLocation("home") or nil
end

local function GetNonHerdingFaceTargetFn(inst)
	return FindClosestPlayerToInst(inst, SOLO_START_FACE_DIST, true)
end

local function KeepNonHerdingFaceTargetFn(inst, target)
	return not target:HasTag("notarget")
		and inst:IsNear(target, SOLO_KEEP_FACE_DIST)
end

local SwampPigBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function SwampPigBrain:OnStart()
	local root =

	PriorityNode(
	{
		RunAway(self.inst, "killer", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),
		FaceEntity(self.inst, GetNonHerdingFaceTargetFn, KeepNonHerdingFaceTargetFn),
		Leash(self.inst, GetLeashPos, MAX_WANDER_DIST, LEASH_RETURN_DIST),
		WhileNode(function() return not self.inst.sg:HasStateTag("busy") end, "Wandering",
			Wander(self.inst, GetLeashPos, MAX_WANDER_DIST))
	}, 0.5)
	self.bt = BT(self.inst, root)
end

return SwampPigBrain
