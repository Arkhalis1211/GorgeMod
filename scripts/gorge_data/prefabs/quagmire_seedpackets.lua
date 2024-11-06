local SPECIAL = {
	[3] = 0.10,
	[7] = 0.05,
}

local common = {
	1,
	2,
	4,
	5,
	6,
}

local function Wrap(prfab, tbl)
	local item = SpawnPrefab(prfab)
	if item then
		local record = item:GetSaveRecord()
		table.insert(tbl, record)
		item:Remove()
	end
end

local function GetSeedsData(id)
	local wrap_data = {}
	
	if id == "mix" then
		for num, chance in pairs(SPECIAL) do
			if math.random() <= chance then
				Wrap("quagmire_seeds_"..num, wrap_data)
			else
				Wrap("quagmire_seeds_"..common[math.random(#common)], wrap_data)
			end
		end
		for i = 1, 2 do
			Wrap("quagmire_seeds_"..common[math.random(#common)], wrap_data)
		end
	else
		for i = 1, (id == 1 and 4 or 3) do
			Wrap("quagmire_seeds_"..id, wrap_data)
		end
	end
	
	return wrap_data
end

local function OnUnwrapped(inst, pos, doer)
	SpawnAt("quagmire_seedpacket_unwrap", pos)
	
	if doer ~= nil and doer.SoundEmitter ~= nil then
		doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
	end
	
	inst:Remove()
end

return {
	master_postinit = function(inst, id)
		id = id or "mix"
		
		inst.AnimState:OverrideSymbol("seed_mix", "quagmire_seedpacket", "seed_"..tostring(id))
		inst:AddComponent("inspectable")
		if id ~= "mix" then
			inst._id:set(id)
		else
			inst._id:set(0)
		end
		inst:AddComponent("unwrappable")
        inst.components.unwrappable.itemdata = GetSeedsData(id)
		inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)
		
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = "quagmire_seedpacket_"..tostring(id)
	end,
}
