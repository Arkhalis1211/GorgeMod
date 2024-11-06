local menv = env
GLOBAL.setfenv(1, GLOBAL)

-- Surg: dirty hack for Geometric Placement mod, he crashed if call "GetRecipe",
--       because rezecib still hasn't fixed it.
if menv._G.KnownModIndex:IsModEnabled("workshop-351325790") then
    menv._G.GetRecipe = function(name)
        if name == 'treasurechest' then
            return {min_spacing = 1}
        end
        return nil
    end
end

local function GetClass(prefab)
	return (math.abs(hash(prefab)) % 3) + 1
end

menv.AddPlayerPostInit(function(inst)
	if not table.contains(MODCHARACTERLIST, inst.prefab) or inst.regorged then
		return
	end
	
	local class = TUNING.GORGE.CLASSES[GetClass(inst.prefab)]
	
	if class.foodie then
		inst:AddTag("quagmire_foodie")
	end
	
	if class.fastpicker then
        inst:AddTag("fastpicker")
        inst:AddTag("quagmire_farmhand")
	end
	
	if not TheWorld.ismastersim then
		return
	end
	
	inst.starting_inventory = class.starting_inv
	
	if class.speed then
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "quagmire_speedup", class.speed)
	end
end)

menv.AddSimPostInit(function()
	for i, character in ipairs(MODCHARACTERLIST) do
		if not STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS[character] then
			STRINGS.QUAGMIRE_CHARACTER_DESCRIPTIONS[character] = STRINGS.GORGE.CHAR_DESC[GetClass(character)]
		end
	end
end)

