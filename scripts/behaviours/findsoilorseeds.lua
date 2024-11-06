local SEE_DIST = 20

local genericfollowposfn = function(inst) return inst:GetPosition() end

FindSoilOrSeeds = Class(BehaviourNode, function(self, inst, action, getfollowposfn, validplantfn, type)
    BehaviourNode._ctor(self, "FindSoilOrSeeds")
    self.inst = inst
    self.action = action
    self.getfollowposfn = getfollowposfn or genericfollowposfn
    self.validplantfn = validplantfn or nil
    self.type = type or nil
end)

local function IsNearFollowPos(self, plant)
    local followpos = self.getfollowposfn(self.inst)
    local plantpos = plant:GetPosition()
    return distsq(followpos.x, followpos.z, plantpos.x, plantpos.z) < SEE_DIST * SEE_DIST
end

function FindSoilOrSeeds:DBString()
    return string.format("Go to plant or soil %s", tostring(self.inst.planttarget))
end

function FindSoilOrSeeds:Visit()
    if self.status == READY then
        self:PickTarget()
        if self.inst.planttarget then
			local action = BufferedAction(self.inst, self.inst.planttarget, self.action, nil, nil, nil, 0.1)
			self.inst.components.locomotor:PushAction(action, self.shouldrun)
			self.status = RUNNING
		else
			self.status = FAILED
        end
    end
    if self.status == RUNNING then
        local plant = self.inst.planttarget
        if not plant or not plant:IsValid() or not IsNearFollowPos(self, plant) or
        not (self.validplantfn == nil or self.validplantfn(self.inst, plant)) then
            self.inst.planttarget = nil
            self.status = FAILED
        --we don't need to test for the component, since we won't ever set clostest plant to anything that lacks that component
        else
            self.inst.planttarget = nil
            self.status = SUCCESS
        end
    end
end

local NOTAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt", "player", "monster" }
local ONEOFTAGS = { "plantedsoil", "edible_SEEDS" , "soil" }
function FindSoilOrSeeds:PickTarget()
    self.inst.planttarget = FindEntity(self.inst, SEE_DIST, function(plant)
        return IsNearFollowPos(self, plant) and (self.validplantfn == nil or self.validplantfn(self.inst, plant))
    end, nil, NOTAGS, ONEOFTAGS)
end
