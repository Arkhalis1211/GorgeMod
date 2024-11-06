local function onpickedfn(inst, picker)
	inst.AnimState:PlayAnimation("picked", false)

	if picker then
		UpdateStat(picker.userid, "herbs_picked", 1)
	end

	RemovePhysicsColliders(inst)
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow")
	inst.AnimState:PushAnimation("idle", true)

	MakeObstaclePhysics(inst, .3)
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("picked")

	RemovePhysicsColliders(inst)
end

return {
	master_postinit_shrub = function(inst)
		inst:AddComponent("inspectable")

		inst:AddComponent("pickable")
		inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"

		inst.components.pickable:SetUp("quagmire_spotspice_sprig", GetGorgeGameModeProperty("item_regrowth") and TUNING.GORGE.SPICE_REGROWTH_TIME)
		inst.components.pickable.onregenfn = onregenfn
		inst.components.pickable.onpickedfn = onpickedfn
		inst.components.pickable.makeemptyfn = makeemptyfn
	end,

	master_postinit_sprig = function(inst)
		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
	end,

	master_postinit_ground = function(inst)
		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	end,
}
