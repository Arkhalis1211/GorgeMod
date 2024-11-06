return {
	master_postinit = function(inst, dish, food, OnReplateDirty)
		inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.replica.inventoryitem:SetImage(food.."_"..dish)
        inst.components.inventoryitem.atlasname = "images/quagmire_food_common_inv_images.xml"		
	end,
}
