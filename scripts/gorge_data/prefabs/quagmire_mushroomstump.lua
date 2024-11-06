local function OnPicked(inst, picker)
    inst.AnimState:PlayAnimation("pick")
    inst.AnimState:PushAnimation("idle")
	for i = 1, 5 do
		inst.AnimState:HideSymbol("a"..i)
	end
	
    inst.components.pickable.canbepicked = false
	
	if picker then
		UpdateStat(picker.userid, "herbs_picked", 1)
	end
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("pick")
    inst.AnimState:PushAnimation("idle")
	
	inst:DoTaskInTime(2 * FRAMES, function(inst)
		for i = 1, 5 do
			inst.AnimState:ShowSymbol("a"..i)
		end
	end)
end

return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")
		
		inst:AddComponent("pickable")
		inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
		inst.components.pickable:SetUp("quagmire_mushrooms", GetGorgeGameModeProperty("item_regrowth") and TUNING.GORGE.MUSHROOM_REGROW_TIME)
		inst.components.pickable.onpickedfn = OnPicked
		inst.components.pickable.onregenfn = onregenfn
		inst.components.pickable.quickpick = false
	end,
}
