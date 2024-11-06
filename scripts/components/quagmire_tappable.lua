local BUCKET_LEVELS =
{
	"empty",
	"full",
	"overflow",
	"overflow_spoiled",
}

local function TrySpawnFlies(inst)
	if inst.flies == nil then
		inst.flies = inst:SpawnChild("flies")
	end
end

local function DelayProduceHandler(inst, self)
	if self.task ~= nil then
		self.task:Cancel()
		self.task = nil
		self.delay = 0
	end

	if self.hasbucket then
		self.level = self.level + 1

		if self.level >= 3 then
			if self.inst:HasTag("withered") then
				self.level = 4
			else
				self.level = 3
				self:ScheduleSpoilTask()
			end
			TheWorld:PushEvent("scannernotice", {scanpref = self.inst})

			self.inst:AddTag("tapped_harvestable")
			self.inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/craft/sap_extractor")
		else
			self:ScheduleProduceTask()
		end

		self.inst.AnimState:OverrideSymbol("swap_sapbucket", "quagmire_sapbucket", "swap_sapbucket_"..BUCKET_LEVELS[self.level])
	end
end

local function DelaySpoilHandler(inst, self)
	if self.task ~= nil then
		self.task:Cancel()
		self.task = nil
		self.delay = 0
	end

	if self.hasbucket then
		self.level = 4
		self.inst.AnimState:OverrideSymbol("swap_sapbucket", "quagmire_sapbucket", "swap_sapbucket_"..BUCKET_LEVELS[self.level])
		self.inst.AnimState:OverrideSymbol("leaf_overlay", "quagmire_tree_cotton_build", "leaf_withered_overlay")
		self.inst.AnimState:OverrideSymbol("swap_leaves", "quagmire_tree_cotton_build", "swap_leaves_withered")
		self.inst.AnimState:OverrideSymbol("trunk", "quagmire_tree_cotton_trunk_build", "trunk_holes")
		self.inst.AnimState:PlayAnimation("sap_leak_pre")
		self.inst.AnimState:PushAnimation("sap_leak_pst")
		self.inst.AnimState:PushAnimation("sway1_loop", true)
		self.inst.AnimState:Show("sap")

		self.inst:AddTag("withered")
		self.inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/craft/sap_extractor")
		TheWorld:PushEvent("scannernotice", {scanpref = self.inst})

		TrySpawnFlies(self.inst)
	end
end

local Quagmire_Tappable = Class(function(self, inst)
	self.inst = inst
	self.hasbucket = false
	self.level = 1
	self.task = nil
	self.delay = 0
end)

function Quagmire_Tappable:IsTapped()
	return self.hasbucket
end

function Quagmire_Tappable:InstallTap(player, bucket)
	if self.inst:HasTag("withered") then
		return false
	end

	local pos = self.inst:GetPosition()

	self.inst.AnimState:OverrideSymbol("swap_sapbucket", "quagmire_sapbucket", "swap_sapbucket_"..BUCKET_LEVELS[1])

	if bucket and bucket.components.stackable then
		bucket.components.stackable:Get(1):Remove()
		self.inst.AnimState:PlayAnimation("install")
		self.inst.AnimState:PushAnimation("sway1_loop", true)
		self.inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/craft/sap_extractor")
		self.hasbucket = true
	end

	SpawnPrefab("sugarwood_leaf_fx_chop").Transform:SetPosition(pos.x, 1, pos.z)

	self.inst.AnimState:Show("swap_tapper")
	self.inst:RemoveTag("tappable")
	self:ScheduleProduceTask()
end

function Quagmire_Tappable:UninstallTap(picker)
	if self.hasbucket then
		if self.task ~= nil then
			self.task:Cancel()
			self.task = nil
			self.delay = 0
		end

		self.inst.AnimState:OverrideSymbol("swap_sapbucket", "quagmire_sapbucket", "swap_sapbucket_empty")
		self.inst.AnimState:Hide("swap_tapper")

		self.inst:RemoveTag("tapped_harvestable")

		if not self.inst:HasTag("withered") then
			self.inst:AddTag("tappable")
		end

		local sapbucket = SpawnPrefab("quagmire_sapbucket")
		local pos = self.inst:GetPosition()

		sapbucket.Transform:SetPosition(pos.x, 0.5, pos.z)

		if sapbucket ~= nil then
			if picker ~= nil and picker.components.inventory ~= nil then
				picker.components.inventory:GiveItem(sapbucket, nil, pos)
			else
				Launch(sapbucket, self.inst, 0.5)
			end
		end

		self:Harvest(picker)

		self.hasbucket = false
		self.level = 1

		if self.inst:HasTag("withered") then
			self.inst:RemoveComponent("quagmire_tappable")
		end
	end
end

function Quagmire_Tappable:Harvest(picker)
	if self.level >= 3 then
		if self.task ~= nil then
			self.task:Cancel()
			self.task = nil
			self.delay = 0
		end

		local prefab = "quagmire_sap"
		if self.level == 4 then
			prefab = "quagmire_sap_spoiled"
		end

		local sap = SpawnPrefab(prefab)
		local pos = self.inst:GetPosition()

		sap.Transform:SetPosition(pos.x, 0.5, pos.z)

		if sap ~= nil then
			local pos = self.inst:GetPosition()
			if picker ~= nil and picker.components.inventory ~= nil then
				picker.components.inventory:GiveItem(sap, nil, pos)
			else
				Launch(sap, self.inst, 0.5)
			end

			self.inst:RemoveTag("tapped_harvestable")

			self.level = 1
			self.inst.AnimState:OverrideSymbol("swap_sapbucket", "quagmire_sapbucket", "swap_sapbucket_"..BUCKET_LEVELS[self.level])
			self:ScheduleProduceTask()
		end
		if picker ~= nil and picker.components.inventory ~= nil then		
			UpdateAchievement("gather_sap", picker.userid, prefab)
		end
		return true
	end

	return false
end

function Quagmire_Tappable:ScheduleProduceTask()
	self.delay = TUNING.GORGE.SUGARTREE.SAP / 2
	self.task = self.inst:DoTaskInTime(self.delay, DelayProduceHandler, self)
end

function Quagmire_Tappable:ScheduleSpoilTask()
	self.delay = TUNING.GORGE.SUGARTREE.ROT
	self.task = self.inst:DoTaskInTime(self.delay, DelaySpoilHandler, self)
end

function Quagmire_Tappable:GetDebugString()
	return string.format("has bucket:%s level:%i delay:%i", tostring(self.hasbucket), self.level, self.delay)
end

return Quagmire_Tappable
