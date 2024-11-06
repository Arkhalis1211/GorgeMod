local function GiveItems(inst, items)
	if not inst.components.inventory then
		return
	end

	local function GiveItem(prefab, count)
		local item = SpawnPrefab(prefab)
		if count and count > 1 and item.components.stackable then
			item.components.stackable.stacksize = count
		end
		
		inst.components.inventory:GiveItem(item)
		if item.components.equippable then
			inst.components.inventory:Equip(item)
		end
	end
	
	inst.components.inventory.ignoresound = true
	for prefab, count in pairs(items) do
		GiveItem(prefab, count)
	end
	inst.components.inventory.ignoresound = false
end

local function NoHoles(pt)
    return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local spidertypes = {
	"quagmire_spidertiller",
	"quagmire_spiderharvester",
	"quagmire_spiderfertilizer",
}

local function SpawnSpiders(inst)
	for k, spider in pairs(spidertypes) do
		local theta = (k / 3) * 2 * PI
		local pt = inst:GetPosition()
		local offset = FindWalkableOffset(pt, theta, 1, 3, true, true, NoHoles) or {x = 0, y = 0, z = 0}
		local pet = inst.components.petleash:SpawnPetAt(pt.x + offset.x, 0, pt.z + offset.z, spider)
		pet.owner = inst
	end
end

return {
	wolfgang = {
		[2] = function(inst)
			inst:RemoveTag("quagmire_ovenmaster")
			inst:AddTag("quagmire_strongman")
			
			inst:DoTaskInTime(5, function()
				inst.components.mightiness.rate = TUNING.GORGE.CHARACTERS.WOLFGANG_MIGHTINESS_RATE
				inst.components.mightiness.invincible = false
			end)

			GiveItems(inst, {quagmire_dumbbell = 1})

			inst:ListenForEvent("mightiness_statechange", function(inst, data)
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "quagmire_speedup", TUNING.GORGE.CHARACTERS.WOLFGANG_SPEEDUP[string.upper(data.state)])
			end)
		end,
	},

	wendy = {
		[2] = function(inst)
			inst:RemoveTag("quagmire_grillmaster")
			inst:AddTag("quagmire_rotpicker")
		end,
	},

	willow = {
		[2] = function(inst)
			inst:RemoveComponent("fuelmaster")
			GiveItems(inst, {quagmire_lighter = 1})
		end,
	},
	
	wx78 = {
		[2] = function(inst)
			inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "quagmire_speedup")
			GiveItems(inst, {quagmire_wxscanner_item = 1})
			inst:ListenForEvent("pingowner", function()
				-- maybe we should do something here?
			end)
		end,
	},
	
	wathgrithr = {
		[2] = function(inst)
			inst:RemoveTag("quagmire_butcher")
		
			inst.worked = 0
			
			inst:ListenForEvent("working", function(inst, data)
				if (inst.sg and inst.sg:HasStateTag("thrusting")) or
				not data or not data.target
				or not data.target.components.workable or
				data.target.components.workable.action ~= ACTIONS.CHOP then
					return
				end
				
				inst.worked = inst.worked + 1
				
				
				if data.target.components.workable.workleft >= 5 and inst.worked >= 5 then
					inst.worked = 0
					
					if inst.sg then
						inst.sg:GoToState("tree_thrust_pre", data.target)
					end
				end
			end)
		end,
	},
	
	webber = {
		[2] = function(inst)
			inst:RemoveTag("quagmire_farmhand")
			inst:RemoveTag("fastpicker")

			inst.components.petleash.maxpets = 3
			inst.components.petleash.petprefab = "quagmire_spider"

			inst:DoTaskInTime(0, SpawnSpiders)
		end,
	},
	walter = {
		[2] = function(inst)
			inst:AddTag("quagmire_shooter")
		end,
	},
}