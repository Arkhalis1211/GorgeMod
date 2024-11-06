require "behaviours/leashandavoid"
require "behaviours/findsoilorseeds"
require "behaviours/findtile"

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 3
local TARGET_FOLLOW_DIST = 2

local SmallSpiderBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetLeadersPos(inst)
	return inst.components.follower.leader and inst.components.follower.leader:GetPosition()
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetFollowPos(inst)
    return GetLeadersPos(inst) or
        inst:GetPosition()
end

local function IsValidPlant(inst, plant)
    if not plant then
        return false
    end

    if inst:HasTag("fertilizer") then
        if inst:HasTag("tired") then
            return false
        end
        if plant.components.quagmire_crop and plant.components.quagmire_crop.tempboost < 1 then
            return true
        end
    elseif inst:HasTag("harvester") then
        if plant.components.inventoryitem then
            if inst.components.inventory:IsFull() and inst.components.inventory:Has(plant.prefab, 1) or 
                not inst.components.inventory:IsFull() then
                return true
            end
        elseif plant:HasTag("soil") then
            if inst:HasTag("tired") then
                return false
            end
            if inst.components.inventory:NumItems() > 0 then
                return true
            end
        end
    elseif inst:HasTag("tiller") then
        return false
    end
    return false
end

function SmallSpiderBrain:OnStart()
    local speed = self.inst:HasTag("tiller") and 1 or 0.25 -- 0.5
	local root = PriorityNode({
        FindSoilOrSeeds(self.inst, ACTIONS.INTERACT_WITH, GetFollowPos, IsValidPlant),
        FindTile(self.inst, ACTIONS.INTERACT_WITH),
		Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
		IfNode(function() return self.inst.components.follower.leader ~= nil end, "HasLeader", FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),
    }, speed)

    self.bt = BT(self.inst, root)
end

return SmallSpiderBrain