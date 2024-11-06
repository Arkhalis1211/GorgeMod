return {
	master_postinit = function(inst)
		if not TheWorld.ismastersim then
			return inst
		end
				
		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
	
		inst:AddComponent("quagmire_slaughtertool")
	end,
}
