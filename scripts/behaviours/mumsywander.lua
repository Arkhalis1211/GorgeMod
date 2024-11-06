MumsyWander = Class(BehaviourNode, function(self, inst, homelocation, max_dist, times, getwalkpos)
    BehaviourNode._ctor(self, "MumsyWander")
    self.homepos = homelocation
    self.maxdist = max_dist
    self.inst = inst
    self.far_from_home = false

    self.getwalkpos = getwalkpos

    self.times =
    {
        minwalktime = times and times.minwalktime or 2,
        randwalktime = times and times.randwalktime or 3,
        minwaittime = times and times.minwaittime or 1,
        randwaittime = times and times.randwaittime or 3,
    }
end)


function MumsyWander:Visit()
    if self.status == READY then
        self.inst.components.locomotor:Stop()
        self:Wait(self.times.minwaittime+math.random()*self.times.randwaittime)
        self.walking = false
        self.status = RUNNING
    elseif self.status == RUNNING then
        if not self.walking and self:IsFarFromHome() then
            self:PickNewDirection()
        end

        if GetTime() > self.waittime then
            if not self.walking then
                self:PickNewDirection()
            else
                self:HoldPosition()
            end
        else
            if not self.walking then
                self:Sleep(self.waittime - GetTime())
            else
                if not self.inst.components.locomotor:WantsToMoveForward() then
                    self:HoldPosition()
                end
            end
        end
    end
end

local function tostring_float(f)
    return f and string.format("%2.2f", f) or tostring(f)
end

function MumsyWander:DBString()
    local w = self.waittime - GetTime()
    return string.format("%s for %2.2f, %s, %s, %s",
        self.walking and 'walk' or 'wait',
        w,
        tostring(self:GetHomePos() or false),
        tostring_float(math.sqrt(self:GetDistFromHomeSq() or 0)),
        self.far_from_home and "Go Home" or "Go Wherever")
end

function MumsyWander:GetHomePos()
    if type(self.homepos) == "function" then 
        return self.homepos(self.inst)
    end

    return self.homepos
end

function MumsyWander:GetDistFromHomeSq()
    local homepos = self:GetHomePos()
    return homepos and distsq(homepos, self.inst:GetPosition()) or nil
end

function MumsyWander:IsFarFromHome()
    local homedistsq = self:GetDistFromHomeSq()
    return homedistsq ~= nil and homedistsq > self:GetMaxDistSq()
end

function MumsyWander:GetMaxDistSq()
    if type(self.maxdist) == "function" then
        local dist = self.maxdist(self.inst)
        return dist*dist
    end

    return self.maxdist*self.maxdist
end

function MumsyWander:Wait(t)
    self.waittime = t+GetTime()
    self:Sleep(t)
end

function MumsyWander:PickNewDirection()
    self.far_from_home = self:IsFarFromHome()

    self.walking = true

    if self.far_from_home or not self.getwalkpos then
        self.inst.components.locomotor:GoToPoint(self:GetHomePos())
    else
		-- Fox: well, that's ugly, but works fine
		local pos = self.getwalkpos(self.inst)
		if pos then
			self.inst.components.locomotor:GoToPoint(pos)
		end
    end

    self:Wait(self.times.minwalktime+math.random()*self.times.randwalktime)
end

function MumsyWander:HoldPosition()
    self.walking = false
    self.inst.components.locomotor:Stop()
    self:Wait(self.times.minwaittime+math.random()*self.times.randwaittime)
end
