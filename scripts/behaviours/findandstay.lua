local CHECK_INTERVAL = 0.5

FindAndStay = Class(BehaviourNode, function(self, inst, safe_dist, targ_fn, run)
    BehaviourNode._ctor(self, "FindAndStay")
    self.inst = inst
    self.targ = nil
    self.targ_fn = targ_fn
	self.safe_dist = safe_dist
	self.run = run
    self.lastchecktime = 0
end)

function FindAndStay:DBString()
    return string.format("Stay near %s", tostring(self.targ))
end

function FindAndStay:Visit()
	if not self.inst or not self.inst:IsValid() then
		self.status = FAILED
		return
	end

    if self.status == READY then
        self:PickTarget()
        self.status = RUNNING
    end

    if self.status == RUNNING then
        if GetTime() - self.lastchecktime > CHECK_INTERVAL then
            self:PickTarget()
        end

        if not self.targ or not self.targ:IsValid() then
            self.status = FAILED
        else
            local actual_safe_dist = type(self.safe_dist) == "function" and self.safe_dist(self.inst, self.targ) or self.safe_dist or 5
            if self.inst:IsNear(self.targ, actual_safe_dist) then
                -- self.status = SUCCESS 
				self.inst:ForceFacePoint(self.targ.Transform:GetWorldPosition())
                self.inst.components.locomotor:Stop()
            else
                self.inst.components.locomotor:GoToPoint(self.inst:GetPositionAdjacentTo(self.targ, actual_safe_dist * 0.98), nil, self.run)
            end
        end
    end
end

function FindAndStay:PickTarget()
    self.targ = self.targ_fn(self.inst)
    self.lastchecktime = GetTime()
end
