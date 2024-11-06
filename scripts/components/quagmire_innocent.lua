local function onkillable(self, killable)
    if killable then
        self.inst:AddTag("killable")
    else
        self.inst:RemoveTag("killable")
    end
end

local function onreportable(self, reportable)
    if reportable then
        self.inst:AddTag("reportable")
    else
        self.inst:RemoveTag("reportable")
    end
end

local Quagmire_Innocent = Class(function(self, inst, activcb)
    self.inst = inst
    self.OnActivate = activcb
    self.killable = true
    self.reportable = false
end,
nil,
{
    killable = onkillable,
    reportable = onreportable,
})

function Quagmire_Innocent:OnRemoveFromEntity()
    self.inst:RemoveTag("killable")
    self.inst:RemoveTag("reportable")
end

function Quagmire_Innocent:CanDie(killer)
	if killer:HasTag("quagmire_murderplayer") and not self.inst.components.health:IsDead() then
		return true
	end
    return false
end

function Quagmire_Innocent:Kill(killer)
	if killer then
		self.inst:AddTag("corpse")
		self.inst.components.health.invincible = false
		self.inst.components.health:Kill()
		
		if self.inst.components.inventory then
			self.inst.components.inventory:DropEverything()
		end
		if killer.components.quagmire_cd then
			killer.components.quagmire_cd:StartCD(TUNING.GORGE.MURDERER_CD)
		end
		self.reportable = true
		self.killable = false
		TheWorld:PushEvent("quagmire_playerkilled", self.inst)
		self.inst.components.talker:IgnoreAll()
		self.inst:DoTaskInTime(2, function()
			self.inst:RemoveTag("corpse")
		end)
		return true
	end
	return false
end

function Quagmire_Innocent:CanReport(reporter)
	if self.reportable then
		return true
	end
    return false
end

function Quagmire_Innocent:Report(reporter)
	if reporter then
		self.reportable = false
		TheWorld.net.components.quagmire_murdermysterymanager:Report(reporter)
		return true
	end
	return false
end

return Quagmire_Innocent
