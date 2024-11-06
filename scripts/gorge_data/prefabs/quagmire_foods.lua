local cooking = require "gorge_cooking"

local function GetDescription(inst, viewer)
    if viewer:HasTag("quagmire_foodie") then
        local quagmirecraving = TheWorld.components.quagmire:GetCraving()
        if table.contains(inst.cravings, quagmirecraving) then
            if table.contains(inst.cravings, "snack") and quagmirecraving ~= "snack" then
                return "MATCH_BUT_SNACK"
            end
            return "MATCH"
        end
        return "MISMATCH"
    end
    return nil
end

return {
    master_postinit = function(inst, name, DISH_NAMES, DISH_IDS, LoadKeys, OnDishDirty)
        local dish = cooking.GetDishByRecipe(name)

        inst.cravings = cooking.GetCravingsByRecipe(name)

        if dish == "bowl" then
            inst.AnimState:SetBank("quagmire_generic_bowl")
            inst.AnimState:SetBuild("quagmire_generic_bowl")
        end
		if GetGorgeGameModeProperty("confusion_enabled") then
			inst.AnimState:HideSymbol("swap_food", "poop", "swap_food")
			local fx = SpawnPrefab("nightmarefuel")
			
			fx:AddTag("FX")
			fx:AddTag("NOCLICK")
			fx:RemoveComponent("stackable")
			fx:RemoveComponent("inspectable")
			fx:RemoveComponent("inventoryitem")
			fx:RemoveComponent("fuel")

			fx.AnimState:SetMultColour(1,1,1,1)
			fx.entity:SetParent(inst.entity)
			fx.entity:AddFollower()
			if dish == "bowl" then
				fx.Follower:FollowSymbol(inst.GUID, "swap_food", 0, -35, 0)
			else
				fx.Follower:FollowSymbol(inst.GUID, "swap_food", 0, 0, 0)
			end
			if not TheNet:IsDedicated() then
				if inst.highlightchildren == nil then
					inst.highlightchildren = { fx }
				else
					table.insert(inst.highlightchildren, fx)
				end
			end
			inst:DoPeriodicTask(5, function()
				local fx2 = SpawnPrefab("shadowhand_fx")
				fx2.entity:SetParent(inst.entity)
				fx2.entity:AddFollower()
				fx2.Follower:FollowSymbol(inst.GUID, "swap_food", 0, 0, 0)
			end)
		end
        inst:AddTag("show_spoilage")

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = "quagmire_food"
        inst.components.inspectable.getstatus = GetDescription

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/quagmire_food_inv_images_"..name..".xml"

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.FOOD.NORMAL)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"

        inst:AddComponent("quagmire_saltable")
        inst:AddComponent("quagmire_stewable")

        if dish ~= nil then
            inst:AddComponent("quagmire_replatable")
            inst.components.quagmire_replatable.basedish = dish

            inst.basedishid:set(DISH_IDS[dish])

			OnDishDirty(inst)
        end
    end,
}
