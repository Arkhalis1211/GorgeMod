return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")
		
		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("tradable")

		inst:AddComponent("quagmire_portalkey")
	end,
}
