local function UpdateStage(inst, new)
	if inst.stage ~= new then
		inst.stage = new
		
		SpawnAt("splash_green", inst)
		
		if new == 2 then
			inst.components.skinner:SetSkinMode("powerup", "wurt_stage2")
			-- inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/transform_to")
		else
			inst.components.skinner:SetSkinMode("normal_skin", "wurt")
			-- inst.SoundEmitter:PlaySound("dontstarve/characters/wurt/transform_from")
		end
	end
end

return {
	master_postinit = function(inst)
		inst.stage = 1
	
		inst:RemoveComponent("foodaffinity")
		inst:RemoveComponent("itemaffinity")
	
		inst.components.locomotor:SetFasterOnGroundTile(GROUND.MARSH, nil)
		inst.components.locomotor:SetFasterOnGroundTile(GROUND.QUAGMIRE_PEATFOREST, true)
		
		inst:ListenForEvent("locomote", function(inst)
			local tile = TheWorld.Map:GetTileAtPoint(inst.Transform:GetWorldPosition())
			UpdateStage(inst, tile == GROUND.QUAGMIRE_PEATFOREST and 2 or 1)
		end)
	end,
}
