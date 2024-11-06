local function CancelRattleTask(station)
	if station.rattletask ~= nil then
		station.rattletask:Cancel()
		station.rattletask = nil
	end
end

local function UpdateMystery(station, stewer)
	local numitems = stewer.components.container:NumItems()

	if numitems == 0 then
		station.AnimState:ClearOverrideSymbol("swap_mystery")
	elseif numitems <= 4 then
		station.AnimState:OverrideSymbol("swap_mystery", station.prefab, "mystery"..numitems)
	end
end

local function OnRattle(station, smoke)
	CancelRattleTask(station)

	if smoke then
		station.AnimState:PlayAnimation("cooking_grill_big")
		station:PushSmoke()
	else
		station.AnimState:PlayAnimation("cooking_grill_small")
	end

	station.AnimState:PushAnimation("idle", true)

	station.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open", nil, .6)
	station.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")

	station:ScheduleRattleTask(smoke)
end

local function OnHeatStart(station, stewer, isempty)
	if not stewer.components.quagmire_stewer:IsOpen() then
		if not isempty and not stewer:HasTag("failedcooked") then
			if stewer:HasTag("donecooking") then
				station:ScheduleRattleTask(true)
			else
				station:ScheduleRattleTask()
			end
		end

		if not isempty and stewer:HasTag("failedcooked") then
			station:Burn(1)
		end
	end
end

local function OnHeatStop(station, stewer)
	CancelRattleTask(station)
	station:Burn(0)
end

local function OnDoneCooking(station, stewer, food)
	CancelRattleTask(station)

	station.AnimState:PlayAnimation("cooking_grill_big")
	station.AnimState:PushAnimation("idle", true)

	station.AnimState:ClearOverrideSymbol("swap_mystery")
	station.AnimState:OverrideSymbol("swap_plate_food", food.prefab, "swap_food")
	station.AnimState:OverrideSymbol("swap_plate", "quagmire_generic_plate", "generic_"..food.dish)

	station:PushSmoke()
	station:ScheduleRattleTask(true)
end

local function OnFailedCooking(station, stewer, food)
	CancelRattleTask(station)

	station:Burn(1)
	station.AnimState:ClearOverrideSymbol("swap_mystery")
	station.AnimState:OverrideSymbol("swap_plate_food", "quagmire_generic_plate", food.dirty)
	station.AnimState:OverrideSymbol("swap_plate", "quagmire_generic_plate", "generic_"..food.dish)
end

local function OnOpen(station, stewer)
	CancelRattleTask(station)

	station.AnimState:PlayAnimation("open", true)
	station.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open")

	if station._burnt:value() ~= 0 then
		station:Burn(0)
	end
end

local function OnClose(station, stewer)
	station.AnimState:PlayAnimation("idle", true)
	station.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
end

local function OnItemGet(station, stewer)
	UpdateMystery(station, stewer)
end

local function OnItemLose(station, stewer)
	if stewer:HasTag("donecooking") then
		local station = stewer.prefaboverride:value()

		station.AnimState:ClearOverrideSymbol("swap_plate_food")
		station.AnimState:ClearOverrideSymbol("swap_plate")

		if station._burnt:value() ~= 0 then
			station:Burn(0)
		end
	end

	UpdateMystery(station, stewer)
end

local function OnPlayerNear(firepit)
	local station = firepit.prefaboverride:value()
	local x, y, z = firepit.Transform:GetWorldPosition()
	local masters = TheSim:FindEntities(x, y, z, TUNING.GORGE.COOKING_BUFF_DISTANCE, nil, nil, {"quagmire_grillmaster"})

	if #masters > 0 then
		station.buff:ShowFX()
	end
end

local function OnPlayerFar(firepit)
	local station = firepit.prefaboverride:value()
	local x, y, z = firepit.Transform:GetWorldPosition()
	local masters = TheSim:FindEntities(x, y, z, TUNING.GORGE.COOKING_BUFF_DISTANCE, nil, nil, {"quagmire_grillmaster"})

	if #masters == 0 then
		station.buff:HideFX()
	end
end

return {
	master_postinit = function(inst, name, AddHighlightChildren, OnBurntDirty, OnGrillSmoke, OnEmbersDirty)
		inst:AddComponent("inspectable")

		inst.rattletask = nil

		inst.PushSmoke = function(inst)
			inst._smoke:push()
			--Dedicated server does not need to spawn the local fx
			if not TheNet:IsDedicated() then
				OnGrillSmoke(inst)
			end
		end

		inst.Burn = function(inst, value)
			inst._burnt:set(value)
			--Dedicated server does not need to spawn the local fx
			if not TheNet:IsDedicated() then
				OnBurntDirty(inst)
			end
		end

		inst.ScheduleRattleTask = function(inst, large)
			local delay = math.random(3, 30) * 0.1
			inst.rattletask = inst:DoTaskInTime(delay, OnRattle, large)
		end

		inst.OnFueldSectionChanged = function(inst, newsection, oldsection)
			inst._embers:set(newsection)
			--Dedicated server does not need to spawn the local fx
			if not TheNet:IsDedicated() then
				OnEmbersDirty(inst)
			end
		end

		inst.oninstallfn = function(inst, firepit)
			inst.buff = SpawnPrefab("quagmire_cooking_buff")
			inst.buff.entity:SetParent(inst.entity)
			inst.buff:HideFX()

			inst.AnimState:PlayAnimation("place")
			inst.AnimState:PushAnimation("idle", true)

			if name == "quagmire_grill" then
				inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/craft/grill_big")
			elseif name == "quagmire_grill_small" then
				inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/craft/grill_small")
			end

			firepit.components.burnable:OverrideBurnFXBuild("quagmire_oven_fire")	
			firepit.components.burnable:OverrideBurnFXFinalOffset(-3)

			firepit:AddComponent("quagmire_stewer")
			firepit.components.quagmire_stewer:SetOpenFn(OnOpen)
			firepit.components.quagmire_stewer:SetCloseFn(OnClose)
			firepit.components.quagmire_stewer:SetItemGetFn(OnItemGet)
			firepit.components.quagmire_stewer:SetItemLoseFn(OnItemLose)
			firepit.components.quagmire_stewer:SetHeatStartFn(OnHeatStart)
			firepit.components.quagmire_stewer:SetHeatStopFn(OnHeatStop)
			firepit.components.quagmire_stewer:SetDoneCookingFn(OnDoneCooking)
			firepit.components.quagmire_stewer:SetFailedCookingFn(OnFailedCooking)
			firepit.components.quagmire_stewer:Connect(firepit, inst, "grill")

			firepit:AddComponent("playerprox")
			firepit.components.playerprox:SetDist(TUNING.GORGE.COOKING_BUFF_DISTANCE, TUNING.GORGE.COOKING_BUFF_DISTANCE)
			firepit.components.playerprox:SetOnPlayerNear(OnPlayerNear)
			firepit.components.playerprox:SetOnPlayerFar(OnPlayerFar)

			inst:OnFueldSectionChanged(firepit.components.fueled:GetCurrentSection(), 0)

			--Dedicated server does not need to set the local fx
			if not TheNet:IsDedicated() then
				AddHighlightChildren(inst, firepit)
			end
		end
	end,

	master_postinit_item = function(inst, name)
		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")

		inst:AddComponent("quagmire_installable")
		inst.components.quagmire_installable.installprefab = name
	end,
}
