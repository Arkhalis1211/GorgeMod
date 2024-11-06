local function GetProductNameByIDSeed(idseed)
	for k, v in pairs(TUNING.GORGE.PRODUCT_PLANTED) do
		if v.idseed == idseed then
			return k
		end
	end
	return nil
end

local function onpicked(inst, picker)
	if inst ~= nil and picker ~= nil then
		local pos = inst:GetPosition()
		local product = inst.components.quagmire_crop.product

		if product ~= nil then
			local loot = nil

			if not inst:HasTag("rotten") or (picker:HasTag("quagmire_rotpicker") and math.random() <= TUNING.GORGE.WENDY_ABILITY_RNG) then
				loot = SpawnPrefab("quagmire_"..product)
				picker.SoundEmitter:PlaySound(TUNING.GORGE.PRODUCT_PLANTED[inst.components.quagmire_crop.product].pick_sound or "dontstarve/wilson/pickup_plants")
			else
				loot = SpawnPrefab("spoiled_food")
				picker.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
			end

			loot.components.stackable:SetStackSize(1)
			picker.components.inventory:GiveItem(loot, nil, pos)
		end
		
		UpdateStat(picker.userid, "crops_picked", 1)

		local soil = SpawnPrefab("quagmire_soil")
		soil.Transform:SetPosition(pos.x, 0, pos.z)
		soil:PushEvent("break")
		inst:Remove()
	end
end

local function ongrow(inst, stage)
	if stage == 1 then
		inst.AnimState:PlayAnimation("grow_med")
		inst.AnimState:PushAnimation("crop_med")
		inst.soil_back.AnimState:PlayAnimation("grow_med")
		inst.soil_front.AnimState:PlayAnimation("grow_med")
	elseif stage == 2 then
		inst.AnimState:PlayAnimation("grow_full")
		inst.AnimState:PushAnimation("crop_full")
		inst.soil_back.AnimState:PlayAnimation("grow_full")
		inst.soil_front.AnimState:PlayAnimation("grow_full")
	end
end

local function onmatured(inst)
	inst.components.pickable.canbepicked = true
end

local function onrotten(inst)
	inst.AnimState:PlayAnimation("grow_rot")
	inst.AnimState:PushAnimation("crop_rot")
	inst.soil_back.AnimState:PlayAnimation("grow_rot")
	inst.soil_front.AnimState:PlayAnimation("grow_rot")
	inst.components.pickable.canbepicked = true

	SetDirty(inst._rotten, true)
end

local function onload_planted(inst, data)
	if data and data.worldgen_planted then
		inst.components.quagmire_crop.cangrow = false
		inst.components.quagmire_crop.canrot = false
		inst.components.quagmire_crop.stage = 2
		inst.components.quagmire_crop:Mature(true)
	else 
		inst.components.quagmire_crop.cangrow = false
		inst.components.quagmire_crop:Rot()
	end
end

