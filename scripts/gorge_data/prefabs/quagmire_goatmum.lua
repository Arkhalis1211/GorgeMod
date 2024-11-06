local function OnActivate(inst)
	inst:PushEvent("item_bought", {first = inst.components.goatmum.firstpurchase})
end

local function OnNear(inst)
	inst:PushEvent("player_near")
end

return {
	master_postinit = function(inst)
		inst.points = {}
	
		inst:AddTag("goatmum")
	
		inst:AddComponent("inspectable")
		
		inst:AddComponent("goatmum")
		
		MakeQuagmireShop(inst, OnNear, nil, OnActivate)
		
		inst:AddComponent("locomotor")
		inst.components.locomotor.runspeed = 6
		inst.components.locomotor.walkspeed = 3
		
		inst:AddComponent("knownlocations")
		inst:AddComponent("homeseeker")
		
		inst:SetStateGraph("SGgoatmum")
		
		inst:SetBrain(require("brains/goatmumbrain"))
	end,
}
