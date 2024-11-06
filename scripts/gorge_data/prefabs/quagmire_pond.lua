return {
	master_postinit = function(inst)
		inst:AddComponent("inspectable")

        inst:AddComponent("quagmire_saltpond")

		inst:AddComponent("fishable")
		inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)
		inst.components.fishable:AddFish("quagmire_salmon")		
	end,
}