return {
	master_postinit_seed = function(inst, id)
		inst:AddTag("bait")
		
		inst:SetPrefabNameOverride("quagmire_"..GetProductNameByIDSeed(id).."_seeds")

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = "quagmire_seeds_"..tostring(id)

		inst:AddComponent("edible")
		inst.components.edible.foodtype = FOODTYPE.SEEDS

		inst:AddComponent("bait")

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.SLOW)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"

		inst:AddComponent("quagmire_plantable")
		inst.components.quagmire_plantable.product = GetProductNameByIDSeed(id)
	end,

	master_postinit_planted = function(inst, product, onrottendirty)
		if product == nil then
			return
		end

		inst:AddTag("crop")
		
		inst.boosted = false

		inst.AnimState:SetLayer(LAYER_WORLD)
		inst.AnimState:SetSortOrder(0)
		inst.AnimState:PlayAnimation("grow_small")
		inst.AnimState:PushAnimation("crop_small")

		if product == "potato" or product == "tomato" then
			inst.AnimState:Show("crop_bulb2")
			inst.AnimState:Show("crop_leaf2")
		elseif product == "wheat" then
			inst.AnimState:Show("crop_bulb3")
			inst.AnimState:Show("crop_leaf3")
		else
			inst.AnimState:Show("crop_bulb1")
			inst.AnimState:Show("crop_leaf1")
		end

		inst.soil_back = SpawnPrefab("quagmire_planted_soil_back")
		inst.soil_front = SpawnPrefab("quagmire_planted_soil_front")
		inst.soil_back.Transform:SetPosition(0, 0, 0)
		inst.soil_front.Transform:SetPosition(0, 0, 0)
		inst.soil_back.entity:SetParent(inst.entity)		
		inst.soil_front.entity:SetParent(inst.entity)
		inst.soil_front.AnimState:SetLayer(LAYER_WORLD)
		inst.soil_front.AnimState:SetSortOrder(0)
		inst.soil_back.AnimState:PlayAnimation("grow_small")
		inst.soil_front.AnimState:PlayAnimation("grow_small")

		inst:AddComponent("inspectable")
		inst:AddComponent("quagmire_fertilizable")
		inst:AddComponent("quagmire_crop")
		inst.components.quagmire_crop.product = product
		inst.components.quagmire_crop.growth_time = TUNING.GORGE.PRODUCT_PLANTED[product].growthtime
		inst.components.quagmire_crop.mature_time = TUNING.GORGE.PRODUCT_PLANTED[product].maturetime
		inst.components.quagmire_crop:SetGrowFn(ongrow)
		inst.components.quagmire_crop:SetMaturedFn(onmatured)
		inst.components.quagmire_crop:SetRottenFn(onrotten)

		inst:AddComponent("pickable")
		inst.components.pickable.canbepicked = false
		inst.components.pickable.onpickedfn = onpicked

		inst.SetBoosted = function(inst, val)
			if inst.boosted == val or (val and inst:HasTag("rotten")) then
				return
			end

			inst.boosted = val

			for i, soil in ipairs({"soil_back", "soil_front"}) do
				inst[soil].AnimState:SetHaunted(val)
			end

			if val then
				if not inst.wormwood_fx then
					inst.wormwood_fx = inst:SpawnChild("quagmire_wormwood_fx")
				end
			elseif inst.wormwood_fx then
				inst.wormwood_fx:Kill()
				inst.wormwood_fx = nil
			end

			inst.components.quagmire_crop:SetBoosted(val)
		end

		inst:ListenForEvent("crop_rotted", function(inst)
			inst:SetBoosted(false)
		end)

		inst.OnLoad = onload_planted
	end,

	master_postinit_raw = function(inst, product, prefab_override, cancook)
		inst:AddTag("show_spoilage")
		if product ~= "wheat" and product ~= "turnip" then
			inst.AnimState:SetBank(product)
			inst.AnimState:SetBuild(product)
			inst.AnimState:PlayAnimation("idle")
		end

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = product == "carrot" and product or "quagmire_"..product

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		if product ~= "wheat" then
			inst:AddComponent("perishable")
			inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.SLOW)
			inst.components.perishable:StartPerishing()
			inst.components.perishable.onperishreplacement = "spoiled_food"

			inst:AddComponent("cookable")
			inst.components.cookable.product = "quagmire_"..product.."_cooked"
			
			inst:AddComponent("edible")
			inst.components.edible.foodtype = FOODTYPE.VEGGIE

			inst:AddComponent("bait")
		end
	end,

	master_postinit_cooked = function(inst, product, prefab_override)
		inst:AddTag("show_spoilage")
		if product ~= "turnip" then
			inst.AnimState:SetBank(product)
			inst.AnimState:SetBuild(product)
			inst.AnimState:PlayAnimation("cooked")
		end

		inst:AddComponent("inspectable")

		inst:AddComponent("edible")
		inst.components.edible.foodtype = FOODTYPE.VEGGIE

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = product == "carrot" and product.."_cooked" or "quagmire_"..product.."_cooked"

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(TUNING.GORGE.PERISH_TIME.INGRIDIENTS.SLOW)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"

		inst:AddComponent("bait")
	end,
}
