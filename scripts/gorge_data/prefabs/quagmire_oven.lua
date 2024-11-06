local function CancelRattleTask(station)
	if station.rattletask ~= nil then
		station.rattletask:Cancel()
		station.rattletask = nil
	end
end

local function AcceptCookwareTest(inst, giver, item)
	if item.prefab == "quagmire_casseroledish" or item.prefab == "quagmire_casseroledish_small" then
		return true
	end
	return false
end

local function OnRattle(station, steam)
	CancelRattleTask(station)

	if steam then
		station.AnimState:PlayAnimation("cooking_bake_large")
		station:PushSteam()
	else
		station.AnimState:PlayAnimation("cooking_bake_small")
	end

	station.AnimState:PushAnimation("idle", true)

	station.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open", nil, .6)
	station.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")

	station:ScheduleRattleTask(steam)
end

local function OnHeatStart(station, stewer, isempty)
	if not isempty and not stewer:HasTag("failedcooked") then
		if stewer:HasTag("donecooking") then
			station:ScheduleRattleTask(true)
		else
			station:ScheduleRattleTask()
		end
	end
end

local function OnHeatStop(station, stewer)
	CancelRattleTask(station)
end

local function OnDoneCooking(station, stewer, food)
	CancelRattleTask(station)

	station.AnimState:PlayAnimation("cooking_bake_large")
	station.AnimState:PushAnimation("idle", true)

	station:PushSteam()
	station:ScheduleRattleTask(true)
end

local function OnFailedCooking(station, stewer, food)
	CancelRattleTask(station)

	station.AnimState:PlayAnimation("burnt")
	station.AnimState:PushAnimation("idle", true)
	station.AnimState:Show("goop_small")

	stewer.AnimState:Show("goop")
	stewer:AddTag("soiled")

	stewer.components.inventoryitem:ChangeImageName(stewer.prefab.."_overcooked")

	station.SoundEmitter:PlaySound("dontstarve/quagmire/common/cooking/boiled_over")
end

local function OnGetItem(firepit, stewer)
	local station = firepit.prefaboverride:value()
	firepit.takeitem:set(stewer)

	--sets fn before Connect
	stewer.components.quagmire_stewer:SetHeatStartFn(OnHeatStart)
	stewer.components.quagmire_stewer:SetHeatStopFn(OnHeatStop)
	stewer.components.quagmire_stewer:SetDoneCookingFn(OnDoneCooking)
	stewer.components.quagmire_stewer:SetFailedCookingFn(OnFailedCooking)
	stewer.components.quagmire_stewer:Connect(firepit, station, "oven")

	station.AnimState:PlayAnimation("place_casserole")
	station.AnimState:PushAnimation("idle", true)

	station.AnimState:AddOverrideBuild(stewer.prefab)

	if stewer:HasTag("soiled") then
		station.AnimState:Show("goop_small")
	end

	station.SoundEmitter:PlaySound("dontstarve/quagmire/common/cooking/dish_place_oven")
end

local function OnTakeItem(firepit, taker, stewer)
	local station = firepit.prefaboverride:value()
	CancelRattleTask(station)

	firepit.takeitem:set(nil)

	stewer.components.quagmire_stewer:Disconnect(taker)

	station.AnimState:PlayAnimation("place_casserole")
	station.AnimState:PushAnimation("idle", true)

	station.AnimState:ClearOverrideBuild(stewer.prefab)

	station.AnimState:Hide("goop_small")
end

local function OnPlayerNear(firepit)
	local station = firepit.prefaboverride:value()
	local x, y, z = firepit.Transform:GetWorldPosition()
	local masters = TheSim:FindEntities(x, y, z, TUNING.GORGE.COOKING_BUFF_DISTANCE, nil, nil, {"quagmire_ovenmaster"})

	if #masters > 0 then
		station.buff:ShowFX()
	end
end

local function OnPlayerFar(firepit)
	local station = firepit.prefaboverride:value()
	local x, y, z = firepit.Transform:GetWorldPosition()
	local masters = TheSim:FindEntities(x, y, z, TUNING.GORGE.COOKING_BUFF_DISTANCE, nil, nil, {"quagmire_ovenmaster"})

	if #masters == 0 then
		station.buff:HideFX()
	end
end

return {
	master_postinit = function(inst, AddHighlightChildren, OnBakeSteam, OnChimneyFireDirty)
		inst:AddComponent("inspectable")

		inst.rattletask = nil

		inst.PushSteam = function(inst)
			inst._steam:push()
			--Dedicated server does not need to spawn the local fx
			if not TheNet:IsDedicated() then
				OnBakeSteam(inst)
			end
		end

		inst.ScheduleRattleTask = function(inst, steam)
			inst.rattletask = inst:DoTaskInTime((math.random(6, 30) * 0.1), OnRattle, steam)
		end

		inst.OnFueldSectionChanged = function(inst, newsection, oldsection)
			if newsection >= 4 then
				inst._chimneyfire:set(true)
				OnChimneyFireDirty(inst)
			end
			if oldsection == 4 then
				inst._chimneyfire:set(false)
				OnChimneyFireDirty(inst)
			end
		end

		inst.oninstallfn = function(inst, firepit)
            firepit.AnimState:Hide("rocks_back")

			inst.back = SpawnPrefab("quagmire_oven_back")
			inst.back.entity:SetParent(inst.entity)
			inst.back.AnimState:PlayAnimation("place")
			inst.back.AnimState:PushAnimation("idle", true)
			inst.back.AnimState:SetFinalOffset(-1)

			inst.buff = SpawnPrefab("quagmire_cooking_buff")
			inst.buff.entity:SetParent(inst.entity)
			inst.buff:HideFX()

			firepit.components.burnable:AddBurnFX("firepit", Vector3(0, 0, 0))
			firepit.components.burnable:OverrideBurnFXBuild("quagmire_oven_fire")
			--firepit.components.burnable:OverrideBurnFXFinalOffset(2)

			inst.AnimState:PlayAnimation("place")
			inst.AnimState:PushAnimation("idle", true)

			inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/craft/oven")

			firepit:AddComponent("shelf")
			firepit.components.shelf:SetOnShelfItem(OnGetItem)
			firepit.components.shelf:SetOnTakeItem(OnTakeItem)

			firepit:AddComponent("quagmire_cookwaretrader")
			firepit.components.quagmire_cookwaretrader:SetAcceptCookwareTest(AcceptCookwareTest)

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

	master_postinit_item = function(inst)
		inst:AddComponent("inspectable")
	
		inst:AddComponent("inventoryitem")

		inst:AddComponent("quagmire_installable")
		inst.components.quagmire_installable.installprefab = "quagmire_oven"
	end,
}
