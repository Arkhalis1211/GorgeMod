local VARIATION_DATA = {
	{
		rng = 10,
		symbols = {
			{
				override = "pig_head",
			},
			
			{
				override = "pig_torso",
			},
		}
	},
	
	{
		rng = 2,
		symbols = {
			{
				override = "v_suspenders",
			},
			
			{
				override = "v_stache1",
				fixsymbol = "v_stache",
			},
			
			{
				override = "v_glove1",
				fixsymbol = "v_glove",
			},
			
			{
				override = "pig_arm",
			},
			
			{
				override = "pig_ear",
			},
		}
	},
	
	{
		rng = 3,
		symbols = {
			{
				override = "swap_hat",
			},
			
			{
				override = "v_apron1",
				fixsymbol = "v_apron",
			},
			
			{
				override = "v_hair1",
				fixsymbol = "v_hair",
			},
		}
	},
}

local function SetVariation(inst, data, variation)
    if variation > 0 then
		inst.AnimState:OverrideSymbol(data.override, "quagmire_swampig_build", (data.fixsymbol or data.override)..tostring(variation))
	else
		inst.AnimState:ClearOverrideSymbol(data.override)
	end
end

local function Init(inst)
	inst.components.knownlocations:RememberLocation("home", inst:GetPosition())
	for i, data in ipairs(VARIATION_DATA) do
		for k, s_data in pairs(data.symbols) do
			SetVariation(inst, s_data, math.random(0, data.rng))
		end
	end
end

local function ontalk(inst)
    inst.SoundEmitter:PlaySound("dontstarve/quagmire/creature/swamp_pig/talk")
end

local function onnear(inst, player)
	inst.components.talker:Chatter("SWAMPIG_TALK_TO_WILSON", math.random(1, #STRINGS.SWAMPIG_TALK_TO_WILSON))
end

return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")
		
		inst:RemoveTag("_named")
		
		inst:AddComponent("playerprox")
		inst.components.playerprox:SetOnPlayerNear(onnear)
		inst.components.playerprox:SetDist(4, 5)
		
		inst:AddComponent("locomotor") 
		inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED --5
		inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED --3

		inst:AddComponent("named")
		inst.components.named.possiblenames = STRINGS.SWAMPIGNAMES
		inst.components.named:PickNewName()

		inst:AddComponent("knownlocations")

		inst:SetBrain(require("brains/swamppigbrain"))
		inst:SetStateGraph("SGswamppig")
		
		inst:ListenForEvent("ontalk", ontalk)
		
		inst:DoTaskInTime(0, Init)
	end,
}
