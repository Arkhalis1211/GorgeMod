local function GetItemData(id, KIT_ITEMS)
	local data = {}
	for _, itemprefab in ipairs(KIT_ITEMS[id]) do
		local item = SpawnPrefab(itemprefab)
		if item then
			local record = item:GetSaveRecord()
			table.insert(data, record)
			item:Remove()
		end
	end
	return data
end

local function OnUnwrapped(inst, pos, doer)
	local owner = inst.components.inventoryitem:GetGrandOwner()
	if owner and owner.components.inventory then
		owner.components.inventory:DropItem(inst)
	end

	inst.components.inventoryitem.canbepickedup = false
	inst.components.unwrappable.canbeunwrapped = false
	
	inst.AnimState:PlayAnimation("unwrap")

	if doer ~= nil and doer.SoundEmitter ~= nil then
		doer.SoundEmitter:PlaySound("dontstarve/common/together/crate_open")
	end

	inst:ListenForEvent("animover", inst.Remove)
end

local function OnDropped(inst)
	if inst.Physics ~= nil then
		local x, _, z = inst.Physics:GetVelocity()
		inst.Physics:SetVel(x, 0, z)
	end
end

return {
	master_postinit = function(inst, kit, KIT_NAMES, KITS, KIT_ITEMS)
		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

		inst:AddComponent("unwrappable")
		inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)

		if kit == "grill" then
			inst._kitid:set(4)
		elseif kit == "grill_small" then
			inst._kitid:set(3)
		elseif kit == "oven" then
			inst._kitid:set(2)
		else
			inst._kitid:set(1)
		end

		if kit ~= nil then
			inst.AnimState:OverrideSymbol("swap_logo", "quagmire_crate", "logo_"..kit)
			inst.components.inventoryitem.imagename = "quagmire_crate_"..kit
			inst.components.unwrappable.itemdata = GetItemData(kit, KIT_ITEMS)
			inst.kit_type = kit
		end
	end,
}
