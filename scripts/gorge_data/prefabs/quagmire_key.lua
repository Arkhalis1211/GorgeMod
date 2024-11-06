return {
	master_postinit = function(inst, anim)
        inst:AddTag("klaussackkey")

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
		
        inst:AddComponent("klaussackkey")
		if anim == "park_key" then
			inst.components.klaussackkey.keytype = "gate_key"	
		else
			inst.components.klaussackkey.keytype = anim	
		end
	end,
}
