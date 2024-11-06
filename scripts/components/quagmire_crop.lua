local function onstate(self, val)
	self.inst:PushEvent("crop_stage_changed", {stage = val})
end

local function OnInit(inst, self)
	if self.cangrow then
		self:ScheduleUpdate(self.countstages > 1 and self.growth_time or self.mature_time)
	end
end

local function CancelTask(self)
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

local Quagmire_Crop = Class(function(self, inst)
    self.inst = inst
    self.cangrow = true
    self.canrot = true
    self.product = nil
    self.ongrowfn = nil
    self.onmaturedfn = nil
    self.onrottenfn = nil
	
	self.growthtime = 0
	self.dt = 1
    self.task = nil
	
	self.mature_time = 10
	self.growth_time = 10
	self.rotting_time = nil
	
    self.countstages = 2
    self.stage = 0
	self.tempboost = 0

    self.inst:AddTag("fertilizable")
	
    inst:DoTaskInTime(0, OnInit, self)
end,
nil,
{
	stage = onstate,
})

function Quagmire_Crop:SetGrowFn(fn)
    self.ongrowfn = fn
end

function Quagmire_Crop:SetMaturedFn(fn)
    self.onmaturedfn = fn
end

function Quagmire_Crop:SetRottenFn(fn)
    self.onrottenfn = fn
end

function Quagmire_Crop:Grow()
	if not self.cangrow then
		return
	end
	
    self.stage = math.min(self.stage + 1, self.countstages)
	
	if self.stage == self.countstages then
        self:Mature(true)
	else
        if self.ongrowfn ~= nil then
            self.ongrowfn(self.inst, self.stage)
        end
		self:ScheduleUpdate(self.stage + 1 == self.countstages and self.mature_time or self.growth_time)
	end
end

function Quagmire_Crop:Mature(force)
	if not force and (self.inst:HasTag("rotten") or self.stage == self.countstages) then
		return false
	end

    self.inst:RemoveTag("fertilizable")
	TheWorld:PushEvent("scannernotice", {scanpref = self.inst})

    if self.onmaturedfn ~= nil then
        self.onmaturedfn(self.inst)
    end  

    if self.ongrowfn ~= nil then
        self.ongrowfn(self.inst, self.stage)
    end
	
	if self.farmer then
		UpdateStat(self.farmer.userid, "crops_farmed", 1)
	end

	if self.canrot then
		self:ScheduleUpdate(self.rotting_time or self.mature_time)
	end
end

function Quagmire_Crop:Rot()
	if not self.canrot then
		return
	end

    self.inst:AddTag("rotten")
    self.inst:RemoveTag("fertilizable")
	
	if self.farmer then
		UpdateStat(self.farmer.userid, "crops_rotten", 1)
	end

    if self.onrottenfn ~= nil then
        self.onrottenfn(self.inst)
    end
	TheWorld:PushEvent("scannernotice", {scanpref = self.inst})

	self.inst:PushEvent("crop_rotted")
end

function Quagmire_Crop:Fertilize(fertilizer, doer)
    if fertilizer.components.fertilizer ~= nil then
        if doer ~= nil and 
			doer.SoundEmitter ~= nil and
			fertilizer.components.fertilizer.fertilize_sound ~= nil then
			doer.SoundEmitter:PlaySound(fertilizer.components.fertilizer.fertilize_sound)
			UpdateAchievement("farm_fertilize", doer.userid, 1)
        end

        self:Grow()

		CancelTask(self)
    end
end

local function Update(inst)
	inst.components.quagmire_crop:Update()
end

function Quagmire_Crop:ScheduleUpdate(t)
	if t then
		self.growthtime = t
	end
	self.task = self.inst:DoTaskInTime(self.dt, Update)
end

function Quagmire_Crop:Update()
	if self.inst:HasTag("rotten") then
		return
	end
	
    local boostfactor = 1

    if self.stage ~= self.countstages then
        if self.boosted then
            boostfactor = TUNING.GORGE.CHARACTERS.WORMWOOD_BOOST
        end
    else
        if self.boosted then
            boostfactor = 1 / TUNING.GORGE.CHARACTERS.WORMWOOD_BOOST
        end
    end

    local dt = self.dt * boostfactor

	if self.tempboost > 0 then
		self.tempboost = self.tempboost - dt

        if not self.boosted then
            if self.stage ~= self.countstages then
                dt = dt * TUNING.GORGE.CHARACTERS.WEBBER_BOOST
            else
                dt = dt * (1 / TUNING.GORGE.CHARACTERS.WEBBER_BOOST)
            end
        end
	end

	self.growthtime = math.max(self.growthtime - dt, 0)
	
	if self.growthtime == 0 then
		if self.stage == self.countstages then
			self:Rot()
		else
			self:Grow()
		end
	else
		self:ScheduleUpdate()
	end
end

function Quagmire_Crop:SetBoosted(val)
	self.boosted = val
end

function Quagmire_Crop:SetTempBoost(val)
	self.tempboost = val
end

function Quagmire_Crop:OnRemoveFromEntity()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end

    self.inst:RemoveTag("rotten")
    self.inst:RemoveTag("fertilizable")
end

Quagmire_Crop.OnRemoveEntity = Quagmire_Crop.OnRemoveFromEntity

function Quagmire_Crop:GetDebugString()
	return string.format("cangrow:%s canrot:%s stage:%i growthtime:%3.2f", tostring(self.cangrow), tostring(self.canrot), self.stage, self.growthtime)
end

return Quagmire_Crop
