return {
	master_postinit = function(inst, basedish, dishtype)
		inst:AddComponent("inspectable")

	    inst:AddComponent("inventoryitem")
	    inst.components.inventoryitem.imagename =  basedish.."_"..dishtype
        inst.components.inventoryitem.atlasname = "images/quagmire_food_common_inv_images.xml"

		inst:AddComponent("quagmire_replater")
		inst.components.quagmire_replater:SetUp(basedish, dishtype)
	end,
}
