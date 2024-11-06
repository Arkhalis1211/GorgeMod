local names = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10"}

local function OnPicked(inst, picker)
	if picker then
		UpdateStat(picker.userid, "herbs_picked", 1)
	end
	inst:Remove()
end

return {
	master_postinit = function(inst)
		inst.animname = names[math.random(#names)]
		inst.AnimState:PlayAnimation(inst.animname)

		inst:AddComponent("inspectable")

		inst:AddComponent("pickable")
		inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
		inst.components.pickable:SetUp("foliage", 10)
		inst.components.pickable.onpickedfn = OnPicked
		inst.components.pickable.quickpick = true	
	end,
}
